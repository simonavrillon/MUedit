classdef MUedit_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        DecompositionSettingsPanel     matlab.ui.container.Panel
        ContrastfunctionDropDown       matlab.ui.control.DropDown
        ContrastfunctionLabel          matlab.ui.control.Label
        DuplicatethresholdEditField    matlab.ui.control.NumericEditField
        DuplicatethresholdEditFieldLabel  matlab.ui.control.Label
        COVthresholdEditField          matlab.ui.control.NumericEditField
        COVthresholdEditFieldLabel     matlab.ui.control.Label
        NumberofelectrodesEditField    matlab.ui.control.NumericEditField
        NumberofelectrodesEditFieldLabel  matlab.ui.control.Label
        ThresholdtargetEditField       matlab.ui.control.NumericEditField
        ThresholdtargetEditFieldLabel  matlab.ui.control.Label
        RefineMUsDropDown              matlab.ui.control.DropDown
        RefineMUsDropDownLabel         matlab.ui.control.Label
        InitialisationDropDown         matlab.ui.control.DropDown
        InitialisationDropDownLabel    matlab.ui.control.Label
        CoVfilterDropDown              matlab.ui.control.DropDown
        CoVfilterDropDownLabel         matlab.ui.control.Label
        NumberofwindowsEditField       matlab.ui.control.NumericEditField
        NumberofwindowsEditFieldLabel  matlab.ui.control.Label
        PeeloffDropDown                matlab.ui.control.DropDown
        PeeloffDropDownLabel           matlab.ui.control.Label
        CheckEMGDropDown               matlab.ui.control.DropDown
        CheckEMGDropDownLabel          matlab.ui.control.Label
        ReferenceDropDown              matlab.ui.control.DropDown
        ReferenceDropDownLabel         matlab.ui.control.Label
        NbofextendedchannelsEditField  matlab.ui.control.NumericEditField
        NbofextendedchannelsLabel      matlab.ui.control.Label
        SelectfileButton               matlab.ui.control.Button
        EditField_saving_3             matlab.ui.control.EditField
        NumberofiterationsEditField_2  matlab.ui.control.NumericEditField
        NumberofiterationsEditField_2Label  matlab.ui.control.Label
        SILthresholdEditField          matlab.ui.control.NumericEditField
        SILthresholdEditFieldLabel     matlab.ui.control.Label
        StartButton                    matlab.ui.control.Button
        VisualisationPanel             matlab.ui.container.Panel
        EditField                      matlab.ui.control.EditField
        UIAxes_Decomp_2                matlab.ui.control.UIAxes
        UIAxes_Decomp_1                matlab.ui.control.UIAxes
        ManualeditionPanel             matlab.ui.container.Panel
        LockspikesButton               matlab.ui.control.Button
        UndoButton                     matlab.ui.control.Button
        EditField_2                    matlab.ui.control.EditField
        ReevaluatewithoutwhiteningButton  matlab.ui.control.Button
        ReevaluatewithwhiteningButton  matlab.ui.control.Button
        ScrollrightButton              matlab.ui.control.Button
        ZoomoutButton                  matlab.ui.control.Button
        ZoominButton                   matlab.ui.control.Button
        ScrollleftButton               matlab.ui.control.Button
        DeleteDRButton                 matlab.ui.control.Button
        DeletespikesButton             matlab.ui.control.Button
        AddspikesButton                matlab.ui.control.Button
        FlagMUfordeletionButton        matlab.ui.control.Button
        RemoveoutliersButton           matlab.ui.control.Button
        MUdisplayedDropDownLabel       matlab.ui.control.Label
        MUdisplayedDropDown            matlab.ui.control.DropDown
        UIAxesDR                       matlab.ui.control.UIAxes
        UIAxesSpiketrain               matlab.ui.control.UIAxes
        EditionPanel                   matlab.ui.container.Panel
        RemoveduplicatesbetweengridsButton  matlab.ui.control.Button
        RemoveduplicateswithingridsButton  matlab.ui.control.Button
        PlotMUfiringratesButton        matlab.ui.control.Button
        SavetheeditionLabel            matlab.ui.control.Label
        VisualisationLabel             matlab.ui.control.Label
        BatchprocessingLabel           matlab.ui.control.Label
        SaveButton                     matlab.ui.control.Button
        PlotMUspiketrainsButton        matlab.ui.control.Button
        RemoveflaggedMUButton          matlab.ui.control.Button
        ReevaluateallMUfiltersButton   matlab.ui.control.Button
        RemovealltheoutliersButton     matlab.ui.control.Button
        ImportdataButton               matlab.ui.control.Button
        SelectfileButton_2             matlab.ui.control.Button
        EditField_saving_2             matlab.ui.control.EditField
        TabGroup                       matlab.ui.container.TabGroup
        DecompositionTab               matlab.ui.container.Tab
        EditionTab                     matlab.ui.container.Tab
    end

    
    properties (Access = private)
        
        filename            % File to decompose
        pathname            % Folder where decomposed data will be saved

        filename2           % File to edit
        pathname2            % Folder where edited data will be saved

        MUedition           % Data for MU edition accross contractions and intensities
        Backup              % Data for MU edition accross contractions and intensities

        graphstart          % first time point of the graph for edition
        graphend            % last time point of the graph for edition
        roi                 % Region of interest for edition
                
    end
    
    properties (Access = public)
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button down function: DecompositionTab
        function DecompositionTabButtonDown(app, event)
            app.DecompositionSettingsPanel.Visible = 'on';
            app.EditionPanel.Visible = 'off';
            app.ManualeditionPanel.Visible = 'off';
            app.VisualisationPanel.Visible = 'on';
        end

        % Button down function: EditionTab
        function EditionTabButtonDown(app, event)
            app.DecompositionSettingsPanel.Visible = 'off';
            app.EditionPanel.Visible = 'on';
            app.ManualeditionPanel.Visible = 'on';
            app.VisualisationPanel.Visible = 'off';
        end

        % Button pushed function: SelectfileButton
        function SelectfileButtonPushed(app, event)
            app.UIFigure.Visible = 'off'; 
            [app.filename,app.pathname] = uigetfile('*.*');
            app.UIFigure.Visible = 'on'; 
            app.EditField_saving_3.Value = app.filename;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)

            app.UIAxes_Decomp_2.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes_Decomp_2.YColor = [0.9412 0.9412 0.9412];

            % if Force, automatic segmentation of the target; if EMG
            % amplitude, manual selection of the windows based on EMG
            % amplitude
            if isequal(app.ReferenceDropDown.Value, 'Force')
                parameters.ref_exist = 1;
            else
                parameters.ref_exist = 0;
            end
            
            % No = Consider all the channels ; Yes = Visual checking
            if isequal(app.CheckEMGDropDown.Value, 'Yes')
                parameters.checkEMG = 1;
            else
                parameters.checkEMG = 0;
            end

            % (update the residual EMG by removing the motor units with the highest SIL value)
            if isequal(app.PeeloffDropDown.Value, 'Yes')
                parameters.peeloff = 1;
            else
                parameters.peeloff = 0;
            end

            % (filter out the motor units with a coefficient of variation of their ISI > than parameters.covthr)
            if isequal(app.CoVfilterDropDown.Value, 'Yes')
                parameters.covfilter = 1;
            else
                parameters.covfilter = 0;
            end

            % (realign the discharge time with the peak of the MUAP (channel with the MUAP with the highest p2p amplitude from double diff EMG signal)
            if isequal(app.InitialisationDropDown.Value, 'EMG max')
                parameters.initialization = 1;
            else
                parameters.initialization = 0;
            end
            
            % (refine the MU spike train over the entire signal 1-remove the discharge times that generate outliers in the discharge rate and 2- reevaluate the MU pulse train)
            if isequal(app.RefineMUsDropDown.Value, 'Yes')
                parameters.refineMU = 1;
            else
                parameters.refineMU = 0;
            end
            
            parameters.NITER = app.NumberofiterationsEditField_2.Value; % number of iteration for each grid
            parameters.nwindows = app.NumberofwindowsEditField.Value; % number of segmented windows over each contraction
            parameters.nbelectrodes = app.NumberofelectrodesEditField.Value; % number of electrodes per grid or array
            parameters.thresholdtarget = app.ThresholdtargetEditField.Value; % threshold to segment the target displayed to the participant, 1 being the maxima of the target (e.g., plateau)
            parameters.nbextchan = app.NbofextendedchannelsEditField.Value; % nb of extended channels (1000 in Negro 2016, can be higher to improve the decomposition)
            parameters.duplicatesthresh = app.DuplicatethresholdEditField.Value; % threshold that define the minimal percentage of common discharge times between duplicated motor units
            parameters.silthr = app.SILthresholdEditField.Value; % Threshold for SIL values
            parameters.covthr = app.COVthresholdEditField.Value; % Threshold for CoV of ISI values
            parameters.CoVDR = 0.3; % threshold that define the CoV of Discharge rate that we want to reach for cleaning the MU discharge times when refineMU is on
            parameters.edges = 0.5; % edges of the signal to remove after preprocessing the signal (in sec)
            parameters.contrastfunc = app.ContrastfunctionDropDown.Value; % contrast functions: 'skew', 'kurtosis', 'logcosh'
            parameters.peeloffwin = 0.025; % duration of the window (s) for detecting the action potentials from the EMG signal
            
            % Step 0: Load the HDsEMG data
            % 0a: determine the number and type of grids
            C = strsplit(app.filename,'.');
            if isequal(C{end}, 'mat')
                load([app.pathname app.filename], 'signal');
            else
                signal = openOTBplus(app.pathname, app.filename, parameters.ref_exist, parameters.nbelectrodes);
            end

            for i = 1:signal.ngrid
                [signal.coordinates{i}, signal.IED(i), signal.EMGmask{i}, signal.emgtype(i)] = formatsignalHDEMG(signal.data((i-1)*parameters.nbelectrodes+1:i*parameters.nbelectrodes,:), signal.gridname{i}, signal.fsamp, parameters.checkEMG, parameters.nbelectrodes);
            end
            
            if parameters.ref_exist == 1
                signalprocess.ref_signal = signal.target;
                signalprocess.coordinatesplateau = segmenttargets(signalprocess.ref_signal, parameters.nwindows, parameters.thresholdtarget);
                for nwin = 1:length(signalprocess.coordinatesplateau)/2
                    for i = 1:signal.ngrid
                        signalprocess.data{i,nwin} = signal.data((i-1)*parameters.nbelectrodes+1:(i-1)*parameters.nbelectrodes+length(signal.EMGmask{i}), signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
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
                plot(app.UIAxes_Decomp_2, tmp', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.25)
                hold(app.UIAxes_Decomp_2, 'on')
                plot(app.UIAxes_Decomp_2, signalprocess.ref_signal, 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                app.UIAxes_Decomp_2.XColor = [0.9412 0.9412 0.9412];
                app.UIAxes_Decomp_2.YColor = [0.9412 0.9412 0.9412];
                app.UIAxes_Decomp_2.YLim = [0 max(signalprocess.ref_signal)*1.5];
                clearvars tmp
                hold(app.UIAxes_Decomp_2, 'off')
                for nwin = 1:parameters.nwindows
                    app.EditField.Value = ['EMG amplitude for 50% of the EMG channels - Select the window #' num2str(nwin)];
                    app.roi = drawrectangle(app.UIAxes_Decomp_2);
                    x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];
                    signalprocess.coordinatesplateau(nwin*2-1) = floor(x(1));
                    signalprocess.coordinatesplateau(nwin*2) = floor(x(2));
                    for i = 1:signal.ngrid
                        signalprocess.data{i,nwin} = signal.data((i-1)*parameters.nbelectrodes+1:(i-1)*parameters.nbelectrodes+length(signal.EMGmask{i}), signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
                        signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
                    end
                end
                clearvars x
            end
            
            app.UIAxes_Decomp_1.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes_Decomp_1.YColor = [0.9412 0.9412 0.9412];

            for i = 1:signal.ngrid
            for nwin = 1:length(signalprocess.coordinatesplateau)/2
            
            % Step 1: Preprocessing
            %       1a: Removing line interference (Notch filter)
                f = waitbar(0.2, ['Grid #' num2str(i) ' - Preprocessing - Filtering the HDsEMG data']);
                signalprocess.data{i,nwin} = notchsignals(signalprocess.data{i,nwin},signal.fsamp);
            %       1b: Bandpass filtering
                signalprocess.data{i,nwin} = bandpassingals(signalprocess.data{i,nwin},signal.fsamp, signal.emgtype(i));
                        
            %       1c: Signal extension (extension factor calculated to reach 1000
            %       channels)
                waitbar(0.4, f, ['Grid #' num2str(i) ' - Preprocessing - Extending the HDsEMG data'])
            
                signalprocess.exFactor = round(parameters.nbextchan/size(signalprocess.data{i,nwin},1));
                signalprocess.ReSIG = zeros(signalprocess.exFactor * size(signalprocess.data{i,nwin},1));
                signalprocess.iReSIG{nwin} = zeros(signalprocess.exFactor * size(signalprocess.data{i,nwin},1));
                
                signalprocess.eSIG{nwin} = extend(signalprocess.data{i,nwin},signalprocess.exFactor);
                signalprocess.ReSIG = signalprocess.eSIG{nwin} * signalprocess.eSIG{nwin}' / size(signalprocess.eSIG{nwin},2);
                signalprocess.iReSIG{nwin} = pinv(signalprocess.ReSIG);
            
            %       1d: Removing the mean
                signalprocess.eSIG{nwin} = demean(signalprocess.eSIG{nwin});
            
            % Step 2: Whitening
            %Whitening with a regularization factor (average of the smallest half of 
            %the eigenvalues of the covariance matrix from the extended signals)
            
            %       2a: Get eigenvalues and eigenvectors (regularization factor =>
            %       average smallest half of eigenvalues)
                waitbar(0.6, f, ['Grid #' num2str(i) ' - Preprocessing - Whitening the HDsEMG data'])
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
            
            waitbar(0.8, f, ['Grid #' num2str(i) ' - Decomposition - Decomposing the HDsEMG data'])
            
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
            
            close(f)
                        
            for j = 1:parameters.NITER
            if j == 1
                signalprocess.X = signalprocess.wSIG{nwin}; % Initialize X (whitened signal), then X: residual
                
                if parameters.initialization == 1
                    actind = sum(signalprocess.X,1).^2;
                    [~, idx1(j)] = max(actind);
                    signalprocess.w = signalprocess.X(:, idx1(j)); % Initialize w
                else
                    signalprocess.w = randn(size(signalprocess.X,1),1); % Initialize w
                end
                time = linspace(0,size(signalprocess.X,2)/signal.fsamp,size(signalprocess.X,2));
            else
                if parameters.initialization == 1
                    actind(idx1(j-1)) = 0; % remove the previous vector
                    [~, idx1(j)] = max(actind);
                    signalprocess.w = signalprocess.X(:, idx1(j)); % Initialize w
                else
                    signalprocess.w = randn(size(signalprocess.X,1),1); % Initialize w
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
            
                plot(app.UIAxes_Decomp_2, signal.target, 'k--', 'LineWidth', 2, 'Color', [0.9412 0.9412 0.9412])
                line(app.UIAxes_Decomp_2,[signalprocess.coordinatesplateau(nwin*2-1) signalprocess.coordinatesplateau(nwin*2-1)],[0 max(signal.target)], 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                line(app.UIAxes_Decomp_2,[signalprocess.coordinatesplateau(nwin*2) signalprocess.coordinatesplateau(nwin*2)],[0 max(signal.target)], 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                app.EditField.Value = ['Grid #' num2str(i) ' - Iteration #' num2str(j) ' - Sil = ' num2str(signalprocess.SIL{nwin}(j)) ' CoV = ' num2str(signalprocess.CoV{nwin}(j))];
                plot(app.UIAxes_Decomp_1,time,signalprocess.icasig,time(signalprocess.spikes),signalprocess.icasig(signalprocess.spikes),'o', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412], 'MarkerSize', 10, 'MarkerEdgeColor', [0.85 0.33 0.10]);
                app.UIAxes_Decomp_1.YLim = [-0.2 1.5];
                drawnow;
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
            
            f = waitbar(0.8,['Grid #' num2str(i) ' - Postprocessing']);
            
            % Batch processing over each window
            [PulseT, distime] = batchprocessfilters(signalprocess.MUFilters, signalprocess.wSIG, signalprocess.coordinatesplateau, signalprocess.exFactor, 0, size(signal.data,2), signal.fsamp);
            
            if size(PulseT,1) > 0
            % Remove duplicates remduplicates(app.MUedition.edition.Pulsetrainclean{i}, app.MUedition.edition.Distimeclean{i}, app.MUedition.edition.Distimeclean{i}, round(app.MUedition.signal.fsamp/40), 0.00025, app.DuplicatethresholdEditField.Value, app.MUedition.signal.fsamp)
                [PulseT, distimenew] = remduplicates(PulseT, distime, distime, round(signal.fsamp/40), 0.00025, parameters.duplicatesthresh, signal.fsamp);
                
                if parameters.refineMU == 1    
                    % Remove outliers generating irrelevant discharge rates before manual
                    % edition (1st time)
                    distimenew = remoutliers(PulseT, distimenew, parameters.CoVDR, signal.fsamp);
                
                    % Reevaluate all the unique motor units over the contractions
                    [signal.Pulsetrain{i}, distimenew] = refineMUs(signal.data((i-1)*parameters.nbelectrodes+1:(i-1)*parameters.nbelectrodes+length(signal.EMGmask{i}), :), signal.EMGmask{i}, PulseT, distimenew, signal.fsamp);
                    
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
            
            close(f);
            end

            parameters.intensity = max(signal.target);

            app.EditField.Value = 'Saving data';
            % Save file
            clearvars signalprocess i j PulseT distime distimenew actind idx1 time ISI CoV maxiter nwin Wini temp
            savename = [app.pathname app.filename '_decomp.mat'];
            save(savename, 'signal', 'parameters');
            app.EditField.Value = 'Data saved';
            app.StartButton.BackgroundColor = [0.5 0.5 0.5];
        end

        % Button pushed function: SelectfileButton_2
        function SelectfileButton_2Pushed(app, event)
            app.UIFigure.Visible = 'off'; 
            [app.filename2,app.pathname2] = uigetfile;
            app.UIFigure.Visible = 'on'; 
            app.EditField_saving_2.Value = app.filename2;
        end

        % Button pushed function: ImportdataButton
        function ImportdataButtonPushed(app, event)
            app.MUdisplayedDropDown.Items = {};
            
            % Load the file
            if contains(app.filename2,'edited')
                files = load([app.pathname2 app.filename2], 'parameters', 'signal', 'edition'); 
                for i = 1:size(files.edition.Pulsetrain,2)
                    % Update the list and load the edited files
                    for j = 1:size(files.edition.Pulsetrain{i},1)
                        app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Grid_', num2str(i), '_MU_' , num2str(j)]});
                        files.edition.silval{i,j} = getsil(files.edition.Pulsetrain{i}(j,:), files.signal.fsamp);
                    end
                end
                app.MUdisplayedDropDown.Enable = 'on';
            else
                files = load([app.pathname2 app.filename2], 'parameters', 'signal');   
                for i = 1:size(files.signal.Pulsetrain,2)
                    % Update the list and load the edited files
                    files.edition.Pulsetrain{i} = files.signal.Pulsetrain{i};
                    for j = 1:size(files.signal.Pulsetrain{i},1)
                        files.edition.Dischargetimes{i,j} = files.signal.Dischargetimes{i,j};
                        app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Grid_', num2str(i), '_MU_' , num2str(j)]});

                        if length(files.edition.Dischargetimes{i,j}) > 2
                            files.edition.silval{i,j} = getsil(files.signal.Pulsetrain{i}(j,:), files.signal.fsamp);
                        else
                            files.edition.silval{i,j} = 1;
                        end
                        files.edition.time = linspace(0,size(files.signal.Pulsetrain{i},2)/files.signal.fsamp, size(files.signal.Pulsetrain{i},2));
                    end
                end
                app.MUdisplayedDropDown.Enable = 'on';
            end
            
            % Display the first MU
            C = strsplit(app.MUdisplayedDropDown.Value,'_');

            plot(app.UIAxesSpiketrain, files.edition.time, files.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, files.edition.time, files.signal.target/max(files.signal.target), '--', 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            plot(app.UIAxesSpiketrain, files.edition.time(files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), files.edition.Pulsetrain{str2double(C{2})}(1,files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')
            app.UIAxesSpiketrain.XColor = [0.9412 0.9412 0.9412];
            app.UIAxesSpiketrain.YColor = [0.9412 0.9412 0.9412];

            distime = zeros(1,length(files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime(i) = (round((files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / files.signal.fsamp;
            end
            DR = 1./((diff(files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/files.signal.fsamp);

            plot(app.UIAxesDR, distime, DR, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.EditField_2.Value = ['SIL = ' num2str(files.edition.silval{1,1})];

            app.UIAxesSpiketrain.XLim = [files.edition.time(1) files.edition.time(end)];
            app.UIAxesDR.XLim = [files.edition.time(1) files.edition.time(end)];
            app.UIAxesDR.YLim = [0 max(DR)*1.5];

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesDR.XColor = [0.9412 0.9412 0.9412];
            app.UIAxesDR.YColor = [0.9412 0.9412 0.9412];
            app.graphstart = files.edition.time(1);
            app.graphend = files.edition.time(end);

            app.MUedition = files;
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};
            app.Backup.lock = 0;
        end

        % Value changed function: MUdisplayedDropDown
        function MUdisplayedDropDownValueChanged(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end

            if ~isempty(distime)
                DR = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime, DR, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
                app.UIAxesDR.YLim = [0 max(DR)*1.5];
            end

            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];

        end

        % Button pushed function: ZoominButton
        function ZoominButtonPushed(app, event)
            duration = app.graphend - app.graphstart;
            center = app.graphstart + duration/2;
            duration = duration * 0.8;
            app.graphstart = center - duration/2;
            app.graphend = center + duration/2;
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
        end

        % Button pushed function: ZoomoutButton
        function ZoomoutButtonPushed(app, event)
            duration = app.graphend - app.graphstart;
            center = app.graphstart + duration/2;
            duration = duration * 1.5;
            if duration > (app.MUedition.edition.time(end) - app.MUedition.edition.time(1))
                app.graphstart = app.MUedition.edition.time(1);
                app.graphend = app.MUedition.edition.time(end);
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            else
                app.graphstart = center - duration/2;
                app.graphend = center + duration/2;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            end
        end

        % Button pushed function: ScrollleftButton
        function ScrollleftButtonPushed(app, event)
            duration = app.graphend - app.graphstart;
            step = 0.05 * duration;
            if (app.graphstart - step) < 0
                app.graphstart = 0;
                app.graphend = app.graphstart + duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            else
                app.graphstart = app.graphstart - step;
                app.graphend = app.graphstart + duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            end
        end

        % Button pushed function: ScrollrightButton
        function ScrollrightButtonPushed(app, event)
            duration = app.graphend - app.graphstart;
            step = 0.05 * duration;
            if (app.graphend + step) > app.MUedition.edition.time(end)
                app.graphend = app.MUedition.edition.time(end);
                app.graphstart = app.graphend - duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            else
                app.graphend = app.graphend + step;
                app.graphstart = app.graphend - duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            end
        end

        % Callback function: AddspikesButton, UIAxes_Decomp_2
        function AddspikesButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};
            
            app.roi = drawrectangle(app.UIAxesSpiketrain);
            y = [app.roi.Position(2) app.roi.Position(2) + app.roi.Position(4)];
            x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];

            temp = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:);
            temp(x(1)> app.MUedition.edition.time | app.MUedition.edition.time>x(2)) = 0;
            [~, locs] = findpeaks(temp,'MinPeakHeight', y(1), 'MinPeakDistance', round(0.005*app.MUedition.signal.fsamp));
            delete(app.roi)

            if ~isempty(locs)
                app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = [app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} locs];
                app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = unique(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});
                app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = sort(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});
                
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
    
                distime1 = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
                for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                    distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
                end
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
    
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
    
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end
        end

        % Button pushed function: DeletespikesButton
        function DeletespikesButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};
            
            app.roi = drawrectangle(app.UIAxesSpiketrain);
            y = [app.roi.Position(2) app.roi.Position(2) + app.roi.Position(4)];
            x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];

            idx = find(x(1)< app.MUedition.edition.time & app.MUedition.edition.time<x(2));
            idx2t1 = find(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:) > y(1) & app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:) < y(2));
            idx2t2 = find(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:) > 1.5);
            idx2 = [idx2t1 idx2t2];
            idx3 = intersect(idx,idx2);

            delete(app.roi)

            if ~isempty(idx3)
                idxdel = intersect(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})},idx3);
                for j = 1:length(idxdel)
                    app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} == idxdel(j)) = [];
                end
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
    
                distime1 = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
                for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                    distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
                end
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
    
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end
        end

        % Button pushed function: DeleteDRButton
        function DeleteDRButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};
            
            distime = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            DR = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
            
            app.roi = drawrectangle(app.UIAxesDR);
            y = [app.roi.Position(2) app.roi.Position(2) + app.roi.Position(4)];
            x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];

            idx = find(x(1)<distime & distime<x(2));
            idx2 = find(DR > y(1));
            idx3 = intersect(idx,idx2);
            delete(app.roi)

            idxdel = zeros(1,length(idx3));
            for i = 1:length(idx3)
                if app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idx3(i))) < app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idx3(i)+1))
                    idxdel(i) = idx3(i);
                else
                    idxdel(i) = idx3(i)+1;
                end
            end
            if ~isempty(idx3)
                app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idxdel) = [];
                
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
    
                distime1 = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
                for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                    distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
                end
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
    
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end
        end

        % Button pushed function: LockspikesButton
        function LockspikesButtonPushed(app, event)
            app.Backup.lock = 1;
            app.LockspikesButton.BackgroundColor = [0.5 0.5 0.5];
        end

        % Button pushed function: FlagMUfordeletionButton
        function FlagMUfordeletionButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};
            app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :) = 0;
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = [1 app.MUedition.signal.fsamp];

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);

            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];
        end

        % Button pushed function: UndoButton
        function UndoButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :) = app.Backup.Pulsetrain;
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = app.Backup.Dischargetimes;

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);

            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];
        end

        % Button pushed function: RemoveoutliersButton
        function RemoveoutliersButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            distime = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            DR = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
            thres = mean(DR) + 3*std(DR);
            idx = find(DR > thres);

            idxdel = zeros(1,length(idx));
            for i = 1:length(idx)
                if app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idx(i))) < app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idx(i)+1))
                    idxdel(i) = idx(i);
                else
                    idxdel(i) = idx(i)+1;
                end
            end
            if ~isempty(idx)
                app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(idxdel) = [];
                
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
    
                distime1 = zeros(1,length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
                for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                    distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
                end
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
    
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
    
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end
        end

        % Button pushed function: ReevaluatewithoutwhiteningButton
        function ReevaluatewithoutwhiteningButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            % Update MU filter
            nbextchan = 1500;
            idx = find(app.MUedition.edition.time > app.graphstart & app.MUedition.edition.time < app.graphend);
            EMG = app.MUedition.signal.data((str2double(C{2})-1)*app.MUedition.parameters.nbelectrodes+1:(str2double(C{2})-1)*app.MUedition.parameters.nbelectrodes+length(app.MUedition.signal.EMGmask{str2double(C{2})}),:);
            EMG = EMG(app.MUedition.signal.EMGmask{str2double(C{2})}==0,idx);
            EMG = bandpassingals(EMG, app.MUedition.signal.fsamp, 1);
            spikes1 = intersect(idx(round(0.1*app.MUedition.signal.fsamp):end-round(0.1*app.MUedition.signal.fsamp)),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});
            spikes2 = (spikes1 - idx(1));
            exFactor1 = round(nbextchan/size(EMG,1));
            eSIG = extend(EMG,exFactor1);
            ReSIG = eSIG*eSIG'/length(eSIG);
            iReSIGt = pinv(ReSIG);
            MUFilters = sum(eSIG(:,spikes2),2);

            Pt = (MUFilters'*iReSIGt)*eSIG; % Update the pulse train
            Pt= Pt(1:size(EMG,2));
            Pt([1:round(0.1*app.MUedition.signal.fsamp) end-round(0.1*app.MUedition.signal.fsamp):end]) = 0; % Remove the edges
            Pt = Pt .* abs(Pt); % Normalized and update the pulse train
            [~,spikes] = findpeaks(Pt,'MinPeakDistance', round(app.MUedition.signal.fsamp*0.005)); % Peak detection
            Pt = Pt/mean(maxk(Pt(spikes),10));

            [L,C2] = kmeans(Pt(spikes)',2); % Kmean classification
            [~, idx2] = max(C2); % Find the class with the highest centroid
            spikes2 = spikes(L==idx2);
            spikes2(Pt(spikes2)>mean(Pt(spikes2))+3*std(Pt(spikes2))) = []; % remove the outliers of the pulse train for the calculation of the filter
             
            if app.Backup.lock == 1
                spikeso = spikes1 - idx(1);
                for i = 1:length(spikeso)
                   [~, imax] = max(Pt(spikeso(i) - 10: spikeso(i) + 10));
                   spikeso(i) = spikeso(i) + imax - 11;
                end
                spikes2 = setdiff(spikes2, spikeso);
                spikes2 = [spikes2, spikeso];
                app.Backup.lock = 0;
                app.LockspikesButton.BackgroundColor = [0.15,0.15,0.15];
            end

            app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),idx(1)+round(0.1*app.MUedition.signal.fsamp)-1:idx(end)-round(0.1*app.MUedition.signal.fsamp)) = Pt(round(0.1*app.MUedition.signal.fsamp):end-round(0.1*app.MUedition.signal.fsamp));
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = setdiff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})},spikes1);
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = [app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, spikes2 + idx(1) - 1];
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = sort(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});

            oldsil = app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})};
            app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})} = getsil(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.signal.fsamp);
            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];
            
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            
            % Color code based one the change in SIL value
            if (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 4
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.6350 0.0780 0.1840]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 2 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 4
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.8500 0.3250 0.0980]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 2
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.3010 0.7450 0.9330]);
            else
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.4660 0.6740 0.1880]);
            end
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end

            if ~isempty(distime1)
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end

            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
        end

        % Button pushed function: ReevaluatewithwhiteningButton
        function ReevaluatewithwhiteningButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            % Update MU filter
            nbextchan = 1500;
            idx = find(app.MUedition.edition.time > app.graphstart & app.MUedition.edition.time < app.graphend);
            EMG = app.MUedition.signal.data((str2double(C{2})-1)*app.MUedition.parameters.nbelectrodes+1:(str2double(C{2})-1)*app.MUedition.parameters.nbelectrodes+length(app.MUedition.signal.EMGmask{str2double(C{2})}),:);
            EMG = EMG(app.MUedition.signal.EMGmask{str2double(C{2})}==0,idx);
            EMG = bandpassingals(EMG, app.MUedition.signal.fsamp, 1);
            spikes1 = intersect(idx(round(0.1*app.MUedition.signal.fsamp):end-round(0.1*app.MUedition.signal.fsamp)),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});
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
            Pt([1:round(0.1*app.MUedition.signal.fsamp) end-round(0.1*app.MUedition.signal.fsamp):end]) = 0; % Remove the edges
            Pt = Pt .* abs(Pt); % Normalized and update the pulse train
            [~,spikes] = findpeaks(Pt,'MinPeakDistance', round(app.MUedition.signal.fsamp*0.005)); % Peak detection
            Pt = Pt/mean(maxk(Pt(spikes),10));

            [L,C2] = kmeans(Pt(spikes)',2); % Kmean classification
            [~, idx2] = max(C2); % Find the class with the highest centroid
            spikes2 = spikes(L==idx2);
            spikes2(Pt(spikes2)>mean(Pt(spikes2))+3*std(Pt(spikes2))) = []; % remove the outliers of the pulse train for the calculation of the filter

            if app.Backup.lock == 1
                spikeso = spikes1 - idx(1);
                for i = 1:length(spikeso)
                   [~, imax] = max(Pt(spikeso(i) - 10: spikeso(i) + 10));
                   spikeso(i) = spikeso(i) + imax - 11;
                end
                spikes2 = setdiff(spikes2, spikeso);
                spikes2 = [spikes2, spikeso];
                app.Backup.lock = 0;
                app.LockspikesButton.BackgroundColor = [0.15,0.15,0.15];
            end

            app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),idx(1)+round(0.1*app.MUedition.signal.fsamp)-1:idx(end)-round(0.1*app.MUedition.signal.fsamp)) = Pt(round(0.1*app.MUedition.signal.fsamp):end-round(0.1*app.MUedition.signal.fsamp));
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = setdiff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})},spikes1);
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = [app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, spikes2 + idx(1) - 1];
            app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})} = sort(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})});

            oldsil = app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})};
            app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})} = getsil(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.signal.fsamp);
            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);

            % Color code based one the change in SIL value
            if (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 4
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.6350 0.0780 0.1840]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 2 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 4
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.8500 0.3250 0.0980]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 2
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.3010 0.7450 0.9330]);
            else
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.4660 0.6740 0.1880]);
            end
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end

            if ~isempty(distime1)
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end

            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
        end

        % Button pushed function: RemovealltheoutliersButton
        function RemovealltheoutliersButtonPushed(app, event)
            fwb = waitbar(0, 'Starting batch processing');
            ite = 0;
            itetot = 0;
            for f = 1:app.MUedition.signal.ngrid
                itetot = itetot + size(app.MUedition.edition.Pulsetrain{f},1);
            end
            for f = 1:app.MUedition.signal.ngrid
                for mu = 1:size(app.MUedition.edition.Pulsetrain{f},1)
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Removing outliers for Grid#' num2str(f) ' _MU#' num2str(mu)])
                    
                    distime = zeros(1, length(app.MUedition.edition.Dischargetimes{f,mu})-1);
                    for i = 1:length(app.MUedition.edition.Dischargetimes{f,mu})-1
                        distime(i) = (round((app.MUedition.edition.Dischargetimes{f,mu}(i+1) - app.MUedition.edition.Dischargetimes{f,mu}(i)) / 2) + app.MUedition.edition.Dischargetimes{f,mu}(i)) / app.MUedition.signal.fsamp;
                    end
                    DR = 1./((diff(app.MUedition.edition.Dischargetimes{f,mu}))/app.MUedition.signal.fsamp);

                    k = 1;
                    while (std(DR)/mean(DR)) > 0.3 && k < 30
                        k = k + 1;       
                        thres = mean(DR) + 3*std(DR);
                        idx = find(DR > thres);
                        if ~isempty(idx)
                            idxdel = zeros(1, length(idx));
                            for i = 1:length(idx)
                                if app.MUedition.edition.Pulsetrain{f}(mu,app.MUedition.edition.Dischargetimes{f,mu}(idx(i))) < app.MUedition.edition.Pulsetrain{f}(mu, app.MUedition.edition.Dischargetimes{f,mu}(idx(i)+1))
                                    idxdel(i) = idx(i);
                                else
                                    idxdel(i) = idx(i)+1;
                                end
                            end
                            app.MUedition.edition.Dischargetimes{f,mu}(idxdel) = [];
                        end

                        %update DR
                        clearvars distime DR idxdel
                        for i = 1:length(app.MUedition.edition.Dischargetimes{f,mu})-1
                            distime(i) = (round((app.MUedition.edition.Dischargetimes{f,mu}(i+1) - app.MUedition.edition.Dischargetimes{f,mu}(i)) / 2) + app.MUedition.edition.Dischargetimes{f,mu}(i)) / app.MUedition.signal.fsamp;
                        end
                        DR = 1./((diff(app.MUedition.edition.Dischargetimes{f,mu}))/app.MUedition.signal.fsamp);
                    end
                    clearvars distime DR
                end
            end
            delete(fwb)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');

            % Update graph
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];
        end

        % Button pushed function: ReevaluateallMUfiltersButton
        function ReevaluateallMUfiltersButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            
            % Update MU filter
            nbextchan = 1500;
            fwb = waitbar(0, 'Starting batch processing');
            ite = 0;
            itetot = 0;
            for f = 1:app.MUedition.signal.ngrid
                itetot = itetot + size(app.MUedition.edition.Pulsetrain{f},1);
            end
            for f = 1:app.MUedition.signal.ngrid
                EMG = app.MUedition.signal.data((f-1)*app.MUedition.parameters.nbelectrodes+1:(f-1)*app.MUedition.parameters.nbelectrodes+length(app.MUedition.signal.EMGmask{f}),:);
                EMG = EMG(app.MUedition.signal.EMGmask{f}==0,:);
                exFactor1 = round(nbextchan/size(EMG,1));
                eSIG = extend(EMG,exFactor1);
                ReSIG = eSIG*eSIG'/length(eSIG);
                iReSIGt = pinv(ReSIG);

                for mu = 1:size(app.MUedition.edition.Pulsetrain{f},1)
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Recalculating filter for Grid#' num2str(f) ' MU#' num2str(mu)])

                    if length(app.MUedition.edition.Dischargetimes{f,mu})>2
                        MUFilters = sum(eSIG(:,app.MUedition.edition.Dischargetimes{f,mu}),2);
                        Pt = (MUFilters'*iReSIGt)*eSIG; % Update the pulse train
                        Pt= Pt(1:size(EMG,2));
                        Pt = Pt .* abs(Pt); % Normalized and update the pulse train
                        [~,spikes] = findpeaks(Pt,'MinPeakDistance', round(app.MUedition.signal.fsamp*0.005)); % Peak detection
                        Pt = Pt/mean(maxk(Pt(spikes),10));
                        [L,C2] = kmeans(Pt(spikes)',2); % Kmean classification
                        [~, idx2] = max(C2); % Find the class with the highest centroid
                        spikes2 = spikes(L==idx2);
                        spikes2(Pt(spikes2)>mean(Pt(spikes2))+3*std(Pt(spikes2))) = []; % remove the outliers of the pulse train for the calculation of the filter

                        app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];
            
                        app.MUedition.edition.Pulsetrain{f}(mu,:) = Pt;
                        app.MUedition.edition.Dischargetimes{f,mu} = [];
                        app.MUedition.edition.Dischargetimes{f,mu} = spikes2;
                        app.MUedition.edition.silval{f,mu} = getsil(app.MUedition.edition.Pulsetrain{f}(mu,:), app.MUedition.signal.fsamp);
                        clearvars Pt MUFilters spikest
                    end
                end
                clearvars EMG eSIG iReSIGt dischan ReSIG
            end
            delete(fwb)
            % Update the graph
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i+1) - app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / 2) + app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}(i)) / app.MUedition.signal.fsamp;
            end
            if ~isempty(distime1)
                DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}))/app.MUedition.signal.fsamp);
                plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);
                app.UIAxesDR.YLim = [0 max(DR1)*1.5];
            end

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
        end

        % Button pushed function: RemoveflaggedMUButton
        function RemoveflaggedMUButtonPushed(app, event)
            % Remove the flagged motor units
            fwb = waitbar(0, 'Checking flagged units');
            ite = 0;
            itetot = 0;
            for f = 1:size(app.MUedition.edition.Pulsetrain,2)
                itetot = itetot + size(app.MUedition.edition.Pulsetrain{f},1);
            end

            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrainclean{i} = app.MUedition.edition.Pulsetrain{i};
                app.MUedition.edition.Distimeclean{i} = {};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Distimeclean{i}{j} = app.MUedition.edition.Dischargetimes{i,j};
                end
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    idx = size(app.MUedition.edition.Pulsetrain{i},1)+1-j;
                    if length(app.MUedition.edition.Dischargetimes{i,idx}) == 2 && mean(app.MUedition.edition.Pulsetrain{i}(idx,:)) == 0
                        app.MUedition.edition.Distimeclean{i}{idx} = [];
                        app.MUedition.edition.Pulsetrainclean{i}(idx,:) = [];
                    end
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Checking flagged units for Grid#' num2str(i) ' _MU#' num2str(j)])
                end
                app.MUedition.edition.Distimeclean{i} = app.MUedition.edition.Distimeclean{i}(~cellfun('isempty',app.MUedition.edition.Distimeclean{i}));
            end

            app.MUedition.edition.Dischargetimes = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrain{i} = app.MUedition.edition.Pulsetrainclean{i};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = app.MUedition.edition.Distimeclean{i}{j};
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Grid_', num2str(i), '_MU_' , num2str(j)]});
                end
            end

            % Update the graph
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{1}(1,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{1,1}), app.MUedition.edition.Pulsetrain{1}(1,app.MUedition.edition.Dischargetimes{1,1}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{1,1})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{1,1})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{1,1}(i+1) - app.MUedition.edition.Dischargetimes{1,1}(i)) / 2) + app.MUedition.edition.Dischargetimes{1,1}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{1,1}))/app.MUedition.signal.fsamp);
            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];

            delete(fwb)
        end

        % Button pushed function: RemoveduplicateswithingridsButton
        function RemoveduplicateswithingridsButtonPushed(app, event)
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrainclean{i} = app.MUedition.edition.Pulsetrain{i};
                app.MUedition.edition.Distimeclean{i} = {};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Distimeclean{i}{j} = app.MUedition.edition.Dischargetimes{i,j};
                end
                [app.MUedition.edition.Pulsetrainclean{i}, app.MUedition.edition.Distimeclean{i}] = remduplicates(app.MUedition.edition.Pulsetrainclean{i}, app.MUedition.edition.Distimeclean{i}, app.MUedition.edition.Distimeclean{i}, round(app.MUedition.signal.fsamp/40), 0.00025, app.DuplicatethresholdEditField.Value, app.MUedition.signal.fsamp);
            end

            app.MUedition.edition.Dischargetimes = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrain{i} = app.MUedition.edition.Pulsetrainclean{i};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = app.MUedition.edition.Distimeclean{i}{j};
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Grid_', num2str(i), '_MU_' , num2str(j)]});
                end
            end

            % Update the graph
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{1}(1,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{1,1}), app.MUedition.edition.Pulsetrain{1}(1,app.MUedition.edition.Dischargetimes{1,1}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{1,1})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{1,1})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{1,1}(i+1) - app.MUedition.edition.Dischargetimes{1,1}(i)) / 2) + app.MUedition.edition.Dischargetimes{1,1}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{1,1}))/app.MUedition.signal.fsamp);
            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];
        end

        % Button pushed function: RemoveduplicatesbetweengridsButton
        function RemoveduplicatesbetweengridsButtonPushed(app, event)
            nmu = 0;
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                if ~isempty(app.MUedition.edition.Pulsetrain{i})
                    nmu = nmu + size(app.MUedition.edition.Pulsetrain{i},1);
                end
            end
            
            PulseT = zeros(nmu, length(app.MUedition.signal.target));
            Distim = cell(1,nmu);
            muscle = zeros(1,nmu);
            mu = 1;
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                if ~isempty(app.MUedition.edition.Pulsetrain{i})
                    for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                        PulseT(mu,:) = app.MUedition.edition.Pulsetrain{i}(j,:);
                        Distim{mu} = app.MUedition.edition.Dischargetimes{i,j};
                        muscle(mu) = i;
                        mu = mu+ 1;
                    end
                end
            end
            
            [PulseT, Distim, muscle] = remduplicatesbgrids(PulseT, Distim, muscle, round(app.MUedition.signal.fsamp/40), 0.00025, app.DuplicatethresholdEditField.Value, app.MUedition.signal.fsamp);
            app.MUedition.edition.Dischargetimes = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                idx = find(muscle == i);
                app.MUedition.edition.Pulsetrain{i} = PulseT(idx,:);
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = Distim{idx(j)};
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Grid_', num2str(i), '_MU_' , num2str(j)]});
                end
            end

            % Update the graph
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{1}(1,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{1,1}), app.MUedition.edition.Pulsetrain{1}(1,app.MUedition.edition.Dischargetimes{1,1}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            hold(app.UIAxesSpiketrain, 'off')

            distime1 = zeros(1, length(app.MUedition.edition.Dischargetimes{1,1})-1);
            for i = 1:length(app.MUedition.edition.Dischargetimes{1,1})-1
                distime1(i) = (round((app.MUedition.edition.Dischargetimes{1,1}(i+1) - app.MUedition.edition.Dischargetimes{1,1}(i)) / 2) + app.MUedition.edition.Dischargetimes{1,1}(i)) / app.MUedition.signal.fsamp;
            end
            DR1 = 1./((diff(app.MUedition.edition.Dischargetimes{1,1}))/app.MUedition.signal.fsamp);
            plot(app.UIAxesDR, distime1, DR1, 'o', 'LineWidth', 1.5, 'MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412]);

            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.YLim = [0 max(DR1)*1.5];
        end

        % Button pushed function: PlotMUspiketrainsButton
        function PlotMUspiketrainsButtonPushed(app, event)
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                firings = nan(size(app.MUedition.edition.Pulsetrain{i}));
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    firings(j,app.MUedition.edition.Dischargetimes{i,j}) = j;
                end
                subplot(1,app.MUedition.signal.ngrid,i)
                plot(app.MUedition.edition.time,firings,'|','MarkerSize', 10, 'Color', [0.9412 0.9412 0.9412])
                hold on
                plot(app.MUedition.edition.time,app.MUedition.signal.target/max(app.MUedition.signal.target)*j,'--','LineWidth',1,'Color',[0.85 0.33 0.10]);
                title(['Grid#' num2str(i) ' with ' num2str(j) ' MUs'], 'Color', [0.9412 0.9412 0.9412], 'FontName', 'Avenir Next')
                xlabel('Time (s)', 'FontName', 'Avenir Next')
                ylabel('MU#', 'FontName', 'Avenir Next')
                ylim([0 j+1])
                set(gcf,'Color', [0.15 0.15 0.15]);
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
                set(gca,'Color', [0.15 0.15 0.15], 'XColor', [0.9412 0.9412 0.9412], 'YColor', [0.9412 0.9412 0.9412]);
            end
            sgtitle(['Raster plots for ' num2str(i) ' grids'], 'FontName', 'Avenir Next', 'FontSize', 25, 'Color', [0.9412 0.9412 0.9412])
        end

        % Button pushed function: PlotMUfiringratesButton
        function PlotMUfiringratesButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            win = hann(app.MUedition.signal.fsamp);
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                firings = zeros(size(app.MUedition.edition.Pulsetrain{i}));
                smoothdr = zeros(size(app.MUedition.edition.Pulsetrain{i}));
                subplot(1,app.MUedition.signal.ngrid,i)
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    firings(j,app.MUedition.edition.Dischargetimes{i,j}) = 1;
                    smoothdr(j,:) = conv(firings(j,:),win,'same');
                    if i == str2double(C{2}) && j == str2double(C{4})
                        plot(app.MUedition.edition.time,smoothdr(j,:), 'Color', [0.85 0.33 0.10], 'LineWidth', 3)
                        hold on
                    else
                        plot(app.MUedition.edition.time,smoothdr(j,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1)
                        hold on
                    end
                end
                clearvars firings smoothdr

                title(['Grid#' num2str(i) ' with ' num2str(j) ' MUs'], 'Color', [0.9412 0.9412 0.9412], 'FontName', 'Avenir Next')
                xlabel('Time (s)', 'FontName', 'Avenir Next')
                ylabel('Smoothed discharge rates', 'FontName', 'Avenir Next')
                set(gcf,'Color', [0.15 0.15 0.15]);
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
                set(gca,'Color', [0.15 0.15 0.15], 'XColor', [0.9412 0.9412 0.9412], 'YColor', [0.9412 0.9412 0.9412]);
            end
            sgtitle(['Smoothed discharge rates for ' num2str(i) ' grids'], 'FontName', 'Avenir Next', 'FontSize', 25, 'Color', [0.9412 0.9412 0.9412])
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            fwb = waitbar(0, 'Checking flagged units');
            ite = 0;
            itetot = 0;
            for f = 1:size(app.MUedition.edition.Pulsetrain,2)
                itetot = itetot + size(app.MUedition.edition.Pulsetrain{f},1);
            end

            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrainclean{i} = app.MUedition.edition.Pulsetrain{i};
                app.MUedition.edition.Distimeclean{i} = {};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Distimeclean{i}{j} = app.MUedition.edition.Dischargetimes{i,j};
                end
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    idx = size(app.MUedition.edition.Pulsetrain{i},1)+1-j;
                    if length(app.MUedition.edition.Dischargetimes{i,idx}) == 2 && mean(app.MUedition.edition.Pulsetrain{i}(idx,:)) == 0
                        app.MUedition.edition.Distimeclean{i}{idx} = [];
                        app.MUedition.edition.Pulsetrainclean{i}(idx,:) = [];
                    end
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Checking flagged units for Grid#' num2str(i) ' _MU#' num2str(j)])
                end
                app.MUedition.edition.Distimeclean{i} = app.MUedition.edition.Distimeclean{i}(~cellfun('isempty',app.MUedition.edition.Distimeclean{i}));
            end

            app.MUedition.edition.Dischargetimes = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrain{i} = app.MUedition.edition.Pulsetrainclean{i};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = app.MUedition.edition.Distimeclean{i}{j};
                end
            end
            
            delete(fwb)

            if contains(app.filename2,'edited')
                savename = [app.pathname2 app.filename2];
            else
                savename = [app.pathname2 app.filename2 '_edited.mat'];
            end
            signal = app.MUedition.signal;
            parameters = app.MUedition.parameters;
            edition = app.MUedition.edition;
            save(savename, 'signal', 'parameters', 'edition', '-v7.3');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [100 100 1141 690];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 646 224 43];

            % Create DecompositionTab
            app.DecompositionTab = uitab(app.TabGroup);
            app.DecompositionTab.Title = 'Decomposition';
            app.DecompositionTab.BackgroundColor = [0.149 0.149 0.149];
            app.DecompositionTab.ForegroundColor = [0.502 0.502 0.502];
            app.DecompositionTab.ButtonDownFcn = createCallbackFcn(app, @DecompositionTabButtonDown, true);

            % Create EditionTab
            app.EditionTab = uitab(app.TabGroup);
            app.EditionTab.Title = 'Edition';
            app.EditionTab.BackgroundColor = [0.149 0.149 0.149];
            app.EditionTab.ForegroundColor = [0.502 0.502 0.502];
            app.EditionTab.ButtonDownFcn = createCallbackFcn(app, @EditionTabButtonDown, true);

            % Create EditionPanel
            app.EditionPanel = uipanel(app.UIFigure);
            app.EditionPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.EditionPanel.Title = 'Edition';
            app.EditionPanel.BackgroundColor = [0.149 0.149 0.149];
            app.EditionPanel.FontName = 'Avenir Next';
            app.EditionPanel.FontWeight = 'bold';
            app.EditionPanel.FontSize = 14;
            app.EditionPanel.Position = [2 1 225 665];

            % Create EditField_saving_2
            app.EditField_saving_2 = uieditfield(app.EditionPanel, 'text');
            app.EditField_saving_2.Editable = 'off';
            app.EditField_saving_2.FontName = 'Avenir Next';
            app.EditField_saving_2.FontSize = 14;
            app.EditField_saving_2.FontColor = [0.8118 0.502 1];
            app.EditField_saving_2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_saving_2.Position = [7 598 94 34];
            app.EditField_saving_2.Value = 'File name';

            % Create SelectfileButton_2
            app.SelectfileButton_2 = uibutton(app.EditionPanel, 'push');
            app.SelectfileButton_2.ButtonPushedFcn = createCallbackFcn(app, @SelectfileButton_2Pushed, true);
            app.SelectfileButton_2.BackgroundColor = [0.149 0.149 0.149];
            app.SelectfileButton_2.FontName = 'Avenir Next';
            app.SelectfileButton_2.FontSize = 14;
            app.SelectfileButton_2.FontWeight = 'bold';
            app.SelectfileButton_2.FontColor = [0.8118 0.502 1];
            app.SelectfileButton_2.Position = [114 598 101 34];
            app.SelectfileButton_2.Text = 'Select file';

            % Create ImportdataButton
            app.ImportdataButton = uibutton(app.EditionPanel, 'push');
            app.ImportdataButton.ButtonPushedFcn = createCallbackFcn(app, @ImportdataButtonPushed, true);
            app.ImportdataButton.BackgroundColor = [0.149 0.149 0.149];
            app.ImportdataButton.FontName = 'Avenir Next';
            app.ImportdataButton.FontSize = 14;
            app.ImportdataButton.FontWeight = 'bold';
            app.ImportdataButton.FontColor = [0.8118 0.502 1];
            app.ImportdataButton.Position = [8 556 207 34];
            app.ImportdataButton.Text = 'Import data';

            % Create RemovealltheoutliersButton
            app.RemovealltheoutliersButton = uibutton(app.EditionPanel, 'push');
            app.RemovealltheoutliersButton.ButtonPushedFcn = createCallbackFcn(app, @RemovealltheoutliersButtonPushed, true);
            app.RemovealltheoutliersButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemovealltheoutliersButton.FontName = 'Avenir Next';
            app.RemovealltheoutliersButton.FontSize = 14;
            app.RemovealltheoutliersButton.FontWeight = 'bold';
            app.RemovealltheoutliersButton.FontColor = [0.5608 0.6196 0.851];
            app.RemovealltheoutliersButton.Position = [8 474 207 34];
            app.RemovealltheoutliersButton.Text = '1 - Remove all the outliers';

            % Create ReevaluateallMUfiltersButton
            app.ReevaluateallMUfiltersButton = uibutton(app.EditionPanel, 'push');
            app.ReevaluateallMUfiltersButton.ButtonPushedFcn = createCallbackFcn(app, @ReevaluateallMUfiltersButtonPushed, true);
            app.ReevaluateallMUfiltersButton.BackgroundColor = [0.149 0.149 0.149];
            app.ReevaluateallMUfiltersButton.FontName = 'Avenir Next';
            app.ReevaluateallMUfiltersButton.FontSize = 14;
            app.ReevaluateallMUfiltersButton.FontWeight = 'bold';
            app.ReevaluateallMUfiltersButton.FontColor = [0.5608 0.6196 0.851];
            app.ReevaluateallMUfiltersButton.Position = [8 430 207 34];
            app.ReevaluateallMUfiltersButton.Text = '2 - Re-evaluate all MU filters';

            % Create RemoveflaggedMUButton
            app.RemoveflaggedMUButton = uibutton(app.EditionPanel, 'push');
            app.RemoveflaggedMUButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveflaggedMUButtonPushed, true);
            app.RemoveflaggedMUButton.WordWrap = 'on';
            app.RemoveflaggedMUButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveflaggedMUButton.FontName = 'Avenir Next';
            app.RemoveflaggedMUButton.FontSize = 14;
            app.RemoveflaggedMUButton.FontWeight = 'bold';
            app.RemoveflaggedMUButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveflaggedMUButton.Position = [8 386 207 34];
            app.RemoveflaggedMUButton.Text = '3 - Remove flagged MU';

            % Create PlotMUspiketrainsButton
            app.PlotMUspiketrainsButton = uibutton(app.EditionPanel, 'push');
            app.PlotMUspiketrainsButton.ButtonPushedFcn = createCallbackFcn(app, @PlotMUspiketrainsButtonPushed, true);
            app.PlotMUspiketrainsButton.BackgroundColor = [0.149 0.149 0.149];
            app.PlotMUspiketrainsButton.FontName = 'Avenir Next';
            app.PlotMUspiketrainsButton.FontSize = 14;
            app.PlotMUspiketrainsButton.FontWeight = 'bold';
            app.PlotMUspiketrainsButton.FontColor = [0.3804 0.7804 0.749];
            app.PlotMUspiketrainsButton.Position = [8 184 207 34];
            app.PlotMUspiketrainsButton.Text = 'Plot MU spike trains';

            % Create SaveButton
            app.SaveButton = uibutton(app.EditionPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.149 0.149 0.149];
            app.SaveButton.FontName = 'Avenir Next';
            app.SaveButton.FontSize = 14;
            app.SaveButton.FontWeight = 'bold';
            app.SaveButton.FontColor = [0.9412 0.9412 0.9412];
            app.SaveButton.Position = [8 41 207 34];
            app.SaveButton.Text = 'Save';

            % Create BatchprocessingLabel
            app.BatchprocessingLabel = uilabel(app.EditionPanel);
            app.BatchprocessingLabel.HorizontalAlignment = 'center';
            app.BatchprocessingLabel.FontName = 'Avenir Next';
            app.BatchprocessingLabel.FontSize = 14;
            app.BatchprocessingLabel.FontColor = [0.9412 0.9412 0.9412];
            app.BatchprocessingLabel.Position = [54 511 115 22];
            app.BatchprocessingLabel.Text = 'Batch processing';

            % Create VisualisationLabel
            app.VisualisationLabel = uilabel(app.EditionPanel);
            app.VisualisationLabel.HorizontalAlignment = 'center';
            app.VisualisationLabel.FontName = 'Avenir Next';
            app.VisualisationLabel.FontSize = 14;
            app.VisualisationLabel.FontColor = [0.9412 0.9412 0.9412];
            app.VisualisationLabel.Position = [70 223 84 22];
            app.VisualisationLabel.Text = 'Visualisation';

            % Create SavetheeditionLabel
            app.SavetheeditionLabel = uilabel(app.EditionPanel);
            app.SavetheeditionLabel.HorizontalAlignment = 'center';
            app.SavetheeditionLabel.WordWrap = 'on';
            app.SavetheeditionLabel.FontName = 'Avenir Next';
            app.SavetheeditionLabel.FontSize = 14;
            app.SavetheeditionLabel.FontColor = [0.9412 0.9412 0.9412];
            app.SavetheeditionLabel.Position = [12 81 199 22];
            app.SavetheeditionLabel.Text = 'Save the edition';

            % Create PlotMUfiringratesButton
            app.PlotMUfiringratesButton = uibutton(app.EditionPanel, 'push');
            app.PlotMUfiringratesButton.ButtonPushedFcn = createCallbackFcn(app, @PlotMUfiringratesButtonPushed, true);
            app.PlotMUfiringratesButton.BackgroundColor = [0.149 0.149 0.149];
            app.PlotMUfiringratesButton.FontName = 'Avenir Next';
            app.PlotMUfiringratesButton.FontSize = 14;
            app.PlotMUfiringratesButton.FontWeight = 'bold';
            app.PlotMUfiringratesButton.FontColor = [0.3804 0.7804 0.749];
            app.PlotMUfiringratesButton.Position = [8 139 207 34];
            app.PlotMUfiringratesButton.Text = 'Plot MU firing rates';

            % Create RemoveduplicateswithingridsButton
            app.RemoveduplicateswithingridsButton = uibutton(app.EditionPanel, 'push');
            app.RemoveduplicateswithingridsButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveduplicateswithingridsButtonPushed, true);
            app.RemoveduplicateswithingridsButton.WordWrap = 'on';
            app.RemoveduplicateswithingridsButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveduplicateswithingridsButton.FontName = 'Avenir Next';
            app.RemoveduplicateswithingridsButton.FontSize = 14;
            app.RemoveduplicateswithingridsButton.FontWeight = 'bold';
            app.RemoveduplicateswithingridsButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveduplicateswithingridsButton.Position = [8 333 207 43];
            app.RemoveduplicateswithingridsButton.Text = '4 - Remove duplicates within grids';

            % Create RemoveduplicatesbetweengridsButton
            app.RemoveduplicatesbetweengridsButton = uibutton(app.EditionPanel, 'push');
            app.RemoveduplicatesbetweengridsButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveduplicatesbetweengridsButtonPushed, true);
            app.RemoveduplicatesbetweengridsButton.WordWrap = 'on';
            app.RemoveduplicatesbetweengridsButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveduplicatesbetweengridsButton.FontName = 'Avenir Next';
            app.RemoveduplicatesbetweengridsButton.FontSize = 14;
            app.RemoveduplicatesbetweengridsButton.FontWeight = 'bold';
            app.RemoveduplicatesbetweengridsButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveduplicatesbetweengridsButton.Position = [8 280 207 43];
            app.RemoveduplicatesbetweengridsButton.Text = '5 - Remove duplicates between grids';

            % Create ManualeditionPanel
            app.ManualeditionPanel = uipanel(app.UIFigure);
            app.ManualeditionPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.ManualeditionPanel.Title = 'Manual edition';
            app.ManualeditionPanel.BackgroundColor = [0.149 0.149 0.149];
            app.ManualeditionPanel.FontName = 'Avenir Next';
            app.ManualeditionPanel.FontWeight = 'bold';
            app.ManualeditionPanel.FontSize = 14;
            app.ManualeditionPanel.Position = [224 1 919 691];

            % Create UIAxesSpiketrain
            app.UIAxesSpiketrain = uiaxes(app.ManualeditionPanel);
            xlabel(app.UIAxesSpiketrain, 'Time (s)')
            ylabel(app.UIAxesSpiketrain, 'Pulse train')
            zlabel(app.UIAxesSpiketrain, 'Z')
            app.UIAxesSpiketrain.Toolbar.Visible = 'off';
            app.UIAxesSpiketrain.FontName = 'Avenir Next';
            app.UIAxesSpiketrain.Color = 'none';
            app.UIAxesSpiketrain.FontSize = 14;
            app.UIAxesSpiketrain.Interruptible = 'off';
            app.UIAxesSpiketrain.HitTest = 'off';
            app.UIAxesSpiketrain.PickableParts = 'none';
            app.UIAxesSpiketrain.Position = [9 48 905 301];

            % Create UIAxesDR
            app.UIAxesDR = uiaxes(app.ManualeditionPanel);
            xlabel(app.UIAxesDR, 'Time (s)')
            ylabel(app.UIAxesDR, 'Discharge rate')
            zlabel(app.UIAxesDR, 'Z')
            app.UIAxesDR.Toolbar.Visible = 'off';
            app.UIAxesDR.FontName = 'Avenir Next';
            app.UIAxesDR.Color = 'none';
            app.UIAxesDR.FontSize = 14;
            app.UIAxesDR.GridColor = [0.9412 0.9412 0.9412];
            app.UIAxesDR.MinorGridColor = [0.9412 0.9412 0.9412];
            app.UIAxesDR.Interruptible = 'off';
            app.UIAxesDR.HitTest = 'off';
            app.UIAxesDR.PickableParts = 'none';
            app.UIAxesDR.Position = [9 406 905 218];

            % Create MUdisplayedDropDown
            app.MUdisplayedDropDown = uidropdown(app.ManualeditionPanel);
            app.MUdisplayedDropDown.Items = {'No MUs'};
            app.MUdisplayedDropDown.ValueChangedFcn = createCallbackFcn(app, @MUdisplayedDropDownValueChanged, true);
            app.MUdisplayedDropDown.Enable = 'off';
            app.MUdisplayedDropDown.FontName = 'Avenir Next';
            app.MUdisplayedDropDown.FontSize = 14;
            app.MUdisplayedDropDown.FontColor = [0.9412 0.9412 0.9412];
            app.MUdisplayedDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.MUdisplayedDropDown.Position = [132 632 139 34];
            app.MUdisplayedDropDown.Value = 'No MUs';

            % Create MUdisplayedDropDownLabel
            app.MUdisplayedDropDownLabel = uilabel(app.ManualeditionPanel);
            app.MUdisplayedDropDownLabel.HorizontalAlignment = 'center';
            app.MUdisplayedDropDownLabel.FontName = 'Avenir Next';
            app.MUdisplayedDropDownLabel.FontSize = 14;
            app.MUdisplayedDropDownLabel.FontColor = [0.9412 0.9412 0.9412];
            app.MUdisplayedDropDownLabel.Position = [6 632 118 34];
            app.MUdisplayedDropDownLabel.Text = 'MU displayed #';

            % Create RemoveoutliersButton
            app.RemoveoutliersButton = uibutton(app.ManualeditionPanel, 'push');
            app.RemoveoutliersButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveoutliersButtonPushed, true);
            app.RemoveoutliersButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveoutliersButton.FontName = 'Avenir Next';
            app.RemoveoutliersButton.FontSize = 14;
            app.RemoveoutliersButton.FontWeight = 'bold';
            app.RemoveoutliersButton.FontColor = [0.9412 0.9412 0.9412];
            app.RemoveoutliersButton.Position = [458 632 165 34];
            app.RemoveoutliersButton.Text = 'Remove outliers';

            % Create FlagMUfordeletionButton
            app.FlagMUfordeletionButton = uibutton(app.ManualeditionPanel, 'push');
            app.FlagMUfordeletionButton.ButtonPushedFcn = createCallbackFcn(app, @FlagMUfordeletionButtonPushed, true);
            app.FlagMUfordeletionButton.BackgroundColor = [0.149 0.149 0.149];
            app.FlagMUfordeletionButton.FontName = 'Avenir Next';
            app.FlagMUfordeletionButton.FontSize = 14;
            app.FlagMUfordeletionButton.FontWeight = 'bold';
            app.FlagMUfordeletionButton.FontColor = [1 0 0];
            app.FlagMUfordeletionButton.Position = [282 632 165 34];
            app.FlagMUfordeletionButton.Text = 'Flag MU for deletion';

            % Create AddspikesButton
            app.AddspikesButton = uibutton(app.ManualeditionPanel, 'push');
            app.AddspikesButton.ButtonPushedFcn = createCallbackFcn(app, @AddspikesButtonPushed, true);
            app.AddspikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.AddspikesButton.FontName = 'Avenir Next';
            app.AddspikesButton.FontSize = 14;
            app.AddspikesButton.FontWeight = 'bold';
            app.AddspikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.AddspikesButton.Position = [8 362 110 34];
            app.AddspikesButton.Text = 'Add spikes';

            % Create DeletespikesButton
            app.DeletespikesButton = uibutton(app.ManualeditionPanel, 'push');
            app.DeletespikesButton.ButtonPushedFcn = createCallbackFcn(app, @DeletespikesButtonPushed, true);
            app.DeletespikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.DeletespikesButton.FontName = 'Avenir Next';
            app.DeletespikesButton.FontSize = 14;
            app.DeletespikesButton.FontWeight = 'bold';
            app.DeletespikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.DeletespikesButton.Position = [124 362 110 34];
            app.DeletespikesButton.Text = 'Delete spikes';

            % Create DeleteDRButton
            app.DeleteDRButton = uibutton(app.ManualeditionPanel, 'push');
            app.DeleteDRButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteDRButtonPushed, true);
            app.DeleteDRButton.BackgroundColor = [0.149 0.149 0.149];
            app.DeleteDRButton.FontName = 'Avenir Next';
            app.DeleteDRButton.FontSize = 14;
            app.DeleteDRButton.FontWeight = 'bold';
            app.DeleteDRButton.FontColor = [0.9412 0.9412 0.9412];
            app.DeleteDRButton.Position = [240 362 110 34];
            app.DeleteDRButton.Text = 'Delete DR';

            % Create ScrollleftButton
            app.ScrollleftButton = uibutton(app.ManualeditionPanel, 'push');
            app.ScrollleftButton.ButtonPushedFcn = createCallbackFcn(app, @ScrollleftButtonPushed, true);
            app.ScrollleftButton.BackgroundColor = [0.149 0.149 0.149];
            app.ScrollleftButton.FontName = 'Avenir Next';
            app.ScrollleftButton.FontSize = 14;
            app.ScrollleftButton.FontWeight = 'bold';
            app.ScrollleftButton.FontColor = [0.9412 0.9412 0.9412];
            app.ScrollleftButton.Position = [6 11 215 34];
            app.ScrollleftButton.Text = '< Scroll left';

            % Create ZoominButton
            app.ZoominButton = uibutton(app.ManualeditionPanel, 'push');
            app.ZoominButton.ButtonPushedFcn = createCallbackFcn(app, @ZoominButtonPushed, true);
            app.ZoominButton.BackgroundColor = [0.149 0.149 0.149];
            app.ZoominButton.FontName = 'Avenir Next';
            app.ZoominButton.FontSize = 14;
            app.ZoominButton.FontWeight = 'bold';
            app.ZoominButton.FontColor = [0.9412 0.9412 0.9412];
            app.ZoominButton.Position = [238 11 215 34];
            app.ZoominButton.Text = 'Zoom in';

            % Create ZoomoutButton
            app.ZoomoutButton = uibutton(app.ManualeditionPanel, 'push');
            app.ZoomoutButton.ButtonPushedFcn = createCallbackFcn(app, @ZoomoutButtonPushed, true);
            app.ZoomoutButton.BackgroundColor = [0.149 0.149 0.149];
            app.ZoomoutButton.FontName = 'Avenir Next';
            app.ZoomoutButton.FontSize = 14;
            app.ZoomoutButton.FontWeight = 'bold';
            app.ZoomoutButton.FontColor = [0.9412 0.9412 0.9412];
            app.ZoomoutButton.Position = [470 11 215 34];
            app.ZoomoutButton.Text = 'Zoom out';

            % Create ScrollrightButton
            app.ScrollrightButton = uibutton(app.ManualeditionPanel, 'push');
            app.ScrollrightButton.ButtonPushedFcn = createCallbackFcn(app, @ScrollrightButtonPushed, true);
            app.ScrollrightButton.BackgroundColor = [0.149 0.149 0.149];
            app.ScrollrightButton.FontName = 'Avenir Next';
            app.ScrollrightButton.FontSize = 14;
            app.ScrollrightButton.FontWeight = 'bold';
            app.ScrollrightButton.FontColor = [0.9412 0.9412 0.9412];
            app.ScrollrightButton.Position = [702 11 215 34];
            app.ScrollrightButton.Text = 'Scroll right >';

            % Create ReevaluatewithwhiteningButton
            app.ReevaluatewithwhiteningButton = uibutton(app.ManualeditionPanel, 'push');
            app.ReevaluatewithwhiteningButton.ButtonPushedFcn = createCallbackFcn(app, @ReevaluatewithwhiteningButtonPushed, true);
            app.ReevaluatewithwhiteningButton.BackgroundColor = [0.149 0.149 0.149];
            app.ReevaluatewithwhiteningButton.FontName = 'Avenir Next';
            app.ReevaluatewithwhiteningButton.FontSize = 14;
            app.ReevaluatewithwhiteningButton.FontWeight = 'bold';
            app.ReevaluatewithwhiteningButton.FontColor = [0.9412 0.9412 0.9412];
            app.ReevaluatewithwhiteningButton.Position = [698 362 220 34];
            app.ReevaluatewithwhiteningButton.Text = 'Re-evaluate with whitening';

            % Create ReevaluatewithoutwhiteningButton
            app.ReevaluatewithoutwhiteningButton = uibutton(app.ManualeditionPanel, 'push');
            app.ReevaluatewithoutwhiteningButton.ButtonPushedFcn = createCallbackFcn(app, @ReevaluatewithoutwhiteningButtonPushed, true);
            app.ReevaluatewithoutwhiteningButton.BackgroundColor = [0.149 0.149 0.149];
            app.ReevaluatewithoutwhiteningButton.FontName = 'Avenir Next';
            app.ReevaluatewithoutwhiteningButton.FontSize = 14;
            app.ReevaluatewithoutwhiteningButton.FontWeight = 'bold';
            app.ReevaluatewithoutwhiteningButton.FontColor = [0.9412 0.9412 0.9412];
            app.ReevaluatewithoutwhiteningButton.Position = [469 362 227 34];
            app.ReevaluatewithoutwhiteningButton.Text = 'Re-evaluate without whitening';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.ManualeditionPanel, 'text');
            app.EditField_2.FontName = 'Avenir Next';
            app.EditField_2.FontSize = 14;
            app.EditField_2.FontColor = [1 1 1];
            app.EditField_2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_2.Position = [810 632 99 33];

            % Create UndoButton
            app.UndoButton = uibutton(app.ManualeditionPanel, 'push');
            app.UndoButton.ButtonPushedFcn = createCallbackFcn(app, @UndoButtonPushed, true);
            app.UndoButton.BackgroundColor = [0.149 0.149 0.149];
            app.UndoButton.FontName = 'Avenir Next';
            app.UndoButton.FontSize = 14;
            app.UndoButton.FontWeight = 'bold';
            app.UndoButton.FontColor = [0.3882 0.8314 0.0706];
            app.UndoButton.Position = [634 632 165 34];
            app.UndoButton.Text = 'Undo';

            % Create LockspikesButton
            app.LockspikesButton = uibutton(app.ManualeditionPanel, 'push');
            app.LockspikesButton.ButtonPushedFcn = createCallbackFcn(app, @LockspikesButtonPushed, true);
            app.LockspikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.LockspikesButton.FontName = 'Avenir Next';
            app.LockspikesButton.FontSize = 14;
            app.LockspikesButton.FontWeight = 'bold';
            app.LockspikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.LockspikesButton.Position = [356 362 110 34];
            app.LockspikesButton.Text = 'Lock spikes';

            % Create VisualisationPanel
            app.VisualisationPanel = uipanel(app.UIFigure);
            app.VisualisationPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.VisualisationPanel.Title = 'Visualisation';
            app.VisualisationPanel.BackgroundColor = [0.149 0.149 0.149];
            app.VisualisationPanel.FontName = 'Avenir Next';
            app.VisualisationPanel.FontWeight = 'bold';
            app.VisualisationPanel.FontSize = 14;
            app.VisualisationPanel.Position = [224 1 919 691];

            % Create UIAxes_Decomp_1
            app.UIAxes_Decomp_1 = uiaxes(app.VisualisationPanel);
            xlabel(app.UIAxes_Decomp_1, 'Time (s)')
            ylabel(app.UIAxes_Decomp_1, 'Pulse train')
            zlabel(app.UIAxes_Decomp_1, 'Z')
            app.UIAxes_Decomp_1.Toolbar.Visible = 'off';
            app.UIAxes_Decomp_1.FontName = 'Avenir Next';
            app.UIAxes_Decomp_1.Color = 'none';
            app.UIAxes_Decomp_1.FontSize = 14;
            app.UIAxes_Decomp_1.GridColor = [1 1 1];
            app.UIAxes_Decomp_1.MinorGridColor = [1 1 1];
            app.UIAxes_Decomp_1.Interruptible = 'off';
            app.UIAxes_Decomp_1.HitTest = 'off';
            app.UIAxes_Decomp_1.PickableParts = 'none';
            app.UIAxes_Decomp_1.Position = [2 2 916 342];

            % Create UIAxes_Decomp_2
            app.UIAxes_Decomp_2 = uiaxes(app.VisualisationPanel);
            xlabel(app.UIAxes_Decomp_2, 'Time (s)')
            ylabel(app.UIAxes_Decomp_2, 'Reference (Force or EMG amplitude)')
            zlabel(app.UIAxes_Decomp_2, 'Z')
            app.UIAxes_Decomp_2.Toolbar.Visible = 'off';
            app.UIAxes_Decomp_2.FontName = 'Avenir Next';
            app.UIAxes_Decomp_2.Color = 'none';
            app.UIAxes_Decomp_2.FontSize = 14;
            app.UIAxes_Decomp_2.GridColor = [0.15 0.15 0.15];
            app.UIAxes_Decomp_2.MinorGridColor = [0 0 0];
            app.UIAxes_Decomp_2.ButtonDownFcn = createCallbackFcn(app, @AddspikesButtonPushed, true);
            app.UIAxes_Decomp_2.Interruptible = 'off';
            app.UIAxes_Decomp_2.HitTest = 'off';
            app.UIAxes_Decomp_2.PickableParts = 'none';
            app.UIAxes_Decomp_2.Position = [1 350 914 285];

            % Create EditField
            app.EditField = uieditfield(app.VisualisationPanel, 'text');
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontName = 'Avenir Next';
            app.EditField.FontSize = 14;
            app.EditField.FontWeight = 'bold';
            app.EditField.FontColor = [1 1 1];
            app.EditField.BackgroundColor = [0.149 0.149 0.149];
            app.EditField.Position = [2 639 917 27];

            % Create DecompositionSettingsPanel
            app.DecompositionSettingsPanel = uipanel(app.UIFigure);
            app.DecompositionSettingsPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.DecompositionSettingsPanel.Title = 'Decomposition Settings';
            app.DecompositionSettingsPanel.BackgroundColor = [0.149 0.149 0.149];
            app.DecompositionSettingsPanel.FontName = 'Avenir Next';
            app.DecompositionSettingsPanel.FontWeight = 'bold';
            app.DecompositionSettingsPanel.FontSize = 14;
            app.DecompositionSettingsPanel.Position = [2 1 225 665];

            % Create StartButton
            app.StartButton = uibutton(app.DecompositionSettingsPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.149 0.149 0.149];
            app.StartButton.FontName = 'Avenir Next';
            app.StartButton.FontSize = 14;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.FontColor = [0.9412 0.9412 0.9412];
            app.StartButton.Position = [6 11 207 34];
            app.StartButton.Text = 'Start';

            % Create SILthresholdEditFieldLabel
            app.SILthresholdEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.SILthresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.SILthresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.SILthresholdEditFieldLabel.FontName = 'Avenir Next';
            app.SILthresholdEditFieldLabel.FontSize = 13;
            app.SILthresholdEditFieldLabel.FontWeight = 'bold';
            app.SILthresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.SILthresholdEditFieldLabel.Position = [71 92 87 22];
            app.SILthresholdEditFieldLabel.Text = 'SIL threshold';

            % Create SILthresholdEditField
            app.SILthresholdEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.SILthresholdEditField.FontName = 'Avenir Next';
            app.SILthresholdEditField.FontSize = 13;
            app.SILthresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.SILthresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.SILthresholdEditField.Position = [173 92 44 22];
            app.SILthresholdEditField.Value = 0.9;

            % Create NumberofiterationsEditField_2Label
            app.NumberofiterationsEditField_2Label = uilabel(app.DecompositionSettingsPanel);
            app.NumberofiterationsEditField_2Label.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofiterationsEditField_2Label.HorizontalAlignment = 'right';
            app.NumberofiterationsEditField_2Label.FontName = 'Avenir Next';
            app.NumberofiterationsEditField_2Label.FontSize = 13;
            app.NumberofiterationsEditField_2Label.FontWeight = 'bold';
            app.NumberofiterationsEditField_2Label.FontColor = [0.3804 0.7804 0.749];
            app.NumberofiterationsEditField_2Label.Position = [22 301 136 22];
            app.NumberofiterationsEditField_2Label.Text = 'Number of iterations';

            % Create NumberofiterationsEditField_2
            app.NumberofiterationsEditField_2 = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.NumberofiterationsEditField_2.FontName = 'Avenir Next';
            app.NumberofiterationsEditField_2.FontSize = 13;
            app.NumberofiterationsEditField_2.FontColor = [0.3804 0.7804 0.749];
            app.NumberofiterationsEditField_2.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofiterationsEditField_2.Position = [173 301 44 22];
            app.NumberofiterationsEditField_2.Value = 150;

            % Create EditField_saving_3
            app.EditField_saving_3 = uieditfield(app.DecompositionSettingsPanel, 'text');
            app.EditField_saving_3.Editable = 'off';
            app.EditField_saving_3.FontName = 'Avenir';
            app.EditField_saving_3.FontSize = 14;
            app.EditField_saving_3.FontColor = [0.8118 0.502 1];
            app.EditField_saving_3.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_saving_3.Position = [7 596 90 34];
            app.EditField_saving_3.Value = 'File name';

            % Create SelectfileButton
            app.SelectfileButton = uibutton(app.DecompositionSettingsPanel, 'push');
            app.SelectfileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectfileButtonPushed, true);
            app.SelectfileButton.BackgroundColor = [0.149 0.149 0.149];
            app.SelectfileButton.FontName = 'Avenir';
            app.SelectfileButton.FontSize = 14;
            app.SelectfileButton.FontWeight = 'bold';
            app.SelectfileButton.FontColor = [0.8118 0.502 1];
            app.SelectfileButton.Position = [103 595 116 34];
            app.SelectfileButton.Text = 'Select file';

            % Create NbofextendedchannelsLabel
            app.NbofextendedchannelsLabel = uilabel(app.DecompositionSettingsPanel);
            app.NbofextendedchannelsLabel.BackgroundColor = [0.149 0.149 0.149];
            app.NbofextendedchannelsLabel.HorizontalAlignment = 'right';
            app.NbofextendedchannelsLabel.WordWrap = 'on';
            app.NbofextendedchannelsLabel.FontName = 'Avenir Next';
            app.NbofextendedchannelsLabel.FontSize = 13;
            app.NbofextendedchannelsLabel.FontWeight = 'bold';
            app.NbofextendedchannelsLabel.FontColor = [0.3804 0.7804 0.749];
            app.NbofextendedchannelsLabel.Position = [14 159 147 32];
            app.NbofextendedchannelsLabel.Text = 'Nb of extended channels ';

            % Create NbofextendedchannelsEditField
            app.NbofextendedchannelsEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.NbofextendedchannelsEditField.FontName = 'Avenir Next';
            app.NbofextendedchannelsEditField.FontSize = 13;
            app.NbofextendedchannelsEditField.FontColor = [0.3804 0.7804 0.749];
            app.NbofextendedchannelsEditField.BackgroundColor = [0.149 0.149 0.149];
            app.NbofextendedchannelsEditField.Position = [174 164 43 22];
            app.NbofextendedchannelsEditField.Value = 1000;

            % Create ReferenceDropDownLabel
            app.ReferenceDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.ReferenceDropDownLabel.HorizontalAlignment = 'right';
            app.ReferenceDropDownLabel.FontName = 'Avenir Next';
            app.ReferenceDropDownLabel.FontSize = 13;
            app.ReferenceDropDownLabel.FontWeight = 'bold';
            app.ReferenceDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.ReferenceDropDownLabel.Position = [26 564 69 22];
            app.ReferenceDropDownLabel.Text = 'Reference';

            % Create ReferenceDropDown
            app.ReferenceDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.ReferenceDropDown.Items = {'Force', 'EMG amplitude'};
            app.ReferenceDropDown.FontName = 'Avenir Next';
            app.ReferenceDropDown.FontSize = 13;
            app.ReferenceDropDown.FontWeight = 'bold';
            app.ReferenceDropDown.FontColor = [0.5608 0.6196 0.851];
            app.ReferenceDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.ReferenceDropDown.Position = [103 562 114 26];
            app.ReferenceDropDown.Value = 'Force';

            % Create CheckEMGDropDownLabel
            app.CheckEMGDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.CheckEMGDropDownLabel.HorizontalAlignment = 'right';
            app.CheckEMGDropDownLabel.FontName = 'Avenir Next';
            app.CheckEMGDropDownLabel.FontSize = 13;
            app.CheckEMGDropDownLabel.FontWeight = 'bold';
            app.CheckEMGDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.CheckEMGDropDownLabel.Position = [17 527 78 22];
            app.CheckEMGDropDownLabel.Text = 'Check EMG';

            % Create CheckEMGDropDown
            app.CheckEMGDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.CheckEMGDropDown.Items = {'Yes', 'No'};
            app.CheckEMGDropDown.FontName = 'Avenir Next';
            app.CheckEMGDropDown.FontSize = 13;
            app.CheckEMGDropDown.FontWeight = 'bold';
            app.CheckEMGDropDown.FontColor = [0.5608 0.6196 0.851];
            app.CheckEMGDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.CheckEMGDropDown.Position = [103 525 114 26];
            app.CheckEMGDropDown.Value = 'Yes';

            % Create PeeloffDropDownLabel
            app.PeeloffDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.PeeloffDropDownLabel.HorizontalAlignment = 'right';
            app.PeeloffDropDownLabel.FontName = 'Avenir Next';
            app.PeeloffDropDownLabel.FontSize = 13;
            app.PeeloffDropDownLabel.FontWeight = 'bold';
            app.PeeloffDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.PeeloffDropDownLabel.Position = [45 375 50 22];
            app.PeeloffDropDownLabel.Text = 'Peeloff';

            % Create PeeloffDropDown
            app.PeeloffDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.PeeloffDropDown.Items = {'Yes', 'No'};
            app.PeeloffDropDown.FontName = 'Avenir Next';
            app.PeeloffDropDown.FontSize = 13;
            app.PeeloffDropDown.FontWeight = 'bold';
            app.PeeloffDropDown.FontColor = [0.5608 0.6196 0.851];
            app.PeeloffDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.PeeloffDropDown.Position = [103 373 114 26];
            app.PeeloffDropDown.Value = 'No';

            % Create NumberofwindowsEditFieldLabel
            app.NumberofwindowsEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.NumberofwindowsEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofwindowsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofwindowsEditFieldLabel.FontName = 'Avenir Next';
            app.NumberofwindowsEditFieldLabel.FontSize = 13;
            app.NumberofwindowsEditFieldLabel.FontWeight = 'bold';
            app.NumberofwindowsEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.NumberofwindowsEditFieldLabel.Position = [24 268 134 22];
            app.NumberofwindowsEditFieldLabel.Text = 'Number of windows';

            % Create NumberofwindowsEditField
            app.NumberofwindowsEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.NumberofwindowsEditField.FontName = 'Avenir Next';
            app.NumberofwindowsEditField.FontSize = 13;
            app.NumberofwindowsEditField.FontColor = [0.3804 0.7804 0.749];
            app.NumberofwindowsEditField.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofwindowsEditField.Position = [173 268 44 22];
            app.NumberofwindowsEditField.Value = 1;

            % Create CoVfilterDropDownLabel
            app.CoVfilterDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.CoVfilterDropDownLabel.HorizontalAlignment = 'right';
            app.CoVfilterDropDownLabel.FontName = 'Avenir Next';
            app.CoVfilterDropDownLabel.FontSize = 13;
            app.CoVfilterDropDownLabel.FontWeight = 'bold';
            app.CoVfilterDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.CoVfilterDropDownLabel.Position = [31 411 64 22];
            app.CoVfilterDropDownLabel.Text = 'CoV filter';

            % Create CoVfilterDropDown
            app.CoVfilterDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.CoVfilterDropDown.Items = {'Yes', 'No'};
            app.CoVfilterDropDown.FontName = 'Avenir Next';
            app.CoVfilterDropDown.FontSize = 13;
            app.CoVfilterDropDown.FontWeight = 'bold';
            app.CoVfilterDropDown.FontColor = [0.5608 0.6196 0.851];
            app.CoVfilterDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.CoVfilterDropDown.Position = [103 409 114 26];
            app.CoVfilterDropDown.Value = 'No';

            % Create InitialisationDropDownLabel
            app.InitialisationDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.InitialisationDropDownLabel.HorizontalAlignment = 'right';
            app.InitialisationDropDownLabel.FontName = 'Avenir Next';
            app.InitialisationDropDownLabel.FontSize = 13;
            app.InitialisationDropDownLabel.FontWeight = 'bold';
            app.InitialisationDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.InitialisationDropDownLabel.Position = [12 447 83 22];
            app.InitialisationDropDownLabel.Text = 'Initialisation';

            % Create InitialisationDropDown
            app.InitialisationDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.InitialisationDropDown.Items = {'EMG max', 'Random'};
            app.InitialisationDropDown.FontName = 'Avenir Next';
            app.InitialisationDropDown.FontSize = 13;
            app.InitialisationDropDown.FontWeight = 'bold';
            app.InitialisationDropDown.FontColor = [0.5608 0.6196 0.851];
            app.InitialisationDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.InitialisationDropDown.Position = [103 445 114 26];
            app.InitialisationDropDown.Value = 'EMG max';

            % Create RefineMUsDropDownLabel
            app.RefineMUsDropDownLabel = uilabel(app.DecompositionSettingsPanel);
            app.RefineMUsDropDownLabel.HorizontalAlignment = 'right';
            app.RefineMUsDropDownLabel.FontName = 'Avenir Next';
            app.RefineMUsDropDownLabel.FontSize = 13;
            app.RefineMUsDropDownLabel.FontWeight = 'bold';
            app.RefineMUsDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.RefineMUsDropDownLabel.Position = [18 339 77 22];
            app.RefineMUsDropDownLabel.Text = 'Refine MUs';

            % Create RefineMUsDropDown
            app.RefineMUsDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.RefineMUsDropDown.Items = {'Yes', 'No'};
            app.RefineMUsDropDown.FontName = 'Avenir Next';
            app.RefineMUsDropDown.FontSize = 13;
            app.RefineMUsDropDown.FontWeight = 'bold';
            app.RefineMUsDropDown.FontColor = [0.5608 0.6196 0.851];
            app.RefineMUsDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.RefineMUsDropDown.Position = [103 337 114 26];
            app.RefineMUsDropDown.Value = 'No';

            % Create ThresholdtargetEditFieldLabel
            app.ThresholdtargetEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.ThresholdtargetEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdtargetEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdtargetEditFieldLabel.FontName = 'Avenir Next';
            app.ThresholdtargetEditFieldLabel.FontSize = 13;
            app.ThresholdtargetEditFieldLabel.FontWeight = 'bold';
            app.ThresholdtargetEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.ThresholdtargetEditFieldLabel.Position = [48 202 110 22];
            app.ThresholdtargetEditFieldLabel.Text = 'Threshold target';

            % Create ThresholdtargetEditField
            app.ThresholdtargetEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.ThresholdtargetEditField.FontName = 'Avenir Next';
            app.ThresholdtargetEditField.FontSize = 13;
            app.ThresholdtargetEditField.FontColor = [0.3804 0.7804 0.749];
            app.ThresholdtargetEditField.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdtargetEditField.Position = [173 202 44 22];
            app.ThresholdtargetEditField.Value = 0.9;

            % Create NumberofelectrodesEditFieldLabel
            app.NumberofelectrodesEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.NumberofelectrodesEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofelectrodesEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofelectrodesEditFieldLabel.FontName = 'Avenir Next';
            app.NumberofelectrodesEditFieldLabel.FontSize = 13;
            app.NumberofelectrodesEditFieldLabel.FontWeight = 'bold';
            app.NumberofelectrodesEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.NumberofelectrodesEditFieldLabel.Position = [15 235 143 22];
            app.NumberofelectrodesEditFieldLabel.Text = 'Number of electrodes';

            % Create NumberofelectrodesEditField
            app.NumberofelectrodesEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.NumberofelectrodesEditField.FontName = 'Avenir Next';
            app.NumberofelectrodesEditField.FontSize = 13;
            app.NumberofelectrodesEditField.FontColor = [0.3804 0.7804 0.749];
            app.NumberofelectrodesEditField.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofelectrodesEditField.Position = [173 235 44 22];
            app.NumberofelectrodesEditField.Value = 64;

            % Create COVthresholdEditFieldLabel
            app.COVthresholdEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.COVthresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.COVthresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.COVthresholdEditFieldLabel.FontName = 'Avenir Next';
            app.COVthresholdEditFieldLabel.FontSize = 13;
            app.COVthresholdEditFieldLabel.FontWeight = 'bold';
            app.COVthresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.COVthresholdEditFieldLabel.Position = [61 59 97 22];
            app.COVthresholdEditFieldLabel.Text = 'COV threshold';

            % Create COVthresholdEditField
            app.COVthresholdEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.COVthresholdEditField.FontName = 'Avenir Next';
            app.COVthresholdEditField.FontSize = 13;
            app.COVthresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.COVthresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.COVthresholdEditField.Position = [173 59 44 22];
            app.COVthresholdEditField.Value = 0.5;

            % Create DuplicatethresholdEditFieldLabel
            app.DuplicatethresholdEditFieldLabel = uilabel(app.DecompositionSettingsPanel);
            app.DuplicatethresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.DuplicatethresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.DuplicatethresholdEditFieldLabel.FontName = 'Avenir Next';
            app.DuplicatethresholdEditFieldLabel.FontSize = 13;
            app.DuplicatethresholdEditFieldLabel.FontWeight = 'bold';
            app.DuplicatethresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.DuplicatethresholdEditFieldLabel.Position = [29 125 129 22];
            app.DuplicatethresholdEditFieldLabel.Text = 'Duplicate threshold';

            % Create DuplicatethresholdEditField
            app.DuplicatethresholdEditField = uieditfield(app.DecompositionSettingsPanel, 'numeric');
            app.DuplicatethresholdEditField.FontName = 'Avenir Next';
            app.DuplicatethresholdEditField.FontSize = 13;
            app.DuplicatethresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.DuplicatethresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.DuplicatethresholdEditField.Position = [173 125 44 22];
            app.DuplicatethresholdEditField.Value = 0.3;

            % Create ContrastfunctionLabel
            app.ContrastfunctionLabel = uilabel(app.DecompositionSettingsPanel);
            app.ContrastfunctionLabel.HorizontalAlignment = 'center';
            app.ContrastfunctionLabel.WordWrap = 'on';
            app.ContrastfunctionLabel.FontName = 'Avenir Next';
            app.ContrastfunctionLabel.FontSize = 13;
            app.ContrastfunctionLabel.FontWeight = 'bold';
            app.ContrastfunctionLabel.FontColor = [0.5608 0.6196 0.851];
            app.ContrastfunctionLabel.Position = [6 482 89 32];
            app.ContrastfunctionLabel.Text = 'Contrast function';

            % Create ContrastfunctionDropDown
            app.ContrastfunctionDropDown = uidropdown(app.DecompositionSettingsPanel);
            app.ContrastfunctionDropDown.Items = {'logcosh', 'skew', 'kurtosis'};
            app.ContrastfunctionDropDown.FontName = 'Avenir Next';
            app.ContrastfunctionDropDown.FontSize = 13;
            app.ContrastfunctionDropDown.FontWeight = 'bold';
            app.ContrastfunctionDropDown.FontColor = [0.5608 0.6196 0.851];
            app.ContrastfunctionDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.ContrastfunctionDropDown.Position = [103 485 114 26];
            app.ContrastfunctionDropDown.Value = 'logcosh';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MUedit_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end