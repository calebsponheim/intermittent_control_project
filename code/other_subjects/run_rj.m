%% Analyze RJ Data

subject = 'RJ';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\Collaborators data\RTP\Raju\r1031206_PMd_MI\r1031206_PMd_MI_modified_clean_spikesSNRgt4';
num_states_subject = 5;

bad_trials = [4;10;30;43;44;46;53;66;71;78;79;84;85;91;106;107;118;128;141;142;145;146;163;165;172;173;180;185;203;209;210;245;254;260;267;270;275;278;281;283;288;289;302;313;314;321;326;340;350;363;364;366;383;385;386;390;391];


% Scripts to run:

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials);

%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject);

%save(strcat(subject,'_HMM_classified_test_data_and_output_',num2str(NUM_STATES),date))
%% Prepare Kinematic Data
[data] = processing_kinematics(subject_filepath,cpl_st_trial_rew,data);

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);

trials_to_plot = 1:5;
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot)

num_segments_to_plot = 25;
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot);
%% Save Result

save(strcat(subject,'_HMM_analysis_',num2str(NUM_STATES),'_states_',date))