function [data,meta] = decode_with_optimal_states(data,meta)
%%
% This function is meant to use the "optimal state number" identified in
% the previous step to decode all trials in the data struct.

% load correct model data based on the optimal number of states

if meta.crosstrain == 0 || meta.crosstrain == 3
    optimal_number_of_states = meta.optimal_number_of_states;
    model_filepath = ['.\data_midway\hn_trained\' meta.subject meta.task num2str(meta.session) '_HMM_hn_' num2str(optimal_number_of_states) '_states_CT' num2str(meta.crosstrain)];
elseif meta.crosstrain == 1 % RTP MODEL, center-out DECODE
    %load midway version of data, but just the optimal states estimate, nothing else
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        meta_for_model = load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\data_with_optimal_states_estimate\' meta.subject 'RTP' meta.session 'CT0'], 'meta');
    else
        meta_for_model = load(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\data_with_optimal_states_estimate\',meta.subject,'RTP','_HMM_struct_',date),'meta');
    end
    optimal_number_of_states = meta_for_model.meta.optimal_number_of_states;
    meta.optimal_number_of_states = optimal_number_of_states;
    model_filepath = ['.\data_midway\hn_trained\' meta.subject 'RTP' num2str(meta.session) '_HMM_hn_' num2str(optimal_number_of_states) '_states_CT0'];
elseif meta.crosstrain == 2 % center-out MODEL, RTP DECODE
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        meta_for_model = load(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\data_with_optimal_states_estimate\' meta.subject 'center_out' meta.session 'CT0'], 'meta');
    else
        meta_for_model = load(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\data_with_optimal_states_estimate\',meta.subject,'center_out','_HMM_struct_',date),'meta');
    end
    optimal_number_of_states = meta_for_model.meta.optimal_number_of_states;
    meta.optimal_number_of_states = optimal_number_of_states;
    model_filepath = ['.\data_midway\hn_trained\' meta.subject 'center_out' num2str(meta.session) '_HMM_hn_' num2str(optimal_number_of_states) '_states_CT0'];
end

model_for_decode = load(model_filepath,'hn_trained');
model_for_decode = model_for_decode.hn_trained{1, 1};


[dc] = decode_trials(model_for_decode,data,meta);
for iTrial = 1:size(dc,1)
    bins = 1:50:size(data(iTrial).ms_relative_to_trial_start,2);
    % resample the dc_thresholded struct to 1k
    for iBin = 1:numel(bins)
        if iBin == 1
            resamp_range = 1:(meta.bin_size*1000);
        else
            resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
        end
        
        trial_resamp_temp(resamp_range) = dc(iTrial).maxprob_state(iBin);
    end
    
    trial_resamp_temp = trial_resamp_temp(1:size(data(iTrial).ms_relative_to_trial_start,2));
    % put the decoded states into the data_struct
    data(iTrial).states_resamp = trial_resamp_temp;
    meta.hn = model_for_decode;
    clear trial_resamp_temp
    
end
end