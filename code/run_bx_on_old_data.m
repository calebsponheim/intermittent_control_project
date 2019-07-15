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

num_states_subject = 5;
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
[trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],[]);


%% Save Model
save(strcat(subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_OLDDATA',date))

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
trials_to_plot = 10:20;
num_segments_to_plot = 100;

[trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
%%
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
%%
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
%%
trials_to_plot = 1:length(trialwise_states);
plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
%%
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

figure; hold on;
imagesc(hn_trained.a)
axis square
axis tight
title([subject,task,' transition matrix']);
box off
set(gcf,'Color','White');
saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
    ,subject,task,num2str(num_states_subject),'states_transition_matrix.png'));
close(gcf);

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);


%% Save Result

save(strcat(subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_OLDDATA',date))