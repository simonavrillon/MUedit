%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimization loop of the MU filter to minimize the coefficient of
% varation of the inter spike intervals

% Input: 
%   w = initial weigths
%   X = whitened signal
%   CoV = coefficient of varation of the inter spike intervals
%   fsamp = sampling frequency


% Output:
%   wlast = new weigths (MU filter)
%   spikeslast = discharge times of the motor unit
%   CoVlast = coefficient of varation of the inter spike intervals 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [wlast, spikeslast, CoVlast] = minimizeCOVISI(w, X, CoV, fsamp)

k = 1;
CoVlast = CoV + 0.1;
spikes = 1;

while CoV < CoVlast

CoVlast = CoV; % save the last CoV
spikeslast = spikes; % save the last discharge times
wlast = w; % save the last MU filter

[~, spikes] = getspikes(w, X, fsamp); % get the discharge times
ISI = diff(spikes/fsamp); % calculate the interspike interval
CoV = std(ISI)/mean(ISI); % Update the CoV of the ISI

%       4e: Update the separation vector
k = k + 1;
w = sum(X(:,spikes), 2);

end

if length(spikeslast) < 2
    [~, spikeslast] = getspikes(w, X, fsamp); % save the last discharge times
end