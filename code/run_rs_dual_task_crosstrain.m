clear
subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1051013_MIall\rs1051013_clean_SNRgt4';
num_states_subject = 8;
task = 'CO+RTP';
crosstrain = 2; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode
validation_trials = 1; % 0: train and test on different tasks | 1: train and test on the same task
trials_to_plot = 1:30;
num_segments_to_plot = 100;

if validation_trials == 1
    run_rs_dual_task_crosstrain_validationset(trials_to_plot,num_segments_to_plot)
else    
    if crosstrain == 1
        task = 'CO_from_RTP_model';
    elseif crosstrain == 2
        task = 'RTP_from_CO_model';
    end
    
    bad_trials = [];
    
    seed_to_train = 042793; % NEED TO CHANGE MANUALLY
    % Scripts to run:
    
    %% Structure Spiking Data
    if crosstrain > 0
        [data_RTP,cpl_st_trial_rew_RTP,bin_timestamps_RTP] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'RTP');
        [data_CO,cpl_st_trial_rew_CO,bin_timestamps_CO] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'CO');
    else
        [data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,'task');
    end
    
%% run the whole thing multiple times

for iIter = 1:1
    
    %% Build and Run Model
        if crosstrain > 0
            [trInd_train,trInd_test,hn_trained,dc,seed_to_train,trInd_train_validation] = train_and_decode_HMM([],num_states_subject,data_RTP,data_CO,crosstrain,seed_to_train);
        else
            [trInd_train,trInd_test,hn_trained,dc,seed_to_train,~] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain,seed_to_train);
        end
        %% Save Model
        if crosstrain > 0
            save(strcat(subject,'_HMM_classified_test_data_and_output_dual_task',num2str(num_states_subject),date,'crosstrain',num2str(crosstrain),'_iter_',num2str(iIter)))
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
    
    
    
    if crosstrain == 1 % RTP model, center-out decode
        [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_CO,data,subject);
        plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
        [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
    elseif crosstrain == 2 % 2: Center-out model, RTP decode
        [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject);
        plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task);
        [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
    else
        [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
        
        plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
        
        [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
    end
    %% normalized segments
     
    [segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);
    %%
    plot_transition_matrix(subject,task,num_states_subject,hn_trained)
    %%
    if crosstrain == 1
        trials_to_plot = datasample(1:length(trialwise_states),100);
        trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
        plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
    end
    %% Save Result
    if crosstrain > 0
        save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date,'crosstrain',num2str(crosstrain),"_iter_",num2str(iIter)))
    else
        save(strcat(subject,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
    end
end 
end