classdef MUedit_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        tabs                           matlab.ui.control.DropDown
        Panel                          matlab.ui.container.Panel
        SegmentsessionButton           matlab.ui.control.Button
        SetconfigurationButton         matlab.ui.control.Button
        ContrastfunctionDropDown       matlab.ui.control.DropDown
        ContrastfunctionLabel          matlab.ui.control.Label
        DuplicatethresholdEditField    matlab.ui.control.NumericEditField
        DuplicatethresholdEditFieldLabel  matlab.ui.control.Label
        COVthresholdEditField          matlab.ui.control.NumericEditField
        COVthresholdEditFieldLabel     matlab.ui.control.Label
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
        Panel_2                        matlab.ui.container.Panel
        EditField                      matlab.ui.control.EditField
        UIAxes_Decomp_2                matlab.ui.control.UIAxes
        UIAxes_Decomp_1                matlab.ui.control.UIAxes
        Panel_4                        matlab.ui.container.Panel
        SILCheckBox                    matlab.ui.control.CheckBox
        CheckBox                       matlab.ui.control.CheckBox
        ReferenceDropDown_2            matlab.ui.control.DropDown
        ReferenceDropDown_2Label       matlab.ui.control.Label
        RemoveduplicatesbetweengridsButton  matlab.ui.control.Button
        RemoveduplicateswithingridsButton  matlab.ui.control.Button
        PlotMUfiringratesButton        matlab.ui.control.Button
        SavetheeditionLabel            matlab.ui.control.Label
        VisualisationLabel             matlab.ui.control.Label
        BatchprocessingLabel           matlab.ui.control.Label
        SaveButton                     matlab.ui.control.Button
        PlotMUspiketrainsButton        matlab.ui.control.Button
        RemoveflaggedMUButton          matlab.ui.control.Button
        UpdateallMUfiltersButton       matlab.ui.control.Button
        RemovealltheoutliersButton     matlab.ui.control.Button
        ImportdataButton               matlab.ui.control.Button
        SelectfileButton_2             matlab.ui.control.Button
        EditField_saving_2             matlab.ui.control.EditField
        Panel_3                        matlab.ui.container.Panel
        LockspikesButton               matlab.ui.control.Button
        UndoButton                     matlab.ui.control.Button
        EditField_2                    matlab.ui.control.EditField
        ExtendMUfilter                 matlab.ui.control.Button
        UpdateMUfilterButton           matlab.ui.control.Button
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
        UIAxesSIL                      matlab.ui.control.UIAxes
        UIAxesDR                       matlab.ui.control.UIAxes
        UIAxesSpiketrain               matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        
        filename            % File to decompose
        pathname            % Folder where decomposed data will be saved

        filename2           % File to edit
        pathname2            % Folder where edited data will be saved

        MUdecomp            % Data for MU decomposition
        Configuration       % Object for recording configuration

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

        % Value changed function: tabs
        function tabsValueChanged(app, event)
            if isequal(app.tabs.Value, 'DECOMPOSITION')
                app.Panel.Visible = 'on';
                app.Panel_4.Visible = 'off';
                app.Panel_3.Visible = 'off';
                app.Panel_2.Visible = 'on';
            else
                app.Panel.Visible = 'off';
                app.Panel_4.Visible = 'on';
                app.Panel_3.Visible = 'on';
                app.Panel_2.Visible = 'off';
            end
        end

        % Button pushed function: SelectfileButton
        function SelectfileButtonPushed(app, event)
            app.UIFigure.Visible = 'off'; 
            [app.filename,app.pathname] = uigetfile('*.*');
            app.UIFigure.Visible = 'on'; 
            app.EditField_saving_3.Value = app.filename;

            app.SelectfileButton.BackgroundColor = [0.15 0.15 0.15];
            app.SetconfigurationButton.BackgroundColor = [0.15 0.15 0.15];
            app.SegmentsessionButton.BackgroundColor = [0.15 0.15 0.15];
            app.StartButton.BackgroundColor = [0.15 0.15 0.15];
            app.EditField.Value = ' ';

            % Load files
            C = strsplit(app.filename,'.');
            if isequal(C{end}, 'mat')
                file = load([app.pathname, app.filename]);
                signal = file.signal;
                app.SetconfigurationButton.Enable = 'off';
            elseif isequal(C{end}, 'otb+') % OT Biolab+
                [app.MUdecomp.config, signal] = openOTBplus(app.pathname, app.filename, 1);
                if ~isempty(app.MUdecomp.config)
                    app.MUdecomp.config.UIFigure.Visible = 'off';
                    movegui(app.MUdecomp.config.UIFigure, 'center')
                    app.SetconfigurationButton.Enable = 'on';
                end
            elseif isequal(C{end}, 'otb4') % OT Biolab24
                [app.MUdecomp.config, signal] = OpenOTB4(app.pathname, app.filename, 0);
                if ~isempty(app.MUdecomp.config)
                    app.MUdecomp.config.UIFigure.Visible = 'off';
                    movegui(app.MUdecomp.config.UIFigure, 'center')
                    app.SetconfigurationButton.Enable = 'on';
                end
            elseif isequal(C{end}, 'rhd') % RHD Intan Tech
                [app.MUdecomp.config, signal] = openIntan(app.pathname, app.filename, 1);
                if ~isempty(app.MUdecomp.config)
                    app.MUdecomp.config.UIFigure.Visible = 'off';
                    movegui(app.MUdecomp.config.UIFigure, 'center')
                    app.SetconfigurationButton.Enable = 'on';
                end
            elseif isequal(C{end}, 'oebin') % Open Ephys GUI
                [app.MUdecomp.config, signal] = openOEphys(app.pathname, app.filename, 1);
                if ~isempty(app.MUdecomp.config)
                    app.MUdecomp.config.UIFigure.Visible = 'off';
                    movegui(app.MUdecomp.config.UIFigure, 'center')
                    app.SetconfigurationButton.Enable = 'on';
                end
            end
            app.ReferenceDropDown.Items = {};
            
            % Update the list of signals for reference
            if isfield(signal,'auxiliaryname')
                app.ReferenceDropDown.Items = cat(2, {'EMG amplitude'}, signal.auxiliaryname);
            elseif isfield(signal,'target')
                signal.auxiliary = [signal.path; signal.target];
                signal.auxiliaryname = cat(2, {'Path'}, {'Target'});
                app.ReferenceDropDown.Items = cat(2, {'EMG amplitude'}, signal.auxiliaryname);
            else
                app.ReferenceDropDown.Items = {'EMG amplitude'};
            end
            
            savename = [app.pathname app.filename '_decomp.mat'];
            save(savename, 'signal', '-v7.3');
            app.SelectfileButton.BackgroundColor = [0.5 0.5 0.5];
            app.EditField.Value = 'Data loaded';
        end

        % Button pushed function: SetconfigurationButton
        function SetconfigurationButtonPushed(app, event)
            app.MUdecomp.config.pathname.Value = [app.pathname app.filename '_decomp.mat'];
            app.MUdecomp.config.UIFigure.Visible = 'on';
            app.SetconfigurationButton.BackgroundColor = [0.5 0.5 0.5];
        end

        % Button pushed function: SegmentsessionButton
        function SegmentsessionButtonPushed(app, event)
            app.MUdecomp.config = segmentsession;
            movegui(app.MUdecomp.config.UIFigure, 'center')
            app.MUdecomp.config.pathname.Value = [app.pathname app.filename '_decomp.mat'];
            app.MUdecomp.config.ReferenceDropDown.Items = {};
            app.MUdecomp.config.ReferenceDropDown.Items = app.ReferenceDropDown.Items;
            app.MUdecomp.config.ReferenceDropDown.Value = app.ReferenceDropDown.Value;
            app.SegmentsessionButton.BackgroundColor = [0.5 0.5 0.5];
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            
            app.UIAxes_Decomp_2.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes_Decomp_2.YColor = [0.9412 0.9412 0.9412];
            
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
            file = load([app.pathname app.filename '_decomp.mat']);
            signal = file.signal;
            
            [signal.coordinates, signal.IED, signal.EMGmask, signal.emgtype] = formatsignalHDEMG(signal.data, signal.gridname, signal.fsamp, parameters.checkEMG);
            arraynb = zeros(size(signal.data,1),1);
            ch1 = 1;
            for i = 1:signal.ngrid
                arraynb(ch1:ch1+length(signal.EMGmask{i})-1) = i;
                ch1 = ch1+length(signal.EMGmask{i});
            end

            if contains(app.ReferenceDropDown.Value, 'Target')
                signalprocess.ref_signal = signal.target;
                signalprocess.coordinatesplateau = segmenttargets(signalprocess.ref_signal, parameters.nwindows, parameters.thresholdtarget);
                for nwin = 1:length(signalprocess.coordinatesplateau)/2
                    for i = 1:signal.ngrid
                        signalprocess.data{i,nwin} = signal.data(arraynb==i, signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
                        signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
                    end
                end
            elseif contains(app.ReferenceDropDown.Value, 'EMG amplitude')
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
                    app.roi = drawrectangle(app.UIAxes_Decomp_2, 'DrawingArea', 'auto');
                    x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];
                    x = sort(x,'ascend');
                    x(x<1) = 1;
                    x(x>length(signalprocess.ref_signal)) = length(signalprocess.ref_signal);
                    signalprocess.coordinatesplateau(nwin*2-1) = floor(x(1));
                    signalprocess.coordinatesplateau(nwin*2) = floor(x(2));
                    for i = 1:signal.ngrid
                        signalprocess.data{i,nwin} = signal.data(arraynb==i, signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
                        signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
                    end
                end
                clearvars x
            else
                for i = 1:length(signal.auxiliaryname)
                    if contains(app.ReferenceDropDown.Value, signal.auxiliaryname{i})
                        idx = i;
                    end
                end
                signalprocess.ref_signal = signal.auxiliary(idx,:);
                signalprocess.ref_signal = (signalprocess.ref_signal-signalprocess.ref_signal(1))/max((signalprocess.ref_signal-signalprocess.ref_signal(1)));
                signal.target = signalprocess.ref_signal;
                signal.path = signalprocess.ref_signal;
                plot(app.UIAxes_Decomp_2, signalprocess.ref_signal, 'Color', [0.5 0.5 0.5], 'LineWidth', 2)
                app.UIAxes_Decomp_2.XColor = [0.9412 0.9412 0.9412];
                app.UIAxes_Decomp_2.YColor = [0.9412 0.9412 0.9412];
                app.UIAxes_Decomp_2.YLim = [1 length(signal.target)];
                app.UIAxes_Decomp_2.YLim = [0 max(signalprocess.ref_signal)*1.2];
                hold(app.UIAxes_Decomp_2, 'off')
                for nwin = 1:parameters.nwindows
                    app.EditField.Value = [signal.auxiliaryname{idx} ' - Select the window #' num2str(nwin)];
                    app.roi = drawrectangle(app.UIAxes_Decomp_2, 'DrawingArea', 'auto');
                    x = [app.roi.Position(1) app.roi.Position(1) + app.roi.Position(3)];
                    x = sort(x,'ascend');
                    x(x<1) = 1;
                    x(x>length(signalprocess.ref_signal)) = length(signalprocess.ref_signal);
                    signalprocess.coordinatesplateau(nwin*2-1) = floor(x(1));
                    signalprocess.coordinatesplateau(nwin*2) = floor(x(2));
                    for i = 1:signal.ngrid
                        signalprocess.data{i,nwin} = signal.data(arraynb==i, signalprocess.coordinatesplateau(nwin*2-1):signalprocess.coordinatesplateau(nwin*2));
                        signalprocess.data{i,nwin}(signal.EMGmask{i} == 1,:) = [];
                    end
                end
                clearvars x idx
            end
            
            signalprocess.time = linspace(0,length(signalprocess.ref_signal)/signal.fsamp,length(signalprocess.ref_signal));

            app.UIAxes_Decomp_1.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes_Decomp_1.YColor = [0.9412 0.9412 0.9412];

            for i = 1:signal.ngrid
            for nwin = 1:length(signalprocess.coordinatesplateau)/2
            
            % Step 1: Preprocessing
            %       1a: Removing line interference (Notch filter)
                f = waitbar(0.2, ['Array #' num2str(i) ' - Preprocessing - Filtering EMG signals']);
                signalprocess.data{i,nwin} = notchsignals(signalprocess.data{i,nwin},signal.fsamp);
            %       1b: Bandpass filtering
                signalprocess.data{i,nwin} = bandpassingals(signalprocess.data{i,nwin},signal.fsamp, signal.emgtype(i));
                        
            %       1c: Signal extension (extension factor calculated to reach 1000
            %       channels)
                waitbar(0.4, f, ['Array #' num2str(i) ' - Preprocessing - Extending EMG signals'])
            
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
                waitbar(0.6, f, ['Array #' num2str(i) ' - Preprocessing - Whitening EMG signals'])
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
            
            waitbar(0.8, f, ['Array #' num2str(i) ' - Decomposition - Decomposing EMG signals'])
            
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
                signalprocess.time2 = linspace(signalprocess.time(signalprocess.coordinatesplateau(nwin*2-1)),signalprocess.time(signalprocess.coordinatesplateau(nwin*2)),size(signalprocess.X,2));
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
            
                plot(app.UIAxes_Decomp_2, signalprocess.time, signal.target, 'k--', 'LineWidth', 2, 'Color', [0.9412 0.9412 0.9412])
                line(app.UIAxes_Decomp_2,[signalprocess.time(signalprocess.coordinatesplateau(nwin*2-1)) signalprocess.time(signalprocess.coordinatesplateau(nwin*2-1))],[0 max(signal.target)], 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                line(app.UIAxes_Decomp_2,[signalprocess.time(signalprocess.coordinatesplateau(nwin*2)) signalprocess.time(signalprocess.coordinatesplateau(nwin*2))],[0 max(signal.target)], 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                app.EditField.Value = ['Array #' num2str(i) ' - Iteration #' num2str(j) ' - Sil = ' num2str(signalprocess.SIL{nwin}(j)) ' CoV = ' num2str(signalprocess.CoV{nwin}(j))];
                plot(app.UIAxes_Decomp_1,signalprocess.time2,signalprocess.icasig,signalprocess.time2(signalprocess.spikes),signalprocess.icasig(signalprocess.spikes),'o', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412], 'MarkerSize', 10, 'MarkerEdgeColor', [0.85 0.33 0.10]);
                app.UIAxes_Decomp_1.YLim = [-0.2 1.5];
                drawnow;
            else
                signalprocess.B(:,j) = signalprocess.w;
                app.EditField.Value = ['Array #' num2str(i) ' - Iteration #' num2str(j)];
                plot(app.UIAxes_Decomp_1,signalprocess.time2,signalprocess.icasig,signalprocess.time2(signalprocess.spikes),signalprocess.icasig(signalprocess.spikes),'o', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412], 'MarkerSize', 10, 'MarkerEdgeColor', [0.85 0.33 0.10]);
                drawnow;
            end
            end
                        
            % Filter out MUfilters below the SIL threshold
            signalprocess.MUFilters{nwin}(:,signalprocess.SIL{nwin} < parameters.silthr) = [];
            if parameters.covfilter == 1
                signalprocess.CoV{nwin}(signalprocess.SIL{nwin} < parameters.silthr) = [];
                signalprocess.MUFilters{nwin}(:,signalprocess.CoV{nwin} > parameters.covthr) = [];
            end
            
            end
            
            f = waitbar(0.8,['Array #' num2str(i) ' - Postprocessing']);
            
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
            
            close(f);
            end

            app.EditField.Value = 'Saving data';
            % Save file
            clearvars signalprocess i j PulseT distime distimenew actind idx1 time ISI CoV maxiter nwin Wini temp
            savename = [app.pathname app.filename '_decomp.mat'];
            save(savename, 'signal', 'parameters', '-v7.3');
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
                        app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Array_', num2str(i), '_MU_' , num2str(j)]});
                        if length(files.edition.Dischargetimes{i,j}) > 2
                            files.edition.silval{i,j} = getsil(files.edition.Pulsetrain{i}(j,:), files.signal.fsamp);
                            files.edition.silvalcon{i,j} = refinesil(files.edition.Pulsetrain{i}(j,:), files.edition.Dischargetimes{i,j}, files.signal.fsamp);
                        else
                            files.edition.silval{i,j} = 0;
                        end

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
                        app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Array_', num2str(i), '_MU_' , num2str(j)]});

                        if length(files.edition.Dischargetimes{i,j}) > 2
                            files.edition.silval{i,j} = getsil(files.signal.Pulsetrain{i}(j,:), files.signal.fsamp);
                            files.edition.silvalcon{i,j} = refinesil(files.signal.Pulsetrain{i}(j,:), files.signal.Dischargetimes{i,j}, files.signal.fsamp);
                        else
                            files.edition.silval{i,j} = 0;
                        end
                        files.edition.time = linspace(0,size(files.signal.Pulsetrain{i},2)/files.signal.fsamp, size(files.signal.Pulsetrain{i},2));
                    end
                end
                app.MUdisplayedDropDown.Enable = 'on';
            end

            files.edition.arraynb = zeros(size(files.signal.data,1),1);
            ch1 = 1;
            for i = 1:files.signal.ngrid
                files.edition.arraynb(ch1:ch1+length(files.signal.EMGmask{i})-1) = i;
                ch1 = ch1+length(files.signal.EMGmask{i});
            end

            % Update the list of references with Auxiliary data
            app.ReferenceDropDown_2.Items = {};
            if isfield(files.signal, 'auxiliary')
                app.ReferenceDropDown_2.Items = files.signal.auxiliaryname;
                app.ReferenceDropDown_2.Value = files.signal.auxiliaryname{1};
                files.signal.target = files.signal.auxiliary(1,:);
            end
            
            % Display the first MU
            C = strsplit(app.MUdisplayedDropDown.Value,'_');

            plot(app.UIAxesSpiketrain, files.edition.time, files.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, files.edition.time(files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), files.edition.Pulsetrain{str2double(C{2})}(1,files.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
            plot(app.UIAxesSpiketrain, files.edition.time, files.signal.target/max(files.signal.target), '--', 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);

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

            if app.SILCheckBox.Value == 1
                bar(app.UIAxesSIL, files.edition.time(files.edition.silvalcon{1,1}(:,1)), files.edition.silvalcon{1,1}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XLim = [files.edition.time(1) files.edition.time(end)];
                app.UIAxesSIL.YLim = [0.5 1];
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
            end

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

            if app.SILCheckBox.Value == 1
                bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
            end

        end

        % Value changed function: ReferenceDropDown_2
        function ReferenceDropDown_2ValueChanged(app, event)
            if contains(app.ReferenceDropDown_2.Value, 'EMG amplitude')
                tmp = zeros(floor(size(app.MUedition.signal.data,1)/2), size(app.MUedition.signal.data,2));
                for i = 1:floor(size(app.MUedition.signal.data,1)/2)
                    tmp(i,:) = movmean(abs(app.MUedition.signal.data(i,:)), app.MUedition.signal.fsamp);
                end
                app.MUedition.signal.target = mean(tmp,1);
                app.MUedition.signal.path = mean(tmp,1);
                % Update the graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{1}(1,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{1,1}), app.MUedition.edition.Pulsetrain{1}(1,app.MUedition.edition.Dischargetimes{1,1}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];

            else
                for i = 1:length(app.MUedition.signal.auxiliaryname)
                    if contains(app.ReferenceDropDown_2.Value, app.MUedition.signal.auxiliaryname{i})
                        idx = i;
                    end
                end
                app.MUedition.signal.target = (app.MUedition.signal.auxiliary(idx,:)-app.MUedition.signal.auxiliary(idx,1))/max(app.MUedition.signal.auxiliary(idx,:)-app.MUedition.signal.auxiliary(idx,1));
                app.MUedition.signal.path = (app.MUedition.signal.auxiliary(idx,:)-app.MUedition.signal.auxiliary(idx,1))/max(app.MUedition.signal.auxiliary(idx,:)-app.MUedition.signal.auxiliary(idx,1));
                % Update the graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{1}(1,:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{1,1}), app.MUedition.edition.Pulsetrain{1}(1,app.MUedition.edition.Dischargetimes{1,1}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            end
            
        end

        % Value changed function: SILCheckBox
        function SILCheckBoxValueChanged(app, event)
            if app.SILCheckBox.Value == 1
                app.UIAxesDR.Position = [5,492,1089,212];
                app.UIAxesSIL.Visible = 'on';
                C = strsplit(app.MUdisplayedDropDown.Value,'_');
                % Update the graph
                app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

                bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412]; 
            else
                app.UIAxesDR.Position = [5,492,1089,290];
                cla(app.UIAxesSIL)
                app.UIAxesSIL.Visible = 'off';
            end
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
            app.UIAxesSIL.XLim = [app.graphstart app.graphend];
            app.UIAxesSIL.YLim = [0.5 1];
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
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
            else
                app.graphstart = center - duration/2;
                app.graphend = center + duration/2;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
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
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
            else
                app.graphstart = app.graphstart - step;
                app.graphend = app.graphstart + duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
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
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
            else
                app.graphend = app.graphend + step;
                app.graphstart = app.graphend - duration;
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesDR.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                app.UIAxesSIL.XLim = [app.graphstart app.graphend];
                app.UIAxesSIL.YLim = [0.5 1];
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

        % Button pushed function: UpdateMUfilterButton
        function UpdateMUfilterButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            % Update MU filter
            nbextchan = 1000;
            idx = find(app.MUedition.edition.time > app.graphstart & app.MUedition.edition.time < app.graphend);
            EMG = app.MUedition.signal.data(app.MUedition.edition.arraynb==str2double(C{2}),:);
            EMG = EMG(app.MUedition.signal.EMGmask{str2double(C{2})}==0,idx);
            EMG = bandpassingals(EMG, app.MUedition.signal.fsamp, app.MUedition.signal.emgtype(str2double(C{2})));
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
            app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})} = refinesil(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, app.MUedition.signal.fsamp);

            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

            if app.SILCheckBox.Value == 1
                bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
            end

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);

            % Color code based one the change in SIL value
            if (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0.04
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.6350 0.0780 0.1840]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0.02 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 0.04
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.8500 0.3250 0.0980]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 0.02
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
            app.UIAxesSIL.XLim = [app.graphstart app.graphend];
            app.UIAxesSIL.YLim = [0.5 1];

        end

        % Button pushed function: ExtendMUfilter
        function ExtendMUfilterPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            app.Backup.Pulsetrain = app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}), :);
            app.Backup.Dischargetimes = app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})};

            % Get the indexes of the current window
            idx = find(app.MUedition.edition.time > app.graphstart & app.MUedition.edition.time < app.graphend);
            step = floor(length(idx)/2);

            % Zoom out on both plots
            app.graphstart = app.MUedition.edition.time(1);
            app.graphend = app.MUedition.edition.time(end);
            app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
            app.UIAxesDR.XLim = [app.graphstart app.graphend];
            app.UIAxesSpiketrain.YLim = [-0.05 1.5];
            app.UIAxesSIL.XLim = [app.graphstart app.graphend];
            app.UIAxesSIL.YLim = [0.5 1];

            % Extend MU filters
            % Move forward
            idx1 = idx;
            for j = 1:ceil((length(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:))-idx(end))/step)
                idx1 = idx1+step;
                idx1(idx1>length(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:))) = [];
                [app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}] = extendfilter(app.MUedition.signal.data(app.MUedition.edition.arraynb==str2double(C{2}),:), app.MUedition.signal.EMGmask{str2double(C{2})}, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, idx1, app.MUedition.signal.fsamp, app.MUedition.signal.emgtype(str2double(C{2})));
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                drawnow
            end
            
            % Move backward
            idx1 = idx;
            for j = 1:ceil(idx(1)/step)
                idx1 = idx1-step;
                idx1(idx1<1) = [];
                [app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}] = extendfilter(app.MUedition.signal.data(app.MUedition.edition.arraynb==str2double(C{2}),:), app.MUedition.signal.EMGmask{str2double(C{2})}, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, idx1, app.MUedition.signal.fsamp, app.MUedition.signal.emgtype(str2double(C{2})));
                % Update graph
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                hold(app.UIAxesSpiketrain, 'on')
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.85 0.33 0.10]);
                hold(app.UIAxesSpiketrain, 'off')
                app.UIAxesSpiketrain.XLim = [app.graphstart app.graphend];
                app.UIAxesSpiketrain.YLim = [-0.05 1.5];
                drawnow
            end

            oldsil = app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})};
            app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})} = getsil(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.signal.fsamp);
            app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})} = refinesil(app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}, app.MUedition.signal.fsamp);

            app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];
            
            if app.SILCheckBox.Value == 1
                bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
            end

            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),:), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
            hold(app.UIAxesSpiketrain, 'on')
            plot(app.UIAxesSpiketrain, app.MUedition.edition.time, app.MUedition.signal.target/max(app.MUedition.signal.target), '--', 'LineWidth', 1, 'Color', [0.9412 0.9412 0.9412]);
            
            % Color code based one the change in SIL value
            if (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0.04
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.6350 0.0780 0.1840]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0.02 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 0.04
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time(app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), app.MUedition.edition.Pulsetrain{str2double(C{2})}(str2double(C{4}),app.MUedition.edition.Dischargetimes{str2double(C{2}),str2double(C{4})}), 'o', 'LineWidth', 1, 'MarkerSize', 10, 'Color', [0.8500 0.3250 0.0980]);
            elseif (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) > 0 && (oldsil - app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})}) < 0.02
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
            app.UIAxesSIL.XLim = [app.graphstart app.graphend];
            app.UIAxesSIL.YLim = [0.5 1];

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
                    waitbar(ite/itetot, fwb,['Removing outliers for Array#' num2str(f) ' _MU#' num2str(mu)])
                    
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

        % Button pushed function: UpdateallMUfiltersButton
        function UpdateallMUfiltersButtonPushed(app, event)
            C = strsplit(app.MUdisplayedDropDown.Value,'_');
            
            % Update MU filter
            nbextchan = 1000;
            fwb = waitbar(0, 'Starting batch processing');
            ite = 0;
            itetot = 0;
            for f = 1:app.MUedition.signal.ngrid
                itetot = itetot + size(app.MUedition.edition.Pulsetrain{f},1);
            end
            for f = 1:app.MUedition.signal.ngrid
                EMG = app.MUedition.signal.data(app.MUedition.edition.arraynb==f,:);
                EMG = EMG(app.MUedition.signal.EMGmask{f}==0,:);
                exFactor1 = round(nbextchan/size(EMG,1));
                eSIG = extend(EMG,exFactor1);
                ReSIG = eSIG*eSIG'/length(eSIG);
                iReSIGt = pinv(ReSIG);

                for mu = 1:size(app.MUedition.edition.Pulsetrain{f},1)
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Recalculating filter for Array#' num2str(f) ' MU#' num2str(mu)])

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
            
                        app.MUedition.edition.Pulsetrain{f}(mu,:) = Pt;
                        app.MUedition.edition.Dischargetimes{f,mu} = [];
                        app.MUedition.edition.Dischargetimes{f,mu} = spikes2;
                        app.MUedition.edition.silval{f,mu} = getsil(app.MUedition.edition.Pulsetrain{f}(mu,:), app.MUedition.signal.fsamp);
                        app.MUedition.edition.silvalcon{f,mu} = refinesil(app.MUedition.edition.Pulsetrain{f}(mu,:), app.MUedition.edition.Dischargetimes{f,mu}, app.MUedition.signal.fsamp);

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

            if app.SILCheckBox.Value == 1
                bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                app.UIAxesSIL.XAxis.Visible = 'Off';
                app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
            end

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
            app.UIAxesSIL.XLim = [app.graphstart app.graphend];
            app.UIAxesSIL.YLim = [0.5 1];

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
                    app.MUedition.edition.silvalclean{i}{j} = app.MUedition.edition.silval{i,j};
                    app.MUedition.edition.silvalconclean{i}{j} = app.MUedition.edition.silvalcon{i,j};
                end
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    idx = size(app.MUedition.edition.Pulsetrain{i},1)+1-j;
                    if length(app.MUedition.edition.Dischargetimes{i,idx}) == 2 && mean(app.MUedition.edition.Pulsetrain{i}(idx,:)) == 0
                        app.MUedition.edition.Distimeclean{i}{idx} = [];
                        app.MUedition.edition.silvalclean{i}{idx} = [];
                        app.MUedition.edition.silvalconclean{i}{idx} = [];
                        app.MUedition.edition.Pulsetrainclean{i}(idx,:) = [];
                    end
                    ite = ite + 1;
                    waitbar(ite/itetot, fwb,['Checking flagged units for Array#' num2str(i) ' _MU#' num2str(j)])
                end
                app.MUedition.edition.Distimeclean{i} = app.MUedition.edition.Distimeclean{i}(~cellfun('isempty',app.MUedition.edition.Distimeclean{i}));
                app.MUedition.edition.silvalclean{i} = app.MUedition.edition.silvalclean{i}(~cellfun('isempty',app.MUedition.edition.silvalclean{i}));
                app.MUedition.edition.silvalconclean{i} = app.MUedition.edition.silvalconclean{i}(~cellfun('isempty',app.MUedition.edition.silvalconclean{i}));
            end

            app.MUedition.edition.Dischargetimes = {};
            app.MUedition.edition.silval = {};
            app.MUedition.edition.silvalcon = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrain{i} = app.MUedition.edition.Pulsetrainclean{i};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = app.MUedition.edition.Distimeclean{i}{j};
                    app.MUedition.edition.silval{i,j} = app.MUedition.edition.silvalclean{i}{j};
                    app.MUedition.edition.silvalcon{i,j} = app.MUedition.edition.silvalconclean{i}{j};
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Array_', num2str(i), '_MU_' , num2str(j)]});
                end
                app.MUdisplayedDropDown.Value = app.MUdisplayedDropDown.Items{1};
            end


            if ~isempty(app.MUdisplayedDropDown.Items)
                C = strsplit(app.MUdisplayedDropDown.Value,'_');
                % Update the graph
                app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

                if app.SILCheckBox.Value == 1
                    bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                    yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                    app.UIAxesSIL.XAxis.Visible = 'Off';
                    app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
                end

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
            else
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                plot(app.UIAxesDR, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                app.MUdisplayedDropDown.Items = {'No MUs'};
                app.MUdisplayedDropDown.Value = 'No MUs';
                app.EditField_2.Value = 'no SIL ';
            end

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
            app.MUedition.edition.silval = {};
            app.MUedition.edition.silvalcon = {};

            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                app.MUedition.edition.Pulsetrain{i} = app.MUedition.edition.Pulsetrainclean{i};
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = app.MUedition.edition.Distimeclean{i}{j};
                    app.MUedition.edition.silval{i,j} = getsil(app.MUedition.edition.Pulsetrain{i}(j,:), app.MUedition.signal.fsamp);
                    app.MUedition.edition.silvalcon{i,j} = refinesil(app.MUedition.edition.Pulsetrain{i}(j,:), app.MUedition.edition.Dischargetimes{i,j}, app.MUedition.signal.fsamp);
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Array_', num2str(i), '_MU_' , num2str(j)]});
                end
                app.MUdisplayedDropDown.Value = app.MUdisplayedDropDown.Items{1};
            end


            if ~isempty(app.MUdisplayedDropDown.Items)
                C = strsplit(app.MUdisplayedDropDown.Value,'_');
                % Update the graph
                app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

                if app.SILCheckBox.Value == 1
                    bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                    yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                    app.UIAxesSIL.XAxis.Visible = 'Off';
                    app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
                end

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
            else
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                plot(app.UIAxesDR, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                app.MUdisplayedDropDown.Items = {'No MUs'};
                app.MUdisplayedDropDown.Value = 'No MUs';
                app.EditField_2.Value = 'no SIL ';
            end
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
            app.MUedition.edition.silval = {};
            app.MUedition.edition.silvalcon = {};

            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                idx = find(muscle == i);
                app.MUedition.edition.Pulsetrain{i} = PulseT(idx,:);
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUedition.edition.Dischargetimes{i,j} = Distim{idx(j)};
                    app.MUedition.edition.silval{i,j} = getsil(app.MUedition.edition.Pulsetrain{i}(j,:), app.MUedition.signal.fsamp);
                    app.MUedition.edition.silvalcon{i,j} = refinesil(app.MUedition.edition.Pulsetrain{i}(j,:), app.MUedition.edition.Dischargetimes{i,j}, app.MUedition.signal.fsamp);
                end
            end

            app.MUdisplayedDropDown.Items = {};
            for i = 1:size(app.MUedition.edition.Pulsetrain,2)
                % Update the list and load the edited files
                for j = 1:size(app.MUedition.edition.Pulsetrain{i},1)
                    app.MUdisplayedDropDown.Items = horzcat(app.MUdisplayedDropDown.Items, {['Array_', num2str(i), '_MU_' , num2str(j)]});
                end
                app.MUdisplayedDropDown.Value = app.MUdisplayedDropDown.Items{1};
            end


            if ~isempty(app.MUdisplayedDropDown.Items)
                C = strsplit(app.MUdisplayedDropDown.Value,'_');
                % Update the graph
                app.EditField_2.Value = ['SIL = ' num2str(app.MUedition.edition.silval{str2double(C{2}),str2double(C{4})})];

                if app.SILCheckBox.Value == 1
                    bar(app.UIAxesSIL, app.MUedition.edition.time(app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,1)), app.MUedition.edition.silvalcon{str2double(C{2}),str2double(C{4})}(:,2), 'EdgeColor', [0.9412 0.9412 0.9412], 'FaceColor', [0.15 0.15 0.15]);
                    yline(app.UIAxesSIL, 0.9, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
                    app.UIAxesSIL.XAxis.Visible = 'Off';
                    app.UIAxesSIL.YColor = [0.9412 0.9412 0.9412];
                end

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
            else
                plot(app.UIAxesSpiketrain, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                plot(app.UIAxesDR, app.MUedition.edition.time, zeros(length(app.MUedition.edition.time),1), 'Color', [0.9412 0.9412 0.9412], 'LineWidth', 1);
                app.MUdisplayedDropDown.Items = {'No MUs'};
                app.MUdisplayedDropDown.Value = 'No MUs';
                app.EditField_2.Value = 'no SIL ';
            end
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
                title(['Array#' num2str(i) ' with ' num2str(j) ' MUs'], 'Color', [0.9412 0.9412 0.9412], 'FontName', 'Avenir Next')
                xlabel('Time (s)', 'FontName', 'Avenir Next')
                ylabel('MU#', 'FontName', 'Avenir Next')
                ylim([0 j+1])
                set(gcf,'Color', [0.15 0.15 0.15]);
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
                set(gca,'Color', [0.15 0.15 0.15], 'XColor', [0.9412 0.9412 0.9412], 'YColor', [0.9412 0.9412 0.9412]);
            end
            sgtitle(['Raster plots for ' num2str(i) ' arrays'], 'FontName', 'Avenir Next', 'FontSize', 25, 'Color', [0.9412 0.9412 0.9412])
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

                title(['Array#' num2str(i) ' with ' num2str(j) ' MUs'], 'Color', [0.9412 0.9412 0.9412], 'FontName', 'Avenir Next')
                xlabel('Time (s)', 'FontName', 'Avenir Next')
                ylabel('Smoothed discharge rates', 'FontName', 'Avenir Next')
                set(gcf,'Color', [0.15 0.15 0.15]);
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
                set(gca,'Color', [0.15 0.15 0.15], 'XColor', [0.9412 0.9412 0.9412], 'YColor', [0.9412 0.9412 0.9412]);
            end
            sgtitle(['Smoothed discharge rates for ' num2str(i) ' arrays'], 'FontName', 'Avenir Next', 'FontSize', 25, 'Color', [0.9412 0.9412 0.9412])
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
                    waitbar(ite/itetot, fwb,['Checking flagged units for Array#' num2str(i) ' _MU#' num2str(j)])
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

        % Key press function: UIFigure
        function UIFigureKeyPress(app, event)
            switch event.Key
                case 'leftarrow'
                    ScrollleftButtonPushed(app);
                    disp(event.Key)
                case 'rightarrow'
                    ScrollrightButtonPushed(app);
                    disp(event.Key)
                case 'uparrow'
                    ZoominButtonPushed(app);
                    disp(event.Key)
                case 'downarrow'
                    ZoomoutButtonPushed(app);
                case 'a'
                    AddspikesButtonPushed(app);
                case 'd'
                    DeletespikesButtonPushed(app);
                case 'r'
                    RemoveoutliersButtonPushed(app);
                case 'space'
                    UpdateMUfilterButtonPushed(app);
                case 's'
                    LockspikesButtonPushed(app);
                case 'e'
                    ExtendMUfilterPushed(app);
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [1 100 1500 850];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @UIFigureKeyPress, true);

            % Create Panel_3
            app.Panel_3 = uipanel(app.UIFigure);
            app.Panel_3.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Panel_3.BackgroundColor = [0.149 0.149 0.149];
            app.Panel_3.FontName = 'Poppins';
            app.Panel_3.FontWeight = 'bold';
            app.Panel_3.FontSize = 24;
            app.Panel_3.Position = [400 0 1100 850];

            % Create UIAxesSpiketrain
            app.UIAxesSpiketrain = uiaxes(app.Panel_3);
            xlabel(app.UIAxesSpiketrain, 'Time (s)')
            ylabel(app.UIAxesSpiketrain, 'Pulse train (au)')
            zlabel(app.UIAxesSpiketrain, 'Z')
            app.UIAxesSpiketrain.Toolbar.Visible = 'off';
            app.UIAxesSpiketrain.FontName = 'Poppins';
            app.UIAxesSpiketrain.Color = 'none';
            app.UIAxesSpiketrain.Interruptible = 'off';
            app.UIAxesSpiketrain.HitTest = 'off';
            app.UIAxesSpiketrain.PickableParts = 'none';
            app.UIAxesSpiketrain.Position = [5 105 1089 320];

            % Create UIAxesDR
            app.UIAxesDR = uiaxes(app.Panel_3);
            xlabel(app.UIAxesDR, 'Time (s)')
            ylabel(app.UIAxesDR, 'Discharge rate (pps)')
            zlabel(app.UIAxesDR, 'Z')
            app.UIAxesDR.Toolbar.Visible = 'off';
            app.UIAxesDR.FontName = 'Poppins';
            app.UIAxesDR.Color = 'none';
            app.UIAxesDR.Interruptible = 'off';
            app.UIAxesDR.HitTest = 'off';
            app.UIAxesDR.PickableParts = 'none';
            app.UIAxesDR.Position = [5 492 1089 212];

            % Create UIAxesSIL
            app.UIAxesSIL = uiaxes(app.Panel_3);
            xlabel(app.UIAxesSIL, 'Time (s)')
            ylabel(app.UIAxesSIL, 'SIL')
            zlabel(app.UIAxesSIL, 'Z')
            app.UIAxesSIL.Toolbar.Visible = 'off';
            app.UIAxesSIL.FontName = 'Poppins';
            app.UIAxesSIL.Color = 'none';
            app.UIAxesSIL.Interruptible = 'off';
            app.UIAxesSIL.HitTest = 'off';
            app.UIAxesSIL.PickableParts = 'none';
            app.UIAxesSIL.Position = [5 706 1089 96];

            % Create MUdisplayedDropDown
            app.MUdisplayedDropDown = uidropdown(app.Panel_3);
            app.MUdisplayedDropDown.Items = {'No MUs'};
            app.MUdisplayedDropDown.ValueChangedFcn = createCallbackFcn(app, @MUdisplayedDropDownValueChanged, true);
            app.MUdisplayedDropDown.Enable = 'off';
            app.MUdisplayedDropDown.FontName = 'Poppins';
            app.MUdisplayedDropDown.FontSize = 18;
            app.MUdisplayedDropDown.FontColor = [0.9412 0.9412 0.9412];
            app.MUdisplayedDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.MUdisplayedDropDown.Position = [212 810 207 40];
            app.MUdisplayedDropDown.Value = 'No MUs';

            % Create MUdisplayedDropDownLabel
            app.MUdisplayedDropDownLabel = uilabel(app.Panel_3);
            app.MUdisplayedDropDownLabel.HorizontalAlignment = 'center';
            app.MUdisplayedDropDownLabel.FontName = 'Poppins';
            app.MUdisplayedDropDownLabel.FontSize = 24;
            app.MUdisplayedDropDownLabel.FontWeight = 'bold';
            app.MUdisplayedDropDownLabel.FontColor = [0.9412 0.9412 0.9412];
            app.MUdisplayedDropDownLabel.Position = [5 810 200 40];
            app.MUdisplayedDropDownLabel.Text = 'MU displayed #';

            % Create RemoveoutliersButton
            app.RemoveoutliersButton = uibutton(app.Panel_3, 'push');
            app.RemoveoutliersButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveoutliersButtonPushed, true);
            app.RemoveoutliersButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveoutliersButton.FontName = 'Poppins';
            app.RemoveoutliersButton.FontSize = 18;
            app.RemoveoutliersButton.FontColor = [0.9412 0.9412 0.9412];
            app.RemoveoutliersButton.Position = [648 810 173 40];
            app.RemoveoutliersButton.Text = 'Remove outliers';

            % Create FlagMUfordeletionButton
            app.FlagMUfordeletionButton = uibutton(app.Panel_3, 'push');
            app.FlagMUfordeletionButton.ButtonPushedFcn = createCallbackFcn(app, @FlagMUfordeletionButtonPushed, true);
            app.FlagMUfordeletionButton.BackgroundColor = [0.149 0.149 0.149];
            app.FlagMUfordeletionButton.FontName = 'Poppins';
            app.FlagMUfordeletionButton.FontSize = 18;
            app.FlagMUfordeletionButton.FontColor = [1 0 0];
            app.FlagMUfordeletionButton.Position = [435 810 197 40];
            app.FlagMUfordeletionButton.Text = 'Flag MU for deletion';

            % Create AddspikesButton
            app.AddspikesButton = uibutton(app.Panel_3, 'push');
            app.AddspikesButton.ButtonPushedFcn = createCallbackFcn(app, @AddspikesButtonPushed, true);
            app.AddspikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.AddspikesButton.FontName = 'Poppins';
            app.AddspikesButton.FontSize = 18;
            app.AddspikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.AddspikesButton.Position = [5 438 150 45];
            app.AddspikesButton.Text = 'Add spikes';

            % Create DeletespikesButton
            app.DeletespikesButton = uibutton(app.Panel_3, 'push');
            app.DeletespikesButton.ButtonPushedFcn = createCallbackFcn(app, @DeletespikesButtonPushed, true);
            app.DeletespikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.DeletespikesButton.FontName = 'Poppins';
            app.DeletespikesButton.FontSize = 18;
            app.DeletespikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.DeletespikesButton.Position = [167 438 150 45];
            app.DeletespikesButton.Text = 'Delete spikes';

            % Create DeleteDRButton
            app.DeleteDRButton = uibutton(app.Panel_3, 'push');
            app.DeleteDRButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteDRButtonPushed, true);
            app.DeleteDRButton.BackgroundColor = [0.149 0.149 0.149];
            app.DeleteDRButton.FontName = 'Poppins';
            app.DeleteDRButton.FontSize = 18;
            app.DeleteDRButton.FontColor = [0.9412 0.9412 0.9412];
            app.DeleteDRButton.Position = [329 438 150 45];
            app.DeleteDRButton.Text = 'Delete DR';

            % Create ScrollleftButton
            app.ScrollleftButton = uibutton(app.Panel_3, 'push');
            app.ScrollleftButton.ButtonPushedFcn = createCallbackFcn(app, @ScrollleftButtonPushed, true);
            app.ScrollleftButton.BackgroundColor = [0.149 0.149 0.149];
            app.ScrollleftButton.FontName = 'Poppins';
            app.ScrollleftButton.FontSize = 18;
            app.ScrollleftButton.FontColor = [0.9412 0.9412 0.9412];
            app.ScrollleftButton.Position = [5 49 250 45];
            app.ScrollleftButton.Text = '< Scroll left';

            % Create ZoominButton
            app.ZoominButton = uibutton(app.Panel_3, 'push');
            app.ZoominButton.ButtonPushedFcn = createCallbackFcn(app, @ZoominButtonPushed, true);
            app.ZoominButton.BackgroundColor = [0.149 0.149 0.149];
            app.ZoominButton.FontName = 'Poppins';
            app.ZoominButton.FontSize = 18;
            app.ZoominButton.FontColor = [0.9412 0.9412 0.9412];
            app.ZoominButton.Position = [285 49 250 45];
            app.ZoominButton.Text = 'Zoom in';

            % Create ZoomoutButton
            app.ZoomoutButton = uibutton(app.Panel_3, 'push');
            app.ZoomoutButton.ButtonPushedFcn = createCallbackFcn(app, @ZoomoutButtonPushed, true);
            app.ZoomoutButton.BackgroundColor = [0.149 0.149 0.149];
            app.ZoomoutButton.FontName = 'Poppins';
            app.ZoomoutButton.FontSize = 18;
            app.ZoomoutButton.FontColor = [0.9412 0.9412 0.9412];
            app.ZoomoutButton.Position = [565 49 250 45];
            app.ZoomoutButton.Text = 'Zoom out';

            % Create ScrollrightButton
            app.ScrollrightButton = uibutton(app.Panel_3, 'push');
            app.ScrollrightButton.ButtonPushedFcn = createCallbackFcn(app, @ScrollrightButtonPushed, true);
            app.ScrollrightButton.BackgroundColor = [0.149 0.149 0.149];
            app.ScrollrightButton.FontName = 'Poppins';
            app.ScrollrightButton.FontSize = 18;
            app.ScrollrightButton.FontColor = [0.9412 0.9412 0.9412];
            app.ScrollrightButton.Position = [845 49 250 45];
            app.ScrollrightButton.Text = 'Scroll right >';

            % Create UpdateMUfilterButton
            app.UpdateMUfilterButton = uibutton(app.Panel_3, 'push');
            app.UpdateMUfilterButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateMUfilterButtonPushed, true);
            app.UpdateMUfilterButton.BackgroundColor = [0.149 0.149 0.149];
            app.UpdateMUfilterButton.FontName = 'Poppins';
            app.UpdateMUfilterButton.FontSize = 18;
            app.UpdateMUfilterButton.FontColor = [0.9412 0.9412 0.9412];
            app.UpdateMUfilterButton.Position = [653 437 215 45];
            app.UpdateMUfilterButton.Text = 'Update MU filter';

            % Create ExtendMUfilter
            app.ExtendMUfilter = uibutton(app.Panel_3, 'push');
            app.ExtendMUfilter.ButtonPushedFcn = createCallbackFcn(app, @ExtendMUfilterPushed, true);
            app.ExtendMUfilter.BackgroundColor = [0.149 0.149 0.149];
            app.ExtendMUfilter.FontName = 'Poppins';
            app.ExtendMUfilter.FontSize = 18;
            app.ExtendMUfilter.FontColor = [0.9412 0.9412 0.9412];
            app.ExtendMUfilter.Position = [880 437 215 45];
            app.ExtendMUfilter.Text = 'Extend MU filter';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.Panel_3, 'text');
            app.EditField_2.FontName = 'Poppins';
            app.EditField_2.FontSize = 18;
            app.EditField_2.FontColor = [1 1 1];
            app.EditField_2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_2.Position = [985 810 110 40];

            % Create UndoButton
            app.UndoButton = uibutton(app.Panel_3, 'push');
            app.UndoButton.ButtonPushedFcn = createCallbackFcn(app, @UndoButtonPushed, true);
            app.UndoButton.BackgroundColor = [0.149 0.149 0.149];
            app.UndoButton.FontName = 'Poppins';
            app.UndoButton.FontSize = 18;
            app.UndoButton.FontColor = [0.3882 0.8314 0.0706];
            app.UndoButton.Position = [836 810 134 40];
            app.UndoButton.Text = 'Undo';

            % Create LockspikesButton
            app.LockspikesButton = uibutton(app.Panel_3, 'push');
            app.LockspikesButton.ButtonPushedFcn = createCallbackFcn(app, @LockspikesButtonPushed, true);
            app.LockspikesButton.BackgroundColor = [0.149 0.149 0.149];
            app.LockspikesButton.FontName = 'Poppins';
            app.LockspikesButton.FontSize = 18;
            app.LockspikesButton.FontColor = [0.9412 0.9412 0.9412];
            app.LockspikesButton.Position = [491 438 150 45];
            app.LockspikesButton.Text = 'Lock spikes';

            % Create Panel_4
            app.Panel_4 = uipanel(app.UIFigure);
            app.Panel_4.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Panel_4.BackgroundColor = [0.149 0.149 0.149];
            app.Panel_4.FontName = 'Poppins';
            app.Panel_4.FontWeight = 'bold';
            app.Panel_4.FontSize = 24;
            app.Panel_4.Position = [0 0 400 810];

            % Create EditField_saving_2
            app.EditField_saving_2 = uieditfield(app.Panel_4, 'text');
            app.EditField_saving_2.Editable = 'off';
            app.EditField_saving_2.FontName = 'Poppins';
            app.EditField_saving_2.FontSize = 18;
            app.EditField_saving_2.FontColor = [0.8118 0.502 1];
            app.EditField_saving_2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_saving_2.Position = [15 757 190 45];
            app.EditField_saving_2.Value = 'File name';

            % Create SelectfileButton_2
            app.SelectfileButton_2 = uibutton(app.Panel_4, 'push');
            app.SelectfileButton_2.ButtonPushedFcn = createCallbackFcn(app, @SelectfileButton_2Pushed, true);
            app.SelectfileButton_2.BackgroundColor = [0.149 0.149 0.149];
            app.SelectfileButton_2.FontName = 'Poppins';
            app.SelectfileButton_2.FontSize = 18;
            app.SelectfileButton_2.FontColor = [0.8118 0.502 1];
            app.SelectfileButton_2.Position = [213 757 172 45];
            app.SelectfileButton_2.Text = 'Select file';

            % Create ImportdataButton
            app.ImportdataButton = uibutton(app.Panel_4, 'push');
            app.ImportdataButton.ButtonPushedFcn = createCallbackFcn(app, @ImportdataButtonPushed, true);
            app.ImportdataButton.BackgroundColor = [0.149 0.149 0.149];
            app.ImportdataButton.FontName = 'Poppins';
            app.ImportdataButton.FontSize = 18;
            app.ImportdataButton.FontColor = [0.8118 0.502 1];
            app.ImportdataButton.Position = [15 707 369 45];
            app.ImportdataButton.Text = 'Import data';

            % Create RemovealltheoutliersButton
            app.RemovealltheoutliersButton = uibutton(app.Panel_4, 'push');
            app.RemovealltheoutliersButton.ButtonPushedFcn = createCallbackFcn(app, @RemovealltheoutliersButtonPushed, true);
            app.RemovealltheoutliersButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemovealltheoutliersButton.FontName = 'Poppins';
            app.RemovealltheoutliersButton.FontSize = 18;
            app.RemovealltheoutliersButton.FontColor = [0.5608 0.6196 0.851];
            app.RemovealltheoutliersButton.Position = [15 609 369 45];
            app.RemovealltheoutliersButton.Text = '1 - Remove all the outliers';

            % Create UpdateallMUfiltersButton
            app.UpdateallMUfiltersButton = uibutton(app.Panel_4, 'push');
            app.UpdateallMUfiltersButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateallMUfiltersButtonPushed, true);
            app.UpdateallMUfiltersButton.BackgroundColor = [0.149 0.149 0.149];
            app.UpdateallMUfiltersButton.FontName = 'Poppins';
            app.UpdateallMUfiltersButton.FontSize = 18;
            app.UpdateallMUfiltersButton.FontColor = [0.5608 0.6196 0.851];
            app.UpdateallMUfiltersButton.Position = [15 552 369 45];
            app.UpdateallMUfiltersButton.Text = '2 - Update all MU filters';

            % Create RemoveflaggedMUButton
            app.RemoveflaggedMUButton = uibutton(app.Panel_4, 'push');
            app.RemoveflaggedMUButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveflaggedMUButtonPushed, true);
            app.RemoveflaggedMUButton.WordWrap = 'on';
            app.RemoveflaggedMUButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveflaggedMUButton.FontName = 'Poppins';
            app.RemoveflaggedMUButton.FontSize = 18;
            app.RemoveflaggedMUButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveflaggedMUButton.Position = [15 495 369 45];
            app.RemoveflaggedMUButton.Text = '3 - Remove flagged MU';

            % Create PlotMUspiketrainsButton
            app.PlotMUspiketrainsButton = uibutton(app.Panel_4, 'push');
            app.PlotMUspiketrainsButton.ButtonPushedFcn = createCallbackFcn(app, @PlotMUspiketrainsButtonPushed, true);
            app.PlotMUspiketrainsButton.BackgroundColor = [0.149 0.149 0.149];
            app.PlotMUspiketrainsButton.FontName = 'Poppins';
            app.PlotMUspiketrainsButton.FontSize = 18;
            app.PlotMUspiketrainsButton.FontColor = [0.3804 0.7804 0.749];
            app.PlotMUspiketrainsButton.Position = [15 218 369 45];
            app.PlotMUspiketrainsButton.Text = 'Plot MU spike trains';

            % Create SaveButton
            app.SaveButton = uibutton(app.Panel_4, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.149 0.149 0.149];
            app.SaveButton.FontName = 'Poppins';
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [0.9412 0.9412 0.9412];
            app.SaveButton.Position = [15 49 369 45];
            app.SaveButton.Text = 'Save';

            % Create BatchprocessingLabel
            app.BatchprocessingLabel = uilabel(app.Panel_4);
            app.BatchprocessingLabel.HorizontalAlignment = 'center';
            app.BatchprocessingLabel.FontName = 'Poppins';
            app.BatchprocessingLabel.FontSize = 18;
            app.BatchprocessingLabel.FontWeight = 'bold';
            app.BatchprocessingLabel.FontColor = [0.9412 0.9412 0.9412];
            app.BatchprocessingLabel.Position = [117 665 166 23];
            app.BatchprocessingLabel.Text = 'Batch processing';

            % Create VisualisationLabel
            app.VisualisationLabel = uilabel(app.Panel_4);
            app.VisualisationLabel.HorizontalAlignment = 'center';
            app.VisualisationLabel.FontName = 'Poppins';
            app.VisualisationLabel.FontSize = 18;
            app.VisualisationLabel.FontWeight = 'bold';
            app.VisualisationLabel.FontColor = [0.9412 0.9412 0.9412];
            app.VisualisationLabel.Position = [137 329 127 23];
            app.VisualisationLabel.Text = 'Visualisation';

            % Create SavetheeditionLabel
            app.SavetheeditionLabel = uilabel(app.Panel_4);
            app.SavetheeditionLabel.HorizontalAlignment = 'center';
            app.SavetheeditionLabel.WordWrap = 'on';
            app.SavetheeditionLabel.FontName = 'Poppins';
            app.SavetheeditionLabel.FontSize = 18;
            app.SavetheeditionLabel.FontWeight = 'bold';
            app.SavetheeditionLabel.FontColor = [0.9412 0.9412 0.9412];
            app.SavetheeditionLabel.Position = [101 109 199 23];
            app.SavetheeditionLabel.Text = 'Save the edition';

            % Create PlotMUfiringratesButton
            app.PlotMUfiringratesButton = uibutton(app.Panel_4, 'push');
            app.PlotMUfiringratesButton.ButtonPushedFcn = createCallbackFcn(app, @PlotMUfiringratesButtonPushed, true);
            app.PlotMUfiringratesButton.BackgroundColor = [0.149 0.149 0.149];
            app.PlotMUfiringratesButton.FontName = 'Poppins';
            app.PlotMUfiringratesButton.FontSize = 18;
            app.PlotMUfiringratesButton.FontColor = [0.3804 0.7804 0.749];
            app.PlotMUfiringratesButton.Position = [15 163 369 45];
            app.PlotMUfiringratesButton.Text = 'Plot MU firing rates';

            % Create RemoveduplicateswithingridsButton
            app.RemoveduplicateswithingridsButton = uibutton(app.Panel_4, 'push');
            app.RemoveduplicateswithingridsButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveduplicateswithingridsButtonPushed, true);
            app.RemoveduplicateswithingridsButton.WordWrap = 'on';
            app.RemoveduplicateswithingridsButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveduplicateswithingridsButton.FontName = 'Poppins';
            app.RemoveduplicateswithingridsButton.FontSize = 18;
            app.RemoveduplicateswithingridsButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveduplicateswithingridsButton.Position = [15 438 369 45];
            app.RemoveduplicateswithingridsButton.Text = '4 - Remove duplicates within grids';

            % Create RemoveduplicatesbetweengridsButton
            app.RemoveduplicatesbetweengridsButton = uibutton(app.Panel_4, 'push');
            app.RemoveduplicatesbetweengridsButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveduplicatesbetweengridsButtonPushed, true);
            app.RemoveduplicatesbetweengridsButton.WordWrap = 'on';
            app.RemoveduplicatesbetweengridsButton.BackgroundColor = [0.149 0.149 0.149];
            app.RemoveduplicatesbetweengridsButton.FontName = 'Poppins';
            app.RemoveduplicatesbetweengridsButton.FontSize = 18;
            app.RemoveduplicatesbetweengridsButton.FontColor = [0.5608 0.6196 0.851];
            app.RemoveduplicatesbetweengridsButton.Position = [15 381 369 45];
            app.RemoveduplicatesbetweengridsButton.Text = '5 - Remove duplicates between grids';

            % Create ReferenceDropDown_2Label
            app.ReferenceDropDown_2Label = uilabel(app.Panel_4);
            app.ReferenceDropDown_2Label.HorizontalAlignment = 'right';
            app.ReferenceDropDown_2Label.FontName = 'Poppins';
            app.ReferenceDropDown_2Label.FontSize = 18;
            app.ReferenceDropDown_2Label.FontColor = [0.3804 0.7804 0.749];
            app.ReferenceDropDown_2Label.Position = [28 287 96 23];
            app.ReferenceDropDown_2Label.Text = 'Reference';

            % Create ReferenceDropDown_2
            app.ReferenceDropDown_2 = uidropdown(app.Panel_4);
            app.ReferenceDropDown_2.Items = {'Target', 'Force', 'EMG amplitude', 'All'};
            app.ReferenceDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ReferenceDropDown_2ValueChanged, true);
            app.ReferenceDropDown_2.FontName = 'Poppins';
            app.ReferenceDropDown_2.FontSize = 18;
            app.ReferenceDropDown_2.FontColor = [0.3804 0.7804 0.749];
            app.ReferenceDropDown_2.BackgroundColor = [0.149 0.149 0.149];
            app.ReferenceDropDown_2.Position = [136 276 162 45];
            app.ReferenceDropDown_2.Value = 'Target';

            % Create CheckBox
            app.CheckBox = uicheckbox(app.Panel_4);
            app.CheckBox.Position = [1 808 2 2];

            % Create SILCheckBox
            app.SILCheckBox = uicheckbox(app.Panel_4);
            app.SILCheckBox.ValueChangedFcn = createCallbackFcn(app, @SILCheckBoxValueChanged, true);
            app.SILCheckBox.Text = ' SIL';
            app.SILCheckBox.FontName = 'Poppins';
            app.SILCheckBox.FontSize = 18;
            app.SILCheckBox.FontColor = [0.3804 0.7804 0.749];
            app.SILCheckBox.Position = [315 276 56 45];

            % Create Panel_2
            app.Panel_2 = uipanel(app.UIFigure);
            app.Panel_2.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Panel_2.BackgroundColor = [0.149 0.149 0.149];
            app.Panel_2.FontName = 'Poppins';
            app.Panel_2.FontWeight = 'bold';
            app.Panel_2.FontSize = 24;
            app.Panel_2.Position = [400 0 1100 850];

            % Create UIAxes_Decomp_1
            app.UIAxes_Decomp_1 = uiaxes(app.Panel_2);
            xlabel(app.UIAxes_Decomp_1, 'Time (s)')
            ylabel(app.UIAxes_Decomp_1, 'Pulse train')
            zlabel(app.UIAxes_Decomp_1, 'Z')
            app.UIAxes_Decomp_1.Toolbar.Visible = 'off';
            app.UIAxes_Decomp_1.FontName = 'Poppins';
            app.UIAxes_Decomp_1.Color = 'none';
            app.UIAxes_Decomp_1.Interruptible = 'off';
            app.UIAxes_Decomp_1.HitTest = 'off';
            app.UIAxes_Decomp_1.PickableParts = 'none';
            app.UIAxes_Decomp_1.Position = [0 35 1100 400];

            % Create UIAxes_Decomp_2
            app.UIAxes_Decomp_2 = uiaxes(app.Panel_2);
            xlabel(app.UIAxes_Decomp_2, 'Time (s)')
            ylabel(app.UIAxes_Decomp_2, 'Reference')
            zlabel(app.UIAxes_Decomp_2, 'Z')
            app.UIAxes_Decomp_2.Toolbar.Visible = 'off';
            app.UIAxes_Decomp_2.FontName = 'Poppins';
            app.UIAxes_Decomp_2.Color = 'none';
            app.UIAxes_Decomp_2.ButtonDownFcn = createCallbackFcn(app, @AddspikesButtonPushed, true);
            app.UIAxes_Decomp_2.Interruptible = 'off';
            app.UIAxes_Decomp_2.HitTest = 'off';
            app.UIAxes_Decomp_2.PickableParts = 'none';
            app.UIAxes_Decomp_2.Position = [0 440 1100 370];

            % Create EditField
            app.EditField = uieditfield(app.Panel_2, 'text');
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontName = 'Poppins';
            app.EditField.FontSize = 24;
            app.EditField.FontWeight = 'bold';
            app.EditField.FontColor = [1 1 1];
            app.EditField.BackgroundColor = [0.149 0.149 0.149];
            app.EditField.Position = [1 810 1100 40];

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Panel.BackgroundColor = [0.149 0.149 0.149];
            app.Panel.FontName = 'Poppins';
            app.Panel.FontWeight = 'bold';
            app.Panel.FontSize = 24;
            app.Panel.Position = [0 0 400 810];

            % Create StartButton
            app.StartButton = uibutton(app.Panel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.149 0.149 0.149];
            app.StartButton.FontName = 'Poppins';
            app.StartButton.FontSize = 18;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.FontColor = [0.9412 0.9412 0.9412];
            app.StartButton.Position = [15 7 369 45];
            app.StartButton.Text = 'Start';

            % Create SILthresholdEditFieldLabel
            app.SILthresholdEditFieldLabel = uilabel(app.Panel);
            app.SILthresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.SILthresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.SILthresholdEditFieldLabel.FontName = 'Poppins';
            app.SILthresholdEditFieldLabel.FontSize = 18;
            app.SILthresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.SILthresholdEditFieldLabel.Position = [118 107 123 35];
            app.SILthresholdEditFieldLabel.Text = 'SIL threshold';

            % Create SILthresholdEditField
            app.SILthresholdEditField = uieditfield(app.Panel, 'numeric');
            app.SILthresholdEditField.FontName = 'Poppins';
            app.SILthresholdEditField.FontSize = 18;
            app.SILthresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.SILthresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.SILthresholdEditField.Position = [256 107 128 35];
            app.SILthresholdEditField.Value = 0.9;

            % Create NumberofiterationsEditField_2Label
            app.NumberofiterationsEditField_2Label = uilabel(app.Panel);
            app.NumberofiterationsEditField_2Label.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofiterationsEditField_2Label.HorizontalAlignment = 'right';
            app.NumberofiterationsEditField_2Label.FontName = 'Poppins';
            app.NumberofiterationsEditField_2Label.FontSize = 18;
            app.NumberofiterationsEditField_2Label.FontColor = [0.3804 0.7804 0.749];
            app.NumberofiterationsEditField_2Label.Position = [44 333 197 35];
            app.NumberofiterationsEditField_2Label.Text = 'Number of iterations';

            % Create NumberofiterationsEditField_2
            app.NumberofiterationsEditField_2 = uieditfield(app.Panel, 'numeric');
            app.NumberofiterationsEditField_2.FontName = 'Poppins';
            app.NumberofiterationsEditField_2.FontSize = 18;
            app.NumberofiterationsEditField_2.FontColor = [0.3804 0.7804 0.749];
            app.NumberofiterationsEditField_2.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofiterationsEditField_2.Position = [256 333 128 35];
            app.NumberofiterationsEditField_2.Value = 150;

            % Create EditField_saving_3
            app.EditField_saving_3 = uieditfield(app.Panel, 'text');
            app.EditField_saving_3.Editable = 'off';
            app.EditField_saving_3.FontName = 'Poppins';
            app.EditField_saving_3.FontSize = 18;
            app.EditField_saving_3.FontColor = [0.8118 0.502 1];
            app.EditField_saving_3.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_saving_3.Position = [15 757 179 45];
            app.EditField_saving_3.Value = 'File name';

            % Create SelectfileButton
            app.SelectfileButton = uibutton(app.Panel, 'push');
            app.SelectfileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectfileButtonPushed, true);
            app.SelectfileButton.BackgroundColor = [0.149 0.149 0.149];
            app.SelectfileButton.FontName = 'Poppins';
            app.SelectfileButton.FontSize = 18;
            app.SelectfileButton.FontColor = [0.8118 0.502 1];
            app.SelectfileButton.Position = [204 757 181 45];
            app.SelectfileButton.Text = 'Select file';

            % Create NbofextendedchannelsLabel
            app.NbofextendedchannelsLabel = uilabel(app.Panel);
            app.NbofextendedchannelsLabel.BackgroundColor = [0.149 0.149 0.149];
            app.NbofextendedchannelsLabel.HorizontalAlignment = 'right';
            app.NbofextendedchannelsLabel.WordWrap = 'on';
            app.NbofextendedchannelsLabel.FontName = 'Poppins';
            app.NbofextendedchannelsLabel.FontSize = 18;
            app.NbofextendedchannelsLabel.FontColor = [0.3804 0.7804 0.749];
            app.NbofextendedchannelsLabel.Position = [15 197 229 35];
            app.NbofextendedchannelsLabel.Text = 'Nb of extended channels ';

            % Create NbofextendedchannelsEditField
            app.NbofextendedchannelsEditField = uieditfield(app.Panel, 'numeric');
            app.NbofextendedchannelsEditField.FontName = 'Poppins';
            app.NbofextendedchannelsEditField.FontSize = 18;
            app.NbofextendedchannelsEditField.FontColor = [0.3804 0.7804 0.749];
            app.NbofextendedchannelsEditField.BackgroundColor = [0.149 0.149 0.149];
            app.NbofextendedchannelsEditField.Position = [257 197 127 35];
            app.NbofextendedchannelsEditField.Value = 1000;

            % Create ReferenceDropDownLabel
            app.ReferenceDropDownLabel = uilabel(app.Panel);
            app.ReferenceDropDownLabel.HorizontalAlignment = 'right';
            app.ReferenceDropDownLabel.FontName = 'Poppins';
            app.ReferenceDropDownLabel.FontSize = 18;
            app.ReferenceDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.ReferenceDropDownLabel.Position = [80 655 98 35];
            app.ReferenceDropDownLabel.Text = 'Reference';

            % Create ReferenceDropDown
            app.ReferenceDropDown = uidropdown(app.Panel);
            app.ReferenceDropDown.Items = {'Target', 'EMG amplitude'};
            app.ReferenceDropDown.FontName = 'Poppins';
            app.ReferenceDropDown.FontSize = 18;
            app.ReferenceDropDown.FontColor = [0.5608 0.6196 0.851];
            app.ReferenceDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.ReferenceDropDown.Position = [186 655 198 35];
            app.ReferenceDropDown.Value = 'Target';

            % Create CheckEMGDropDownLabel
            app.CheckEMGDropDownLabel = uilabel(app.Panel);
            app.CheckEMGDropDownLabel.HorizontalAlignment = 'right';
            app.CheckEMGDropDownLabel.FontName = 'Poppins';
            app.CheckEMGDropDownLabel.FontSize = 18;
            app.CheckEMGDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.CheckEMGDropDownLabel.Position = [70 609 108 35];
            app.CheckEMGDropDownLabel.Text = 'Check EMG';

            % Create CheckEMGDropDown
            app.CheckEMGDropDown = uidropdown(app.Panel);
            app.CheckEMGDropDown.Items = {'Yes', 'No'};
            app.CheckEMGDropDown.FontName = 'Poppins';
            app.CheckEMGDropDown.FontSize = 18;
            app.CheckEMGDropDown.FontColor = [0.5608 0.6196 0.851];
            app.CheckEMGDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.CheckEMGDropDown.Position = [186 609 198 35];
            app.CheckEMGDropDown.Value = 'Yes';

            % Create PeeloffDropDownLabel
            app.PeeloffDropDownLabel = uilabel(app.Panel);
            app.PeeloffDropDownLabel.HorizontalAlignment = 'right';
            app.PeeloffDropDownLabel.FontName = 'Poppins';
            app.PeeloffDropDownLabel.FontSize = 18;
            app.PeeloffDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.PeeloffDropDownLabel.Position = [110 425 68 35];
            app.PeeloffDropDownLabel.Text = 'Peeloff';

            % Create PeeloffDropDown
            app.PeeloffDropDown = uidropdown(app.Panel);
            app.PeeloffDropDown.Items = {'Yes', 'No'};
            app.PeeloffDropDown.FontName = 'Poppins';
            app.PeeloffDropDown.FontSize = 18;
            app.PeeloffDropDown.FontColor = [0.5608 0.6196 0.851];
            app.PeeloffDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.PeeloffDropDown.Position = [186 425 198 35];
            app.PeeloffDropDown.Value = 'Yes';

            % Create NumberofwindowsEditFieldLabel
            app.NumberofwindowsEditFieldLabel = uilabel(app.Panel);
            app.NumberofwindowsEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofwindowsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofwindowsEditFieldLabel.FontName = 'Poppins';
            app.NumberofwindowsEditFieldLabel.FontSize = 18;
            app.NumberofwindowsEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.NumberofwindowsEditFieldLabel.Position = [51 287 190 35];
            app.NumberofwindowsEditFieldLabel.Text = 'Number of windows';

            % Create NumberofwindowsEditField
            app.NumberofwindowsEditField = uieditfield(app.Panel, 'numeric');
            app.NumberofwindowsEditField.FontName = 'Poppins';
            app.NumberofwindowsEditField.FontSize = 18;
            app.NumberofwindowsEditField.FontColor = [0.3804 0.7804 0.749];
            app.NumberofwindowsEditField.BackgroundColor = [0.149 0.149 0.149];
            app.NumberofwindowsEditField.Position = [256 287 128 35];
            app.NumberofwindowsEditField.Value = 1;

            % Create CoVfilterDropDownLabel
            app.CoVfilterDropDownLabel = uilabel(app.Panel);
            app.CoVfilterDropDownLabel.HorizontalAlignment = 'right';
            app.CoVfilterDropDownLabel.FontName = 'Poppins';
            app.CoVfilterDropDownLabel.FontSize = 18;
            app.CoVfilterDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.CoVfilterDropDownLabel.Position = [88 471 90 35];
            app.CoVfilterDropDownLabel.Text = 'CoV filter';

            % Create CoVfilterDropDown
            app.CoVfilterDropDown = uidropdown(app.Panel);
            app.CoVfilterDropDown.Items = {'Yes', 'No'};
            app.CoVfilterDropDown.FontName = 'Poppins';
            app.CoVfilterDropDown.FontSize = 18;
            app.CoVfilterDropDown.FontColor = [0.5608 0.6196 0.851];
            app.CoVfilterDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.CoVfilterDropDown.Position = [186 471 198 35];
            app.CoVfilterDropDown.Value = 'Yes';

            % Create InitialisationDropDownLabel
            app.InitialisationDropDownLabel = uilabel(app.Panel);
            app.InitialisationDropDownLabel.HorizontalAlignment = 'right';
            app.InitialisationDropDownLabel.FontName = 'Poppins';
            app.InitialisationDropDownLabel.FontSize = 18;
            app.InitialisationDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.InitialisationDropDownLabel.Position = [56 517 122 35];
            app.InitialisationDropDownLabel.Text = 'Initialisation';

            % Create InitialisationDropDown
            app.InitialisationDropDown = uidropdown(app.Panel);
            app.InitialisationDropDown.Items = {'EMG max', 'Random'};
            app.InitialisationDropDown.FontName = 'Poppins';
            app.InitialisationDropDown.FontSize = 18;
            app.InitialisationDropDown.FontColor = [0.5608 0.6196 0.851];
            app.InitialisationDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.InitialisationDropDown.Position = [186 517 198 35];
            app.InitialisationDropDown.Value = 'EMG max';

            % Create RefineMUsDropDownLabel
            app.RefineMUsDropDownLabel = uilabel(app.Panel);
            app.RefineMUsDropDownLabel.HorizontalAlignment = 'right';
            app.RefineMUsDropDownLabel.FontName = 'Poppins';
            app.RefineMUsDropDownLabel.FontSize = 18;
            app.RefineMUsDropDownLabel.FontColor = [0.5608 0.6196 0.851];
            app.RefineMUsDropDownLabel.Position = [72 379 106 35];
            app.RefineMUsDropDownLabel.Text = 'Refine MUs';

            % Create RefineMUsDropDown
            app.RefineMUsDropDown = uidropdown(app.Panel);
            app.RefineMUsDropDown.Items = {'Yes', 'No'};
            app.RefineMUsDropDown.FontName = 'Poppins';
            app.RefineMUsDropDown.FontSize = 18;
            app.RefineMUsDropDown.FontColor = [0.5608 0.6196 0.851];
            app.RefineMUsDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.RefineMUsDropDown.Position = [186 379 198 35];
            app.RefineMUsDropDown.Value = 'Yes';

            % Create ThresholdtargetEditFieldLabel
            app.ThresholdtargetEditFieldLabel = uilabel(app.Panel);
            app.ThresholdtargetEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdtargetEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdtargetEditFieldLabel.FontName = 'Poppins';
            app.ThresholdtargetEditFieldLabel.FontSize = 18;
            app.ThresholdtargetEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.ThresholdtargetEditFieldLabel.Position = [82 242 159 35];
            app.ThresholdtargetEditFieldLabel.Text = 'Threshold target';

            % Create ThresholdtargetEditField
            app.ThresholdtargetEditField = uieditfield(app.Panel, 'numeric');
            app.ThresholdtargetEditField.FontName = 'Poppins';
            app.ThresholdtargetEditField.FontSize = 18;
            app.ThresholdtargetEditField.FontColor = [0.3804 0.7804 0.749];
            app.ThresholdtargetEditField.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdtargetEditField.Position = [256 242 128 35];
            app.ThresholdtargetEditField.Value = 0.9;

            % Create COVthresholdEditFieldLabel
            app.COVthresholdEditFieldLabel = uilabel(app.Panel);
            app.COVthresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.COVthresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.COVthresholdEditFieldLabel.FontName = 'Poppins';
            app.COVthresholdEditFieldLabel.FontSize = 18;
            app.COVthresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.COVthresholdEditFieldLabel.Position = [102 62 139 35];
            app.COVthresholdEditFieldLabel.Text = 'COV threshold';

            % Create COVthresholdEditField
            app.COVthresholdEditField = uieditfield(app.Panel, 'numeric');
            app.COVthresholdEditField.FontName = 'Poppins';
            app.COVthresholdEditField.FontSize = 18;
            app.COVthresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.COVthresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.COVthresholdEditField.Position = [256 62 128 35];
            app.COVthresholdEditField.Value = 0.5;

            % Create DuplicatethresholdEditFieldLabel
            app.DuplicatethresholdEditFieldLabel = uilabel(app.Panel);
            app.DuplicatethresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.DuplicatethresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.DuplicatethresholdEditFieldLabel.FontName = 'Poppins';
            app.DuplicatethresholdEditFieldLabel.FontSize = 18;
            app.DuplicatethresholdEditFieldLabel.FontColor = [0.3804 0.7804 0.749];
            app.DuplicatethresholdEditFieldLabel.Position = [53 152 188 35];
            app.DuplicatethresholdEditFieldLabel.Text = 'Duplicate threshold';

            % Create DuplicatethresholdEditField
            app.DuplicatethresholdEditField = uieditfield(app.Panel, 'numeric');
            app.DuplicatethresholdEditField.FontName = 'Poppins';
            app.DuplicatethresholdEditField.FontSize = 18;
            app.DuplicatethresholdEditField.FontColor = [0.3804 0.7804 0.749];
            app.DuplicatethresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.DuplicatethresholdEditField.Position = [256 152 128 35];
            app.DuplicatethresholdEditField.Value = 0.3;

            % Create ContrastfunctionLabel
            app.ContrastfunctionLabel = uilabel(app.Panel);
            app.ContrastfunctionLabel.HorizontalAlignment = 'center';
            app.ContrastfunctionLabel.WordWrap = 'on';
            app.ContrastfunctionLabel.FontName = 'Poppins';
            app.ContrastfunctionLabel.FontSize = 18;
            app.ContrastfunctionLabel.FontColor = [0.5608 0.6196 0.851];
            app.ContrastfunctionLabel.Position = [9 563 169 35];
            app.ContrastfunctionLabel.Text = 'Contrast function';

            % Create ContrastfunctionDropDown
            app.ContrastfunctionDropDown = uidropdown(app.Panel);
            app.ContrastfunctionDropDown.Items = {'skew', 'kurtosis', 'logcosh'};
            app.ContrastfunctionDropDown.FontName = 'Poppins';
            app.ContrastfunctionDropDown.FontSize = 18;
            app.ContrastfunctionDropDown.FontColor = [0.5608 0.6196 0.851];
            app.ContrastfunctionDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.ContrastfunctionDropDown.Position = [186 563 198 35];
            app.ContrastfunctionDropDown.Value = 'skew';

            % Create SetconfigurationButton
            app.SetconfigurationButton = uibutton(app.Panel, 'push');
            app.SetconfigurationButton.ButtonPushedFcn = createCallbackFcn(app, @SetconfigurationButtonPushed, true);
            app.SetconfigurationButton.BackgroundColor = [0.149 0.149 0.149];
            app.SetconfigurationButton.FontName = 'Poppins';
            app.SetconfigurationButton.FontSize = 18;
            app.SetconfigurationButton.FontColor = [0.8118 0.502 1];
            app.SetconfigurationButton.Position = [15 701 180 45];
            app.SetconfigurationButton.Text = 'Set configuration';

            % Create SegmentsessionButton
            app.SegmentsessionButton = uibutton(app.Panel, 'push');
            app.SegmentsessionButton.ButtonPushedFcn = createCallbackFcn(app, @SegmentsessionButtonPushed, true);
            app.SegmentsessionButton.BackgroundColor = [0.149 0.149 0.149];
            app.SegmentsessionButton.FontName = 'Poppins';
            app.SegmentsessionButton.FontSize = 18;
            app.SegmentsessionButton.FontColor = [0.8118 0.502 1];
            app.SegmentsessionButton.Position = [204 701 180 45];
            app.SegmentsessionButton.Text = 'Segment session';

            % Create tabs
            app.tabs = uidropdown(app.UIFigure);
            app.tabs.Items = {'DECOMPOSITION', 'MANUAL EDITING'};
            app.tabs.ValueChangedFcn = createCallbackFcn(app, @tabsValueChanged, true);
            app.tabs.FontName = 'Poppins';
            app.tabs.FontSize = 24;
            app.tabs.FontWeight = 'bold';
            app.tabs.FontColor = [0.9608 0.9608 0.9608];
            app.tabs.BackgroundColor = [0.149 0.149 0.149];
            app.tabs.Position = [0 810 400 40];
            app.tabs.Value = 'DECOMPOSITION';

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