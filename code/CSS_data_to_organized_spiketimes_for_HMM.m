function  [data,cpl_st_trial_rew,bin_timestamps] = CSS_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,spike_hz_threshold,task,subject_events,arrays,trial_length,trial_event_cutoff)

% load and import unsorted spiketimes for each channel
if strcmp(task,'RTP')
    for iArray = 1:length(subject_filepath)
        load(subject_filepath{iArray},'u','trial_end_30k','trial_start_30k');
        
        % turning spike_hz_threshold into spike_num_threshold
        temp = cellfun(@max,[u.spikeTimes],'UniformOutput',false);
        
        trial_length_for_threshold = max(vertcat(temp{:}))/1000;
        spike_num_threshold = trial_length_for_threshold*spike_hz_threshold*max(vertcat(temp{:}));
        
        if max(cell2mat(strfind(subject_filepath,'180313'))) > 0
            if iArray == 1
                units = [u.spikeTimes];
            else
                units = [units [u.spikeTimes]];
            end
        else
            if iArray == 1
                units = [u([u.nSpikes] >= spike_num_threshold).spikeTimes];
            else
                units = [units [u([u.nSpikes] >= spike_num_threshold).spikeTimes]];
            end
        end
        clear u
    end
elseif strcmp(task,'center_out')
    load(subject_events, ['periOn' arrays{1}(1:2) '_30k'], ['rewardOn' arrays{1}(1:2) '_30k'],'events','tp');
    
    for iArray = 1:length(subject_filepath)
        load(subject_filepath{iArray},'u');
        
        % turning spike_hz_threshold into spike_num_threshold
        trial_length_for_threshold = size(u(1).spikesLogical,2)/1000;
        spike_num_threshold = trial_length_for_threshold*spike_hz_threshold*size(u(1).spikesLogical,1);
        
        if max(cell2mat(strfind(subject_filepath,'180323'))) > 0
            if iArray == 1
                units = [u.spikeTimes];
            else
                units = [units [u.spikeTimes]];
            end
        else
            if iArray == 1
                units = [u([u.nSpikes] >= spike_num_threshold).spikeTimes];
            else
                units = [units [u([u.nSpikes] >= spike_num_threshold).spikeTimes]];
            end
        end
        clear u
    end
    
    if max(strfind(subject_filepath{1},'180323')) > 0
        %         trial_start_relative_to_periOn = events(:,1);
        trial_end_relative_to_periOn = events(:,6);
        trial_go_relative_to_periOn = events(:,2);
    else
        %         trial_start_relative_to_periOn = events(:,1);
        trial_end_relative_to_periOn = events(:,6);
        trial_go_relative_to_periOn = events(:,3);
    end
    
    if strcmp(trial_event_cutoff,'go') % goes from go to peri target reached.
        trial_start_30k = arrayfun(@(x,y) (x + y*30000),periOnM1_30k,trial_go_relative_to_periOn');
        trial_end_30k = arrayfun(@(x,y) (x + y*30000),periOnM1_30k,trial_end_relative_to_periOn');
    elseif strcmp(trial_event_cutoff,'')
        trial_start_30k = arrayfun(@(x) (x + trial_length(1)*30000),periOnM1_30k);%,trial_start_relative_to_periOn');
        trial_end_30k = arrayfun(@(x) (x + trial_length(2)*30000),periOnM1_30k);%,trial_end_relative_to_periOn');
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
if ~isempty(bad_trials)
    units{bad_trials,:} = [];
end
num_trials = size(trials,2);

% Change Spiketime Relative Timing from periON to "trial start" time

if strcmp(task,'center_out')
    for iTrial = 1:num_trials
        data(iTrial).tp = tp(iTrial);
        units(iTrial,:) = cellfun(@(x)(x - trial_go_relative_to_periOn(iTrial)),units(iTrial,:),'UniformOutput',false);
    end %iTrial
end
%



for iTrial = 1:num_trials
    if ~isnan(cpl_st_trial_rew(iTrial,2))
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