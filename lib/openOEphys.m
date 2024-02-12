%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To load EMG signals recorded with the Open Ephys GUI (structure.oebin)

% Input: 
% path: path name
% file: file name
% dialog: 1 = Open a dialog window with the configuration of the recording

% Output:
% signal: structure with the EMG signals
% dlgbox: dialog window with the configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dlgbox, signal] = openOEphys(path, file, dialog)

    % Create a session (loads all data from the most recent recording)
    info = jsondecode(fileread([path file]));

    % Get the path with the data
    directory = fullfile(path, 'continuous', info.continuous.folder_name);
    
    signal.fsamp = info.continuous.sample_rate;
    signal.nChan = info.continuous.num_channels;
    
    for i = 1:signal.nChan
        name{i} = info.continuous.channels(i).channel_name;
        if contains(name{i},'CH')
            sigtype(i) = 1;
        elseif contains(name{i},'ADC')
            sigtype(i) = 2;
        end
    end

    time = readNPY(fullfile(directory, 'timestamps.npy'));
    num_samples = readNPY(fullfile(directory, 'sample_numbers.npy'));

    data = memmapfile(fullfile(directory, 'continuous.dat'), 'Format', 'int16');
    samples = double(reshape(data.Data, [signal.nChan, length(data.Data) / signal.nChan]));
    
    for i = 1:signal.nChan
        samples(i,:) = samples(i,:) * info.continuous.channels(i).bit_volts;
    end

    signal.data = samples(sigtype == 1, :);
    signal.auxiliary = samples(sigtype == 2, :);
    
    idx = find(sigtype == 2);
    for i = 1: length(idx)
        signal.auxiliaryname{i} = name{idx(i)};
    end

    if dialog == 1
        dlgbox = OEphysdlg;
        dlgbox.EditField_nchan.Value = size(signal.data,1);
        dlgbox.EditField_Ain.Value = size(signal.auxiliary,1);
        dlgbox.EditField_Din.Value = 0;
    else
        dlgbox = [];
    end
end
