% Link Kinematics to Neural States


num_states = num_states_subject;
% get test trial indices
% get state info from test trials
% get kinematics for test trials
clear trialwise_states
clc
for iTrial = 1:length(trInd_test)
    trialwise_states(iTrial).test_indices = trInd_test(iTrial);
    trialwise_states(iTrial).latent_state = dc_thresholded(iTrial).maxprob_state;
    trialwise_states(iTrial).latent_state_bin_timestamp = bin_timestamps{trialwise_states(iTrial).test_indices};
    trialwise_states(iTrial).speed = data(trialwise_states(iTrial).test_indices).speed;
    trialwise_states(iTrial).x_smoothed = data(trialwise_states(iTrial).test_indices).x_smoothed;
    trialwise_states(iTrial).y_smoothed = data(trialwise_states(iTrial).test_indices).y_smoothed;
    trialwise_states(iTrial).kinematic_timestamps = data(trialwise_states(iTrial).test_indices).kinematic_timestamps;
    
    % Split each trial into segments
    % Put each segment's neural timestamps in a cell row based on the state number
    
    segment_count = 0;
    segment_bin = 0;
    
    for iBin = 1:(size(trialwise_states(iTrial).latent_state,2))
        
        
        if iBin == 1
            if isnan(trialwise_states(iTrial).latent_state(1))
            elseif ~isnan(trialwise_states(iTrial).latent_state(1)) && (trialwise_states(iTrial).latent_state(1) == trialwise_states(iTrial).latent_state(2))
                segment_count = 1;

                % assigning two bins to neural segment
                trialwise_states(iTrial).neural_state_segment{1}(1) = trialwise_states(iTrial).latent_state_bin_timestamp(1);
                trialwise_states(iTrial).segment_state_number(1) = trialwise_states(iTrial).latent_state(1);                
                trialwise_states(iTrial).neural_state_segment{1}(2) = trialwise_states(iTrial).latent_state_bin_timestamp(2);
                
                segment_bin = 2;
            elseif ~isnan(trialwise_states(iTrial).latent_state(1))
                disp('something''s wrong')
            end
            
        elseif iBin == (size(trialwise_states(iTrial).latent_state,2))
            if isnan(trialwise_states(iTrial).latent_state(iBin))

            % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (trialwise_states(iTrial).latent_state(iBin - 1) ~= trialwise_states(iTrial).latent_state(iBin))
            % if the bin ahead is the same as current bin
            elseif trialwise_states(iTrial).latent_state(iBin - 1) == trialwise_states(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;            
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = trialwise_states(iTrial).latent_state_bin_timestamp(iBin);              
            end

        elseif iBin ~= 1
            % Checking for NaN cells and skipping them
            if isnan(trialwise_states(iTrial).latent_state(iBin))

            % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (trialwise_states(iTrial).latent_state(iBin - 1) ~= trialwise_states(iTrial).latent_state(iBin)) && (trialwise_states(iTrial).latent_state(iBin + 1) == trialwise_states(iTrial).latent_state(iBin)) && (~isempty(trialwise_states(iTrial).latent_state(iBin + 1)))

                segment_bin = 1; %resetting intra-segment bin number
                segment_count = segment_count + 1; % adding to the segment count
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = trialwise_states(iTrial).latent_state_bin_timestamp(iBin);
                trialwise_states(iTrial).segment_state_number(segment_count) = trialwise_states(iTrial).latent_state(iBin);

            elseif trialwise_states(iTrial).latent_state(iBin - 1) ~= trialwise_states(iTrial).latent_state(iBin)
                disp('something''s wrong')
            
            % if the bin ahead is the same as current bin
            elseif trialwise_states(iTrial).latent_state(iBin - 1) == trialwise_states(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;            
                trialwise_states(iTrial).neural_state_segment{segment_count}(segment_bin) = trialwise_states(iTrial).latent_state_bin_timestamp(iBin);
               
            end
        end
    end
    
    % same with the kinematic timestamps associated with each segment (but + 100 ms)
    for iSegment = 1:size(trialwise_states(iTrial).neural_state_segment,2)
        if ~isempty(trialwise_states(iTrial).neural_state_segment{iSegment})
            trialwise_states(iTrial).segment_length(iSegment) = length(unique(trialwise_states(iTrial).neural_state_segment{iSegment}));
                
                if trialwise_states(iTrial).segment_length(iSegment) == 1
                    disp("something is wrong");
                end

                
            segment_beginning = min(trialwise_states(iTrial).neural_state_segment{iSegment})+.10 - .025;
            segment_end = max(trialwise_states(iTrial).neural_state_segment{iSegment})+.10 + .025;
            
            [~,closest_first] = min(abs(segment_beginning - trialwise_states(iTrial).kinematic_timestamps));
            [~,closest_end] = min(abs(segment_end - trialwise_states(iTrial).kinematic_timestamps));
            
            closest_first = closest_first;
            closest_end = closest_end;
            
            if length(trialwise_states(iTrial).x_smoothed) < closest_end
                closest_end = closest_end - 1;
            end
            
            
            
            trialwise_states(iTrial).segment_kinematic_speed{iSegment} = trialwise_states(iTrial).speed(closest_first:closest_end);
            trialwise_states(iTrial).segment_kinematic_x{iSegment} = trialwise_states(iTrial).x_smoothed(closest_first:closest_end);
            trialwise_states(iTrial).segment_kinematic_y{iSegment} = trialwise_states(iTrial).y_smoothed(closest_first:closest_end);
            trialwise_states(iTrial).segment_kinematic_timestamps{iSegment} = trialwise_states(iTrial).kinematic_timestamps(closest_first:closest_end);
        end
    end
    
end

%%
colors = hsv(num_states);

%% Ok, so trying to plot a single trial?

for iTrial = 1:5%datasample(1:length(trInd_test),3)
    % Speed Plot
    figure('visible','off'); hold on
    plot(trialwise_states(iTrial).kinematic_timestamps,trialwise_states(iTrial).speed,'k')
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}(1),trialwise_states(iTrial).segment_kinematic_speed{iSegment}(1),'ko')
            plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment},trialwise_states(iTrial).segment_kinematic_speed{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:))
        end
    end
    title(strcat('Trial ',num2str(iTrial),' speed'));
    xlabel('time')
    box off
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_speed.png'));
    close(gcf);

    % Position Plot
    figure('visible','off'); hold on
    plot(trialwise_states(iTrial).x_smoothed,trialwise_states(iTrial).y_smoothed,'k')
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            plot(trialwise_states(iTrial).segment_kinematic_x{iSegment}(1),trialwise_states(iTrial).segment_kinematic_y{iSegment}(1),'ko')
            plot(trialwise_states(iTrial).segment_kinematic_x{iSegment},trialwise_states(iTrial).segment_kinematic_y{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:))
        end
    end
    plot(trialwise_states(iTrial).x_smoothed(1),trialwise_states(iTrial).y_smoothed(1),'ro')
    title(strcat('Test Trial ',num2str(iTrial),' position'));
    xlabel('x position');
    ylabel('y position');
    set(gcf,'Color','White');
    box off
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_position.png'));
    close(gcf);

end


%% Plotting segments by state, by coords
clear segment_analysis
global_segment_num = ones(1,num_states);
for iTrial = datasample(1:length(trInd_test),15)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}) && trialwise_states(iTrial).segment_state_number(iSegment) ~= 0
            state_num = trialwise_states(iTrial).segment_state_number(iSegment);
            segment_analysis(state_num).kinetic_timestamps{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_timestamps{iSegment};
            segment_analysis(state_num).x{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_x{iSegment};
            segment_analysis(state_num).y{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_y{iSegment};
            
            % Segment Direction
            beginning_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(1);
            beginning_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(1);
            end_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(end);
            end_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(end);
            segment_vector = [end_of_segment(1) - beginning_of_segment(1),end_of_segment(2) - beginning_of_segment(2)];
            segment_analysis(state_num).direction(global_segment_num(state_num)) = atan2(segment_vector(2),segment_vector(1));
            %%%%%%%%%%%%%%%%%%%%%%%%%

            segment_analysis(state_num).speed{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_speed{iSegment};
            segment_analysis(state_num).length(global_segment_num(state_num)) = trialwise_states(iTrial).segment_length(iSegment);

        
        end
            global_segment_num(state_num) = global_segment_num(state_num) + 1;
    end
end

%% Plotting random segments
for istate = 1:size(segment_analysis,2)
    figure;hold on
    cellfun(@plot,segment_analysis(istate).x,segment_analysis(istate).y)
    
    x_start = cellfun(@(v)v(1),segment_analysis(istate).x(~cellfun('isempty',segment_analysis(istate).x)));
    y_start = cellfun(@(v)v(1),segment_analysis(istate).y(~cellfun('isempty',segment_analysis(istate).y)));
    plot(x_start,y_start,'ro');
    
    title(strcat(subject,' state ',num2str(istate),'snippets (random subset)'));
    xlabel('x position');
    ylabel('y position');
    box off
    xlim([min(vertcat(trialwise_states.x_smoothed)) max(vertcat(trialwise_states.x_smoothed))])
    ylim([min(vertcat(trialwise_states.y_smoothed)) max(vertcat(trialwise_states.y_smoothed))])
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,num2str(num_states_subject),'states','_state_',num2str(istate),'_snippets_random_subset.png'));
    close(gcf);
end

%% Plotting segments by state, by coords
clear segment_analysis
global_segment_num = ones(1,num_states);
for iTrial = 1:length(trInd_test)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}) && trialwise_states(iTrial).segment_state_number(iSegment) ~= 0
            state_num = trialwise_states(iTrial).segment_state_number(iSegment);
            segment_analysis(state_num).kinetic_timestamps{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_timestamps{iSegment};
            segment_analysis(state_num).x{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_x{iSegment};
            segment_analysis(state_num).y{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_y{iSegment};
            
            %%% Segment Direction %%%
            beginning_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(1);
            beginning_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(1);
            end_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(end);
            end_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(end);
            segment_vector = [end_of_segment(1) - beginning_of_segment(1),end_of_segment(2) - beginning_of_segment(2)];
            segment_analysis(state_num).direction(global_segment_num(state_num)) = atan2(segment_vector(2),segment_vector(1));
            %%%%%%%%%%%%%%%%%%%%%%%%%

            segment_analysis(state_num).speed{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_speed{iSegment};
            segment_analysis(state_num).length(global_segment_num(state_num)) = trialwise_states(iTrial).segment_length(iSegment);

        
        end
            global_segment_num(state_num) = global_segment_num(state_num) + 1;
    end
end
%% Plotting histogram of segment lengths and directions
edges = [0:50:1200];

for iState = 1:size(segment_analysis,2)
    figure;hold on
    histogram((segment_analysis(iState).length*50),edges)
    title(strcat('state ',num2str(iState),'segment lengths'));
    xlabel('Segment Length (milliseconds)');
    ylabel('Number of Segments');
    ylim([0 300]);
    box off
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_length_histogram.png'));
    close(gcf);
end
close all

for iState = 1:size(segment_analysis,2)
    %direction rose plot
    polarhistogram((segment_analysis(iState).direction),20)
    title(strcat('state ',num2str(iState),'segment lengths'));
    box off
    rlim([0 100]);
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_direction_histogram.png'));
    close(gcf);

    
end