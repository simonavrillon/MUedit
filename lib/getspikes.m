%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To identify the discharge times of the motor unit

% Input: 
%   w = weigths
%   X = whitened signal
%   fsamp = sampling frequency

% Output:
%   icasig = MU pulse train
%   spikes2 = discharge times of the motor unit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [icasig, spikes2] = getspikes(w, X, fsamp)

icasig = (w' * X).*abs(w' * X); % 4a: Estimate the i source
[~,spikes] = findpeaks(icasig, 'MinPeakDistance', round(fsamp*0.02)); % 4b: Peak detection
icasig = icasig/mean(maxk(icasig(spikes),10));
if length(spikes)>1
    [L,C] = kmeans(icasig(spikes)',2); % 4c: Kmean classification
    [~, idx2] = max(C); % Spikes should be in the class with the highest centroid
    spikes2 = spikes(L==idx2);
    spikes2(icasig(spikes2)>mean(icasig(spikes2))+3*std(icasig(spikes2))) = []; % remove the outliers of the pulse train
else
    spikes2 = spikes;
end
