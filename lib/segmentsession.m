classdef segmentsession < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        WindowsEditField         matlab.ui.control.NumericEditField
        WindowsEditFieldLabel    matlab.ui.control.Label
        pathname                 matlab.ui.control.EditField
        ConcatenateButton        matlab.ui.control.Button
        SplitButton              matlab.ui.control.Button
        ThresholdEditField       matlab.ui.control.NumericEditField
        ThresholdEditFieldLabel  matlab.ui.control.Label
        OKButton                 matlab.ui.control.Button
        ReferenceDropDown        matlab.ui.control.DropDown
        ReferenceDropDownLabel   matlab.ui.control.Label
        UIAxes                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        file % File to update with the segmentation
        coordinates % Time stamps for segmentation
        data % Segmented data
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Drop down opening function: ReferenceDropDown
        function ReferenceDropDownOpening(app, event)
            app.file = load(app.pathname.Value);

            app.UIAxes.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes.YColor = [0.9412 0.9412 0.9412];
            
            if contains(app.ReferenceDropDown.Value, 'EMG amplitude')
                tmp = zeros(floor(size(app.file.signal.data,1)/2), size(app.file.signal.data,2));
                for i = 1:floor(size(app.file.signal.data,1)/2)
                    tmp(i,:) = movmean(abs(app.file.signal.data(i,:)), app.file.signal.fsamp);
                end
                app.file.signal.target = mean(tmp,1);
                app.file.signal.path = mean(tmp,1);
                plot(app.UIAxes, tmp', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.25)
                hold(app.UIAxes, 'on')
                plot(app.UIAxes, app.file.signal.target, 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                ylim(app.UIAxes, 'tight');
                clearvars tmp
                hold(app.UIAxes, 'off')
                app.ThresholdEditField.Enable = 'off';
            else
                for i = 1:length(app.file.signal.auxiliaryname)
                    if contains(app.ReferenceDropDown.Value, app.file.signal.auxiliaryname{i})
                        idx = i;
                    end
                end
                app.file.signal.target = app.file.signal.auxiliary(idx,:);
                plot(app.UIAxes, app.file.signal.target, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)
                ylim(app.UIAxes, 'tight');
                app.ThresholdEditField.Enable = 'on';
                hold(app.UIAxes, 'off')
            end
        end

        % Value changed function: ReferenceDropDown
        function ReferenceDropDownValueChanged(app, event)
            app.UIAxes.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes.YColor = [0.9412 0.9412 0.9412];
            
            if contains(app.ReferenceDropDown.Value, 'EMG amplitude')
                tmp = zeros(floor(size(app.file.signal.data,1)/2), size(app.file.signal.data,2));
                for i = 1:floor(size(app.file.signal.data,1)/2)
                    tmp(i,:) = movmean(abs(app.file.signal.data(i,:)), app.file.signal.fsamp);
                end
                app.file.signal.target = mean(tmp,1);
                app.file.signal.path = mean(tmp,1);
                plot(app.UIAxes, tmp', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.25)
                hold(app.UIAxes, 'on')
                plot(app.UIAxes, app.file.signal.target, 'Color', [0.85 0.33 0.10], 'LineWidth', 2)
                ylim(app.UIAxes, 'tight');
                clearvars tmp
                hold(app.UIAxes, 'off')
                app.ThresholdEditField.Enable = 'off';
            else
                for i = 1:length(app.file.signal.auxiliaryname)
                    if contains(app.ReferenceDropDown.Value, app.file.signal.auxiliaryname{i})
                        idx = i;
                    end
                end
                app.file.signal.target = app.file.signal.auxiliary(idx,:);
                plot(app.UIAxes, app.file.signal.target, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)
                ylim(app.UIAxes, 'tight');
                app.ThresholdEditField.Enable = 'on';
                hold(app.UIAxes, 'off')
            end
        end

        % Value changed function: ThresholdEditField
        function ThresholdEditFieldValueChanged(app, event)
            if contains(app.ReferenceDropDown.Value, 'EMG amplitude') == 0
                app.coordinates = segmenttargets(app.file.signal.target, 1, app.ThresholdEditField.Value);
                for i = 1:length(app.coordinates)/2
                    app.coordinates(i*2-1) = app.coordinates(i*2-1) - app.file.signal.fsamp;
                    app.coordinates(i*2) = app.coordinates(i*2) + app.file.signal.fsamp;
                end
                app.coordinates(app.coordinates<1) = 1;
                app.coordinates(app.coordinates>length(app.file.signal.target)) = length(app.file.signal.target);

                lincol = winter(length(app.coordinates)/2);
                plot(app.UIAxes, app.file.signal.target, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)
                hold(app.UIAxes, 'on')
                for i = 1:length(app.coordinates)/2
                    line(app.UIAxes, [app.coordinates(i*2-1) app.coordinates(i*2-1)], [min(app.file.signal.target) max(app.file.signal.target)],'Color', lincol(i,:), 'LineWidth', 2)
                    line(app.UIAxes, [app.coordinates(i*2) app.coordinates(i*2)], [min(app.file.signal.target) max(app.file.signal.target)],'Color', lincol(i,:), 'LineWidth', 2)
                end
                hold(app.UIAxes, 'off')
                ylim(app.UIAxes, 'tight');
            end
        end

        % Value changed function: WindowsEditField
        function WindowsEditFieldValueChanged(app, event)
            lincol = winter(app.WindowsEditField.Value*2);
            plot(app.UIAxes, app.file.signal.target, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)
            hold(app.UIAxes, 'on')
            for nwin = 1:app.WindowsEditField.Value
                roi = drawrectangle(app.UIAxes, 'DrawingArea', 'auto');
                x = [roi.Position(1) roi.Position(1) + roi.Position(3)];
                x = sort(x,'ascend');
                x(x<1) = 1;
                x(x>length(app.file.signal.target)) = length(app.file.signal.target);
                app.coordinates(nwin*2-1) = floor(x(1));
                app.coordinates(nwin*2) = floor(x(2));
                line(app.UIAxes, [app.coordinates(nwin*2-1) app.coordinates(nwin*2-1)], [min(app.file.signal.target) max(app.file.signal.target)],'Color', lincol(nwin,:), 'LineWidth', 2)
                line(app.UIAxes, [app.coordinates(nwin*2) app.coordinates(nwin*2)], [min(app.file.signal.target) max(app.file.signal.target)],'Color', lincol(nwin,:), 'LineWidth', 2)
                delete(roi);
            end
            hold(app.UIAxes, 'off')
            ylim(app.UIAxes, 'tight');
        end

        % Button pushed function: SplitButton
        function SplitButtonPushed(app, event)
            for i = 1:length(app.coordinates)/2
                app.data.data{i} = app.file.signal.data(:, app.coordinates(i*2-1):app.coordinates(i*2));
                app.data.auxiliary{i} = app.file.signal.auxiliary(:, app.coordinates(i*2-1):app.coordinates(i*2));
                app.data.target{i} = app.file.signal.target(app.coordinates(i*2-1):app.coordinates(i*2));
                app.data.path{i} = app.data.target{i};
            end

            % Save the updated files
            for i = 1:length(app.coordinates)/2
                app.file.signal.data = app.data.data{i};
                app.file.signal.auxiliary = app.data.auxiliary{i};
                app.file.signal.target = app.data.target{i};
                app.file.signal.path = app.file.signal.target;
  
                signal = app.file.signal;
                save([app.pathname.Value '_' num2str(i) '.mat'], 'signal', '-v7.3');    
            end

            % Update de pathname
            app.pathname.Value = [app.pathname.Value '_1.mat'];

            % Update the plot with the first segment
            plot(app.UIAxes, app.data.target{1}, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)
            ylim(app.UIAxes, 'tight');
            app.ConcatenateButton.Enable = 'off';
            app.SplitButton.Enable = 'off';
        end

        % Button pushed function: ConcatenateButton
        function ConcatenateButtonPushed(app, event)
            app.data.data = [];
            app.data.auxiliary = [];
            app.data.target = [];
            app.data.path = [];
            for i = 1:length(app.coordinates)/2
                app.data.data = [app.data.data, app.file.signal.data(:, app.coordinates(i*2-1):app.coordinates(i*2))];
                app.data.auxiliary = [app.data.auxiliary, app.file.signal.auxiliary(:, app.coordinates(i*2-1):app.coordinates(i*2))];
                app.data.target = [app.data.target, app.file.signal.target(app.coordinates(i*2-1):app.coordinates(i*2))];
            end

            app.file.signal.data = app.data.data;
            app.file.signal.auxiliary = app.data.auxiliary;
            app.file.signal.target = app.data.target;
            app.file.signal.path = app.file.signal.target;

            % Update plot
            plot(app.UIAxes, app.file.signal.target, 'Color', [0.95 0.95 0.95], 'LineWidth', 2)

            % Save the updated file
            signal = app.file.signal;
            save(app.pathname.Value, 'signal', '-v7.3');

            app.ConcatenateButton.Enable = 'off';
            app.SplitButton.Enable = 'off';

        end

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            delete(app.UIFigure)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [100 100 600 331];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Reference')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Toolbar.Visible = 'off';
            app.UIAxes.AmbientLightColor = [0.9412 0.9412 0.9412];
            app.UIAxes.FontName = 'Poppins';
            app.UIAxes.Color = [0.149 0.149 0.149];
            app.UIAxes.FontSize = 12;
            app.UIAxes.Interruptible = 'off';
            app.UIAxes.HitTest = 'off';
            app.UIAxes.PickableParts = 'none';
            app.UIAxes.Position = [10 10 581 293];

            % Create ReferenceDropDownLabel
            app.ReferenceDropDownLabel = uilabel(app.UIFigure);
            app.ReferenceDropDownLabel.BackgroundColor = [0.149 0.149 0.149];
            app.ReferenceDropDownLabel.HorizontalAlignment = 'right';
            app.ReferenceDropDownLabel.FontName = 'Poppins';
            app.ReferenceDropDownLabel.FontColor = [0.9412 0.9412 0.9412];
            app.ReferenceDropDownLabel.Position = [12 304 65 22];
            app.ReferenceDropDownLabel.Text = 'Reference';

            % Create ReferenceDropDown
            app.ReferenceDropDown = uidropdown(app.UIFigure);
            app.ReferenceDropDown.Items = {'No ref'};
            app.ReferenceDropDown.DropDownOpeningFcn = createCallbackFcn(app, @ReferenceDropDownOpening, true);
            app.ReferenceDropDown.ValueChangedFcn = createCallbackFcn(app, @ReferenceDropDownValueChanged, true);
            app.ReferenceDropDown.FontName = 'Poppins';
            app.ReferenceDropDown.FontColor = [0.9412 0.9412 0.9412];
            app.ReferenceDropDown.BackgroundColor = [0.149 0.149 0.149];
            app.ReferenceDropDown.Position = [84 304 71 22];
            app.ReferenceDropDown.Value = 'No ref';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.149 0.149 0.149];
            app.OKButton.FontName = 'Poppins';
            app.OKButton.FontWeight = 'bold';
            app.OKButton.FontColor = [0.9412 0.9412 0.9412];
            app.OKButton.Position = [546 303 45 23];
            app.OKButton.Text = 'OK';

            % Create ThresholdEditFieldLabel
            app.ThresholdEditFieldLabel = uilabel(app.UIFigure);
            app.ThresholdEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdEditFieldLabel.FontName = 'Poppins';
            app.ThresholdEditFieldLabel.FontColor = [0.9412 0.9412 0.9412];
            app.ThresholdEditFieldLabel.Position = [158 304 66 22];
            app.ThresholdEditFieldLabel.Text = 'Threshold';

            % Create ThresholdEditField
            app.ThresholdEditField = uieditfield(app.UIFigure, 'numeric');
            app.ThresholdEditField.ValueChangedFcn = createCallbackFcn(app, @ThresholdEditFieldValueChanged, true);
            app.ThresholdEditField.FontName = 'Poppins';
            app.ThresholdEditField.FontColor = [0.9412 0.9412 0.9412];
            app.ThresholdEditField.BackgroundColor = [0.149 0.149 0.149];
            app.ThresholdEditField.Position = [231 303 31 22];

            % Create SplitButton
            app.SplitButton = uibutton(app.UIFigure, 'push');
            app.SplitButton.ButtonPushedFcn = createCallbackFcn(app, @SplitButtonPushed, true);
            app.SplitButton.BackgroundColor = [0.149 0.149 0.149];
            app.SplitButton.FontName = 'Poppins';
            app.SplitButton.FontWeight = 'bold';
            app.SplitButton.FontColor = [0.9412 0.9412 0.9412];
            app.SplitButton.Position = [470 303 74 23];
            app.SplitButton.Text = 'Split';

            % Create ConcatenateButton
            app.ConcatenateButton = uibutton(app.UIFigure, 'push');
            app.ConcatenateButton.ButtonPushedFcn = createCallbackFcn(app, @ConcatenateButtonPushed, true);
            app.ConcatenateButton.BackgroundColor = [0.149 0.149 0.149];
            app.ConcatenateButton.FontName = 'Poppins';
            app.ConcatenateButton.FontWeight = 'bold';
            app.ConcatenateButton.FontColor = [0.9412 0.9412 0.9412];
            app.ConcatenateButton.Position = [372 303 96 23];
            app.ConcatenateButton.Text = 'Concatenate';

            % Create pathname
            app.pathname = uieditfield(app.UIFigure, 'text');
            app.pathname.FontName = 'Poppins';
            app.pathname.FontSize = 14;
            app.pathname.FontColor = [0.9412 0.9412 0.9412];
            app.pathname.BackgroundColor = [0.149 0.149 0.149];
            app.pathname.Visible = 'off';
            app.pathname.Position = [514 1 87 22];

            % Create WindowsEditFieldLabel
            app.WindowsEditFieldLabel = uilabel(app.UIFigure);
            app.WindowsEditFieldLabel.BackgroundColor = [0.149 0.149 0.149];
            app.WindowsEditFieldLabel.HorizontalAlignment = 'right';
            app.WindowsEditFieldLabel.FontName = 'Poppins';
            app.WindowsEditFieldLabel.FontColor = [0.9412 0.9412 0.9412];
            app.WindowsEditFieldLabel.Position = [265 304 66 22];
            app.WindowsEditFieldLabel.Text = 'Windows';

            % Create WindowsEditField
            app.WindowsEditField = uieditfield(app.UIFigure, 'numeric');
            app.WindowsEditField.ValueChangedFcn = createCallbackFcn(app, @WindowsEditFieldValueChanged, true);
            app.WindowsEditField.FontName = 'Poppins';
            app.WindowsEditField.FontColor = [0.9412 0.9412 0.9412];
            app.WindowsEditField.BackgroundColor = [0.149 0.149 0.149];
            app.WindowsEditField.Position = [338 303 31 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = segmentsession

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