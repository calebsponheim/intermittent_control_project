function [] = plot_all_trials_v2(meta,data,colors)

%%
% colors = hsv(meta.optimal_number_of_states);
colors = vertcat(colors,[0 0 0]);
figure('visible','off','color','white'); hold on
box off
for iTrial = 1:size(data,2)
    states_for_plotting = data(iTrial).states_resamp;
    states_for_plotting(states_for_plotting == 0) = max(states_for_plotting)+1;
    trial_colors = zeros(length(states_for_plotting),3);
    trial_colors(~isnan(states_for_plotting),:) = colors(states_for_plotting(~isnan(states_for_plotting)),:);
    scatter(data(iTrial).x_smoothed,data(iTrial).y_smoothed,5,trial_colors(1:length(data(iTrial).x_smoothed),:),'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1)
end
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' all trials position'));
% legend([plots{state_present(2,state_present(1,:)>0)}]);
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_all_trials_position.png'));

end