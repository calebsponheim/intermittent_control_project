function [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath)

colors = jet(num_states_subject);

%% Plotting segments by state, by coords
global_segment_num = ones(1,num_states_subject);
for iTrial = datasample(1:length(trInd_test),num_segments_to_plot)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}) && trialwise_states(iTrial).segment_state_number(iSegment) ~= 0
            state_num = trialwise_states(iTrial).segment_state_number(iSegment);
            segmentwise_analysis(state_num).kinetic_timestamps{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_timestamps{iSegment};
            segmentwise_analysis(state_num).x{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_x{iSegment};
            segmentwise_analysis(state_num).y{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_y{iSegment};
            
            if isfield(trialwise_states, 'tp')
                segmentwise_analysis(state_num).tp{global_segment_num(state_num)} = trialwise_states(iTrial).tp;
                segmentwise_analysis(state_num).target{global_segment_num(state_num)} = trialwise_states(iTrial).target;
            end
            if include_EMG_analysis == 1
                for iMuscle = 1:length(muscle_names)
                    segmentwise_analysis(state_num).(muscle_names{iMuscle}){global_segment_num(state_num)} = trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment};
                end
            end
            
            % Segment Direction
            beginning_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(1);
            beginning_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(1);
            end_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(end);
            end_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(end);
            segment_vector = [end_of_segment(1) - beginning_of_segment(1),end_of_segment(2) - beginning_of_segment(2)];
            segmentwise_analysis(state_num).direction(global_segment_num(state_num)) = atan2(segment_vector(2),segment_vector(1));
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            segmentwise_analysis(state_num).speed{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_speed{iSegment};
            segmentwise_analysis(state_num).length(global_segment_num(state_num)) = trialwise_states(iTrial).segment_length(iSegment);
            segmentwise_analysis(state_num).trial_index(global_segment_num(state_num)) = trInd_test(iTrial);
            
        end
        global_segment_num(state_num) = global_segment_num(state_num) + 1;
    end
end

%% Plotting random segments
for istate = 1:size(segmentwise_analysis,2)
    if ~isempty(segmentwise_analysis(istate).x)
        figure('visible','off');hold on
        cellfun(@(x,y) (plot(x,y,'Color',colors(istate,:))),segmentwise_analysis(istate).x,segmentwise_analysis(istate).y);
        x_start = cellfun(@(v)v(1),segmentwise_analysis(istate).x(~cellfun('isempty',segmentwise_analysis(istate).x)));
        y_start = cellfun(@(v)v(1),segmentwise_analysis(istate).y(~cellfun('isempty',segmentwise_analysis(istate).y)));
        plot(x_start,y_start,'ro');
        
        title(strcat(subject,strrep(task,'_',' '),' state ',num2str(istate),'snippets (random subset)'));
        xlabel('x position');
        ylabel('y position');
        box off
        if strcmp(subject,'RS') == 0
            xlim([min([trialwise_states.x_smoothed]) max([trialwise_states.x_smoothed])])
            ylim([min([trialwise_states.y_smoothed]) max([trialwise_states.y_smoothed])])
        elseif strcmp(subject,'RS')
            xlim([min(vertcat(trialwise_states.x_smoothed)) max(vertcat(trialwise_states.x_smoothed))])
            ylim([min(vertcat(trialwise_states.y_smoothed)) max(vertcat(trialwise_states.y_smoothed))])
        end
        set(gcf,'Color','White');
        if ispc
        saveas(gcf,strcat(figure_folder_filepath,'\',subject,task,num2str(num_states_subject),'states','_state_',num2str(istate),'_snippets_random_subset.png'));
        else
        saveas(gcf,strcat('~/git/intermittent_control_project/figures/',subject,task,num2str(num_states_subject),'states','_state_',num2str(istate),'_snippets_random_subset.png'));
        end
        close(gcf);
    end
end

%% Plotting segments by state, by coords
clear segmentwise_analysis
global_segment_num = ones(1,num_states_subject);
for iTrial = 1:length(trInd_test)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}) && trialwise_states(iTrial).segment_state_number(iSegment) ~= 0
            state_num = trialwise_states(iTrial).segment_state_number(iSegment);
            segmentwise_analysis(state_num).kinetic_timestamps{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_timestamps{iSegment};
            segmentwise_analysis(state_num).x{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_x{iSegment};
            segmentwise_analysis(state_num).y{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_y{iSegment};
            
            if isfield(trialwise_states, 'tp')
                segmentwise_analysis(state_num).tp{global_segment_num(state_num)} = trialwise_states(iTrial).tp;
                segmentwise_analysis(state_num).target{global_segment_num(state_num)} = trialwise_states(iTrial).target;
                segmentwise_analysis(state_num).target_location{global_segment_num(state_num)} = trialwise_states(iTrial).target_location;
            end

            if include_EMG_analysis == 1
                for iMuscle = 1:length(muscle_names)
                    segmentwise_analysis(state_num).(muscle_names{iMuscle}){global_segment_num(state_num)} = trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment};
                end
            end
            
            %%% Segment Direction %%%
            beginning_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(1);
            beginning_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(1);
            end_of_segment(1) = trialwise_states(iTrial).segment_kinematic_x{iSegment}(end);
            end_of_segment(2) = trialwise_states(iTrial).segment_kinematic_y{iSegment}(end);
            segment_vector = [end_of_segment(1) - beginning_of_segment(1),end_of_segment(2) - beginning_of_segment(2)];
            segmentwise_analysis(state_num).direction(global_segment_num(state_num)) = atan2(segment_vector(2),segment_vector(1));
            %%%%%%%%%%%%%%%%%%%%%%%%%
            
            segmentwise_analysis(state_num).speed{global_segment_num(state_num)} = trialwise_states(iTrial).segment_kinematic_speed{iSegment};
            segmentwise_analysis(state_num).length(global_segment_num(state_num)) = trialwise_states(iTrial).segment_length(iSegment);
            
            
        end
        global_segment_num(state_num) = global_segment_num(state_num) + 1;
    end
end
%% Plotting histogram of segment lengths and directions
edges = 0:50:(max([segmentwise_analysis.length])*50);
dir_edges = -pi:((2*pi)/30):pi;
for iState = 1:size(segmentwise_analysis,2)
    % Preparing binned data for plotting
    binned_segment_lengths{iState} = histcounts((segmentwise_analysis(iState).length*50),edges);
    binned_segment_directions{iState} = histcounts((segmentwise_analysis(iState).direction(segmentwise_analysis(iState).direction ~= 0)),dir_edges);
end %iState

for iState = 1:size(segmentwise_analysis,2)
    figure('visible', 'off');hold on
    bar(edges(1:end-1),binned_segment_lengths{iState},'FaceColor',colors(iState,:),'EdgeColor',colors(iState,:))
    %     histogram((segmentwise_analysis(iState).length*50),edges,'FaceColor',colors(iState,:))
    title(strcat(subject,strrep(task,'_',' '),'state ',num2str(iState),'segment lengths'));
    xlabel('Segment Length (milliseconds)');
    ylabel('Number of Segments');
    ylim([0 max(max(vertcat(binned_segment_lengths{:})))]);
    box off
    set(gcf,'Color','White');
    if ispc
    saveas(gcf,strcat(figure_folder_filepath,'\',subject,task,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_length_histogram.png'));
    else
    saveas(gcf,strcat('~/git/intermittent_control_project/figures/',subject,task,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_length_histogram.png'));
    end
    close(gcf);
end
close all

for iState = 1:size(segmentwise_analysis,2)
    %direction rose plot
    polarhistogram('BinEdges',dir_edges,'BinCounts',binned_segment_directions{iState},'FaceColor',colors(iState,:),'EdgeColor',colors(iState,:))
    title(strcat(subject,strrep(task,'_',' '),'state ',num2str(iState),'segment lengths'));
    box off
    rlim([0 max(max(vertcat(binned_segment_directions{:})))]);
    set(gcf,'Color','White');
    if ispc
    saveas(gcf,strcat(figure_folder_filepath,'\',subject,task,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_direction_histogram.png'));
    else
    saveas(gcf,strcat('~/git/intermittent_control_project/figures/',subject,task,num2str(num_states_subject),'states','_state_',num2str(iState),'_snippet_direction_histogram.png'));
    end
    close(gcf);
    
end