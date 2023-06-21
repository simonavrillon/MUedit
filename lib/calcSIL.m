%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To calculate the silouhette value to estimate the quality of the Motor
% Unit (the distance between the peaks and the noise)

% Input: 
%   w = weigths
%   X = whitened signal
%   fsamp = sampling frequency


% Output:
%   icasig = Normalized motor unit pulse train
%   spikes2 = discharge times of the motor unit
%   sil = silhouette value 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [icasig, spikes2, sil] = calcSIL(X, w, fsamp)

icasig = (w' * X).* abs(w' * X); % get the MU pulse train
[~,spikes] = findpeaks(icasig,'MinPeakDistance',round(fsamp*0.02)); % 4b: Peak detection
icasig = icasig/mean(maxk(icasig(spikes),10)); % normalization of the MU pulse train
if length(spikes) > 1
    [L,C,sumd,D] = kmeans(icasig(spikes)',2); % 4c: Kmean classification
    [~, idx2] = max(C); % Spikes should be in the class with the highest centroid
    spikes2 = spikes(L==idx2);
    within = sumd(idx2);
    between = sum(D(L==idx2, setdiff([1 2],idx2)));
    sil = (between-within)/max([within,between]); % Silhouette measure
else
    sil = 0;
end
