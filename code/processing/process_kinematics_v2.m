function [data] = process_kinematics_v2(meta,data)
% process Kinematics for HMM comparison
arrays = meta.arrays;
subject_filepath_base = meta.subject_filepath_base;
task = meta.task;
session = meta.session;
subject_events = meta.subject_events;
trial_length = meta.trial_length;
trial_event_cutoff = meta.trial_event_cutoff;
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
    elseif strcmp(trial_event_cutoff,'move')
        trial_start_relative_to_periOn = events(events(:,7)>0,4);
        trial_end_relative_to_periOn = events(events(:,7)>0,7);
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
        if iFile == 1 
            isSuccess = events(:,7) > 0;
        else
            isSuccess = vertcat(isSuccess,(events(:,7) > 0));
        end
        
        x = [x mat2cell(kinPERION.xp(:,(events(:,7) > 0)),size(kinPERION.xp(:,(events(:,7) > 0)),1),ones(1,size(kinPERION.xp(:,(events(:,7) > 0)),2)))];
        y = [y mat2cell(kinPERION.yp(:,(events(:,7) > 0)),size(kinPERION.yp(:,(events(:,7) > 0)),1),ones(1,size(kinPERION.yp(:,(events(:,7) > 0)),2)))];
        x_vel = [x_vel mat2cell(kinPERION.xv(:,(events(:,7) > 0)),size(kinPERION.xv(:,(events(:,7) > 0)),1),ones(1,size(kinPERION.xv(:,(events(:,7) > 0)),2)))];
        y_vel = [y_vel mat2cell(kinPERION.yv(:,(events(:,7) > 0)),size(kinPERION.yv(:,(events(:,7) > 0)),1),ones(1,size(kinPERION.yv(:,(events(:,7) > 0)),2)))];
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

%% Normalizing

[~,C_x,S_x] = normalize([x{:}]);
[~,C_y,S_y] = normalize([y{:}]);
%%

sampling_rate = 2000;

dt=1/sampling_rate; % defining timestep size
fN=sampling_rate/2;

fc = 6;
fs = sampling_rate;

[b,a] = butter(6,fc/(fs/2));

x_normalized = cellfun(@(x) (normalize(x,"center",C_x,"scale",S_x)),x,'UniformOutput',false);
y_normalized = cellfun(@(x) (normalize(x,"center",C_y,"scale",S_y)),y,'UniformOutput',false);

filt_lowpass_x = cellfun(@(x) (filtfilt(b,a,x)),x_normalized,'UniformOutput',false); % running lowpass filter.
filt_lowpass_y = cellfun(@(x) (filtfilt(b,a,x)),y_normalized,'UniformOutput',false); % running lowpass filter.

filt_lowpass_x_vel = cellfun(@(x) (diff(x)),filt_lowpass_x,'UniformOutput',false); % running lowpass filter.
filt_lowpass_y_vel = cellfun(@(x) (diff(x)),filt_lowpass_y,'UniformOutput',false); % running lowpass filter.


% filt_lowpass_x = cellfun(@(x) (filtfilt(b,a,x)),x,'UniformOutput',false); % running lowpass filter.
% filt_lowpass_y = cellfun(@(x) (filtfilt(b,a,x)),y,'UniformOutput',false); % running lowpass filter.
% 
% filt_lowpass_x_vel = cellfun(@(x) (filtfilt(b,a,x)),x_vel,'UniformOutput',false); % running lowpass filter.
% filt_lowpass_y_vel = cellfun(@(x) (filtfilt(b,a,x)),y_vel,'UniformOutput',false); % running lowpass filter.
% 
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
        periOn_seconds = periOnM1_30k./30000;
    end

% for each trial


for iTrial = 1:size(data,2)
    if strcmp(task,'RTP')
        x_temp = filt_lowpass_x{iTrial}(1:2:end);
        data(iTrial).x_smoothed = x_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
        y_temp = filt_lowpass_y{iTrial}(1:2:end);
        data(iTrial).y_smoothed = y_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
        x_velocity_temp = filt_lowpass_x_vel{iTrial}(1:2:end);
        x_velocity_temp = [0 x_velocity_temp];
        data(iTrial).x_velocity = x_velocity_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
        y_velocity_temp = filt_lowpass_y_vel{iTrial}(1:2:end);
        y_velocity_temp = [0 y_velocity_temp];
        data(iTrial).y_velocity = y_velocity_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
        speed_temp = velocity{iTrial}(1:2:end);
        speed_temp = [0 speed_temp];
        data(iTrial).speed = speed_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
        
        %adding acceleration analysis
        data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
        
        data(iTrial).kinematic_timestamps = (data(iTrial).trial_start_ms):1:data(iTrial).trial_end_ms;
        
    elseif strcmp(task,'center_out') && (iTrial <= size(filt_lowpass_x,2))
        
            x_smoothed_2k =  filt_lowpass_x{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' ...
                & t < trial_end_relative_to_periOn(iTrial)');
            data(iTrial).x_smoothed = x_smoothed_2k(1:2:end);
            
            y_smoothed_2k = filt_lowpass_y{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' ...
                & t < trial_end_relative_to_periOn(iTrial)');
            data(iTrial).y_smoothed = y_smoothed_2k(1:2:end);
            
            x_velocity_smoothed_2k =  filt_lowpass_x_vel{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' ...
                & t < trial_end_relative_to_periOn(iTrial)');
            data(iTrial).x_velocity = x_velocity_smoothed_2k(1:2:end);

            y_velocity_smoothed_2k =  filt_lowpass_y_vel{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' ...
            & t < trial_end_relative_to_periOn(iTrial)');
            data(iTrial).y_velocity = y_velocity_smoothed_2k(1:2:end);

            speed_2k =  velocity{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & ...
                t < trial_end_relative_to_periOn(iTrial)');
            data(iTrial).speed = speed_2k(1:2:end);
            
            data(iTrial).acceleration = [0 diff(data(iTrial).speed)];
            
            kinematic_timestamps_2k = t(t >= trial_start_relative_to_periOn(iTrial)' & ...
                t < trial_end_relative_to_periOn(iTrial)') + periOn_seconds(iTrial);
            data(iTrial).kinematic_timestamps = kinematic_timestamps_2k(1:2:end)*1000;
    end
end
end
