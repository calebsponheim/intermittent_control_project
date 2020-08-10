function  [data,cpl_st_trial_rew,targets] = CS_spiketimes_to_bins_v2(meta)

subject_filepath = meta.subject_filepath;
bad_trials = meta.bad_trials;
spike_hz_threshold = meta.spike_hz_threshold;
task = meta.task;
subject_events = meta.subject_events;
arrays = meta.arrays;
trial_length = meta.trial_length;
trial_event_cutoff = meta.trial_event_cutoff;
bin_size = meta.bin_size;




% load and import unsorted spiketimes for each channel
if strcmp(task,'RTP')
    for iArray = 1:length(subject_filepath)
        load(subject_filepath{iArray},'u','trial_end_30k','trial_start_30k');
        
        %%%%%%%%%%%%%% turning spike_hz_threshold into spike_num_threshold
        temp = cellfun(@max,[u.spikeTimes],'UniformOutput',false);
        
        trial_length_for_threshold = max(vertcat(temp{:}))/1000;
        spike_num_threshold = trial_length_for_threshold*spike_hz_threshold*max(vertcat(temp{:}));
        %%%%%%%%%%%%%%
        
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
    targets = [];
elseif strcmp(task,'center_out')
    load(subject_events, ['periOn' arrays{1}(1:2) '_30k'],'events','tp','targets');
    periOnM1_30k = periOnM1_30k(events(:,7) > 0);
    tp = tp(events(:,7) > 0,:);
    events = events(events(:,7) > 0,:);
    
    for iArray = 1:length(subject_filepath)
        load(subject_filepath{iArray},'u');
        
        %%%%%% turning spike_hz_threshold into spike_num_threshold
        trial_length_for_threshold = size(u(1).spikesLogical,2)/1000;
        spike_num_threshold = trial_length_for_threshold*spike_hz_threshold*size(u(1).spikesLogical,1);
        %%%%%%
        
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
        trial_go_relative_to_periOn = events(:,3);
        trial_move_relative_to_periOn = events(:,5);
        trial_end_relative_to_periOn = events(:,6);
    end
    
    if strcmp(trial_event_cutoff,'go') % goes from go to peri target reached.
        trial_start_30k = arrayfun(@(x,y) (x + y*30000),periOnM1_30k,trial_go_relative_to_periOn');
        trial_end_30k = arrayfun(@(x,y) (x + y*30000),periOnM1_30k,trial_end_relative_to_periOn');
    elseif strcmp(trial_event_cutoff,'move') % goes from move to peri target reached.
        trial_start_30k = arrayfun(@(x,y) (x + y*30000),periOnM1_30k,trial_move_relative_to_periOn');
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

% Create Bins
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
        data(iTrial).periOn_ms = periOnM1_30k(iTrial)/30;
        data(iTrial).tp = tp(iTrial);
        data(iTrial).target = targets(tp(iTrial),1:2);
        data(iTrial).ms_relative_to_periOn = ((trial_length(1)*1000)+.001):1:(trial_length(2)*1000); %ms
        if strcmp(trial_event_cutoff,'go')
            units(iTrial,:) = ...
                cellfun(@(x)(x - trial_go_relative_to_periOn(iTrial)),units(iTrial,:),'UniformOutput',false);
        elseif strcmp(trial_event_cutoff,'move')
            units(iTrial,:) = ...
                cellfun(@(x)(x - trial_move_relative_to_periOn(iTrial)),units(iTrial,:),'UniformOutput',false);
        elseif strcmp(trial_event_cutoff,'')
            units(iTrial,:) = ...
                cellfun(@(x)(x - trial_length(1)),units(iTrial,:),'UniformOutput',false);
        end
    end %iTrial
end
%



for iTrial = 1:num_trials
    if ~isnan(cpl_st_trial_rew(iTrial,2))
        % figure out how many 50ms bins can fit in the trial
        trial_len(iTrial) = cpl_st_trial_rew(iTrial,2) - cpl_st_trial_rew(iTrial,1);
        if strcmp(task,'center_out')
            num_bins_per_trial(iTrial) = round(trial_len(iTrial)/bin_size);
        else
            num_bins_per_trial(iTrial) = ceil(trial_len(iTrial)/bin_size);
        end
        % assigning bin edges
        for iBin = 1:num_bins_per_trial(iTrial)+1
            if iBin == 1
                bin_edges(iTrial,iBin,1:2) = ...
                    [cpl_st_trial_rew_relative(iTrial,1),cpl_st_trial_rew_relative(iTrial,1)+bin_size];
                data_temp(iTrial).bin_timestamps(iBin) = ...
                    (cpl_st_trial_rew(iTrial,1)+(bin_size/2))*1000;
            elseif iBin < (num_bins_per_trial(iTrial)+1)
                bin_edges(iTrial,iBin,1:2) = ...
                    [bin_edges(iTrial,iBin-1,2),bin_edges(iTrial,iBin-1,2)+bin_size];
                data_temp(iTrial).bin_timestamps(iBin) = ...
                    (data_temp(iTrial).bin_timestamps(iBin-1))+((bin_size)*1000);
            elseif iBin == (num_bins_per_trial(iTrial)+1)
                bin_edges(iTrial,iBin,1:2) = ...
                    [bin_edges(iTrial,iBin-1,2),bin_edges(iTrial,iBin-1,2)+bin_size];
            end
        end
    end
end

% putting spike counts in bins.
for iTrial = 1:num_trials
    data(iTrial).trial_start_ms = cpl_st_trial_rew(iTrial,1)*1000;
    data(iTrial).trial_end_ms = cpl_st_trial_rew(iTrial,2)*1000;
    
    if strcmp(task,'center_out')
        data(iTrial).ms_relative_to_trial_start = 1:1:((abs(trial_length(1)) + trial_length(2))*1000); %ms
    elseif strcmp(task,'RTP')
        data(iTrial).ms_relative_to_trial_start = 1:1:((data(iTrial).trial_end_ms - data(iTrial).trial_start_ms)+1); %ms
    end
    
    for iUnit = 1:num_units
        for iBin = 1:(sum(bin_edges(iTrial,:,1)>0))
            
            spikecount = sum(units{iTrial,iUnit} >  bin_edges(iTrial,iBin,1) ...
                & units{iTrial,iUnit} <  bin_edges(iTrial,iBin,2));
            
            % This was the original spikecount, un re-sampled, one cell per
            % bin size.
            
            % data(iTrial).spikecount(iUnit,iBin) = spikecount;
            
            % For Code Revamp: Resampling 50ms bins to 1ms bins, but
            % essentially by just duplicating the values, not by interpolating
            % or changing the actual size of the bins.
            
            if iBin == 1
                resamp_range = 1:(bin_size*1000);
            else
                resamp_range = ((iBin-1)*(bin_size*1000)+1) : ((iBin)*(bin_size*1000));
            end
            data_temp(iTrial).spikecountresamp(iUnit,resamp_range) = spikecount;
            data_temp(iTrial).bin_timestamps_resamp(resamp_range) = data_temp(iTrial).bin_timestamps(iBin);
        end
        data(iTrial).spikecountresamp(iUnit,1:length(data(iTrial).ms_relative_to_trial_start)) = ...
            data_temp(iTrial).spikecountresamp(iUnit,1:length(data(iTrial).ms_relative_to_trial_start));
    end
        data(iTrial).bin_timestamps_resamp = ...
            data_temp(iTrial).bin_timestamps_resamp(1:length(data(iTrial).ms_relative_to_trial_start));
end
end