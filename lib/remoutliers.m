%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To remove high values of DR that we consider as outliers until we reach a
% low coefficient of variation of the discharge rates

% Input: 
%   PulseTold = previous pulse trains of the motor units
%   Distimeold = previous discharge times of the motor units
%   thresh = Threshold for the coefficent of variation of the discharge
%   rate that we want to reach
%   fsamp = sampling frequency

% Output:
%   Distime = new discharge times of the motor units

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function distime = remoutliers(pulseT, distime, thresh, fsamp)

for nMU = 1:length(distime)

    DR = 1./(diff(distime{nMU})/fsamp);
    % Iteration on CoV of discharge rates, i.e., 50%
    k = 1;
    while (std(DR)/mean(DR)) > thresh && k < 30
        k = k + 1;
        thres = mean(DR) + 3*std(DR);
        idx = find(DR > thres);
        if ~isempty(idx)
            for i = 1:length(idx)
                if pulseT(nMU, distime{nMU}(idx(i))) < pulseT(nMU, distime{nMU}((idx(i)+1)))
                    idxdel(i) = idx(i);
                else
                    idxdel(i) = idx(i)+1;
                end
            end
            distime{nMU}(idxdel) = [];
            clearvars idxdel
        end
        DR = 1./(diff(distime{nMU})/fsamp);
    end
end