classdef Quattrodlg < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        pathname            matlab.ui.control.EditField
        CheckBox_M4         matlab.ui.control.CheckBox
        CheckBox_M3         matlab.ui.control.CheckBox
        CheckBox_M2         matlab.ui.control.CheckBox
        CheckBox_M1         matlab.ui.control.CheckBox
        CheckBox_S2         matlab.ui.control.CheckBox
        CheckBox_S1         matlab.ui.control.CheckBox
        OKButton            matlab.ui.control.Button
        ChannelsLabel       matlab.ui.control.Label
        EditField_nchan     matlab.ui.control.NumericEditField
        Lamp_M4             matlab.ui.control.Lamp
        Lamp_M3             matlab.ui.control.Lamp
        Lamp_M2             matlab.ui.control.Lamp
        Lamp_M1             matlab.ui.control.Lamp
        Lamp_S2             matlab.ui.control.Lamp
        Lamp_S1             matlab.ui.control.Lamp
        Image               matlab.ui.control.Image
        MI4Panel            matlab.ui.container.Panel
        MusclenameLabel_M4  matlab.ui.control.Label
        ArraytypeLabel_M4   matlab.ui.control.Label
        EditField_M4        matlab.ui.control.EditField
        DropDown_M4         matlab.ui.control.DropDown
        MI3Panel            matlab.ui.container.Panel
        MusclenameLabel_M3  matlab.ui.control.Label
        ArraytypeLabel_M3   matlab.ui.control.Label
        EditField_M3        matlab.ui.control.EditField
        DropDown_M3         matlab.ui.control.DropDown
        MI2Panel            matlab.ui.container.Panel
        MusclenameLabel_M2  matlab.ui.control.Label
        ArraytypeLabel_M2   matlab.ui.control.Label
        EditField_M2        matlab.ui.control.EditField
        DropDown_M2         matlab.ui.control.DropDown
        MI1Panel            matlab.ui.container.Panel
        MusclenameLabel_M1  matlab.ui.control.Label
        ArraytypeLabel_M1   matlab.ui.control.Label
        EditField_M1        matlab.ui.control.EditField
        DropDown_M1         matlab.ui.control.DropDown
        Splitter2Panel      matlab.ui.container.Panel
        MusclenameLabel_S2  matlab.ui.control.Label
        ArraytypeLabel_S2   matlab.ui.control.Label
        EditField_S2        matlab.ui.control.EditField
        DropDown_S2         matlab.ui.control.DropDown
        Splitter1Panel      matlab.ui.container.Panel
        MusclenameLabel_S1  matlab.ui.control.Label
        ArraytypeLabel_S1   matlab.ui.control.Label
        EditField_S1        matlab.ui.control.EditField
        DropDown_S1         matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        file % File to update with the configuration
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            app.file = load(app.pathname.Value);
            
            ports(1) = app.CheckBox_S1.Value;
            ports(2) = app.CheckBox_S2.Value;
            ports(3) = app.CheckBox_M1.Value;
            ports(4) = app.CheckBox_M2.Value;
            ports(5) = app.CheckBox_M3.Value;
            ports(6) = app.CheckBox_M4.Value;

            app.file.signal.ngrid = sum(ports);
            
            grid{1} = app.DropDown_S1.Value;
            grid{2} = app.DropDown_S2.Value;
            grid{3} = app.DropDown_M1.Value;
            grid{4} = app.DropDown_M2.Value;
            grid{5} = app.DropDown_M3.Value;
            grid{6} = app.DropDown_M4.Value;

            muscle{1} = app.EditField_S1.Value;
            muscle{2} = app.EditField_S2.Value;
            muscle{3} = app.EditField_M1.Value;
            muscle{4} = app.EditField_M2.Value;
            muscle{5} = app.EditField_M3.Value;
            muscle{6} = app.EditField_M4.Value;

            idxports = find(ports == 1);
            for i = 1:app.file.signal.ngrid
                app.file.signal.gridname{i} = grid{idxports(i)};
                app.file.signal.muscle{i} = muscle{idxports(i)};
            end

            signal = app.file.signal;
            save(app.pathname.Value, 'signal', '-v7.3');
            delete(app.UIFigure)
        end

        % Value changed function: CheckBox_S1
        function CheckBox_S1ValueChanged(app, event)
            if app.CheckBox_S1.Value
                app.Lamp_S1.Color = 'Green';
                app.PortS1Panel.Enable = "on";
            else
                app.Lamp_S1.Color = 'Red';
                app.PortS1Panel.Enable = "off";
            end                        
        end

        % Value changed function: CheckBox_S2
        function CheckBox_S2ValueChanged(app, event)
            if app.CheckBox_S2.Value
                app.Lamp_S2.Color = 'Green';
                app.PortS2Panel.Enable = "on";
            else
                app.Lamp_S2.Color = 'Red';
                app.PortS2Panel.Enable = "off";
            end                                    
        end

        % Value changed function: CheckBox_M1
        function CheckBox_M1ValueChanged(app, event)
            if app.CheckBox_M1.Value
                app.Lamp_M1.Color = 'Green';
                app.PortM1Panel.Enable = "on";
            else
                app.Lamp_M1.Color = 'Red';
                app.PortM1Panel.Enable = "off";
            end                                    
        end

        % Value changed function: CheckBox_M2
        function CheckBox_M2ValueChanged(app, event)
            if app.CheckBox_M2.Value
                app.Lamp_M2.Color = 'Green';
                app.PortM2Panel.Enable = "on";
            else
                app.Lamp_M2.Color = 'Red';
                app.PortM2Panel.Enable = "off";
            end                                                
        end

        % Value changed function: CheckBox_M3
        function CheckBox_M3ValueChanged(app, event)
            if app.CheckBox_M3.Value
                app.Lamp_M3.Color = 'Green';
                app.PortM3Panel.Enable = "on";
            else
                app.Lamp_M3.Color = 'Red';
                app.PortM3Panel.Enable = "off";
            end                                                            
        end

        % Value changed function: CheckBox_M4
        function CheckBox_M4ValueChanged(app, event)
            if app.CheckBox_M4.Value
                app.Lamp_M4.Color = 'Green';
                app.PortM4Panel.Enable = "on";
            else
                app.Lamp_M4.Color = 'Red';
                app.PortM4Panel.Enable = "off";
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

            % Create Splitter1Panel
            app.Splitter1Panel = uipanel(app.UIFigure);
            app.Splitter1Panel.Enable = 'off';
            app.Splitter1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Splitter1Panel.TitlePosition = 'centertop';
            app.Splitter1Panel.Title = 'Splitter #1';
            app.Splitter1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.Splitter1Panel.FontName = 'Poppins';
            app.Splitter1Panel.FontWeight = 'bold';
            app.Splitter1Panel.FontSize = 14;
            app.Splitter1Panel.Position = [143 138 125 125];

            % Create DropDown_S1
            app.DropDown_S1 = uidropdown(app.Splitter1Panel);
            app.DropDown_S1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_S1.FontName = 'Poppins';
            app.DropDown_S1.FontSize = 10;
            app.DropDown_S1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_S1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_S1.Position = [7 56 111 22];
            app.DropDown_S1.Value = 'GR04MM1305';

            % Create EditField_S1
            app.EditField_S1 = uieditfield(app.Splitter1Panel, 'text');
            app.EditField_S1.FontName = 'Poppins';
            app.EditField_S1.FontSize = 10;
            app.EditField_S1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_S1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_S1.Position = [7 6 111 22];

            % Create ArraytypeLabel_S1
            app.ArraytypeLabel_S1 = uilabel(app.Splitter1Panel);
            app.ArraytypeLabel_S1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_S1.FontName = 'Poppins';
            app.ArraytypeLabel_S1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_S1.Position = [32 79 67 22];
            app.ArraytypeLabel_S1.Text = 'Array type';

            % Create MusclenameLabel_S1
            app.MusclenameLabel_S1 = uilabel(app.Splitter1Panel);
            app.MusclenameLabel_S1.HorizontalAlignment = 'center';
            app.MusclenameLabel_S1.FontName = 'Poppins';
            app.MusclenameLabel_S1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_S1.Position = [20 28 86 22];
            app.MusclenameLabel_S1.Text = 'Muscle name';

            % Create Splitter2Panel
            app.Splitter2Panel = uipanel(app.UIFigure);
            app.Splitter2Panel.Enable = 'off';
            app.Splitter2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.Splitter2Panel.TitlePosition = 'centertop';
            app.Splitter2Panel.Title = 'Splitter #2';
            app.Splitter2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.Splitter2Panel.FontName = 'Poppins';
            app.Splitter2Panel.FontWeight = 'bold';
            app.Splitter2Panel.FontSize = 14;
            app.Splitter2Panel.Position = [285 138 125 125];

            % Create DropDown_S2
            app.DropDown_S2 = uidropdown(app.Splitter2Panel);
            app.DropDown_S2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_S2.FontName = 'Poppins';
            app.DropDown_S2.FontSize = 10;
            app.DropDown_S2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_S2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_S2.Position = [7 56 111 22];
            app.DropDown_S2.Value = 'GR04MM1305';

            % Create EditField_S2
            app.EditField_S2 = uieditfield(app.Splitter2Panel, 'text');
            app.EditField_S2.FontName = 'Poppins';
            app.EditField_S2.FontSize = 10;
            app.EditField_S2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_S2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_S2.Position = [7 6 111 22];

            % Create ArraytypeLabel_S2
            app.ArraytypeLabel_S2 = uilabel(app.Splitter2Panel);
            app.ArraytypeLabel_S2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_S2.FontName = 'Poppins';
            app.ArraytypeLabel_S2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_S2.Position = [32 79 67 22];
            app.ArraytypeLabel_S2.Text = 'Array type';

            % Create MusclenameLabel_S2
            app.MusclenameLabel_S2 = uilabel(app.Splitter2Panel);
            app.MusclenameLabel_S2.HorizontalAlignment = 'center';
            app.MusclenameLabel_S2.FontName = 'Poppins';
            app.MusclenameLabel_S2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_S2.Position = [20 28 86 22];
            app.MusclenameLabel_S2.Text = 'Muscle name';

            % Create MI1Panel
            app.MI1Panel = uipanel(app.UIFigure);
            app.MI1Panel.Enable = 'off';
            app.MI1Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.MI1Panel.TitlePosition = 'centertop';
            app.MI1Panel.Title = 'MI #1';
            app.MI1Panel.BackgroundColor = [0.149 0.149 0.149];
            app.MI1Panel.FontName = 'Poppins';
            app.MI1Panel.FontWeight = 'bold';
            app.MI1Panel.FontSize = 14;
            app.MI1Panel.Position = [1 7 125 125];

            % Create DropDown_M1
            app.DropDown_M1 = uidropdown(app.MI1Panel);
            app.DropDown_M1.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_M1.FontName = 'Poppins';
            app.DropDown_M1.FontSize = 10;
            app.DropDown_M1.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_M1.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_M1.Position = [7 56 111 22];
            app.DropDown_M1.Value = 'GR04MM1305';

            % Create EditField_M1
            app.EditField_M1 = uieditfield(app.MI1Panel, 'text');
            app.EditField_M1.FontName = 'Poppins';
            app.EditField_M1.FontSize = 10;
            app.EditField_M1.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_M1.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_M1.Position = [7 6 111 22];

            % Create ArraytypeLabel_M1
            app.ArraytypeLabel_M1 = uilabel(app.MI1Panel);
            app.ArraytypeLabel_M1.HorizontalAlignment = 'center';
            app.ArraytypeLabel_M1.FontName = 'Poppins';
            app.ArraytypeLabel_M1.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_M1.Position = [32 79 67 22];
            app.ArraytypeLabel_M1.Text = 'Array type';

            % Create MusclenameLabel_M1
            app.MusclenameLabel_M1 = uilabel(app.MI1Panel);
            app.MusclenameLabel_M1.HorizontalAlignment = 'center';
            app.MusclenameLabel_M1.FontName = 'Poppins';
            app.MusclenameLabel_M1.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_M1.Position = [20 28 86 22];
            app.MusclenameLabel_M1.Text = 'Muscle name';

            % Create MI2Panel
            app.MI2Panel = uipanel(app.UIFigure);
            app.MI2Panel.Enable = 'off';
            app.MI2Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.MI2Panel.TitlePosition = 'centertop';
            app.MI2Panel.Title = 'MI #2';
            app.MI2Panel.BackgroundColor = [0.149 0.149 0.149];
            app.MI2Panel.FontName = 'Poppins';
            app.MI2Panel.FontWeight = 'bold';
            app.MI2Panel.FontSize = 14;
            app.MI2Panel.Position = [143 7 125 125];

            % Create DropDown_M2
            app.DropDown_M2 = uidropdown(app.MI2Panel);
            app.DropDown_M2.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_M2.FontName = 'Poppins';
            app.DropDown_M2.FontSize = 10;
            app.DropDown_M2.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_M2.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_M2.Position = [7 56 111 22];
            app.DropDown_M2.Value = 'GR04MM1305';

            % Create EditField_M2
            app.EditField_M2 = uieditfield(app.MI2Panel, 'text');
            app.EditField_M2.FontName = 'Poppins';
            app.EditField_M2.FontSize = 10;
            app.EditField_M2.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_M2.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_M2.Position = [7 6 111 22];

            % Create ArraytypeLabel_M2
            app.ArraytypeLabel_M2 = uilabel(app.MI2Panel);
            app.ArraytypeLabel_M2.HorizontalAlignment = 'center';
            app.ArraytypeLabel_M2.FontName = 'Poppins';
            app.ArraytypeLabel_M2.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_M2.Position = [32 79 67 22];
            app.ArraytypeLabel_M2.Text = 'Array type';

            % Create MusclenameLabel_M2
            app.MusclenameLabel_M2 = uilabel(app.MI2Panel);
            app.MusclenameLabel_M2.HorizontalAlignment = 'center';
            app.MusclenameLabel_M2.FontName = 'Poppins';
            app.MusclenameLabel_M2.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_M2.Position = [20 28 86 22];
            app.MusclenameLabel_M2.Text = 'Muscle name';

            % Create MI3Panel
            app.MI3Panel = uipanel(app.UIFigure);
            app.MI3Panel.Enable = 'off';
            app.MI3Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.MI3Panel.TitlePosition = 'centertop';
            app.MI3Panel.Title = 'MI #3';
            app.MI3Panel.BackgroundColor = [0.149 0.149 0.149];
            app.MI3Panel.FontName = 'Poppins';
            app.MI3Panel.FontWeight = 'bold';
            app.MI3Panel.FontSize = 14;
            app.MI3Panel.Position = [285 7 125 125];

            % Create DropDown_M3
            app.DropDown_M3 = uidropdown(app.MI3Panel);
            app.DropDown_M3.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_M3.FontName = 'Poppins';
            app.DropDown_M3.FontSize = 10;
            app.DropDown_M3.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_M3.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_M3.Position = [7 56 111 22];
            app.DropDown_M3.Value = 'GR04MM1305';

            % Create EditField_M3
            app.EditField_M3 = uieditfield(app.MI3Panel, 'text');
            app.EditField_M3.FontName = 'Poppins';
            app.EditField_M3.FontSize = 10;
            app.EditField_M3.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_M3.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_M3.Position = [7 6 111 22];

            % Create ArraytypeLabel_M3
            app.ArraytypeLabel_M3 = uilabel(app.MI3Panel);
            app.ArraytypeLabel_M3.HorizontalAlignment = 'center';
            app.ArraytypeLabel_M3.FontName = 'Poppins';
            app.ArraytypeLabel_M3.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_M3.Position = [32 79 67 22];
            app.ArraytypeLabel_M3.Text = 'Array type';

            % Create MusclenameLabel_M3
            app.MusclenameLabel_M3 = uilabel(app.MI3Panel);
            app.MusclenameLabel_M3.HorizontalAlignment = 'center';
            app.MusclenameLabel_M3.FontName = 'Poppins';
            app.MusclenameLabel_M3.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_M3.Position = [20 28 86 22];
            app.MusclenameLabel_M3.Text = 'Muscle name';

            % Create MI4Panel
            app.MI4Panel = uipanel(app.UIFigure);
            app.MI4Panel.Enable = 'off';
            app.MI4Panel.ForegroundColor = [0.9412 0.9412 0.9412];
            app.MI4Panel.TitlePosition = 'centertop';
            app.MI4Panel.Title = 'MI #4';
            app.MI4Panel.BackgroundColor = [0.149 0.149 0.149];
            app.MI4Panel.FontName = 'Poppins';
            app.MI4Panel.FontWeight = 'bold';
            app.MI4Panel.FontSize = 14;
            app.MI4Panel.Position = [426 7 125 125];

            % Create DropDown_M4
            app.DropDown_M4 = uidropdown(app.MI4Panel);
            app.DropDown_M4.Items = {'GR04MM1305', 'GR08MM1305', 'GR10MM0808', 'HD04MM1305', 'HD08MM1305', 'HD10MM0808', 'GR10MM0804', 'HD10MM0804', 'MYOMRF-4x8', 'MYOMNP-1x32'};
            app.DropDown_M4.FontName = 'Poppins';
            app.DropDown_M4.FontSize = 10;
            app.DropDown_M4.FontColor = [0.9412 0.9412 0.9412];
            app.DropDown_M4.BackgroundColor = [0.149 0.149 0.149];
            app.DropDown_M4.Position = [7 56 111 22];
            app.DropDown_M4.Value = 'GR04MM1305';

            % Create EditField_M4
            app.EditField_M4 = uieditfield(app.MI4Panel, 'text');
            app.EditField_M4.FontName = 'Poppins';
            app.EditField_M4.FontSize = 10;
            app.EditField_M4.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_M4.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_M4.Position = [7 6 111 22];

            % Create ArraytypeLabel_M4
            app.ArraytypeLabel_M4 = uilabel(app.MI4Panel);
            app.ArraytypeLabel_M4.HorizontalAlignment = 'center';
            app.ArraytypeLabel_M4.FontName = 'Poppins';
            app.ArraytypeLabel_M4.FontColor = [0.9412 0.9412 0.9412];
            app.ArraytypeLabel_M4.Position = [32 79 67 22];
            app.ArraytypeLabel_M4.Text = 'Array type';

            % Create MusclenameLabel_M4
            app.MusclenameLabel_M4 = uilabel(app.MI4Panel);
            app.MusclenameLabel_M4.HorizontalAlignment = 'center';
            app.MusclenameLabel_M4.FontName = 'Poppins';
            app.MusclenameLabel_M4.FontColor = [0.9412 0.9412 0.9412];
            app.MusclenameLabel_M4.Position = [20 28 86 22];
            app.MusclenameLabel_M4.Text = 'Muscle name';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [5 274 405 118];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'Quattrocento.jpg');

            % Create Lamp_S1
            app.Lamp_S1 = uilamp(app.UIFigure);
            app.Lamp_S1.Position = [92 329 20 20];
            app.Lamp_S1.Color = [1 0 0];

            % Create Lamp_S2
            app.Lamp_S2 = uilamp(app.UIFigure);
            app.Lamp_S2.Position = [236 329 20 20];
            app.Lamp_S2.Color = [1 0 0];

            % Create Lamp_M1
            app.Lamp_M1 = uilamp(app.UIFigure);
            app.Lamp_M1.Position = [56 277 20 20];
            app.Lamp_M1.Color = [1 0 0];

            % Create Lamp_M2
            app.Lamp_M2 = uilamp(app.UIFigure);
            app.Lamp_M2.Position = [128 277 20 20];
            app.Lamp_M2.Color = [1 0 0];

            % Create Lamp_M3
            app.Lamp_M3 = uilamp(app.UIFigure);
            app.Lamp_M3.Position = [199 277 20 20];
            app.Lamp_M3.Color = [1 0 0];

            % Create Lamp_M4
            app.Lamp_M4 = uilamp(app.UIFigure);
            app.Lamp_M4.Position = [270 277 20 20];
            app.Lamp_M4.Color = [1 0 0];

            % Create EditField_nchan
            app.EditField_nchan = uieditfield(app.UIFigure, 'numeric');
            app.EditField_nchan.HorizontalAlignment = 'center';
            app.EditField_nchan.FontName = 'Poppins';
            app.EditField_nchan.FontSize = 10;
            app.EditField_nchan.FontWeight = 'bold';
            app.EditField_nchan.FontColor = [0.9412 0.9412 0.9412];
            app.EditField_nchan.BackgroundColor = [0.149 0.149 0.149];
            app.EditField_nchan.Position = [335 321 41 22];

            % Create ChannelsLabel
            app.ChannelsLabel = uilabel(app.UIFigure);
            app.ChannelsLabel.HorizontalAlignment = 'center';
            app.ChannelsLabel.FontName = 'Poppins';
            app.ChannelsLabel.FontSize = 10;
            app.ChannelsLabel.FontColor = [0.9412 0.9412 0.9412];
            app.ChannelsLabel.Position = [330 342 53 22];
            app.ChannelsLabel.Text = 'Channels';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.149 0.149 0.149];
            app.OKButton.FontName = 'Poppins';
            app.OKButton.FontSize = 14;
            app.OKButton.FontWeight = 'bold';
            app.OKButton.FontColor = [0.9412 0.9412 0.9412];
            app.OKButton.Position = [407 320 136 25];
            app.OKButton.Text = 'OK';

            % Create CheckBox_S1
            app.CheckBox_S1 = uicheckbox(app.UIFigure);
            app.CheckBox_S1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_S1ValueChanged, true);
            app.CheckBox_S1.Text = '';
            app.CheckBox_S1.Position = [248 241 25 22];

            % Create CheckBox_S2
            app.CheckBox_S2 = uicheckbox(app.UIFigure);
            app.CheckBox_S2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_S2ValueChanged, true);
            app.CheckBox_S2.Text = '';
            app.CheckBox_S2.Position = [391 241 25 22];

            % Create CheckBox_M1
            app.CheckBox_M1 = uicheckbox(app.UIFigure);
            app.CheckBox_M1.ValueChangedFcn = createCallbackFcn(app, @CheckBox_M1ValueChanged, true);
            app.CheckBox_M1.Text = '';
            app.CheckBox_M1.Position = [106 109 25 22];

            % Create CheckBox_M2
            app.CheckBox_M2 = uicheckbox(app.UIFigure);
            app.CheckBox_M2.ValueChangedFcn = createCallbackFcn(app, @CheckBox_M2ValueChanged, true);
            app.CheckBox_M2.Text = '';
            app.CheckBox_M2.Position = [248 109 25 22];

            % Create CheckBox_M3
            app.CheckBox_M3 = uicheckbox(app.UIFigure);
            app.CheckBox_M3.ValueChangedFcn = createCallbackFcn(app, @CheckBox_M3ValueChanged, true);
            app.CheckBox_M3.Text = '';
            app.CheckBox_M3.Position = [391 109 25 22];

            % Create CheckBox_M4
            app.CheckBox_M4 = uicheckbox(app.UIFigure);
            app.CheckBox_M4.ValueChangedFcn = createCallbackFcn(app, @CheckBox_M4ValueChanged, true);
            app.CheckBox_M4.Text = '';
            app.CheckBox_M4.Position = [531 109 25 22];

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
        function app = Quattrodlg

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