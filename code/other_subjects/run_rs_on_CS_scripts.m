%% Analyze RS Data

subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4';
num_states_subject = 8;
task = 'RTP';

bad_trials = [2;92;151;167;180;212;244;256;325;415;457;508;571;662;686;748];

% Scripts to run:

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials);

%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],0);

%% Save Model
save(strcat(subject,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),date))
%% Prepare Kinematic Data
[data] = processing_kinematics(subject_filepath,cpl_st_trial_rew,data);

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);

trials_to_plot = 1:5;
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)

num_segments_to_plot = 25;
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);

%% Save Result

save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))