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
 
filt_lowpass_x = filtfilt(b,a,x(:,2)); % running lowpass filter.
filt_lowpass_y = filtfilt(b,a,y(:,2)); % running lowpass filter.

%% calculate speed/velocity/acceleration

x_speed = diff(filt_lowpass_x);
y_speed = diff(filt_lowpass_y);

% velocity
velocity = sqrt(x_speed.^2 + y_speed.^2);

% Acceleration
acceleration = diff(velocity);

%% segment position and speed vectors into trials

% for each trial
for iTrial = 1:size(cpl_st_trial_rew,1)
    data(iTrial).x_smoothed = filt_lowpass_x(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        %Note: Hacky hack here: there is , for some reason, a difference with this line, causing each trial of y_smoothed to be al ittle
        %longer than the x. Idk why this is; it's the same code.
    %data(iTrial).y_smoothed = filt_lowpass_y(y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).y_smoothed = filt_lowpass_y(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).speed = velocity(y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2)));
    data(iTrial).kinematic_timestamps = x((y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2))),1);
end 
