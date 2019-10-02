%% Analyze Breaux Data
clear

subject = 'Bx';
% arrays = {'M1m';'M1l'};
arrays = {'M1m'};
session = '190228';
subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
% subject_filepath_base = 'C:\Users\calebsponheim\Documents\Data\190228\';
% task = 'center_out';
% task = 'RTP';
task = 'center_out_and_RTP';

crosstrain = 3; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode | 3: both tasks together

if strcmp(task,'RTP') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(task,'center_out') && crosstrain == 0
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = 'go'; % supersedes trial_length if active
elseif crosstrain ~= 0
    subject_filepath_RTP = cellfun(@(x) [subject_filepath_base 'Bx' session x '_RTP_units'] ,arrays,'UniformOutput',0);
    subject_filepath_center_out = cellfun(@(x) [subject_filepath_base 'Bx' session 'x' x '_CO_units'] ,arrays,'UniformOutput',0);
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = 'go'; % supersedes trial_length if active
end

num_states_subject = 8;
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
%%
if crosstrain > 0
    %CO
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data_center_out,2)
        if isempty(data_center_out(iTrial).spikecount)
            bad_trials_CO(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data_center_out(iTrial).spikecount;
            timestamps_temp{trial_count} = bin_timestamps_center_out{iTrial};
            good_trials_CO(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data_center_out = data_temp;
    bin_timestamps_center_out = timestamps_temp;
    clear data_temp
    clear timestamps_temp
    %RTP
    trial_count = 1;
    bad_trial_count = 1;
    for iTrial = 1:size(data_RTP,2)
        if isempty(data_RTP(iTrial).spikecount)
            bad_trials_RTP(bad_trial_count) = iTrial;
            bad_trial_count = bad_trial_count + 1;
        else
            data_temp(trial_count).spikecount = data_RTP(iTrial).spikecount;
            timestamps_temp{trial_count} = bin_timestamps_RTP{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data_RTP = data_temp;
    bin_timestamps_RTP = timestamps_temp;
    
else
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
end

%% Prepare Kinematic Data

if crosstrain == 1 % RTP model, center-out decode
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events,good_trials);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events,good_trials);
elseif crosstrain == 3 % 3: Center-out and RTP together
    [data_RTP] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events,good_trials);
    [data_center_out] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events,good_trials);
else
    [data] = processing_CSS_kinematics(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials);
end

%%
if crosstrain > 0
else
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
end
%% Build and Run Model
if crosstrain > 0
    [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM([],num_states_subject,data_RTP,data_center_out,crosstrain);
else
    [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain);
end


%% Save Model
save(strcat(subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_',date))

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**
trials_to_plot = 1:20;
num_segments_to_plot = 1000;

if crosstrain == 1 % RTP model, center-out decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_center_out,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'center_out')
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'center_out');
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'RTP')
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'RTP');
elseif crosstrain == 3
    bin_timestamps = [bin_timestamps_center_out bin_timestamps_RTP];
    data = [data_center_out data_RTP];
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
else
    [trialwise_states] = segment_analysis(num_states_subject,trInd_test,dc_thresholded,bin_timestamps,data,subject);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
end

%%
trials_to_plot = datasample(1:length(trialwise_states),100);
trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
% trials_to_plot = [20:25];
plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
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
% close(gcf);

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject);


%% Save Result

save(strcat(subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))