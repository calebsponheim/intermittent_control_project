% Cross-subject kinematic comparison
[~, colors] = colornames('xkcd', ...
    'black','grey','red','brown','purple','blue','hot pink','orange', ...
    'mustard','green','teal','light blue','olive green', ...
    'peach','periwinkle','magenta','salmon','lime green');
%% 
bx_data = load('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\BxRTP0.05sBins\BxRTP190228CT0.mat');
rs_data = load('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\RSRTP0.05sBins\RS_RTP.mat');
rj_data = load('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\RJRTP0.05sBins\RJRTP.mat');

%%
rs_speed = vertcat(rs_data.data.speed);
rj_speed = vertcat(rj_data.data.speed);
bx_speed = [bx_data.data.speed];


%% Video Time
xlims = [min([bx_data.data.x_smoothed]) max([bx_data.data.x_smoothed])];
ylims = [min([bx_data.data.y_smoothed]) max([bx_data.data.y_smoothed])];

v = VideoWriter('C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\Bx\RTP_CT0\kinematics.mp4','MPEG-4');
v.Quality = 100;
v.FrameRate = 30;
open(v)

for iTrial = 10
    for iFrame = 1:20:(size(bx_data.data(iTrial).x_smoothed,2)-50)
        figure('visible','off');hold on
        plot(bx_data.data(iTrial).x_smoothed(iFrame:iFrame+50),bx_data.data(iTrial).y_smoothed(iFrame:iFrame+50));
        xlim(xlims)
        ylim(ylims)
        frame = getframe(gcf);
        writeVideo(v,frame)
    end
    disp(strcat('trial',num2str(iTrial),' done'))
end
close(v)
%%

figure('visible','on'); hold on
[~, ~, ~, q_temp, ~] = al_goodplot(bx_speed(1:5:end),1,0.75, colors(1,:), 'right', .1,std(bx_speed(1:5:end))/1000,1);
q(1) = q_temp(7,1);
[~, ~, ~, q_temp, ~] = al_goodplot(rs_speed(1:5:end),2,0.75, colors(2,:), 'right', .1,std(rs_speed(1:5:end))/1000,1);
q(2) = q_temp(7,1);
[~, ~, ~, q_temp, ~] = al_goodplot(rj_speed(1:5:end),3,0.75, colors(3,:), 'right', .1,std(rj_speed(1:5:end))/1000,1);
q(3) = q_temp(7,1);

ylim([0 mean(q,'omitnan')])
xlim([1 5])
xticks([1,2,3])
xticklabels({'Bx','RS','RJ'})
hold off
box off
set(gcf,'color','w','Position',[100 100 600 800])
title(strcat('subject comparison for speed'));
xlabel('State Number')
ylabel('speed')

%%


saveas(gcf,strcat('C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\cross-subject_speed.png'));
close gcf