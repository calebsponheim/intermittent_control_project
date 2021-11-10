function  [data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,task,bin_size,move_only,muscle_lag)

% load and import unsorted spiketimes for each channel
if contains(subject_filepath,'1051013') || contains(subject_filepath,'1050225')
    if strcmp(task,'RTP')        
        load(subject_filepath,'spikes','st_trial_SRT','reward_SRT','MIchans');
        
        success_trial_count = 1;
        for iTrial = 1:length(st_trial_SRT)
            % if a reward time exists between this and the next start time,
            % then it's a successful trial. put it in the list.
            if iTrial == length(st_trial_SRT)
                if reward_SRT(reward_SRT > st_trial_SRT(iTrial))
                    st_trial_SRT_success(success_trial_count) = st_trial_SRT(iTrial);
                    success_trial_count = success_trial_count + 1;
                end
            elseif reward_SRT(reward_SRT > st_trial_SRT(iTrial) & reward_SRT < st_trial_SRT(iTrial+1))
                st_trial_SRT_success(success_trial_count) = st_trial_SRT(iTrial);
                success_trial_count = success_trial_count + 1;
            end
        end
        
        cpl_st_trial_rew(:,1) = st_trial_SRT_success;
        cpl_st_trial_rew(:,2) = reward_SRT;
    elseif strcmp(task,'CO')
        if move_only == 1
            load(subject_filepath,'spikes','go_cue','stmv','endmv','reward','st_trial','MIchans');
            
            success_trial_count = 1;
            for iTrial = 1:length(endmv)
                % if a reward time exists between this and the next start time,
                % then it's a successful trial. put it in the list.
                try
                    trial_start = st_trial(iTrial);
                    trial_go = go_cue(go_cue > trial_start & go_cue < st_trial(iTrial+1)); 
                    trial_go = trial_go(1);
                    trial_move = stmv(stmv > trial_go & stmv < st_trial(iTrial+1)); 
                    trial_move = trial_move(1);
                    trial_move_end = endmv(endmv > trial_move & endmv < st_trial(iTrial+1)); 
                    trial_move_end = trial_move_end(1);
                    trial_reward = reward(reward > trial_move_end & reward < st_trial(iTrial+1)); 
                    trial_reward = trial_reward(1);
                    
                    go_cue_success(success_trial_count) = trial_go + .150;
                    end_mv_success(success_trial_count) = trial_move_end;
                                        
                    success_trial_count = success_trial_count + 1;
                catch
                end
            end
            
            cpl_st_trial_rew(:,1) = go_cue_success';
            cpl_st_trial_rew(:,2) = end_mv_success';
        else
            load(subject_filepath,'spikes','cpl_st_trial','reward','MIchans')
            cpl_st_trial_rew(:,1) = cpl_st_trial;
            cpl_st_trial_rew(:,2) = reward;
        end
    else
        load(subject_filepath,'spikes','cpl_st_trial','reward','st_trial_SRT','reward_SRT','MIchans');
        
        success_trial_count = 1;
        for iTrial = 1:length(st_trial_SRT)
            % if a reward time exists between this and the next start time,
            % then it's a successful trial. put it in the list.
            if iTrial == length(st_trial_SRT)
                if reward_SRT(reward_SRT > st_trial_SRT(iTrial))
                    st_trial_SRT_success(success_trial_count) = st_trial_SRT(iTrial);
                    success_trial_count = success_trial_count + 1;
                end
            elseif reward_SRT(reward_SRT > st_trial_SRT(iTrial) & reward_SRT < st_trial_SRT(iTrial+1))
                st_trial_SRT_success(success_trial_count) = st_trial_SRT(iTrial);
                success_trial_count = success_trial_count + 1;
            end
        end
        
        cpl_st_trial_rew(:,1) = vertcat(cpl_st_trial,st_trial_SRT_success');
        cpl_st_trial_rew(:,2) = vertcat(reward,reward_SRT);
    end
else
    load(subject_filepath,'spikes','cpl_st_trial_rew','MIchans');
end

% getting rid of unneeded channels
spikes = spikes(MIchans);

% breaking out channels into units
for iChannel = 1:size(spikes,1)
    if iChannel == 1
        units = [spikes{iChannel}];
    else
        units = [units,spikes{iChannel}];
    end
end

% Making sure that empty channels are removed
unit_count = 1;
for iUnit = 1:size(units,2)
    if isempty(units{iUnit})
    else
        units_temp(unit_count) = units(iUnit);
        unit_count = unit_count + 1;
    end
end

%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

num_units = size(units,2);

% Create Bins
clear trial_length
clear num_bins_per_trial
clear bin_edges
clear bin_timestamps

trials = 1:size(cpl_st_trial_rew,1);
trials(bad_trials) = [];
cpl_st_trial_rew(bad_trials,:) = [];
num_trials = size(trials,2);

for iTrial = 1:num_trials
    % figure out how many 50ms bins can fit in the trial
    trial_length(iTrial) = cpl_st_trial_rew(iTrial,2) - cpl_st_trial_rew(iTrial,1);
    num_bins_per_trial(iTrial) = ceil(trial_length(iTrial)/bin_size);
    
    % assigning bin edges
    for iBin = 1:num_bins_per_trial(iTrial)
        if iBin == 1
            bin_edges(iTrial,iBin,1:2) = [cpl_st_trial_rew(iTrial,1),cpl_st_trial_rew(iTrial,1)+bin_size];
            bin_timestamps{iTrial}(iBin) = cpl_st_trial_rew(iTrial,1)+.025;
        else
            bin_edges(iTrial,iBin,1:2) = [bin_edges(iTrial,iBin-1,2),bin_edges(iTrial,iBin-1,2)+bin_size];
            bin_timestamps{iTrial}(iBin) = bin_edges(iTrial,iBin-1,2)+.025;
        end
    end
end

% putting spike counts in bins.
for iTrial = 1:num_trials
    for iUnit = 1:num_units
        for iBin = 1:(sum(bin_edges(iTrial,:,1)>0))
            data(iTrial).spikecount(iUnit,iBin) = sum(units{iUnit} >  bin_edges(iTrial,iBin,1) & units{iUnit} <  bin_edges(iTrial,iBin,2));
        end
    end
end