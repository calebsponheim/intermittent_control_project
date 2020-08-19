function [data] = decode_with_optimal_states(data,meta)
%%
% This function is meant to use the "optimal state number" identified in
% the previous step to decode all trials in the data struct.

% load correct model data based on the optimal number of states
optimal_number_of_states = meta.optimal_number_of_states;
model_filepath = ['.\data_midway\hn_trained\' meta.subject meta.task num2str(meta.session) '_HMM_hn_' num2str(optimal_number_of_states) '_states_CT' num2str(meta.crosstrain)];
model_for_decode = load(model_filepath,'hn_trained');
model_for_decode = model_for_decode.hn_trained{1, 1};

[dc] = decode_trials(model_for_decode,data,meta);
bins = 1:50:4500;
for iTrial = 1:size(dc,1)
% resample the dc_thresholded struct to 1k
for iBin = 1:numel(bins)
    if iBin == 1
        resamp_range = 1:(meta.bin_size*1000);
    else
        resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
    end

    trial_resamp_temp(resamp_range) = dc(1).maxprob_state(iBin);
end


% put the decoded states into the data_struct
data(iTrial).states_resamp = trial_resamp_temp;

clear trial_resamp_temp

end
end