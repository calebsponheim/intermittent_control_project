clear all

session = {'190228b' '190228d' '190228f'};

channels_to_analyze = 1:13;

for iBlock = 1:length(session)
    [trialwise_EMG] = EMG_processing_CS(session{iBlock},channels_to_analyze);
    save(['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' session{1}(1:6) '\CO_EMGs_' session{iBlock}],'trialwise_EMG')
end