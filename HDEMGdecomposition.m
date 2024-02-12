%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decomposition of surface high-density EMG signals in motor unit discharge
% times using the method developed by Negro et al. (2016)

% FastICA: Hyvärinen & Oja (1997)
% gCKC : Holobar & Zazula (2007)

% Pseudo algorithm:
% Step 0: Load the HDsEMG data
%       0a: determine the number and type of grids
% Step 1: Preprocessing
%       1a: Signal filtering
%       1b: Removing line interference
%       1c: Differentiation in the time domain (only if the signal is good)
%       1d: Signal extension
%       1e: Removing the mean
% Step 2: Whitening
%       2a: Get eigenvalues and eigenvectors
%       2b: Zero-phase component analysis (ZCA)
% Step 3: FastICA method
%       3a: Fixed point algorithm (end when sparsness is maximized)
%       3b: Orthogonalization
%       3c: Normalization
% Step 4: Minimization of the CoV of discharge times (end when CoV is
% minimized)
%       4a: Estimate the i source
%       4b: Peak detection
%       4c: Kmean ++ classification to separate the high peaks (motor units
%       A)from small motor units (motor units B)
%       4d: Calculate CoV
%       4e: Update the separation vector
% Step 5: Select the reliable MU (SIL >0.9)
%       5a: Calculate SIL
%       5b: add the separation vector to the separation matrice
% Step 6: Update the residual signal
%       6a: Source deflation (Orthogonalization)
%       6b: go back to Step 3 to 6

%% 
clear
close all;
clc;
%% Input parameters
parameters.pathname = '/Users/savrillo/Downloads/'; % add a '/' at the end for Mac OS, add a '\' at the end for Windows
parameters.filename = '10_DF.otb+'; % filename.otb+ or filename.mat

% DECOMPOSITION PARAMETERS
parameters.NITER = 75;
parameters.ref_exist = 0; % if ref_signal exist ref_exist = 1; if not ref_exist = 0 and manual selection of windows
parameters.checkEMG = 0; % 0 = Consider all the channels ; 1 = Visual checking
parameters.nwindows = 1; % number of segmented windows over each contraction
parameters.differentialmode = 0; % 0 = no; 1 = yes (filter out the smallest MU, can improve decomposition at the highest intensities
parameters.initialization = 1; % 0 = max EMG; 1 = random weights
parameters.peeloff = 1; % 0 = no; 1 = yes (update the residual EMG by removing the motor units with the highest SIL value)
parameters.covfilter = 0; % 0 = no; 1 = yes (filter out the motor units with a coefficient of variation of their ISI > than parameters.covthr)
parameters.refineMU = 0; % 0 = no; 1 = yes (refine the MU spike train over the entire signal 1-remove the discharge times that generate outliers in the discharge rate and 2- reevaluate the MU pulse train)
parameters.drawingmode = 1; % 0 = Output in the command window ; 1 = Output in a figure
parameters.duplicatesbgrids = 0; % 0 = do not consider duplicates between grids ; 1 = Remove duplicates between grids

% SPECIFIC VALUES
parameters.thresholdtarget = 0.8; % threshold to segment the target displayed to the participant, 1 being the maxima of the target (e.g., plateau)
parameters.nbextchan = 1000; % nb of extended channels (1000 in Negro 2016, can be higher to improve the decomposition)
parameters.edges = 0.2; % edges of the signal to remove after preprocessing the signal (in sec)
parameters.contrastfunc = 'skew'; % contrast functions: 'skew', 'kurtosis', 'logcosh'
parameters.silthr = 0.90; % Threshold for SIL values
parameters.covthr = 0.5; % Threshold for CoV of ISI values
parameters.peeloffwin = 0.025; % duration of the window (ms) for detecting the action potentials from the EMG signal
parameters.duplicatesthresh = 0.3; % threshold that define the minimal percentage of common discharge times between duplicated motor units
parameters.CoVDR = 0.3; % threshold that define the CoV of Discharge rate that we want to reach for cleaning the MU discharge times when refineMU is on

%% Step 0: Load the HDsEMG data
%       0a: determine the number and type of grids
C = strsplit(parameters.filename,'.');
if isequal(C{end}, 'mat')
    load([parameters.pathname parameters.filename], 'signal');
else
    [~, signal] = openOTBplus(parameters.pathname, parameters.filename,0);
end

[signal.coordinates, signal.IED, signal.EMGmask, signal.emgtype] = formatsignalHDEMG(signal.data, signal.gridname, signal.fsamp, parameters.checkEMG);

arraynb = zeros(size(signal.data,1),1);
ch1 = 1;
for i = 1:signal.ngrid
    arraynb(ch1:ch1+length(signal.EMGmask{i})-1) = i;
    ch1 = ch1+length(signal.EMGmask{i});
end
%% 
    % Step 0 <opt> Selection of the region of interest
if parameters.ref_exist == 1
    signalprocess.ref_signal = signal.target;
    signalprocess.coordinatesplateau = segmenttargets(signalprocess.ref_signal, parameters.nwindows, parameters.thresholdtarget);
    for nwin = 1:length(signalprocess.coordinatesplateau)/2
        for i = 1:signal.ngrid
            signalprocess.data{i,nwin} = signal.data(arraynb==i, signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
            signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
        end
    end
else
    tmp = zeros(floor(size(signal.data,1)/2), size(signal.data,2));
    for i = 1:floor(size(signal.data,1)/2)
        tmp(i,:) = movmean(abs(signal.data(i,:)), signal.fsamp);
    end
    signalprocess.ref_signal = mean(tmp,1);
    signal.target = signalprocess.ref_signal;
    signal.path = signalprocess.ref_signal;
    plot(tmp','Color', [0.5 0.5 0.5],'LineWidth',0.5)
    hold on
    plot(signalprocess.ref_signal,'k','LineWidth',1)
    ylim([0 max(signalprocess.ref_signal)*1.5])
    title('EMG amplitude for 50% of the EMG channels')
    grid on
    clearvars tmp maskEMG
    [A,B] = ginput(2*parameters.nwindows);
    A(A<1) = 1;
    A(A>length(signalprocess.ref_signal)) = length(signalprocess.ref_signal);
    signalprocess.coordinatesplateau = zeros(1,parameters.nwindows*2);
    for nwin = 1:parameters.nwindows
        signalprocess.coordinatesplateau(nwin*2-1) = floor(A(nwin*2-1));
        signalprocess.coordinatesplateau(nwin*2) = floor(A(nwin*2));
        for i = 1:signal.ngrid
            signalprocess.data{i,nwin} = signal.data(arraynb==i, signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
            signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
        end
    end
    clearvars A B
end
close all;

%%
fmu = zeros(1,signal.ngrid);
for i = 1:signal.ngrid
for nwin = 1:length(signalprocess.coordinatesplateau)/2

% Step 1: Preprocessing
%       1a: Removing line interference (Notch filter)
    signalprocess.data{i,nwin} = notchsignals(signalprocess.data{i,nwin},signal.fsamp);
%       1b: Bandpass filtering
    signalprocess.data{i,nwin} = bandpassingals(signalprocess.data{i,nwin},signal.fsamp, signal.emgtype(i));

%       1c: Differentiation (perform only if there is many motor units,
%      filter out the smallest motor units) useful for high intensities
    if parameters.differentialmode == 1
            signalprocess.data{i,nwin} = diff(signalprocess.data{i,nwin},1,2);
    end

%       1d: Signal extension (extension factor calculated to reach 1000
%       channels)
    signalprocess.exFactor = round(parameters.nbextchan/size(signalprocess.data{i,nwin},1));
    signalprocess.ReSIG = zeros(signalprocess.exFactor * size(signalprocess.data{i,nwin},1));
    signalprocess.iReSIG{nwin} = zeros(signalprocess.exFactor * size(signalprocess.data{i,nwin},1));
    
    signalprocess.eSIG{nwin} = extend(signalprocess.data{i,nwin},signalprocess.exFactor);
    signalprocess.ReSIG = signalprocess.eSIG{nwin} * signalprocess.eSIG{nwin}' / size(signalprocess.eSIG{nwin},2);
    signalprocess.iReSIG{nwin} = pinv(signalprocess.ReSIG);

%       1e: Removing the mean
    signalprocess.eSIG{nwin} = demean(signalprocess.eSIG{nwin});

% Step 2: Whitening
%Whitening with a regularization factor (average of the smallest half of 
%the eigenvalues of the covariance matrix from the extended signals)

%       2a: Get eigenvalues and eigenvectors (regularization factor =>
%       average smallest half of eigenvalues)
    [E, D] = pcaesig(signalprocess.eSIG{nwin}); %Returns the eigenvector (E) and diagonal eigenvalue (D) matrices

%       2b: Zero-phase component analysis
    [signalprocess.wSIG{nwin}, ~, ~] = whiteesig(signalprocess.eSIG{nwin}, E, D);
    clearvars E D

% Remove the edges
    signalprocess.eSIG{nwin} = signalprocess.eSIG{nwin}(:,round(signal.fsamp*parameters.edges):end-round(signal.fsamp*parameters.edges));
    signalprocess.wSIG{nwin} = signalprocess.wSIG{nwin}(:,round(signal.fsamp*parameters.edges):end-round(signal.fsamp*parameters.edges));

    if i == 1
        signalprocess.coordinatesplateau(nwin*2-1) = signalprocess.coordinatesplateau(nwin*2-1) + round(signal.fsamp*parameters.edges)-1;
        signalprocess.coordinatesplateau(nwin*2) = signalprocess.coordinatesplateau(nwin*2) - round(signal.fsamp*parameters.edges);
    end

% Step 3: FastICA method

% Initialize matrix B (n x m) n: separation vectors, m: iterations 
% Initialize matrix MUFilters to only save the reliable filters
% Intialize SIL and PNR

signalprocess.B = zeros(size(signalprocess.wSIG{nwin},1), parameters.NITER); % all separation vectors
signalprocess.MUFilters{nwin} = zeros(size(signalprocess.wSIG{nwin},1), parameters.NITER); % only reliable vectors
signalprocess.w = zeros(size(signalprocess.wSIG{nwin},1), 1);
signalprocess.icasig = zeros(parameters.NITER, size(signalprocess.wSIG{nwin},2));
signalprocess.SIL{nwin} = zeros(1, parameters.NITER);
signalprocess.CoV{nwin} = zeros(1, parameters.NITER);
idx1 = zeros(1, parameters.NITER);

% Find the index where the square of the summed whitened vectors is
% maximized and initialize W with the whitened observations at this time

for j = 1:parameters.NITER
if j == 1
    signalprocess.X = signalprocess.wSIG{nwin}; % Initialize X (whitened signal), then X: residual
    if parameters.initialization == 0
        actind = sum(signalprocess.X,1).^2;
        [~, idx1(j)] = max(actind);
        signalprocess.w = signalprocess.X(:, idx1(j)); % Initialize w
    else
        signalprocess.w = randn(size(signalprocess.X,1),1);
    end
    time = linspace(0,size(signalprocess.X,2)/signal.fsamp,size(signalprocess.X,2));
else
    if parameters.initialization == 0
        actind(idx1(j-1)) = 0; % remove the previous vector
        [~, idx1(j)] = max(actind);
        signalprocess.w = signalprocess.X(:, idx1(j)); % Initialize w
    else
        signalprocess.w = randn(size(signalprocess.X,1),1);
    end
end

signalprocess.w = signalprocess.w - signalprocess.B * signalprocess.B' * signalprocess.w; % Orthogonalization
signalprocess.w = signalprocess.w / norm(signalprocess.w); % Normalization

%       3a: Fixed point algorithm (end when sparsness is maximized)
maxiter = 500; % max number of iterations for the fixed point algorithm
signalprocess.w = fixedpointalg(signalprocess.w, signalprocess.X, signalprocess.B , maxiter, parameters.contrastfunc);

% Step 4: Minimization of the CoV of discharge times (end when CoV is
% minimized)

% Initialize CoV (variation of interspike intervals, %) Step 4a => 4e
[signalprocess.icasig, signalprocess.spikes] = getspikes(signalprocess.w, signalprocess.X, signal.fsamp);

if length(signalprocess.spikes) > 10
    ISI = diff(signalprocess.spikes/signal.fsamp); % Interspike interval
    signalprocess.CoV{nwin}(j) = std(ISI)/mean(ISI); % Coefficient of variation
    Wini = sum(signalprocess.X(:,signalprocess.spikes),2); % update W by summing the spikes
                   
            % Minimization of the CoV of discharge times (end when CoV is
    % minimized)
    [signalprocess.MUFilters{nwin}(:,j), signalprocess.spikes, signalprocess.CoV{nwin}(j)] = minimizeCOVISI(Wini, signalprocess.X, signalprocess.CoV{nwin}(j), signal.fsamp);
    signalprocess.B(:,j) = signalprocess.w;

    % Calculate SIL values
    [signalprocess.icasig, signalprocess.spikes, signalprocess.SIL{nwin}(j)] = calcSIL(signalprocess.X, signalprocess.MUFilters{nwin}(:,j), signal.fsamp);
    
    % Peel-off of the (reliable) source    
    if parameters.peeloff == 1 && signalprocess.SIL{nwin}(j) > parameters.silthr
       signalprocess.X = peeloff(signalprocess.X, signalprocess.spikes, signal.fsamp, parameters.peeloffwin);
    end

    if parameters.drawingmode == 1
        subplot(2,1,1)
        plot(signal.target, 'k--', 'LineWidth', 2)
        line([signalprocess.coordinatesplateau(nwin*2-1) signalprocess.coordinatesplateau(nwin*2-1)],[0 max(signal.target)], 'Color', 'r', 'LineWidth', 2)
        line([signalprocess.coordinatesplateau(nwin*2) signalprocess.coordinatesplateau(nwin*2)],[0 max(signal.target)], 'Color', 'r', 'LineWidth', 2)
        title(['Grid #' num2str(i) ' - Iteration #' num2str(j) ' - Sil = ' num2str(signalprocess.SIL{nwin}(j)) ' CoV = ' num2str(signalprocess.CoV{nwin}(j))]);
        subplot(2,1,2)
        plot(time,signalprocess.icasig,time(signalprocess.spikes),signalprocess.icasig(signalprocess.spikes),'o');
        drawnow;
    else
        disp(['Grid #' num2str(i) ' - Iteration #' num2str(j) ' - Sil = ' num2str(signalprocess.SIL{nwin}(j)) ' CoV = ' num2str(signalprocess.CoV{nwin}(j))])
    end
else
    signalprocess.B(:,j) = signalprocess.w;
end
end

% Filter out MUfilters below the SIL threshold
signalprocess.MUFilters{nwin}(:,signalprocess.SIL{nwin} < parameters.silthr) = [];
if parameters.covfilter == 1
    signalprocess.CoV{nwin}(signalprocess.SIL{nwin} < parameters.silthr) = [];
    signalprocess.MUFilters{nwin}(:,signalprocess.CoV{nwin} > parameters.covthr) = [];
end

end

% Batch processing over each window
[PulseT, distime] = batchprocessfilters(signalprocess.MUFilters, signalprocess.wSIG, signalprocess.coordinatesplateau, signalprocess.exFactor, parameters.differentialmode, size(signal.data,2), signal.fsamp);

if size(PulseT,1) > 0
    % Remove duplicates
    fmu(i) = 1;
    [PulseT, distimenew] = remduplicates(PulseT, distime, distime, round((signal.fsamp/40)), 0.00025, parameters.duplicatesthresh, signal.fsamp);
    
    if parameters.refineMU == 1    
        % Remove outliers generating irrelevant discharge rates before manual
        % edition (1st time)
        distimenew = remoutliers(PulseT, distimenew, parameters.CoVDR, signal.fsamp);
    
        % Reevaluate all the unique motor units over the contractions
        [signal.Pulsetrain{i}, distimenew] = refineMUs(signal.data(arraynb==i, :), signal.EMGmask{i}, PulseT, distimenew, signal.fsamp);
        
        % Remove outliers generating irrelevant discharge rates before manual
        % edition (2nd time)
        distimenew = remoutliers(signal.Pulsetrain{i}, distimenew, parameters.CoVDR, signal.fsamp);
    else
        signal.Pulsetrain{i} = PulseT;
    end
    
    % Save the results
    for j = 1:length(distimenew)
        signal.Dischargetimes{i,j} = distimenew{j};
    end
end
end

if sum(fmu) > 0 && parameters.duplicatesbgrids == 1
    nmu = 0;
    for i = 1:size(signal.Pulsetrain,2)
        if ~isempty(signal.Pulsetrain{i})
            nmu = nmu + size(signal.Pulsetrain{i},1);
        end
    end
    
    PulseT = zeros(nmu, length(signal.target));
    Distim = cell(1,nmu);
    muscle = zeros(1,nmu);
    mu = 1;
    for i = 1:size(signal.Pulsetrain,2)
        if ~isempty(signal.Pulsetrain{i})
            for j = 1:size(signal.Pulsetrain{i},1)
                PulseT(mu,:) = signal.Pulsetrain{i}(j,:);
                Distim{mu} = signal.Dischargetimes{i,j};
                muscle(mu) = i;
                mu = mu+ 1;
            end
        end
    end
    
    [PulseT, Distim, muscle] = remduplicatesbgrids(PulseT, Distim, muscle, round(signal.fsamp/40), 0.00025, 0.3, signal.fsamp);
    signal.Dischargetimes = {};
    for i = 1:size(signal.Pulsetrain,2)
        idx = find(muscle == i);
        signal.Pulsetrain{i} = PulseT(idx,:);
        for j = 1:size(signal.Pulsetrain{i},1)
            signal.Dischargetimes{i,j} = Distim{idx(j)};
        end
    end
end

% Save file
clearvars signalprocess i j PulseT distime distimenew distimea actind idx1 time ISI CoV maxiter nwin Wini f xwb temp muscle
savename = [parameters.filename '_decomp.mat'];
save(savename, 'signal', 'parameters', '-v7.3');
close all