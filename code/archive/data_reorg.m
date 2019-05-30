% formatting BREAUX CENTER OUT data for HMM training

clear all

% setting variables
session = '180313';
array = 'M1';
alignments = {'movement','instruction','BAT'}; % 'movement', 'instruction', etc.
TPs = [2 6];
num_TPs = length(TPs);
timesteps = -1000:1:2999;


dataDir = '\\prfs.cri.uchicago.edu\nicho-lab\vassilis\code\lib_spikes\';

%% get events and units
dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\20' session(1:2) '\'];
eventsFile = [dataDirServer session '\Bx' session '_events.mat'];
load(eventsFile,'events','eventsVidLat','stimPattern','isSuccess','tp','moveIDXwrtCorrectedPeriOn');
events = events+eventsVidLat; events = events - repmat(events(:,2),1,size(events,2)); %realign on perion 
events = 1000*events;%go to ms
moveMs = moveIDXwrtCorrectedPeriOn.relative2max./2; % updated way of computing movement onset 5/10/18
events(:,5) = moveMs; 
%unitFile = [dataDir session array 'units.mat'];
    unitFile = strcat(dataDir,session,array,'units.mat');
load(unitFile);

%% Reorganizing data for Naama Code
%   data should be a struct array, with field 'spikecount'
%   s.t., for each i trial, data(i).spikecount is an N x T matrix, 
%   where N is the number of recorded units and T is the number of time
%   bins.
%   data(i).spikecount(j,k) holds the sum of spikes (integer value) of unit
%   j at time bin k.
num_units = size(u,2);
num_trials = size(events,1);

bin_size = 50; %ms
num_bins = size(u(1).spikesLogical,2)/bin_size;

%%%

for iTrial = 1:size(events,1)
    data(iTrial).spikecount = zeros(num_units,num_bins);
    for iUnit = 1:num_units
        for iBin = 1:num_bins
            if iBin == 1
                data(iTrial).spikecount(iUnit,iBin) = sum(u(iUnit).spikesLogical(iTrial,1:50));
            else
                data(iTrial).spikecount(iUnit,iBin) = sum(u(iUnit).spikesLogical(iTrial,(((iBin-1)*50)+1):(iBin*50)));
            end
        end
%         [data(iTrial).spikecount(iUnit,:),~] = discretize(u(iUnit).spikesLogical(iTrial,:),num_bins);
    end
end