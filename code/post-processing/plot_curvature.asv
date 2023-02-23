function plot_curvature(meta,data,snippet_data,colors)

%%
available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end
overall_curve_count = 1;
for iState = 1:size(snippet_data,2)
    curve_count = 1;
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    if ~isempty(state_snippets)
        for iSnippet = 1:size(state_snippets,2)
            x_temp = data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet});
            y_temp = data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet});
            snippet_kin = [smooth(x_temp,3), smooth(y_temp,3)];
            if size(snippet_kin,1) > 1
                %             figure; plot(snippet_kin(:,1), snippet_kin(:,2))
                [cum_arc_length_temp,radius_temp,curvature_vector_temp] = curvature(snippet_kin);
                avg_radius = mean(radius_temp(3:end-3),'omitnan');
                curvature_per_state{iState}(curve_count) = avg_radius;
                curvature_overall(overall_curve_count) = avg_radius;
                curve_count = curve_count + 1;
                overall_curve_count = overall_curve_count + 1;
            end
        end
    end
    if curve_count > 1
        figure('visible','off'); hold on
        [~, ~, ~, q_temp, ~] = al_goodplot(curvature_per_state{iState},0,20, colors(iState,:), 'bilateral', 100,std(curvature_per_state{iState})/5000,5);
        if ~isnan(q_temp(end,1))
            ylim([0 q_temp(end,1)])
        end
        hold off
        box off
        set(gcf,'color','w','Position',[100 100 300 800])
        title(strcat(meta.subject,'   ',strrep(meta.task,'_','  '),'  State  ',num2str(iState), 'Radius of Curvature'));
        xlabel('')
        ylabel('Radius Size')
        saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_Curvature.png'));
        close gcf
    end
end

%%
figure('visible','off'); hold on
for iState = 1:size(snippet_data,2)
    [~, ~, ~, q_temp, ~] = al_goodplot(curvature_per_state{iState},iState,0.75, colors(iState,:), 'right', 50,std(curvature_per_state{iState})/10000,0);
    q(iState) = q_temp(end,1);
end
ylim([0 mean(q,'omitnan')])
xlim([1 size(snippet_data,2)+1])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat(meta.subject,'   ',strrep(meta.task,'_','  '),' Radius of Curvature'));
xlabel('State Number')
ylabel('Radius Size')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_Curvature.png'));
close gcf

%%
writematrix(curvature_overall,strcat(file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\',meta.subject,meta.task,'curve_data.csv'))


end