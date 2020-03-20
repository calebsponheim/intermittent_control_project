clear
%% Analyze Breaux Data
clear

%% User-Defined Variables
subject = 'Bx'; % Subject
arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
session = '190228'; % Which day of data

include_EMG_analysis = 1; % Process EMG data along with kinematics?

% task = 'center_out';       % Choose one of the three options here
task = 'RTP';              % Choose one of the three options here
% task = 'center_out_and_RTP'; % Choose one of the three options here

center_out_trial_window = 'go'; % If center-out, what event to bound analysis window?
crosstrain = 0; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode | 3: both tasks together
num_states_subject = 8; % How many states in the model?
spike_hz_threshold = 0; % Minimum required FR for units?
bad_trials = []; % Any explicitly bad trials to throw out?
seed_to_train = round(abs(randn(1)*1000)); % can manually define the randomization seed for replication 
% seed_to_train = 0239348;

trials_to_plot = 1:2; % Which individual trials to plot
num_segments_to_plot = 100; % How cluttered to make the segment plots

%% Setting Paths
if ispc
    subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
elseif ismac
    subject_filepath_base = ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' session '/'];
end

if strcmp(task,'RTP') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(task,'center_out') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
elseif crosstrain ~= 0
    subject_filepath_RTP = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_filepath_center_out = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
end


%% Structure Spiking Data

if crosstrain > 0
    [data_RTP,cpl_st_trial_rew_RTP,bin_timestamps_RTP] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath_RTP,bad_trials,spike_hz_threshold,'RTP',subject_events,arrays,trial_length,trial_event_cutoff);
    
    [data_center_out,cpl_st_trial_rew_center_out,bin_timestamps_center_out] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath_center_out,bad_trials,spike_hz_threshold,'center_out',subject_events,arrays,trial_length,trial_event_cutoff);
else
    [data,cpl_st_trial_rew,bin_timestamps] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,spike_hz_threshold,task,subject_events,arrays,trial_length,trial_event_cutoff);
end
%%
if crosstrain > 0
    %CO
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data_center_out,2)
        if isempty(data_center_out(iTrial).spikecount)
            bad_trials_CO(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data_center_out(iTrial).spikecount;
            timestamps_temp{trial_count} = bin_timestamps_center_out{iTrial};
            good_trials_CO(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data_center_out = data_temp;
    bin_timestamps_center_out = timestamps_temp;
    clear data_temp
    clear timestamps_temp
    %RTP
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data_RTP,2)
        if isempty(data_RTP(iTrial).spikecount)
            bad_trials_RTP(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data_RTP(iTrial).spikecount;
            timestamps_temp{trial_count} = bin_timestamps_RTP{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data_RTP = data_temp;
    bin_timestamps_RTP = timestamps_temp;
    
else
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data,2)
        if isempty(data(iTrial).spikecount)
            bad_trials(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data(iTrial).spikecount;
            timestamps_temp{trial_count} = bin_timestamps{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data = data_temp;
    bin_timestamps = timestamps_temp;
end

%% Prepare Kinematic Data

if crosstrain == 1 % RTP model, center-out decode
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events,good_trials);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events,good_trials);
elseif crosstrain == 3 % 3: Center-out and RTP together
    [data_RTP] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events,good_trials);
    [data_center_out] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events,good_trials);
else
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials);
end

%%
if crosstrain > 0
else
    clear data_temp
    clear good_trials
    clear timestamps_temp
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data,2)
        if isempty(data(iTrial).x_smoothed)
            bad_trials(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data(iTrial).spikecount;
            data_temp(trial_count).x_smoothed = data(iTrial).x_smoothed;
            data_temp(trial_count).y_smoothed = data(iTrial).y_smoothed;
            data_temp(trial_count).speed = data(iTrial).speed;
            data_temp(trial_count).acceleration = data(iTrial).acceleration;
            data_temp(trial_count).kinematic_timestamps = data(iTrial).kinematic_timestamps;
            
            timestamps_temp{trial_count} = bin_timestamps{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data = data_temp;
    bin_timestamps = timestamps_temp;
end
%% Build and Run Model - log-likelihood

num_states_subject = 16;
TRAIN_PORTION = .5;

rng(5);

for iStatenum = 2:20
    
    num_states_subject = iStatenum;
    for iRepeat = 1:5
        seed_to_train = round(abs(randn(1)*1000));
        [~,~,hn_trained{iStatenum,iRepeat},dc{iStatenum,iRepeat},dc_trainset{iStatenum,iRepeat},~,~] = train_and_decode_HMM(data,num_states_subject,[],[],0,seed_to_train,TRAIN_PORTION);
    end
end
    
save(strcat(subject,task,session,'_HMM_hn_',num2str(num_states_subject),'_states_',date),'hn_trained','dc','dc_trainset')