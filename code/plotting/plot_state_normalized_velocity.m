function meta = plot_state_normalized_velocity(meta,data,snippet_data,colors)
%%

% colors = hsv(meta.optimal_number_of_states);

available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));

if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end

normspeed = [];
interpnormspeed = {};
interpnormspeedmean = cell(size(snippet_data,2),1);
interpnormspeedstderr = cell(size(snippet_data,2),1);
for iState = 1:size(snippet_data,2)
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    if ~isempty(state_snippets)
        max_snippet_length = max(cellfun(@(x) length(x),state_snippets));
        max_res = (1/max_snippet_length):(1/max_snippet_length):1;
        snip_num = 1;
        for iSnippet = 1:size(state_snippets,2)
            % Normalize Speed
            if length(data(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet})) > 1
                normspeed{snip_num,iState} = normalize(data(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet}),'range');
                average_speed{snip_num,iState} = mean(data(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet}));
                peak_speed{snip_num,iState} = max(data(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet}));
                peak_acceleration{snip_num,iState} = max(data(state_snippet_trials(iSnippet)).acceleration(state_snippets{iSnippet}));
                native_res = (1/length(normspeed{snip_num,iState})):(1/length(normspeed{snip_num,iState})):1;
                % Interpolate that normalized speed
                interpnormspeed{iState}(snip_num,:) = interp1(native_res,normspeed{snip_num,iState},max_res);
                snip_num = snip_num + 1;
            end
        end %iSnippet
        interpnormspeedmean{iState} = mean(interpnormspeed{iState},1,'omitnan');
        %         speedmean{iState} = mean([average_speed{:,iState}],'omitnan');
        meta.mean_speed{iState} = [average_speed{:,iState}];
        %         speedpeak{iState} = mean([peak_speed{:,iState}],'omitnan');
        meta.peak_speed{iState} = [peak_speed{:,iState}];
        meta.peak_acceleration{iState} = [peak_acceleration{:,iState}];
        line_fit_temp = polyfit(max_res,interpnormspeedmean{iState},1);
        y_for_line_plot = polyval(line_fit_temp,max_res);
        line_slope_temp = line_fit_temp(1);
        if line_slope_temp > .2
            meta.acc_classification(iState) = 1; % ACCELERATIVE
        elseif line_slope_temp < -.2
            meta.acc_classification(iState) = 0; % DECELRATIVE
        else
            meta.acc_classification(iState) = 2; % FLAT
        end
        interpnormspeedstderr{iState} = std(interpnormspeed{iState},1,'omitnan') / sqrt(size(interpnormspeed{iState},1));

        % plot the normalized speed
        figure('Visible','off','color','white'); hold on;
        patch([max_res fliplr(max_res)],[(interpnormspeedmean{iState}+interpnormspeedstderr{iState})...
            fliplr((interpnormspeedmean{iState}-interpnormspeedstderr{iState}))],colors(iState,:),'edgecolor','none')
        alpha(0.4)
        plot(max_res,interpnormspeedmean{iState},'Color',colors(iState,:),'linewidth',2)
        plot(max_res,y_for_line_plot,'b-','LineWidth',2)
        annotation('textbox',[.5 .1 .1 .1],'String',['Slope: ' num2str(line_slope_temp)],'FitBoxToText','on');
        box off
        xlabel('Time (normalized)')
        ylabel('Speed (normalized)')
        ylim([0 1])
        xlim([.02 1])
        title([meta.subject,'  ',strrep(meta.task,'_',' '),' State ',num2str(iState),' Normalized Speed']);
        hold off
        saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_norm_velocity.png'));
        close gcf
    end %if
end %iState

% Plot Average Speed
figure('Visible','off','color','white'); hold on;
for iState = 1:size(snippet_data,2)
    %     histogram([average_speed{:,iState}],'facecolor',colors(iState,:))
    if ~isempty([average_speed{:,iState}])
        al_goodplot([average_speed{:,iState}],iState,0.75, colors(iState,:), 'right',.05,std([average_speed{:,iState}])/1000,1);
    end
end
title([meta.subject,'  ',strrep(meta.task,'_',' '),' Average Snippet Speed']);
ylabel('Mean Snippet Speed')
xlabel('State Number')
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_avg_velocity.png'));
close gcf

% Plot Peak Speed
figure('Visible','off','color','white'); hold on;
for iState = 1:size(snippet_data,2)
    %     histogram([peak_speed{:,iState}],'facecolor',colors(iState,:))
    if ~isempty([peak_speed{:,iState}])
        al_goodplot([peak_speed{:,iState}],iState,0.75, colors(iState,:), 'right', .05,std([peak_speed{:,iState}])/1000,1);
    end
end %iState
title([meta.subject,'  ',strrep(meta.task,'_',' '),' Peak Snippet Speed']);
ylabel('Peak Snippet Speed')
xlabel('State Number')
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_peak_velocity.png'));
close gcf



% Plot Peak Acceleration
figure('Visible','off','color','white'); hold on;
for iState = 1:size(snippet_data,2)
    %     histogram([peak_speed{:,iState}],'facecolor',colors(iState,:))
    if ~isempty([peak_acceleration{:,iState}])
        al_goodplot([peak_acceleration{:,iState}],iState,0.75, colors(iState,:), 'right', .05,std([peak_acceleration{:,iState}])/1000,1);
    end
end %iState
title([meta.subject,'  ',strrep(meta.task,'_',' '),' Peak Snippet Acceleration']);
ylabel('Peak Snippet Speed')
xlabel('State Number')
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_peak_acceleration.png'));
close gcf



end