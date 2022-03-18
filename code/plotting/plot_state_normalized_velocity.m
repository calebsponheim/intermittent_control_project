function meta = plot_state_normalized_velocity(meta,data,snippet_data,colors)
%%

% colors = hsv(meta.optimal_number_of_states);

available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
% available_test_trials = find(ismember([data.tp],2));
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
                native_res = (1/length(normspeed{snip_num,iState})):(1/length(normspeed{snip_num,iState})):1;
                % Interpolate that normalized speed
                interpnormspeed{iState}(snip_num,:) = interp1(native_res,normspeed{snip_num,iState},max_res);
                snip_num = snip_num + 1;
            end
        end %iSnippet
        interpnormspeedmean{iState} = nanmean(interpnormspeed{iState},1);
        line_fit_temp = polyfit(max_res,interpnormspeedmean{iState},1);
        line_slope_temp = line_fit_temp(1);
        if line_slope_temp > .2
            meta.acc_classification(iState) = 1;
        elseif line_slope_temp < -.2
            meta.acc_classification(iState) = 0;
        else
            meta.acc_classification(iState) = 2;
        end
        interpnormspeedstderr{iState} = nanstd(interpnormspeed{iState},1) / sqrt(size(interpnormspeed{iState},1));
        % plot the normalized speed
        figure('Visible','off','color','white'); hold on;
        patch([max_res fliplr(max_res)],[(interpnormspeedmean{iState}+interpnormspeedstderr{iState})...
            fliplr((interpnormspeedmean{iState}-interpnormspeedstderr{iState}))],colors(iState,:),'edgecolor','none')
        alpha(0.4)
        plot(max_res,interpnormspeedmean{iState},'Color',colors(iState,:),'linewidth',2)
        box off
        xlabel('Time (normalized)')
        ylabel('Speed (normalized)')
        ylim([0 1])
        xlim([.02 1])
        title([meta.subject,'  ',strrep(meta.task,'_',' '),' State ',num2str(iState),' Normalized Speed']);
        hold off
        saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_norm_velocity.png']);
        close gcf
        
    end
end %iState

end