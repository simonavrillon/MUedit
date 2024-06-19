%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To load EMG signals from otb+ files

% Input: 
% path: path name
% file: file name
% dialog: 1 = Open a dialog window with the configuration of the recording

% Output:
% signal: structure with the EMG signals
% dlgbox: dialog window with the configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dlgbox, signal] = openOTBplus(path, file, dialog)
%Reads files of type OTB+, extrapolating the information on the signal,
%in turn uses the xml2struct function to read file.xml and allocate them in an easily readable Matlab structure.
% Isn't possible to read OTB files because the internal structure of these
% files is different.

mkdir('tmpopen');

untar([path file],'tmpopen');
signals = dir(fullfile('tmpopen','*.sig'));

PowerSupply = 3.3;
abs = readXMLotb(fullfile('.','tmpopen', [signals.name(1:end-4) '.xml']));
Fsample=str2double(abs.Device.Attributes.SampleFrequency);
nChannel=str2double(abs.Device.Attributes.DeviceTotalChannels);
nADBit=str2double(abs.Device.Attributes.ad_bits);

Gains = zeros(1,nChannel);
Adapter = zeros(1,nChannel);
Posdev = zeros(1,nChannel);
Grid = cell(1,nChannel);
Muscle = cell(1,nChannel);

for nChild = 1:length(abs.Device.Channels.Adapter)
    localGain = str2double(abs.Device.Channels.Adapter{nChild}.Attributes.Gain);
    startIndex = str2double(abs.Device.Channels.Adapter{nChild}.Attributes.ChannelStartIndex);
    
    Channel = abs.Device.Channels.Adapter{nChild}.Channel;

    for nChan=1:length(Channel)
        if iscell(Channel)
            ChannelAtt = Channel{nChan}.Attributes;
        elseif isstruct(Channel)
            ChannelAtt = Channel(nChan).Attributes;
        end

        Description = ChannelAtt.Description;
        idx = str2double(ChannelAtt.Index);

        if contains(Description,'General') || contains(Description,'iEMG')
            Adapter(startIndex+idx+1) = 1;
        elseif contains(Description,'16')
            Adapter(startIndex+idx+1) = 2;
        elseif contains(Description,'32')
            Adapter(startIndex+idx+1) = 3;
        elseif contains(Description,'64')
            Adapter(startIndex+idx+1) = 4;
        elseif contains(Description,'Splitter') 
            Adapter(startIndex+idx+1) = 4;
        else
            Adapter(startIndex+idx+1) = 5;
        end

        if contains(abs.Device.Attributes.Name, 'QUATTROCENTO')
            Adpatidx = ChannelAtt.Prefix;
            if contains(Adpatidx,'MULTIPLE IN')
                Posdev(startIndex+idx+1) = str2double(Adpatidx(13)) + 2;
            elseif contains(Adpatidx,'IN')
                Posdev(startIndex+idx+1) = str2double(Adpatidx(4));
                if Posdev(startIndex+idx+1) < 5
                    Posdev(startIndex+idx+1) = 1;
                else
                    Posdev(startIndex+idx+1) = 2;
                end
            end
        else
            Posdev(startIndex+idx+1) = str2double(abs.Device.Channels.Adapter{nChild}.Attributes.AdapterIndex);
        end
        Gains(startIndex+idx+1) = localGain;
        Grid{startIndex+idx+1} = ChannelAtt.ID;
        Muscle{startIndex+idx+1} = ChannelAtt.Muscle;
    end
end

h=fopen(fullfile('tmpopen',signals.name),'r');
data=fread(h,[nChannel Inf], 'short'); 
fclose(h);

for nCh=1:nChannel
    data(nCh,:) = data(nCh,:)*PowerSupply/(2^nADBit)*1000/Gains(nCh);
end

signal.data = data(Adapter == 3 | Adapter == 4,:);
signal.auxiliary = data(Adapter == 5,:);

if ~isempty(data(Adapter < 3,:))
    signal.emgnotgrid = data(Adapter < 3,:);
end

nch = 1;
nch2 = 1;
for i = 1:length(Grid)
    if Adapter(i) == 3 || Adapter(i) == 4
        Grid2{nch} = Grid{i};
        Muscle2{nch} = Muscle{i};
        nch = nch + 1;
    elseif Adapter(i) == 5
        signal.auxiliaryname{nch2} =  Grid{i};
        nch2 = nch2 + 1;
    end
end
clearvars Grid Muscle
Grid = Grid2;
Muscle = Muscle2;

signal.fsamp=Fsample;
signal.nChan=nChannel;
Posdev = Posdev(Adapter == 3 | Adapter == 4);

idxa = unique(Posdev);
idxb = unique(Muscle);

if length(idxa)>=length(idxb)
    signal.ngrid = length(idxa);  
    for i=1:signal.ngrid
        idx = find(Posdev == (idxa(i)), 1, 'First');
        signal.gridname{i} = Grid{idx};
        signal.muscle{i} = Muscle{idx};
    end
    
    if ~contains(abs.Device.Attributes.Name, 'QUATTROCENTO')
        idxa = 1:1:length(idxa);
        idxa = idxa+2;
    end

else
    signal.ngrid = length(idxb);  
    for i=1:signal.ngrid
        idx = find(strcmp(Muscle2, idxb{i}));
        idx = idx(1);
        signal.gridname{i} = Grid{idx};
        signal.muscle{i} = Muscle{idx};
    end
end

% if the signals were recorded with a feedback generated by OTBiolab+,
% get the target and the path performed by the participant
target = dir(fullfile('tmpopen','*.sip'));

if ~isempty(target)
    h=fopen(fullfile('tmpopen',target(2).name),'r');
    data1=fread(h,[1 Inf],'float64');
    fclose(h);
    data1 = data1(1:size(data,2));
    signal.path = data1;

    h=fopen(fullfile('tmpopen',target(3).name),'r');
    data2=fread(h,[1 Inf],'float64');
    fclose(h);
    data2 = data2(1:size(data,2));
    signal.target = data2;

    if isfield(signal, 'auxiliary')
        signal.auxiliary = [signal.auxiliary; signal.path; signal.target];
        signal.auxiliaryname = cat(2, signal.auxiliaryname, {'Path'}, {'Target'});
    else
        signal.auxiliary = [signal.path; signal.target];
        signal.auxiliaryname = cat(2, {'Path'}, {'Target'});
    end
end

rmdir('tmpopen','s');

if dialog == 1
    % Set the configuration
    dlgbox = Quattrodlg;
    dlgbox.EditField_nchan.Value = size(signal.data,1);
    
    if find(idxa == 1)
        dlgbox.CheckBox_S1.Value = 1;
        dlgbox.CheckBox_S1.Visible = 'off';
        dlgbox.Splitter1Panel.Enable = 'on';
        dlgbox.Lamp_S1.Color = 'Green';
        dlgbox.DropDown_S1.Value = signal.gridname{idxa == 1};
        dlgbox.EditField_S1.Value = signal.muscle{idxa == 1};
    end
    
    if find(idxa == 2)
        dlgbox.CheckBox_S2.Value = 1;
        dlgbox.CheckBox_S2.Visible = 'off';
        dlgbox.Splitter2Panel.Enable = 'on';
        dlgbox.Lamp_S2.Color = 'Green';
        dlgbox.DropDown_S2.Value = signal.gridname{idxa == 2};
        dlgbox.EditField_S2.Value = signal.muscle{idxa == 2};
    end
    
    if find(idxa == 3)
        dlgbox.CheckBox_M1.Value = 1;
        dlgbox.CheckBox_M1.Visible = 'off';
        dlgbox.MI1Panel.Enable = 'on';
        dlgbox.Lamp_M1.Color = 'Green';
        dlgbox.DropDown_M1.Value = signal.gridname{idxa == 3};
        dlgbox.EditField_M1.Value = signal.muscle{idxa == 3};
    end
    
    if find(idxa == 4)
        dlgbox.CheckBox_M2.Value = 1;
        dlgbox.CheckBox_M2.Visible = 'off';
        dlgbox.MI2Panel.Enable = 'on';
        dlgbox.Lamp_M2.Color = 'Green';
        dlgbox.DropDown_M2.Value = signal.gridname{idxa == 4};
        dlgbox.EditField_M2.Value = signal.muscle{idxa == 4};
    end
    
    if find(idxa == 5)
        dlgbox.CheckBox_M3.Value = 1;
        dlgbox.CheckBox_M3.Visible = 'off';
        dlgbox.MI3Panel.Enable = 'on';
        dlgbox.Lamp_M3.Color = 'Green';
        dlgbox.DropDown_M3.Value = signal.gridname{idxa == 5};
        dlgbox.EditField_M3.Value = signal.muscle{idxa == 5};
    end
    
    if find(idxa == 6)
        dlgbox.CheckBox_M4.Value = 1;
        dlgbox.CheckBox_M4.Visible = 'off';
        dlgbox.MI4Panel.Enable = 'on';
        dlgbox.Lamp_M4.Color = 'Green';
        dlgbox.DropDown_M4.Value = signal.gridname{idxa == 6};
        dlgbox.EditField_M4.Value = signal.muscle{idxa == 6};
    end    
else
    dlgbox = [];
end
end
