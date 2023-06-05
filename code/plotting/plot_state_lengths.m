function snippet_length_per_state = plot_state_lengths(meta,snippet_data,colors)

length_count = 1;
figure('visible','off'); hold on
for iState = 1:length(snippet_data)
    iState_length_count = 1;
    for iSnippet = 1:length(snippet_data(iState).snippet_timestamps)
        snippet_length(length_count) = length(snippet_data(iState).snippet_timestamps{iSnippet});
        snippet_length_per_state{iState}(iState_length_count) = length(snippet_data(iState).snippet_timestamps{iSnippet});
        iState_length_count = iState_length_count + 1;
        length_count = length_count + 1;
    end
    if iState_length_count > 1 && (round(max(snippet_length_per_state{iState}),-1) >= 50)
        al_goodplot([snippet_length_per_state{iState}],iState,0.75, colors(iState,:), 'right', 50,std([snippet_length_per_state{iState}])/1000,1);
%         bar_x = 25:50:round(max(snippet_length_per_state{iState}),-1);
%         bar_values = histcounts(snippet_length_per_state{iState},0:50:round(max(snippet_length_per_state{iState}),-1));
%         if length(bar_values) < length(bar_x)
%             bar_x = bar_x(1:end-1);
%         end
%         bar(bar_x,bar_values,'FaceColor',colors(iState,:))
    end
end
box off
set(gcf,'color','w')
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' snippet length'));
ylabel('length of snippet (ms)')
xlabel('State Number')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_snippet_length.png'));
close gcf

figure('visible','off'); hold on
bar_x = 25:50:round(max(snippet_length),-1);
bar_values = histcounts(snippet_length,0:50:round(max(snippet_length),-1));
if length(bar_values) < length(bar_x)
    bar_x = bar_x(1:end-1);
end
bar(bar_x,bar_values)
box off
set(gcf,'color','w')
title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' snippet length'));
xlabel('length of snippet (ms)')
ylabel('Count (number of snippets)')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.crosstrain),'_snippet_length_all.png'));
close gcf

fprintf('Segment Length Mean: %i \nSegment Length Std Deviation: %i \n',[round(mean(snippet_length)),round(std(snippet_length))])
end