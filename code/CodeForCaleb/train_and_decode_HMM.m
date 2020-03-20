function [trInd_train,trInd_test,hn_trained,dc,dc_trainset,seed_to_train,trInd_train_validation] = train_and_decode_HMM(data,num_states_subject,data_RTP,data_center_out,crosstrain,seed_to_train,TRAIN_PORTION)
% example script built from Naama Kadmon Harpaz

% Load data
%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

if crosstrain == 1 % RTP model, center-out decode
    NumTrials_train = length(data_RTP);
    NumTrials_test = length(data_center_out);
    data = data_RTP;
    data_test = data_center_out;
elseif crosstrain == 2 % Center-out model, RTP decode
    NumTrials_train = length(data_center_out);
    NumTrials_test = length(data_RTP);
    data = data_center_out;
    data_test = data_RTP;
elseif crosstrain == 3
    disp('this is where you combine things')
    data = [data_center_out data_RTP];
    NumTrials_train = length(data);
else
    NumTrials_train = length(data); % Number of trials
end

%% Prepare data
% Static parameters:
if crosstrain > 0 && crosstrain < 3
    TRAIN_PORTION = 0.75; % Portion of trials from the first task to use for training
    TEST_PORTION = 1; % Portion of trials from the second task to use for training
else
    TRAIN_PORTION = TRAIN_PORTION; % Portion of trials to use for training
end

if crosstrain > 0 && crosstrain < 3
MAX_SPIKECOUNT = min([max(max([data_test.spikecount])),max(max([data.spikecount]))]) ; % Trim spikecounts at this value 
rp_test = randperm(length(data_test)); % Get shuffled trial indices
else
MAX_SPIKECOUNT = inf ; % Trim spikecounts at this value
end
%

rng(seed_to_train); % Set seed for repeatability
rp = randperm(length(data)); % Get shuffled trial indices
if crosstrain > 0 && crosstrain < 3
    nTrainTrials = round(TRAIN_PORTION*length(data)); % #train trials
    trInd_train = sort(rp(1:nTrainTrials)); % train indices
    trInd_train_validation = sort(rp(nTrainTrials+1:end)); % test indices

    nTestTrials = round(TEST_PORTION*length(data_test)); % #train trials
    trInd_test = sort(rp_test(1:nTestTrials)); % train indices    
    trainset_validation = cell(size(trInd_train_validation));
else    
    % % Randomly divide into train/test trials..
    % seed_to_train = rand(1)*1000;
    nTrainTrials = round(TRAIN_PORTION*length(data)); % #train trials
    trInd_train = sort(rp(1:nTrainTrials)); % train indices
    trInd_test = sort(rp(nTrainTrials+1:end)); % test indices
end

% Save data to arrays..
trainset = cell(size(trInd_train));
testset = cell(size(trInd_test));
fullset = cell(1,NumTrials_train);

for iTrial = 1 : NumTrials_train
    
    % Get activations matrix, apply threshold:
    S = data(iTrial).spikecount ;
    S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
    
    % Save matrix to proper cell array:
    if any(iTrial==trInd_train) % if trial is in train set:
        trainset{iTrial==trInd_train} = S;
    else % else, trial is in test set:
        if crosstrain > 0 && crosstrain < 3
            trainset_validation{iTrial==trInd_train_validation} = S;
        else
            testset{iTrial==trInd_test} = S;
        end
    end
    
    fullset{iTrial} = S;
    
end

if crosstrain > 0 && crosstrain < 3
    clear testset
    testset = cell(size(trInd_test));
    
    for iTrial = 1:NumTrials_test
        % Get activations matrix, apply threshold:
        S = data_test(iTrial).spikecount ;
        S(S>MAX_SPIKECOUNT) = MAX_SPIKECOUNT;
        if any(iTrial==trInd_test) % if trial is in train set:
            testset{iTrial==trInd_test} = S;
        end
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
rng('shuffle'); % Reshuffle seed
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
dc_trainset = ehmmDecode(hn_trained,trainset) ;
if crosstrain == 0
    trInd_train_validation = [];
end
end
