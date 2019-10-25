 %% Analyze Breaux Data
clear

subject = 'Bx';
arrays = {'M1m' 'M1l'};
session = '180323';
subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' session '\'];
task = 'center_out';

subject_filepath = cellfun(@(x) [subject_filepath_base session x '_units'] ,arrays,'UniformOutput',0);
subject_events = [subject_filepath_base 'Bx' session '_events'];
trial_length = [-1 4]; %seconds. defaults is [-1 4];
trial_event_cutoff = 'go'; % supersedes trial_length if active
% trial_event_cutoff = 'speed'; % supersedes trial_length if active

num_states_subject = 8;
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

%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],0,round(rand(1)*1000));
                                                       
%% Save Model
save(strcat(subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_OLDDATA',date))

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
trials_to_plot = 1:10;
num_segments_to_plot = 500;

[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
%%
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
%%
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
%%
trials_to_plot = datasample(1:length(trialwise_states),100);
trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
% trials_to_plot = [20:25];
plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
%%
plot_transition_matrix(subject,task,num_states_subject,hn_trained)

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);


%% Save Result

save(strcat(subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_OLDDATA',date))