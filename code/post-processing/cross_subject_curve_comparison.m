%plotting curvature of different subjects' snippets across states

bx_curves = readmatrix('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\BxRTPcurve_data.csv');
rs_curves = readmatrix('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\RSRTPcurve_data.csv');
rj_curves = readmatrix('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\RJRTPcurve_data.csv');

figure('visible','on'); hold on
[~, ~, ~, q_temp, ~] = al_goodplot(bx_curves,1,0.75, colors(1,:), 'right', 50,std(bx_curves)/10000,0);
q(1) = q_temp(end,1);
[~, ~, ~, q_temp, ~] = al_goodplot(rs_curves,2,0.75, colors(2,:), 'right', 50,std(rs_curves)/10000,0);
q(2) = q_temp(end,1);
[~, ~, ~, q_temp, ~] = al_goodplot(rj_curves,3,0.75, colors(3,:), 'right', 50,std(rj_curves)/10000,0);
q(3) = q_temp(end,1);

ylim([0 mean(q,'omitnan')])
xlim([1 5])
xticklabels({'Bx','RS','RJ'})
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('subject comparison for Radius of Curvature of all state snippets'));
xlabel('State Number')
ylabel('Radius Size')
saveas(gcf,strcat('C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\cross-subject_Curvature.png'));
close gcf