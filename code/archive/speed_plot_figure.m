% Link Kinematics to Neural States


num_states = 6; % for rj
% get test trial indices
% get state info from test trials
% get kinematics for test trials
clear speed_plot
clc
for iTrial = 1:length(trInd_test)
    speed_plot(iTrial).test_indices = trInd_test(iTrial);
    speed_plot(iTrial).latent_state = dc_thresholded(iTrial).maxprob_state;
    speed_plot(iTrial).latent_state_bin_timestamp = bin_timestamps{speed_plot(iTrial).test_indices};
    speed_plot(iTrial).speed = data(speed_plot(iTrial).test_indices).speed;
    speed_plot(iTrial).x_smoothed = data(speed_plot(iTrial).test_indices).x_smoothed;
    speed_plot(iTrial).y_smoothed = data(speed_plot(iTrial).test_indices).y_smoothed;
    speed_plot(iTrial).kinematic_timestamps = data(speed_plot(iTrial).test_indices).kinematic_timestamps;
    
    % Split each trial into segments
    % Put each segment's neural timestamps in a cell row based on the state number
    
    segment_count = 0;
    segment_bin = 0;
    
    for iBin = 1:(size(speed_plot(iTrial).latent_state,2))
        
        
        if iBin == 1
            if isnan(speed_plot(iTrial).latent_state(1))
            elseif ~isnan(speed_plot(iTrial).latent_state(1)) && (speed_plot(iTrial).latent_state(1) == speed_plot(iTrial).latent_state(2))
                segment_count = 1;

                % assigning two bins to neural segment
                speed_plot(iTrial).neural_state_segment{1}(1) = speed_plot(iTrial).latent_state_bin_timestamp(1);
                speed_plot(iTrial).segment_state_number(1) = speed_plot(iTrial).latent_state(1);                
                speed_plot(iTrial).neural_state_segment{1}(2) = speed_plot(iTrial).latent_state_bin_timestamp(2);
                
                segment_bin = 2;
            elseif ~isnan(speed_plot(iTrial).latent_state(1))
                disp('something''s wrong')
            end
            
        elseif iBin == (size(speed_plot(iTrial).latent_state,2))
            if isnan(speed_plot(iTrial).latent_state(iBin))

            % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (speed_plot(iTrial).latent_state(iBin - 1) ~= speed_plot(iTrial).latent_state(iBin))
            % if the bin ahead is the same as current bin
            elseif speed_plot(iTrial).latent_state(iBin - 1) == speed_plot(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;            
                speed_plot(iTrial).neural_state_segment{segment_count}(segment_bin) = speed_plot(iTrial).latent_state_bin_timestamp(iBin);              
            end

        elseif iBin ~= 1
            % Checking for NaN cells and skipping them
            if isnan(speed_plot(iTrial).latent_state(iBin))

            % if the latent state of the bin before doesn't equal the current bin, start a new segment.
            elseif (speed_plot(iTrial).latent_state(iBin - 1) ~= speed_plot(iTrial).latent_state(iBin)) && (speed_plot(iTrial).latent_state(iBin + 1) == speed_plot(iTrial).latent_state(iBin)) && (~isempty(speed_plot(iTrial).latent_state(iBin + 1)))

                segment_bin = 1; %resetting intra-segment bin number
                segment_count = segment_count + 1; % adding to the segment count
                speed_plot(iTrial).neural_state_segment{segment_count}(segment_bin) = speed_plot(iTrial).latent_state_bin_timestamp(iBin);
                speed_plot(iTrial).segment_state_number(segment_count) = speed_plot(iTrial).latent_state(iBin);

            elseif speed_plot(iTrial).latent_state(iBin - 1) ~= speed_plot(iTrial).latent_state(iBin)
                disp('something''s wrong')
            
            % if the bin ahead is the same as current bin
            elseif speed_plot(iTrial).latent_state(iBin - 1) == speed_plot(iTrial).latent_state(iBin)
                segment_bin = segment_bin + 1;            
                speed_plot(iTrial).neural_state_segment{segment_count}(segment_bin) = speed_plot(iTrial).latent_state_bin_timestamp(iBin);
               
            end
        end
    end
    
    % same with the kinematic timestamps associated with each segment (but + 100 ms)
    for iSegment = 1:size(speed_plot(iTrial).neural_state_segment,2)
        if ~isempty(speed_plot(iTrial).neural_state_segment{iSegment})
            speed_plot(iTrial).segment_length(iSegment) = length(unique(speed_plot(iTrial).neural_state_segment{iSegment}));
                
                if speed_plot(iTrial).segment_length(iSegment) == 1
                    disp("something is wrong");
                end

                
                segment_beginning = min(speed_plot(iTrial).neural_state_segment{iSegment})+.010;
            segment_end = max(speed_plot(iTrial).neural_state_segment{iSegment})+.010;
            
            [~,closest_first] = min(abs(segment_beginning - speed_plot(iTrial).kinematic_timestamps));
            [~,closest_end] = min(abs(segment_end - speed_plot(iTrial).kinematic_timestamps));
            
            if length(speed_plot(iTrial).x_smoothed) < closest_end
                closest_end = closest_end - 1;
            end
            
            speed_plot(iTrial).segment_kinematic_speed{iSegment} = speed_plot(iTrial).speed(closest_first:closest_end);
            speed_plot(iTrial).segment_kinematic_x{iSegment} = speed_plot(iTrial).x_smoothed(closest_first:closest_end);
            speed_plot(iTrial).segment_kinematic_y{iSegment} = speed_plot(iTrial).y_smoothed(closest_first:closest_end);
            speed_plot(iTrial).segment_kinematic_timestamps{iSegment} = speed_plot(iTrial).kinematic_timestamps(closest_first:closest_end);
        end
    end
    
end

% Calculating Segment Lengths


colors = hsv(num_states);

%% Ok, so trying to plot a single trial?

for iTrial = 50:53%1:length(trInd_test)
    % Speed Plot
    figure('visible','on'); hold on
    plot(speed_plot(iTrial).kinematic_timestamps,speed_plot(iTrial).speed,'k')
    for iSegment = 1:size(speed_plot(iTrial).segment_state_number,2)
        if ~isempty(speed_plot(iTrial).segment_kinematic_timestamps{iSegment})
            plot(speed_plot(iTrial).segment_kinematic_timestamps{iSegment}(1),speed_plot(iTrial).segment_kinematic_speed{iSegment}(1),'ko')
            plot(speed_plot(iTrial).segment_kinematic_timestamps{iSegment},speed_plot(iTrial).segment_kinematic_speed{iSegment},'Color',colors(speed_plot(iTrial).segment_state_number(iSegment),:))
        end
    end
    title(strcat('Trial ',num2str(iTrial),' speed'));
    xlabel('time')
    box off
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\Test Trial_',num2str(iTrial),'_speed.png'));
    close(gcf);

    % Position Plot
    figure('visible','on'); hold on
    plot(speed_plot(iTrial).x_smoothed,speed_plot(iTrial).y_smoothed,'k')
    for iSegment = 1:size(speed_plot(iTrial).segment_state_number,2)
        if ~isempty(speed_plot(iTrial).segment_kinematic_timestamps{iSegment})
            plot(speed_plot(iTrial).segment_kinematic_x{iSegment}(1),speed_plot(iTrial).segment_kinematic_y{iSegment}(1),'ko')
            plot(speed_plot(iTrial).segment_kinematic_x{iSegment},speed_plot(iTrial).segment_kinematic_y{iSegment},'Color',colors(speed_plot(iTrial).segment_state_number(iSegment),:))
        end
    end
    plot(speed_plot(iTrial).x_smoothed(1),speed_plot(iTrial).y_smoothed(1),'ro')
    title(strcat('Test Trial ',num2str(iTrial),' position'));
    xlabel('x position');
    ylabel('y position');
    set(gcf,'Color','White');
    box off
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\Test Trial_',num2str(iTrial),'_position.png'));
    close(gcf);

end

% Create generic bin timing for a given trial




% convert latent state bins to

% make colorscale and legend info

% test plot kinematics with state info colors

% implement lag


%% Plotting segments by state, by coords
clear segment_analysis
global_segment_num = ones(1,num_states);
for iTrial = 1:length(trInd_test)%  datasample(1:length(trInd_test),15) % 
    for iSegment = 1:size(speed_plot(iTrial).segment_state_number,2)
        if ~isempty(speed_plot(iTrial).segment_kinematic_timestamps{iSegment}) && speed_plot(iTrial).segment_state_number(iSegment) ~= 0
            state_num = speed_plot(iTrial).segment_state_number(iSegment);
            segment_analysis(state_num).kinetic_timestamps{global_segment_num(state_num)} = speed_plot(iTrial).segment_kinematic_timestamps{iSegment};
            segment_analysis(state_num).x{global_segment_num(state_num)} = speed_plot(iTrial).segment_kinematic_x{iSegment};
            segment_analysis(state_num).y{global_segment_num(state_num)} = speed_plot(iTrial).segment_kinematic_y{iSegment};
            segment_analysis(state_num).speed{global_segment_num(state_num)} = speed_plot(iTrial).segment_kinematic_speed{iSegment};
            segment_analysis(state_num).length(global_segment_num(state_num)) = speed_plot(iTrial).segment_length(iSegment);
        end
            global_segment_num(state_num) = global_segment_num(state_num) + 1;
    end
end

%%
for istate = 1:7
    figure;hold on
    %cellfun(@plot,segment_analysis(1).speed)
    cellfun(@plot,segment_analysis(istate).x,segment_analysis(istate).y)
    
    x_start = cellfun(@(v)v(1),segment_analysis(istate).x(~cellfun('isempty',segment_analysis(istate).x)));
    y_start = cellfun(@(v)v(1),segment_analysis(istate).y(~cellfun('isempty',segment_analysis(istate).y)));
    % x_start = cellfun(@(v)v(1),segment_analysis(istate).x);
    % y_start = cellfun(@(v)v(1),segment_analysis(istate).y);
    plot(x_start,y_start,'ro');
    
    title(strcat('state ',num2str(istate),'snippets (random subset)'));
    xlabel('x position');
    ylabel('y position');
    box off
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\state_',num2str(istate),'_snippets_random_subset.png'));
    close(gcf);
end

%% Plotting histogram of segment lengths

for iState = 1:7
    figure;hold on
    histogram((segment_analysis(iState).length*50))
    title(strcat('state ',num2str(iState),'segment lengths'));
    xlabel('Segment Length (milliseconds)');
    ylabel('Number of Segments');
    box off
    set(gcf,'Color','White');
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\state_',num2str(iState),'_snippet_length_histogram.png'));
    close(gcf);

end