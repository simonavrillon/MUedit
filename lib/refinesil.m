function sil = refinesil(PulseT, distime, fsamp)

[~,spikes] = findpeaks(PulseT,'MinPeakDistance',round(fsamp*0.005)); % 4b: Peak detection
PulseT = PulseT/mean(maxk(PulseT(spikes),10)); % normalization of the MU pulse train

for i = 1:floor(length(PulseT)/fsamp)
    idx = find(spikes > 1+(i-1)*fsamp & spikes < i*fsamp);
    idx1 = find(distime > 1+(i-1)*fsamp & distime < i*fsamp);

    if length(idx)>2 && length(idx1)>2
        [L,C,sumd,D] = kmeans(PulseT(spikes(idx))',2); % 4c: Kmean classification
        [~, idx2] = max(C); % Spikes should be in the class with the highest centroid
        within = sumd(idx2);
        between = sum(D(L==idx2, setdiff([1 2],idx2)));
        sil(i,1) = floor(i*fsamp - (fsamp/2));
        sil(i,2) = (between-within)/max([within,between]); % Silhouette measure   
    else
        sil(i,1) = floor(i*fsamp - (fsamp/2));
        sil(i,2) = NaN;
    end
end
