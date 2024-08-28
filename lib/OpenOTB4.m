% Reads files of type OTB4, extrapolating the information on the signal,
% in turn uses the xml2struct function to read file.xml 
% and allocate them in an easily readable Matlab structure.
% It isn't possible to read OTB and OTB+ files because the 
% internal structure of these files is different.

function [dlgbox, signal] = openOTB4(path, file, dialog)

% Make new folder
mkdir('tmpopen');  
%cd('tempopen');

% Extract contents of tar file
untar([path file],'tmpopen');
signals = dir(fullfile('tmpopen','*.sig')); %List folder contents and build full file name from parts

nChannel{1}=0;
nCh=zeros(1,length(signals)-1);
Fs=zeros(1,length(signals)-1);
abstracts=['Tracks_000.xml'];
abs = xml2struct(fullfile('.','tmpopen',abstracts));
AUX_index = -1;
EMG_index = zeros(1,[length(abs.ArrayOfTrackInfo.TrackInfo)]);
EMG_nchannel = zeros(1,[length(abs.ArrayOfTrackInfo.TrackInfo)]);
counter = 1;
AUX_Subtitle = "";
for ntype=1:length(abs.ArrayOfTrackInfo.TrackInfo)
        device = textscan(abs.ArrayOfTrackInfo.TrackInfo{1,1}.Device.Text, '%s', 1, 'Delimiter', ';');
        device = device{1}{1};
        Gains{ntype}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.Gain.Text);
        nADBit{ntype}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.ADC_Nbits.Text);
        PowerSupply{ntype}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.ADC_Range.Text);
        Fsample{ntype}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.SamplingFrequency.Text);
        Path{ntype}=abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.SignalStreamPath.Text;
        nChannel{ntype+1}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.NumberOfChannels.Text);
        startIndex{ntype}=str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.AcquisitionChannel.Text);
        Title{ntype}=abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.Title.Text;
    
        channels = str2num(abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.NumberOfChannels.Text);
        %there is no adapter index in the new .otb4 file so we create
        %something similar using available information
        if(channels == 32 || channels == 64)
            for i = counter:(counter + channels - 1)
                EMG_index(i) = startIndex{ntype}; %contains index of connector (adapter)
                EMG_nchannel(i) = channels; % contains n° of channels in that adapter
            end            
            counter = counter + channels;
        end
        if Title{ntype} == "Direct connection to Auxiliary Input"
            AUX_index = startIndex{ntype};
            AUX_Subtitle = abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.SubTitle.Text;        
        end   
        
        if(channels >= 32) 
            signal.gridname{ntype} = abs.ArrayOfTrackInfo.TrackInfo{1,ntype}.SubTitle.Text;
        end
end 

TotCh = sum(cell2mat(nChannel));

if strcmp(device,'Novecento+')
    for i = 2:length(signals)
        flag = false;
        for j = 1:length(Path)
            if(strcmp(Path(j), signals(i).name))
                nCh(i-1) = nCh(i-1) + nChannel{j+1};
                Fs(i-1) = Fsample{j};
                Psup(i-1) = PowerSupply{j};
                ADbit(i-1) = nADBit{j};
                Gain(i-1) = Gains{j};
                flag = true;
            end
        end
        if flag == true
            h=fopen(fullfile('tmpopen', signals(i).name),'r');
            data = fread(h,[nCh(i-1) Inf],'int32');
            fclose(h);

            Data{i-1}=data;
            figs{i-1}=figure;
            for Ch=1:nCh(i-1)
                data(Ch,:)=data(Ch,:)*Psup(i-1)/(2^ADbit(i-1))*1000/Gain(i-1);
            end  
        end
    end
else
    for nSig = 1%:length(signals)
        h=fopen(fullfile('tmpopen', signals(nSig).name),'r');
        data=fread(h,[TotCh Inf],'short'); 
        fclose(h);
     
        Data{nSig}=data;
        figs{nSig}=figure;

        sumidx = nChannel{1};
        idx = zeros(1, length(nChannel));
        idx(1) = sumidx;
        for i = 2:length(nChannel)
            sumidx = sumidx + nChannel{i};
            idx(i) = sumidx;
        end
        for ntype=2:length(abs.ArrayOfTrackInfo.TrackInfo)+1
            for nCh=idx(ntype-1)+1:idx(ntype)
                data(nCh,:)=data(nCh,:)*PowerSupply{ntype-1}/(2^nADBit{ntype-1})*1000/Gains{ntype-1};
            end
        end
    end   
end

Gains = zeros(1,TotCh);
Adapter = zeros(1,TotCh);
Posdev = zeros(1,TotCh);
Grid = cell(1,TotCh);
Muscle = cell(1,TotCh);

%fill the adapter array similarly to the openOTB+ script
Adapter = zeros(1,TotCh);
for i = 1:length(EMG_index)
    value = 3; % 32 channels
    if EMG_nchannel(i) == 64
        value = 4; % 64 channels
    end
    Adapter(i) = value;        
end

signal.data = data(Adapter == 3 | Adapter == 4,:);
if AUX_index ~= -1 
    signal.auxiliary = data(AUX_index,:);
end

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
%Muscle = Muscle2; removed because muscle are missing from OTB4 file at the
%moment

signal.fsamp=Fsample{1};
signal.nChan=TotCh;
Posdev = Posdev(Adapter == 3 | Adapter == 4);

idxa = unique(Posdev);
%idxb = unique(Muscle);

signal.ngrid = length(signal.gridname);
%signal.ngrid = length(idxa);  
%for i=1:signal.ngrid
    %idx = find(Posdev == (idxa(i)), 1, 'First');
    %signal.gridname{i} = Grid{idx};
    %signal.muscle{i} = Muscle{idx};
%end

if ~contains(device, 'QUATTROCENTO')
    idxa = 1:1:length(idxa);
    idxa = idxa+2;
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
        signal.auxiliaryname = AUX_Subtitle; % cat(2, signal.auxiliaryname, {'Path'}, {'Target'});
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
