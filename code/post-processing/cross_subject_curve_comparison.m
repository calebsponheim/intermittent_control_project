%plotting curvature of different subjects' snippets across states
if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
     file_base_base = 'Caleb (Work)';
end

bx_curves = readmatrix(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\BxRTPcurve_data.csv'));
rs_curves = readmatrix(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPcurve_data.csv'));
rj_curves = readmatrix(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\RJRTPcurve_data.csv'));


bx_data = load(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\BxRTP0.05sBins\BxRTP190228CT0.mat'));
rs_data = load(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\RSRTP0.05sBins\RS_RTP.mat'));
rj_data = load(strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\RJRTP0.05sBins_1031126\RJRTP.mat'));

%%
rs_x_position = vertcat(rs_data.data.x_smoothed);
rj_x_position = vertcat(rj_data.data.x_smoothed);
bx_x_position = [bx_data.data.x_smoothed]';

rs_y_position = vertcat(rs_data.data.y_smoothed);
rj_y_position = vertcat(rj_data.data.y_smoothed);
bx_y_position = [bx_data.data.y_smoothed]';

rs_speed = vertcat(rs_data.data.speed);
rj_speed = vertcat(rj_data.data.speed);
bx_speed = [bx_data.data.speed]';

rs_acceleration = vertcat(rs_data.data.acceleration);
rj_acceleration = vertcat(rj_data.data.acceleration);
bx_acceleration = [bx_data.data.acceleration]';

%% plotting position differences

figure; hold on; 
plot(rs_speed,'DisplayName','RS'); 
plot(rj_speed,'DisplayName','RJ'); 
plot(bx_speed,'DisplayName','BX');
legend()

%% finding curve values at trial transitions and eliminating them
bx_curves_trial_transition_removed = bx_curves;
bx_speed_trial_transition_removed = bx_speed;
bx_acceleration_trial_transition_removed = bx_acceleration;

transition_timepoints = [];
for iTrial = 1:size(bx_data.data,2)
    if iTrial == 1
        transition_timepoints(iTrial) = length(bx_data.data(iTrial).x_smoothed);
    else
        transition_timepoints(iTrial) = transition_timepoints(iTrial-1) + length(bx_data.data(iTrial).x_smoothed);
    end
    bx_curves_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    bx_speed_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    bx_acceleration_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
end

rs_curves_trial_transition_removed = rs_curves;
rs_speed_trial_transition_removed = rs_speed;
rs_acceleration_trial_transition_removed = rs_acceleration;
transition_timepoints = [];

for iTrial = 1:size(rs_data.data,2)
    if iTrial == 1
        transition_timepoints(iTrial) = length(rs_data.data(iTrial).x_smoothed);
    else
        transition_timepoints(iTrial) = transition_timepoints(iTrial-1) + length(rs_data.data(iTrial).x_smoothed);
    end
    rs_curves_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    rs_speed_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    rs_acceleration_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
end

rj_curves_trial_transition_removed = rj_curves;
rj_speed_trial_transition_removed = rj_speed;
rj_acceleration_trial_transition_removed = rj_acceleration;
transition_timepoints = [];

for iTrial = 1:size(rj_data.data,2)
    if iTrial == 1
        transition_timepoints(iTrial) = length(rj_data.data(iTrial).x_smoothed);
    else
        transition_timepoints(iTrial) = transition_timepoints(iTrial-1) + length(rj_data.data(iTrial).x_smoothed);
    end
    rj_curves_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    rj_speed_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
    rj_acceleration_trial_transition_removed((transition_timepoints(iTrial)-10) : (transition_timepoints(iTrial)+10)) = nan;
end


% figure; hold on; plot(bx_speed_trial_transition_removed(10000:20000)*2000); plot(bx_curves_trial_transition_removed(10000:20000));

%%

bx_curves_during_movement = bx_curves_trial_transition_removed(bx_speed_trial_transition_removed>.0005);
rj_curves_during_movement = rj_curves_trial_transition_removed(rj_speed_trial_transition_removed>.01);
rs_curves_during_movement = rs_curves_trial_transition_removed(rs_speed_trial_transition_removed>.01);

bx_speed_during_movement = bx_speed_trial_transition_removed(bx_speed_trial_transition_removed>.0005);
rj_speed_during_movement = rj_speed_trial_transition_removed(rj_speed_trial_transition_removed>.01);
rs_speed_during_movement = rs_speed_trial_transition_removed(rs_speed_trial_transition_removed>.01);

bx_acceleration_during_movement = bx_acceleration_trial_transition_removed(bx_speed_trial_transition_removed>.0005);
rj_acceleration_during_movement = rj_acceleration_trial_transition_removed(rj_speed_trial_transition_removed>.01);
rs_acceleration_during_movement = rs_acceleration_trial_transition_removed(rs_speed_trial_transition_removed>.01);

%%
rs_acceleration_maxima = findpeaks(rs_speed_during_movement);
rj_acceleration_maxima = findpeaks(rj_speed_during_movement);
bx_acceleration_maxima = findpeaks(bx_speed_during_movement);
rs_acceleration_minima = findpeaks(-rs_speed_during_movement);
rj_acceleration_minima = findpeaks(-rj_speed_during_movement);
bx_acceleration_minima = findpeaks(-bx_speed_during_movement);

%% Plot Acceleration Maxima
x1 = bx_acceleration_maxima;
x2 = rj_acceleration_maxima;
x3 = rs_acceleration_maxima;
x = [x1; x2; x3];

g1 = repmat({'Bx'},length(x1),1);
g2 = repmat({'Rj'},length(x2),1);
g3 = repmat({'Rs'},length(x3),1);
g = [g1; g2; g3];

figure('visible','on'); hold on
boxplot(x,g,'Symbol','r_','OutlierSize',2)
ylim([min(x),max(x)])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('Acceleration Maxima'));
xlabel('Subject')
ylabel('Maxima Magnitude')
name = 'acceleration_maxima';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));

%% Plot Acceleration Minima
x1 = -bx_acceleration_minima;
x2 = -rj_acceleration_minima;
x3 = -rs_acceleration_minima;
x = [x1; x2; x3];

g1 = repmat({'Bx'},length(x1),1);
g2 = repmat({'Rj'},length(x2),1);
g3 = repmat({'Rs'},length(x3),1);
g = [g1; g2; g3];

figure('visible','on'); hold on
boxplot(x,g,'Symbol','r_','OutlierSize',2)
ylim([min(x),max(x)])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('Acceleration Minima'));
xlabel('Subject')
ylabel('Minima Magnitude')
name = 'acceleration_minima';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));

%% Plot acceleration_during_movement
x1 = bx_acceleration_during_movement;
x2 = rj_acceleration_during_movement;
x3 = rs_acceleration_during_movement;
x = [x1; x2; x3];

g1 = repmat({'Bx'},length(x1),1);
g2 = repmat({'Rj'},length(x2),1);
g3 = repmat({'Rs'},length(x3),1);
g = [g1; g2; g3];

figure('visible','on'); hold on
boxplot(x,g,'Symbol','r_','OutlierSize',2)
ylim([min(x),max(x)])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('Acceleration'));
xlabel('Subject')
ylabel('Acceleration Magnitude')
name = 'acceleration';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));

%% Plot speed_during_movement
x1 = bx_speed_during_movement;
x2 = rj_speed_during_movement;
x3 = rs_speed_during_movement;
x = [x1; x2; x3];

g1 = repmat({'Bx'},length(x1),1);
g2 = repmat({'Rj'},length(x2),1);
g3 = repmat({'Rs'},length(x3),1);
g = [g1; g2; g3];

figure('visible','on'); hold on
boxplot(x,g,'Symbol','r_','OutlierSize',2)
ylim([min(x),max(x)])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('Speed'));
xlabel('Subject')
ylabel('Speed Magnitude')
name = 'speed';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));
%% Plot curve_during_movement
x1 = bx_curves_during_movement;
x2 = rj_curves_during_movement;
x3 = rs_curves_during_movement;
x = [x1; x2; x3];

g1 = repmat({'Bx'},length(x1),1);
g2 = repmat({'Rj'},length(x2),1);
g3 = repmat({'Rs'},length(x3),1);
g = [g1; g2; g3];

figure('visible','on'); hold on
boxplot(x,g,'Symbol','r_','OutlierSize',2)
ylim([min(x),1])
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('Radius of Curvature'));
xlabel('Subject')
ylabel('Radius of Curvature')
name = 'curvature';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));

%%
edges = 0 : .0001 : .1;

[N_rs_curves, ~] = histcounts(rs_curves_during_movement,edges);
[N_rj_curves, ~] = histcounts(rj_curves_during_movement,edges);
[N_bx_curves, ~] = histcounts(bx_curves_during_movement,edges);
N_rs_curves = N_rs_curves/numel(rs_curves_during_movement);
N_rj_curves = N_rj_curves/numel(rj_curves_during_movement);
N_bx_curves = N_bx_curves/numel(bx_curves_during_movement);


figure; hold on; 

% subplot(3,1,1);
% bar(edges(1:end-1),N_bx_curves,'DisplayName','BX','EdgeColor','none','FaceAlpha',.5); 
% legend()
% ylim([0 1])

subplot(2,1,1);
bar(edges(1:end-1),N_rs_curves,'DisplayName','RS','EdgeColor','none','FaceAlpha',.5); 
% ylim([0 1])
legend()

subplot(2,1,2);
bar(edges(1:end-1),N_rj_curves,'DisplayName','RJ','EdgeColor','none','FaceAlpha',.5); 
% ylim([0 1])
title('Curve Radius across all kinematics')
legend()
ylabel('Percent of total')
xlabel('Radius of Curvature')
name = 'curvature';
saveas(gcf,strcat('C:\Users\',file_base_base,'\Documents\git\intermittent_control_project\figures\cross_subject_kinematic_analysis\',name,'.png'));

%%
[p_curve,uhhhh,uh] = ranksum(rs_curves_during_movement,rj_curves_during_movement);
disp(strcat('RS vs RJ Curve P-Value: ',num2str(p_curve)))

%%

% 
% close gcf