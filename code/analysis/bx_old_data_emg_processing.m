%% Center_out

session = '180323';

channels_to_analyze = 1:13;
task = 'CO';

subject_filepath_base = ...
    ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' session '\'];
subject_events = [subject_filepath_base 'Bx' session '_events.mat'];
load(subject_events,'periOnPM_30k','isSuccess');


[trialwise_EMG] = EMG_processing_CS(session,channels_to_analyze,task,periOnPM_30k,isSuccess);
save(['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' ...
     session(1:6) '\CO_EMGs_' session],'trialwise_EMG')
