%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend MU filter and update it over sliding windows with an overlap of 50%

% Input: 
%   EMG = EMG signals
%   EMGmask = mask to remove channels with low SNR or artifacts
%   PulseT = motor unit pulse train
%   distime = discharge times
%   idx = indexes of the window
%   fsamp = sampling rate
%   EMGtype = type of EMG signals (1 = surface; 2 = intramuscular)

% Output:
%   PulseT = motor unit pulse train
%   distime = discharge times

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [PulseT, distime] = extendfilter(EMG, EMGmask, PulseT, distime, idx, fsamp, EMGtype)

    nbextchan = 1000;
    EMG = EMG(EMGmask==0, idx);
    EMG = bandpassingals(EMG, fsamp, EMGtype);
    spikes1 = intersect(idx(round(0.1*fsamp):end-round(0.1*fsamp)), distime);
    if ~isempty(spikes1)
        spikes2 = (spikes1 - idx(1));
        exFactor1 = round(nbextchan/size(EMG,1));
        eSIG = extend(EMG,exFactor1);
        ReSIG = eSIG*eSIG'/length(eSIG);
        iReSIGt = pinv(ReSIG);
        [E, D] = pcaesig(eSIG);
        [wSIG, ~, dewhiteningMatrix] = whiteesig(eSIG, E, D);
        MUFilters = sum(wSIG(:,spikes2),2);
        
        Pt = ((dewhiteningMatrix * MUFilters)' * iReSIGt) * eSIG; % Update the pulse train
        Pt= Pt(1:size(EMG,2));
        Pt([1:round(0.1*fsamp) end-round(0.1*fsamp):end]) = 0; % Remove the edges
        Pt = Pt .* abs(Pt); % Normalized and update the pulse train
        [~,spikes] = findpeaks(Pt,'MinPeakDistance', round(fsamp*0.005)); % Peak detection
        Pt = Pt/mean(maxk(Pt(spikes),10));
        
        if spikes > 2
            [L,C2] = kmeans(Pt(spikes)',2); % Kmean classification
            [~, idx2] = max(C2); % Find the class with the highest centroid
            spikes2 = spikes(L==idx2);
            spikes2(Pt(spikes2)>mean(Pt(spikes2))+3*std(Pt(spikes2))) = []; % remove the outliers of the pulse train for the calculation of the filter
            
            PulseT(idx(1)+round(0.1*fsamp)-1:idx(end)-round(0.1*fsamp)) = Pt(round(0.1*fsamp):end-round(0.1*fsamp));
            distime = setdiff(distime,spikes1);
            distime = [distime, spikes2 + idx(1) - 1];
            distime = sort(distime);
        end
    end
end
