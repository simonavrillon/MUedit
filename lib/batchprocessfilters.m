%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To reapply the MU filters over each segment of decomposed data

% Input: 
%   MUFilters = matrix of MU filters
%   wSIG = whitened EMG signal
%   coordinates = onset and offset of each segment of data
%   exFactor = extension factor
%   differentialmode = differential mode on or off (1 or 0)
%   ltime = duration of the raw signal 
%   fsamp = sampling frequency


% Output:
%   PulseT = Pulse train of each MU
%   distime = discharge times of the motor units 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [PulseT, distime] = batchprocessfilters(MUFilters, wSIG, coordinates, exFactor, differentialmode, ltime, fsamp)

f = waitbar(0,'Batch processing MUs');
MUn = 0;
for nwin = 1:size(wSIG,2)
    MUn = MUn + size(MUFilters{nwin},2);
end
x = 1/MUn;

PulseT = zeros(MUn, ltime);
distime = cell(1,MUn);
MUnb=1; 
for nwin = 1:size(wSIG,2)
    for j = 1:size(MUFilters{nwin},2)
        for nwin2 = 1:size(wSIG,2)
            PulseT(MUnb,coordinates(nwin2*2-1):coordinates(nwin2*2)+exFactor-1-differentialmode) = MUFilters{nwin}(:,j)'  * wSIG{nwin2};
        end  
        PulseT(MUnb,:) = PulseT(MUnb,:) .* abs(PulseT(MUnb,:));
        [~,spikes] = findpeaks(PulseT(MUnb,:), 'MinPeakDistance', round(fsamp*0.005)); % Peak detection
        PulseT(MUnb,:) = PulseT(MUnb,:)/mean(maxk(PulseT(MUnb,spikes),10));
        [L,C] = kmeans(PulseT(MUnb,spikes)',2); % Kmean ++ classification
        [~, idx] = max(C); % Determine highest centroid
        distime{MUnb} = spikes(L==idx); 
        waitbar(x*MUnb, f, ['Batch processing MU#' num2str(MUnb) ' out of ' num2str(MUn) 'MUs'])
        MUnb = MUnb+1;
    end   
end
PulseT = PulseT(:, 1:ltime);
close(f);

