function plot_eigs(meta,colors)
%%
real_eigenvalues = readmatrix([meta.filepath 'real_eigenvalues.csv']);
real_eigenvalues = real_eigenvalues(2:end,:);
imaginary_eigenvalues = readmatrix([meta.filepath 'imaginary_eigenvalues.csv']);
imaginary_eigenvalues = imaginary_eigenvalues(2:end,:);


%% Scatter
figure('color','w','visible','off');
hold on;
box off;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
for iState = 1:size(real_eigenvalues,2)
    if meta.acc_classification(iState) == 1
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(1,:));
    elseif meta.acc_classification(iState) == 0
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(2,:));
    elseif meta.acc_classification(iState) == 2
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color','black');
    end
end
xlabel('Real Component')
ylabel('Imaginary Component')
title('Blue = Accelerative | Red = Decelerative')

hold off
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigs.png']);
close gcf

%% Bar

acc_states_real = [];
acc_states_imag = [];
for iState = 1:size(real_eigenvalues,2)
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
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eig_dist_real.png']);
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
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eig_dist_imag.png']);
close gcf




end
