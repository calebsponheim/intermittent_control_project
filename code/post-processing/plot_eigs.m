function plot_eigs(meta,colors,snippet_direction_out,snippet_length_per_state)
%%


dimension_cutoffs = readmatrix(strcat(meta.filepath,'dims_to_include.csv'));
trajectory_speed = readmatrix(strcat(meta.filepath,'avg_state_trajectory_speed.csv'));
real_eigenvalues = readmatrix(strcat(meta.filepath,'real_eigenvalues.csv'));
real_eigenvalues = real_eigenvalues(2:end,:);
imaginary_eigenvalues = readmatrix(strcat(meta.filepath,'imaginary_eigenvalues.csv'));
imaginary_eigenvalues = imaginary_eigenvalues(2:end,:);

%% Scatter
figure('color','w','visible','on');
hold on;
box off;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
acc_eig_count = 1;
dec_eig_count = 1;
acc_eigs_real = [];
acc_eigs_imag = [];
dec_eigs_real = [];
dec_eigs_imag = [];
for iState = 1:numel(meta.acc_classification)
    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    imaginary_eigenvalues_temp = imaginary_eigenvalues(iState,dims_to_include_temp);
    trajectory_speeds_temp = trajectory_speed(iState,dims_to_include_temp);
    if meta.acc_classification(iState) == 1
        plot(real_eigenvalues_temp,imaginary_eigenvalues_temp,'.','color',colors(iState,:),'MarkerSize',30);
        acc_eigs_real{acc_eig_count} = real_eigenvalues_temp;
        acc_eigs_imag{acc_eig_count} = abs(imaginary_eigenvalues_temp);
        acc_trajectory_speeds{acc_eig_count} = trajectory_speeds_temp;
        acc_eig_count = acc_eig_count + 1;
    elseif meta.acc_classification(iState) == 0
        plot(real_eigenvalues_temp,imaginary_eigenvalues_temp,'.','color',colors(iState,:),'MarkerSize',30);
        dec_eigs_real{dec_eig_count} = real_eigenvalues_temp;
        dec_eigs_imag{dec_eig_count} = abs(imaginary_eigenvalues_temp);
        dec_trajectory_speeds{dec_eig_count} = trajectory_speeds_temp;
        dec_eig_count = dec_eig_count + 1;
    elseif meta.acc_classification(iState) == 2
        plot(real_eigenvalues_temp,imaginary_eigenvalues_temp,'.','color',colors(iState,:),'MarkerSize',30);
    end
end
xlabel('Real Component')
ylabel('Imaginary Component')
title('Eigenvalue Magnitudes (Color = State)')
ylim([0 max(imaginary_eigenvalues_temp)])

hold off
saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs.png'));
close gcf
%% Trajectory Speed Analysis

if ~isempty(acc_eigs_real) &&  ~isempty(dec_eigs_real)
    figure('color','w','visible','on','Position',[100 100 200 500]); hold on
    acc_mean = mean([acc_trajectory_speeds{:}]);
    acc_std_err = std([acc_trajectory_speeds{:}])/sqrt(length([acc_trajectory_speeds{:}]));
    errorbar(1,acc_mean,acc_std_err,acc_std_err,0,0,'o','Color','Blue','MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    dec_mean = mean([dec_trajectory_speeds{:}]);
    dec_std_err = std([dec_trajectory_speeds{:}])/sqrt(length([dec_trajectory_speeds{:}]));
    errorbar(2,dec_mean,dec_std_err,dec_std_err,0,0,'o','Color','Red','MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    xlim([0 3])
    box off;
    xticks([0 1 2 3])
    xticklabels({' ','Acc','Dec',' '})
    ylabel('Mean Neural Latent Trajectory Speed')
    hold off
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trajectory_speed_dec_vs_acc.png'));
    close gcf


% some more misc analysis on trajectory speed:

    figure('color','w','visible','on','Position',[100 100 200 500]); hold on
    x1 = [acc_trajectory_speeds{:}];
    x2 = [dec_trajectory_speeds{:}];

    x = [x1, x2];

    g1 = repmat({'Acc'},length(x1),1);
    g2 = repmat({'Dec'},length(x2),1);
    g = [g1; g2];
    
    boxplot(x,g)
    errorbar(1,acc_mean,acc_std_err,acc_std_err,0,0,'o','Color','Blue','MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    errorbar(2,dec_mean,dec_std_err,dec_std_err,0,0,'o','Color','Red','MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    
    title(meta.subject)

    [p_trajectory_speed,~,~] = ranksum(x1,x2);
    disp(strcat('Trajectory Speed P-Value: ',num2str(p_trajectory_speed)))
    annotation('textbox',[.2 .5 .3 .3],'String',strcat('P-Value: ',num2str(p_trajectory_speed)),'FitBoxToText','on');
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trajectory_speed_dec_vs_acc_box.png'));
    close gcf

% save out data for fold comparison

%     writematrix(x1,strcat(file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\',meta.subject,meta.task,'acc_trajectory_speeds.csv'))
%     writematrix(x2,strcat(file_base_base,'\Documents\git\intermittent_control_project\data\python_switching_models\',meta.subject,meta.task,'dec_trajectory_speeds.csv'))
% 

% some more misc analysis on trajectory speed:
    figure('color','w','visible','on','Position',[100 100 500 200]); hold on
    edges = .2 : .05 : 1;
    [acc_speed, ~] = histcounts(x1,edges);
    [dec_speed, ~] = histcounts(x2,edges);
    bar(edges(1:end-1),acc_speed,'DisplayName','Acc','EdgeColor','none','FaceAlpha',.5); 
    bar(edges(1:end-1),dec_speed,'DisplayName','Dec','EdgeColor','none','FaceAlpha',.5); 
    title('Trajectory Speed')
    legend()
    ylabel('Count')
    xlabel('Trajectory Speed')
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'_trajectory_speed_dec_vs_acc_histogram.png'));
    close gcf

end

%% Error Bar Plot
if ~isempty(acc_eigs_real) &&  ~isempty(dec_eigs_real) 
    reshaped_real = reshape([acc_eigs_real{:}],[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    reshaped_imag = reshape([acc_eigs_imag{:}],[],1);
    imag_mean = mean(reshaped_imag);
    imag_std_err = std(reshaped_imag)/sqrt(length(reshaped_imag));
    
    reshaped_dec_real = reshape([dec_eigs_real{:}],[],1);
    dec_real_mean = mean(reshaped_dec_real);
    dec_real_std_err = std(reshaped_dec_real)/sqrt(length(reshaped_dec_real));
    reshaped_dec_imag = reshape([dec_eigs_imag{:}],[],1);
    dec_imag_mean = mean(reshaped_dec_imag);
    dec_imag_std_err = std(reshaped_dec_imag)/sqrt(length(reshaped_dec_imag));
    
    x = [real_mean dec_real_mean];
    y = [imag_mean dec_imag_mean];
    yneg = [imag_std_err dec_imag_std_err];
    ypos = yneg;
    xneg = [real_std_err dec_real_std_err];
    xpos = xneg;
    [p_real,~,~] = ranksum(reshaped_real,reshaped_dec_real);
    [p_imag,~,~] = ranksum(reshaped_imag,reshaped_dec_imag);
    
    disp(strcat('Real Eigenvalue P-Value: ',num2str(p_real)))
    disp(strcat('Imaginary Eigenvalue P-Value: ',num2str(p_imag)))
   
    figure('color','w','visible','on');
    hold on;
    box off;
    
    errorbar(x(1),y(1),yneg(1),ypos(1),xneg(1),xpos(1),'o','Color','Blue','MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    errorbar(x(2),y(2),yneg(2),ypos(2),xneg(2),xpos(2),'o','Color','Red','MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    
    xlabel('Real Component')
    ylabel('Imaginary Component (Absolute Value)')
    title('Accelerative (Blue) vs Decelerative (Red) Discrete States')
    
    hold off
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs_dec_vs_acc.png'));
    close gcf
end
%% Error Bar Plot By Direction

%turning snippet direction into color
% colors_by_degree = hsv(360);
% direction_in_degrees = rad2deg(snippet_direction_out)+180;
% colors = colors_by_degree(round(direction_in_degrees),:);

% Actually plotting

figure('visible','off','Color','w'); hold on; box off

for iState = 1:length(snippet_direction_out)
    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    imaginary_eigenvalues_temp = imaginary_eigenvalues(iState,dims_to_include_temp);

    real_eigs_to_plot = real_eigenvalues_temp;
    imaginary_eigs_to_plot = abs(imaginary_eigenvalues_temp);
    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    reshaped_imag = reshape(imaginary_eigs_to_plot,[],1);
    imag_mean = mean(reshaped_imag);
    imag_std_err = std(reshaped_imag)/sqrt(length(reshaped_imag));

    x = real_mean;
    y = imag_mean;
    yneg = imag_std_err;
    ypos = yneg;
    xneg = real_std_err;
    xpos = xneg;

    if meta.acc_classification(iState) == 1
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    elseif meta.acc_classification(iState) == 0
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    elseif meta.acc_classification(iState) == 2
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Black','LineWidth',2)
    end


end

xlabel('Real Component')
ylabel('Imaginary Component (Absolute Value)')
title('Color = Discrete State')
    
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real+imag_eigs_by_dir.png'));
close gcf

%% By Direction - Real Eigenvalues
hold off
for iState = 1:length(snippet_direction_out)
    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    real_eigs_to_plot = real_eigenvalues_temp;    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);

    Angle = snippet_direction_out(iState)';
    Radius = real_mean;
    tbl = table(Angle,Radius);
    if meta.acc_classification(iState) == 1
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Blue','Marker','o','MarkerSize',20);
    elseif meta.acc_classification(iState) == 0
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Red','Marker','o','MarkerSize',20);
    elseif meta.acc_classification(iState) == 2
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Black','Marker','o','MarkerSize',20);
    end
    hold on
end

hold off
set(gca,'GridLineStyle',':','GridColor','k')
set(gcf,'Color','White','Position',[300,300,600,600])
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real_eigs_by_movement_direction.png'));
close gcf

%% By Direction - Imaginary Eigenvalues
hold off
for iState = 1:length(snippet_direction_out)
    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    imaginary_eigenvalues_temp = imaginary_eigenvalues(iState,dims_to_include_temp);
    imaginary_eigs_to_plot = abs(imaginary_eigenvalues_temp);    
    reshaped_imaginary = reshape(imaginary_eigs_to_plot,[],1);
    imaginary_mean = mean(reshaped_imaginary);

    Angle = snippet_direction_out(iState)';
    Radius = imaginary_mean;
    tbl = table(Angle,Radius);
    if meta.acc_classification(iState) == 1
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Blue','Marker','o','MarkerSize',20);
    elseif meta.acc_classification(iState) == 0
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Red','Marker','o','MarkerSize',20);
    elseif meta.acc_classification(iState) == 2
        polarplot(tbl,"Angle","Radius",'LineStyle','none','LineWidth',6,'color',colors(iState,:),'MarkerFaceColor','Black','Marker','o','MarkerSize',20);
    end
    hold on
end

hold off
set(gca,'GridLineStyle',':','GridColor','k')
set(gcf,'Color','White','Position',[300,300,600,600])
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_imaginary_eigs_by_movement_direction.png'));
close gcf

%% By Snippet Length

%snippet_length_per_state

figure('visible','on','Color','w'); hold on; box off
eig_mean = [];
snippet_mean = [];
for iState = 1:length(snippet_direction_out)

    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    real_eigs_to_plot = real_eigenvalues_temp;    

    snippet_length_to_plot = snippet_length_per_state{iState};
    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    snippet_length_mean = mean(snippet_length_to_plot);
    snippet_length_std_err = std(snippet_length_mean)/sqrt(length(snippet_length_mean));
    eig_mean = vertcat(eig_mean,real_mean);
    snippet_mean = vertcat(snippet_mean, repmat(snippet_length_mean,length(real_mean),1));
    y = real_mean;
    x = snippet_length_mean;
    xneg = snippet_length_std_err;
    xpos = xneg;
    yneg = real_std_err;
    ypos = yneg;

    if meta.acc_classification(iState) == 1
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    elseif meta.acc_classification(iState) == 0
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    elseif meta.acc_classification(iState) == 2
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Black','LineWidth',2)
    end


end

title('Line Color = State')
 
[R,P] = corrcoef(eig_mean,snippet_mean);
[f,g] = fit(snippet_mean(~isnan(snippet_mean)),eig_mean(~isnan(snippet_mean)),'power2');
disp(strcat('Snippet Length R^2: ',num2str(g.rsquare)))
% disp(strcat('Snippet Length P-Value: ',num2str(P(2))))
plot(f)
legend off
xlabel('Mean Snippet Length')
ylabel('Real Eigenvalue Magnitude')
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real_eigs_by_snippet_length.png'));
close gcf

%% By Avg Speed

%snippet_length_per_state

figure('visible','on','Color','w'); hold on; box off
eig_mean = [];
snippet_mean = [];

for iState = 1:length(snippet_direction_out)

    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    real_eigs_to_plot = real_eigenvalues_temp;    

    mean_speed_to_plot = meta.mean_speed{iState};
    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    mean_speed_mean= mean(mean_speed_to_plot);
    mean_speed_std_err = std(mean_speed_mean)/sqrt(length(snippet_length_mean));
    eig_mean = vertcat(eig_mean,reshaped_real);
    snippet_mean = vertcat(snippet_mean, repmat(mean_speed_mean,length(reshaped_real),1));

    y = real_mean;
    x = mean_speed_mean;
    xneg = mean_speed_std_err;
    xpos = xneg;
    yneg = real_std_err;
    ypos = yneg;

    if meta.acc_classification(iState) == 1
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    elseif meta.acc_classification(iState) == 0
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    elseif meta.acc_classification(iState) == 2
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Black','LineWidth',2)
    end


end

[R,P] = corrcoef(eig_mean,snippet_mean);
disp(strcat('Mean Speed Correlation: ',num2str(R(2))))
disp(strcat('Mean Speed P-Value: ',num2str(P(2))))

xlabel('Mean Snippet Speed')
ylabel('Real Eigenvalue Magnitude')
title('Line Color = State')
    
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real_eigs_by_snippet_mean_speed.png'));
close gcf
%% By Peak Speed

%snippet_length_per_state

figure('visible','on','Color','w'); hold on; box off
eig_mean = [];
snippet_mean = [];

for iState = 1:length(snippet_direction_out)

    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    real_eigs_to_plot = real_eigenvalues_temp;    

    peak_speed_to_plot = meta.peak_speed{iState};
    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    peak_speed_mean= mean(peak_speed_to_plot);
    peak_speed_std_err = std(peak_speed_mean)/sqrt(length(snippet_length_mean));
    eig_mean = vertcat(eig_mean,reshaped_real);
    snippet_mean = vertcat(snippet_mean, repmat(peak_speed_mean,length(reshaped_real),1));

    y = real_mean;
    x = peak_speed_mean;
    xneg = peak_speed_std_err;
    xpos = xneg;
    yneg = real_std_err;
    ypos = yneg;

    if meta.acc_classification(iState) == 1
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    elseif meta.acc_classification(iState) == 0
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    elseif meta.acc_classification(iState) == 2
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Black','LineWidth',2)
    end


end
[R,P] = corrcoef(eig_mean,snippet_mean);
disp(strcat('Peak Speed Correlation: ',num2str(R(2))))
disp(strcat('Peak Speed P-Value: ',num2str(P(2))))

xlabel('Peak Snippet Speed')
ylabel('Real Eigenvalue Magnitude')
title('Line Color = State')
    
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real_eigs_by_snippet_peak_speed.png'));
close gcf
%% By Median Curvature

%snippet_length_per_state

figure('visible','on','Color','w'); hold on; box off
eig_mean = [];
snippet_mean = [];

for iState = 1:length(snippet_direction_out)

    dims_to_include_temp = dimension_cutoffs(iState,~isnan(dimension_cutoffs(iState,:)));
    real_eigenvalues_temp = real_eigenvalues(iState,dims_to_include_temp);
    real_eigs_to_plot = real_eigenvalues_temp;    

    curvature_to_plot = meta.curvature_out{iState};
    
    reshaped_real = reshape(real_eigs_to_plot,[],1);
    real_mean = mean(reshaped_real);
    real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
    curvature_median= median(curvature_to_plot);
    peak_speed_std_err = std(curvature_median)/sqrt(length(curvature_median));
    eig_mean = vertcat(eig_mean,reshaped_real);
    snippet_mean = vertcat(snippet_mean, repmat(curvature_median,length(reshaped_real),1));

    y = real_mean;
    x = curvature_median;
    xneg = peak_speed_std_err;
    xpos = xneg;
    yneg = real_std_err;
    ypos = yneg;

    if meta.acc_classification(iState) == 1
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
    elseif meta.acc_classification(iState) == 0
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)
    elseif meta.acc_classification(iState) == 2
        errorbar(x,y,yneg,ypos,xneg,xpos,'o','Color',colors(iState,:),'MarkerSize',10,'MarkerFaceColor','Black','LineWidth',2)
    end


end
[R,P] = corrcoef(eig_mean,snippet_mean);
disp(strcat('Median Curvature Correlation: ',num2str(R(2))))
disp(strcat('Median Curvature P-Value: ',num2str(P(2))))

xlabel('Median Curvature')
ylabel('Real Eigenvalue Magnitude')
title('Line Color = State')
    
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_real_eigs_by_median_curvature.png'));
close gcf

%% Bar

acc_states_real = [];
acc_states_imag = [];
for iState = 1:size(meta.acc_classification,1)
    if meta.acc_classification(iState) == 1
        acc_states_real = [acc_states_real real_eigenvalues(iState,:)];
        acc_states_imag = [acc_states_imag imaginary_eigenvalues(iState,:)];
    elseif meta.acc_classification(iState) == 0
        dec_states_real = [acc_states_real real_eigenvalues(iState,:)];
        dec_states_imag = [acc_states_imag imaginary_eigenvalues(iState,:)];
    end
end
if ~isempty(acc_states_real) ||  ~isempty(dec_eigs_real) 
    bin_size = 0.25;
    edges = -2:bin_size:2;
    [acc_states_real_counts,acc_states_real_edges] = histcounts(reshape(acc_states_real,[1,size(acc_states_real,1)*size(acc_states_real,2)]),edges);
    [dec_states_real_counts,dec_states_real_edges] = histcounts(reshape(dec_states_real,[1,size(dec_states_real,1)*size(dec_states_real,2)]),edges);
    
    figure('color','w','visible','off');
    hold on;
    bar(acc_states_real_edges(2:end)-(bin_size/2),acc_states_real_counts,'facecolor',colors(1,:),'FaceAlpha',0.2)
    bar(dec_states_real_edges(2:end)-(bin_size/2),dec_states_real_counts,'facecolor',colors(2,:),'FaceAlpha',0.2)
    box off;
    text(1,50,{'Blue = Accelerative ','Red = Decelerative','Purple = Overlap'})
    title('Real Components of Eigenvalues')
    hold off;
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eig_dist_real.png'));
    close gcf
    
    [acc_states_imag_counts,acc_states_imag_edges] = histcounts(reshape(acc_states_imag,[1,size(acc_states_imag,1)*size(acc_states_imag,2)]),edges);
    [dec_states_imag_counts,dec_states_imag_edges] = histcounts(reshape(dec_states_imag,[1,size(dec_states_imag,1)*size(dec_states_imag,2)]),edges);
    
    figure('color','w','visible','off');
    hold on;
    bar(acc_states_imag_edges(2:end)-(bin_size/2),acc_states_imag_counts,'facecolor',colors(1,:),'FaceAlpha',0.2)
    bar(dec_states_imag_edges(2:end)-(bin_size/2),dec_states_imag_counts,'facecolor',colors(2,:),'FaceAlpha',0.2)
    box off;
    text(1,50,{'Blue = Accelerative ','Red = Decelerative','Purple = Overlap'})
    title('Imaginary Components of Eigenvalues')
    hold off
    saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eig_dist_imag.png'));
    close gcf
end



end
