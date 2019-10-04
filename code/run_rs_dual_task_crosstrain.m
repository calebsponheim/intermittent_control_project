clear
subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1051013_MIall\rs1051013_clean_SNRgt4';
num_states_subject = 24;
task = 'CO+RTP';
crosstrain = 1; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode
bad_trials = [];

% Scripts to run:

%% Structure Spiking Data
if crosstrain > 0
    [data_RTP,cpl_st_trial_rew_RTP,bin_timestamps_RTP] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'RTP');
    [data_CO,cpl_st_trial_rew_CO,bin_timestamps_CO] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'CO');
end
%% Build and Run Model
if crosstrain > 0
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM([],num_states_subject,data_RTP,data_CO,crosstrain);
else
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain);
end
%% Save Model
if crosstrain > 0
    save(strcat(subject,'_HMM_classified_test_data_and_output_dual_task',num2str(num_states_subject),date,'crosstrain',num2str(crosstrain)))
else
    save(strcat(subject,'_HMM_classified_test_data_and_output_dual_task',num2str(num_states_subject),date))
end
%% Prepare Kinematic Data

if crosstrain == 1 % RTP model, center-out decode
    [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew_CO,data_CO);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew_RTP,data_RTP);
else
    [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew,data);
end

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**


trials_to_plot = 1:20;
num_segments_to_plot = 100;

if crosstrain == 1 % RTP model, center-out decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_CO,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'center_out_from_RTP_model')
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'center_out_out_from_RTP_model');
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'RTP_from_CO_model')
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'RTP_from_CO_model');
else
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
    
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
    
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
end
%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);
%%
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

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
if crosstrain > 0
    save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date,'crosstrain',num2str(crosstrain)))
else
    save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
end