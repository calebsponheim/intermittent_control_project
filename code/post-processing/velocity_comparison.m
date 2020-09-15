function velocity_compare = velocity_comparison(data,snippet_data,meta,second_dataset,second_dataset_meta)
% function intention: compare the average speed of each state's snippets to
% every other state's speed.

%%
available_test_trials = find(ismember([data.trial_classification],'test'));

for iState = 1:size(snippet_data,2)
    [~,~,allowed_snippets] = intersect(available_test_trials,snippet_data(iState).snippet_trial);
    state_snippets = snippet_data(iState).snippet_timestamps(allowed_snippets);
    state_snippet_trials = snippet_data(iState).snippet_trial(allowed_snippets);
    for iSnippet = 1:size(state_snippets,2)
        snippet_velocity(iSnippet,iState) = data(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet}(end));
    end
end

%% Stats
if exist('second_dataset','var')
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
            snippet_velocity_second_dataset(iSnippet,iState) = second_dataset(state_snippet_trials(iSnippet)).speed(state_snippets{iSnippet}(end));
        end
    end
    
    if size(snippet_velocity,1) > size(snippet_velocity_second_dataset,1)
        snippet_velocity_second_dataset(end+1:size(snippet_velocity,1),:) = 0;
    else
        snippet_velocity(end+1:size(snippet_velocity_second_dataset,1),:) = 0;
    end
    
    all_snippet_velocity = [snippet_velocity snippet_velocity_second_dataset];
    all_snippet_velocity_labels = [(1:size(snippet_data,2)) (1:size(second_dataset_snippet_data,2))];
    states = 1:size(all_snippet_velocity,2);
    [A,B] = meshgrid(states,states);
    c=cat(2,A',B');
    d=reshape(c,[],2);
    d = unique(sort(d,2), 'rows');
%     d(d(:,1)==d(:,2),:) = [];
    
    
    %bonferroni correction
    p_thresh = (.05)/size(d,1);
    diff_count = 0;
    same_count = 0;
    for iCompare = 1:size(d,1)
        [p(d(iCompare,1),d(iCompare,2)),h(d(iCompare,1),d(iCompare,2)),~] = ...
            ranksum(all_snippet_velocity(all_snippet_velocity(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            all_snippet_velocity(all_snippet_velocity(:,d(iCompare,2)) ~= 0,d(iCompare,2)),'alpha',p_thresh); % input 2
        if h(d(iCompare,1),d(iCompare,2)) == 1
            diff_count = diff_count + 1;
        elseif h(d(iCompare,1),d(iCompare,2)) == 0
            same_count = same_count + 1;
        end
        
    end
else
    states = 1:size(snippet_velocity,2);
    [A,B] = meshgrid(states,states);
    c=cat(2,A',B');
    d=reshape(c,[],2);
    d = unique(sort(d,2), 'rows');
%     d(d(:,1)==d(:,2),:) = [];
    
    
    %bonferroni correction\
    p_thresh = (.05)/size(d,1);
    diff_count = 0;
    same_count = 0;
    
    for iCompare = 1:size(d,1)
        [p(d(iCompare,1),d(iCompare,2)),h(d(iCompare,1),d(iCompare,2)),~] = ...
            ranksum(snippet_velocity(snippet_velocity(:,d(iCompare,1)) ~= 0,d(iCompare,1)),... input 1
            snippet_velocity(snippet_velocity(:,d(iCompare,2)) ~= 0,d(iCompare,2)),'alpha',p_thresh); % input 2
        if h(d(iCompare,1),d(iCompare,2)) == 1
            diff_count = diff_count + 1;
        elseif h(d(iCompare,1),d(iCompare,2)) == 0
            same_count = same_count + 1;
        end
    end
end

velocity_compare.p = p;
velocity_compare.p_thresh = p_thresh;
velocity_compare.is_sig = h;
velocity_compare.diff_count = diff_count;
velocity_compare.same_count = same_count;
velocity_compare.total_num_comparisons = diff_count + same_count;
velocity_compare.num_different_comparisons_percentage = diff_count/velocity_compare.total_num_comparisons;
if exist('second_dataset','var')
    velocity_compare.state_labels = all_snippet_velocity_labels;
else
    velocity_compare.state_labels = states;
end

%% visualize stats lmao
figure('visible','on','color','white'); hold on
[n,~]=size(h);
h_reflect=h'+h;
h_reflect(1:n+1:end)=diag(h);

imagesc(h_reflect);
if exist('second_dataset','var')
    xticks(all_snippet_velocity_labels)
    xticks(all_snippet_velocity_labels)
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
str = {'significant proportion of ',['comparisons between states: ' num2str(velocity_compare.num_different_comparisons_percentage)]};
annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');

title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' state difference matrix - velocity'));
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_velocity_compare_matrix.png'));
close gcf



end