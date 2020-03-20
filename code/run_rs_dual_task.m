
subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1051013_MIall\rs1051013_clean_SNRgt4';
num_states_subject = 16;
task = 'CO+RTP';

bad_trials = [];
% Scripts to run:

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'task');

%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],0);

%% Save Model
save(strcat(subject,'_HMM_classified_test_data_and_output_dual_task',num2str(num_states_subject),date))
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


%% transition matrix
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);

figure; hold on;
imagesc(hn_trained.a)
colormap(gca,jet)
axis square
axis tight
colorbar
if strcmp(task,'center_out')
    title([subject,' center out transition matrix']);
else
    title([subject,task,' transition matrix']);
end
box off
set(gcf,'Color','White');
saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
    ,subject,task,num2str(num_states_subject),'states_transition_matrix.png'));
%% Save Result

save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))