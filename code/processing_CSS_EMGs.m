function [data] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials)

% process Kinematics for HMM comparison

%clear all

% load and import unsorted kinematics

sampling_rate = 2000; % samples per second

% figure out a way to concatonate the kinematics together; maybe pull from
% the event codes?

%% FIX THIS BULLSHIT
file_list = dir(subject_filepath_base);
file_list = {file_list.name};

if strcmp(task,'RTP')
    EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
elseif strcmp(task,'center_out')
    EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'__emg50to1kN.mat')),'UniformOutput',false);
    block_events_file = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_events.mat')),'UniformOutput',false);
    load(subject_events,'events',['periOn' arrays{1}(1:2) '_30k']);
    trial_start_relative_to_periOn = events(:,1);
    trial_end_relative_to_periOn = events(:,7);
end

trial_start = [];
trial_end = [];
x = [];
y = [];
x_vel = [];
y_vel = [];
t = [];
EMG_signals = {};

if strcmp(task,'RTP')
    if strcmp(arrays{1}(1:2),'PM')
    elseif strcmp(arrays{1}(1:2),'M1')
        for iFile = 1:length(EMG_files)
            load(EMG_files{iFile});
            muscle_names = fieldnames(trialwise_EMG);
            muscle_names = muscle_names(startsWith(muscle_names,['EMG']));
            trial_start = [trial_start [trialwise_EMG.trial_start]];
            trial_end = [trial_end [trialwise_EMG.trial_end]];
            
            for iMuscle = 1:length(muscle_names)
                if iFile == 1
                    EMG_signals{iMuscle} = {trialwise_EMG.(muscle_names{iMuscle})};
                else
                    EMG_signals{iMuscle} = [EMG_signals{iMuscle} {trialwise_EMG.(muscle_names{iMuscle})}];
                end
            end
            %             x = [x {trialwise_EMG.x}]; % CHANGE ME
            clear trialwise_EMG
        end
    end
elseif strcmp(task,'center_out')
    for iFile = 1:length(EMG_files)
        load(EMG_files{iFile});
        load(block_events_file{iFile},'isSuccess');
        %         trial_start = [trial_start [trialwise_kinematics.trial_start]];
        %         trial_end = [trial_end [trialwise_kinematics.trial_end]];
        t = [emgt];
        x = [x mat2cell(emgPERION.xp(:,isSuccess),size(emgPERION.xp(:,isSuccess),1),ones(1,size(kinPERION.xp(:,isSuccess),2)))];
        clear kinPERION;
    end
end

if strcmp(task,'center_out')
    x = cellfun(@(x) (x'),x,'UniformOutput',false);
    y = cellfun(@(x) (x'),y,'UniformOutput',false);
    x_vel = cellfun(@(x) (x'),x_vel,'UniformOutput',false);
    y_vel = cellfun(@(x) (x'),y_vel,'UniformOutput',false);
    t = t/1000;
end
%% segment position and speed vectors into trials
if strcmp(task,'center_out')
    periOn_seconds = periOnM1_30k./30000;
end

cpl_st_trial_rew_EMG = double([trial_start',trial_end'])/sampling_rate;

% for each trial
for iTrial = 1:size(cpl_st_trial_rew,1)
    if strcmp(task,'RTP')
        
        for iMuscle = 1:length(muscle_names)
            data(iTrial).(muscle_names{iMuscle}) = EMG_signals{iMuscle}{iTrial};
        end
        
        data(iTrial).EMG_timestamps = cpl_st_trial_rew(iTrial,1):(1/sampling_rate):cpl_st_trial_rew(iTrial,2);
%         if length(data(iTrial).kinematic_timestamps) ~= length(data(iTrial).x_smoothed)
%             data(iTrial).kinematic_timestamps = cpl_st_trial_rew(iTrial,1):(1/sampling_rate):(cpl_st_trial_rew(iTrial,2)+(1/sampling_rate));
%         end
%         
    elseif strcmp(task,'center_out') && (iTrial <= size(filt_lowpass_x,2))
        
        % put in exception for 180323 here
        if contains(subject_filepath_base,'180323') > 0 && iTrial < size(good_trials,2)
            good_trial_num = good_trials(iTrial);
            data(iTrial).x_smoothed = filt_lowpass_x{good_trial_num}(t >= trial_start_relative_to_periOn(good_trial_num)' & t <= trial_end_relative_to_periOn(good_trial_num)');
            data(iTrial).y_smoothed = filt_lowpass_y{good_trial_num}(t >= trial_start_relative_to_periOn(good_trial_num)' & t <= trial_end_relative_to_periOn(good_trial_num)');
            data(iTrial).speed = velocity{good_trial_num}(t >= trial_start_relative_to_periOn(good_trial_num)' & t <= trial_end_relative_to_periOn(good_trial_num)');
            data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
            data(iTrial).kinematic_timestamps = t(t >= trial_start_relative_to_periOn(good_trial_num)' & t <= trial_end_relative_to_periOn(good_trial_num)') + periOn_seconds(good_trial_num);
        elseif contains(subject_filepath_base,'180323') == 0
            %
            data(iTrial).x_smoothed = filt_lowpass_x{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).y_smoothed = filt_lowpass_y{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).speed = velocity{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
            data(iTrial).kinematic_timestamps = t(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)') + periOn_seconds(iTrial);
        end
    end
end
end
