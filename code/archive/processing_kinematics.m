function [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew,data,muscle_lag)

% process Kinematics for HMM comparison

%clear all

% load and import unsorted kinematics
load(subject_filepath,'x','y');

%% bidirectionally filter x and y traces separately

sampling_rate = 500;  
 
dt=1/sampling_rate; % defining timestep size
fN=sampling_rate/2; 
 
fc = 6;
fs = sampling_rate;

[b,a] = butter(6,fc/(fs/2));
 
filt_lowpass_x = normalize(filtfilt(b,a,x(:,2)),'zscore'); % running lowpass filter.
filt_lowpass_y = normalize(filtfilt(b,a,y(:,2)),'zscore'); % running lowpass filter.

%% calculate speed/velocity/acceleration

x_speed = diff(filt_lowpass_x);
y_speed = diff(filt_lowpass_y);

% velocity
velocity = sqrt(x_speed.^2 + y_speed.^2);

% Acceleration
acceleration = diff(velocity);

%% segment position and speed vectors into trials
cpl_st_trial_rew = cpl_st_trial_rew + muscle_lag;
% for each trial
for iTrial = 1:size(cpl_st_trial_rew,1)
    data(iTrial).x_smoothed = filt_lowpass_x(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        %Note: Hacky hack here: there is , for some reason, a difference with this line, causing each trial of y_smoothed to be al ittle
        %longer than the x. Idk why this is; it's the same code.
    %data(iTrial).y_smoothed = filt_lowpass_y(y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).y_smoothed = filt_lowpass_y(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).speed = velocity(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).x_velocity = x_speed(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).y_velocity = y_speed(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).acceleration = acceleration(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).kinematic_timestamps = x((x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2))),1);
end 


% resample from 500hz to 1000hz
for iTrial = 1:size(cpl_st_trial_rew,1)
    data(iTrial).acceleration = repelem(data(iTrial).acceleration,2);
    data(iTrial).x_smoothed = repelem(data(iTrial).x_smoothed,2);
    data(iTrial).y_smoothed = repelem(data(iTrial).y_smoothed,2);
    data(iTrial).speed = repelem(data(iTrial).speed,2);
    data(iTrial).x_velocity = repelem(data(iTrial).x_velocity,2);
    data(iTrial).y_velocity = repelem(data(iTrial).y_velocity,2);
    data(iTrial).kinematic_timestamps = repelem(data(iTrial).kinematic_timestamps,2);
end 

