%% Analyze Breaux Data
clear

subject = 'Bx';
arrays = {'M1m';'M1l'};
% arrays = {'M1m'};
session = '190228';
% subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
subject_filepath_base = 'C:\Users\calebsponheim\Documents\Data\190228\';
% task = 'center_out';
task = 'RTP';

crosstrain = 0; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode

if strcmp(task,'RTP') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(task,'center_out') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session 'x' x '_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = 'go'; % supersedes trial_length if active
elseif crosstrain ~= 0
    subject_filepath_RTP = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_filepath_center_out = cellfun(@(x) [subject_filepath_base 'Bx' session 'x' x '_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = 'go'; % supersedes trial_length if active
end

num_states_subject = 7;
spike_hz_threshold = 0;
bad_trials = [];

% Scripts to run:

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
%% Build and Run Model
if crosstrain > 0 
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM([],num_states_subject,data_RTP,data_center_out,crosstrain);
else
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain);
end 


%% Save Model
save(strcat(subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_',date))

%% Prepare Kinematic Data

if crosstrain == 1 % RTP model, center-out decode
[data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
[data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events);
else
[data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events);
end
%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
trials_to_plot = 1:5;
num_segments_to_plot = 100;

if crosstrain == 1 % RTP model, center-out decode
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_center_out,data,subject);
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'center_out')
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'center_out');
elseif crosstrain == 2 % 2: Center-out model, RTP decode
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject);
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'RTP')
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'RTP');
else
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
end

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);


%% Save Result

save(strcat(subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))