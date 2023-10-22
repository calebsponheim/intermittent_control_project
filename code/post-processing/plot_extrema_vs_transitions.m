function plot_extrema_vs_transitions(meta,data)

iTestTrials = 1;
num_transitions = zeros(size(data,2),1);
num_speed_extrema = zeros(size(data,2),1);

prominence_RS = .0038;
prominence_RJ = .0081;
prominence_Bx = .0002;
if contains(meta.subject,'RS')
    prominence = prominence_RS;
elseif contains(meta.subject,'RJ')
    prominence = prominence_RJ;
elseif contains(meta.subject,'Bx')
    prominence = prominence_Bx;
end

for iTrial = 1:size(data,2)
    num_transitions(iTestTrials) = length(nonzeros(diff(data(iTrial).states_resamp)));
    num_speed_extrema(iTestTrials) = length(vertcat(nonzeros(islocalmax(data(iTrial).speed,'MinProminence',prominence)),nonzeros(islocalmin(data(iTrial).speed,'MinProminence',prominence))));
    iTestTrials = iTestTrials + 1;
end
[R,P] = corrcoef(num_transitions,num_speed_extrema);
disp(strcat('Transition/extrema Correlation: ',num2str(R(2))))
disp(strcat('Transition/extrema P-Value: ',num2str(P(2))))
linear_regression = fitlm(num_transitions,num_speed_extrema,'Intercept',false);
figure('visible','off','color','white'); hold on
plot(jitter(num_transitions),jitter(num_speed_extrema),'k.')
plot(0:100,(linear_regression.Coefficients.Estimate(1)*(0:100)),'LineWidth',3,'Color','Black')
line([0 100],[0 100],'Color','black')
xlabel('Number of State Transitions')
ylabel('Number of Local Extrema')
% dim = [.7 .02 .3 .3];
% str = strcat('Correlation: ',num2str(R(2),2));
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
xlim([0 max(vertcat(num_speed_extrema,num_transitions))]);
ylim([0 max(vertcat(num_speed_extrema,num_transitions))]);
box off
saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_extrema_vs_transitions.png'));
close gcf



end