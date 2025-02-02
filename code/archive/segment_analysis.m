function [trialwise_states] = ...
    segment_analysis(trInd_test,dc_thresholded,bin_timestamps,data,...
    subject,muscle_names,include_EMG_analysis,target_locations)
% Link Kinematics to Neural States

% This function takes in the decoded latent states from the HMM and links them, 
% by each test trial, to the appropriate kinematics.
% In order to correctly run this function, you need to
% have run "nicho_data_to_organized_spiketimes_for_HMM",
% "train_and_decode_HMM", "processing_kinematics", 
% and "censor_and_threshold_HMM_output".

% get test trial indices
% get state info from test trials
% get kinematics for test trials
clear trialwise_states
clc
for iTrial = 1:length(trInd_test)
    trialwise_states(iTrial).test_indices = trInd_test(iTrial);
    trialwise_states(iTrial).latent_state = dc_thresholded(iTrial).maxprob_state;
    trialwise_states(iTrial).latent_state_bin_timestamp = ...
        bin_timestamps{trialwise_states(iTrial).test_indices};
    
    % calculating beginning and end of classified kinematics, cutting off
    trialwise_states(iTrial).speed = data(trialwise_states(iTrial).test_indices).speed;
    
    if strcmp(subject,'RS') == 0
        trialwise_states(iTrial).acceleration = ...
            data(trialwise_states(iTrial).test_indices).acceleration;
    end
    
    trialwise_states(iTrial).x_smoothed = ...
        data(trialwise_states(iTrial).test_indices).x_smoothed;
    trialwise_states(iTrial).y_smoothed = ...
        data(trialwise_states(iTrial).test_indices).y_smoothed;
    trialwise_states(iTrial).kinematic_timestamps = ...
        data(trialwise_states(iTrial).test_indices).kinematic_timestamps;
    
    if isfield(data, 'tp') && ~isempty(data(trialwise_states(iTrial).test_indices).tp)
        trialwise_states(iTrial).tp = data(trialwise_states(iTrial).test_indices).tp;
        trialwise_states(iTrial).target = data(trialwise_states(iTrial).test_indices).target;
        
        %okay: so, this is where we turn "tp" into meaningful target
        %designations instead of just, like, TP numbers which don't mean
        %anything other than the person who made the freakin task in
        %Dexterit-E. It's going to take an input into the function.
        
        trialwise_states(iTrial).target_location = target_locations{trialwise_states(iTrial).tp};
    else    
        trialwise_states(iTrial).tp = [];
        trialwise_states(iTrial).target = [];
        trialwise_states(iTrial).target_location = [];
    end
    
    if include_EMG_analysis == 1
        for iMuscle = 1:length(muscle_names)
            trialwise_states(iTrial).(muscle_names{iMuscle}) = ...
                data(trialwise_states(iTrial).test_indices).(muscle_names{iMuscle});
        end
    end
    % Split each trial into segments
    % Put each segment's neural timestamps in a cell row based on the state number
    
    segment_count = 0;
    segment_bin = 0;
    
    for iBin = 1:(size(trialwise_states(iTrial).latent_state,2))
        
        if iBin == 1
            if isnan(trialwise_states(iTrial).latent_state(1))
            elseif ~isnan(trialwise_states(iTrial).latent_state(1)) && ...
                    (trialwise_states(iTrial).latent_state(1) == trialwise_states(iTrial).latent_state(2))
                segment_count = 1;
                
                % assigning two bins to neural segment
                trialwise_states(iTrial).neural_state_segment{1}(1) = ...
                    trialwise_states(iTrial).latent_state_bin_timestamp(1);
                trialwise_states(iTrial).segment_state_number(1) = ...
                    trialwise_states(iTrial).latent_state(1);
                trialwise_states(iTrial).neural_state_segment{1}(2) = ...
                    trialwise_states(iTrial).latent_state_bin_timestamp(2);
                
                segment_bin = 2;
%                 iBin = 2;
            elseif ~isnan(trialwise_states(iTrial).latent_state(1))
                disp('something''s wrong')
            end
%         elseif iBin == 2 && ~isempty(trialwise_states(iTrial).neural_state_segment{1}(2))
        elseif iBin == (size(trialwise_states(iTrial).latent_state,2))
            if isnan(trialwise_states(iTrial).latent_state(iBin))
                
                % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (trialwise_states(iTrial).latent_state(iBin - 1) ~= ...
                    trialwise_states(iTrial).latent_state(iBin))
                % if the bin ahead is the same as current bin
            elseif trialwise_states(iTrial).latent_state(iBin - 1) == ...
                    trialwise_states(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = ...
                    trialwise_states(iTrial).latent_state_bin_timestamp(iBin);
            end
            
        elseif iBin ~= 1
            % Checking for NaN cells and skipping them
            if isnan(trialwise_states(iTrial).latent_state(iBin))
                
                % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (trialwise_states(iTrial).latent_state(iBin - 1) ~= ...
                    trialwise_states(iTrial).latent_state(iBin)) && ...
                   (trialwise_states(iTrial).latent_state(iBin + 1) == ...
                    trialwise_states(iTrial).latent_state(iBin)) && ...
                    (~isempty(trialwise_states(iTrial).latent_state(iBin + 1)))
                
                segment_bin = 1; %resetting intra-segment bin number
                segment_count = segment_count + 1; % adding to the segment count
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = ...
                    trialwise_states(iTrial).latent_state_bin_timestamp(iBin);
                trialwise_states(iTrial).segment_state_number(segment_count) = ...
                    trialwise_states(iTrial).latent_state(iBin);
                
            elseif trialwise_states(iTrial).latent_state(iBin - 1) ~= trialwise_states(iTrial).latent_state(iBin)
                disp('something''s wrong')
                
                % if the bin ahead is the same as current bin
            elseif trialwise_states(iTrial).latent_state(iBin - 1) == trialwise_states(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = ...
                    trialwise_states(iTrial).latent_state_bin_timestamp(iBin);
                
            end
        end
    end
    
    % same with the kinematic timestamps associated with each segment (but + 100 ms)
    for iSegment = 1:size(trialwise_states(iTrial).neural_state_segment,2)
        if ~isempty(trialwise_states(iTrial).neural_state_segment{iSegment})
            trialwise_states(iTrial).segment_length(iSegment) = ...
                length(unique(trialwise_states(iTrial).neural_state_segment{iSegment}));
            
            if trialwise_states(iTrial).segment_length(iSegment) == 1
                disp("something is wrong");
            end
            
            
            segment_beginning = min(trialwise_states(iTrial).neural_state_segment{iSegment})+.10 - .025;
            segment_end = max(trialwise_states(iTrial).neural_state_segment{iSegment})+.10 + .025;
            
            [~,closest_first] = min(abs(segment_beginning - trialwise_states(iTrial).kinematic_timestamps));
            [~,closest_end] = min(abs(segment_end - trialwise_states(iTrial).kinematic_timestamps));
                        
            if length(trialwise_states(iTrial).x_smoothed) < closest_end
                closest_end = closest_end - 1;
            end
            
            
            
            trialwise_states(iTrial).segment_kinematic_speed{iSegment} = ...
            trialwise_states(iTrial).speed(closest_first:closest_end);
            
            if strcmp(subject,'RS') == 0
                trialwise_states(iTrial).segment_kinematic_acceleration{iSegment} = ...
                    trialwise_states(iTrial).acceleration(closest_first:closest_end);
            end
            
            trialwise_states(iTrial).segment_kinematic_x{iSegment} = ...
                trialwise_states(iTrial).x_smoothed(closest_first:closest_end);
            trialwise_states(iTrial).segment_kinematic_y{iSegment} = ...
                trialwise_states(iTrial).y_smoothed(closest_first:closest_end);
            trialwise_states(iTrial).segment_kinematic_timestamps{iSegment} = ...
                trialwise_states(iTrial).kinematic_timestamps(closest_first:closest_end);
            
            %Adding Muscles
            if include_EMG_analysis == 1
                for iMuscle = 1:length(muscle_names)
                    if iSegment < size(trialwise_states(iTrial).neural_state_segment,2)
                        
                        trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment} = ....
                            trialwise_states(iTrial).(muscle_names{iMuscle})(closest_first:closest_end);
                    
                    elseif iSegment == size(trialwise_states(iTrial).neural_state_segment,2)
                        
                        if length(trialwise_states(iTrial).kinematic_timestamps) == ...
                                length(trialwise_states(iTrial).(muscle_names{iMuscle}))
                            
                            trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment} = ...
                                trialwise_states(iTrial).(muscle_names{iMuscle})(closest_first:closest_end);
                        
                        elseif length(trialwise_states(iTrial).kinematic_timestamps) > ...
                                length(trialwise_states(iTrial).(muscle_names{iMuscle}))
                            
                            trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment} = ...
                                trialwise_states(iTrial).(muscle_names{iMuscle})(closest_first:closest_end-1);
                            trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}])...
                                {iSegment}(length(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})) = ...
                                trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment}(end);
                        
                        elseif length(trialwise_states(iTrial).kinematic_timestamps) < ...
                                length(trialwise_states(iTrial).(muscle_names{iMuscle}))
                            
                            trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment} = ...
                                trialwise_states(iTrial).(muscle_names{iMuscle})(closest_first:closest_end);
                        end
                    end
                end
            end
        end
    end
    
end