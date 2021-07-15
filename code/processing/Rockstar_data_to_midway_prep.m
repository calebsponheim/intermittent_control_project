%% Rockstar_data_to_midway_prep

subject = 'RS';
if ispc
    subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4';
elseif ismac
    subject_filepath = '/Volumes/nicho-lab/nicho/ANALYSIS/rs1050211/rs1050211_clean_spikes_SNRgt4';
end
task = 'RTP';
bin_size = .050; %s
bad_trials = [2;92;151;167;180;212;244;256;325;415;457;508;571;662;686;748];
meta.session = '1050211';

% Scripts to run:

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

%% save
if ispc
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\' meta.subject meta.task meta.session 'CT' num2str(meta.crosstrain)], 'meta', 'data','-v7.3')
    else
        save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',meta.subject,meta.task,'_HMM_struct_',date),'-v7.3')
    end
else
    save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' meta.subject meta.task '_HMM_classified_test_data_and_output_' num2str(meta.num_states_subject) '_states_' meta.date],'-v7.3')
end
