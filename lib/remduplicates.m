%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To remove the duplicates (MUs that share most of their discharge times,
% the threshold is defined in the script main.m)

% Input: 
%   PulseT = Pulse train of each MU
%   distime = discharge times of the motor units 
%   distime2 = discharge times of the motor units realigned with the MUAP
%   maxlag = maximal lag between motor unit spike trains
%   jitter = tolerance in sec for the estimation of discharge times
%   tol = percentage of shared discharge times to define a duplicate
%   fsamp = sampling frequency

% Output:
%   Pulsenew = Pulse train of non-duplicated MU
%   distimenew = discharge times of non-duplicated MU

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Pulsenew, distimenew] = remduplicates(PulseT, distime, distime2, maxlag, jitter, tol, fsamp)

f = waitbar(0,'Removing duplicates');

jit = round(jitter*fsamp);

% Generate binary spike trains
firings = zeros(size(PulseT));
for i = 1:size(PulseT,1)
    firings(i , distime2{i}) = 1;
    distimmp{i} = [];
    for j = 1:jit
        distimmp{i} = [distimmp{i} distime2{i}-j];
        distimmp{i} = [distimmp{i} distime2{i}+j];
    end
    distimmp{i} = [distimmp{i} distime2{i}];
end

MUn = length(distime2);
x = 1/MUn;

i = 1;
% Remove duplicates
while ~isempty(distimmp)
    % Remove lag that may exist between MU
    distimetemp = cell(1,length(distimmp));
    for j = 1:length(distimmp)
        [c, lags] = xcorr(firings(1,:), firings(j,:), maxlag*2,'normalized');
        [correl, idx] = max(c);
        if correl > 0.2
            distimetemp{j} = distimmp{j} + lags(idx);
        else
            distimetemp{j} = distimmp{j};
        end
    end
    
    % Find common discharge times
    comdis = zeros(1, length(distimmp));
    for j = 2:length(distimmp)
        com = intersect(distimmp{1}, distimetemp{j});
        com([false,diff(com) == 1]) = [];
        comdis(j) = length(com)/max([length(distime{1}) length(distime{j})]);
        clearvars com
    end
    
    % Flag duplicates and keep the MU with the lowest CoV of ISI
    duplicates = find(comdis >= tol);
    duplicates = [1 duplicates];
    CoV = zeros(1, length(duplicates));
    for j = 1:length(duplicates)
        ISI = diff(distime{duplicates(j)});
        CoV(j) = std(ISI)/mean(ISI);
    end
    [~, survivor] = min(CoV);
    
    % Delete duplicates and save the surviving MU
    distimenew{i} = distime{duplicates(survivor)};
    Pulsenew(i,:) = PulseT(duplicates(survivor),:);

    % Update firings and discharge times 
    for j = 1:length(duplicates)
        distime{duplicates(end-(j-1))} = [];
        distime2{duplicates(end-(j-1))} = [];
        distimmp{duplicates(end-(j-1))} = [];
    end
    distime = distime(~cellfun('isempty',distime));
    distime2 = distime2(~cellfun('isempty',distime2));
    distimmp = distimmp(~cellfun('isempty',distimmp));

    firings(duplicates,:) = [];
    PulseT(duplicates,:) = [];
    waitbar(x*(MUn-length(distime)), f, [num2str(length(distime)) ' remaining MUs to check'])
    i = i + 1;
end

close(f);