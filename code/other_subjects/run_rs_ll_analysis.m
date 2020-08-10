%% Analyze Breaux Data
clear
subject = 'RS';
subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4';
% subject_filepath = '/Volumes/nicho-lab/nicho/ANALYSIS/rs1050211/rs1050211_clean_spikes_SNRgt4.mat';
task = 'RTP';

bad_trials = [2;92;151;167;180;212;244;256;325;415;457;508;571;662;686;748];

% Scripts to run:

%% Structure Spiking Data
[data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials);

% save('RS_RTP_for_midway')
%% Build and Run Model - log-likelihood

num_states_subject = 16;
TRAIN_PORTION = .5;

rng(5);

for iStatenum = 2:30
    
    num_states_subject = iStatenum;
    for iRepeat = 1:3
        seed_to_train = round(abs(randn(1)*1000));
        [~,~,hn_trained{iStatenum,iRepeat},dc{iStatenum,iRepeat},dc_trainset{iStatenum,iRepeat},~,~] = train_and_decode_HMM(data,num_states_subject,[],[],0,seed_to_train,TRAIN_PORTION);
    end
end

save(strcat(subject,task,'_HMM_hn_',num2str(num_states_subject),'_states_',date),'hn_trained','dc','dc_trainset')