%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To segment the target displayed to the participant to decompose EMG
% signals

% Input: 
% target: target displayed to the participant (automatic import with otb+
% files)
% nwindows: number of windows to decompose for each segment
% threshold: threshold to segment the target displayed to the participant, 1 being the maxima of the target

% Output:
% coordinates: indexes for each window to decompose

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function coordinates = segmenttargets(target, nwindows, threshold)
    plateau = find(target >= max(target)*threshold);
    sep = find(diff(plateau) > 1);
    if nwindows > 1 && ~isempty(sep)
        coordinatestmp(1,:) = [plateau(1), plateau(sep(1))];
        for i = 1:length(sep)
            if i < length(sep)
                coordinatestmp(i+1,:) = [plateau(sep(i)+1), plateau(sep(i+1))];
            else
                coordinatestmp(i+1,:) = [plateau(sep(i)+1), plateau(end)];
            end
        end
    
        lplat = coordinatestmp(:,2) - coordinatestmp(:,1);
        lwin = floor(lplat/nwindows);
    
        coordinates = zeros(length(sep)+1,nwindows*2);
        for i = 1:nwindows
            coordinates(:,i*2-1) = coordinatestmp(:,1) + (i-1) * lwin + 1;
            coordinates(:,i*2) = coordinatestmp(:,1) + i * lwin;
        end
        coordinates = reshape(coordinates',1,[]);
    elseif nwindows > 1
        coordinatestmp(1,:) = [plateau(1), plateau(end)];    
        lplat = coordinatestmp(:,2) - coordinatestmp(:,1);
        lwin = floor(lplat/nwindows);
        coordinates = zeros(length(sep)+1,nwindows*2);
        for i = 1:nwindows
            coordinates(:,i*2-1) = coordinatestmp(:,1) + (i-1) * lwin + 1;
            coordinates(:,i*2) = coordinatestmp(:,1) + i * lwin;
        end
        coordinates = reshape(coordinates',1,[]);
    elseif nwindows == 1 && ~isempty(sep)
        coordinatestmp(1,:) = [plateau(1), plateau(sep(1))];
        for i = 1:length(sep)
            if i < length(sep)
                coordinatestmp(i+1,:) = [plateau(sep(i)+1), plateau(sep(i+1))];
            else
                coordinatestmp(i+1,:) = [plateau(sep(i)+1), plateau(end)];
            end
        end
        lplat = coordinatestmp(:,2) - coordinatestmp(:,1);
        lwin = floor(lplat/nwindows);
    
        coordinates = zeros(length(sep)+1,nwindows*2);
        for i = 1:nwindows
            coordinates(:,i*2-1) = coordinatestmp(:,1) + (i-1) * lwin + 1;
            coordinates(:,i*2) = coordinatestmp(:,1) + i * lwin;
        end
        coordinates = reshape(coordinates',1,[]);
    else
        coordinates = [plateau(1), plateau(end)];
    end
    
end