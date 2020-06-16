function [data,meta] = assign_trials_to_HMM_group(data,meta)
% This function will assign categories to trials based on the percentage
% that need to be assigned to three categories: Training Data (meant for
% log-likelihood analysis and other cross-validation methods) ; Model
% Selection Data (meant to select the corrent number of hidden states) ;
% Test Data (will be decoded using the chosen model).


if meta.crosstrain > 0 % 1: RTP model, center-out decode
    center_out_data_and_meta = ...
        load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' ...
        meta.subject 'center_out' meta.session]);
    RTP_data_and_meta = ...
        load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' ...
        meta.subject 'RTP' meta.session]);
    
    center_out_fieldnames = fieldnames(center_out_data_and_meta.data);
    RTP_fieldnames = fieldnames(RTP_data_and_meta.data);
    for iField = 1:length(center_out_fieldnames)
       if sum(cellfun(@(x) strcmp(center_out_fieldnames(iField),x),RTP_fieldnames)) > 0
           for iTrial = 1:length(center_out_data_and_meta.data)
               data(iTrial).(center_out_fieldnames{iField}) = center_out_data_and_meta.data(iTrial).(center_out_fieldnames{iField});
           end
           for iTrial = (length(center_out_data_and_meta.data)+1):(length(center_out_data_and_meta.data)+length(RTP_data_and_meta.data))
               data(iTrial).(center_out_fieldnames{iField}) = RTP_data_and_meta.data(iTrial).(center_out_fieldnames{iField});
           end
%            data.(center_out_fieldnames{iField}) = vertcat(center_out_data_and_meta.data.(center_out_fieldnames{iField}),RTP_data_and_meta.data.(center_out_fieldnames{iField}));
       else
           for iTrial = 1:length(center_out_data_and_meta.data)
               data(iTrial).(center_out_fieldnames{iField}) = center_out_data_and_meta.data(iTrial).(center_out_fieldnames{iField});
           end
           for iTrial = (length(center_out_data_and_meta.data)+1):(length(center_out_data_and_meta.data)+length(RTP_data_and_meta.data))
               data(iTrial).(center_out_fieldnames{iField}) = [];
           end
       end
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