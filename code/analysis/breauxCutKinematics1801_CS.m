function [] = breauxCutKinematics1801(session,params)

%%params and filenames
% dataDir = params.dataDirServer; %[params.dataDir session(1:6) '\'];
% correctVideo = params.correctVideo;
dataDirServer = params.dataDirServer;
plotDir = params.plotDir;

convconst = 1/6562;

kinematicsFile = ['Bx' session 'M1']; 
if strcmp(session(1:6),'171122') || strcmp(session(1:6),'171124')%changed arrays to check spectra problem
    disp(['session ' session(1:6) ' reading kinematics from PM?']);
    kinematicsFile = ['Bx' session 'PM'];
end

eventsFile = [dataDirServer 'Bx' session '_events.mat'];
load(eventsFile,'periOnM1_30k','isSuccess','eventsVidLat','targets','events');

% if correctVideo
%     file2save = [dataDirServer 'Bx' session '_kinematics.mat'];
%     events = events+eventsVidLat; events = events - repmat(events(:,2),1,size(events,2)); %realign on perion
% else
    file2save = [dataDirServer 'Bx' session '_kinematicsNoCorrection.mat'];
% end

%% cut and save kinematics
xGain = 0.2; xOffset = -4;
yGain = 0.2; yOffset = -2;

%read kinematics
filestring = [dataDirServer kinematicsFile, '.ns3'];

%find out how many chanels are the file 
kindata = openNSx(filestring, 'read', 't:1:10','sample');
nChannels = size(kindata.Data,1);

if nChannels == 132 %128 lfp + 4 kinematics
    kindata = openNSx(filestring, 'read', 'p:double','c:129:132'); %4 channels : x, y, vx, vy
    xpChannel = 1; ypChannel = 2;
    xvChannel = 3; yvChannel = 4;
    hasEyes = false;
elseif nChannels == 6 %just behavior (only used for pilots)
    kindata = openNSx(filestring, 'read', 'p:double'); %4 channels : x, y, vx, vy
    eyeXchannel = 1; eyeYchannel = 2;
    xpChannel = 3; ypChannel = 4;
    xvChannel = 5; yvChannel = 6;
    hasEyes = true;  
elseif nChannels == 134 %128 lfp + 2 eyes + 4 arm kinematics
    kindata = openNSx(filestring, 'read', 'p:double','c:129:134'); %4 channels : x, y, vx, vy
    eyeXchannel = 1; eyeYchannel = 2;
    xpChannel = 3; ypChannel = 4;
    xvChannel = 5; yvChannel = 6;
    hasEyes = true;
end    
kinPERION.hasEyes = hasEyes;

kData = kindata.Data;
% if strcmp(session,'171219')
%     kData = [kindata.Data{1} kindata.Data{2} kindata.Data{3} kindata.Data{4}];
% end
if strcmp(session,'180823c'), kData = [kindata.Data{1} kindata.Data{2}];
end
if strcmp(session,'181011a'), kData = kindata.Data{1};
end
if strcmp(session,'181106b'), kData = [kindata.Data{1} kindata.Data{2}];
end

%get event times in kin samp freq
periOnKin = round(periOnM1_30k./15);
% gocueKin = round(gocue./(flagSFREQ/kinSFREQ));
% reachcueKin = round(reward./(flagSFREQ/kinSFREQ));

if correctVideo
    periOnKin = periOnKin' + round(2000*eventsVidLat(:,2));
end

nTrials = numel(periOnKin);

%set time period to keep
msBeforePeriOn = 1000; msAfterPerioOn = 3500; lngthPERI = (2*msBeforePeriOn) + (2*msAfterPerioOn) + 1;
kinPERION.t = -(msBeforePeriOn):0.5:(msAfterPerioOn);
kinPERION.xp = nan(lngthPERI,nTrials); kinPERION.yp = kinPERION.xp; 
kinPERION.xv = kinPERION.xp; kinPERION.yv = kinPERION.xp; 
kinPERION.speed = kinPERION.xp;

if hasEyes
    kinPERION.eyex = nan(lngthPERI,nTrials); kinPERION.eyey = kinPERION.eyex;
end

%define a period of interest to look for movement onset
lookForOnset = [0 1000]; % ms wrt go cue

moveIDX.relative2max = nan(1,nTrials);
velfactor15 = 0.15; %relative to max speed

moveIDX.threshold = nan(1,nTrials);
vel_threshold = 0.03; %hard threshold (in volts, so essentially a meaningmess number)

moveIDX.exitsCenter = nan(1,nTrials); %we already have an event for this
%convert target data from kinarm log (cm) to volt values (gain & offset values are set on the trial dexterit file)
centerTarget(1) = xGain.*targets(1,1)+xOffset;
centerTarget(2) = yGain.*targets(1,2)+yOffset;
dist_threshold = xGain*targets(1,3);

%save in new variables (easier to test for noise and filter)
xp = kData(xpChannel,:).*convconst;
yp = kData(ypChannel,:).*convconst;
xv = kData(xvChannel,:).*convconst;
yv = kData(yvChannel,:).*convconst;

%sometimes there is 60 hz noise in the velocity recordings 
xv = removeLineNoise_SpectrumEstimation(xv, 2000, ...
    'LF = 60, M = 4096-point, WIN = hanning, hw = 8',[60 120 180 300 333 360 666]);
yv = removeLineNoise_SpectrumEstimation(yv, 2000, ...
    'LF = 60, M = 4096-point, WIN = hanning, hw = 8',[60 120 180 300 333 360 666]);

%this will reduce size to 50% without losing any important info. Also
%smooth velocity a bit. 
xp = round(xp,4); yp = round(yp,4);
xv = round(smooth(xv,31),4); yv = round(smooth(yv,31),4);

%treat eyes similarly if they exist
if hasEyes 
    xe = kData(eyeXchannel,:).*convconst;
    ye = kData(eyeYchannel,:).*convconst;
    % plot(xe(1:80000)); hold on
    % plot(medfilt1(xe(1:80000),80))
    xe = round(medfilt1(xe,181),4);
    ye = round(medfilt1(ye,181),4);
end

%   paramsFilter.Fs = 2000;
%   paramsFilter.tapers = [3 5]; %[3 5];% [5 9]; %[10 19]; %[3 5]; [NW K], K = 2NW-1
%   paramsFilter.pad = 0;% 1;%
%   paramsFilter.fpass = [0 1000];
%   paramsFilter.trialave = 0;
%   [S, f] = mtspectrumc(xe, paramsFilter);
%   figure; hold on;  plot(f,S); title('xp');

for iTrial = 1:nTrials
    iPeriOn = periOnKin(iTrial);
    
    if isSuccess(iTrial) %only keep successful trials
        %cut kinematics wrt PeriOn  
        kinPERION.xp(:,iTrial) = xp(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
        kinPERION.yp(:,iTrial) = yp(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
        kinPERION.xv(:,iTrial) = xv(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
        kinPERION.yv(:,iTrial) = yv(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
        kinPERION.speed(:,iTrial) = sqrt(kinPERION.xv(:,iTrial).^2+kinPERION.yv(:,iTrial).^2);
            
        if hasEyes
            kinPERION.eyex(:,iTrial) = xe(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
            kinPERION.eyey(:,iTrial) = ye(iPeriOn-2*msBeforePeriOn:iPeriOn+2*msAfterPerioOn);
        end
%         kinPERION.periOnMS(iTrial) = round(iPeriOn/2);
        
        %use gocue to search for movement onset after the go cue 
        iGOcue = round(2000*events(iTrial,3));
        iStart = iGOcue + 2*(msBeforePeriOn+lookForOnset(1));
        iEnd = iGOcue + 2*(msBeforePeriOn+lookForOnset(2));
        iSpeed = kinPERION.speed(iStart:iEnd,iTrial);
        ixp = kinPERION.xp(iStart:iEnd,iTrial);
        iyp = kinPERION.yp(iStart:iEnd,iTrial);
        
        
        %find move onset for this trial based on speed threshold
        if ~isempty(find(iSpeed >= vel_threshold, 1))
            moveIDX.threshold(iTrial) = iStart + find(iSpeed >= vel_threshold, 1) - 2*msBeforePeriOn;%save in samples relative to periOn
            %WHY NOT FLIP FOR THIS ^
            
            %find move onset for this trial based on max(speed), only if
            %above criterion satisfied
            iSpeedNRM = mapminmax(iSpeed',0,1); %iSpeedNRM = iSpeed./max(iSpeed); %
            [~,iMax] = max(iSpeedNRM); dummySpeed = iSpeedNRM(1:iMax);
            i15prc = iMax-find(fliplr(dummySpeed)<velfactor15,1);
            if ~isempty(i15prc) %this will be empty if iMax == 1
                moveIDX.relative2max(iTrial) = iStart + i15prc - 2*msBeforePeriOn;%save in samples relative to periOn
            end
            
            %sanity plot
%         a = moveIDX.relative2max(iTrial); figure; hold on;
%         plot(kinPERION.t,kinPERION.speed(:,iTrial))
%         line([a/2 a/2], ylim)
                
        else
            disp(['trial ' num2str(iTrial) ' velocity less than ' num2str(2000*xGain*xGain*vel_threshold) ' (cm/s?) for every point before ' num2str(lookForOnset(2)) ' ms']);
        end
           
        %find move onset based on when cursor leaves central target
        iDist = sqrt((ixp - centerTarget(1)).^2 + (iyp - centerTarget(2)).^2);
        if ~isempty(find(iDist >=  dist_threshold, 1))
            moveIDX.exitsCenter(iTrial) = iStart + find(iDist >=  dist_threshold, 1) - 2*msBeforePeriOn;%save in samples relative to periOn
        else
            disp(['trial ' num2str(iTrial) ' cursor did not leave ' num2str(dist_threshold) ' radius window before ' num2str(lookForOnset(2)) ' ms']);
        end
       
    end%if successful trial
end

if hasEyes
    figure; hold on
    for iTrial = 1:50
        plot(kinPERION.eyex(:,iTrial),kinPERION.eyey(:,iTrial),'.','color',[0 0 0 0.1])
    end
    
    if ~(exist(plotDir,'dir')), mkdir(plotDir); end
    saveas(gcf,[plotDir session ' eyes XY for 50 first trials.png']);
end

save(file2save,'kinPERION','moveIDX');

%also save in events file

if correctVideo
    moveIDXwrtCorrectedPeriOn = moveIDX; 
    
    moveIDX.relative2max = moveIDX.relative2max+round(2000*eventsVidLat(:,2))';
    moveIDX.threshold = moveIDX.threshold+round(2000*eventsVidLat(:,2))';
    moveIDX.exitsCenter = moveIDX.exitsCenter+round(2000*eventsVidLat(:,2))';
    moveIDXwrtNotCorrectedPeriOn = moveIDX;     
    
else
    moveIDXwrtNotCorrectedPeriOn = moveIDX; 
    
    moveIDX.relative2max = moveIDX.relative2max-round(2000*eventsVidLat(:,2))';
    moveIDX.threshold = moveIDX.threshold-round(2000*eventsVidLat(:,2))';
    moveIDX.exitsCenter = moveIDX.exitsCenter-round(2000*eventsVidLat(:,2))';
    moveIDXwrtCorrectedPeriOn = moveIDX; 
end

save(eventsFile,'moveIDXwrtCorrectedPeriOn','moveIDXwrtNotCorrectedPeriOn','-append');
    

end %function
