function [] = c3pKinematicAnalysis_CS(session)

setName = session;

% if exist('params','var') % if params contain variables
%     % dataDir = [params.baseDir 'data\Breaux\kinarm\'];
%     dataDir = params.dataDirServer; % set data directory
%     plotDir = [params.plotDir 'behavior\from kinarm\']; % set plotting directory
% else % otherwise, set your own goddamn analysis paths   
    dataDir = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\20' session(1:2) '\' session(1:6) '\'];
%     plotDir = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\new_results\Breaux\' session '\behavior\from kinarm\'];
    plotDir = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\new_results\Theseus\210810\'];
% end

if ~exist(plotDir,'dir'), mkdir(plotDir); end

%% load
file2read = [dataDir 'Bx' setName 'kinarmLog.zip'];
bkindata = zip_load(file2read);
bkindata = bkindata(1).c3d;
bkindata = KINARM_add_hand_kinematics(bkindata);
rate = bkindata(1).HAND.RATE;

%% params
% trgCenters = [-10.0  2.0;
%               -10.0  8.0; -5.757 6.243;
%                -4.0  2.0; -5.757 -2.243;
%               -10.0 -4.0; -14.243 -2.243;
%               -16.0  2.0; -14.243 6.243];
%
% trgWinDiam = 2*[0.8; 1; 1; 1; 1; 1; 1; 1; 1];
% fingertipDocking = [+18.648 +9.2417]; %position of finger tip when pin is on
% trgCentersGlobal = trgCenters + repmat(fingertipDocking,9,1);

colors_directory = hsv(16); target_colors = [0 0 0; hsv(64)];

targetTable = bkindata(1).TARGET_TABLE;

logicalRadius = targetTable.Logical_Radius; logicalRadius(logicalRadius==0) = [];
nTargets = numel(logicalRadius);

trgWinDiam = 2*logicalRadius;
trgCentersGlobal = [targetTable.X_GLOBAL(1:nTargets) targetTable.Y_GLOBAL(1:nTargets)];

% LAngAtCenter = [62 132]; %WHERE ARE THESE VALUES? should be in bkindata(1).CALIBRATION but it seems nothing is saved there

%EVENTS:
% 'FIRST_TARGET_ON'     1
% 'SECOND_TARGET_ON'    2
% 'THIRD_TARGET_ON'     3
% 'FOURTH_TARGET_ON'    4
% 'FIFTH_TARGET_ON'     5
% 'SIXTH_TARGET_ON'     6
% 'SEVENTH TARGET ON'   7
% 'CENTER_TARGET_OFF'   8
% 'HAND_IN_CENTER'      9
% 'HAND_IN_PERI'        10
% 'MOVEMENT'            11
% 'REACTION'            12
% 'SUCCESS          '   13
%% sort and save success trials
nFirst_target_on = 0;
nSecond_target_on = 0;
nThird_target_on = 0;
nFourth_target_on = 0;
nFifth_target_on = 0;
nSixth_target_on = 0;
nSeventh_target_on = 0;
iSuccessTrial = 0;
trials = [];
nAllTrials = size(bkindata,2);
for iTrial = 1:nAllTrials
    if ~isempty(bkindata(iTrial).EVENTS)
        events = bkindata(iTrial).EVENTS.TIMES;
        evlabels = bkindata(iTrial).EVENTS.LABELS;
%         if strncmp(evlabels(end),'FIRST_TARGET_ON',7)
%             nFirst_target_on = nFirst_target_on+1;
%         elseif strncmp(evlabels(end),'SECOND_TARGET_ON',7)
%             nSecond_target_on = nSecond_target_on+1;
%         elseif strncmp(evlabels(end),'THIRD_TARGET_ON',7)
%             nThird_target_on = nThird_target_on+1;
%         elseif strncmp(evlabels(end),'FOURTH_TARGET_ON',7)
%             nFourth_target_on = nFourth_target_on+1;
%         elseif strncmp(evlabels(end),'FIFTH_TARGET_ON',7)
%             nFifth_target_on = nFifth_target_on+1;
%         elseif strncmp(evlabels(end),'SIXTH_TARGET_ON',7)
%             nSixth_target_on = nSixth_target_on+1;
%         elseif strncmp(evlabels(end),'SEVENTH TARGET ON',7)
%             nSeventh_target_on = nSeventh_target_on+1;
%         elseif strncmp(evlabels(end),'SUCCESS',7)
         if contains(evlabels(end),'ERROR')
         elseif contains (evlabels(end),'HAND_IN_CENTER')
         else
            iSuccessTrial = iSuccessTrial+1;
            
            t = 0:(1000/rate):1000*events(end);
            t = t/1000;
            
            talk = true;
            while length(t)<length(bkindata(iTrial).Right_HandX)
%                 if talk, disp(['expanding t for trial ' num2str(iTrial)]); talk = false;
%                 end
                t = [t t(end)+(1/rate)];
            end
            
            talk = true;
            while length(t)>length(bkindata(iTrial).Right_HandX)
%                 if talk, disp(['shrinking t for trial ' num2str(iTrial)]); talk = false;
%                 end
                t = t(1:end-1);
            end
            
            [~,iStart] = min(abs(t-1000*events(1))); %this not needed in the new task because events(1) = 0 now for all trials
            
            t = t(iStart:end); t = t - t(1);
            events = events-events(1);
            
            trials(iSuccessTrial).t = t;
            trials(iSuccessTrial).events = events;
            trials(iSuccessTrial).eventLabels = evlabels;
            trials(iSuccessTrial).x = bkindata(iTrial).Right_HandX(iStart:end);% - 0.09; %bring to kinarm center (where is it now?)
            trials(iSuccessTrial).y = bkindata(iTrial).Right_HandY(iStart:end);% - 0.09;
            
            vx = bkindata(iTrial).Right_HandXVel(iStart:end);
            vy = bkindata(iTrial).Right_HandYVel(iStart:end);
            trials(iSuccessTrial).v = sqrt(vx.^2 + vy.^2);
            
            trials(iSuccessTrial).L1Ang = bkindata(iTrial).Right_L1Ang(iStart:end);
            trials(iSuccessTrial).L2Ang = bkindata(iTrial).Right_L2Ang(iStart:end);
            
            trials(iSuccessTrial).tp = bkindata(iTrial).TRIAL.TP;
            trials(iSuccessTrial).trialNum = bkindata(iTrial).TRIAL.TRIAL_NUM;
            
        end
    end
end

%also sort trials according to time
trials = sortStruct(trials,'trialNum');

%% calc and display success rates
nSuccess = iSuccessTrial;
nAllTrials = nFirst_target_on + nSecond_target_on + nThird_target_on + nFourth_target_on + nFifth_target_on + nSixth_target_on + nSeventh_target_on + nSuccess;
% disp(['Peri appeared but monkey broke hold: ' num2str(nPeriOn) '/' num2str(nAllTrials) '(' num2str(100*nPeriOn/nAllTrials,3) '%)']);
% disp(['Go cue given but monkey started implausibly fast: ' num2str(nGocue) '/' num2str(nAllTrials) '(' num2str(100*nGocue/nAllTrials,3) '%)']);
% disp(['Go cue given but monkey did not start moving: ' num2str(nGocueNoMovement) '/' num2str(nAllTrials) '(' num2str(100*nGocueNoMovement/nAllTrials,3) '%)']);
% disp(['Movement started but did not reach peri in time: ' num2str(nMovementStart) '/' num2str(nAllTrials) '(' num2str(100*nMovementStart/nAllTrials,3) '%)']);
% disp(['Cursor in peri but not for long enough: ' num2str(nHandInPeri) '/' num2str(nAllTrials) '(' num2str(100*nHandInPeri/nAllTrials,3) '%)']);
disp(['nSuccess: ' num2str(nSuccess) '/' num2str(nAllTrials) '(' num2str(100*nSuccess/nAllTrials,3) '%)']);

%% plot x y separately for each tp
% fromEvent = 1; toEvent = 7;
% 
% figure('position',[96,126,1144,852]);
% idx = [2 3 6 9 8 7 4 1];
% for iTarget = 1:8
%     tIDX = [trials(:).tp]==iTarget;
%     tTrials = trials(tIDX);
%     ntTrials = size(tTrials,2);
%     subplot(3,3,idx(iTarget)); hold on
%     for iTrial = 1:ntTrials
%         t = tTrials(iTrial).t; ev = tTrials(iTrial).events;
%         x = 100*tTrials(iTrial).x - trgCentersGlobal(1,1);
%         y = 100*tTrials(iTrial).y - trgCentersGlobal(1,2);
%         [~,iStart] = min(abs(t-ev(fromEvent))); [~,iEnd] = min(abs(t-ev(toEvent)));
%         t = t - t(iStart); %align to ev2 (gocue)
%         iStart = iStart-200; %plot a bit before that (samprate = 1000)
%         h1 = plot(t(iStart:iEnd),x(iStart:iEnd),'color',[.8 .1 .1 .3]);
%         h2 = plot(t(iStart:iEnd),y(iStart:iEnd),'color',[.1 .1 .8 .3]);
%     end
%       axis([-0.200 2.5 -7 7]); %x / y
%     if iTarget == 6
%         xlabel(['sec from ' trials(1).eventLabels{fromEvent}]);
%         ylabel('cm from central target'); legend({'x'; 'y'});
%     end
%     line([0 0],ylim,'color','k');
% end
% suptitle([session 'x y']);
% saveas(gcf,[plotDir  session ' x y.png']);
% 
%% plot L1 L2 separately for each tp
% fromEvent = 5; toEvent = 7;
% 
% figure('position',[96,126,1144,852]);
% idx = [2 3 6 9 8 7 4 1];
% for iTarget = 1:8
%     tIDX = [trials(:).tp]==iTarget;
%     tTrials = trials(tIDX);
%     ntTrials = size(tTrials,2);
%     subplot(3,3,idx(iTarget)); hold on
%     for iTrial = 1:ntTrials
%         t = tTrials(iTrial).t; ev = tTrials(iTrial).events;
%         x = rad2deg(tTrials(iTrial).L1Ang) - LAngAtCenter(1); %tTrials(iTrial).x;
%         y = rad2deg(tTrials(iTrial).L2Ang) - LAngAtCenter(2); %tTrials(iTrial).y;
%         [~,iStart] = min(abs(t-ev(fromEvent))); [~,iEnd] = min(abs(t-ev(toEvent)));
%         t = t - t(iStart); %align to ev2 (gocue)
%         iStart = iStart-200; %plot a bit before that (samprate = 1000)
%         h1 = plot(t(iStart:iEnd),x(iStart:iEnd),'color',[.8 .1 .1 .3]);
%         h2 = plot(t(iStart:iEnd),y(iStart:iEnd),'color',[.1 .1 .8 .3]);
%     end
%     axis([-0.200 1.5 -40 40]); %L1 L2 ang
%     
%     if iTarget == 6
%         xlabel(['sec from ' trials(1).eventLabels{fromEvent}]);
%         ylabel('deg from central position'); legend({'L1ang'; 'L2ang'});
%     end
%     line([0 0],ylim,'color','k');
% end
% 
% suptitle([session 'L1 L2']);
% saveas(gcf,[plotDir  session ' L1 L2.png']);

%% plot 2D trajectories
fromEvent = 1; toEvent = 7;
for iTrial = 1:nSuccess
    figure('visible','off'); hold on
    t = trials(iTrial).t; ev = trials(iTrial).events;
    x = 100*trials(iTrial).x - trgCentersGlobal(1,1); y = 100*trials(iTrial).y - trgCentersGlobal(1,2);
%     v = trials(iTrial).v;
    
    [~,iStart] = min(abs(t-ev(fromEvent))); [~,iEnd] = min(abs(t-ev(end)));
    
    %     plot(x(iStart:iEnd),y(iStart:iEnd),'color',[dirColors(trials(iTrial).tp,:)]);
    plot(x(iStart:iEnd),y(iStart:iEnd))%,'color',[colors_directory(trials(iTrial).tp,:) 0.4]);
    %     plot(x(iStart:iEnd),y(iStart:iEnd),'color',[0 0 0 0.3]);
    %     plot(trials(iTrial).t,trials(iTrial).v,'color',[0 0 0 0.3])
axis([-8 8 -8 8]); axis equal

%add target circles
nTargets = numel(trgWinDiam);
% figure; hold on;

centralC = trgCentersGlobal(1,:) ;
for iTarget = 1:nTargets
    targetC = trgCentersGlobal(iTarget,:) - centralC;
    h = plot(targetC(1),targetC(2),'ko','MarkerSize',trgWinDiam(iTarget)*10);
    set(h,'color',target_colors(iTarget,:));
%     distanceFrom1 = sqrt((targetC(1) - 0)^2 + (targetC(2) - 0)^2);
%     text(targetC(1),targetC(2),num2str(distanceFrom1,3));
end
axis([-8 8 -8 8]); 
saveas(gcf,[plotDir  num2str(iTrial) 'trajectories.png']);
close(gcf);
end


%% hist epoch durations
% nEvents = 7;
% events = reshape([trials(:).events],nEvents,nSuccess);
% epochs = nan(nSuccess,nEvents-1);
% for iEpoch = 1:nEvents-1
%     epochs(:,iEpoch) = events(iEpoch+1,:) - events(iEpoch,:);
% end
% figure; hold on
% epochNames = {'center target hold'; 'instructed delay'; 'min reaction'; 'reaction'; 'movement'; 'peri target hold' };
% rows = 2; cols = 3;
% epLims = nan(nEvents-1,2);
% for iEpoch = 1:nEvents-1
%     subplot(2,3,iEpoch);
%     histogram(epochs(:,iEpoch)); title(epochNames{iEpoch});
%     epLims(iEpoch,:) = xlim; xx =  epLims(iEpoch,1);
%     yy = ylim; yy = yy(1) + 0.9*(yy(2)-yy(1));
%     text(xx,yy,['mean: ' num2str(mean(epochs(:,iEpoch)),3) ' median: '  num2str(median(epochs(:,iEpoch)),3) ])
% end
% saveas(gcf,[plotDir  session ' epoch durations.png']);

%% bar epochs
% tp =  [trials(:).tp];
% nTP = numel(unique(tp));
% 
% if nTP>1
% for iEpoch = 4:5
%     
%     epData = cell(1,nTP); ii =1;
%     tpNames = {'01 N'; '02 NE'; '03 E'; '04 SE'; '05 S'; '06 SW'; '07 W'; '08 NW'};
%     tpNames = tpNames(ismember(1:8,unique(tp)));
%     
%     for iTP = 1:8
%         if sum(tp==iTP)
%             epData{ii} = epochs(tp==iTP,iEpoch); ii = ii+1;
%         end
%     end
%     
%     barCell(epData,epLims(iEpoch,:),tpNames,dirColors(ismember(1:8,unique(tp)),:),[],epochNames{iEpoch},true);
%     saveas(gcf,[plotDir  session ' ' epochNames{iEpoch} ' bar.png']);
% 
% end
% end
%%

