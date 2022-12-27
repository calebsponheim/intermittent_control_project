function plot_eigs(meta,colors,snippet_direction_out)
%%

dimension_cutoff_from_PCA_analysis = 10;

real_eigenvalues = readmatrix(strcat(meta.filepath,'real_eigenvalues.csv'));
real_eigenvalues = real_eigenvalues(2:end,:);
imaginary_eigenvalues = readmatrix(strcat(meta.filepath,'imaginary_eigenvalues.csv'));
imaginary_eigenvalues = imaginary_eigenvalues(2:end,:);

real_eigenvalues = real_eigenvalues(:,1:dimension_cutoff_from_PCA_analysis);
imaginary_eigenvalues = imaginary_eigenvalues(:,1:dimension_cutoff_from_PCA_analysis);

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
for iState = 1:size(real_eigenvalues,1)
    if meta.acc_classification(iState) == 1
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(1,:));
        acc_eigs_real(acc_eig_count,:) = real_eigenvalues(iState,:);
        acc_eigs_imag(acc_eig_count,:) = abs(imaginary_eigenvalues(iState,:));
        acc_eig_count = acc_eig_count + 1;
    elseif meta.acc_classification(iState) == 0
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(2,:));
        dec_eigs_real(dec_eig_count,:) = real_eigenvalues(iState,:);
        dec_eigs_imag(dec_eig_count,:) = abs(imaginary_eigenvalues(iState,:));
        dec_eig_count = dec_eig_count + 1;
    elseif meta.acc_classification(iState) == 2
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color','black');
    end
end
xlabel('Real Component')
ylabel('Imaginary Component')
title('Blue = Accelerative | Red = Decelerative')

hold off
saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs.png'));
close gcf

%% Error Bar Plot
reshaped_real = reshape(acc_eigs_real,[],1);
real_mean = mean(reshaped_real);
real_std_err = std(reshaped_real)/sqrt(length(reshaped_real));
reshaped_imag = reshape(acc_eigs_imag,[],1);
imag_mean = mean(reshaped_imag);
imag_std_err = std(reshaped_imag)/sqrt(length(reshaped_imag));

reshaped_dec_real = reshape(dec_eigs_real,[],1);
dec_real_mean = mean(reshaped_dec_real);
dec_real_std_err = std(reshaped_dec_real)/sqrt(length(reshaped_dec_real));
reshaped_dec_imag = reshape(dec_eigs_imag,[],1);
dec_imag_mean = mean(reshaped_dec_imag);
dec_imag_std_err = std(reshaped_dec_imag)/sqrt(length(reshaped_dec_imag));

x = [real_mean dec_real_mean];
y = [imag_mean dec_imag_mean];
yneg = [imag_std_err dec_imag_std_err];
ypos = yneg;
xneg = [real_std_err dec_real_std_err];
xpos = xneg;

figure('color','w','visible','on');
hold on;
box off;

errorbar(x(1),y(1),yneg(1),ypos(1),xneg(1),xpos(1),'o','Color','Blue','MarkerSize',10,'MarkerFaceColor','Blue','LineWidth',2)
errorbar(x(2),y(2),yneg(2),ypos(2),xneg(2),xpos(2),'o','Color','Red','MarkerSize',10,'MarkerFaceColor','Red','LineWidth',2)

xlabel('Real Component')
ylabel('Imaginary Component (Absolute Value)')
title('Blue = Accelerative | Red = Decelerative')

hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs_dec_vs_acc.png'));
% close gcf
%% Error Bar Plot By Direction

%turning snippet direction into color
% colors_by_degree = hsv(360);
% direction_in_degrees = rad2deg(snippet_direction_out)+180;
% colors = colors_by_degree(round(direction_in_degrees),:);

% Actually plotting

figure('visible','on','Color','w'); hold on; box off

for iState = 1:length(snippet_direction_out)

    real_eigs_to_plot = real_eigenvalues(iState, :);
    imaginary_eigs_to_plot = abs(imaginary_eigenvalues(iState, :));
    
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
title('Color = direction')
    
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs_by_dir.png'));
close gcf

%% 
for iState = 1:length(snippet_direction_out)
    real_eigs_to_plot = real_eigenvalues(iState, :);    
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
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_direction_key_for_eigs.png'));
close gcf
%% Bar

acc_states_real = [];
acc_states_imag = [];
for iState = 1:size(real_eigenvalues,1)
    if meta.acc_classification(iState) == 1
        acc_states_real = [acc_states_real real_eigenvalues(iState,:)];
        acc_states_imag = [acc_states_imag imaginary_eigenvalues(iState,:)];
    elseif meta.acc_classification(iState) == 0
        dec_states_real = [acc_states_real real_eigenvalues(iState,:)];
        dec_states_imag = [acc_states_imag imaginary_eigenvalues(iState,:)];
    end
end
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
