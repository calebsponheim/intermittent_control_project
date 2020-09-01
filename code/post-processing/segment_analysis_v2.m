function [meta,data] = segment_analysis_v2(meta,data)


segment_count = ones(meta.optimal_number_of_states,1);
for iTrial = 1:size(data,2)
    for iState = 1:meta.optimal_number_of_states
        data_by_state(iState).
        segment_count(iState) = segment_count(iState)+length(
    end
end
end