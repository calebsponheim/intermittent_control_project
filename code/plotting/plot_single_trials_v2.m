function [] = plot_single_trials_v2(meta,data)

%%
colors = hsv(meta.optimal_number_of_states);

if strcmp(meta.subject,'RS')
    available_test_trials = find(ismember({data.trial_classification},'test'));
else
    available_test_trials = find(ismember({data.trial_classification},'test'));
end

if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end

for iTrial = available_test_trials(meta.trials_to_plot)
    
    trial_colors = zeros(length(data(iTrial).states_resamp),3);
    selection = data(iTrial).states_resamp(~isnan(data(iTrial).states_resamp));
    selection = selection > 0;
    trial_colors(selection,:) = colors(data(iTrial).states_resamp(selection),:);
    % Pos
    figure('visible','off','color','white'); hold on
    scatter(data(iTrial).x_smoothed(1:length(trial_colors)),data(iTrial).y_smoothed(1:length(trial_colors)),5,trial_colors,'filled')
    scatter(data(iTrial).x_smoothed(1),data(iTrial).y_smoothed(1),150,'g','filled')
    scatter(data(iTrial).x_smoothed(end),data(iTrial).y_smoothed(end),150,'r','filled')
    title([meta.subject,'  ',strrep(meta.task,'_',' '),' trial ',num2str(iTrial),' position']);
    if strcmp(meta.subject,'RS') || strcmp(meta.subject,'RJ')
        xlim([min(vertcat(data.x_smoothed)) max(vertcat(data.x_smoothed))])
        ylim([min(vertcat(data.y_smoothed)) max(vertcat(data.y_smoothed))])
    else
        xlim([min([data.x_smoothed]) max([data.x_smoothed])])
        ylim([min([data.y_smoothed]) max([data.y_smoothed])])
    end
    box off
    hold off
    saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trial_',num2str(iTrial),'_position.png']);
    close gcf
    
    % Vel
    figure('visible','off','color','white'); hold on
    scatter(data(iTrial).ms_relative_to_trial_start(1:length(trial_colors)),data(iTrial).speed(1:length(trial_colors)),5,trial_colors,'filled')
    scatter(data(iTrial).ms_relative_to_trial_start(1),data(iTrial).speed(1),150,'g','filled')
    scatter(data(iTrial).ms_relative_to_trial_start(end),data(iTrial).speed(end),150,'r','filled')
    title([meta.subject,'  ',strrep(meta.task,'_',' '),' trial ',num2str(iTrial),' velocity']);
    xlim([min([data(iTrial).ms_relative_to_trial_start]) max([data(iTrial).ms_relative_to_trial_start])])
    if strcmp(meta.subject,'RS') || strcmp(meta.subject,'RJ')
        ylim([min(vertcat(data.speed)) max(vertcat(data.speed))])
    else
        ylim([min([data.speed]) max([data.speed])])
    end
    xlabel('time relative to trial start (ms)')
    box off
    hold off
    saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trial_',num2str(iTrial),'_velocity.png']);
    close gcf
    
    % Accel
    if strcmp(meta.subject,'RS') || strcmp(meta.subject,'RJ')
    else
        figure('visible','off','color','white'); hold on
        scatter(data(iTrial).ms_relative_to_trial_start(1:length(trial_colors)),data(iTrial).acceleration(1:length(trial_colors)),5,trial_colors,'filled')
        scatter(data(iTrial).ms_relative_to_trial_start(1),data(iTrial).acceleration(1),150,'g','filled')
        scatter(data(iTrial).ms_relative_to_trial_start(end),data(iTrial).acceleration(end),150,'r','filled')
        title([meta.subject,'  ',strrep(meta.task,'_',' '),' trial ',num2str(iTrial),' acceleration']);
        xlim([min([data(iTrial).ms_relative_to_trial_start]) max([data(iTrial).ms_relative_to_trial_start])])
        ylim([min([data.acceleration]) max([data.acceleration])])
        xlabel('time relative to trial start (ms)')
        box off
        hold off
        saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trial_',num2str(iTrial),'_acceleration.png']);
        close gcf
    end
end

end

