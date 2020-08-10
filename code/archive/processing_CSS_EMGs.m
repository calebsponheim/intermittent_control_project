function [data,muscle_names] = processing_CSS_EMGs(arrays,subject_filepath_base,cpl_st_trial_rew,data,task,session,subject_events,good_trials)

% process Kinematics for HMM comparison

%clear all

% load and import unsorted kinematics

sampling_rate = 2000; % samples per second

% figure out a way to concatonate the kinematics together; maybe pull from
% the event codes?

%%
file_list = dir(subject_filepath_base);
file_list = {file_list.name};

if strcmp(task,'RTP')
    EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
elseif strcmp(task,'center_out')
    EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_emg50to1kN.mat')),'UniformOutput',false);
    block_events_file = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_events.mat')),'UniformOutput',false);
    load(subject_events,'events','periOnPM_30k');
    events = events(events(:,7) > 0,:);
    periOnPM_30k = periOnPM_30k(events(:,7) > 0);
    trial_start_relative_to_periOn = events(:,1);
    trial_end_relative_to_periOn = events(:,7);
    EMG_files_for_names = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
    
    if strcmp('180323',session)
        file_list_for_names = dir('\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\190228\');
        file_list_for_names = {file_list_for_names.name};
        EMG_files_for_names = cellfun(@(x) ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\190228\' x], file_list_for_names(startsWith(file_list_for_names,'RTP_EMGs')),'UniformOutput',false);
    end
    % TESTING %%%%%%%%%%%%%%%%%%
    
    % Vassilis Files
    VP_EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,['Bx' session]) & endsWith(file_list,'_emg50to1kN.mat')),'UniformOutput',false);
    
    % Caleb Files
    CS_EMG_files = cellfun(@(x)[subject_filepath_base x],file_list(startsWith(file_list,'CO_EMGs')),'UniformOutput',false);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            muscle_names = fieldnames(trialwise_EMG);
            muscle_names = muscle_names(startsWith(muscle_names,['EMG']));
            trial_start = [trial_start [trialwise_EMG.trial_start]];
            trial_end = [trial_end [trialwise_EMG.trial_end]];
            
            for iMuscle = 1:length(muscle_names)
                if iFile == 1
                    EMG_signals{iMuscle} = {trialwise_EMG.(muscle_names{iMuscle})};
                else
                    EMG_signals{iMuscle} = [EMG_signals{iMuscle} {trialwise_EMG.(muscle_names{iMuscle})}];
                end
            end
            clear trialwise_EMG
        end
    end
elseif strcmp(task,'center_out')
%     for iFile = 1:length(EMG_files)
%         load(block_events_file{iFile},'isSuccess');
        
        %         load(EMG_files_for_names{iFile});
        %         muscle_names = fieldnames(trialwise_EMG);
        %         muscle_names = muscle_names(startsWith(muscle_names,['EMG']));
%         clear trialwise_EMG
        %         for iMuscle = 1:length(muscle_names)
        %             for iTrial = 1:size(emgPERION{iMuscle},1)
        %                 emg_temp{iTrial} = emgPERION{iMuscle}(iTrial,:);
        %             end
        %             if iFile == 1
        %                 EMG_signals{iMuscle} = emg_temp;
        %             else
        %                 EMG_signals{iMuscle} = [EMG_signals{iMuscle} emg_temp];
        %             end
        %             clear emg_temp
        %         end
        %         clear emgPERION;
        %     end
        %
        %     % Feed Unprocessed CO EMG Signals Into Processing Pipeline
        %
        %     EMG_signals = process_CO_EMGs_CS(EMG_signals);
        %
        %     %
        
        % Testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %         Vassilis
        %             for iFile = 1:length(VP_EMG_files)
        %                 load(VP_EMG_files{iFile});
        %                 load(block_events_file{iFile},'isSuccess');
        %                 t = emgt;
        %
        %                 load(EMG_files_for_names{iFile});
        %                 muscle_names = fieldnames(trialwise_EMG);
        %                 muscle_names = muscle_names(startsWith(muscle_names,['EMG']));
        %                 clear trialwise_EMG
        %                 for iMuscle = 1:length(muscle_names)
        %                     for iTrial = 1:size(emgPERION{iMuscle},1)
        %                         emg_temp{iTrial} = emgPERION{iMuscle}(iTrial,:);
        %                     end
        %                     if iFile == 1
        %                         VP_EMG_signals{iMuscle} = emg_temp;
        %                     else
        %                         VP_EMG_signals{iMuscle} = [VP_EMG_signals{iMuscle} emg_temp];
        %                     end
        %                     clear emg_temp
        %                 end
        %                 clear emgPERION;
%     end
    
    
    % Caleb
    for iFile = 1:length(CS_EMG_files)
        load(EMG_files{iFile});
        t = emgt;
        load(CS_EMG_files{iFile});
        muscle_names = fieldnames(trialwise_EMG);
        muscle_names = muscle_names(startsWith(muscle_names,['EMG']));
        trial_start = [trial_start [trialwise_EMG.trial_start]];
        trial_end = [trial_end [trialwise_EMG.trial_end]];
        
        for iMuscle = 1:length(muscle_names)
            if iFile == 1
                CS_EMG_signals{iMuscle} = {trialwise_EMG.(muscle_names{iMuscle})};
            else
                CS_EMG_signals{iMuscle} = [CS_EMG_signals{iMuscle} {trialwise_EMG.(muscle_names{iMuscle})}];
            end
        end
        clear trialwise_EMG
    end
end

EMG_signals = CS_EMG_signals;
%     EMG_signals = VP_EMG_signals;

% Testing Over %%%%%%%%%%%%%%%%%%%%%%%
if strcmp(task,'center_out')
    t = t/1000;
end
%% segment position and speed vectors into trials
if strcmp(task,'center_out')
    periOn_seconds = periOnPM_30k./30000;
end

% for each trial
trial_count = 1;
for iTrial = 1:size(cpl_st_trial_rew,1)
    if strcmp(task,'RTP')
        
        for iMuscle = 1:length(muscle_names)
            data(iTrial).(muscle_names{iMuscle}) = EMG_signals{iMuscle}{iTrial};
        end
        
    elseif strcmp(task,'center_out')
        
        % put in exception for 180323 here
        if isempty(data(iTrial).kinematic_timestamps)
        elseif contains(subject_filepath_base,'180323') > 0 && iTrial <= size(good_trials,2)
            for iMuscle = 1:length(muscle_names)
                data(iTrial).(muscle_names{iMuscle}) = EMG_signals{iMuscle}{trial_count}(t >= trial_start_relative_to_periOn(trial_count)' & t <= trial_end_relative_to_periOn(trial_count)');
            end
            trial_count = trial_count + 1;
        elseif contains(subject_filepath_base,'180323') == 0
            %
            for iMuscle = 1:length(muscle_names)
                data(iTrial).(muscle_names{iMuscle}) = EMG_signals{iMuscle}{iTrial}(t >= trial_start_relative_to_periOn(iTrial)' & t <= trial_end_relative_to_periOn(iTrial)');
            end
            
            
        end
    end
end
end
