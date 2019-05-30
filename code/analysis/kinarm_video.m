% Plot kinarm kinematic data with video


for iTrial = 2%:10
    frames_to_plot = 1:50:length(bkindata(iTrial).Right_HandX);
    v = VideoWriter(char(strcat("\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\",num2str(session),'_kinarmtrial_',num2str(iTrial))));
    open(v);
    for iFrame = 1:(length(frames_to_plot)-2)
        figure('visible','off'); hold on
        plot(bkindata(iTrial).Right_HandX(frames_to_plot(iFrame):frames_to_plot(iFrame)+100),bkindata(iTrial).Right_HandY(frames_to_plot(iFrame):frames_to_plot(iFrame)+100))
        xlim([min(bkindata(iTrial).Right_HandX) max(bkindata(iTrial).Right_HandX)]);
        ylim([min(bkindata(iTrial).Right_HandY) max(bkindata(iTrial).Right_HandY)]);
        % 4. save each frame
        frame = getframe(gcf);
        writeVideo(v,frame);
        close(gcf);
    end
    close(v);
end

