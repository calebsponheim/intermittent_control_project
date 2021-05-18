%% Analyze Breaux Data
clear

subject = 'Bx';
arrays = {'M1m' 'M1l'};
session = '180323';
if ispc
    subject_filepath_base = ...
        ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' session '\'];
elseif ismac
    subject_filepath_base = ...
        ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2018/' session '/'];
end

task = 'center_out';

subject_filepath = cellfun(@(x) [subject_filepath_base session x '_units'] ...
    ,arrays,'UniformOutput',0);
subject_events = [subject_filepath_base 'Bx' session '_events'];
trial_length = [-1 3.5]; %seconds. defaults is [-1 4];

% If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')
center_out_trial_window = 'go';
trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
% trial_event_cutoff = 'speed'; % supersedes trial_length if active

bin_size = .050; %seconds


% 0: none |
% 1: RTP model, center-out decode |
% 2: Center-out model, RTP decode |
% 3: both tasks together
crosstrain = 0;

% How many states in the model?
num_states_subject = 12;

% Minimum required FR for units?
spike_hz_threshold = 0;

% Any explicitly bad trials to throw out?
bad_trials = [];

% can manually define the randomization seed for replication
seed_to_train = round(abs(randn(1)*1000));

% seed_to_train = 9348;

TRAIN_PORTION = 0.80; %

trials_to_plot = 1:5; % Which individual trials to plot
num_segments_to_plot = 200; % How cluttered to make the segment plots

%Defining Target Locations:
target_locations = {'N','NE','E','SE','S','SW','W','NW'};

% Scripts to run:

%% Structure Spiking Data

[data,cpl_st_trial_rew,bin_timestamps,targets] = ...
    CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,...
    spike_hz_threshold,task,subject_events,arrays,...
    trial_length,trial_event_cutoff,bin_size);
%%
trial_count = 1;
bad_trial_count = 1;
for iTrial = 1:size(data,2)
    if isempty(data(iTrial).spikecount)
        bad_trials(bad_trial_count) = iTrial;
        bad_trial_count = bad_trial_count + 1;
    else
        data_temp(trial_count).spikecount = data(iTrial).spikecount;
        if strcmp(task,'center_out')
            data_temp(trial_count).tp = data(iTrial).tp;
            data_temp(trial_count).target = data(iTrial).target;
        end
        
        timestamps_temp{trial_count} = bin_timestamps{iTrial};
        good_trials(trial_count) = iTrial;
        trial_count = trial_count + 1;
    end
end

data = data_temp;
bin_timestamps = timestamps_temp;

%% Prepare Kinematic Data

[data] = processing_CSS_kinematics(arrays,subject_filepath_base,trial_event_cutoff,data,task,session,subject_events,trial_length);
%% muscles

[data,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,...
    cpl_st_trial_rew,data,task,session,subject_events,good_trials);
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
            data_temp(trial_count).kinematic_timestamps = ...
                data(iTrial).kinematic_timestamps;
            if strcmp(task,'center_out')
                data_temp(trial_count).tp = data(iTrial).tp;
                data_temp(trial_count).target = data(iTrial).target;
            end
            for iMuscle = 1:length(muscle_names)
                data_temp(trial_count).(muscle_names{iMuscle}) = ...
                    data(iTrial).(muscle_names{iMuscle});
            end
            
            timestamps_temp{trial_count} = bin_timestamps{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data = data_temp;
    bin_timestamps = timestamps_temp;
end

%% Build and Run Model
[trInd_train,trInd_test,hn_trained,dc,dc_trainset,seed_to_train,trInd_train_validation] = ...
    train_and_decode_HMM(data,num_states_subject,[],[],...
    crosstrain,seed_to_train,TRAIN_PORTION);

%% Save Model
save(strcat(subject,task,'_HMM_classified_test_data_and_output_',...
    num2str(num_states_subject),'_states_OLDDATA',date))

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);


%%
file_list = ...
    dir('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\');
file_list = {file_list.name};
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-6);

figure_folder_filepath = ...
    ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',...
    subject,task,num2str(num_states_subject),'_states_',...
    current_date_and_time,'_CT_',num2str(crosstrain)];
figure_folder_filepath_dupe_comp = ...
    [subject,task,num2str(num_states_subject),...
    '_states_',current_date_and_time,'_CT_',crosstrain];
dupe_status = cell2mat(cellfun(@(x,y)strcmp(x,figure_folder_filepath_dupe_comp)...
    ,file_list,'UniformOutput',false));
if sum(dupe_status) > 0
    figure_folder_filepath = [figure_folder_filepath 'a'];
end
mkdir(figure_folder_filepath)
%% Create Snippets and Plot **everything**
trials_to_plot = 1:10;
num_segments_to_plot = 500;


[trialwise_states] = segment_analysis(trInd_test,...
    dc_thresholded,bin_timestamps,data,subject,muscle_names,1,target_locations);

%%
[segmentwise_analysis] = plot_segments(trialwise_states,...
    num_states_subject,trInd_test,subject,num_segments_to_plot,task);
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

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,...
    subject,task,num_states_subject);
%% Plot Avg EMG Center Out stuff

if strcmp(task,'center_out')
    avg_CO_emg_traces(muscle_names,trialwise_states,targets,...
        figure_folder_filepath,subject,task)
end



%% Save Result

save(strcat(subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_OLDDATA',date))