function [] = run_rs_dual_task_crosstrain_validationset(trials_to_plot,num_segments_to_plot)
trials_to_plot_temp = trials_to_plot;
disp('please select file from which to generate validation trials');
uiopen
validation_trials = 1;
if crosstrain == 1
    task = 'RTP_from_RTP_model_validation';
elseif crosstrain == 2
    task = 'CO_from_CO_model_validation';
end

trials_to_plot = trials_to_plot_temp;
trainset_validation = cell(size(trInd_train_validation));
if crosstrain == 1
    NumTrials_train = length(data_RTP);
elseif crosstrain == 2
    NumTrials_train = length(data_CO);
end
for iTrial = 1 : NumTrials_train
    
    % Get activations matrix, apply threshold:
    if crosstrain == 1
        S = data_RTP(iTrial).spikecount ;
    elseif crosstrain == 2
        S = data_CO(iTrial).spikecount ;
    end
    
    % Save matrix to proper cell array:
    if any(iTrial==trInd_train) % if trial is in train set:
    else % else, trial is in test set:
        if crosstrain > 0 && crosstrain < 3
            trainset_validation{iTrial==trInd_train_validation} = S;
        else
        end
    end
end
dc = ehmmDecode(hn_trained,trainset_validation) ;
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Prepare Kinematic Data for VALIDATION DATA
if crosstrain == 1 % RTP model, RTP decode
    [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew_RTP,data_RTP);
elseif crosstrain == 2 % 2: Center-out model, CO decode
    [data] = processing_kinematics(subject_filepath,cpl_st_trial_rew_CO,data_CO);
end

% Plotting
if crosstrain == 1 % RTP model, RTP decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_train_validation,dc_thresholded,bin_timestamps_RTP,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_train_validation,subject,num_segments_to_plot,task);
elseif crosstrain == 2 % 2: Center-out model, Center-out decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_train_validation,dc_thresholded,bin_timestamps_CO,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_train_validation,subject,num_segments_to_plot,task);
end

%% normalized segments
    
    [segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);
    
    if crosstrain == 2
        trials_to_plot = datasample(1:length(trialwise_states),100);
        trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
        plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
    end

    %%
    plot_transition_matrix(subject,task,num_states_subject,hn_trained)
