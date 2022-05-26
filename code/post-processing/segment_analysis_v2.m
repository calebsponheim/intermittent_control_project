function [meta,data,snippet_data,sorted_state_transitions] = segment_analysis_v2(meta,data)
% a segment is a snippet is a segment is a snippet

snippet_count_per_state = ones(meta.optimal_number_of_states,1);
iTransition = 1;
for iTrial = 1:size(data,2)
    trial_states = diff(data(iTrial).states_resamp);
    if sum(isnan(trial_states))>0
        disp("you've got nans in your states!")
        trial_state_nans = find(isnan(trial_states));
        trial_states(trial_state_nans) = 0;
        trial_states(max(trial_state_nans)) = 1;
        trial_states(min(trial_state_nans)) = 1;
        snippet_boundaries = find(trial_states~=0);
    elseif sum(trial_states == 0) > 0
        trial_state_zeros = find(trial_states == 0);
        trial_states(trial_state_zeros) = 0;
        trial_states(max(trial_state_zeros)) = 1;
        trial_states(min(trial_state_zeros)) = 1;
        snippet_boundaries = find(trial_states~=0);
    else
        snippet_boundaries = [1 find(trial_states~=0)];
    end
    for iSnippet = 1:(numel(snippet_boundaries)-1)
        if snippet_boundaries(iSnippet) ~= 1
            state_transitions(iTransition,1:2) = data(iTrial).states_resamp(snippet_boundaries(iSnippet):snippet_boundaries(iSnippet)+1);
            state_transitions_combined(iTransition) = str2double([num2str(state_transitions(iTransition,1)) num2str(state_transitions(iTransition,2))]);
            iTransition = iTransition + 1;
        end
        iState = data(iTrial).states_resamp(snippet_boundaries(iSnippet)+1);
        if iState == 0
        else
            snippet_data(iState).snippet_trial(snippet_count_per_state(iState)) = iTrial;
            if iSnippet == 1
                snippet_data(iState).snippet_timestamps{snippet_count_per_state(iState)} = (snippet_boundaries(iSnippet)):(snippet_boundaries(iSnippet+1));
            else
                snippet_data(iState).snippet_timestamps{snippet_count_per_state(iState)} = (snippet_boundaries(iSnippet)+1):(snippet_boundaries(iSnippet+1));
            end
            snippet_count_per_state(iState) = snippet_count_per_state(iState) + 1;
        end
    end
end

% Count up occurences of transitions
[N,X] = histc(state_transitions_combined',unique(state_transitions_combined));
M = [state_transitions(:,1),state_transitions(:,2),N(X)];
[~, I] = sort(N(X),'descend');
sorted_state_transitions = M(I, :);
sorted_state_transitions = unique(sorted_state_transitions,'rows');
[~, I] = sort(sorted_state_transitions(:,3),'descend');
sorted_state_transitions = sorted_state_transitions(I, :);

end % end of function