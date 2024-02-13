%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To load EMG signals recorded with the RHD Recording System from Intan (info.rhd)

% Input: 
% path: path name
% file: file name
% dialog: 1 = Open a dialog window with the configuration of the recording

% Output:
% signal: structure with the EMG signals
% dlgbox: dialog window with the configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dlgbox, signal] = openIntan(path, file, dialog)
    
    % Step 1: Get the configuration of the Intan board
    [amplifier_channels, board_adc_channels, board_dig_in_channels, frequency_parameters] = read_Intan_RHD_MUedit(path,file);
    
    % Step 2: Timestamp
    filetime = dir([path 'time.dat']);
    num_samples = filetime.bytes/4; % int32 = 4 bytes
    fid = fopen([path 'time.dat'], 'r');
    time = fread(fid, num_samples, 'int32');
    fclose(fid);
    time = time / frequency_parameters.amplifier_sample_rate; % sample rate from header file
    clearvars filetime
    
    % Step 3: Import the data
    % amplifier channels
    for i = 1:size(amplifier_channels,2)
        filename = dir([path '*' amplifier_channels(i).native_channel_name '*']);
        num_samples = filename.bytes/2; % int16 = 2 bytes
        fid = fopen([path filename.name], 'r');
        v = fread(fid, num_samples, 'int16');
        fclose(fid);
        signal.data(i,:) = v' * 0.195; % convert to microvolts
        clearvars v
    end
    
    % analog inputs
    ch = 1;
    for i = 1:size(board_adc_channels,2)
        filename = dir([path '*' board_adc_channels(i).native_channel_name '*']);
        num_samples = filename.bytes/2; % int16 = 2 bytes
        fid = fopen([path filename.name], 'r');
        v = fread(fid, num_samples, 'uint16');
        fclose(fid);
        signal.auxiliary(ch,:) = v';
        signal.auxiliaryname{ch} = board_adc_channels(i).custom_channel_name;
        ch = ch + 1;
        clearvars v
    end
    
    % digital inputs
    for i = 1:size(board_dig_in_channels,2)
        filename = dir([path '*' board_dig_in_channels(i).native_channel_name '*']);
        num_samples = filename.bytes/2; % int16 = 2 bytes
        fid = fopen([path filename.name], 'r');
        v = fread(fid, num_samples, 'uint16');
        fclose(fid);
        signal.auxiliary(ch,:) = v';
        signal.auxiliaryname{ch} = board_dig_in_channels(i).custom_channel_name;
        ch = ch + 1;
        clearvars v
    end
    
    % Step 4 Reorganize the structure for MUedit
    signal.fsamp = frequency_parameters.amplifier_sample_rate;
    ports = unique({amplifier_channels(:).port_prefix}); 
    signal.ngrid = length(unique([amplifier_channels(:).port_prefix]));
    for i = 1:signal.ngrid
        idxchan = find([amplifier_channels(:).port_prefix] == ports{i});
        if length(idxchan) < 16
            posgrid(idxchan) = 0;
            ports{i} = [];
        else
            posgrid(idxchan) = 1;
        end
    end
    signal.emgnotgrid = signal.data(posgrid==0,:);
    signal.data = signal.data(posgrid==1,:);
    signal.nChan = size(signal.data,1);
    ports = ports(~cellfun('isempty',ports));
        
    if dialog == 1
        dlgbox = Intandlg;
        dlgbox.EditField_nchan.Value = signal.nChan;
        dlgbox.EditField_Ain.Value = size(board_adc_channels,2);
        dlgbox.EditField_Din.Value = size(board_dig_in_channels,2);
        
        if sum(strcmpi('A', ports)) == 1
            dlgbox.Lamp_A1.Color = 'Green';
            dlgbox.PortA1Panel.Enable = 'on';
            dlgbox.CheckBox_A1.Value = 1;
            dlgbox.CheckBox_A1.Visible = 'off';
        end
        
        if sum(strcmpi('B', ports)) == 1
            dlgbox.Lamp_B1.Color = 'Green';
            dlgbox.PortB1Panel.Enable = 'on';
            dlgbox.CheckBox_B1.Value = 1;
            dlgbox.CheckBox_B1.Visible = 'off';
        end
        
        if sum(strcmpi('C', ports)) == 1
            dlgbox.Lamp_C1.Color = 'Green';
            dlgbox.PortC1Panel.Enable = 'on';
            dlgbox.CheckBox_C1.Value = 1;
            dlgbox.CheckBox_C1.Visible = 'off';
        end
        
        if sum(strcmpi('D', ports)) == 1
            dlgbox.Lamp_D1.Color = 'Green';
            dlgbox.PortD1Panel.Enable = 'on';
            dlgbox.CheckBox_D1.Value = 1;
            dlgbox.CheckBox_D1.Visible = 'off';
        end 
    else
        dlgbox = [];
    end
end
