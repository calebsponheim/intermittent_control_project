function eig_angles(meta,sorted_state_transitions)

eigenvalue_magnitude_threshold = 0.75;

sorted_state_transitions_for_function = sorted_state_transitions(:,:);
for iState = 1:meta.optimal_number_of_states
    real_eigenvectors_temp = readmatrix(strcat(meta.filepath,'real_eigenvectors_state_',num2str(iState),'.csv'));
    real_eigenvectors{iState} = real_eigenvectors_temp(2:end,:);
    imaginary_eigenvectors_temp = readmatrix(strcat(meta.filepath,'imaginary_eigenvectors_state_',num2str(iState),'.csv'));
    imaginary_eigenvectors{iState} = imaginary_eigenvectors_temp(2:end,:);
end


real_eigenvalues = readmatrix(strcat(meta.filepath,'real_eigenvalues.csv'));
real_eigenvalues = real_eigenvalues(2:end,:);
imaginary_eigenvalues = readmatrix(strcat(meta.filepath,'imaginary_eigenvalues.csv'));
imaginary_eigenvalues = imaginary_eigenvalues(2:end,:);

%% Eigenvalue Magnitude Mapping
% eigenvalue_magnitude = sqrt(real_eigenvalues.^2 + imaginary_eigenvalues.^2);
eigenvalue_magnitude = real_eigenvalues;
figure('visible','off'); hold on
for iState = 1:size(eigenvalue_magnitude,1)
    temp_eigenvalue_magnitude = eigenvalue_magnitude(iState,:);
    plot((cumsum(fliplr(sort(temp_eigenvalue_magnitude)))))
%     plot(fliplr(sort(temp_eigenvalue_magnitude)))
end
xlabel('Dimension index')
ylabel('cumulative Magnitude')
title(strcat("Cumulative Eigenvalue Magnitude (Real)"))
hold off
box off
set(gcf,"Color",'White')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvalue_magnitudes.png'));

close gcf

%% Calculating the complex vectors

for iState = 1:size(real_eigenvectors, 2)
    complex_eigenvectors{iState} = complex(real_eigenvectors{iState},imaginary_eigenvectors{iState});
end

%% Okay now we calculate angles between all the other combinations of things.
[m,n] = ndgrid(1:meta.optimal_number_of_states,1:meta.optimal_number_of_states);
all_state_combos = [m(:),n(:)];

%%%% finding intersection of actual transitions and all possible states and
%%%% getting rid of the ones that overlap.
for iRow = 1:length(all_state_combos)
    all_combo_for_intersect(iRow) = str2double(strrep([num2str(all_state_combos(iRow,1)) num2str(all_state_combos(iRow,2))],' ',''));
end
for iRow = 1:size(sorted_state_transitions_for_function,1)
    sorted_transitions_for_intersect(iRow) = str2double(strrep([num2str(sorted_state_transitions_for_function(iRow,1)) num2str(sorted_state_transitions_for_function(iRow,2))],' ',''));
end


[~, ia, ~] = intersect(all_combo_for_intersect,sorted_transitions_for_intersect);

all_state_combos(ia,:) = [];
all_state_combos(all_state_combos(:,1) == all_state_combos(:,2),:) = [];
complex_eigenvector_angles_all_combos = [];
for iCombo = 1:size(all_state_combos,1)

    complex_eigenvector_temp_one = complex_eigenvectors{all_state_combos(iCombo,1)};
    complex_eigenvector_temp_two = complex_eigenvectors{all_state_combos(iCombo,2)};
    eigenvalue_magnitude_temp_one = eigenvalue_magnitude(all_state_combos(iCombo,1),:);
    eigenvalue_magnitude_temp_two = eigenvalue_magnitude(all_state_combos(iCombo,2),:);
    % Step 4: calculate dot products between all state eigenvector combos
    % of the two selected combos
    [m,n] = ndgrid(find(eigenvalue_magnitude_temp_one > eigenvalue_magnitude_threshold),find(eigenvalue_magnitude_temp_two > eigenvalue_magnitude_threshold));
    eigenvector_combos = [m(:),n(:)];

    for iIntraCombo = 1:size(eigenvector_combos,1)  
        input_one = complex_eigenvector_temp_one(:,eigenvector_combos(iIntraCombo,1));
        input_two = complex_eigenvector_temp_two(:,eigenvector_combos(iIntraCombo,2));
        complex_dot_product_temp(iIntraCombo) = dot(input_one,input_two);
        complex_vector_length_product_temp(iIntraCombo) = norm(input_one) * norm(input_two);
    end
    % Step 5: calculate product of vector length combos

    % Step 6: calculate ((X.Y)/(|X||Y|)) = theta
    if size(eigenvector_combos,1) > 0
    complex_eigenvector_angles_all_combos{iCombo} = arrayfun(@(x,y) x/y,complex_dot_product_temp,complex_vector_length_product_temp);
    end
end
%%
colors = cool(size(sorted_state_transitions_for_function,1));
complex_eigenvector_angles = [];
for iCombo = 1:size(sorted_state_transitions_for_function,1)

    complex_eigenvector_temp_one = complex_eigenvectors{sorted_state_transitions_for_function(iCombo,1)};
    complex_eigenvector_temp_two = complex_eigenvectors{sorted_state_transitions_for_function(iCombo,2)};
    eigenvalue_magnitude_temp_one = eigenvalue_magnitude(sorted_state_transitions_for_function(iCombo,1),:);
    eigenvalue_magnitude_temp_two = eigenvalue_magnitude(sorted_state_transitions_for_function(iCombo,2),:);

    [m,n] = ndgrid(find(eigenvalue_magnitude_temp_one > eigenvalue_magnitude_threshold),find(eigenvalue_magnitude_temp_two > eigenvalue_magnitude_threshold));
    eigenvector_combos = [m(:),n(:)];
    eigenvector_combos(eigenvector_combos(:,1) == eigenvector_combos(:,2),:) = [];


    for iIntraCombo = 1:size(eigenvector_combos,1)
        input_one = complex_eigenvector_temp_one(:,eigenvector_combos(iIntraCombo,1));
        input_two = complex_eigenvector_temp_two(:,eigenvector_combos(iIntraCombo,2));
        complex_dot_product_temp(iIntraCombo) = dot(input_one,input_two);
        complex_vector_length_product_temp(iIntraCombo) = norm(input_one) * norm(input_two);
    end

    % Step 6: calculate ((X.Y)/(|X||Y|)) = cosine
    complex_eigenvector_angles{iCombo} = arrayfun(@(x,y) x/y,complex_dot_product_temp,complex_vector_length_product_temp);
end


%%
% Step 7: plot
figure('Visible','off'); hold on;
for iCombo = 1:size(all_state_combos,1)
    plot(real(complex_eigenvector_angles_all_combos{iCombo}),imag(complex_eigenvector_angles_all_combos{iCombo}),'.',"Color",'k','MarkerSize',10)
end
for iCombo = 1:size(sorted_state_transitions_for_function,1)
    plot(real(complex_eigenvector_angles{iCombo}),imag(complex_eigenvector_angles{iCombo}),'.',"Color",colors(iCombo,:),'MarkerSize',10)
end


xlabel('real component of cosine between eigenvectors')
ylabel('imaginary component of cosine between eigenvectors')
hold off
box off
set(gcf,"Color",'White')
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvector_angles.png'));

close gcf

%% plot
reshaped_all_combos_real = reshape(real([complex_eigenvector_angles_all_combos{:}]),[],1);
reshaped_all_combos_real_err = std(reshaped_all_combos_real)/sqrt(length(reshaped_all_combos_real));
reshaped_all_combos_imag = reshape(imag([complex_eigenvector_angles_all_combos{:}]),[],1);
reshaped_all_combos_imag_err = std(reshaped_all_combos_imag)/sqrt(length(reshaped_all_combos_imag));
reshaped_angles_real = reshape(real([complex_eigenvector_angles{:}]),[],1);
reshaped_angles_real_err = std(reshaped_angles_real)/sqrt(length(reshaped_angles_real));
reshaped_angles_imag = reshape(imag([complex_eigenvector_angles{:}]),[],1);
reshaped_angles_imag_err = std(reshaped_angles_imag)/sqrt(length(reshaped_angles_imag));

err_bars_real = [
    reshaped_all_combos_real_err
    reshaped_angles_real_err
    ];
err_bars_imag = [
    reshaped_all_combos_imag_err
    reshaped_angles_imag_err
    ];

figure('visible','off'); hold on
subplot(1,2,1); hold on
errorbar([mean(reshaped_all_combos_real) mean(reshaped_angles_real)],err_bars_real,'o')
xlim([0 3])
xticklabels({'','all combo','top transitions',''})
title('real eigenvector angles')

subplot(1,2,2); hold on
errorbar([mean(reshaped_all_combos_imag) mean(reshaped_angles_imag)],err_bars_imag,'o')
xlim([0 3])
xticklabels({'','all combo','top transitions',''})
title('imaginary eigenvector angles')
box off
set(gcf,"Color","w")
saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvector_angles_comparison.png'));
close gcf

end