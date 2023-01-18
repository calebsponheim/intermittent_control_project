function snippet_length_per_state = plot_state_lengths(meta,snippet_data,colors)

length_count = 1;
for iState = 1:length(snippet_data)
    iState_length_count = 1;
    for iSnippet = 1:length(snippet_data(iState).snippet_timestamps)
        snippet_length(length_count) = length(snippet_data(iState).snippet_timestamps{iSnippet});
        snippet_length_per_state{iState}(iState_length_count) = length(snippet_data(iState).snippet_timestamps{iSnippet});
        iState_length_count = iState_length_count + 1;
        length_count = length_count + 1;
    end

    figure('visible','off'); hold on
    bar(25:50:round(max(snippet_length_per_state{iState}),-1),histcounts(snippet_length_per_state{iState},0:50:round(max(snippet_length_per_state{iState}),-1)),'FaceColor',colors(iState,:))
    box off
    set(gcf,'color','w')
    title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),'State ',num2str(iState),' snippet length'));
    xlabel('length of snippet (ms)')
    ylabel('Count (number of snippets)')
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','State ',num2str(iState),'_snippet_length.png'));
    close gcf
end

figure('visible','off'); hold on
bar(25:50:round(max(snippet_length),-1),histcounts(snippet_length,0:50:round(max(snippet_length),-1)))
box off
set(gcf,'color','w')
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' snippet length'));
xlabel('length of snippet (ms)')
ylabel('Count (number of snippets)')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_snippet_length.png'));
close gcf

end