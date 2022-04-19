function [meta,data,snippet_data] = segment_analysis_v2(meta,data)
% a segment is a snippet is a segment is a snippet

snippet_count_per_state = ones(meta.optimal_number_of_states,1);

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

end % end of function