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
    plot(real_eigenvalues(iState,:),imaginary_eigenvalues(iState,:),'o','color',colors(iState,:));
end
xlabel('Real Component')
ylabel('Imaginary Component')
end
