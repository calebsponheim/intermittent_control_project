% function nicho_spikes_to_organized_spiketimes()

%clear all

% load and import unsorted spiketimes for each channel
load(subject_filepath,'spikes','cpl_st_trial_rew','MIchans');

% format spiketimes to match the unit inputs normally given to Liz's script

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

units = units_temp;
clear units_temp

%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

num_units = size(units,2);
bin_size = .050; %seconds

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