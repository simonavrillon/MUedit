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
Gains        = cell(1, nTrack);
nADBit       = cell(1, nTrack);
PowerSupply  = cell(1, nTrack);
Fsample      = cell(1, nTrack);
Path         = cell(1, nTrack);
nChannel     = cell(1, nTrack);
startIndex   = cell(1, nTrack);
TotChInFile  = cell(1, nTrack);
SampleSize   = cell(1, nTrack);
Title        = cell(1, nTrack);

isControl    = false(1, nTrack);
isQuaternion = false(1, nTrack);
isEMG        = false(1, nTrack);

signal.gridname      = {};
signal.muscle        = {};
signal.auxiliaryname = {};

% Parse per-track XML metadata
for n = 1:nTrack
    Gains{n}       = str2double(TI{n}.Gain.Text);
    nADBit{n}      = str2double(TI{n}.ADC_Nbits.Text);
    PowerSupply{n} = str2double(TI{n}.ADC_Range.Text);
    Fsample{n}     = str2double(TI{n}.SamplingFrequency.Text);
    Path{n}        = TI{n}.SignalStreamPath.Text;
    nChannel{n}    = str2double(TI{n}.NumberOfChannels.Text);
    startIndex{n}  = str2double(TI{n}.AcquisitionChannel.Text);
    TotChInFile{n} = str2double(TI{n}.TotalChannelsInFile.Text);

    % Title: <Title> element, fall back to Description.Name
    if isfield(TI{n}, 'Title') && isfield(TI{n}.Title, 'Text')
        Title{n} = TI{n}.Title.Text;
    elseif isfield(TI{n}, 'Description') && isfield(TI{n}.Description, 'Name')
        Title{n} = TI{n}.Description.Name.Text;
    else
        Title{n} = '';
    end

    % SampleSize (bytes per sample): default to 4 (int32) if not present
    if isfield(TI{n}, 'SampleSize') && isfield(TI{n}.SampleSize, 'Text')
        SampleSize{n} = str2double(TI{n}.SampleSize.Text);
    else
        SampleSize{n} = 4;
    end

    % IsControl
    if isfield(TI{n}, 'IsControl') && isfield(TI{n}.IsControl, 'Text') && ...
       strcmpi(TI{n}.IsControl.Text, 'true')
        isControl(n) = true;
    end

    % IsQuaternion: check Title and Description.Name (matches Python's _track_is_quaternion)
    descName = '';
    if isfield(TI{n}, 'Description') && isfield(TI{n}.Description, 'Name') && ...
       isfield(TI{n}.Description.Name, 'Text')
        descName = TI{n}.Description.Name.Text;
    end
    if contains(Title{n}, 'Quaternion', 'IgnoreCase', true) || ...
       contains(descName,  'Quaternion', 'IgnoreCase', true)
        isQuaternion(n) = true;
    end

    % EMG: not control, not quaternion, adc_bits > 0
    if ~isControl(n) && ~isQuaternion(n) && nADBit{n} > 0
        isEMG(n) = true;
        % Extract grid name from Description.SensorType via regexp (e.g. "HD08MM1305")
        gridLabel = extractGridName(TI{n});
        if isempty(gridLabel)
            gridLabel = 'Unknown';
            warning('OpenOTB4: could not determine grid type for track %d, set to ''Unknown''.', n);
        end
        signal.gridname{end+1} = gridLabel;
    end
end

if ~any(isEMG) && ~any(isQuaternion)
    rmdir('tmpopen', 's');
    error('OpenOTB4:noData', 'No EMG or Quaternion tracks found in %s.', file);
end

% Load signal data: group by sig file, read once per file, slice per track
uniquePaths = unique(Path, 'stable');

emg_blocks = cell(1, sum(isEMG));
emgIdx     = 0;
nQuatCh    = sum(cellfun(@(n,q) n*q, nChannel, num2cell(isQuaternion)));
quat_data  = zeros(nQuatCh, 0);
quatRow    = 0;
fsamp      = [];

for f = 1:length(uniquePaths)
    sigName = uniquePaths{f};
    idx     = find(strcmp(Path, sigName));
    sigPath = fullfile('tmpopen', sigName);
    if ~exist(sigPath, 'file'); continue; end

    totCh = TotChInFile{idx(1)};
    ss    = SampleSize{idx(1)};
    if ss == 4
        dtype = 'int32';
    else
        dtype = 'int16';
    end

    h   = fopen(sigPath, 'r');
    raw = fread(h, [totCh, Inf], dtype);
    fclose(h);

    for k = idx
        acqCh = startIndex{k};          % 0-based index from XML
        nCh   = nChannel{k};
        block = double(raw(acqCh+1 : acqCh+nCh, :));

        if isQuaternion(k)
            % Quaternions stored as int32 scaled by 32768 -> normalize to [-1, 1]
            block = block / 32768.0;
            nS    = size(block, 2);
            if size(quat_data, 2) < nS
                quat_data(:, end+1:nS) = 0;
            end
            quat_data(quatRow+1 : quatRow+nCh, 1:nS) = block;
            quatRow = quatRow + nCh;

        elseif isEMG(k) && nADBit{k} > 0
            % EMG: apply physical scaling
            block  = block * PowerSupply{k} / (2^nADBit{k}) * 1000 / Gains{k};
            emgIdx = emgIdx + 1;
            emg_blocks{emgIdx} = block;
            if isempty(fsamp)
                fsamp = Fsample{k};
            end
        end
    end
end

if emgIdx == 0
    rmdir('tmpopen', 's');
    error('OpenOTB4:noEMG', 'No EMG signal blocks found in %s.', file);
end
emg_blocks = emg_blocks(1:emgIdx);

% Truncate all blocks to minimum length and concatenate
minLen     = min(cellfun(@(b) size(b,2), emg_blocks));
signal.data = cell2mat(cellfun(@(b) b(:,1:minLen), emg_blocks, 'UniformOutput', false)');

if quatRow > 0
    signal.auxiliary = quat_data(1:quatRow, 1:minLen);
    for i = 1:size(signal.auxiliary, 1)
        signal.auxiliaryname{i} = 'Quaternions';
    end
end

% Sampling rate
if isempty(fsamp)
    fsamp = Fsample{1};
end
signal.fsamp = fsamp;
signal.nChan = size(signal.data, 1);
signal.ngrid = length(signal.gridname);

dlgbox = [];
% Clean Folder
rmdir('tmpopen','s');

end

% -------------------------------------------------------------------------
function gridName = extractGridName(track)
% Extract grid model name (e.g. "HD08MM1305") from OTB4 track XML struct.
% Mirrors inferGridNameFromSensorType in openOTB4N.m.
%
% Priority:
%  1. Description.SensorType  — contains verbose string with model embedded
%  2. StringsDescriptions.OriginalSensor
%  3. Description.Name        — often "Unknown", used as last resort
%  4. AdapterModel            — StringsDescriptions.OriginalAdapter fallback

    gridName = '';
    pattern = '(HD\d{2}MM\d{4}|GR\d{2}MM\d{4}|ELSCH\d+NM\d+|MYOMRF-\d+X\d+|MYOMNP-\d+X\d+)';

    % 1. Description.SensorType
    if isfield(track, 'Description') && isfield(track.Description, 'SensorType')
        st = track.Description.SensorType;
        if isfield(st, 'Text'), st = st.Text; end
        if ischar(st)
            tok = regexp(upper(st), pattern, 'match', 'once');
            if ~isempty(tok); gridName = tok; return; end
        end
    end

    % 2. StringsDescriptions.OriginalSensor
    if isfield(track, 'StringsDescriptions') && isfield(track.StringsDescriptions, 'OriginalSensor')
        os = track.StringsDescriptions.OriginalSensor;
        if isfield(os, 'Text'), os = os.Text; end
        if ischar(os)
            tok = regexp(upper(os), pattern, 'match', 'once');
            if ~isempty(tok); gridName = tok; return; end
        end
    end

    % 3. Description.Name (might be "Unknown", but try anyway)
    if isfield(track, 'Description') && isfield(track.Description, 'Name')
        dn = track.Description.Name;
        if isfield(dn, 'Text'), dn = dn.Text; end
        if ischar(dn)
            tok = regexp(upper(dn), pattern, 'match', 'once');
            if ~isempty(tok); gridName = tok; return; end
        end
    end

    % 4. Nothing found — return empty, caller will assign 'Unknown'
end
