function plot_state_snippets(meta,data,snippet_data,colors)

% colors = hsv(meta.optimal_number_of_states);

available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
% available_test_trials = find(ismember([data.tp],2));
if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end

for iState = 1:size(snippet_data,2)
    figure('visible','off','color','white'); hold on
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    if ~isempty(state_snippets)
        for iSnippet = 1:size(state_snippets,2)
            scatter(data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}),data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}),3,colors(iState,:),'filled','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',0.1);
            scatter(data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(1)),data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(1)),7,'g','filled');
            scatter(data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(end)),data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(end)),7,'r','filled');
        end
    end
    if strcmp(meta.subject,'RS') || strcmp(meta.subject,'RJ')
        xlim([min(vertcat(data.x_smoothed)) max(vertcat(data.x_smoothed))])
        ylim([min(vertcat(data.y_smoothed)) max(vertcat(data.y_smoothed))])
    else
        xlim([min([data.x_smoothed]) max([data.x_smoothed])])
        ylim([min([data.y_smoothed]) max([data.y_smoothed])])
    end
    title([meta.subject,'  ',strrep(meta.task,'_',' '),' state ',num2str(iState),' snippets']);
    box off
    hold off
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_position.png'));
    close gcf
    
end