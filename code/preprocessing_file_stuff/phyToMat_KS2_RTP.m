function [] = phyToMat_KS2_RTP(params)

% This is an edited version of Vassilis Papadourakis' phytoMat script for center-out data. 
% This script has been adapted for RTP data.

session = params.session;  
array = params.array;
% taskType = params.task; 
monkey = params.monkey; 
monkeyLong = params.monkeyLong;

%read the clustered phy output, and save spikes in trials (works for merged
%files)

% phyDataDir = ['C:\Kilosort\DATA\' session array '\'];
% phyDataDir = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\' monkeyLong '\20' session(1:2) '\' session(1:6) '\kilosort_outputs\' monkey session(1:6) array '\'];
% 
dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\' monkeyLong '\20' session(1:2) '\' session(1:6) '\'];

% phyDataDir = ['C:\Users\calebsponheim\Documents\Data\'  session(1:6) '\Kilosort outputs\' monkey session(1:6) array '\'];
phyDataDir =  ['C:\Users\calebsponheim\Documents\Data\from_vassilis\190227\Bx190227' array '\'];
% dataDirServer = 'C:\Users\calebsponheim\Documents\Data\190227\';


% saving file
% load([dataDirServer monkey session array '_RTP_units.mat'],'u','nUnits','spikesT','unitNum','trial_start','trial_end');

%read phy results 
spikeTimes = readNPY([phyDataDir 'spike_times.npy']); %spikeTimes are uint64
spikeClusters = readNPY([phyDataDir 'spike_clusters.npy']);
spikeTemplates = readNPY([phyDataDir 'spike_templates.npy']); spikeTemplates = spikeTemplates+1;
clusterStatus =  importphyCSV([phyDataDir 'cluster_groups.csv'], 2, inf);
clusterID = clusterStatus{:,1}; clusterStatus = clusterStatus{:,2};

load([phyDataDir monkey session(1:6) array '_rez2.mat'],'rez');
% template2channel = rez.ypos; % this var is not saved in KS2
[~, template2channel]       = max(gather(rez.U(:,:,1)), [], 1);

nSpikes = numel(spikeTemplates); spikeChannels = nan(nSpikes,1);  
for iSpike = 1:nSpikes, spikeChannels(iSpike) = template2channel(spikeTemplates(iSpike));
end %find out each spikes' channel (only way to work with current code)

chansWithSpikes = unique(spikeChannels); 

%% get events

file_list = dir(dataDirServer);
file_list = {file_list.name};

PM_files = cellfun(@(x)[dataDirServer x],file_list(startsWith(file_list,'RTP_EMGs')),'UniformOutput',false);
M1_files = cellfun(@(x)[dataDirServer x],file_list(startsWith(file_list,'RTP_kinematics')),'UniformOutput',false);

if strcmp(array(1:2),'PM')
    trial_start_2k = [];
    trial_end_2k = [];
    trial_session = [];
    for iFile = 1:length(PM_files)
        load(PM_files{iFile});
        trial_start_2k = [trial_start_2k [trialwise_EMGs.trial_start]];
        trial_end_2k = [trial_end_2k [trialwise_EMGs.trial_end]];
        trial_session = [trial_session {trialwise_EMGs.session}];
        clear trialwise_EMGs
    end
elseif strcmp(array(1:2),'M1')
    trial_start_2k = [];
    trial_end_2k = [];
    trial_session = [];
    for iFile = 1:length(M1_files)
        load(M1_files{iFile});
        trial_start_2k = [trial_start_2k [trialwise_kinematics.trial_start]];
        trial_end_2k = [trial_end_2k [trialwise_kinematics.trial_end]];
        trial_session = [trial_session {trialwise_kinematics.session}];
        clear trialwise_kinematics
    end
end

trial_start_30k = trial_start_2k*15;
trial_end_30k = trial_end_2k*15;

% load(eventsFile,['periOn' array(1:2) '_30k'],'isSuccess','eventsVidLat','stimPattern');
% eval(['periOn_30k = periOn' array(1:2) '_30k;']);
% if correctVideo, periOn_30k = periOn_30k' + round(30000*eventsVidLat(:,2)); 
% end

% keepTrials = isSuccess&(stimPattern==3)'; %only do successful no stim trials
% periOn_30k = periOn_30k(keepTrials); 

nTrials = numel(trial_start_30k);

% if strcmp(taskCondition,'delay')
%     msBeforePeriOn = 1500; msAfterPeriOn = 3500; %for instructed delay
% elseif strcmp(taskCondition,'nodelay')
%     if strcmp(monkey,'Bx')
%         msBeforePeriOn = 1000; msAfterPeriOn = 3000; %for no delay Breaux (longer task: proper rt control and intertrial period)
%     else
%         msBeforePeriOn = 1000; msAfterPeriOn = 1000; %for no delay Lester to avoid icms artifacts
%     end
%     disp(['saving ' num2str(msBeforePeriOn) ' ms before to ' num2str(msAfterPeriOn) ' ms after peri on (no delay task)']);
% end

spikesT = arrayfun(@(x,y) (x:1:y),trial_start_30k,trial_end_30k,'UniformOutput',false); 
nTimePoints = cellfun(@numel,spikesT);

%% read size of original files and convert perion to merged index (spikeTimes index)
load([dataDirServer monkey session(1:6) '_chunks.mat'],[monkey session(1:6) array '_dataLengths'],'sessions');
eval(['setLengths = ' monkey session(1:6) array '_dataLengths;']);
% load(eventsFile,'set','sets2merge');

sets2merge = unique(trial_session);

for iSession = 1:length(sets2merge)
    set(strcmp(sets2merge{iSession},trial_session)) = iSession;
end

cumSetLengths = cumsum(setLengths);
nSets = numel(unique(trial_session));
for iSet = 1:nSets
    setIndex = find(strcmp(sessions,[session(1:6) sets2merge{iSet}(end)]));
    if setIndex>1
        trial_start_30k(set==iSet) =  trial_start_30k(set==iSet) + cumSetLengths(setIndex-1);
        trial_end_30k(set==iSet) =  trial_end_30k(set==iSet) + cumSetLengths(setIndex-1);
    end
end

%% read phy and sort phy data channel, unit, trial
nChannels = 64; uCount = 1; 

for iChannel = 1:nChannels
    if ismember(iChannel,chansWithSpikes)%if template was found in this channel
        chanClusters = unique(spikeClusters(spikeChannels==iChannel)); %infer the channel clusters from spike channels 
        clusterCount = 0;
        for iCluster = chanClusters'     
%             if clusterStatus(clusterID==iCluster)~='noise' %if cluster not noise, make unit  
             if clusterStatus(clusterID==iCluster)=='good' %if cluster not noise, make unit
%              if clusterStatus(clusterID==iCluster)=='mua'
                    clusterCount = clusterCount+1;
                if sum(strcmp(array,{'M1m';'PMl'; 'LAm'; 'MEm'}))
                    u(uCount).channel = iChannel+32;
                elseif sum(strcmp(array,{'M1l';'PMm'; 'LAl'; 'MEl'}))
                    if iChannel<33, u(uCount).channel = iChannel;
                    else u(uCount).channel = iChannel+64;
                    end
                end
                u(uCount).array = array;
            
                uSpikeTimes = spikeTimes(spikeClusters==iCluster); 

                
                %u(uCount).WFmean = nanmean(uSpikeWFs);
                %u(uCount).WFstd = nanstd(uSpikeWFs);
                u(uCount).nSpikes = numel(uSpikeTimes);
            
                %sig = max(mean(uSpikeWFs)) - min(mean(uSpikeWFs));
                %rms = mean(std(uSpikeWFs));
                %u(uCount).SNR = sig / (2*rms);
            
                u(uCount).spikeTimes = cell(nTrials,1);
%                 u(uCount).spikesLogical = false(nTrials,nTimePoints);
                for iTrial = 1:nTrials
                    
                        %testing
%                         if iTrial == 97
%                             disp('halt')
%                         end
                    
                        iStart = trial_start_30k(iTrial);%*30;
                        iEnd = trial_end_30k(iTrial);%*30;
                        
                        iSpikes = double(uSpikeTimes(uSpikeTimes>iStart & uSpikeTimes<iEnd));
                        if ~isempty(iSpikes)
                            iSpikes = round((iSpikes-iStart)/30); %align and convert to ms
                            u(uCount).spikeTimes{iTrial} = unique(iSpikes); %sometimes there will be duplicates because of short trials
                        end%if spikes in trial                    
                end%for nTrials

                %keep a list also (unit, channel, unit in channel)
                unitNum(uCount,1) = uCount;
                unitNum(uCount,2) = iChannel;
                unitNum(uCount,3) = clusterCount;
                
                uCount = uCount+1;
            end% if cluster not noise
        end%for channel clusters
    else
        disp(['no template for ' session ' ' array ' ch' num2str(iChannel)]);
    end%if channel has units
end%for nChannels
    
nUnits = uCount-1;

%also make nUnits x nTrials x nTimePoints for Taka
% spikes3D = false(nUnits,nTrials,nTimePoints);
% for iUnit = 1:nUnits, spikes3D(iUnit,:,:) = u.spikesLogical;
% end

%save
disp([session ' ' array ' sorted ' num2str(nUnits) ' units']);
% saving file
save([dataDirServer monkey session array '_RTP_units.mat'],'u','nUnits','spikesT','unitNum','trial_start_30k','trial_end_30k'); %save to SERVER

end%function 

