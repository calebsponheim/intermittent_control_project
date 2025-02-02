function plot_continuous_states(meta,data)
%% Intention: Average and plot latent variable values *per reach direction*

% Start by plotting each reach direction averaged, the whole reach, not
% normalized. 
dirs = unique([data.target_direction]);
latent_dim_plot = cell(length(dirs),1);
average_plots = cell(length(dirs),1);
stderr_plots = cell(length(dirs),1);
for iDir = 1:length(dirs)
    max_trial_length = 0;
    temp =  {data([data.target_direction] == dirs(iDir)).continuous_states};
    for iTrial = 1:length(temp)
        if max_trial_length < max(size(temp{iTrial}))
            max_trial_length = max(size(temp{iTrial}));
        end
    end
    latent_dim_plot{iDir} = nan(max_trial_length,size(temp{1},2),size(temp,2));

    for iTrial = 1:length(temp)
        latent_dim_plot{iDir}(1:size(temp{iTrial},1),1:size(temp{iTrial},2),iTrial) = temp{iTrial};
    end

    average_plots{iDir} = mean(latent_dim_plot{iDir},3,'omitnan');
    stderr_plots{iDir} = std(latent_dim_plot{iDir},[],3,'omitnan')/sqrt(size(latent_dim_plot{iDir},3));
    figure('Visible','off'); hold on
    sgtitle(['Avg Latent Dim Values for ' num2str(dirs(iDir)) ' Dir'])
    num_dims = size(average_plots{iDir},2);
    colors = hsv(num_dims);
    for iDim = 1:num_dims
        subplot(num_dims,1,iDim); hold on
        data_to_plot = average_plots{iDir}(:,iDim)';
        err_to_plot = stderr_plots{iDir}(:,iDim)';
        patch([1:length(data_to_plot) fliplr(1:length(data_to_plot))],[(data_to_plot+err_to_plot)...
        fliplr(data_to_plot-err_to_plot)],colors(iDim,:),'edgecolor','none','FaceAlpha',.3)
        plot(data_to_plot,'Color',colors(iDim,:))
        ylim([min(min(average_plots{iDir})) max(max(average_plots{iDir}))])
    end
    box off
    set(gcf,'color','w','Position',[100 100 350 1000])
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_dir_',num2str(iDir),'_avg_continuous_states.png'));
    close gcf
end