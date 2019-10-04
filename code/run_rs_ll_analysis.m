%% Analyze Breaux Data
clear
subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4';
task = 'RTP';

bad_trials = [2;92;151;167;180;212;244;256;325;415;457;508;571;662;686;748];

% Scripts to run:

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials);

%% Build and Run Model - log-likelihood

num_states_subject = 16;

for iStatenum = 2:16
    
    num_states_subject = iStatenum;
    for iRepeat = 1:5
            [~,~,hn_trained{iStatenum,iRepeat},dc{iStatenum,iRepeat},~] = train_and_decode_HMM(data,num_states_subject,[],[],0);
    end
end
    
save(strcat(subject,task,'_HMM_hn_',num2str(num_states_subject),'_states_',date),'hn_trained','dc')