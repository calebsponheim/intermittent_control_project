function [data,meta] = assign_trials_to_HMM_group(data,meta)
% This function will assign categories to trials based on the percentage
% that need to be assigned to three categories: Training Data (meant for
% log-likelihood analysis and other cross-validation methods) ; Model
% Selection Data (meant to select the corrent number of hidden states) ;
% Test Data (will be decoded using the chosen model).


if meta.crosstrain > 0
    center_out_data_and_meta = ...
        load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' ...
        meta.subject 'center_out' meta.session 'CT0']);
    RTP_data_and_meta = ...
        load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' ...
        meta.subject 'RTP' meta.session 'CT0']);
    
    center_out_fieldnames = fieldnames(center_out_data_and_meta.data);
    RTP_fieldnames = fieldnames(RTP_data_and_meta.data);
    for iField = 1:length(center_out_fieldnames)
        trial_count = 1;
        if sum(cellfun(@(x) strcmp(center_out_fieldnames(iField),x),RTP_fieldnames)) > 0
            for iTrial = 1:length(center_out_data_and_meta.data)
                data(iTrial).(center_out_fieldnames{iField}) = center_out_data_and_meta.data(iTrial).(center_out_fieldnames{iField});
                data(iTrial).task = "center_out";
            end
            for iTrial = (length(center_out_data_and_meta.data)+1):(length(center_out_data_and_meta.data)+length(RTP_data_and_meta.data))
                data(iTrial).(center_out_fieldnames{iField}) = RTP_data_and_meta.data(trial_count).(center_out_fieldnames{iField});
                trial_count = trial_count+1;
                data(iTrial).task = "RTP";
            end
            %            data.(center_out_fieldnames{iField}) = vertcat(center_out_data_and_meta.data.(center_out_fieldnames{iField}),RTP_data_and_meta.data.(center_out_fieldnames{iField}));
        else
            for iTrial = 1:length(center_out_data_and_meta.data)
                data(iTrial).(center_out_fieldnames{iField}) = center_out_data_and_meta.data(iTrial).(center_out_fieldnames{iField});
                data(iTrial).task = "center_out";
            end
            for iTrial = (length(center_out_data_and_meta.data)+1):(length(center_out_data_and_meta.data)+length(RTP_data_and_meta.data))
                data(iTrial).(center_out_fieldnames{iField}) = [];
                data(iTrial).task = "RTP";
            end
        end
    end
    
    if meta.crosstrain == 1  % RTP MODEL, center-out DECODE
        % for each trial
        for iTrial = 1:size(data,2)
            % if the task is RTP
            if strcmp(data(iTrial).task,'RTP')
                
                % if the trial classification is train, leave it
                if strcmp(data(iTrial).trial_classification,'test')
                    % if the trial classification is test, change it to 'test_native'
                    data(iTrial).trial_classification = 'test_native';
                end
                % if the trial classification if model_select, leave it
                
                % if the task is center_out
            elseif strcmp(data(iTrial).task,'center_out')
                % set trial classification as test, regardless.
                data(iTrial).trial_classification = 'test';
            end
        end
    elseif meta.crosstrain == 2
        % for each trial
        for iTrial = 1:size(data,2)
            % if the task is center_out
            if strcmp(data(iTrial).task,'center_out')
                if strcmp(data(iTrial).trial_classification,'test')
                % if the trial classification is test, change it to 'test_native'
                    data(iTrial).trial_classification = 'test_native';
                end
            % if the task is RTP
            elseif strcmp(data(iTrial).task,'RTP')
               % set trial classification as test, regardless.
               data(iTrial).trial_classification = 'test';
            end
        end
    elseif meta.crosstrain == 3
        % nothing changes because it's combined, babyyyyyy
    else
        disp("this shouldn't be possible");
    end
elseif meta.crosstrain == 0 % 0: none |
    train_portion = meta.TRAIN_PORTION;
    model_select_portion = meta.MODEL_SELECT_PORTION;
    test_portion = meta.TEST_PORTION;
    
    number_of_trials = size(data,2);
    trial_indices = 1:number_of_trials;
    shuffled_indices = trial_indices(randperm(number_of_trials));
    
    train_trials = ...
        shuffled_indices(1:round(number_of_trials*train_portion));
    model_select_trials = ...
        shuffled_indices(round(number_of_trials*train_portion):...
        (round(number_of_trials*train_portion)+round(number_of_trials*model_select_portion)));
    test_trials = ...
        shuffled_indices((round(number_of_trials*train_portion)+round(number_of_trials*model_select_portion)):end);
    trial_classification = {};
    trial_classification(train_trials) = {'train'};
    trial_classification(model_select_trials) = {'model_select'};
    trial_classification(test_trials) = {'test'};
    
    for iTrial = 1:number_of_trials
        data(iTrial).trial_classification = trial_classification(iTrial);
    end
    
    % To Do: Implement an analysis of Dalton's "check empty trials" for
    % individual neurons
end
end