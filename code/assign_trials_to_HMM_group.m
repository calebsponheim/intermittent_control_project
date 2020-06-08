function [data] = assign_trials_to_HMM_group(data,meta,data_center_out,data_RTP)
% This function will assign categories to trials based on the percentage
% that need to be assigned to three categories: Training Data (meant for
% log-likelihood analysis and other cross-validation methods) ; Model
% Selection Data (meant to select the corrent number of hidden states) ;
% Test Data (will be decoded using the chosen model).


if meta.crosstrain == 1 % 1: RTP model, center-out decode
    if strcmp(meta.task,'RTP')
    elseif strcmp(meta.task,'center_out')
    end
elseif meta.crosstrain == 2 % 2: Center-out model, RTP decode
    if strcmp(meta.task,'RTP')
    elseif strcmp(meta.task,'center_out')
    end
elseif meta.crosstrain == 3 % 3: both tasks together
    
    % Add "task" label to the structs, based on data_RTP and
    % data_center_out
    
    if strcmp(meta.task,'RTP')
    elseif strcmp(meta.task,'center_out')
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