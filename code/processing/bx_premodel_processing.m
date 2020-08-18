function [meta,data] = bx_premodel_processing(meta)
%% Process and structure Breaux Data in Preparation for HMM Model

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
end