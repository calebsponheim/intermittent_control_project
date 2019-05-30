% Kinematics Video

%% Plotting video of a single trial

for iTrial = 76
    frames_to_plot = 1:50:length(trialwise_kinematics(iTrial).x);
    v = VideoWriter(char(strcat("\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\",num2str(session),'_trial_',num2str(iTrial))));
    open(v);
    for iFrame = 1:(length(frames_to_plot)-2)
        figure('visible','off'); hold on
        plot(trialwise_kinematics(iTrial).x(frames_to_plot(iFrame):frames_to_plot(iFrame)+100),trialwise_kinematics(iTrial).y(frames_to_plot(iFrame):frames_to_plot(iFrame)+100))
        xlim([min(trialwise_kinematics(iTrial).x) max(trialwise_kinematics(iTrial).x)]);
        ylim([min(trialwise_kinematics(iTrial).y) max(trialwise_kinematics(iTrial).y)]);
        % 4. save each frame
        frame = getframe(gcf);
        writeVideo(v,frame);
        close(gcf);
    end
    close(v);
end
