function data_export(filepath)

data = load(filepath);

%% Main Loop

% for each trial, write a csv that is UNITSxTIMESTEPS
mkdir(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\'])
for iTrial = 1:size(data.data,2)
    spikecountresamp = data.data(iTrial).spikecountresamp; 
    filename = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\trial' num2str(iTrial) '_spikes.csv'];
    writematrix(spikecountresamp,filename)
    
    % Kinematics
    x_smoothed = data.data(iTrial).x_smoothed; 
    y_smoothed = data.data(iTrial).y_smoothed;
    speed = data.data(iTrial).speed;
    filename = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\trial' num2str(iTrial) '_kinematics.csv'];
    writematrix(vertcat(x_smoothed,y_smoothed,speed),filename)
    
    % Events
    trial_start_ms = data.data(iTrial).trial_start_ms;
    move_relative_to_trial_start = data.data(iTrial).move_relative_to_trial_start + trial_start_ms;
    target_reach_relative_to_trial_start = data.data(iTrial).target_reach_relative_to_trial_start + trial_start_ms;
    filename = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\trial' num2str(iTrial) '_events.csv'];
    writematrix(vertcat(trial_start_ms,move_relative_to_trial_start,target_reach_relative_to_trial_start),filename)
    
    disp(iTrial)
end
% write an additional csv with the meta struct to the same folder.
data.meta.targets = [];
writestruct(data.meta,['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\' data.meta.subject data.meta.task data.meta.session num2str(data.meta.bin_size) 'sBins\meta'],'FileType','xml')
end