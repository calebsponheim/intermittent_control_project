function meta = plot_curvature(meta,data,snippet_data,colors,file_base_base)

%%
available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end
for iState = 1:size(snippet_data,2)
    curvature_per_state{iState} = [];
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    if ~isempty(state_snippets)
        for iSnippet = 1:size(state_snippets,2)
            x_temp = data(state_snippet_trials(iSnippet)).x_velocity(state_snippets{iSnippet});
            y_temp = data(state_snippet_trials(iSnippet)).y_velocity(state_snippets{iSnippet});
            snippet_kin = [smooth(x_temp,4), smooth(y_temp,4)];
            if size(snippet_kin,1) > 1
                %             figure; plot(snippet_kin(:,1), snippet_kin(:,2))
                radius_temp = rad_curv(snippet_kin(:,1),snippet_kin(:,2),.001);
                %                 avg_radius = mean(radius_temp(3:end-3),'omitnan');
                curvature_per_state{iState} = vertcat(curvature_per_state{iState},radius_temp(3:end-3));
                meta.curvature_out{iState} = curvature_per_state{iState};
            end
        end
    end
    %     if ~isempty(curvature_per_state{iState})
    %         figure('visible','off'); hold on
    %         [~, ~, ~, q_temp, ~] = al_goodplot(curvature_per_state{iState},0,2, colors(iState,:), 'bilateral', 100,std(curvature_per_state{iState})/1000000,1);
    %         if ~isnan(q_temp(end,1))
    %             ylim([0 q_temp(end,1)])
    %         end
    %         hold off
    %         box off
    %         set(gcf,'color','w','Position',[100 100 300 800])
    %         title(strcat(meta.subject,'   ',strrep(meta.task,'_','  '),'  State  ',num2str(iState), 'Radius of Curvature'));
    %         xlabel('')
    %         ylabel('Radius Size')
    %         saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_Curvature.png'));
    %         close gcf
    %     end
end
%% overall curve
if contains(meta.subject,'RJ') || contains(meta.subject,'RS')
    overall_position = [smooth(vertcat(data.x_smoothed)',4),smooth(vertcat(data.y_smoothed)',4)];
    overall_velocity = [smooth(vertcat(data.x_velocity)',4),smooth(vertcat(data.y_velocity)',4)];
else
    overall_position = [smooth([data.x_smoothed],4),smooth([data.y_smoothed],4)];
    overall_velocity = [smooth([data.x_velocity],4),smooth([data.y_velocity],4)];
end
% [~,radius_temp,~] = curvature(overall_kin);
% curvature_overall = radius_temp;


curvature_overall = rad_curv(overall_velocity(:,1),overall_velocity(:,2),.001);
%%
figure('visible','off'); hold on
for iState = 1:size(snippet_data,2)
    if ~isempty(curvature_per_state{iState})
        if contains(meta.subject,'bx')
            [~, ~, ~, q_temp, ~] = al_goodplot(curvature_per_state{iState},iState,0.75, colors(iState,:), 'right', 1,std(curvature_per_state{iState})/1000000,1);
        else
            [~, ~, ~, q_temp, ~] = al_goodplot(curvature_per_state{iState},iState,0.75, colors(iState,:), 'right', 50,std(curvature_per_state{iState})/100000,1);
        end
        q(iState) = q_temp(end,1);
    end
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