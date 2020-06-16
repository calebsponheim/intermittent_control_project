function [hn_trained,data,meta] = train_HMM(meta,data)
% Load data
%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

trInd_train = find(cellfun(@(x) strcmp(x,'train'),[data.trial_classification]));
%% Prepare data
% Static parameters:

MAX_SPIKECOUNT = inf ; % Trim spikecounts at this value

trainset = cell(length(trInd_train),1);

for iTrial = 1 : length(data)
    
    % Get activations matrix, apply threshold:
    S = data(iTrial).spikecountresamp;
    S = S(:,1:(meta.bin_size*1000):end);
    S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
    
    % Save matrix to proper cell array:
    if any(iTrial==trInd_train) % if trial is in train set:
        trainset{iTrial==trInd_train} = S;
    end
end

%% Train model
% OUTPUT:
%   hn_trained - Struct with fields:
%   .a - Transition matrix, s.t.,
%       hn_trained.a(i,j) = P(S(t+1) = j|S(t) = i)
%   .b - Emission matrix in a tabular form, s.t.,
%       hn_trained.b(i,j,k) = P(O = j|S = i) for unit k (i.e,. probability
%       of observing j spikes in unit k, given that the current state = i.
rng('shuffle'); % Reshuffle seed
hn_trained = ehmmTrainAnneal(trainset',meta.num_states_subject);

end
