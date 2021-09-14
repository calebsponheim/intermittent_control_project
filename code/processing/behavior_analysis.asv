task = 'CO';
session = '210810';
subject = 'Theseus';

dataDir = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\' subject '\' num2str(20) session(1:2) '\' session '\'];
files = dir([dataDir '*.zip']);
setName = files.name;
baseDir = '\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\';
plotDir = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\new_results\' subject '\' session '\'];
if ~exist(plotDir,'dir'), mkdir(plotDir); end

%% load
file2read = [dataDir setName];
bkindata = zip_load(file2read);
bkindata = bkindata(1).c3d;
bkindata = KINARM_add_hand_kinematics(bkindata);
rate = bkindata(1).HAND.RATE;

%% params
dirColors = hsv(8); trgColors = [0 0 0; hsv(8)];
if strcmp(task,'CO')
    targetTable = bkindata(1).TARGET_TABLE;
elseif strcmp(task,'RTP')
    targetTable = bkindata(1).TARGET_TABLE;
end
logicalRadius = targetTable.Logical_Radius; logicalRadius(logicalRadius==0) = [];
nTargets = numel(logicalRadius);

trgCentersGlobal = [targetTable.X_GLOBAL(1:nTargets) targetTable.Y_GLOBAL(1:nTargets)];

if strcmp(task,'CO')
    % EVENTS:
    %{'HAND_IN_CENTER   ', %1
    % 'PERI_TARGET_ON   ', %2
    % 'CENTER_TARGET_OFF', %3
    % 'REACTION         ', %4
    % 'MOVEMENT         ', %5
    % 'HAND_IN_PERI     ', %6
    % 'SUCCESS          '} %7
    
    % sort and save success trials
    nHandInCenter = 0; nPeriOn = 0; nGocue = 0; nGocueNoMovement = 0;
    nMovementStart = 0; nHandInPeri = 0; iSuccessTrial = 0; nErrorOut = 0;
    nAllTrials = size(bkindata,2);
    for iTrial = 1:nAllTrials
        if ~isempty(bkindata(iTrial).EVENTS)
            events = bkindata(iTrial).EVENTS.TIMES;
            evlabels = bkindata(iTrial).EVENTS.LABELS;
            if strncmp(evlabels(end),'HAND_IN_CENTER',14)
                nHandInCenter = nHandInCenter+1;
            elseif strncmp(evlabels(end),'PERI_TARGET_ON',14)
                nPeriOn = nPeriOn+1;
            elseif strncmp(evlabels(end),'CENTER_TARGET_OFF',17)
                nGocue = nGocue+1;
            elseif strncmp(evlabels(end),'REACTION',8)
                nGocueNoMovement = nGocueNoMovement+1;
            elseif strncmp(evlabels(end),'MOVEMENT',8)
                nMovementStart = nMovementStart+1;
            elseif strncmp(evlabels(end),'HAND_IN_PERI',12)
                nHandInPeri = nHandInPeri+1;
            elseif contains(evlabels(end),'ERROR')
                nErrorOut = nErrorOut+1;
            elseif strncmp(evlabels(end),'SUCCESS',7)
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
    nAllTrials = nPeriOn + nGocue + nGocueNoMovement + nMovementStart + nHandInPeri + nSuccess;
    disp(['Peri appeared but monkey broke hold: ' num2str(nPeriOn) '/' num2str(nAllTrials) '(' num2str(100*nPeriOn/nAllTrials,3) '%)']);
    disp(['Go cue given but monkey started implausibly fast: ' num2str(nGocue) '/' num2str(nAllTrials) '(' num2str(100*nGocue/nAllTrials,3) '%)']);
    disp(['Go cue given but monkey did not start moving: ' num2str(nGocueNoMovement) '/' num2str(nAllTrials) '(' num2str(100*nGocueNoMovement/nAllTrials,3) '%)']);
    disp(['Movement started but did not reach peri in time: ' num2str(nMovementStart) '/' num2str(nAllTrials) '(' num2str(100*nMovementStart/nAllTrials,3) '%)']);
    disp(['Cursor in peri but not for long enough: ' num2str(nHandInPeri) '/' num2str(nAllTrials) '(' num2str(100*nHandInPeri/nAllTrials,3) '%)']);
    disp(['nSuccess: ' num2str(nSuccess) '/' num2str(nAllTrials) '(' num2str(100*nSuccess/nAllTrials,3) '%)']);
    
    % plot x y separately for each tp
    fromEvent = 1; toEvent = 7;
    
    figure('visible','off','position',[96,126,1144,852]);
    idx = [2 3 6 9 8 7 4 1];
    for iTarget = 1:8
        tIDX = [trials(:).tp]==iTarget;
        tTrials = trials(tIDX);
        ntTrials = size(tTrials,2);
        subplot(3,3,idx(iTarget)); hold on
        for iTrial = 1:ntTrials
            t = tTrials(iTrial).t; ev = tTrials(iTrial).events;
            if max(ev) ~= 0
                
                x = 100*tTrials(iTrial).x - trgCentersGlobal(1,1);
                y = 100*tTrials(iTrial).y - trgCentersGlobal(1,2);
                [~,iStart] = min(abs(t-ev(fromEvent)));
                [~,iEnd] = min(abs(t-ev(end)));
                t = t - t(iStart); %align to ev2 (gocue)
                iStart = iStart-200; %plot a bit before that (samprate = 1000)
                h1 = plot(t,x,'color',[.8 .1 .1 .3]);
                h2 = plot(t,y,'color',[.1 .1 .8 .3]);
                
            end
            axis([-0.200 2.5 -7 7]); %x / y
            if iTarget == 6
                xlabel(['sec from ' trials(1).eventLabels{fromEvent}]);
                ylabel('cm from central target'); legend({'x'; 'y'});
            end
            line([0 0],ylim,'color','k');
        end
    end
    suptitle([session 'x y']);
    saveas(gcf,[plotDir  session ' x y.png']);
    
    % plot 2D trajectories
    fromEvent = 1; toEvent = 7;
    figure('visible','off'); hold on
    for iTrial = 1:nSuccess
        t = trials(iTrial).t; ev = trials(iTrial).events;
        if max(ev) ~= 0
            x = 100*trials(iTrial).x - trgCentersGlobal(1,1); y = 100*trials(iTrial).y - trgCentersGlobal(1,2);
            v = trials(iTrial).v;
            
            [~,iStart] = min(abs(t-ev(fromEvent)));
            [~,iEnd] = min(abs(t-ev(end)));
            
            %     plot(x(iStart:iEnd),y(iStart:iEnd),'color',[dirColors(trials(iTrial).tp,:)]);
            plot(x,y,'color',[dirColors(trials(iTrial).tp,:) 0.4]);
            %     plot(x(iStart:iEnd),y(iStart:iEnd),'color',[0 0 0 0.3]);
            %     plot(trials(iTrial).t,trials(iTrial).v,'color',[0 0 0 0.3])
        end
    end
    axis([-8 8 -8 8]); axis equal
    
    %add target circles
    % figure; hold on;
    
    centralC = trgCentersGlobal(1,:) ;
    for iTarget = 1:nTargets
        targetC = trgCentersGlobal(iTarget,:) - centralC;
        h = circle(targetC,logicalRadius(iTarget),100);
        set(h,'color',trgColors(iTarget,:));
    end
    axis([-8 8 -8 8]); axis equal
    saveas(gcf,[plotDir  session ' trajectories.png']);
    
    
    % hist epoch durations
    nEvents = 7;
    events = [];
    for iTrial = 1:size(trials,2)
        if length(trials(iTrial).events) == 6
            events(iTrial,:) = [0 .001 trials(iTrial).events(2:end)];
        elseif length(trials(iTrial).events) == 7
            events(iTrial,:) = trials(iTrial).events;
        else
            disp('something is wrong');
        end
    end
%     events = reshape([trials(:).events],nEvents,nSuccess);

    epochs = nan(length(events),nEvents-1);
    for iEpoch = 1:nEvents-1
        epochs(:,iEpoch) = events(:,iEpoch+1) - events(:,iEpoch);
    end
    figure('visible','off'); hold on
    epochNames = {'center target hold'; 'instructed delay'; 'min reaction'; 'reaction'; 'movement'; 'peri target hold' };
    rows = 2; cols = 3;
    epLims = nan(nEvents-1,2);
    for iEpoch = 1:nEvents-1
        subplot(2,3,iEpoch);
        histogram(epochs(:,iEpoch)); title(epochNames{iEpoch});
        epLims(iEpoch,:) = xlim; xx =  epLims(iEpoch,1);
        yy = ylim; yy = yy(1) + 0.9*(yy(2)-yy(1));
        text(xx,yy,['mean: ' num2str(mean(epochs(:,iEpoch)),3) ' median: '  num2str(median(epochs(:,iEpoch)),3) ])
    end
    saveas(gcf,[plotDir  session ' epoch durations.png']);
    
    % bar epochs
    tp =  [trials(:).tp];
    nTP = numel(unique(tp));
    figure('visible','off');
    for iEpoch = 4:5
        
        epData = cell(1,nTP); ii =1;
        tpNames = {'01 N'; '02 NE'; '03 E'; '04 SE'; '05 S'; '06 SW'; '07 W'; '08 NW'};
        tpNames = tpNames(ismember(1:8,unique(tp)));
        
        for iTP = 1:8
            if sum(tp==iTP)
                epData{ii} = epochs(tp==iTP,iEpoch); 
                ii = ii+1;
            end
        end
        
        barCell(epData,epLims(iEpoch,:),tpNames,dirColors(ismember(1:8,unique(tp)),:),[],epochNames{iEpoch},true);
        saveas(gcf,[plotDir  session ' ' epochNames{iEpoch} ' bar.png']);
        
    end
elseif strcmp(task,'RTP')
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
            if strncmp(evlabels(end),'FIRST_TARGET_ON',7)
                nFirst_target_on = nFirst_target_on+1;
            elseif strncmp(evlabels(end),'SECOND_TARGET_ON',7)
                nSecond_target_on = nSecond_target_on+1;
            elseif strncmp(evlabels(end),'THIRD_TARGET_ON',7)
                nThird_target_on = nThird_target_on+1;
            elseif strncmp(evlabels(end),'FOURTH_TARGET_ON',7)
                nFourth_target_on = nFourth_target_on+1;
            elseif strncmp(evlabels(end),'FIFTH_TARGET_ON',7)
                nFifth_target_on = nFifth_target_on+1;
            elseif strncmp(evlabels(end),'SIXTH_TARGET_ON',7)
                nSixth_target_on = nSixth_target_on+1;
            elseif strncmp(evlabels(end),'SEVENTH TARGET ON',7)
                nSeventh_target_on = nSeventh_target_on+1;
            elseif strncmp(evlabels(end),'SUCCESS',7)
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
    disp(['Peri appeared but monkey broke hold: ' num2str(nPeriOn) '/' num2str(nAllTrials) '(' num2str(100*nPeriOn/nAllTrials,3) '%)']);
    disp(['Go cue given but monkey started implausibly fast: ' num2str(nGocue) '/' num2str(nAllTrials) '(' num2str(100*nGocue/nAllTrials,3) '%)']);
    disp(['Go cue given but monkey did not start moving: ' num2str(nGocueNoMovement) '/' num2str(nAllTrials) '(' num2str(100*nGocueNoMovement/nAllTrials,3) '%)']);
    disp(['Movement started but did not reach peri in time: ' num2str(nMovementStart) '/' num2str(nAllTrials) '(' num2str(100*nMovementStart/nAllTrials,3) '%)']);
    disp(['Cursor in peri but not for long enough: ' num2str(nHandInPeri) '/' num2str(nAllTrials) '(' num2str(100*nHandInPeri/nAllTrials,3) '%)']);
    disp(['nSuccess: ' num2str(nSuccess) '/' num2str(nAllTrials) '(' num2str(100*nSuccess/nAllTrials,3) '%)']);
    
    
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
    
    
end

