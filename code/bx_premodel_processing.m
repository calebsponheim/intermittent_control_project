%% Process and structure Breaux Data in Preparation for HMM Model
clear

%% User-Defined Variables via "meta" struct

meta.subject = 'Bx'; % Subject
meta.arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
meta.session = '190228'; % Which day of data
meta.task = 'center_out';       % Choose one of the three options here
% meta.task = 'RTP';              % Choose one of the three options here
% meta.task = 'center_out_and_RTP'; % Choose one of the three options here

meta.include_EMG_analysis = 1; % Process EMG data along with kinematics?

meta.bin_size = .050; %seconds
meta.center_out_trial_window = ''; % If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')

% in "events" ; this is the window that the HMM will actually analyze, inside of the bigger center-out window.
meta.CO_HMM_analysis_window = {'move','reward'}; % TIMING IS RELATIVE TO "TRIAL  START". THIS IS USUALLY -1000ms FROM PERION

meta.crosstrain = 3; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode | 3: both tasks together

meta.num_states_subject = 16; % How many states in the model?

meta.spike_hz_threshold = 0; % Minimum required FR for units
meta.bad_trials = []; % Any explicitly bad trials to throw out?
meta.seed_to_train = round(abs(randn(1)*1000)); % can manually define the randomization seed for replication
% seed_to_train = 9348;

meta.TRAIN_PORTION = 0.8; % percent
meta.MODEL_SELECT_PORTION = 0.1;
meta.TEST_PORTION = 0.1;

meta.trials_to_plot = 1:10; % Which individual trials to plot
meta.num_segments_to_plot = 200; % How cluttered to make the segment plots

%Defining Target Locations:
meta.target_locations = {'N','NE','E','SE','S','SW','W','NW'};

%% Setting Paths
if ispc
    meta.subject_filepath_base = ...
        ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' meta.session '\'];
elseif ismac
    meta.subject_filepath_base = ...
        ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' meta.session '/'];
end

meta.subject_events = [meta.subject_filepath_base 'Bx' meta.session 'x_events'];

if strcmp(meta.task,'RTP') && meta.crosstrain == 0
    meta.subject_filepath = ...
        cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_RTP_units'] ,meta.arrays,'UniformOutput',0);
    meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
    meta.trial_event_cutoff = ''; % supersedes trial_length if active
elseif strcmp(meta.task,'center_out') && meta.crosstrain == 0
    meta.subject_filepath = ...
        cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_CO_units'] ,meta.arrays,'UniformOutput',0);
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
else
    [data,meta.targets] = CS_spiketimes_to_bins_v2(meta);
end

%% Prepare Kinematic Data

if meta.crosstrain > 0
else
    [data] = process_kinematics_v2(meta,data);
end

%% Prepare EMG Data

if meta.include_EMG_analysis == 1
    if meta.crosstrain > 0
    else
        [data,meta] = process_EMGs_v2(meta,data);
    end
else
    meta.muscle_names = [];
end

%% Allocate Trials to test/model/train
if meta.crosstrain > 0
    [data,meta] = assign_trials_to_HMM_group([],meta);
else
    [data,meta] = assign_trials_to_HMM_group(data,meta);
end
%% pre-model-save
if meta.crosstrain == 0
    if ispc
        if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
            save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)], 'meta', 'data','-v7.3')
        else
            save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',meta.subject,meta.task,'_HMM_struct_',date),'-v7.3')
        end
    else
        save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' meta.subject meta.task '_HMM_classified_test_data_and_output_' num2str(meta.num_states_subject) '_states_' meta.date],'-v7.3')
    end
elseif meta.crosstrain > 0
    if ispc
        if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
            save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' meta.subject meta.session 'CT' num2str(meta.crosstrain)], 'meta', 'data','-v7.3')
        else
            save(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',meta.subject,meta.session,'CT',num2str(meta.crosstrain)],'meta', 'data','-v7.3')
        end
    else
        save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' meta.subject meta.session 'CT' num2str(meta.crosstrain)],'meta', 'data','-v7.3')
    end
end
