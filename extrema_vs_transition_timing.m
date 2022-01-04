function extrema_vs_transition_timing(data,meta)
% Compare the timing of extrema versus the timing of transitions.

transition_timestamps = [];
speed_extrema_timestamps = [];
all_extrema_count = 1;
distances = [];

for iTrial = 1:size(data,2)
    % Get all transition times across trials
    transition_timestamps = unique(data(iTrial).ms_relative_to_trial_start(diff(data(iTrial).states_resamp) ~= 0));
    % Get all extrema times across trials
    speed_extrema_timestamps = unique(data(iTrial).ms_relative_to_trial_start(data(iTrial).speed == max(data(iTrial).speed)));
    speed_extrema_timestamps = speed_extrema_timestamps(1);

    for iExtrema = 1:size(speed_extrema_timestamps,1)
        % Find the closest transition time to each extrema time
        closest_transition_time_ahead = transition_timestamps(transition_timestamps > speed_extrema_timestamps(iExtrema));
        if sum(closest_transition_time_ahead) ~= 0
            closest_transition_time_ahead = closest_transition_time_ahead(1);
        else
            closest_transition_time_ahead = NaN;
        end

        closest_transition_time_behind = transition_timestamps(transition_timestamps < speed_extrema_timestamps(iExtrema));
        if sum(closest_transition_time_behind) ~= 0
            closest_transition_time_behind = closest_transition_time_behind(end);
        else
            closest_transition_time_behind = NaN;
        end
        % Calculate the time between the transition and the closest extrema
        % (signed)
        distances_temp = [closest_transition_time_ahead - speed_extrema_timestamps(iExtrema), closest_transition_time_behind - speed_extrema_timestamps(iExtrema)];
        % store it
        distances_temp_temp = distances_temp(abs(distances_temp) == min(abs(distances_temp)));
        if sum(distances_temp_temp) ~= 0
            distances(all_extrema_count) = distances_temp_temp(1);
            all_extrema_count = all_extrema_count + 1;
        end
    end
end

% plot all of them as a histogram

[y,x] = histcounts(distances,round(min(distances),-2):50:round(max(distances),-2));

figure('visible','off','color','w'); hold on
bar(x(2:end),y)
box off
xlabel('Distance of Hidden State Transition from Speed Peak (ms)')
ylabel('Number of Hidden State Transitions')

% Save the plot

saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_extrema_vs_transition_distance.png']);
close gcf


end
