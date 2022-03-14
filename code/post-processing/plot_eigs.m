function plot_eigs(meta,colors)

real_eigenvalues = readmatrix([meta.filepath 'real_eigenvalues.csv']);
real_eigenvalues = real_eigenvalues(2:end,:);
imaginary_eigenvalues = readmatrix([meta.filepath 'imaginary_eigenvalues.csv']);
imaginary_eigenvalues = imaginary_eigenvalues(2:end,:);

figure('color','w','visible','on');
hold on;
box off;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
for iState = 1:size(real_eigenvalues,1)
    if meta.acc_classification(iState) == 1
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(1,:));
    elseif meta.acc_classification(iState) == 0
        plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(2,:));
    end
end
xlabel('Real Component')
ylabel('Imaginary Component')
title('Blue = Accelerative | Red = Decelerative')

hold off
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_state_',num2str(iState),'_eigs.png']);
close gcf

end
