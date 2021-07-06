%% Raju Data to Midway-prep-ready

subject = 'RJ';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\Collaboratorsdata\RTP\Raju\r1031206_PMd_MI\r1031206_PMd_MI_modified_clean_spikesSNRgt4';
num_states_subject = 5;
task = 'CO';
bin_size = .050;
meta.session = '1031206';
bad_trials = [4;10;30;43;44;46;53;66;71;78;79;84;85;91;106;107;118;128;141;142;145;146;163;165;172;173;180;185;203;209;210;245;254;260;267;270;275;278;281;283;288;289;302;313;314;321;326;340;350;363;364;366;383;385;386;390;391];

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,task,bin_size);

%% Assign Trial Classification
meta.bin_size = bin_size;
meta.subject = subject;
meta.crosstrain = 0;
meta.TRAIN_PORTION = 0.8; % percent
meta.MODEL_SELECT_PORTION = 0.1;
meta.TEST_PORTION = 0.1;
meta.task = task;
[data,meta] = assign_trials_to_HMM_group(data,meta);

%% Save Data for Midway

if ispc
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)], 'meta', 'data','-v7.3')
    else
        save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',meta.subject,meta.task,'_HMM_struct_',date),'-v7.3')
    end
else
    save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' meta.subject meta.task '_HMM_classified_test_data_and_output_' num2str(meta.num_states_subject) '_states_' meta.date],'-v7.3')
end
