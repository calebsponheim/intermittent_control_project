% This is a modification from Vassilis' code


% 2DO easy stuff: 
% Modes behavioral diff
% Modes BAT and R2 distributions <- this first, more fundamental

% OBS RTP PAPER

% plot wave

clear; 
close all
%addpath(genpath(pwd));
% addpath('\\midwaysmb.rcc.uchicago.edu\project\nicho\ToolBoxes\Waves\');
% no stim EMG
% filenames = {'171121'; '171122'; '171124'; %1-3    %'171011';?? %STIM AMP 4 targets <-these need attention for PM
%     '171128'; '171129'; '171130'; '171201b'; %4-7   %171205; ?? %OLD AMPS 4 targets
%     '171215'; '171220'; '171221'; %8-10  %2 targets %OLD AMPS 
%     '180105'; '180110b'; %11-12 %old amps, 8targets instructed delay
%     '180322'; '180323'; '180328'; '180605'};%13-16 %old amps, 8targets no delay


%% (stim sessions) EMG no delay task (two targets '/');
% filenames = {'180126'; '180129'; '180130';... %1-3
%              '180206'; '180208'; '180209'; '180212'; '180214'; '180215'; '180219'; '180222';... %4-11
%              '180312'; '180313'; '180314'; '180315'; '180316'; '180319'; '180320'; ... %12-18
%              '180409'; '180410'}; %19-20

%% all stim delay task1      2         3         4         5       6          7        8       9         10      
% filenames = {'180109'; '180112'; '180117'; '180119'; '180122'; '180124'; '180125'};

%% RC stim, no delay, 15 uA, tp2 tp6 BAD STIM DATASET
%          1(12uA,250ms) 2(250ms) 3(150ms)  4(100ms) 5(150ms)  6(150ms)  7(200ms)  8(200ms)  9(200ms, tp2)
% filenames = {'180206'; '180207'; '180208'; '180209'; '180212'; '180214'; '180215'; '180219'; '180222'}; 

%% all no delay (RC or diagonal stim, 15 uA, tp2 tp6)
% filenames = {'180126'; '180129'; '180130'; ...
%     '180208'; '180209'; '180212'; '180214'; '180215'; '180219'; '180222'; ...
%     '180312'; '180313'; '180314'; '180315'; '180316'; '180319'; '180320'; '180409'; '180410'}; 

%no delay dataset
% filenames = {'180313'; '180314'; '180315'; '180316'; '180319'; '180320'; '180126'; '180129'; '180409'; '180410';  };


%% expected delay exp
% filenames = {'180412'; '180413'; '180418a'; '180418b'};

%% exob
% filenames = {'180817b'; '180817c';'180820b'; '180820c';'180822b'; '180822c';'180823c'; '180823d'};
%               1           2         3          4          5           6         7          8          9   
filenames = {'180928b';  '181004'; '181009a'; '181009b'; '181010a'; '181010b'; '181011a'; '181011b'; '181011c';
%               10          11        12          13        14         15         16         17
            '181016a'; '181016b'; '181017a'; '181017b'; '181017c'; '181019a'; '181019b'; '181019c'; ...             
%               18        19          20          21         22         23        24          25          26
            '181021a'; '181021b'; '181021c';  '181022a'; '181022b'; '181022c'; '181029a'; '181029b'; '181029c';...
            %   27         28         29        30         31         32          33        34          35
            '181101a'; '181101b'; '181101c'; '181102a'; '181102b'; '181102c'; '181105a'; '181105b'; '181105c';...
            %   36         37         38        39
            '181106a'; '181106b'; '181205a'; '181205b'};

        
%% dummy
% filenames = {'181113';};% '171220'; '171221'; '180109'; '180112'; '180117'; '180119'; '180122'; '180124'; '180125'; ...
%     '180313'; '180314'; '180315'; '180316'; '180319'; '180320'; '180126'; '180129'; '180130'; '180409'; '180410';};

%%
nFiles = numel(filenames);
% bat85 = repmat(-250,nFiles,1);

%% initialize params and read beta peaks (cf) and start time of beta drop (bat85) from xls
params = init_paramsBreaux;

breauxxls = [params.codeDir 'Bx Log Book.xlsx']; cfSheet = 'cf';
[~,~,raw] = xlsread(breauxxls,cfSheet,'A2:AA144');
sessionNamesCF = cell2mat(raw(:,1)); cfLowAll = cell2mat(raw(:,2)); cfHighAll = cell2mat(raw(:,3));

[~,~,raw] = xlsread(breauxxls,'bat85','A3:S144');
sessionNamesBAT85 = cell2mat(raw(:,1));
% bat85All = -cell2mat(raw(:,2:10)); %low beta
bat85All = -cell2mat(raw(:,11:19)); %high beta % ms priot to MOVE

% params.reactionLimsAll = [stimOnXLSA+(stimDurXLS./2) stimOnXLSB+(stimDurXLS./2)-bat85];
%% run stuff
% params.correctVideo = true;
% for iTP = [2 6] 
%     params.theTP = iTP; 
%     breauxPatternedICMSreactionTimesAllFiles1803(filenames, params)
% end
%or sessionGroupAnalysisBreaux.m for this

%% 
for iFile = 38:39%1:nFiles %[18 20 21 22 29 28] %1:nFiles
 
%     close all
    params = init_paramsBreaux;
     
    session = filenames{iFile}; 
    params.session = session; 
    params.dataDirServer =  [params.dataDirServer session(1:2) '\' session(1:6) '\']; 
    params.plotDir = [params.codeDir 'new results\Breaux\' session '\'];
%     params.plotDir = [params.codeDir 'new results\exob beta drop\'];
%   params.plotDir = [params.baseDir 'new results\Breaux\patterned icms\vs trial number\'];
%   params.plotDir = [params.baseDir 'new results\Breaux\fooof fits\'];
%     params.plotDir = [params.codeDir 'new results\mode kinematics\'];
    
    disp(['running stuff for Breaux ' session]);

%     if strcmp(session,'180215'), params.keepTheseTrials = [301 1415]; end %first 300 trials were no stim trials
    
 %%  BEHAVIOR 
%     c3pKinAnalysisForBatch(session,params)
    
    %get and plot behavior 
%     breauxGetEvents(session,params);      
%     breauxCutKinematics1801(session,params);
% 
%     breauxPlotKinematics1801(session,params);
%     breauxPlotKinematicsAndEyes1804(session,params);
    
    %observation
%     breauxGetObservationEvents(session,params);
%     breauxCutEyesObservation(session,params);
%     breauxPlotOnlyEyes(session,params);

    %kinematics for different modes
%     breauxCompareModeKinematics1805(session,params);

%% patterned stim plots
%     %get effective range
%     load([params.dataDirServer 'Bx' session '_events.mat'],'stimParams')
%     stimOnA = round(nanmean(stimParams.timeFromGoCue)); stimOnB = stimOnA;
%     if params.correctVideo
%         stimOnA = stimOnA -45;%-45; %-38;%
%         stimOnB = stimOnB -45; %-38;%
%     end % 30 37.5 45
%     stimDur = (stimParams.nPulses-1)*stimParams.InterPulseIntervalMS;
% % % %     
%     for iTP = [2 6]       
%         params.theTP = iTP;   
%         bat85 = bat85All(sessionNamesBAT85==str2double(session),params.theTP);
%         if ~isnan(bat85)
%             params.reactionLims = [stimOnA+(stimDur./2) stimOnB+(stimDur./2)-bat85];
% %             params.reactionLims = [stimOnA+(stimDur./2) 1000];%
% % %            
%             breauxKinematicsPatternedICMS1801(session,params);
%             breauxPatternedICMSreactionTimes1801(session,params);
% %             breauxPatternedICMS_RTandBAOrose(session,params);
%         end
%     end
    
%% LFP STUFF 
    params.reactionLims = []; params.theTP = 9;
%     params.array = 'PM'; cutLFPchannelsBreaux1805(session, params,'.ns3');
%     params.array = 'M1'; cutLFPchannelsBreaux1805(session, params,'.ns3');
%     params.array = 'M1m'; plotStimArtifactBreauxFaster(session,params); % THIS NEEDS UPDATE FOR NEW RESULTS 
%     params.array = 'PM'; plotStimArtifactBreauxFaster(session,params);

%  params.array = 'M1'; removeLFPartifactBreaux1801(session, params,'.ns6');


%% spectra 
%     params.discardEMGtrials = true; 
%     params.alignEvent = 3; params.alignment = 'GO';
%     params.spectra_frange = [5 50]; %this will be used for PSD estimation, normalization, fit. 
% %     params.spectra_tLims = [-499.5 00]; %with respect to alignment. size affects the PSD frequency bw
%     params.spectra_tLims = [-999.5 00]; %with respect to alignment. size affects the PSD frequency bw
% 
% 
%     params.array = 'PM'; calcSaveSpectraBreaux1807(session,params);  close all;
%     params.array = 'M1'; calcSaveSpectraBreaux1807(session,params);  close all;
% % % % % % % %     
%     params.array = 'PM'; plotSpectraBreaux1807(session,params); close all;
%     params.array = 'M1'; plotSpectraBreaux1807(session,params); close all;
% % % % % % % %     
%     plotSpectraFOOOFBreaux1807(session,params);%needs data run for both arrays
%     plotSpectraFOOOFvsBehaviorBreaux1807(session,params);  close all;
%     
%     params.alignEvent = 5; params.alignment = 'MOVE';
%     params.spectra_frange = [5 50]; %this will be used for PSD estimation, normalization, fit. 
%     params.spectra_tLims = [00 +499.5]; %with respect to alignment. size affects the PSD frequency bw
% %     
%     params.array = 'PM'; calcSaveSpectraBreaux1807(session,params);  close all;
%     params.array = 'M1'; calcSaveSpectraBreaux1807(session,params);  close all;
% % %     
%     params.array = 'PM'; plotSpectraBreaux1807(session,params); close all;
%     params.array = 'M1'; plotSpectraBreaux1807(session,params); close all;
%    
%     plotSpectraFOOOFBreaux1807(session,params);%needs data run for both arrays
%     plotSpectraFOOOFvsBehaviorBreaux1807(session,params); %also see plotBATvsRT.m

 %calcAndPlotSpectraBreauxSimple1801test(session,params); %norm and fooof tests

    %spectrogram 
%     params.array = 'PM'; calcSaveSlidingSpectraBreaux1807(session,params);
%     params.array = 'M1'; calcSaveSlidingSpectraBreaux1807(session,params);
    
%     plotTrialSpctGramBreaux1807(session,params)
    

%% envelopes
    %get cf 
    cfLow = cfLowAll(sessionNamesCF==str2double(session(1:6)));
    cfHigh = cfHighAll(sessionNamesCF==str2double(session(1:6)));
    
    params.alignEvent = 2; params.alignment = 'PERION';
    
    params.array = 'M1m';
    params.betaPeakF = cfLow;%cfHigh;% 
    saveBetaAmpAndPhaseBreaux(session,params)
    savePSDnormedBetaAmpBreaux(session,params);
    plotBetaDropBreaux(session,params);
% 
    params.betaPeakF = cfHigh;% cfLow;%
    saveBetaAmpAndPhaseBreaux(session,params)
    savePSDnormedBetaAmpBreaux(session,params);
    plotBetaDropBreaux(session,params);
    
%     params.array = 'M1l';
% % %     
%     params.betaPeakF = cfLow; plotBetaDropBreaux(session,params);
%     params.betaPeakF = cfHigh; plotBetaDropBreaux(session,params);


%% phase wave
params.array = 'M1m'; params.betaPeakF = cfHigh; 
calcSavePhaseWaveBreaux(session,params)

    %% BAO FOR ALL DIRECTIONS   
    doBoot = false; 
% % %     

%     params.alignEvent = 5; params.alignment = 'MOVE';
%     params.msBefore = -400; params.msAfter = 100; %LESTER: -1000 to 900    
% %     params.betaPeakF = cfLow;%
% %     params.array = 'M1m'; calcPlotBreauxBAO8trgts(session,params,doBoot);
% %     params.array = 'M1l'; calcPlotBreauxBAO8trgts(session,params,doBoot);
% %     params.array = 'PMm'; calcPlotBreauxBAO8trgts(session,params,doBoot);
% %     params.array = 'PMl'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.betaPeakF = cfHigh;%
%     params.array = 'M1m'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.array = 'M1l'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.array = 'PMm'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.array = 'PMl'; calcPlotBreauxBAO8trgts(session,params,doBoot);
       
%     params.alignEvent = 3; params.alignment = 'GO';
%     params.msBefore = -100; params.msAfter = 800; %LESTER: -1000 to 900
%     params.betaPeakF = cfLow;% 19;% 
%     params.array = 'M1m'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.array = 'M1l'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.betaPeakF = cfHigh;% 19;% 
%     params.array = 'M1m'; calcPlotBreauxBAO8trgts(session,params,doBoot);
%     params.array = 'M1l'; calcPlotBreauxBAO8trgts(session,params,doBoot);

    %% reaction time effect on BAO (promising analysis)
%     params.alignEvent = 5; params.alignment = 'MOVE';
%     params.msBefore = -400; params.msAfter = 100; %LESTER: -1000 to 900    
%     params.array = 'M1m'; 
%     params.betaPeakF = cfLow;% 19;% 
%     reactionTimeEffect(session,params);
%     params.betaPeakF = cfHigh;% 19;% 
%     reactionTimeEffect(session,params);
% %              
%     params.alignEvent = 3; params.alignment = 'GO';
%     params.msBefore = -100; params.msAfter = 500; %-100 to 800; LESTER: -1000 to 900
%     params.array = 'M1m';
%     params.betaPeakF = cfLow;% 19;% 
%     reactionTimeEffect(session,params);
%     params.betaPeakF = cfHigh;% 19;% 
%     reactionTimeEffect(session,params);
    
    %% run separately for each TP to see envelopes and detailed maps
%     for iTP = 9% [2 6 9]%  
%         params.theTP = iTP; calcPlotBreauxBAO1target(session,params);
%     end

%     params.betaPeakF =  21; 
%     for iTP =  9% [2 6 9]%  
%         params.theTP = iTP; calcPlotBreauxBAO1target(session,params);
%     end

%     params.betaPeakF =  25;
%     for iTP = 9%[2 4 6 8 9]% 
%         params.theTP = iTP; calcPlotBreauxBAO1target(session,params);
%     end

   
%% EMG
%         params.correctVideo = true; params.notchEMG = true;
% %     params.discardEMGtrials = true; 
% %     params.keepIsLooking = true; 
% 
%         doTPs = [1 3 5 7]; [2 4 6 8];
% %         cutBreauxEMG1805(session,params);
% %  
% %         findEMGactivationInObservationTrials(session,params);
% %  
%         params.alignEvent = 5; params.alignment = 'MOVE'; 
%         plotEMGoneplotBreaux1801(session,params,doTPs);
% % % 
%         params.alignEvent = 3; params.alignment = 'GO';
%         plotEMGoneplotBreaux1801(session,params,doTPs);
%         
%         for iTP = [2 6] %[2 4 6 8]%[1 3 5 7]%
%             params.theTP = iTP;
%             plotStimEMGBreaux1802(session,params);
%         end

        %dimReductEMGBreaux1808(session,params)           
        
end


%% outdated functions
% params.array = 'M1'; params.theTP = 2; calcAndPlotSpectrogramBreuax1801(session,params); close all; 
% params.betaPeakF = cfHigh; plotBetaDropBreauxStimPattern(session,params);      
% params.betaPeakF = cfHigh; plotBetaDropBreauxTOPO(session,params);
% EMGylims = getEMGylimsBreaux(session,params); %needs update but also useless? 
% saveDataForWeiGPFA(session,params); %emg