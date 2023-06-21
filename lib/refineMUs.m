%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To reapply the filters of each motor unit over the EMG entire signal

% Input: 
%   EMG = raw EMG signal
%   EMGmask = flagged EMG channels with artifacts or low signal to noise
%   ratio
%   PulseTold = previous pulse trains of the motor units
%   Distimeold = previous discharge times of the motor units
%   fsamp = sampling frequency

% Output:
%   PulseT = new pulse trains of the motor units
%   Distime = new discharge times of the motor units

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [PulseT, Distime] = refineMUs(EMG, EMGmask, PulseTold, Distimeold, fsamp)

f = waitbar(0,'Refining MU pulse trains - Signal extension');

EMG(EMGmask == 1,:) = [];
nbextchan = 1500;
exFactor = round(nbextchan/size(EMG,1));
eSIG = extend(EMG,exFactor);
ReSIG = eSIG*eSIG'/length(eSIG);
iReSIGt = pinv(ReSIG);

PulseT = zeros(size(PulseTold));
Distime = cell(1,size(PulseTold,1));

x = 1/size(PulseTold,1);

% Recalculate MUfilters
for i = 1:size(PulseTold,1)
    Distimeold{i}(PulseTold(i,Distimeold{i})>mean(PulseTold(i,Distimeold{i}))+3*std(PulseTold(i,Distimeold{i}))) = [];
    MUFilters = sum(eSIG(:,Distimeold{i}),2); 
    IPTtmp = (MUFilters'*iReSIGt)*eSIG;
    PulseT(i,:) = IPTtmp(1:size(EMG,2));
    PulseT(i,:) = abs(PulseT(i,:)).*PulseT(i,:);
    [~,spikes] = findpeaks(PulseT(i,:), 'MinPeakDistance', round(fsamp*0.02)); % Peak detection
    PulseT(i,:) = PulseT(i,:)/mean(maxk(PulseT(i,spikes),10));
    [L,C] = kmeans(PulseT(i,spikes)',2); % Kmean classification
    [~, idx] = max(C); % Spikes should be in the class with the highest centroid
    Distime{i} = spikes(L==idx);
    waitbar(x*i, f, ['Refining MU#' num2str(i) ' out of ' num2str(size(PulseTold,1)) 'MUs'])
end

close(f);
