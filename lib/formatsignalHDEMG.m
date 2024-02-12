%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To get the 2d coordinates of EMG channels over the grid
% To check the EMG signals (automatic or visual)

% Input: 
% signal: row-wise signal
% gridname: name of the OTB grid of electrodes
% check EMG: 1 = Visual checking of EMG channels

% Output:
% coordinates: x and y coordinates of each electrode
% IED: inter electrode distance
% discardChannelsVec: vector of discarded channels after visual checking (1 = discarded channel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [coordinates, IED, discardChannelsVec, emgtype] = formatsignalHDEMG(signal, gridname, fsamp, checkEMG)

for i = 1:length(gridname)
    % Define the parameters depending on the name of the grid
    if contains(gridname{i}, 'GR04MM1305') || contains(gridname{i}, 'HD04MM1305')
        ElChannelMap = ([1 25 26 51 52; ...
                       1 24 27 50 53; ...  
                       2 23 28 49 54; ...
                       3 22 29 48 55; ...
                       4 21 30 47 56; ...
                       5 20 31 46 57; ... 
                       6 19 32 45 58 ; ...
                       7 18 33 44 59; ...
                       8 17 34 43 60; ...
                       9 16 35 42 61; ...
                       10 15 36 41 62; ...
                       11 14 37 40 63; ...
                       12 13 38 39 64]);
       
        if contains(gridname{i}, 'HD')
            ElChannelMap = fliplr(ElChannelMap);
        end
        discardChannelsVec{i} = zeros(64,1);
        nbelectrodes = 64;
        IED(i) = 4;
        emgtype(i) = 1;
            
    elseif contains(gridname{i}, 'GR08MM1305') || contains(gridname{i}, 'HD08MM1305')
        ElChannelMap = ([1 25 26 51 52; ...
                       1 24 27 50 53; ...
                       2 23 28 49 54; ...
                       3 22 29 48 55; ...
                       4 21 30 47 56; ...
                       5 20 31 46 57; ... 
                       6 19 32 45 58 ; ...
                       7 18 33 44 59; ...
                       8 17 34 43 60; ...
                       9 16 35 42 61; ...
                       10 15 36 41 62; ...
                       11 14 37 40 63; ...
                       12 13 38 39 64]); 

        if contains(gridname{i}, 'HD')
            ElChannelMap = fliplr(ElChannelMap);
        end
        discardChannelsVec{i} = zeros(64,1);
        nbelectrodes = 64;
        IED(i) = 8;
        emgtype(i) = 1;
        
    elseif contains(gridname{i}, 'GR10MM0808') || contains(gridname{i}, 'HD10MM0808')
        ElChannelMap = ([8 16 24 32 40 48 56 64; ...
                       7 15 23 31 39 47 55 63; ...
                       6 14 22 30 38 46 54 62; ...
                       5 13 21 29 37 45 53 61; ...
                       4 12 20 28 36 44 52 60; ...
                       3 11 19 27 35 43 51 59; ... 
                       2 10 18 26 34 42 50 58; ...
                       1 9 17 25 33 41 49 57]);
        
        if contains(gridname{i}, 'HD')
            ElChannelMap = fliplr(ElChannelMap);
        end
        discardChannelsVec{i} = zeros(64,1);
        nbelectrodes = 64;
        IED(i) = 10;
        emgtype(i) = 1;
        
    elseif contains(gridname{i}, 'GR10MM0804') || contains(gridname{i}, 'HD10MM0804')
        ElChannelMap = ([32 24 16 8; ...
                       31 23 15 7; ...
                       30 22 14 6; ...
                       29 21 13 5; ...
                       28 20 12 4; ...
                       27 19 11 3; ... 
                       26 18 10 2; ...
                       25 17 9 1]);

        if contains(gridname{i}, 'HD')
            ElChannelMap = rot90(ElChannelMap,2);
        end
        discardChannelsVec{i} = zeros(64,1);
        nbelectrodes = 64;
        IED(i) = 10;
        emgtype(i) = 1;
         
    elseif contains(gridname{i}, 'MYOMRF-4x8')
         ElChannelMap = ([25 1 16 24; ...
                       26 2 15 23; ...  
                       27 3 14 22; ...
                       28 4 13 21; ...
                       29 5 12 20; ...
                       30 6 11 19; ... 
                       31 7 10 18; ...
                       32 8 9 17]);
        discardChannelsVec{i} = zeros(32,1);
        nbelectrodes = 32;
        IED(i) = 1;
        emgtype(i) = 2;
                 
    elseif contains(gridname{i}, 'MYOMNP-1x32')
         ElChannelMap = ([24 25 16 1; ...
                       23 26 15 2; ...  
                       22 27 14 3; ...
                       21 28 13 4; ...
                       20 29 12 5; ...
                       19 30 11 6; ... 
                       18 31 10 7; ...
                       17 32 9 8]);
        discardChannelsVec{i} = zeros(32,1);
        nbelectrodes = 32;
        IED(i) = 1;
        emgtype(i) = 2;
    end
    
    for r=1:size(ElChannelMap,1) % electrode array 1
        for c=1:size(ElChannelMap,2)
            coordinates{i}(ElChannelMap(r,c),1) = r;
            coordinates{i}(ElChannelMap(r,c),2) = c;
        end
    end
    
    % Notch filter and bandpassfilter before visualization
    signal = notchsignals(signal,fsamp);
    
    % Visual checking of EMG signals by column
    if checkEMG == 1
        ch=1;
        for c = 1:size(ElChannelMap,2)
            figure;
            lincol = colormap(turbo(size(ElChannelMap,1)));
            for r = 1:size(ElChannelMap,1)
                if ch < length(discardChannelsVec{i}) + 1
                    plot(signal(ch,:)/max(signal(ch,:)) + r, 'Color', lincol(r,:), 'LineWidth', 1)
                    grid on
                    hold on
                    ylim([0 size(ElChannelMap,1)+1])
                    ch = ch+1;
                end
            end
            title(['Column#' num2str(c)], 'Color', [0.9412 0.9412 0.9412], 'FontName', 'Avenir Next', 'FontSize', 20)
            xlabel('Time (s)', 'FontName', 'Avenir Next', 'FontSize', 20)
            ylabel('Row #', 'FontName', 'Avenir Next', 'FontSize', 20)
            set(gcf,'Color', [0.5 0.5 0.5]);
            set(gcf,'units','normalized','outerposition',[0 0 1 1])
            set(gca,'Color', [0.5 0.5 0.5], 'XColor', [0.9412 0.9412 0.9412], 'YColor', [0.9412 0.9412 0.9412]);
            discchan = inputdlg('Enter the number of discarded channels (Enter space-separated numbers):');
            
            if ~isnan(str2num(discchan{1}))
                discardChannelsVec{i}(str2num(discchan{1}) + (c-1)*size(ElChannelMap,1)) = 1;
            end
            close;
        end
        if length(discardChannelsVec{i}) > nbelectrodes
            discardChannelsVec{i} = discardChannelsVec{i}(1:nbelectrodes);
        end
    else
        discardChannelsVec{i} = zeros(nbelectrodes,1);
    end  
end
end
