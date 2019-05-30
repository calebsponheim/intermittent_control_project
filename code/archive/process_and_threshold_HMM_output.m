% Process and threshold HMM output

% filepath = '\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\nicho_rs1050211_HMM_output.mat';
%
% load(filepath,'dc');
dc_thresholded = dc;
% clear dc

for iTrial = 1:size(dc_thresholded,2)
    
    for iBin = 2:size(dc_thresholded(iTrial).maxprob_state,2)
    % any state with probability equal to or lower than 0.6 is removed
        if dc_thresholded(iTrial).maxprob_prob(iBin) < 0.6
            dc_thresholded(iTrial).maxprob_state(iBin) = dc_thresholded(iTrial).maxprob_state(iBin-1);
        end
    end
end

for iTrial = 1:size(dc_thresholded,2)

    % for each neural bin
    for iBin = 1:(size(dc_thresholded(iTrial).maxprob_state,2)-1)
        
        if iBin == 1 % if it's the first bin
            % if the first bin's state matches the second bin's state, then no need to remove it
            if (dc_thresholded(iTrial).maxprob_state(iBin + 1) == dc_thresholded(iTrial).maxprob_state(iBin))
                
            % if the first bin does not match the second bin, then remove it.
            elseif (dc_thresholded(iTrial).maxprob_state(iBin + 1) ~= dc_thresholded(iTrial).maxprob_state(iBin))
                dc_thresholded(iTrial).maxprob_state(iBin) = NaN;
            end
         
        % if the bin isn't 1
        elseif iBin ~= 1
            
            % if the previous bin matches the current bin, then don't remove it
            elseif (dc_thresholded(iTrial).maxprob_state(iBin - 1) == dc_thresholded(iTrial).maxprob_state(iBin)) || (dc_thresholded(iTrial).maxprob_state(iBin + 1) == dc_thresholded(iTrial).maxprob_state(iBin))

            % otherwise, the bins don't match, so remove the bin.
            else
                %dc_thresholded(iTrial).maxprob_state(iBin) = NaN;
                dc_thresholded(iTrial).maxprob_state(iBin) = dc_thresholded(iTrial).maxprob_state(iBin - 1);
        end
    end
    
    for iBin = 2:(size(dc_thresholded(iTrial).maxprob_state,2)-1)
        if (dc_thresholded(iTrial).maxprob_state(iBin - 1) ~= dc_thresholded(iTrial).maxprob_state(iBin)) && (dc_thresholded(iTrial).maxprob_state(iBin + 1) ~= dc_thresholded(iTrial).maxprob_state(iBin))
                    %dc_thresholded(iTrial).maxprob_state(iBin) = NaN;
                    dc_thresholded(iTrial).maxprob_state(iBin) = dc_thresholded(iTrial).maxprob_state(iBin - 1);

        end
    end
end

%save("nicho_rs1050211_HMM_output_thresholded",'dc_thresholded');