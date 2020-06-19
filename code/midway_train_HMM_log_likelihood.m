function midway_train_HMM_log_likelihood(filepath,num_states,num_iters)

load(filepath,'meta','data')

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

for iIter = 1:num_iters
    rng('shuffle'); % Reshuffle seed
    hn_trained{iIter} = ehmmTrainAnneal(trainset',num_states);
end
save([meta.subject,meta.task,meta.session,'_HMM_hn_',num2str(num_states),'_states_CT0'],'hn_trained')
end
