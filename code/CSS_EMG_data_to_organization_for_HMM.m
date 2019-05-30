function  [data,cpl_st_trial_rew,bin_timestamps] = CSS_EMG_data_to_organization_for_HMM(subject_filepath_EMGs,bad_trials,task)

% load and import unsorted spiketimes for each channel
if strcmp(task,'RTP')
    for iSession = 1:length(subject_filepath_EMGs)
        load(subject_filepath_EMGs{iSession});
        muscle_names = fieldnames(trialwise_EMG);
        muscle_names = muscle_names(startsWith(muscle_names,'EMG_'));
        if iSession == 1
            units = [u([u.nSpikes] >= spike_num_threshold).spikeTimes];
        else
            units = [units [u([u.nSpikes] >= spike_num_threshold).spikeTimes]];
        end
        clear u
    end
elseif strcmp(task,'center_out')
    for iSession = 1:length(subject_filepath_EMGs)
        load(subject_filepath_EMGs{iSession});
        if iSession == 1
            muscles = emgPERION;
        else
            muscles = cellfun(@(x,y)(vertcat(x,y)),muscles,emgPERION,'UniformOutput',false);
        end
        muscle_time = emgt;
        clear emgt emgPERION
    end
    
    % For center out, you need to preprocess the EMG data more:
    
    % from EMG processing script:
    sampling_rate = 2000;
    lowpassed_1k_resampled_2k = muscles;
    
    for iTrial = 1:size(muscles{1},1)
        % highpass at 10-15 hz
        dt=1/sampling_rate; % defining timestep size
        fN=sampling_rate/2;
        
        fhs=10;           % highpass frequency filter?
        
        [b,a]=butter(2,fhs/fN,'high');
        
        for iMuscle = 1:size(muscles,2)
            lo1k_resamp_hi10{iMuscle}(iTrial,:) = filtfilt(b,a,lowpassed_1k_resampled_2k{iMuscle}(iTrial,:)); % running bandpass filter.
        end
        
        % Rectify
        for iMuscle = 1:size(muscles,2)
            rectified_filtered_resampled{iMuscle}(iTrial,:) = abs(lo1k_resamp_hi10{iMuscle}(iTrial,:));
        end
        
        % Smooth (another lowpass)
        
        fhs=50; % lowpass frequency
        
        [b,a]=butter(2,fhs/fN);
        
        for iMuscle = 1:size(muscles,2)
            final_lowpass_data{iMuscle}(iTrial,:) = filtfilt(b,a,rectified_filtered_resampled{iMuscle}(iTrial,:)); % running bandpass filter.
        end
        
        %%%%%% done with preprocessing %%%%%%
        
    end
end




units = cellfun(@(x) (x./1000),units,'UniformOutput',false);

%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

cpl_st_trial_rew = ([trial_start_30k;trial_end_30k]')/30000;
cpl_st_trial_rew_relative = cpl_st_trial_rew - ((trial_start_30k/30000)');

num_units = size(units,2);
bin_size = .050; %seconds

% Create Bins
clear trial_length
clear num_bins_per_trial
clear bin_edges
clear bin_timestamps

trials = 1:size(units,1);
trials(bad_trials) = [];
units(bad_trials,:) = [];
num_trials = size(trials,2);

for iTrial = 1:num_trials
    % figure out how many 50ms bins can fit in the trial
    trial_length(iTrial) = cpl_st_trial_rew(iTrial,2) - cpl_st_trial_rew(iTrial,1);
    num_bins_per_trial(iTrial) = ceil(trial_length(iTrial)/bin_size);
    
    % assigning bin edges
    for iBin = 1:num_bins_per_trial(iTrial)
        if iBin == 1
            bin_edges(iTrial,iBin,1:2) = [cpl_st_trial_rew_relative(iTrial,1),cpl_st_trial_rew_relative(iTrial,1)+bin_size];
            bin_timestamps{iTrial}(iBin) = cpl_st_trial_rew(iTrial,1)+(bin_size/2);
        else
            bin_edges(iTrial,iBin,1:2) = [bin_edges(iTrial,iBin-1,2),bin_edges(iTrial,iBin-1,2)+bin_size];
            bin_timestamps{iTrial}(iBin) = bin_timestamps{iTrial}(iBin-1)+(bin_size);
        end
    end
end

% putting spike counts in bins.
for iTrial = 1:num_trials
    for iUnit = 1:num_units
        for iBin = 1:(sum(bin_edges(iTrial,:,1)>0))
            data(iTrial).spikecount(iUnit,iBin) = sum(units{iTrial,iUnit} >  bin_edges(iTrial,iBin,1) & units{iTrial,iUnit} <  bin_edges(iTrial,iBin,2));
            %             if data(iTrial).spikecount(iUnit,iBin) >= 1
            %                 disp('ok there''s one');
            %             end
        end
    end
end
end