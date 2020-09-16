function [] = plot_all_trials_v2(meta,data)

%%
colors = hsv(meta.optimal_number_of_states);
figure('visible','off','color','white'); hold on
box off
for iTrial = 1:size(data,2)
    if strcmp(data(iTrial).trial_classification,'test')
        trial_colors = zeros(length(data(iTrial).states_resamp),3);
        trial_colors(~isnan(data(iTrial).states_resamp),:) = colors(data(iTrial).states_resamp(~isnan(data(iTrial).states_resamp)),:);
        scatter(data(iTrial).x_smoothed(1:length(trial_colors)),data(iTrial).y_smoothed(1:length(trial_colors)),5,trial_colors,'filled')
    end
end
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' all trials position'));
% legend([plots{state_present(2,state_present(1,:)>0)}]);
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_all_trials_position.png'));

end

