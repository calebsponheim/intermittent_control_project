%% Make new RTP Trace Single Trial Video

trial_to_plot = 20;
length_of_trail = 200; %frames



v = VideoWriter('~/Downloads/single_trial_vid.avi');
open(v)
for iFrame = 1:33:(length(data(trial_to_plot).x_smoothed)-length_of_trail)
    figure('visible','off');hold on
    box off
    set(gcf,'color','w')
    xlim([min(data(trial_to_plot).x_smoothed) max(data(trial_to_plot).x_smoothed)])
    ylim([min(data(trial_to_plot).y_smoothed) max(data(trial_to_plot).y_smoothed)])
    plot(data(trial_to_plot).x_smoothed(iFrame:iFrame+length_of_trail),data(trial_to_plot).y_smoothed(iFrame:iFrame+length_of_trail),'r','LineWidth',2.5)
    plot(data(trial_to_plot).x_smoothed(iFrame+length_of_trail),data(trial_to_plot).y_smoothed(iFrame+length_of_trail),'ro','MarkerSize',20)
    frame = getframe(gcf);
    writeVideo(v,frame);
    close(gcf);
end
close(v);