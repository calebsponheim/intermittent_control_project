%% Analyze Breaux Data
clear

%% User-Defined Variables via "meta" struct

meta.subject = 'Bx'; % Subject
meta.arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
meta.session = '190228'; % Which day of data
% meta.task = 'center_out';       % Choose one of the three options here
meta.task = 'RTP';              % Choose one of the three options here
% meta.task = 'center_out_and_RTP'; % Choose one of the three options here

meta.include_EMG_analysis = 1; % Process EMG data along with kinematics?

meta.bin_size = .050; %seconds
meta.center_out_trial_window = ''; % If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')

% in "events" ; this is the window that the HMM will actually analyze, inside of the bigger center-out window. 
meta.CO_HMM_analysis_window = {'move','reward'}; % TIMING IS RELATIVE TO "TRIAL  START". THIS IS USUALLY -1000ms FROM PERION

meta.crosstrain = 0; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode | 3: both tasks together

meta.num_states_subject = 16; % How many states in the model?

meta.spike_hz_threshold = 0; % Minimum required FR for units?
meta.bad_trials = []; % Any explicitly bad trials to throw out?
meta.seed_to_train = round(abs(randn(1)*1000)); % can manually define the randomization seed for replication 
% seed_to_train = 9348;

meta.TRAIN_PORTION = 0.80; % percent

meta.trials_to_plot = 1:10; % Which individual trials to plot
meta.num_segments_to_plot = 200; % How cluttered to make the segment plots

%Defining Target Locations:
meta.target_locations = {'N','NE','E','SE','S','SW','W','NW'};

%% Setting Paths
if ispc
    meta.subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' meta.session '\'];
elseif ismac
    meta.subject_filepath_base = ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' meta.session '/'];
end

meta.subject_events = [meta.subject_filepath_base 'Bx' meta.session 'x_events'];

if strcmp(meta.task,'RTP') && meta.crosstrain == 0
    meta.subject_filepath = cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_RTP_units'] ,meta.arrays,'UniformOutput',0);    
    meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
    meta.trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(meta.task,'center_out') && meta.crosstrain == 0
    meta.subject_filepath = cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_CO_units'] ,meta.arrays,'UniformOutput',0);
    meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
    meta.trial_event_cutoff = meta.center_out_trial_window; % supersedes trial_length if active
elseif meta.crosstrain ~= 0
    meta.subject_filepath_RTP = ...
        cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_RTP_units'] ,meta.arrays,'UniformOutput',0);
    meta.subject_filepath_center_out = ...
        cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_CO_units'] ,meta.arrays,'UniformOutput',0);
    meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
    meta.trial_event_cutoff = meta.center_out_trial_window; % supersedes trial_length if active
end

 
%% Structure Spiking Data

if meta.crosstrain > 0
    meta.subject_filepath = meta.subject_filepath_RTP;
    meta.task = 'RTP';

    [data_RTP,~] = ...
        CSS_data_to_organized_spiketimes_for_HMM(meta);
    
    meta.subject_filepath = meta.subject_filepath_center_out;
    meta.task = 'center_out';
    
    [data_center_out,meta.targets] = ...
        CSS_data_to_organized_spiketimes_for_HMM(meta);
else
    [data,meta.targets] = CS_spiketimes_to_bins_v2(meta);
end

%% Prepare Kinematic Data

if meta.crosstrain == 1 % RTP model, center-out decode
    meta.task = 'center_out';
    [data] = processing_CSS_kinematics(meta,data_center_out);
elseif meta.crosstrain == 2 % 2: Center-out model, RTP decode
    meta.task = 'RTP';
    [data] = processing_CSS_kinematics(meta,data_RTP);
elseif meta.crosstrain == 3 % 3: Center-out and RTP together
    meta.task = 'RTP';
    [data_RTP] = processing_CSS_kinematics(meta,data_RTP);
    meta.task = 'center_out';
    [data_center_out] = processing_CSS_kinematics(meta,data_center_out);
else
    [data] = processing_CSS_kinematics(meta,data);
end

%% Prepare EMG Data

if include_EMG_analysis == 1
    if crosstrain == 1 % RTP model, center-out decode
        [data,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data,'center_out',session,subject_events,good_trials);
    elseif crosstrain == 2 % 2: Center-out model, RTP decode
        [data,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data,'RTP',session,subject_events,good_trials);
    elseif crosstrain == 3 % 3: Center-out and RTP together
        [data_RTP,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew_RTP,data_RTP,'RTP',session,subject_events,good_trials);
        [data_center_out,~] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew_center_out,data_center_out,'center_out',session,subject_events,good_trials);    
    else
        [data,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials);
    end
else
    muscle_names = [];
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
            if strcmp(task,'center_out')              
                data_temp(trial_count).tp = data(iTrial).tp;
                data_temp(trial_count).target = data(iTrial).target;
            end
            for iMuscle = 1:length(muscle_names)
                data_temp(trial_count).(muscle_names{iMuscle}) = data(iTrial).(muscle_names{iMuscle});
            end
            
            timestamps_temp{trial_count} = bin_timestamps{iTrial};
            good_trials(trial_count) = iTrial;
            trial_count = trial_count + 1;
        end
    end
    
    data = data_temp;
    bin_timestamps = timestamps_temp;
end

%% pre-model-save
% save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',subject,task,'_HMM_struct_',date))

%% Build and Run Model
if crosstrain > 0
    [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM([],num_states_subject,data_RTP,data_center_out,crosstrain,seed_to_train,TRAIN_PORTION);
else
    [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain,seed_to_train,TRAIN_PORTION);
end


%% Save Model
if ispc
    save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_CT_',num2str(crosstrain),'_',date))
%     save(['C:\Users\vpapadourakis\Documents\' subject task '_HMM_classified_test_data_and_output_' num2str(num_states_subject) '_states_' date])
else
    save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' subject task '_HMM_classified_test_data_and_output_' num2str(num_states_subject) '_states_' date])
end

%% Create Plot Figure Results Folder

file_list = dir('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\');
file_list = {file_list.name};
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-6);

figure_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'_states_',current_date_and_time,'_CT_',num2str(crosstrain)];
figure_folder_filepath_dupe_comp = [subject,task,num2str(num_states_subject),'_states_',current_date_and_time,'_CT_',crosstrain];
dupe_status = cell2mat(cellfun(@(x,y)strcmp(x,figure_folder_filepath_dupe_comp),file_list,'UniformOutput',false));
if sum(dupe_status) > 0
    figure_folder_filepath = [figure_folder_filepath 'a'];
end
mkdir(figure_folder_filepath)

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**

if crosstrain == 1 % RTP model, center-out decode
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps_center_out,data,subject,muscle_names,include_EMG_analysis,target_locations);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'center_out',muscle_names,include_EMG_analysis,figure_folder_filepath)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'center_out',muscle_names,include_EMG_analysis,figure_folder_filepath);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject,muscle_names,include_EMG_analysis,target_locations);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'RTP',muscle_names,include_EMG_analysis,figure_folder_filepath)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'RTP',muscle_names,include_EMG_analysis,figure_folder_filepath);
elseif crosstrain == 3 
    bin_timestamps = [bin_timestamps_center_out bin_timestamps_RTP];
    data = [data_center_out data_RTP];
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps,data,subject,muscle_names,include_EMG_analysis,target_locations);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath)
else
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps,data,subject,muscle_names,include_EMG_analysis,target_locations);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath)
end

%%
% trials_to_plot = datasample(1:length(trialwise_states),100);
% trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
% trials_to_plot = [20:25];
trials_to_plot = 1:length(trialwise_states);
plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,figure_folder_filepath)
%%
transition_matrix_for_plot = hn_trained.a;

for iState = 1:num_states_subject
    transition_matrix_for_plot(iState,iState) = 0;
end

figure('visible','off'); hold on;
imagesc(transition_matrix_for_plot)
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
saveas(gcf,strcat(figure_folder_filepath,'\'...
    ,subject,task,num2str(num_states_subject),'states_transition_matrix.png'));

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject,include_EMG_analysis,muscle_names,figure_folder_filepath);

%% Plot Avg EMG Center Out stuff

if strcmp(task,'center_out')
    avg_CO_emg_traces(muscle_names,trialwise_states,targets,figure_folder_filepath,subject,task)
end

%% Save Result

% save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
% save(strcat('C:\Users\vpapadourakis\Documents\',subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
