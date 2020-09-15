function direction_comparison_matrix = direction_comparison(data,snippet_data,meta,second_dataset,second_dataset_meta)
% function intention: compare the average speed of each state's snippets to
% every other state's speed.

%%
available_test_trials = find(ismember([data.trial_classification],'test'));

for iState = 1:size(snippet_data,2)
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    for iSnippet = 1:size(state_snippets,2)
        endx = data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(end));
        beginningx = data(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(1));
        endy = data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(end));
        beginningy = data(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(1));
        snippet_vector = [endx - beginningx, endy - beginningy];
        snippet_direction(iSnippet,iState) = atan2(snippet_vector(2),snippet_vector(1));
    end
end

%% Stats
if exist('second_dataset','var')
    %% second model compare
    % do snippet analysis on the second dataset
    second_dataset = second_dataset.data;
    second_dataset_meta = second_dataset_meta.meta;
    [second_dataset_meta,second_dataset,second_dataset_snippet_data] = ...
        segment_analysis_v2(second_dataset_meta,second_dataset);
    available_test_trials_second_dataset = find(ismember([second_dataset.trial_classification],'test'));
    
    for iState = 1:size(second_dataset_snippet_data,2)
        [~,~,allowed_snippets] = intersect(available_test_trials_second_dataset,second_dataset_snippet_data(iState).snippet_trial);
        state_snippets = second_dataset_snippet_data(iState).snippet_timestamps(allowed_snippets);
        state_snippet_trials = second_dataset_snippet_data(iState).snippet_trial(allowed_snippets);
        for iSnippet = 1:size(state_snippets,2)
            endx = second_dataset(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(end));
            beginningx = second_dataset(state_snippet_trials(iSnippet)).x_smoothed(state_snippets{iSnippet}(1));
            endy = second_dataset(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(end));
            beginningy = second_dataset(state_snippet_trials(iSnippet)).y_smoothed(state_snippets{iSnippet}(1));
            snippet_vector = [endx - beginningx, endy - beginningy];
            snippet_direction_second_dataset(iSnippet,iState) = atan2(snippet_vector(2),snippet_vector(1));
        end
    end
    
    if size(snippet_direction,1) > size(snippet_direction_second_dataset,1)
        snippet_direction_second_dataset(end+1:size(snippet_direction,1),:) = 0;
    else
        snippet_direction(end+1:size(snippet_direction_second_dataset,1),:) = 0;
    end
    
    all_snippet_directions = [snippet_direction snippet_direction_second_dataset];
    all_snippet_direction_labels = [(1:size(snippet_data,2)) (1:size(second_dataset_snippet_data,2))];
    states = 1:size(all_snippet_directions,2);
    [A,B] = meshgrid(states,states);
    c=cat(2,A',B');
    d=reshape(c,[],2);
    d = unique(sort(d,2), 'rows');
    
    
    %bonferroni correction
    p_thresh = (.05)/size(d,1);
    diff_count = 0;
    same_count = 0;
    
    for iCompare = 1:size(d,1)
        [p(d(iCompare,1),d(iCompare,2)),h(d(iCompare,1),d(iCompare,2)),~] = ...
            ranksum(all_snippet_directions(all_snippet_directions(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            all_snippet_directions(all_snippet_directions(:,d(iCompare,2)) ~= 0,d(iCompare,2)),'alpha',p_thresh); % input 2
        p_circ(d(iCompare,1),d(iCompare,2)) = circ_cmtest(all_snippet_directions(all_snippet_directions(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            all_snippet_directions(all_snippet_directions(:,d(iCompare,2)) ~= 0,d(iCompare,2)));
        cvfX = {all_snippet_directions(all_snippet_directions(:,d(iCompare,1)) ~= 0,d(iCompare,1)),all_snippet_directions(all_snippet_directions(:,d(iCompare,2)) ~= 0,d(iCompare,2))};
        [bH{d(iCompare,1),d(iCompare,2)}, fPEst{d(iCompare,1),d(iCompare,2)}, fWTest{d(iCompare,1),d(iCompare,2)}, strPMethod{d(iCompare,1),d(iCompare,2)}] = mardiatestn_circ_equal(cvfX,p_thresh);
        if pcirc(d(iCompare,1),d(iCompare,2)) <= p_thresh
            diff_count = diff_count + 1;
        elseif pcirc(d(iCompare,1),d(iCompare,2)) >= p_thresh
            same_count = same_count + 1;
        end
    end
    
    %%
else
    states = 1:size(snippet_direction,2);
    [A,B] = meshgrid(states,states);
    c=cat(2,A',B');
    d=reshape(c,[],2);
    d = unique(sort(d,2), 'rows');
    
    %bonferroni correction
    p_thresh = (.05)/size(d,1);
    diff_count = 0;
    same_count = 0;
    for iCompare = 1:size(d,1)
        [p(d(iCompare,1),d(iCompare,2)),h(d(iCompare,1),d(iCompare,2)),~] = ...
            ranksum(snippet_direction(snippet_direction(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            snippet_direction(snippet_direction(:,d(iCompare,2)) ~= 0,d(iCompare,2)),'alpha',p_thresh); % input 2
        p_circ(d(iCompare,1),d(iCompare,2)) = circ_cmtest(snippet_direction(snippet_direction(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            snippet_direction(snippet_direction(:,d(iCompare,2)) ~= 0,d(iCompare,2)));
        cvfX = {snippet_direction(snippet_direction(:,d(iCompare,1)) ~= 0,d(iCompare,1)),snippet_direction(snippet_direction(:,d(iCompare,2)) ~= 0,d(iCompare,2))};
        [bH{d(iCompare,1),d(iCompare,2)}, fPEst{d(iCompare,1),d(iCompare,2)}, fWTest{d(iCompare,1),d(iCompare,2)}, strPMethod{d(iCompare,1),d(iCompare,2)}] = mardiatestn_circ_equal(cvfX,p_thresh);
        if p_circ(d(iCompare,1),d(iCompare,2)) <= p_thresh
            diff_count = diff_count + 1;
            h(d(iCompare,1),d(iCompare,2)) = 1;
        elseif p_circ(d(iCompare,1),d(iCompare,2)) >= p_thresh
            same_count = same_count + 1;
            h(d(iCompare,1),d(iCompare,2)) = 0;
        end
    end    
end



direction_comparison_matrix.p = p_circ;
direction_comparison_matrix.p_thresh = p_thresh;
direction_comparison_matrix.is_sig = p_circ < p_thresh;
direction_compare.diff_count = diff_count;
direction_compare.same_count = same_count;
direction_compare.total_num_comparisons = diff_count + same_count;
direction_compare.num_different_comparisons_percentage = diff_count/direction_compare.total_num_comparisons;
if exist('second_dataset','var')
    direction_comparison_matrix.state_labels = all_snippet_direction_labels;
else
    direction_comparison_matrix.state_labels = states;
end


%% Plotting
figure('visible','on','color','white'); hold on
h = h';
[n,~]=size(h);
h_reflect=h'+h;
h_reflect(1:n+1:end)=diag(h);

imagesc(h_reflect);

if exist('second_dataset','var')
    xticks(all_snippet_direction_labels)
    xticks(all_snippet_direction_labels)
else
    xticks(states)
    yticks(states)
end
colormap(gca,winter(2));
axis square
axis tight
c = colorbar;
c.Ticks = [0,1];
c.TickLabels = {'similar','different'};
box off
xlabel('State Number')
ylabel('State Number')
dim = [.18 .6 .3 .3];
str = {'significant proportion of ',['comparisons between states: ' num2str(direction_compare.num_different_comparisons_percentage)]};
annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');

title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' state difference matrix - direction'));
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_direction_compare_matrix.png'));
close gcf



end