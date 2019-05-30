clear all

session = {'190228a' '190228c' '190228e' '190228g'};

total_trial_num = 0;

for iBlock = 1:length(session)
    trialwise_kinematics = event_pull_CS(session{iBlock});
%     total_trial_num = total_trial_num + length(data(iBlock).trialwise_kinematics);
    save(['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session{1}(1:6) '\RTP_kinematics_' session{iBlock}],'trialwise_kinematics')
end

clear iBlock
