%% Center_out

session = {'180323'};

channels_to_analyze = 1:13;
task = 'CO';

for iBlock = 1:length(session)
    [trialwise_EMG] = EMG_processing_CS(session{iBlock},channels_to_analyze,task);
    save(['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' session{1}(1:6) '\CO_EMGs_' session{iBlock}],'trialwise_EMG')
end