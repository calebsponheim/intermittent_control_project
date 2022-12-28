function data_export(filepath)

data = load(filepath);
if contains(filepath,'(Work)')
    filepath_base = 'C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\';
else
    filepath_base = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\';
end
if contains(filepath,'RSCO')
    data.subject = 'RS';
    data.task = 'CO';
elseif contains(filepath,'Bx18CO')
    data.subject = 'Bx18';
    data.task = 'CO';
    data.bin_size = data.meta.bin_size;
elseif contains(filepath,'Bxcenter_out')
    data.subject = 'Bx';
    data.task = 'CO';
    data.bin_size = data.meta.bin_size;
end
if contains(filepath,'move')
    move_window = 1;
else
    move_window = 0;
end
%% Main Loop


% There's something going on with RS timestamps and their format and
% scaling.
if move_window == 1
    mkdir([filepath_base data.subject data.task '_move_window' num2str(data.bin_size) 'sBins\'])
else
    mkdir([filepath_base data.subject data.task num2str(data.bin_size) 'sBins\'])
end
for iTrial = 1:size(data.data,2)
    if iTrial < 10
        iTrial_string = ['000' num2str(iTrial)];
    elseif iTrial < 100
        iTrial_string = ['00' num2str(iTrial)];
    elseif iTrial < 1000
        iTrial_string = ['0' num2str(iTrial)];
    end

    spikecount = data.data(iTrial).spikecount;
    if move_window == 1
        filename = [filepath_base data.subject data.task '_move_window' num2str(data.bin_size) 'sBins\trial' iTrial_string '_spikes.csv'];
    else
        filename = [filepath_base data.subject data.task num2str(data.bin_size) 'sBins\trial' iTrial_string '_spikes.csv'];
    end
    writematrix(spikecount,filename)

    % Kinematics
    x_smoothed = data.data(iTrial).x_smoothed;
    y_smoothed = data.data(iTrial).y_smoothed;
    x_velocity = data.data(iTrial).x_velocity;
    y_velocity = data.data(iTrial).y_velocity;
    acceleration = data.data(iTrial).acceleration;
    if move_window == 1
        filename = [filepath_base data.subject data.task '_move_window' num2str(data.bin_size) 'sBins\trial' iTrial_string '_kinematics.csv'];
    else
        filename = [filepath_base data.subject data.task num2str(data.bin_size) 'sBins\trial' iTrial_string '_kinematics.csv'];
    end
    if contains(data.subject,'Bx')
        writematrix(horzcat(x_smoothed',y_smoothed',x_velocity',y_velocity',acceleration'),filename)
    else
        writematrix(horzcat(x_smoothed,y_smoothed,x_velocity,y_velocity,acceleration),filename)
    end

    disp(iTrial)
end
% write an additional csv with the meta struct to the same folder.
if move_window == 1
    writematrix(data.subject,[filepath_base data.subject data.task '_move_window' num2str(data.bin_size) 'sBins\meta.csv'])
else
    writematrix(data.subject,[filepath_base data.subject data.task num2str(data.bin_size) 'sBins\meta.csv'])
end
end