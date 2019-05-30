% function nicho_spikes_to_organized_spiketimes()

%clear all

% load and import unsorted spiketimes for each channel
load('\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4','spikes','cpl_st_trial_rew','MIchans','x','y');

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


%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix,
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.

num_trials = size(cpl_st_trial_rew,1);
num_units = size(units,2);
bin_size = .050; %seconds

% Create Bins
clear trial_length
clear num_bins_per_trial
clear bin_edges
clear bin_timestamps

for iTrial = 1:num_trials
    % figure out how many 50ms bins can fit in the trial
    trial_length(iTrial) = cpl_st_trial_rew(iTrial,2) - cpl_st_trial_rew(iTrial,1);
    num_bins_per_trial(iTrial) = ceil(trial_length(iTrial)/bin_size);
    for iBin = 1:num_bins_per_trial(iTrial)
        if iBin == 1
            bin_edges(iTrial,iBin,1:2) = [cpl_st_trial_rew(iTrial,1),cpl_st_trial_rew(iTrial,1)+.050];
            bin_timestamps{iTrial}(iBin) = cpl_st_trial_rew(iTrial,1)+.025;
        else
            bin_edges(iTrial,iBin,1:2) = [bin_edges(iTrial,iBin-1,2)+.0001,bin_edges(iTrial,iBin-1,2)+.050];
            bin_timestamps{iTrial}(iBin) = bin_edges(iTrial,iBin-1,2)+.0251;
        end
    end
end


for iTrial = 1:num_trials
%     % Kinematic Binning
%     for iBin = 1:sum(bin_edges(iTrial,:,1)>0)
%         data(iTrial).kinematics.x(iBin) = average(x(%units{iUnit} >=  bin_edges(iTrial,iBin,1) & units{iUnit} <=  bin_edges(iTrial,iBin,2));
%         data(iTrial).kinematics.y(iBin) = average(y(%units{iUnit} >=  bin_edges(iTrial,iBin,1) & units{iUnit} <=  bin_edges(iTrial,iBin,2));
%     end
    
    for iUnit = 1:num_units
        for iBin = 1:sum(bin_edges(iTrial,:,1)>0)
            data(iTrial).spikecount(iUnit,iBin) = sum(units{iUnit} >=  bin_edges(iTrial,iBin,1) & units{iUnit} <=  bin_edges(iTrial,iBin,2));
        end
    end
end
        
%         %%% old code %%%
%         for iChannel = 1:length(spikeT)
%             u(iChannel).spikesLogical = false(length(periOnM1_ms),6000);
%             u(iChannel).channel = iChannel;
%             u(iChannel).array = array;
%             % for iTrial = 1:length(periOnM1_ms)
%             for iTrial = 100:length(periOnM1_ms)
%                 %     disp(iTrial)
%                 
%                 u(iChannel).spikeTimes{iTrial,1} = spikeT_ms{iChannel}(spikeT_ms{iChannel} <= (periOnM1_ms(iTrial)+(4499)) & spikeT_ms{iChannel} >= (periOnM1_ms(iTrial)-(1500))) - periOnM1_ms(iTrial);
%                 u(iChannel).spikesLogical(iTrial,((u(iChannel).spikeTimes{iTrial,1}+1501))) = true;
%             end
%         end
%         
%         % Create unitNum and nUnits and spikesT
%         unitNum(:,1) = 1:length(spikeT);
%         unitNum(:,2) = 33:96;
%         unitNum(:,3) = 1;
%         
%         nUnits = length(spikeT);
%         
%         spikesT = -1500:1:4499;
%         
%         save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\spatiotemporal_project\data\multiunit\Bx',session,array,'multiunit_per_channel_as_units.mat'),'u','unitNum','nUnits','spikesT')
%         
%     end