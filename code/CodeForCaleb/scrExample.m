% example script

% Load data
%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix, 
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

NumTrials = length(data); % Number of trials

%% Prepare data
% Static parameters:
TRAIN_PORTION = 0.75; % Portion of trials to use for training
MAX_SPIKECOUNT = inf ; % Trim spikecounts at this value
% 
% % Radnomly divide into train/test trials..
seed_to_train = rand(1)*1000;
rng(seed_to_train); % Set seed for repeatability
rp = randperm(length(data)); % Get shuffled trial indices
nTrainTrials = round(TRAIN_PORTION*length(data)); % #train trials
trInd_train = sort(rp(1:nTrainTrials)); % train indices
trInd_test = sort(rp(nTrainTrials+1:end)); % test indices
rng('shuffle'); % Reshuffle seed

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
%%

NUM_STATES = num_states_subject ; % Number of states to train the model on.

save(strcat('HMM_params',num2str(NUM_STATES),'_states_',date))

%% Train model
% OUTPUT:
%   hn_trained - Struct with fields:
%   .a - Transition matrix, s.t., 
%       hn_trained.a(i,j) = P(S(t+1) = j|S(t) = i)
%   .b - Emission matrix in a tabular form, s.t.,
%       hn_trained.b(i,j,k) = P(O = j|S = i) for unit k (i.e,. probability
%       of observing j spikes in unit k, given that the current state = i.

% 



hn_trained = ehmmTrainAnneal(trainset,NUM_STATES);
%%

% save(strcat(subject,'HMM_trained_out_',date,num2str(NUM_STATES),'_states_','hn_trained'))

%% Decode
% OUTPUT:
%   dc - Struct array with fields:
%   .prob - Matrix of S x T, S = # of states, T = # of time bins
%       dc(iTrial).prob(s,t) = decoded probability of state s
%       at time bin t during trial iTrial.
%   .maxprob - Vector of length T, s.t., dc(iTrial).maxprob(t) = state
%       with maximal probability at time bin t.

dc = ehmmDecode(hn_trained,testset) ;


