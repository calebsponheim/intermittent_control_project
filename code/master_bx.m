% Master Breaux

%% User-Defined Variables via "meta" struct

meta.subject = 'Bx'; % Subject
meta.arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
meta.session = '190228'; % Which day of data
% meta.task = 'center_out';       % Choose one of the three options here
% meta.task = 'RTP';              % Choose one of the three options here
meta.task = 'center_out_and_RTP'; % Choose one of the three options here

meta.include_EMG_analysis = 1; % Process EMG data along with kinematics?

meta.bin_size = .050; %seconds
meta.muscle_lag = .1; %seconds
meta.center_out_trial_window = ''; % If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')

% in "events" ; this is the window that the HMM will actually analyze, inside of the bigger center-out window.
meta.CO_HMM_analysis_window = {'move','reward'}; % TIMING IS RELATIVE TO "TRIAL START". THIS IS USUALLY -1000ms FROM PERION

meta.crosstrain = 3; % 0: none | 1: RTP model, center-out decode | 2: Center-out model, RTP decode | 3: both tasks together

% meta.num_states_subject = 16; % How many states in the model? NO LONGER USED

meta.spike_hz_threshold = 0; % Minimum required FR for units
meta.bad_trials = []; % Any explicitly bad trials to throw out?
meta.seed_to_train = round(abs(randn(1)*1000)); % can manually define the randomization seed for replication
% seed_to_train = 9348;

meta.TRAIN_PORTION = 0.8; % percent
meta.MODEL_SELECT_PORTION = 0.1;
meta.TEST_PORTION = 0.1;

meta.trials_to_plot = 1:10; % Which individual trials to plot
meta.num_segments_to_plot = 200; % How cluttered to make the snippet plots

%Defining Target Locations:
meta.target_locations = {'N','NE','E','SE','S','SW','W','NW'};

%% checking to see if preprocessing has already been done

if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    filelist = dir('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\');
    filelist = {filelist.name};
else
    filelist = dir('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\');
    filelist = {filelist.name};
end

if ~(contains(filelist,[meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)]))
    data_file_already_exists = 0;
else
    data_file_already_exists = 1;
end
%% Preprocessing
if data_file_already_exists == 0
    [meta,data] = bx_premodel_processing(meta);
elseif data_file_already_exists == 1
    load(['.\data\' meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)])
end
%% Next, run models on midway

%% Next, transfer all the data back from midway AND decode trials based on their role
% Determine optimal number of states
[meta] = model_select_HMM(data,meta);

%% decode with the optimal number of states
[data,meta] = decode_with_optimal_states(data,meta);

%% Saving
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\data_with_optimal_states_estimate\' meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)], 'meta', 'data','-v7.3')
else
    save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\data_with_optimal_states_estimate\',meta.subject,meta.task,'_HMM_struct_',date),'-v7.3')
end

%% Post-model Analysis (including plotting)
bx_postmodel_analysis(meta,data)