function [] = breauxGetEvents_CS(session,params)

% will read kinarm file, flags from DAQ, flags from stimulator and nev and
% save events and tp for each trial, PERION in 30k iSample for both cerebuses,
% stim on in 30k iSample and stim pattern.

%% read cerebus data
% addpath(genpath(pwd));
% clear

close all
dataDir = params.dataDirServer;
plotDir = params.plotDir; if ~(exist(plotDir,'dir')), mkdir(plotDir); end

filenameNS5 = ['Bx' session 'M1']; filenameNEV = ['Bx' session 'PM'];

if strcmp(session(1:6),'171122') || strcmp(session(1:6),'171124')%changed arrays to check spectra problem
    filenameNS5 = ['Bx' session 'PM'];  filenameNEV = ['Bx' session 'M1'];
end

file2save = [dataDir 'Bx' session '_events.mat'];

convconst = 1/6562; %openNSx raw, not 'uV'

flagStartCh = 1; flagRewardCh = 2;
stimsyncChannel = 3; stimpatternChannel = 4;
stimsyncChannelPM = 1; stimpatternChannelPM = 2;

startEpochHEXA = 65508;
rewardEpochHEXA = 65512;

%% read perion event from ns5
filenameNS5 = [dataDir filenameNS5, '.ns5'];
[Trialstart_StartNS5, Trialstart_EndNS5, rewardStartNS5, validTrialsNS5, hasStim] = getEventsFromNS5(session,filenameNS5,flagStartCh,flagRewardCh,convconst);
nTrialsNS5 = numel(validTrialsNS5);

%% read perion event from nev
if strcmp(session(1:6),'180206')||strcmp(session(1:6),'180207')||strcmp(session(1:6),'180222')...
        ||strcmp(session(1:6),'180405') %use this to ignore PM recording. 
    delayStartNEV = Trialstart_StartNS5; delayEndNEV = Trialstart_EndNS5; 
    rewardStartNEV = rewardStartNS5; validTrialsNEV = validTrialsNS5; 
    nTrialsNEV = nTrialsNS5; stimOnPM = nan(nTrialsNS5,1);
    disp(['ignoring PM recording for ' session(1:6) '.']);
else %normal read NEV for PM and EMGs
    filenameNEV = [dataDir filenameNEV, '.nev'];
    [delayStartNEV, delayEndNEV, rewardStartNEV, validTrialsNEV] = getEventsFromNEV(filenameNEV,startEpochHEXA,rewardEpochHEXA);
    nTrialsNEV = numel(validTrialsNEV);
end

%% verify ns5 vs nev
[validNS5, validNEV] = alignBasedonTrialStart30k(Trialstart_StartNS5,delayStartNEV);

Trialstart_StartNS5 = Trialstart_StartNS5(validNS5); Trialstart_EndNS5 = Trialstart_EndNS5(validNS5);
validTrialsNS5 = validTrialsNS5(validNS5);

delayStartNEV = delayStartNEV(validNEV); delayEndNEV = delayEndNEV(validNEV);
validTrialsNEV = validTrialsNEV(validNEV);

ns5 = Trialstart_StartNS5-Trialstart_StartNS5(1);
nev = delayStartNEV-delayStartNEV(1);

figure('position',[1063 112 493 861]); hold on
subplot 211; hold on
plot(nev./30000, (nev-ns5)./30,'.');
xlabel('time (sec)'); ylabel('lag (=top-mid) (ms)');
title(['lag between cerebuses. maximum lag:' num2str(max(nev-ns5)/30) 'ms']);
subplot 212; hold on
aa = diff(ns5); bb = diff(nev); ka = aa-bb;
plot(aa,bb,'.'); line([0 max(aa)],[0 max(aa)]); 
axis equal; title(['nPoints out of diagonal: ' num2str(sum(abs(ka)>60))]);
xlabel('M1ns5 diff'); ylabel('PMnev diff');

saveas(gcf,[plotDir session ' cerebuses latency and alignment.png']);

%% get trial protocol (tp) and video latencies from kinarm log
% kinFilename = [kinarmFileDir 'data\Breaux\kinarm\' session '.zip'];
kinFilename = [dataDir 'Bx' session 'kinarmLog.zip'];
[events, eventsVidLat, trialsTP, trialNum, targets, delayStartKinarm] = getEventsFromKinarm(kinFilename);

% if strcmp(session(1:6),'180206') 
%     disp('breauxGetEvents: treating 180206 differently when reading kinarm (why?).');
%     events = events(6:end,:); 
%     eventsVidLat = eventsVidLat(6:end,:);
%     trialsTP = trialsTP(6:end);
%     trialNum = trialNum(6:end);
%     delayStartKinarm = delayStartKinarm(6:end);
% end

figure('visible','off');
subplot(2,1,1); histogram(eventsVidLat(eventsVidLat(:,2)>0,2),20:2:50); title('peri on command latency (ms)');
subplot(2,1,2); histogram(eventsVidLat(eventsVidLat(:,3)>0,3),20:2:50); title('go cue command latency (ms)');
saveas(gcf,[plotDir session ' videoLatency.png']);

eventsVidLat = eventsVidLat./1000;
nTrialsKinarm = numel(trialsTP); validTrialsKinarm = true(nTrialsKinarm,1);

%% verify that kinarm and cerebus are aligned and fix if needed
[validNS5, validKIN] = alignBasedonTrialStart30k(Trialstart_StartNS5,30000*delayStartKinarm);

Trialstart_StartNS5 = Trialstart_StartNS5(validNS5); Trialstart_EndNS5 = Trialstart_EndNS5(validNS5);
validTrialsNS5 = validTrialsNS5(validNS5);
delayStartNEV = delayStartNEV(validNS5); delayEndNEV = delayEndNEV(validNS5); % we can do this because these are already aligned
validTrialsNEV = validTrialsNEV(validNS5);

events = events(validKIN,:); eventsVidLat = eventsVidLat(validKIN,:);
trialsTP = trialsTP(validKIN); trialNum = trialNum(validKIN);
delayStartKinarm = delayStartKinarm(validKIN);
    
%realign delayStart and plot verification plot
delayStartKinarm = delayStartKinarm - delayStartKinarm(1);
delayStartSecNS5 = (Trialstart_StartNS5 - Trialstart_StartNS5(1))./30000;
diffKinarm = diff(delayStartKinarm);
diffCereb = diff(delayStartSecNS5)';

figure('position',[913,286,568,541]); hold on
plot(delayStartSecNS5,delayStartKinarm);
axis equal
xlabel('cerebus peri on'); ylabel('kinarm peri on');
title(['this line should be straight and this number zero: ' ...
    num2str(mean(diffKinarm - diffCereb))]);
saveas(gcf,[plotDir session ' mid cerebus vs kinarm perion.png']);

%% get type of patterned stimulation for each trial
nTrialsNS5 = numel(validTrialsNS5);
% if ~hasStim
%     disp(['no stimulation done in session ' session '.']);
%     stimPattern = 3*ones(nTrialsNS5,1); %label 3 is no stim
%     stimOnM1 = nan(nTrialsNS5,1); stimOnPM = nan(nTrialsNS5,1);
%     stimParams.nPulses = 0; stimParams.InterPulseIntervalMS = 0; stimParams.timeFromGoCue = 0;
% else
%     [stim_nPulses,stim_InterPulseIntervalMS,stim_timeFromGoCue,stimOnM1,stimPattern] = ...
%         readStimParamsAndPattern(filenameNS5,stimsyncChannel,stimpatternChannel,delayEndNS5,events,convconst,plotDir,session);
%     
%     if ~exist('stimOnPM','var') %read stimOnPM (good for removing artifacts) if PM is to be regarded 
%         [stim_nPulses2,stim_InterPulseIntervalMS2,stim_timeFromGoCue2,stimOnPM,stimPattern2] = ...
%             readStimParamsAndPattern([filenameNEV(1:end-3) 'ns5'],stimsyncChannelPM,stimpatternChannelPM,delayEndNEV,events,convconst,plotDir,session);
%     end
%     
%     stimParams.nPulses = stim_nPulses;
%     stimParams.InterPulseIntervalMS = stim_InterPulseIntervalMS;
%     stimParams.timeFromGoCue = stim_timeFromGoCue;
%     
%     %change "with" to "against" and vice versa for this session for 
%     %consistency with older sessions
%     if strcmp(session(1:6),'180409')
%         disp(['with changed to against for ' session(1:6) ' for consistency with other sessions']);
%         stimPattern(stimPattern==1) = 123; 
%         stimPattern(stimPattern==2) = 1;
%         stimPattern(stimPattern==123) = 2;
%         
%         stimPattern2(stimPattern2==1) = 123; 
%         stimPattern2(stimPattern2==2) = 1;
%         stimPattern2(stimPattern2==123) = 2;
%     end
% end%if hasStim

%% verify that everything is properly aligned (final sanity check) and save success index
iSuccessNS5 = nan(1,nTrialsNS5); isSuccess = false(1,nTrialsNS5);
for iTrial = 1:nTrialsNS5
    iPeriOn = Trialstart_StartNS5(iTrial);
    if ~isnan(events(iTrial,7)) %if successful trial according to kinarm
        if iTrial < nTrialsNS5
            iPeriOnNextTrial = Trialstart_StartNS5(iTrial+1);
            idx = find(rewardStartNS5>iPeriOn & rewardStartNS5<iPeriOnNextTrial,1);
        else %last trial
            idx = find(rewardStartNS5>iPeriOn,1);
        end
        
        if ~isempty(idx)
            isSuccess(iTrial) = true;
            iSuccessNS5(iTrial) = rewardStartNS5(idx(1))-iPeriOn;
            rewardStartNS5(idx) = [];
        else
            disp(['could not find success flag for trial ' num2str(iTrial) '. Trial will be marked as failed.']);
            events(iTrial,7) = nan;
        end
        
    end%if successful trial
end

%% at this point NS5, NEV, usablepattern and kinarm should have the same nTrials
%discard non valid trials (trials that were in the edges of the recording)
validTrials = validTrialsNS5 & validTrialsNEV;

periOnM1_30k = Trialstart_StartNS5(validTrials);
delayEndM1_30k = Trialstart_EndNS5(validTrials);
rewardOnM1_30k = iSuccessNS5(validTrials); %bad name because this is actually aligned to perion

periOnPM_30k = delayStartNEV(validTrials);
delayEndPM_30k = delayEndNEV(validTrials);

events = events(validTrials,:);
eventsVidLat = eventsVidLat(validTrials,:);
tp = trialsTP(validTrials);
isSuccess = isSuccess(validTrials); %redundant but keep
trialNum = trialNum(validTrials);

stimPattern = stimPattern(validTrials);

%% add observation condition 
nTrials = numel(tp); condition = cell(nTrials, 2);  
[condition{:,1}] = deal('EXEC');
if sum(strcmp(session,{'181018';'181019b';'181021c';'181022b';'181101b'}))
    [condition{:,2}] = deal('NODELAY');
elseif sum(strcmp(session,{'181029b';'181102b'}))
    [condition{:,2}] = deal('DELAY');
elseif sum(strcmp(session,{'181105b'; '181106b';'181113'}))
    [condition{ismember(tp,[1 3 5 7]),2}] = deal('NODELAY');
    [condition{ismember(tp,[2 4 6 8]),2}] = deal('DELAY');
    tp(tp==1) = 2; tp(tp==3) = 4; tp(tp==5) = 6; tp(tp==7) = 8; 
else
    disp('must add condition for this session')
    asfsdf
end

%also add these
emgBadTrials = false(sum(isSuccess),1); islooking = true(sum(isSuccess),1);
spikesBadTrials = false(sum(isSuccess),1); 

%% save
events = events - repmat(events(:,2),1,size(events,2)); %align on perion

save(file2save,'periOnM1_30k','delayEndM1_30k','rewardOnM1_30k',...
    'periOnPM_30k','delayEndPM_30k',...
    'events','eventsVidLat','tp','isSuccess','trialNum','targets',...
    'stimOnM1', 'stimOnPM', 'stimPattern', 'stimParams',...
    'emgBadTrials','islooking','condition');

end %function

function [delayStart, delayEnd, rewardStart, validTrialsNS5, hasStim] = getEventsFromNS5(session,filestring,flagDelayCh,flagRewardCh,convconst)
%read flags from ns5 of kinematics cerebus

flagData = openNSx(filestring, 'read'); %'p:double'
% flagSFREQ = flagData.MetaTags.SamplingFreq/1000;

fData = flagData.Data;
% if strcmp(session,'171219')
%     fData = [flagData.Data{1} flagData.Data{2} flagData.Data{3} flagData.Data{4}];
% end

if strcmp(session,'180823c'), fData = [flagData.Data{1} flagData.Data{2}];
end
if strcmp(session,'181011a'), fData = flagData.Data{1};
end
if strcmp(session,'181106b'), fData = [flagData.Data{1} flagData.Data{2}];
end
%check if session has stim by checking flagData size
hasStim = false;
if size(fData,1) >2
    stimData =  fData(3,:).*convconst;
    stimData = stimData>2; nStims = strfind(stimData, [0 1]);
    if nStims >10, hasStim = true; end
end

%read go cue and reach events
flagDelayEpoch = fData(flagDelayCh,:).*convconst;
flagRewardEpoch = fData(flagRewardCh,:).*convconst;

flagDelayEpoch = flagDelayEpoch>2;
flagRewardEpoch = flagRewardEpoch>2;

delayStart = strfind(flagDelayEpoch, [0 1]); %periOn, in sample index
delayEnd = strfind(flagDelayEpoch, [1 0]);
rewardStart = strfind(flagRewardEpoch, [0 1]);

nTrialsNS5 = numel(delayStart); validTrialsNS5 = true(nTrialsNS5,1);

i = 1;
while delayStart(i)<30001, validTrialsNS5(i) = false; i = i+1;
end%need to save at least one second before perion

if delayStart(1)>delayEnd(1), delayEnd(1) = []; end % remove first delayEnd, in case recording started mid trial

i = 1;
while delayStart(1)>rewardStart(i), rewardStart(i) = []; i = i+1;
end %remove any reward events may happened before the first trial

if  delayStart(end) > delayEnd(end) %if recording stopped midtrial and channel remained "on"
    validTrialsNS5(end) = false;
end
end%function

function [delayStartNEV, delayEndNEV, rewardStartNEV, validTrialsNEV] = getEventsFromNEV(filestring,delayEpochHEXA,rewardEpochHEXA)

digidata = openNEV(filestring, 'noread','nosave', 'nomat');

%SerialDigitalIO.UnparsedData has one entry for each occuring event.
%SerialDigitalIO.Timestamp has the time index of these events.
state_delayOn = find(digidata.Data.SerialDigitalIO.UnparsedData==delayEpochHEXA);
state_delayOff = state_delayOn+1;
state_reward = digidata.Data.SerialDigitalIO.UnparsedData==rewardEpochHEXA;

nTrialsNEV = numel(state_delayOn); validTrialsNEV = true(nTrialsNEV,1);

if state_delayOff(end)>numel(digidata.Data.SerialDigitalIO.TimeStamp)%if recording stopped midtrial and channel remained "on"
    state_delayOff(end) = [];
    validTrialsNEV(end) = false;
end

delayStartNEV = double(digidata.Data.SerialDigitalIO.TimeStamp(state_delayOn));
delayEndNEV =  double(digidata.Data.SerialDigitalIO.TimeStamp(state_delayOff));
rewardStartNEV =  double(digidata.Data.SerialDigitalIO.TimeStamp(state_reward));

i = 1;
while delayStartNEV(i)<30001, validTrialsNEV(i) = false; i = i+1;
end %need to save at least one second before perion

if delayStartNEV(1)>delayEndNEV(1), delayEndNEV(1) = []; end % remove first delayEnd, in case recording started mid trial

i = 1;
while delayStartNEV(1)>rewardStartNEV(i), rewardStartNEV(i) = []; i = i+1;
end %remove any reward events that may happened before the first trial
end

function [stim_nPulses,stim_InterPulseIntervalMS,stim_timeFromGoCue,stimOn,stimPattern] = ...
    readStimParamsAndPattern(filenameNS5,stimsyncChannel,stimpatternChannel,delayEndNS5,events,convconst,plotDir,session)

nTrialsNS5 = size(events,1);

flagData = openNSx(filenameNS5, 'read');%, 'p:double');
fData = flagData.Data;

stimsync = fData(stimsyncChannel,:).*convconst;
stimpattern = fData(stimpatternChannel,:).*convconst;

figure('visible','on'); hold on
iStart = 1; iEnd = 10000000;
% iStart = 96525688-10000000; iEnd = 96525688+10000000; 
% iStart = numel(stimsync)-100000000; iEnd = numel(stimsync);
t = (iStart:iEnd)/30;

goCue = delayEndNS5(~isnan(events(:,3)));
goCueMs = goCue./30;
hh = line([goCueMs; goCueMs]',[-5 5],'color',[0 0 0 0.3]);
h(1) = plot(t,stimsync(iStart:iEnd));
h(2) = plot(t,stimpattern(iStart:iEnd));
xlim([t(1) t(end)]);
legend([hh(1) h],'gocue', 'stimsync','stimpattern')
if ~(exist(plotDir,'dir')), mkdir(plotDir); end
saveas(gcf,[plotDir session ' stimData.png']);

stimOn = strfind(stimsync>1, [0 1]);
%     stimOff = strfind(stimsync>1, [1 0]);

%get nPulses from 1st pulse set
diffStimOn = diff(stimOn);
stim_nPulses = find(diffStimOn>1000,1);
stim_InterPulseIntervalMS = median(diff(stimOn)./30);

disp(['pulses in pattern: ' num2str(stim_nPulses)]);
disp(['inter pulse interval: ' num2str(stim_InterPulseIntervalMS) ' ms']);

%     disp(['pulse width: ' num2str(median((stimOff-stimOn)./30)) ' ms']); %this has no real meaning
%     trialsBeh.stimWidthMS = median((stimOff-stimOn)./30);

nPatterns = 3; offsetLabelsByOne = true;
[up] = getStimPattern(stimpattern, nPatterns, offsetLabelsByOne);

nStimAcks = size(up,1);
disp(['found ' num2str(nStimAcks) ' stim acknowledgements and gocues are ' num2str(nTrialsNS5) '. Aligning..']);

%there should be one pattern type for each go cue. Because sometimes a
%pattern is dropped, assign pattern to each go cue in a for loop. If no
%pattern is found near that gocue, don't assign anything.
goCue = delayEndNS5; %(~isnan(events(:,3)));
usablepattern = nan(nTrialsNS5,2); usablepattern(:,1) = goCue;
maxSampDiff = 5;

stim_timeFromGoCue = nan(nTrialsNS5,1);
stimOn1st = stimOn(1:stim_nPulses:end);

for iTrial = 1:nTrialsNS5
    if ~isnan(events(iTrial,3))
        [d,idx] = min(abs(goCue(iTrial)-up(:,1)));
        if d<maxSampDiff %should be d==0, but give some space (in samples)
            usablepattern(iTrial,:) = up(idx,:);
            up(idx,:) = [];
            if usablepattern(iTrial,2) <3 %with or against
                iStimOn = stimOn1st(find(stimOn1st>usablepattern(iTrial,1),1));
                
                if isempty(iStimOn)
                    disp(['no stim sync for trial' num2str(iTrial) ' pattern ' num2str(usablepattern(iTrial,2)) ...
                        '. Reverting trial to no stim (pattern 3).']);
                    usablepattern(iTrial,2) = 3;
                elseif (iStimOn-goCue(iTrial))/30 >300
                    disp(['stim sync for trial' num2str(iTrial) ' pattern ' num2str(usablepattern(iTrial,2)) ...
                        ' further than 300 ms. Reverting trial to no stim (pattern 3).']);
                    usablepattern(iTrial,2) = 3;
                else %valid stim
                    stim_timeFromGoCue(iTrial) = (iStimOn - usablepattern(iTrial,1))/30;
                end
                
            end
            
        else
            disp(['no pattern for trial ' num2str(iTrial) '/' num2str(nTrialsNS5) ', sample distance = ' num2str(d)]);
        end
    end%if go cue was actually shown in this trial
end%for nTrials

stimPattern = usablepattern(:,2);
disp(['stim delivered ' num2str(nanmedian(stim_timeFromGoCue)) ' ms after go cue']);

end%function
