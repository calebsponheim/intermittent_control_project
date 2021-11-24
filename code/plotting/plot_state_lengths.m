function plot_state_lengths(meta,snippet_data)

length_count = 1;
for iState = 1:length(snippet_data)
    for iSnippet = 1:length(snippet_data(iState).snippet_timestamps)
        snippet_length(length_count) = length(snippet_data(iState).snippet_timestamps{iSnippet});
        length_count = length_count + 1;
    end
end

figure('visible','off'); hold on
bar(25:50:1500,histcounts(snippet_length,0:50:1500))
box off
set(gcf,'color','w')
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' snippet length'));
xlabel('length of snippet (ms)')
ylabel('Count (number of snippets)')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_snippet_length.png'));
close gcf

end