%% Doing some kinematic analysis

session = '190228a';
load(['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\190228\RTP_kinematics_' session '.mat'])

%% Trial Duration - throw out toooo long trials?

for iTrial = 1:size(trialwise_kinematics,2)
    trialwise_kinematics(iTrial).trial_length_sec = (trialwise_kinematics(iTrial).trial_end - trialwise_kinematics(iTrial).trial_start)/2000;
    if trialwise_kinematics(iTrial).trial_length_sec > 10
        trialwise_kinematics(iTrial).too_long_trial = 1;
    else
        trialwise_kinematics(iTrial).too_long_trial = 0;
    end
end

figure; hold on
histogram([trialwise_kinematics.trial_length_sec])
title(['trial length distribution for session ' session]);
xlabel('length of trial (seconds)')
hold off
saveas(gcf,['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' session '_trial_length_dist.png']);
close(gcf)
%% Quantify areas of Low Speed

low_speed_cutoff = .012;

for iTrial = 1:size(trialwise_kinematics,2)
    trialwise_kinematics(iTrial).instant_speed = sqrt((trialwise_kinematics(iTrial).x_vel.^2) + (trialwise_kinematics(iTrial).y_vel.^2));
    trialwise_kinematics(iTrial).low_speed_times = trialwise_kinematics(iTrial).instant_speed < low_speed_cutoff;
end


