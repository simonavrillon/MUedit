%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To load EMG signals from otb4 files

% Input: 
% path: path name
% file: file name
% dialog: 1 = Open a dialog window with the configuration of the recording

% Output:
% signal: structure with the EMG signals
% dlgbox: dialog window with the configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dlgbox, signal] = OpenOTB4(path, file, dialog)

% Make new folder
mkdir('tmpopen');  

% Extract contents of tar file
untar([path file],'tmpopen');

% Read XML
abstracts = 'Tracks_000.xml';
abs = xml2struct(fullfile('tmpopen', abstracts));
TI = abs.ArrayOfTrackInfo.TrackInfo;
nTrack = length(TI);

% Pre-allocate metadata arrays
Gains       = cell(1, nTrack);
nADBit      = cell(1, nTrack);
PowerSupply = cell(1, nTrack);
Fsample     = cell(1, nTrack);
Path        = cell(1, nTrack);
nChannel       = cell(1, nTrack);
startIndex     = cell(1, nTrack);
ChannelsInBlock = cell(1, nTrack);
Title          = cell(1, nTrack);

isEMG        = false(1, nTrack);  % tracks whose title starts with "IN"
isAUX        = false(1, nTrack);  % tracks whose title starts with "AUX" or contains "Quaternions"
signal.gridname = {};
signal.muscle   = {};
signal.auxiliaryname = {};

% Read device name once (same for all tracks)
device = textscan(TI{1}.Device.Text, '%s', 1, 'Delimiter', ';');
device = device{1}{1};

% Parse per-track XML metadata
for n = 1:nTrack
    Gains{n}       = str2double(TI{n}.Gain.Text);
    nADBit{n}      = str2double(TI{n}.ADC_Nbits.Text);
    PowerSupply{n} = str2double(TI{n}.ADC_Range.Text);
    Fsample{n}     = str2double(TI{n}.SamplingFrequency.Text);
    Path{n}        = TI{n}.SignalStreamPath.Text;
    nChannel{n}        = str2double(TI{n}.NumberOfChannels.Text);
    startIndex{n}      = str2double(TI{n}.AcquisitionChannel.Text);
    ChannelsInBlock{n} = str2double(TI{n}.ChannelsInBlock.Text);
    Title{n} = TI{n}.Description.Name.Text;
    SubTitle{n} = TI{n}.SubTitle.Text;

    % EMG: title starts with "HD"
    if strncmpi(Title{n}, 'HD', 2) || strncmpi(Title{n}, 'GR', 2)
        isEMG(n) = true;
        signal.gridname{end+1} = Title{n};
    end

    % AUX: title starts with "AUX" or contains "Quaternions"
    if strncmpi(Title{n}, 'AUX', 3) || strncmpi(SubTitle{n}, 'AUX', 3) || contains(Title{n}, 'Quaternions', 'IgnoreCase', true)
        isAUX(n) = true;
    end
end

if ~any(isEMG) && ~any(isAUX)
    rmdir('tmpopen', 's');
    error('OpenOTB4:noData', 'No EMG or AUX tracks found in %s.', file);
end

% Load signal data: read each .sig file once, then slice per track
data    = [];
emgRows = [];
auxRows = [];
r1      = 0;

if strcmp(device, 'Novecento+')
    % Each .sig file may hold multiple tracks; group and read once per file
    uniquePaths = unique(Path, 'stable');
    for f = 1:length(uniquePaths)
        sigName  = uniquePaths{f};
        idx      = find(strcmp(Path, sigName));
        if ~any(isEMG(idx) | isAUX(idx)); continue; end
        nChFile  = ChannelsInBlock{idx(1)};

        h   = fopen(fullfile('tmpopen', sigName), 'r');
        raw = fread(h, [nChFile, Inf], 'int32');
        fclose(h);
        nSamples = size(raw, 2);

        for k = idx
            if ~(isEMG(k) || isAUX(k)); continue; end
            block = raw(startIndex{k}+1 : startIndex{k}+nChannel{k}, :);
            if nADBit{k} > 0
                block = block * PowerSupply{k} / (2^nADBit{k}) * 1000 / Gains{k};
            end
            r0 = r1 + 1;  r1 = r1 + nChannel{k};
            data(r0:r1, 1:nSamples) = block;
            if isEMG(k)
                emgRows = [emgRows, r0:r1];
            elseif isAUX(k)
                auxRows = [auxRows, r0:r1];
            end
        end
    end
else
    % Standard devices: single .sig file, int16, all tracks interleaved
    sigFiles = dir(fullfile('tmpopen', '*.sig'));
    if isempty(sigFiles)
        error('OpenOTB4:noSigFile', 'No .sig file found in archive.');
    end
    TotCh = sum(cell2mat(nChannel));

    h   = fopen(fullfile('tmpopen', sigFiles(1).name), 'r');
    raw = fread(h, [TotCh, Inf], 'short');
    fclose(h);
    nSamples = size(raw, 2);

    for n = 1:nTrack
        if ~(isEMG(n) || isAUX(n)); continue; end
        block = raw(startIndex{n}+1 : startIndex{n}+nChannel{n}, :);
        if nADBit{n} > 0
            block = block * PowerSupply{n} / (2^nADBit{n}) * 1000 / Gains{n};
        end
        r0 = r1 + 1;  r1 = r1 + nChannel{n};
        data(r0:r1, 1:nSamples) = block;
        if isEMG(n)
            emgRows = [emgRows, r0:r1];
        elseif isAUX(n)
            auxRows = [auxRows, r0:r1];
        end
    end
end

signal.data = data(emgRows, :);
if ~isempty(auxRows)
    signal.auxiliary = data(auxRows, :);
end

% Sampling rate from first EMG track; fall back to track 1
emgTrack = find(isEMG, 1);
if ~isempty(emgTrack)
    signal.fsamp = Fsample{emgTrack};
else
    signal.fsamp = Fsample{1};
end

signal.nChan = size(signal.data, 1);
signal.ngrid = length(signal.gridname);

if isfield(signal, 'auxiliary')
    for i = 1:signal.ngrid*4
        signal.auxiliaryname{i} = 'Quaternions';
    end
    auxn=1;
    for j = i+1:size(signal.auxiliary,1)
        signal.auxiliaryname{j} = ['AUX' num2str(auxn)];
        auxn = auxn + 1;
    end
end

dlgbox = [];
% Clean Folder
rmdir('tmpopen','s');

end
