classdef OEphysdlg < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        pathname            matlab.ui.control.EditField
        CheckBox_B1         matlab.ui.control.CheckBox
        CheckBox_B2         matlab.ui.control.CheckBox
        CheckBox_D2         matlab.ui.control.CheckBox
        CheckBox_D1         matlab.ui.control.CheckBox
        CheckBox_C2         matlab.ui.control.CheckBox
        CheckBox_C1         matlab.ui.control.CheckBox
        CheckBox_A2         matlab.ui.control.CheckBox
        CheckBox_A1         matlab.ui.control.CheckBox
        OKButton            matlab.ui.control.Button
        ChannelsLabel       matlab.ui.control.Label
        EditField_nchan     matlab.ui.control.NumericEditField
        EditField_Ain       matlab.ui.control.NumericEditField
        EditField_Din       matlab.ui.control.NumericEditField
        Lamp_D2             matlab.ui.control.Lamp
        Lamp_D1             matlab.ui.control.Lamp
        Lamp_C2             matlab.ui.control.Lamp
        Lamp_C1             matlab.ui.control.Lamp
        Lamp_B2             matlab.ui.control.Lamp
        Lamp_B1             matlab.ui.control.Lamp
        Lamp_A2             matlab.ui.control.Lamp
        Lamp_A1             matlab.ui.control.Lamp
        Image               matlab.ui.control.Image
        PortD2Panel         matlab.ui.container.Panel
        MusclenameLabel_D2  matlab.ui.control.Label
        ArraytypeLabel_D2   matlab.ui.control.Label
        EditField_D2        matlab.ui.control.EditField
        DropDown_D2         matlab.ui.control.DropDown
        PortC2Panel         matlab.ui.container.Panel
        MusclenameLabel_C2  matlab.ui.control.Label
        ArraytypeLabel_C2   matlab.ui.control.Label
        EditField_C2        matlab.ui.control.EditField
        DropDown_C2         matlab.ui.control.DropDown
        PortB2Panel         matlab.ui.container.Panel
        MusclenameLabel_B2  matlab.ui.control.Label
        ArraytypeLabel_B2   matlab.ui.control.Label
        EditField_B2        matlab.ui.control.EditField
        DropDown_B2         matlab.ui.control.DropDown
        PortA2Panel         matlab.ui.container.Panel
        MusclenameLabel_A2  matlab.ui.control.Label
        ArraytypeLabel_A2   matlab.ui.control.Label
        EditField_A2        matlab.ui.control.EditField
        DropDown_A2         matlab.ui.control.DropDown
        PortD1Panel         matlab.ui.container.Panel
        MusclenameLabel_D1  matlab.ui.control.Label
        ArraytypeLabel_D1   matlab.ui.control.Label
        EditField_D1        matlab.ui.control.EditField
        DropDown_D1         matlab.ui.control.DropDown
        PortC1Panel         matlab.ui.container.Panel
        MusclenameLabel_C1  matlab.ui.control.Label
        ArraytypeLabel_C1   matlab.ui.control.Label
        EditField_C1        matlab.ui.control.EditField
        DropDown_C1         matlab.ui.control.DropDown
        PortB1Panel         matlab.ui.container.Panel
        MusclenameLabel_B1  matlab.ui.control.Label
        ArraytypeLabel_B1   matlab.ui.control.Label
        EditField_B1        matlab.ui.control.EditField
        DropDown_B1         matlab.ui.control.DropDown
        PortA1Panel         matlab.ui.container.Panel
        MusclenameLabel_A1  matlab.ui.control.Label
        ArraytypeLabel_A1   matlab.ui.control.Label
        EditField_A1        matlab.ui.control.EditField
        DropDown_A1         matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        file % File to update with the configuration
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            app.file = load(app.pathname.Value);
            
            ports(1) = app.CheckBox_A1.Value;
            ports(2) = app.CheckBox_A2.Value;
            ports(3) = app.CheckBox_B1.Value;
            ports(4) = app.CheckBox_B2.Value;
            ports(5) = app.CheckBox_C1.Value;
            ports(6) = app.CheckBox_C2.Value;
            ports(7) = app.CheckBox_D1.Value;
            ports(8) = app.CheckBox_D2.Value;

            app.file.signal.ngrid = sum(ports);
            
            grid{1} = app.DropDown_A1.Value;
            grid{2} = app.DropDown_A2.Value;
            grid{3} = app.DropDown_B1.Value;
            grid{4} = app.DropDown_B2.Value;
            grid{5} = app.DropDown_C1.Value;
            grid{6} = app.DropDown_C2.Value;
            grid{7} = app.DropDown_D1.Value;
            grid{8} = app.DropDown_D2.Value;

            muscle{1} = app.EditField_A1.Value;
            muscle{2} = app.EditField_A2.Value;
            muscle{3} = app.EditField_B1.Value;
            muscle{4} = app.EditField_B2.Value;
            muscle{5} = app.EditField_C1.Value;
            muscle{6} = app.EditField_C2.Value;
            muscle{7} = app.EditField_D1.Value;
            muscle{8} = app.EditField_D2.Value;

            idxports = find(ports == 1);
            for i = 1:app.file.signal.ngrid
                app.file.signal.gridname{i} = grid{idxports(i)};
                app.file.signal.muscle{i} = muscle{idxports(i)};
            end

            signal = app.file.signal;
            save(app.pathname.Value, 'signal', '-v7.3');
            delete(app.UIFigure)
        end

        % Value changed function: CheckBox_A1
        function CheckBox_A1ValueChanged(app, event)
            if app.CheckBox_A1.Value
                app.Lamp_A1.Color = 'Green';
                app.PortA1Panel.Enable = "on";
            else
                app.Lamp_A1.Color = 'Red';
                app.PortA1Panel.Enable = "off";
            end
        end

        % Value changed function: CheckBox_A2
        function CheckBox_A2ValueChanged(app, event)
            if app.CheckBox_A2.Value
                app.Lamp_A2.Color = 'Green';
                app.PortA2Panel.Enable = "on";
            else
                app.Lamp_A2.Color = 'Red';
                app.PortA2Panel.Enable = "off";
            end
        end

        % Value changed function: CheckBox_B1
        function CheckBox_B1ValueChanged(app, event)
            if app.CheckBox_B1.Value
                app.Lamp_B1.Color = 'Green';
                app.PortB1Panel.Enable = "on";
            else
                app.Lamp_B1.Color = 'Red';
                app.PortB1Panel.Enable = "off";
            end            
        end

        % Value changed function: CheckBox_B2
        function CheckBox_B2ValueChanged(app, event)
            if app.CheckBox_B2.Value
                app.Lamp_B2.Color = 'Green';
                app.PortB2Panel.Enable = "on";
            else
                app.Lamp_B2.Color = 'Red';
                app.PortB2Panel.Enable = "off";
            end                        
        end

        % Value changed function: CheckBox_C1
        function CheckBox_C1ValueChanged(app, event)
            if app.CheckBox_C1.Value
                app.Lamp_C1.Color = 'Green';
                app.PortC1Panel.Enable = "on";
            else
                app.Lamp_C1.Color = 'Red';
                app.PortC1Panel.Enable = "off";
            end                                    
        end

        % Value changed function: CheckBox_C2
        function CheckBox_C2ValueChanged(app, event)
            if app.CheckBox_C2.Value
                app.Lamp_C2.Color = 'Green';
                app.PortC2Panel.Enable = "on";
            else
                app.Lamp_C2.Color = 'Red';
                app.PortC2Panel.Enable = "off";
            end                                                
        end

        % Value changed function: CheckBox_D1
        function CheckBox_D1ValueChanged(app, event)
            if app.CheckBox_D1.Value
                app.Lamp_D1.Color = 'Green';
                app.PortD1Panel.Enable = "on";
            else
                app.Lamp_D1.Color = 'Red';
                app.PortD1Panel.Enable = "off";
            end                                                
        end

        % Value changed function: CheckBox_D2
        function CheckBox_D2ValueChanged(app, event)
            if app.CheckBox_D2.Value
                app.Lamp_D2.Color = 'Green';
                app.PortD2Panel.Enable = "on";
            else
                app.Lamp_D2.Color = 'Red';
                app.PortD2Panel.Enable = "off";
            end                                                
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Position = [100 100 550 400];
            app.UIFigure.Name = 'MATLAB App';

            % Create PortA1Panel
            app.PortA1Panel = uipanel(app.UIFigure);
            app.PortA1Panel.Enable = 'off';
            app.PortA1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortA1Panel.TitlePosition = 'centertop';
            app.PortA1Panel.Title = 'Port A1';
            app.PortA1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortA1Panel.FontName = 'Poppins';
            app.PortA1Panel.FontWeight = 'bold';
            app.PortA1Panel.FontSize = 14;
            app.PortA1Panel.Position = [1 138 125 125];

            % Create DropDown_A1
            app.DropDown_A1 = uidropdown(app.PortA1Panel);
            app.DropDown_A1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_A1.FontName = 'Poppins';
            app.DropDown_A1.FontSize = 10;
            app.DropDown_A1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_A1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_A1.Position = [7 56 111 22];
            app.DropDown_A1.Value = 'GR04MM1305';

            % Create EditField_A1
            app.EditField_A1 = uieditfield(app.PortA1Panel, 'text');
            app.EditField_A1.FontName = 'Poppins';
            app.EditField_A1.FontSize = 10;
            app.EditField_A1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_A1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_A1.Position = [7 6 111 22];

            % Create ArraytypeLabel_A1
            app.ArraytypeLabel_A1 = uilabel(app.PortA1Panel);
            app.ArraytypeLabel_A1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_A1.FontName = 'Poppins';
            app.ArraytypeLabel_A1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_A1.Position = [32 79 67 22];
            app.ArraytypeLabel_A1.Text = 'Array type';

            % Create MusclenameLabel_A1
            app.MusclenameLabel_A1 = uilabel(app.PortA1Panel);
            app.MusclenameLabel_A1.HorizontalAlignment = 'center';
            app.MusclenameLabel_A1.FontName = 'Poppins';
            app.MusclenameLabel_A1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_A1.Position = [20 28 86 22];
            app.MusclenameLabel_A1.Text = 'Muscle name';

            % Create PortB1Panel
            app.PortB1Panel = uipanel(app.UIFigure);
            app.PortB1Panel.Enable = 'off';
            app.PortB1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortB1Panel.TitlePosition = 'centertop';
            app.PortB1Panel.Title = 'Port B1';
            app.PortB1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortB1Panel.FontName = 'Poppins';
            app.PortB1Panel.FontWeight = 'bold';
            app.PortB1Panel.FontSize = 14;
            app.PortB1Panel.Position = [143 138 125 125];

            % Create DropDown_B1
            app.DropDown_B1 = uidropdown(app.PortB1Panel);
            app.DropDown_B1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_B1.FontName = 'Poppins';
            app.DropDown_B1.FontSize = 10;
            app.DropDown_B1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_B1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_B1.Position = [7 56 111 22];
            app.DropDown_B1.Value = 'GR04MM1305';

            % Create EditField_B1
            app.EditField_B1 = uieditfield(app.PortB1Panel, 'text');
            app.EditField_B1.FontName = 'Poppins';
            app.EditField_B1.FontSize = 10;
            app.EditField_B1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_B1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_B1.Position = [7 6 111 22];

            % Create ArraytypeLabel_B1
            app.ArraytypeLabel_B1 = uilabel(app.PortB1Panel);
            app.ArraytypeLabel_B1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_B1.FontName = 'Poppins';
            app.ArraytypeLabel_B1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_B1.Position = [32 79 67 22];
            app.ArraytypeLabel_B1.Text = 'Array type';

            % Create MusclenameLabel_B1
            app.MusclenameLabel_B1 = uilabel(app.PortB1Panel);
            app.MusclenameLabel_B1.HorizontalAlignment = 'center';
            app.MusclenameLabel_B1.FontName = 'Poppins';
            app.MusclenameLabel_B1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_B1.Position = [20 28 86 22];
            app.MusclenameLabel_B1.Text = 'Muscle name';

            % Create PortC1Panel
            app.PortC1Panel = uipanel(app.UIFigure);
            app.PortC1Panel.Enable = 'off';
            app.PortC1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortC1Panel.TitlePosition = 'centertop';
            app.PortC1Panel.Title = 'Port C1';
            app.PortC1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortC1Panel.FontName = 'Poppins';
            app.PortC1Panel.FontWeight = 'bold';
            app.PortC1Panel.FontSize = 14;
            app.PortC1Panel.Position = [285 138 125 125];

            % Create DropDown_C1
            app.DropDown_C1 = uidropdown(app.PortC1Panel);
            app.DropDown_C1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_C1.FontName = 'Poppins';
            app.DropDown_C1.FontSize = 10;
            app.DropDown_C1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_C1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_C1.Position = [7 56 111 22];
            app.DropDown_C1.Value = 'GR04MM1305';

            % Create EditField_C1
            app.EditField_C1 = uieditfield(app.PortC1Panel, 'text');
            app.EditField_C1.FontName = 'Poppins';
            app.EditField_C1.FontSize = 10;
            app.EditField_C1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_C1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_C1.Position = [7 6 111 22];

            % Create ArraytypeLabel_C1
            app.ArraytypeLabel_C1 = uilabel(app.PortC1Panel);
            app.ArraytypeLabel_C1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_C1.FontName = 'Poppins';
            app.ArraytypeLabel_C1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_C1.Position = [32 79 67 22];
            app.ArraytypeLabel_C1.Text = 'Array type';

            % Create MusclenameLabel_C1
            app.MusclenameLabel_C1 = uilabel(app.PortC1Panel);
            app.MusclenameLabel_C1.HorizontalAlignment = 'center';
            app.MusclenameLabel_C1.FontName = 'Poppins';
            app.MusclenameLabel_C1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_C1.Position = [20 28 86 22];
            app.MusclenameLabel_C1.Text = 'Muscle name';

            % Create PortD1Panel
            app.PortD1Panel = uipanel(app.UIFigure);
            app.PortD1Panel.Enable = 'off';
            app.PortD1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortD1Panel.TitlePosition = 'centertop';
            app.PortD1Panel.Title = 'Port D1';
            app.PortD1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortD1Panel.FontName = 'Poppins';
            app.PortD1Panel.FontWeight = 'bold';
            app.PortD1Panel.FontSize = 14;
            app.PortD1Panel.Position = [426 138 125 125];

            % Create DropDown_D1
            app.DropDown_D1 = uidropdown(app.PortD1Panel);
            app.DropDown_D1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_D1.FontName = 'Poppins';
            app.DropDown_D1.FontSize = 10;
            app.DropDown_D1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_D1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_D1.Position = [7 56 111 22];
            app.DropDown_D1.Value = 'GR04MM1305';

            % Create EditField_D1
            app.EditField_D1 = uieditfield(app.PortD1Panel, 'text');
            app.EditField_D1.FontName = 'Poppins';
            app.EditField_D1.FontSize = 10;
            app.EditField_D1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_D1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_D1.Position = [7 6 111 22];

            % Create ArraytypeLabel_D1
            app.ArraytypeLabel_D1 = uilabel(app.PortD1Panel);
            app.ArraytypeLabel_D1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_D1.FontName = 'Poppins';
            app.ArraytypeLabel_D1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_D1.Position = [32 79 67 22];
            app.ArraytypeLabel_D1.Text = 'Array type';

            % Create MusclenameLabel_D1
            app.MusclenameLabel_D1 = uilabel(app.PortD1Panel);
            app.MusclenameLabel_D1.HorizontalAlignment = 'center';
            app.MusclenameLabel_D1.FontName = 'Poppins';
            app.MusclenameLabel_D1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_D1.Position = [20 28 86 22];
            app.MusclenameLabel_D1.Text = 'Muscle name';

            % Create PortA2Panel
            app.PortA2Panel = uipanel(app.UIFigure);
            app.PortA2Panel.Enable = 'off';
            app.PortA2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortA2Panel.TitlePosition = 'centertop';
            app.PortA2Panel.Title = 'Port A2';
            app.PortA2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortA2Panel.FontName = 'Poppins';
            app.PortA2Panel.FontWeight = 'bold';
            app.PortA2Panel.FontSize = 14;
            app.PortA2Panel.Position = [1 7 125 125];

            % Create DropDown_A2
            app.DropDown_A2 = uidropdown(app.PortA2Panel);
            app.DropDown_A2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_A2.FontName = 'Poppins';
            app.DropDown_A2.FontSize = 10;
            app.DropDown_A2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_A2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_A2.Position = [7 56 111 22];
            app.DropDown_A2.Value = 'GR04MM1305';

            % Create EditField_A2
            app.EditField_A2 = uieditfield(app.PortA2Panel, 'text');
            app.EditField_A2.FontName = 'Poppins';
            app.EditField_A2.FontSize = 10;
            app.EditField_A2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_A2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_A2.Position = [7 6 111 22];

            % Create ArraytypeLabel_A2
            app.ArraytypeLabel_A2 = uilabel(app.PortA2Panel);
            app.ArraytypeLabel_A2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_A2.FontName = 'Poppins';
            app.ArraytypeLabel_A2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_A2.Position = [32 79 67 22];
            app.ArraytypeLabel_A2.Text = 'Array type';

            % Create MusclenameLabel_A2
            app.MusclenameLabel_A2 = uilabel(app.PortA2Panel);
            app.MusclenameLabel_A2.HorizontalAlignment = 'center';
            app.MusclenameLabel_A2.FontName = 'Poppins';
            app.MusclenameLabel_A2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_A2.Position = [20 28 86 22];
            app.MusclenameLabel_A2.Text = 'Muscle name';

            % Create PortB2Panel
            app.PortB2Panel = uipanel(app.UIFigure);
            app.PortB2Panel.Enable = 'off';
            app.PortB2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortB2Panel.TitlePosition = 'centertop';
            app.PortB2Panel.Title = 'Port B2';
            app.PortB2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortB2Panel.FontName = 'Poppins';
            app.PortB2Panel.FontWeight = 'bold';
            app.PortB2Panel.FontSize = 14;
            app.PortB2Panel.Position = [143 7 125 125];

            % Create DropDown_B2
            app.DropDown_B2 = uidropdown(app.PortB2Panel);
            app.DropDown_B2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_B2.FontName = 'Poppins';
            app.DropDown_B2.FontSize = 10;
            app.DropDown_B2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_B2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_B2.Position = [7 56 111 22];
            app.DropDown_B2.Value = 'GR04MM1305';

            % Create EditField_B2
            app.EditField_B2 = uieditfield(app.PortB2Panel, 'text');
            app.EditField_B2.FontName = 'Poppins';
            app.EditField_B2.FontSize = 10;
            app.EditField_B2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_B2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_B2.Position = [7 6 111 22];

            % Create ArraytypeLabel_B2
            app.ArraytypeLabel_B2 = uilabel(app.PortB2Panel);
            app.ArraytypeLabel_B2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_B2.FontName = 'Poppins';
            app.ArraytypeLabel_B2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_B2.Position = [32 79 67 22];
            app.ArraytypeLabel_B2.Text = 'Array type';

            % Create MusclenameLabel_B2
            app.MusclenameLabel_B2 = uilabel(app.PortB2Panel);
            app.MusclenameLabel_B2.HorizontalAlignment = 'center';
            app.MusclenameLabel_B2.FontName = 'Poppins';
            app.MusclenameLabel_B2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_B2.Position = [20 28 86 22];
            app.MusclenameLabel_B2.Text = 'Muscle name';

            % Create PortC2Panel
            app.PortC2Panel = uipanel(app.UIFigure);
            app.PortC2Panel.Enable = 'off';
            app.PortC2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortC2Panel.TitlePosition = 'centertop';
            app.PortC2Panel.Title = 'Port C2';
            app.PortC2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortC2Panel.FontName = 'Poppins';
            app.PortC2Panel.FontWeight = 'bold';
            app.PortC2Panel.FontSize = 14;
            app.PortC2Panel.Position = [285 7 125 125];

            % Create DropDown_C2
            app.DropDown_C2 = uidropdown(app.PortC2Panel);
            app.DropDown_C2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_C2.FontName = 'Poppins';
            app.DropDown_C2.FontSize = 10;
            app.DropDown_C2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_C2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_C2.Position = [7 56 111 22];
            app.DropDown_C2.Value = 'GR04MM1305';

            % Create EditField_C2
            app.EditField_C2 = uieditfield(app.PortC2Panel, 'text');
            app.EditField_C2.FontName = 'Poppins';
            app.EditField_C2.FontSize = 10;
            app.EditField_C2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_C2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_C2.Position = [7 6 111 22];

            % Create ArraytypeLabel_C2
            app.ArraytypeLabel_C2 = uilabel(app.PortC2Panel);
            app.ArraytypeLabel_C2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_C2.FontName = 'Poppins';
            app.ArraytypeLabel_C2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_C2.Position = [32 79 67 22];
            app.ArraytypeLabel_C2.Text = 'Array type';

            % Create MusclenameLabel_C2
            app.MusclenameLabel_C2 = uilabel(app.PortC2Panel);
            app.MusclenameLabel_C2.HorizontalAlignment = 'center';
            app.MusclenameLabel_C2.FontName = 'Poppins';
            app.MusclenameLabel_C2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_C2.Position = [20 28 86 22];
            app.MusclenameLabel_C2.Text = 'Muscle name';

            % Create PortD2Panel
            app.PortD2Panel = uipanel(app.UIFigure);
            app.PortD2Panel.Enable = 'off';
            app.PortD2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.PortD2Panel.TitlePosition = 'centertop';
            app.PortD2Panel.Title = 'Port D2';
            app.PortD2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.PortD2Panel.FontName = 'Poppins';
            app.PortD2Panel.FontWeight = 'bold';
            app.PortD2Panel.FontSize = 14;
            app.PortD2Panel.Position = [426 7 125 125];

            % Create DropDown_D2
            app.DropDown_D2 = uidropdown(app.PortD2Panel);
            app.DropDown_D2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_D2.FontName = 'Poppins';
            app.DropDown_D2.FontSize = 10;
            app.DropDown_D2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_D2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_D2.Position = [7 56 111 22];
            app.DropDown_D2.Value = 'GR04MM1305';

            % Create EditField_D2
            app.EditField_D2 = uieditfield(app.PortD2Panel, 'text');
            app.EditField_D2.FontName = 'Poppins';
            app.EditField_D2.FontSize = 10;
            app.EditField_D2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_D2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_D2.Position = [7 6 111 22];

            % Create ArraytypeLabel_D2
            app.ArraytypeLabel_D2 = uilabel(app.PortD2Panel);
            app.ArraytypeLabel_D2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_D2.FontName = 'Poppins';
            app.ArraytypeLabel_D2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_D2.Position = [32 79 67 22];
            app.ArraytypeLabel_D2.Text = 'Array type';

            % Create MusclenameLabel_D2
            app.MusclenameLabel_D2 = uilabel(app.PortD2Panel);
            app.MusclenameLabel_D2.HorizontalAlignment = 'center';
            app.MusclenameLabel_D2.FontName = 'Poppins';
            app.MusclenameLabel_D2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_D2.Position = [20 28 86 22];
            app.MusclenameLabel_D2.Text = 'Muscle name';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [5 274 461 118];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'OpenEphys.jpg');

            % Create Lamp_A1
            app.Lamp_A1 = uilamp(app.UIFigure);
            app.Lamp_A1.Position = [201 301 20 20];
            app.Lamp_A1.Color = [1 0 0];

            % Create Lamp_A2
            app.Lamp_A2 = uilamp(app.UIFigure);
            app.Lamp_A2.Position = [227 301 20 20];
            app.Lamp_A2.Color = [1 0 0];

            % Create Lamp_B1
            app.Lamp_B1 = uilamp(app.UIFigure);
            app.Lamp_B1.Position = [265 301 20 20];
            app.Lamp_B1.Color = [1 0 0];

            % Create Lamp_B2
            app.Lamp_B2 = uilamp(app.UIFigure);
            app.Lamp_B2.Position = [291 301 20 20];
            app.Lamp_B2.Color = [1 0 0];

            % Create Lamp_C1
            app.Lamp_C1 = uilamp(app.UIFigure);
            app.Lamp_C1.Position = [327 301 20 20];
            app.Lamp_C1.Color = [1 0 0];

            % Create Lamp_C2
            app.Lamp_C2 = uilamp(app.UIFigure);
            app.Lamp_C2.Position = [353 301 20 20];
            app.Lamp_C2.Color = [1 0 0];

            % Create Lamp_D1
            app.Lamp_D1 = uilamp(app.UIFigure);
            app.Lamp_D1.Position = [389 301 20 20];
            app.Lamp_D1.Color = [1 0 0];

            % Create Lamp_D2
            app.Lamp_D2 = uilamp(app.UIFigure);
            app.Lamp_D2.Position = [415 301 20 20];
            app.Lamp_D2.Color = [1 0 0];

            % Create EditField_Din
            app.EditField_Din = uieditfield(app.UIFigure, 'numeric');
            app.EditField_Din.HorizontalAlignment = 'center';
            app.EditField_Din.FontName = 'Poppins';
            app.EditField_Din.FontSize = 10;
            app.EditField_Din.FontWeight = 'bold';
            app.EditField_Din.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_Din.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_Din.Position = [57 298 28 22];

            % Create EditField_Ain
            app.EditField_Ain = uieditfield(app.UIFigure, 'numeric');
            app.EditField_Ain.HorizontalAlignment = 'center';
            app.EditField_Ain.FontName = 'Poppins';
            app.EditField_Ain.FontSize = 10;
            app.EditField_Ain.FontWeight = 'bold';
            app.EditField_Ain.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_Ain.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_Ain.Position = [102 298 28 22];

            % Create EditField_nchan
            app.EditField_nchan = uieditfield(app.UIFigure, 'numeric');
            app.EditField_nchan.HorizontalAlignment = 'center';
            app.EditField_nchan.FontName = 'Poppins';
            app.EditField_nchan.FontSize = 10;
            app.EditField_nchan.FontWeight = 'bold';
            app.EditField_nchan.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_nchan.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_nchan.Position = [150 322 41 22];

            % Create ChannelsLabel
            app.ChannelsLabel = uilabel(app.UIFigure);
            app.ChannelsLabel.HorizontalAlignment = 'center';
            app.ChannelsLabel.FontName = 'Poppins';
            app.ChannelsLabel.FontSize = 10;
            app.ChannelsLabel.FontColor = [0.9412 0.9412 0.9412];
            app.ChannelsLabel.Position = [145 343 53 22];
            app.ChannelsLabel.Text = 'Channels';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.149 0.149 0.149];
            app.OKButton.FontName = 'Poppins';
            app.OKButton.FontSize = 14;
            app.OKButton.FontWeight = 'bold';
            app.OKButton.FontColor = [0.9412 0.9412 0.9412];
            app.OKButton.Position = [459 321 86 25];
            app.OKButton.Text = 'OK';

            % Create CheckBox_A1
            app.CheckBox_A1 = uicheckbox(app.UIFigure);
            app.CheckBox_A1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_A1ValueChanged, true);
            app.CheckBox_A1.Text = '';
            app.CheckBox_A1.Position = [106 241 25 22];

            % Create CheckBox_A2
            app.CheckBox_A2 = uicheckbox(app.UIFigure);
            app.CheckBox_A2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_A2ValueChanged, true);
            app.CheckBox_A2.Text = '';
            app.CheckBox_A2.Position = [106 110 25 22];

            % Create CheckBox_C1
            app.CheckBox_C1 = uicheckbox(app.UIFigure);
            app.CheckBox_C1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_C1ValueChanged, true);
            app.CheckBox_C1.Text = '';
            app.CheckBox_C1.Position = [390 241 25 22];

            % Create CheckBox_C2
            app.CheckBox_C2 = uicheckbox(app.UIFigure);
            app.CheckBox_C2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_C2ValueChanged, true);
            app.CheckBox_C2.Text = '';
            app.CheckBox_C2.Position = [390 110 25 22];

            % Create CheckBox_D1
            app.CheckBox_D1 = uicheckbox(app.UIFigure);
            app.CheckBox_D1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_D1ValueChanged, true);
            app.CheckBox_D1.Text = '';
            app.CheckBox_D1.Position = [531 241 25 22];

            % Create CheckBox_D2
            app.CheckBox_D2 = uicheckbox(app.UIFigure);
            app.CheckBox_D2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_D2ValueChanged, true);
            app.CheckBox_D2.Text = '';
            app.CheckBox_D2.Position = [531 110 25 22];

            % Create CheckBox_B2
            app.CheckBox_B2 = uicheckbox(app.UIFigure);
            app.CheckBox_B2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_B2ValueChanged, true);
            app.CheckBox_B2.Text = '';
            app.CheckBox_B2.Position = [248 110 25 22];

            % Create CheckBox_B1
            app.CheckBox_B1 = uicheckbox(app.UIFigure);
            app.CheckBox_B1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_B1ValueChanged, true);
            app.CheckBox_B1.Text = '';
            app.CheckBox_B1.Position = [248 241 25 22];

            % Create pathname
            app.pathname = uieditfield(app.UIFigure, 'text');
            app.pathname.FontName = 'Poppins';
            app.pathname.FontSize = 14;
            app.pathname.FontColor = [0.9412 0.9412 0.9412];
            app.pathname.BackgroundColor = [0.149 0.149 0.149];
            app.pathname.Visible = 'off';
            app.pathname.Position = [458 377 87 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = OEphysdlg

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