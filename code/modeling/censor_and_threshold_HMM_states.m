function [states_thresholded] = censor_and_threshold_HMM_states(states_thresholded)
% Process and threshold HMM output

% for iTrial = 1:size(states_thresholded,1)
%
%     for iBin = 2:size(states_thresholded,2)
%     % any state with probability equal to or lower than 0.6 is removed
%         if states_thresholded(iTrial,iBin) < 0.6
%             states_thresholded(iTrial,iBin) = states_thresholded(iTrial,iBin-1);
%         end
%     end
% end
for iTrial = 1:size(states_thresholded,1)
    num_bins = length(states_thresholded(iTrial,~isnan(states_thresholded(iTrial,:))));
    if (states_thresholded(iTrial, 2) ~= states_thresholded(iTrial, 1))
        states_thresholded(iTrial, 1) = states_thresholded(iTrial, 2);
    end

    % for each neural bin
    for iBin = 2:(num_bins-1)
        % if the previous bin matches the current bin, then don't remove it
        if (states_thresholded(iTrial, iBin - 1) == states_thresholded(iTrial, iBin)) || (states_thresholded(iTrial, iBin + 1) == states_thresholded(iTrial, iBin))

        else
            % otherwise, the bins don't match, so remove the bin.
            states_thresholded(iTrial, iBin) = states_thresholded(iTrial, iBin - 1);
        end
    end

    for iBin = 2:(num_bins-1)
        if (states_thresholded(iTrial,iBin - 1) ~= states_thresholded(iTrial,iBin)) && (states_thresholded(iTrial,iBin + 1) ~= states_thresholded(iTrial,iBin))
            states_thresholded(iTrial,iBin) = states_thresholded(iTrial,iBin - 1);
        end
    end

end