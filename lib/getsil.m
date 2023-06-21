function sil = getsil(PulseT, fsamp)

[~,spikes] = findpeaks(PulseT,'MinPeakDistance',round(fsamp*0.005)); % 4b: Peak detection
PulseT = PulseT/mean(maxk(PulseT(spikes),10)); % normalization of the MU pulse train
[L,C,sumd,D] = kmeans(PulseT(spikes)',2); % 4c: Kmean classification
[~, idx2] = max(C); % Spikes should be in the class with the highest centroid
within = sumd(idx2);
between = sum(D(L==idx2, setdiff([1 2],idx2)));
sil = (between-within)/max([within,between]); % Silhouette measure
