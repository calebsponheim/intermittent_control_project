function [HMMdecode,out] = smoothHmmDecode(HMMdecode,probTh,minDuration)
% INPUT:
%   HMMdecode - project's hmm decode struct
%   probTh - probability threshold
%   minDuration - minimum duration of state to allow (seconds)
%
% OUTPUT:
%   - HMMdecode struct after smoothing.
%   - out(i) contains additional information regarding HMMdecode(i)


binsize = mean(diff(HMMdecode(1).time_stamps));
minStateLength = round(minDuration/binsize);
out = StructInit(length(HMMdecode),...
    'changedBinsNum','changedBinsPortion',...
    'stateBinLength','stateSecLength');
for i = 1 : length(HMMdecode)
    
    prob = HMMdecode(i).PSTATES;
    [maxprob_prob,maxprob_state] = max(prob,[],1);
    maxprob_prob = [ maxprob_prob 1 ];
    maxprob_state = [ maxprob_state -1 ];
    
    states = maxprob_state;
    stateLength = 1;
    for t = 2 : length(maxprob_prob)
        
        % *
        % probability threshold:
        
        if maxprob_prob(t)>probTh % if state's prob is above thresh
            states(t) = maxprob_state(t);
            
        else % if state's prob is below thresh, use previus state
            states(t) = states(t-1);
        end
        
        % *
        % duration threshold:
        
        if (states(t) == states(t-1)) && (states(t)~=0)
            % no state change, increment length count
            stateLength = stateLength+1;
            
        elseif states(t) ~= states(t-1)
            % state was changed. if last state was too short, replace it
            % with the (stable) state that came before it:
            if (t-stateLength-1)>0 && stateLength < minStateLength
                states(t+(-stateLength:-1)) = states(t-stateLength-1);
            end
            
            % initalize state length count:
            stateLength = 1;
        end
        
    end
    states = states(1:end-1);
    
    % write data to struct:
    state_change_bins = [ 0 find(diff(states)~=0) ]+1 ;
    state_change_seq = states(state_change_bins);
    
    HMMdecode(i).states = states;
    HMMdecode(i).states_changes = state_change_bins;
    HMMdecode(i).times_changes = ...
        HMMdecode(i).time_stamps(HMMdecode(i).states_changes);
    HMMdecode(i).states_seq = state_change_seq ;
    
    % additional output:
    out(i).changedBinsNum = nnz(states~=maxprob_state(1:end-1));
    out(i).changedBinsPortion = out(i).changedBinsNum/length(states);
    out(i).stateBinLength = diff([ state_change_bins length(states)+1 ]);
    out(i).stateSecLength = out(i).stateBinLength*binsize;
end



