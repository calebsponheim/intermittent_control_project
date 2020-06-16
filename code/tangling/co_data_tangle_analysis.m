%% Transform center_out data into trial-averaged firing rates for trajectory tangling analysis.

% From The Demo:

% Data should be formatted as for jPCA. Each data structure (e.g. D_m1,
% located in M1_sampleData.mat) contains C elements corresponding to the
% number of conditions (here, 2). The t x n matrix 'A' contains the
% trial-averaged firing rates as a function of time for each neuron. All
% other fields are optional. The 'times' field indicates the time course of
% each sample in A and the 'analyzeTimes' field indicates which of these
% times should be analyzed for tangling.

%% Collect 1ms - bin un-averaged trial data, aligned on movement
clear
%%%%%%%% User-defined Variables %%%%%%%%%%%%%%%
subject = 'Bx'; % Subject

if strcmp(subject,'Bx')
    arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
    session = '190228'; % Which day of data
    
    task = 'center_out';       % Choose one of the three options here
    
    center_out_trial_window = 'move'; % If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')
    
    spike_hz_threshold = 0; % Minimum required FR for units?
    bad_trials = []; % Any explicitly bad trials to throw out?
    bin_size = .001; %seconds
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Defining Target Locations:
    target_locations = {'N','NE','E','SE','S','SW','W','NW'};
    if ispc
        subject_filepath_base = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session '\'];
    elseif ismac
        subject_filepath_base = ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' session '/'];
    end
    subject_events = [subject_filepath_base 'Bx' session 'x_events'];
    subject_filepath = cellfun(@(x) [subject_filepath_base 'Bx' session x '_CO_units'] ,arrays,'UniformOutput',0);
    trial_length = [-1 4]; %seconds. defaults is [-1 4];
    trial_event_cutoff = center_out_trial_window; % supersedes trial_length if active
    [data,~,bin_timestamps,~] = CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,spike_hz_threshold,task,subject_events,arrays,trial_length,trial_event_cutoff,bin_size);
elseif strcmp(subject,'RJ')
    subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\Collaborators data\RTP\Raju\r1031206_PMd_MI\r1031206_PMd_MI_modified_clean_spikesSNRgt4';
    bin_size = .001; %seconds
    bad_trials = [4;10;30;43;44;46;53;66;71;78;79;84;85;91;106;107;118;128;141;142;145;146;163;165;172;173;180;185;203;209;210;245;254;260;267;270;275;278;281;283;288;289;302;313;314;321;326;340;350;363;364;366;383;385;386;390;391];
    [data,~,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,bin_size);
end
%% average across trials, but not across units

%% Assign data to out_m1 structure

%% Perform Actual Tangling Analysis

tangle_visualize_cs( out_m1 )
    
