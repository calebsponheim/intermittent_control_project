function plot_transition_matrix_v2(meta)

    matrix_no_identity = meta.hn.a;

for iState = 1:meta.optimal_number_of_states
    matrix_no_identity(iState,iState) = 0;
end

figure('visible','off','color','white'); hold on
imagesc(matrix_no_identity,[0 .5])
colormap(gca,jet)
axis square
axis tight
colorbar
box off
xlabel('pre-transition state')
ylabel('post-transition state number')

title(strcat(meta.subject,' ',strrep(meta.task,'_',' '),' transition matrix'));
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,num2str(meta.optimal_number_of_states),'states','_transition_matrix.png'));
close gcf
end