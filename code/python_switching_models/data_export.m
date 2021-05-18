function data_export(filepath)

data = load(filepath);


move_window = 1;

%% Main Loop

try strcmp(data.meta.subject,'Bx')
    % for each trial, write a csv that is UNITSxTIMESTEPS
    if move_window == 1
        save_folder = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) '_sBins_move_window_only\'];
    else
        save_folder = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\'];
    end
    mkdir(save_folder)
    for iTrial = 1:size(data.data,2)
        if iTrial < 10
            iTrial_string = ['000' num2str(iTrial)];
        elseif iTrial < 100
            iTrial_string = ['00' num2str(iTrial)];
        elseif iTrial < 1000
            iTrial_string = ['0' num2str(iTrial)];
        end
        
        if move_window == 1
            spikecountresamp = data.data(iTrial).spikecountresamp(:,int64(data.data(iTrial).move_relative_to_trial_start):int64(data.data(iTrial).target_reach_relative_to_trial_start));
        else
            spikecountresamp = data.data(iTrial).spikecountresamp;
        end
        filename = [save_folder 'trial' iTrial_string '_spikes.csv'];
        writematrix(spikecountresamp,filename)
        
        % Kinematics
        x_smoothed = data.data(iTrial).x_smoothed;
        y_smoothed = data.data(iTrial).y_smoothed;
        speed = data.data(iTrial).speed;
        filename = [save_folder 'trial' iTrial_string '_kinematics.csv'];
        writematrix(vertcat(x_smoothed,y_smoothed,speed),filename)
        
        % Events
        trial_start_ms = data.data(iTrial).trial_start_ms;
        if strcmp(data.meta.task,'center_out')
            move_relative_to_trial_start = data.data(iTrial).move_relative_to_trial_start + trial_start_ms;
            target_reach_relative_to_trial_start = data.data(iTrial).target_reach_relative_to_trial_start + trial_start_ms;
        end
        filename = [save_folder 'trial' iTrial_string '_events.csv'];
        if strcmp(data.meta.task,'center_out')
            writematrix(vertcat(trial_start_ms,move_relative_to_trial_start,target_reach_relative_to_trial_start),filename)
        else
            writematrix(vertcat(trial_start_ms),filename)
        end
        disp(iTrial)
    end
    % write an additional csv with the meta struct to the same folder.
    data.meta.targets = [];
    if contains(filepath,'optimal')
        data.meta.hn = [];
    end
    writestruct(data.meta,[save_folder 'meta'],"FileType",'xml')
catch
    mkdir(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.subject data.task num2str(data.bin_size) 'sBins\'])
    for iTrial = 1:size(data.data,2)
        if iTrial < 10
            iTrial_string = ['000' num2str(iTrial)];
        elseif iTrial < 100
            iTrial_string = ['00' num2str(iTrial)];
        elseif iTrial < 1000
            iTrial_string = ['0' num2str(iTrial)];
        end
        
        spikecount = data.data(iTrial).spikecount;
        filename = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.subject data.task num2str(data.bin_size) 'sBins\trial' iTrial_string '_spikes.csv'];
        writematrix(spikecount,filename)
        
        % Kinematics
        x_smoothed = data.data(iTrial).x_smoothed;
        y_smoothed = data.data(iTrial).y_smoothed;
        speed = data.data(iTrial).speed;
        filename = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.subject data.task num2str(data.bin_size) 'sBins\trial' iTrial_string '_kinematics.csv'];
        writematrix(vertcat(x_smoothed,y_smoothed,speed),filename)
        
        disp(iTrial)
    end
    % write an additional csv with the meta struct to the same folder.
    writematrix(data.subject,['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.subject data.task num2str(data.bin_size) 'sBins\meta.csv'])
    
end
end