function [states_thresholded] = censor_and_threshold_HMM_states(states)
% Process and threshold HMM output

states_thresholded = states + 1;

for iTrial = 1:size(states_thresholded,1)
    
    for iBin = 2:size(states_thresholded,2)
    % any state with probability equal to or lower than 0.6 is removed
        if states_thresholded(iTrial,iBin) < 0.6
            states_thresholded(iTrial,iBin) = states_thresholded(iTrial,iBin-1);
        end
    end
end

for iTrial = 1:size(states_thresholded,1)

    % for each neural bin
    for iBin = 1:(size(states_thresholded,2)-1)
        
        if iBin == 1 % if it's the first bin
            % if the first bin's state matches the second bin's state, then no need to remove it
            if (states_thresholded(iTrial, iBin + 1) == states_thresholded(iTrial, iBin))
                
            % if the first bin does not match the second bin, then remove it.
            elseif (states_thresholded(iTrial, iBin + 1) ~= states_thresholded(iTrial, iBin))
                states_thresholded(iTrial, iBin) = states_thresholded(iTrial, iBin + 1);
            end
         
        % if the bin isn't 1
        elseif iBin ~= 1
            
            % if the previous bin matches the current bin, then don't remove it
            elseif (states_thresholded(iTrial, iBin - 1) == states_thresholded(iTrial, iBin)) || (states_thresholded(iTrial, iBin + 1) == states_thresholded(iTrial, iBin))

            % otherwise, the bins don't match, so remove the bin.
            else
                %dc_thresholded(iTrial).maxprob_state(iBin) = NaN;
                states_thresholded(iTrial, iBin) = states_thresholded(iTrial, iBin - 1);
        end
    end
    
    for iBin = 2:(size(states_thresholded,2)-1)
        if (states_thresholded(iTrial,iBin - 1) ~= states_thresholded(iTrial,iBin)) && (states_thresholded(iTrial,iBin + 1) ~= states_thresholded(iTrial,iBin))
                    %dc_thresholded(iTrial).maxprob_state(iBin) = NaN;
                    states_thresholded(iTrial,iBin) = states_thresholded(iTrial,iBin - 1);

        end
    end
    
end

states_thresholded = states_thresholded - 1;

%save("nicho_rs1050211_HMM_output_thresholded",'dc_thresholded');