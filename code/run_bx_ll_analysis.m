%% Analyze Breaux Data
clear

subject = 'Bx';
arrays = {'M1m';'M1l'};
% arrays = {'M1m'};
session = '190227';
subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
% subject_filepath_base = 'C:\Users\calebsponheim\Documents\Data\190228\';
task = 'center_out';
% task = 'RTP';

crosstrain = 0; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode

if strcmp(task,'RTP') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(task,'center_out') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = 'go'; % supersedes trial_length if active
end

spike_hz_threshold = 0;
bad_trials = [];

% Scripts to run:

%% Structure Spiking Data

    [data,cpl_st_trial_rew,bin_timestamps] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,spike_hz_threshold,task,subject_events,arrays,trial_length,trial_event_cutoff);
%%
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

%% Prepare Kinematic Data

    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials);

%%
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



%% Build and Run Model - log-likelihood

num_states_subject = 16;

for iStatenum = 2:16
    
    num_states_subject = iStatenum;
    for iRepeat = 1:5
            [~,~,hn_trained{iStatenum,iRepeat},dc{iStatenum,iRepeat},~] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain);
    end
end
    
save(strcat(subject,task,session,'_HMM_hn_',num2str(num_states_subject),'_states_',date),'hn_trained','dc')