function [data,meta] = process_EMGs_v2(meta,data)
arrays = meta.arrays;
subject_filepath_base = meta.subject_filepath_base;
task = meta.task;
session = meta.session;
subject_events = meta.subject_events;
%%
file_list = dir(subject_filepath_base);
file_list = {file_list.name};

if strcmp(task,'RTP')
    EMG_files = cellfun(@(x)[subject_filepath_base x],...
        file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
elseif strcmp(task,'center_out')
    EMG_files = cellfun(@(x)[subject_filepath_base x],...
        file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_emg50to1kN.mat')),'UniformOutput',false);
    load(subject_events,'events','periOnPM_30k');
    events = events(events(:,7) > 0,:);
    periOnPM_30k = periOnPM_30k(events(:,7) > 0);
    trial_start_relative_to_periOn = events(:,1);
    trial_end_relative_to_periOn = events(:,7);
    
    % Caleb Files
    CS_EMG_files = cellfun(@(x)[subject_filepath_base x],...
        file_list(startsWith(file_list,'CO_EMGs')),'UniformOutput',false);
    
end

trial_start = [];
trial_end = [];
t = [];
EMG_signals = {};

if strcmp(task,'RTP')
    if strcmp(arrays{1}(1:2),'PM')
    elseif strcmp(arrays{1}(1:2),'M1')
        for iFile = 1:length(EMG_files)
            load(EMG_files{iFile});
            meta.muscle_names = fieldnames(trialwise_EMG);
            meta.muscle_names = meta.muscle_names(startsWith(meta.muscle_names,['EMG']));
            trial_start = [trial_start [trialwise_EMG.trial_start]];
            trial_end = [trial_end [trialwise_EMG.trial_end]];
            
            for iMuscle = 1:length(meta.muscle_names)
                if iFile == 1
                    EMG_signals{iMuscle} = {trialwise_EMG.(meta.muscle_names{iMuscle})};
                else
                    EMG_signals{iMuscle} = [EMG_signals{iMuscle} {trialwise_EMG.(meta.muscle_names{iMuscle})}];
                end
            end
            clear trialwise_EMG
        end
    end
elseif strcmp(task,'center_out')  
    % Caleb
    for iFile = 1:length(CS_EMG_files)
        load(CS_EMG_files{iFile});
        meta.muscle_names = fieldnames(trialwise_EMG);
        meta.muscle_names = meta.muscle_names(startsWith(meta.muscle_names,['EMG']));
        trial_start = [trial_start [trialwise_EMG.trial_start]];
        trial_end = [trial_end [trialwise_EMG.trial_end]];
        
        for iMuscle = 1:length(meta.muscle_names)
            if iFile == 1
                EMG_signals{iMuscle} = {trialwise_EMG.(meta.muscle_names{iMuscle})};
            else
                EMG_signals{iMuscle} = [EMG_signals{iMuscle} {trialwise_EMG.(meta.muscle_names{iMuscle})}];
            end
        end
        clear trialwise_EMG
    end
end


%% segment position and speed vectors into trials

% for each trial
for iTrial = 1:size(data,2)        
        for iMuscle = 1:length(meta.muscle_names)
            data_temp = EMG_signals{iMuscle}{iTrial}(1:2:end);
            data(iTrial).(meta.muscle_names{iMuscle}) = data_temp(1:length(data(iTrial).kinematic_timestamps));
        end
end
end
