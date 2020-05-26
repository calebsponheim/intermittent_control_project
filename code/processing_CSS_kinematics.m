function [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials,trial_length,trial_event_cutoff)
% process Kinematics for HMM comparison

%%
file_list = dir(subject_filepath_base);
file_list = {file_list.name};

if strcmp(task,'RTP')
    PM_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
    M1_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'RTP_kinematics')),'UniformOutput',false);
elseif strcmp(task,'center_out')
    kinematic_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_kinematics.mat')),'UniformOutput',false);
    block_events_file = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_events.mat')),'UniformOutput',false);
    load(subject_events,'events',['periOn' arrays{1}(1:2) '_30k'],'isSuccess');
    trial_start_relative_to_periOn = events(events(:,7)>0,1);
    trial_end_relative_to_periOn = events(events(:,7)>0,7);
    if strcmp(trial_event_cutoff,'')
        trial_start_relative_to_periOn(:) = trial_length(1);
        trial_end_relative_to_periOn(:) = trial_length(2);
    end
end

trial_start = [];
trial_end = [];
x = [];
y = [];
x_vel = [];
y_vel = [];
t = [];

if strcmp(task,'RTP')
    if strcmp(arrays{1}(1:2),'PM')
        for iFile = 1:length(PM_files)
            load(PM_files{iFile});
            trial_start = [trial_start [trialwise_EMGs.trial_start]];
            trial_end = [trial_end [trialwise_EMGs.trial_end]];
            x = [x {trialwise_EMGs.x}];
            y = [y {trialwise_EMGs.y}];
            x_vel = [x_vel {trialwise_EMGs.x_vel}];
            y_vel = [y_vel {trialwise_EMGs.y_vel}];
            clear trialwise_EMGs
        end
    elseif strcmp(arrays{1}(1:2),'M1')
        for iFile = 1:length(M1_files)
            load(M1_files{iFile});
            trial_start = [trial_start [trialwise_kinematics.trial_start]];
            trial_end = [trial_end [trialwise_kinematics.trial_end]];
            x = [x {trialwise_kinematics.x}];
            y = [y {trialwise_kinematics.y}];
            x_vel = [x_vel {trialwise_kinematics.x_vel}];
            y_vel = [y_vel {trialwise_kinematics.y_vel}];
            clear trialwise_kinematics
        end
    end
elseif strcmp(task,'center_out')
    for iFile = 1:length(kinematic_files)
        load(kinematic_files{iFile},'kinPERION');
        load(block_events_file{iFile},'events');
        %         trial_start = [trial_start [trialwise_kinematics.trial_start]];
        %         trial_end = [trial_end [trialwise_kinematics.trial_end]];
        t = [kinPERION.t];
        isSuccess = events(:,7) > 0;
        x = [x mat2cell(kinPERION.xp(:,isSuccess),size(kinPERION.xp(:,isSuccess),1),ones(1,size(kinPERION.xp(:,isSuccess),2)))];
        y = [y mat2cell(kinPERION.yp(:,isSuccess),size(kinPERION.yp(:,isSuccess),1),ones(1,size(kinPERION.yp(:,isSuccess),2)))];
        x_vel = [x_vel mat2cell(kinPERION.xv(:,isSuccess),size(kinPERION.xv(:,isSuccess),1),ones(1,size(kinPERION.xv(:,isSuccess),2)))];
        y_vel = [y_vel mat2cell(kinPERION.yv(:,isSuccess),size(kinPERION.yv(:,isSuccess),1),ones(1,size(kinPERION.yv(:,isSuccess),2)))];
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
%% bidirectionally filter x and y traces separately

sampling_rate = 2000;

dt=1/sampling_rate; % defining timestep size
fN=sampling_rate/2;

fc = 6;
fs = sampling_rate;

[b,a] = butter(6,fc/(fs/2));

filt_lowpass_x = cellfun(@(x) (filtfilt(b,a,x)),x,'UniformOutput',false); % running lowpass filter.
filt_lowpass_y = cellfun(@(x) (filtfilt(b,a,x)),y,'UniformOutput',false); % running lowpass filter.

filt_lowpass_x_vel = cellfun(@(x) (filtfilt(b,a,x)),x_vel,'UniformOutput',false); % running lowpass filter.
filt_lowpass_y_vel = cellfun(@(x) (filtfilt(b,a,x)),y_vel,'UniformOutput',false); % running lowpass filter.

%% calculate speed/velocity/acceleration

% x_speed = diff(filt_lowpass_x);
% y_speed = diff(filt_lowpass_y);
%
% % velocity
velocity = cellfun(@(x,y) (sqrt(x.^2 + y.^2)),filt_lowpass_x_vel,filt_lowpass_y_vel,'UniformOutput',false);
%
% % Acceleration
% acceleration = diff(velocity);

%% segment position and speed vectors into trials
    if strcmp(task,'center_out')
        periOn_seconds = periOnM1_30k(isSuccess)./30000;
    end

% for each trial


for iTrial = 1:size(cpl_st_trial_rew,1)
    if strcmp(task,'RTP')
        data(iTrial).x_smoothed = filt_lowpass_x{iTrial};
        data(iTrial).y_smoothed = filt_lowpass_y{iTrial};
        data(iTrial).speed = velocity{iTrial};
        
        %adding acceleration analysis
        data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
        
        data(iTrial).kinematic_timestamps = cpl_st_trial_rew(iTrial,1):(1/sampling_rate):cpl_st_trial_rew(iTrial,2);
        if length(data(iTrial).kinematic_timestamps) ~= length(data(iTrial).x_smoothed)
            data(iTrial).kinematic_timestamps = cpl_st_trial_rew(iTrial,1):(1/sampling_rate):(cpl_st_trial_rew(iTrial,2)+(1/sampling_rate));
        end
        
    elseif strcmp(task,'center_out') && (iTrial <= size(filt_lowpass_x,2))
        
        % put in exception for 180323 here
        if contains(subject_filepath_base,'180323') > 0% && iTrial < size(good_trials,2)
            %good_trial_num = good_trials(iTrial);
            data(iTrial).x_smoothed = filt_lowpass_x{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).y_smoothed = filt_lowpass_y{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).speed = velocity{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
            data(iTrial).kinematic_timestamps = t(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)') + periOn_seconds(iTrial);
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
