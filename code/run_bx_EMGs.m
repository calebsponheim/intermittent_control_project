%% Analyze RS Data


subject = 'Bx';
session = '190228';
subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
bad_trials = [];
num_states_subject = 8;
task = 'center_out';
% task = 'RTP';

if strcmp(task,'RTP')
sessions = {'a' 'c' 'e' 'g'};
subject_filepath_EMGs = cellfun(@(x) [subject_filepath_base 'RTP_EMGs_' session x] ,sessions,'UniformOutput',0);
elseif strcmp(task,'center_out')
sessions = {'b' 'd' 'f'};
subject_filepath_EMGs = cellfun(@(x) [subject_filepath_base subject session x '_emg50to1kN'] ,sessions,'UniformOutput',0);
end    

%% Structure Spiking Data

[data,cpl_st_trial_rew,bin_timestamps] = CSS_EMG_data_to_organization_for_HMM(subject_filepath_EMGs,bad_trials,task);


%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject);

%% Save Model
save(strcat(subject,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_',date))
%% Prepare Kinematic Data
% if strcmp(arrays{1}(1:2),'M1')
%     kinematic_filepath = [subject_filepath_base 'RTP_kinematics_' session];
% elseif strcmp(arrays{1}(1:2),'PM')
%     kinematic_filepath = [subject_filepath_base 'RTP_EMGs_' session];
% end

[data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data);

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data);


trials_to_plot = 1:5;
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot)

num_segments_to_plot = 25;
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot);
%% Save Result

save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))