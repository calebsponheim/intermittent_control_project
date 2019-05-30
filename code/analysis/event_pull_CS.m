function [trialwise_kinematics] = event_pull_CS(session)
% Reading event data from Cerebus

%session = '190228a';
params = init_paramsBreaux_CS(session(1:6));

trial_start_event_channel = 1;
reward_event_channel = 2;

filenameNS5 = ['Bx' session 'M1'];

filestring = [params.dataDirServer filenameNS5 '.ns5'];


convconst = 1/6562; %openNSx raw, not 'uV'

%% 
flagData = openNSx(filestring, 'read'); %'p:double'

fData = flagData.Data;

if iscell(fData) && session == "190225d"
    fData = [fData{1} fData{2}];
end

trial_start_event_Epoch = fData(trial_start_event_channel,:).*convconst;
reward_event_Epoch = fData(reward_event_channel,:).*convconst;

trial_start_event_Epoch = trial_start_event_Epoch>1.5;
reward_event_Epoch = reward_event_Epoch>1.5;

trialStart = strfind(trial_start_event_Epoch, [0 1]); 
rewardStart = strfind(reward_event_Epoch, [0 1]);

nTrialsNS5 = numel(trialStart); validTrialsNS5 = true(nTrialsNS5,1);

% Take ns5 event times and divide by 15 to get 2k times

trialStart_2k = trialStart/15;
rewardStart_2k = rewardStart/15;

% import ns3 data (x, y, xvelocity, yvelocity)

filestring = [params.dataDirServer filenameNS5 '.ns3'];
x_y_Data = openNSx(filestring, 'read'); %'p:double'

x = double(x_y_Data.Data(131,:))*convconst;
y = double(x_y_Data.Data(132,:))*convconst;
x_velocity = double(x_y_Data.Data(133,:))*convconst;
y_velocity = double(x_y_Data.Data(134,:))*convconst;

%% Split kinematics into trials
% 
for iTrial = 1:size(rewardStart_2k,2)
    trialwise_kinematics(iTrial).session = session;
    trial_start_times_temp = trialStart_2k(trialStart_2k<rewardStart_2k(iTrial));
    trialwise_kinematics(iTrial).trial_start = trial_start_times_temp(end);
    trialwise_kinematics(iTrial).trial_end = rewardStart_2k(iTrial);    
    trialwise_kinematics(iTrial).trial_num = find(trialStart_2k == trialwise_kinematics(iTrial).trial_start);
    trialwise_kinematics(iTrial).x = x(round(trialStart_2k(iTrial)):round(rewardStart_2k(iTrial)));
    trialwise_kinematics(iTrial).y = y(round(trialStart_2k(iTrial)):round(rewardStart_2k(iTrial)));
    trialwise_kinematics(iTrial).x_vel = x_velocity(round(trialStart_2k(iTrial)):round(rewardStart_2k(iTrial)));
    trialwise_kinematics(iTrial).y_vel = y_velocity(round(trialStart_2k(iTrial)):round(rewardStart_2k(iTrial)));
end
%%

% xGain = 0.2; xOffset = -4;
% yGain = 0.2; yOffset = -2;
% % xGain = 1; xOffset = 0;
% % yGain = 1; yOffset = 0;
% 
% figure;hold on
% plot(trialwise_kinematics(1).x,trialwise_kinematics(1).y)
% plot(bkindata(1).Right_HandX,bkindata(1).Right_HandY,'r')
% plot((bkindata(1).TARGET_TABLE.X_GLOBAL.*xGain)+xOffset,(bkindata(1).TARGET_TABLE.Y_GLOBAL.*yGain)+yOffset,'ro')
% hold off
% 
% %% Getting correct target locations
% centerTarget(1) = xGain.*targets(1,1)+xOffset;
% centerTarget(2) = yGain.*targets(1,2)+yOffset;

