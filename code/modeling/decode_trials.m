function [dc] = decode_trials(hn_trained,data,meta)
% Maybe add tag for "cleaning/thresholding" the dc, with the "threshold"
% function nested in here? just a "0" or "1".

MAX_SPIKECOUNT = inf ; % Trim spikecounts at this value

decodeset = cell(length(data),1);

for iTrial = 1 : length(data)
    
    % Get activations matrix, apply threshold:
    S = data(iTrial).spikecountresamp;
    S = S(:,1:(meta.bin_size*1000):end);
    S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
    
    % Save matrix to proper cell array:
        decodeset{iTrial} = S;
end

dc = ehmmDecode(hn_trained,decodeset);
dc = censor_and_threshold_HMM_output(dc);
end
