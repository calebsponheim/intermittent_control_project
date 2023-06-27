function extrema_vs_transition_timing(data,meta)
%%
% Compare the timing of extrema versus the timing of transitions.

transition_timestamps = [];
speed_extrema_timestamps = [];
speed_extrema_timestamps_all_trials = [];
transition_timestamps_all_trials = [];
speed_all_trials = [];
speed_all_trials_timestamps = [];
window_size = 2000; %ms

prominence_RS = .0038;
prominence_RJ = .0081;
prominence_Bx = .0002;
if contains(meta.subject,'RS')
    prominence_amount = prominence_RS;
elseif contains(meta.subject,'RJ')
    prominence_amount = prominence_RJ;
elseif contains(meta.subject,'Bx')
    prominence_amount = prominence_Bx;
end

for iTrial = 1:size(data,2)
    % Find Trial Length in ms, add it to the extrema and transition timestamps
    % Get all transition times across trials
    transition_timestamps = unique(data(iTrial).ms_relative_to_trial_start(diff(data(iTrial).states_resamp) ~= 0));
    % Get all extrema times across trials
    speed_extrema_timestamps = data(iTrial).ms_relative_to_trial_start(islocalmax(data(iTrial).speed,'MinProminence',prominence_amount));
    speed_extrema_timestamps = [speed_extrema_timestamps data(iTrial).ms_relative_to_trial_start(islocalmin(data(iTrial).speed,'MinProminence',prominence_amount))];
    speed_timestamps = data(iTrial).ms_relative_to_trial_start;
%     if mod(iTrial,100) == 0
%         figure('visible','on','color','w'); hold on
%         xline(transition_timestamps, 'r','LineWidth',2,'Alpha',.3)
%         plot(data(iTrial).speed,'LineWidth',2)
%         plot(speed_extrema_timestamps,data(iTrial).speed(speed_extrema_timestamps),'ko','LineWidth',2)
%         hold off
%     end
    %     for iExtrema = 1:size(speed_extrema_timestamps,2)
    %         % Find the closest transition time to each extrema time
    %         closest_transition_time_ahead = transition_timestamps(transition_timestamps > speed_extrema_timestamps(iExtrema));
    %         if sum(closest_transition_time_ahead) ~= 0
    %             closest_transition_time_ahead = closest_transition_time_ahead(1);
    %         else
    %             closest_transition_time_ahead = NaN;
    %         end
    %
    %         closest_transition_time_behind = transition_timestamps(transition_timestamps < speed_extrema_timestamps(iExtrema));
    %         if sum(closest_transition_time_behind) ~= 0
    %             closest_transition_time_behind = closest_transition_time_behind(end);
    %         else
    %             closest_transition_time_behind = NaN;
    %         end
    %         % Calculate the time between the transition and the closest extrema
    %         % (signed)
    %         distances_temp = [closest_transition_time_ahead - speed_extrema_timestamps(iExtrema), closest_transition_time_behind - speed_extrema_timestamps(iExtrema)];
    %         % store it
    %         distances_temp_temp = distances_temp(abs(distances_temp) == min(abs(distances_temp)));
    %         if sum(distances_temp_temp) ~= 0
    %             distances(all_extrema_count) = distances_temp_temp(1);
    %             all_extrema_count = all_extrema_count + 1;
    %         end
    %     end

    if iTrial > 1
        last_trial_length_in_ms = max(speed_all_trials_timestamps);
        speed_extrema_timestamps = sort(speed_extrema_timestamps) + last_trial_length_in_ms;
        transition_timestamps = transition_timestamps + last_trial_length_in_ms;
        speed_timestamps = speed_timestamps + last_trial_length_in_ms;
    else
        speed_extrema_timestamps = sort(speed_extrema_timestamps);
    end
    speed_extrema_timestamps_all_trials = [speed_extrema_timestamps_all_trials speed_extrema_timestamps];
    transition_timestamps_all_trials = [transition_timestamps_all_trials transition_timestamps];
    if contains(meta.subject,'Bx')
        speed_all_trials = [speed_all_trials data(iTrial).speed];
    else
        speed_all_trials = [speed_all_trials data(iTrial).speed'];
    end
    speed_all_trials_timestamps = [speed_all_trials_timestamps speed_timestamps];
end

max_timestep = max([speed_extrema_timestamps_all_trials transition_timestamps_all_trials]);
windows = 1 : window_size : max_timestep;
%% Null Time
all_extrema_count = 1;
distances = [];

data_windows = [];
shuffled_order = randperm(length(windows)-1);
for iWindow = 2:length(windows)
    data_windows(iWindow-1).edges = [windows(iWindow-1) windows(iWindow)];
    data_windows(iWindow-1).speed_extrema = speed_extrema_timestamps_all_trials(speed_extrema_timestamps_all_trials > windows(iWindow-1) & speed_extrema_timestamps_all_trials < windows(iWindow)) - (windows(iWindow-1) - 1);
    data_windows(iWindow-1).transitions = transition_timestamps_all_trials(transition_timestamps_all_trials > windows(iWindow-1) & transition_timestamps_all_trials < windows(iWindow)) - (windows(iWindow-1) - 1);
    data_windows(iWindow-1).speed = speed_all_trials(windows(iWindow-1):windows(iWindow));
end %iWindow
for iWindow = 1:size(data_windows,2)
    data_windows(iWindow).shuffled_transitions = data_windows(shuffled_order(iWindow)).transitions;
end %iWindow

for iWindow = 1:size(data_windows,2)
    if mod(iWindow,100) == 0
        figure('visible','off','color','w'); hold on
        xline(data_windows(iWindow).transitions,'g','LineWidth',2,'Alpha',.3)
        xline(data_windows(iWindow).shuffled_transitions,'r','LineWidth',2,'Alpha',.3)
        plot(data_windows(iWindow).speed,'LineWidth',2)
        plot(data_windows(iWindow).speed_extrema,data_windows(iWindow).speed(data_windows(iWindow).speed_extrema),'ko','LineWidth',2)
        axis tight
        title(strcat('Window',num2str(iWindow)))
        xlabel('Time(ms)')
        ylabel('Speed')
        hold off
        saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_extrema_vs_transition_individual_windows_',num2str(iWindow),'.png'))
    end
    for iExtrema = 1:size(data_windows(iWindow).speed_extrema,2)
        % Find the closest transition time to each extrema time
        closest_transition_time_ahead = data_windows(iWindow).transitions(data_windows(iWindow).transitions > data_windows(iWindow).speed_extrema(iExtrema));
        if sum(closest_transition_time_ahead) ~= 0
            closest_transition_time_ahead = closest_transition_time_ahead(1);
        else
            closest_transition_time_ahead = NaN;
        end

        closest_transition_time_behind = data_windows(iWindow).transitions(data_windows(iWindow).transitions < data_windows(iWindow).speed_extrema(iExtrema));
        if sum(closest_transition_time_behind) ~= 0
            closest_transition_time_behind = closest_transition_time_behind(end);
        else
            closest_transition_time_behind = NaN;
        end
        % Calculate the time between the transition and the closest extrema
        % (signed)
        distances_temp = [closest_transition_time_ahead - data_windows(iWindow).speed_extrema(iExtrema), closest_transition_time_behind - data_windows(iWindow).speed_extrema(iExtrema)];
        % store it
        distances_temp_temp = distances_temp(abs(distances_temp) == min(abs(distances_temp)));
        if sum(distances_temp_temp) ~= 0
            distances(all_extrema_count) = distances_temp_temp(1);
            all_extrema_count = all_extrema_count + 1;
        end
    end
end

distances_null = [];
all_extrema_count = 1;
for iWindow = 1:size(data_windows,2)
    for iExtrema = 1:size(data_windows(iWindow).speed_extrema,2)
        % Find the closest transition time to each extrema time
        closest_transition_time_ahead = data_windows(iWindow).shuffled_transitions(data_windows(iWindow).shuffled_transitions > data_windows(iWindow).speed_extrema(iExtrema));
        if sum(closest_transition_time_ahead) ~= 0
            closest_transition_time_ahead = closest_transition_time_ahead(1);
        else
            closest_transition_time_ahead = NaN;
        end

        closest_transition_time_behind = data_windows(iWindow).shuffled_transitions(data_windows(iWindow).shuffled_transitions < data_windows(iWindow).speed_extrema(iExtrema));
        if sum(closest_transition_time_behind) ~= 0
            closest_transition_time_behind = closest_transition_time_behind(end);
        else
            closest_transition_time_behind = NaN;
        end
        % Calculate the time between the transition and the closest extrema
        % (signed)
        distances_temp = [closest_transition_time_ahead - data_windows(iWindow).speed_extrema(iExtrema), closest_transition_time_behind - data_windows(iWindow).speed_extrema(iExtrema)];
        % store it
        distances_temp_temp = distances_temp(abs(distances_temp) == min(abs(distances_temp)));
        if sum(distances_temp_temp) ~= 0
            distances_null(all_extrema_count) = distances_temp_temp(1);
            all_extrema_count = all_extrema_count + 1;
        end
    end
end
%%
% plot all of them as a histogram

[y,x] = histcounts(distances,round(min(distances),-2):10:round(max(distances),-2));
[y_null,x_null] = histcounts(distances_null,round(min(distances_null),-2):10:round(max(distances_null),-2));

figure('visible','off','color','w'); hold on
bar(x(2:end),y)
bar(x_null(2:end),y_null)
box off
xlabel('Distance of Hidden State Transition from Speed Extrema (ms)')
ylabel('Number of Hidden State Transitions')

% Save the plot

saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_extrema_vs_transition_distance.png'));
%
[p,~,~] = ranksum(distances,distances_null);
disp(strcat('Distances P-Value: ',num2str(p)))
close gcf

end
