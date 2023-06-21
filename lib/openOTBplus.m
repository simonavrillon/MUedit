%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To import all the data from OTB files and reformat it for decomposition

% Input: 
% pathname: path of the folder where the files are saved
% filename: name of the OTB file
% ref_exist: % if target and force were recorded ref_exist = 1; if not, ref_exist = 0

% Output:
% signal: struct with all the data from OTB
%    signal.data = all the data recorded (EMG, force, aux output)
%    signal.fsamp = sampling freauency
%    signal.nChan = number of EMG channels
%    signal.ngrid = number of grids of electrodes
%    signal.gridname{i} = name of the grid of electrodes (one cell per
%    grid)
%    signal.muscle{i} = name of the muscle under the grid of electrode (one
%    cell per grid)

% if ref_exist = 1
%    signal.path = normalized force developed by the participant
%    signal.target = target displayed to the participant

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signal = openOTBplus(pathname, filename, ref_exist, nbelectrodes)

    % Create a new folder to uncompress otb+ files
    mkdir('tempopen');
    cd('tempopen');
    untar([pathname filename]);
    
    % Get all the information from the trial using the xml file (same name
    % as the signal file)
    signals=dir('*.sig');
    abstracts=[signals(1).name(1:end-4) '.xml'];
    abs = readXMLotb(abstracts);
    
    nChannel=str2num(abs.Attributes(4).Value);
    Fsample=str2num(abs.Attributes(8).Value);
    nADBit=str2num(abs.Attributes(10).Value);
        
    h=fopen(signals(1).name,'r');
    data=fread(h,[nChannel Inf],'short');
    fclose(h);
    
    % convert EMG singals in µV
    for nCh=1:nChannel
        data(nCh,:)=data(nCh,:)*5/(2^nADBit)*1000;
    end
    
    signal.data=data;
    signal.fsamp=Fsample;
    signal.nChan=nChannel;
    signal.ngrid = floor(signal.nChan/nbelectrodes);
    
    for i=1:signal.ngrid
        signal.gridname{i} = abs.Children(2).Children(2*i).Children(2).Attributes(3).Value;
        signal.muscle{i} = abs.Children(2).Children(2*i).Children(2).Attributes(5).Value;
    end
    
    % if the signals were recorded with a feedback generated by OTBiolab+,
    % get the target and the path performed by the participant
    if ref_exist == 1
        target=dir('*.sip');
        h=fopen(target(2).name,'r');
        data1=fread(h,[1 Inf],'float64');
        fclose(h);
        data1 = data1(1:size(data,2));
        signal.path = data1;

        h=fopen(target(3).name,'r');
        data2=fread(h,[1 Inf],'float64');
        fclose(h);
        data2 = data2(1:size(data,2));
        signal.target = data2;
    end
    
    theFiles = dir;
    for k = 1 : length(theFiles)
      baseFileName = theFiles(k).name;
      delete(baseFileName);
    end
    
    cd ..;
    rmdir('tempopen');

end