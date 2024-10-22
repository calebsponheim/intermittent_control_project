function [snippet_direction_out] = plot_state_direction(meta,data,snippet_data,colors)
%%

available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end
snippet_direction = [];
snippet_direction_out = [];
for iState = 1:size(snippet_data,2)
    snippet_direction_temp = [];
    normalized_snippet_vector = [];
    snippet_unit_vectors = [];
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    if ~isempty(state_snippets)
        for iSnippet = 1:size(state_snippets,2)
            endx = data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(end));
            beginningx = data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(1));
            endy = data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(end));
            beginningy = data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(1));
            snippet_vector = [endx - beginningx, endy - beginningy];
            snippet_unit_vectors(iSnippet,1:2) = snippet_vector./norm(snippet_vector);
            snippet_direction(iSnippet,iState) = atan2(snippet_vector(2),snippet_vector(1));
        end
        snippet_direction_out(iState) = atan2(mean(snippet_unit_vectors(:,2)),mean(snippet_unit_vectors(:,1)));
    end
   
%     Angle = snippet_direction_out(iState)';
%     Radius = 50;
%     tbl = table(Angle,Radius);

    if ~isempty(state_snippet_trials)
        figure('visible','off');polaraxes; hold on
        polarhistogram(snippet_direction(snippet_direction(:,iState) ~= 0,iState),'numbins',25,'FaceAlpha',.5,'FaceColor',colors(iState,:),'EdgeColor',colors(iState,:)); hold on
%         polarplot(tbl,"Angle","Radius",'LineWidth',6,'color',colors(iState,:),'MarkerFaceColor',colors(iState,:),'Marker','o','MarkerSize',20)
        title([meta.subject,'  ',strrep(meta.task,'_',' '),' State ',num2str(iState),' Direction']);
        box off
        set(gcf,'color','white')
        hold off
        saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_direction.png'));
        close gcf
    end
end
end