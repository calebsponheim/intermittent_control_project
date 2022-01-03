function plot_extrema_vs_transitions(meta,data)

iTestTrials = 1;
num_transitions = zeros(size(data,2),1);
num_speed_extrema = zeros(size(data,2),1);

for iTrial = 1:size(data,2)
    num_transitions(iTestTrials) = length(nonzeros(diff(data(iTrial).states_resamp)));
    num_speed_extrema(iTestTrials) = length(vertcat(nonzeros(islocalmax(data(iTrial).speed,'MinProminence',.1)),nonzeros(islocalmin(data(iTrial).speed,'MinProminence',.1))));
    iTestTrials = iTestTrials + 1;
end

figure('visible','off','color','white'); hold on
plot(num_transitions,num_speed_extrema,'k.')
line([0 100],[0 100],'Color','black')
xlabel('Number of State Transitions')
ylabel('Number of Local Extrema')
xlim([0 max(vertcat(num_speed_extrema,num_transitions))]);
ylim([0 max(vertcat(num_speed_extrema,num_transitions))]);
box off
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_extrema_vs_transitions.png']);
close gcf

end