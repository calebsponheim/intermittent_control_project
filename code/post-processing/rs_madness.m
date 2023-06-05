%% testing

acc_fold_1 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPacc_trajectory_speeds_fold_1');
acc_fold_2 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPacc_trajectory_speeds_fold_2');
acc_fold_3 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPacc_trajectory_speeds_fold_3');
acc_fold_4 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPacc_trajectory_speeds_fold_4');
acc_fold_5 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPacc_trajectory_speeds_fold_5');

dec_fold_1 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPdec_trajectory_speeds_fold_1');
dec_fold_2 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPdec_trajectory_speeds_fold_2');
dec_fold_3 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPdec_trajectory_speeds_fold_3');
dec_fold_4 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPdec_trajectory_speeds_fold_4');
dec_fold_5 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPdec_trajectory_speeds_fold_5');


figure('color','w','visible','on','Position',[100 100 200 500]); hold on
x1 = [acc_fold_1,acc_fold_2,acc_fold_3,acc_fold_4,acc_fold_5];
x2 = [dec_fold_1,dec_fold_2,dec_fold_3,dec_fold_4,dec_fold_5];

x = [x1, x2];

g1 = repmat({'Acc'},length(x1),1);
g2 = repmat({'Dec'},length(x2),1);
g = [g1; g2];

boxplot(x,g)
plot(1,mean(x1),'o','Color','Blue','MarkerSize',10,'MarkerFaceColor','Blue')
plot(2,mean(x2),'o','Color','Red','MarkerSize',10,'MarkerFaceColor','Red')
title('RS')

[p_trajectory_speed,~,~] = ranksum(x1,x2);
disp(strcat('Trajectory Speed P-Value: ',num2str(p_trajectory_speed)))
annotation('textbox',[.2 .5 .3 .3],'String',strcat('P-Value: ',num2str(p_trajectory_speed)),'FitBoxToText','on');

%% angles

angles_not_in_trials_fold_1 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPall_angles_fold_1');
angles_not_in_trials_fold_2 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPall_angles_fold_2');
angles_not_in_trials_fold_3 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPall_angles_fold_3');
angles_not_in_trials_fold_4 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPall_angles_fold_4');
angles_not_in_trials_fold_5 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPall_angles_fold_5');

angles_in_trials_fold_1 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPangles_in_trials_fold_1');
angles_in_trials_fold_2 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPangles_in_trials_fold_2');
angles_in_trials_fold_3 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPangles_in_trials_fold_3');
angles_in_trials_fold_4 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPangles_in_trials_fold_4');
angles_in_trials_fold_5 = readmatrix('C:\Users\Caleb (Work)\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPangles_in_trials_fold_5');

figure('color','w','visible','on','Position',[100 100 200 500]); hold on
x1 = [angles_not_in_trials_fold_1;angles_not_in_trials_fold_2;angles_not_in_trials_fold_3;angles_not_in_trials_fold_4;angles_not_in_trials_fold_5];
x2 = [angles_in_trials_fold_1;angles_in_trials_fold_2;angles_in_trials_fold_3;angles_in_trials_fold_4;angles_in_trials_fold_5];

x = [x1', x2'];

g1 = repmat({'Not in Data'},length(x1),1);
g2 = repmat({'in Data'},length(x2),1);
g = [g1; g2];

boxplot(x,g)
plot(1,mean(x1),'o','Color','k','MarkerSize',10,'MarkerFaceColor','k')
plot(2,mean(x2),'o','Color','k','MarkerSize',10,'MarkerFaceColor','k')
title('RS')

[p_trajectory_speed,~,~] = ranksum(x1,x2);
disp(strcat('Angle P-Value: ',num2str(p_trajectory_speed)))
annotation('textbox',[.2 .5 .3 .3],'String',strcat('P-Value: ',num2str(p_trajectory_speed)),'FitBoxToText','on');
