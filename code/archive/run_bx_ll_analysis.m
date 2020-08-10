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
% seed_to_train = round(abs(randn(1)*1000)); % can manually define the randomization seed for replication 
seed_to_train = 0239348;

TRAIN_PORTION = 0.5; %


%% Setting Paths
if ispc
    subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
elseif ismac
    subject_filepath_base = ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' session '/'];
end

subject_events = [subject_filepath_base 'Bx' session 'x_events'];

if strcmp(task,'RTP') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);    
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(task,'center_out') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
elseif crosstrain ~= 0
    subject_filepath_RTP = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_filepath_center_out = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
end

%% Structure Spiking Data

if crosstrain > 0
    [data_RTP,cpl_st_trial_rew_RTP,bin_timestamps_RTP,~] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath_RTP,bad_trials,spike_hz_threshold,'RTP',subject_events,arrays,trial_length,trial_event_cutoff);
    
    [data_center_out,cpl_st_trial_rew_center_out,bin_timestamps_center_out,targets] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath_center_out,bad_trials,spike_hz_threshold,'center_out',subject_events,arrays,trial_length,trial_event_cutoff);
else
    [data,cpl_st_trial_rew,bin_timestamps,targets] = ...
        CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,spike_hz_threshold,task,subject_events,arrays,trial_length,trial_event_cutoff);
end

%% Build and Run Model - log-likelihood

num_states_subject = 16;
TRAIN_PORTION = .5;

rng(5);

for iStatenum = 2:30
    
    num_states_subject = iStatenum;
    for iRepeat = 1:5
        seed_to_train = round(abs(randn(1)*1000));
        [~,~,hn_trained{iStatenum,iRepeat},dc{iStatenum,iRepeat},dc_trainset{iStatenum,iRepeat},~,~] = train_and_decode_HMM(data,num_states_subject,[],[],0,seed_to_train,TRAIN_PORTION);
    end
end
    
save(strcat(subject,task,session,'_HMM_hn_',num2str(num_states_subject),'_states_',date),'hn_trained','dc','dc_trainset')