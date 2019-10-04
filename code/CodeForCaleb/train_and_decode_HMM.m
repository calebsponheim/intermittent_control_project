function [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,data_RTP,data_center_out,crosstrain)
% example script built from Naama Kadmon Harpaz

% Load data
%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.
if crosstrain == 1 % RTP model, center-out decode
    NumTrials = length(data_RTP);
    data = data_RTP;
    data_test = data_center_out;
elseif crosstrain == 2 % Center-out model, RTP decode
    NumTrials = length(data_center_out);
    data = data_center_out;
    data_test = data_RTP;
elseif crosstrain == 3
    disp('this is where you combine things')
    data = [data_center_out data_RTP];
    NumTrials = length(data);
else
    NumTrials = length(data); % Number of trials
end
%% Prepare data
% Static parameters:
if crosstrain > 0 && crosstrain < 3
    TRAIN_PORTION = .75; % Portion of trials to use for training
else
    TRAIN_PORTION = 0.75; % Portion of trials to use for training
end
MAX_SPIKECOUNT = inf ; % Trim spikecounts at this value
%

if crosstrain > 0 && crosstrain < 3
    trInd_train = 1:NumTrials;
    trInd_test = 1:length(data_test);
    seed_to_train = rand(1)*1000;
else
    
% % Randomly divide into train/test trials..
seed_to_train = rand(1)*1000;
rng(seed_to_train); % Set seed for repeatability
rp = randperm(length(data)); % Get shuffled trial indices
nTrainTrials = round(TRAIN_PORTION*length(data)); % #train trials
trInd_train = sort(rp(1:nTrainTrials)); % train indices
trInd_test = sort(rp(nTrainTrials+1:end)); % test indices
rng('shuffle'); % Reshuffle seed
end

% Save data to arrays..
trainset = cell(size(trInd_train));
testset = cell(size(trInd_test));
fullset = cell(1,NumTrials);

for iTrial = 1 : NumTrials
    
        % Get activations matrix, apply threshold:
        S = data(iTrial).spikecount ;
        S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
        
        % Save matrix to proper cell array:
        if any(iTrial==trInd_train) % if trial is in train set:
            trainset{iTrial==trInd_train} = S;
        else % else, trial is in test set:
            testset{iTrial==trInd_test} = S;
        end
        
        fullset{iTrial} = S;
    
end

if crosstrain > 0 && crosstrain < 3
    for iTrial = 1:length(data_test)
        % Get activations matrix, apply threshold:
        S = data_test(iTrial).spikecount ;
        S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
        testset{iTrial} = S;
    end
end


NUM_STATES = num_states_subject ; % Number of states to train the model on.
%% Train model
% OUTPUT:
%   hn_trained - Struct with fields:
%   .a - Transition matrix, s.t.,
%       hn_trained.a(i,j) = P(S(t+1) = j|S(t) = i)
%   .b - Emission matrix in a tabular form, s.t.,
%       hn_trained.b(i,j,k) = P(O = j|S = i) for unit k (i.e,. probability
%       of observing j spikes in unit k, given that the current state = i.

hn_trained = ehmmTrainAnneal(trainset,NUM_STATES);

%% Decode
% OUTPUT:
%   dc - Struct array with fields:
%   .prob - Matrix of S x T, S = # of states, T = # of time bins
%       dc(iTrial).prob(s,t) = decoded probability of state s
%       at time bin t during trial iTrial.
%   .maxprob - Vector of length T, s.t., dc(iTrial).maxprob(t) = state
%       with maximal probability at time bin t.

dc = ehmmDecode(hn_trained,testset) ;

if seed_to_train
else
    seed_to_train = 0;
end
