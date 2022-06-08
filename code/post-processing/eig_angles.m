function eig_angles(meta,snippet_direction,sorted_state_transitions)
sorted_state_transitions = sorted_state_transitions(1:5,:);
for iState = 1:meta.optimal_number_of_states
    real_eigenvectors_temp = readmatrix([meta.filepath 'real_eigenvectors_state_' num2str(iState) '.csv']);
    real_eigenvectors{iState} = real_eigenvectors_temp(2:end,:);
    imaginary_eigenvectors_temp = readmatrix ([meta.filepath 'imaginary_eigenvectors_state_' num2str(iState) '.csv']);
    imaginary_eigenvectors{iState} = imaginary_eigenvectors_temp(2:end,:);
end

%% Calculating the complex vectors

for iState = 1:size(real_eigenvectors, 2)
    complex_eigenvectors{iState} = complex(real_eigenvectors{iState},imaginary_eigenvectors{iState});
end
% Step 1: calculate the lengths of each eigenvector.

% Square root of the sum of the squares of each vector's elements.
for iState = 1:size(complex_eigenvectors,2)
    for iVector = 1:size(complex_eigenvectors{iState},2)
        complex_eigenvector_lengths(iState,iVector) = sqrt(sum(complex_eigenvectors{iState}(:,iVector).^2,'all'));
    end
end

% Step 2: identify the kinematic directionality of each state
for iState = 1:size(snippet_direction,2)
    avg_direction(iState) = circ_mean(snippet_direction(snippet_direction(:,iState) ~= 0,iState));
end
%% Okay now we calculate angles between all the other combinations of things.
[m,n] = ndgrid(1:meta.optimal_number_of_states,1:meta.optimal_number_of_states);
all_state_combos = [m(:),n(:)];

%%%% finding intersection of actual transitions and all possible states and
%%%% getting rid of the ones that overlap.
for iRow = 1:length(all_state_combos)
    all_combo_for_intersect(iRow) = str2double(strrep([num2str(all_state_combos(iRow,1)) num2str(all_state_combos(iRow,2))],' ',''));
end
for iRow = 1:length(sorted_state_transitions)
    sorted_transitions_for_intersect(iRow) = str2double(strrep([num2str(sorted_state_transitions(iRow,1)) num2str(sorted_state_transitions(iRow,2))],' ',''));
end


[~, ia, ~] = intersect(all_combo_for_intersect,sorted_transitions_for_intersect);

all_state_combos(ia,:) = [];

complex_eigenvector_angles_all_combos = [];
for iCombo = 1:size(all_state_combos,1)

    normalized_complex_eigenvector_temp_one = complex_eigenvectors{all_state_combos(iCombo,1)}/norm(complex_eigenvectors{all_state_combos(iCombo,1)});
    normalized_complex_eigenvector_temp_two = complex_eigenvectors{all_state_combos(iCombo,2)}/norm(complex_eigenvectors{all_state_combos(iCombo,2)});

    % Step 4: calculate dot products between all state eigenvector combos
    % of the two selected combos
    [m,n] = ndgrid(1:size(normalized_complex_eigenvector_temp_one,2),1:size(normalized_complex_eigenvector_temp_two,2));
    eigenvector_combos = [m(:),n(:)];

    for iIntraCombo = 1:size(eigenvector_combos,1)
        complex_dot_product_temp(iIntraCombo) = dot(normalized_complex_eigenvector_temp_one(eigenvector_combos(iIntraCombo,1)),normalized_complex_eigenvector_temp_two(eigenvector_combos(iIntraCombo,2)));
        complex_vector_length_product_temp(iIntraCombo) = complex_eigenvector_lengths(all_state_combos(iCombo,1),eigenvector_combos(iIntraCombo,1))*complex_eigenvector_lengths(all_state_combos(iCombo,2),eigenvector_combos(iIntraCombo,2));
    end
    % Step 5: calculate product of vector length combos

    % Step 6: calculate arcosine((X.Y)/(|X||Y|)) = theta
    complex_eigenvector_angles_all_combos(iCombo,:) = (complex_dot_product_temp./ complex_vector_length_product_temp);
    %     kinematic_direction_angles(iCombo) = circ_dist(avg_direction(sorted_state_transitions(iCombo,1)),avg_direction(sorted_state_transitions(iCombo,2)));
%     plot(real(complex_eigenvector_angles_all_combos(iCombo,3)),imag(complex_eigenvector_angles_all_combos(iCombo,3)),'.',"Color",'k','MarkerSize',7)
end
%%
colors = cool(size(sorted_state_transitions,1));
complex_eigenvector_angles = [];
for iCombo = 1:size(sorted_state_transitions,1)

    normalized_complex_eigenvector_temp_one = complex_eigenvectors{sorted_state_transitions(iCombo,1)}/norm(complex_eigenvectors{sorted_state_transitions(iCombo,1)});
    normalized_complex_eigenvector_temp_two = complex_eigenvectors{sorted_state_transitions(iCombo,2)}/norm(complex_eigenvectors{sorted_state_transitions(iCombo,2)});

    % Step 4: calculate dot products between all state eigenvector combos
    % of the two selected combos
    [m,n] = ndgrid(1:size(normalized_complex_eigenvector_temp_one,2),1:size(normalized_complex_eigenvector_temp_two,2));
    eigenvector_combos = [m(:),n(:)];

    for iIntraCombo = 1:size(eigenvector_combos,1)
        complex_dot_product_temp(iIntraCombo) = dot(normalized_complex_eigenvector_temp_one(eigenvector_combos(iIntraCombo,1)),normalized_complex_eigenvector_temp_two(eigenvector_combos(iIntraCombo,2)));
        complex_vector_length_product_temp(iIntraCombo) = complex_eigenvector_lengths(sorted_state_transitions(iCombo,1),eigenvector_combos(iIntraCombo,1))*complex_eigenvector_lengths(sorted_state_transitions(iCombo,2),eigenvector_combos(iIntraCombo,2));
    end
    % Step 5: calculate product of vector length combos

    % Step 6: calculate arcosine((X.Y)/(|X||Y|)) = theta
    complex_eigenvector_angles(iCombo,:) = (complex_dot_product_temp./ complex_vector_length_product_temp);
    %     kinematic_direction_angles(iCombo) = circ_dist(avg_direction(sorted_state_transitions(iCombo,1)),avg_direction(sorted_state_transitions(iCombo,2)));
%     plot(real(complex_eigenvector_angles(iCombo,:)),imag(complex_eigenvector_angles(iCombo,:)),'.',"Color",colors(iCombo,:),'MarkerSize',7)
end


%%
% Step 7: plot
figure('Visible','on'); hold on;
for iCombo = 1:size(all_state_combos,1)
    plot(real(complex_eigenvector_angles_all_combos(iCombo,:)),imag(complex_eigenvector_angles_all_combos(iCombo,:)),'.',"Color",'k','MarkerSize',7)
end
for iCombo = 1:size(sorted_state_transitions,1)
    plot(real(complex_eigenvector_angles(iCombo,:)),imag(complex_eigenvector_angles(iCombo,:)),'.',"Color",colors(iCombo,:),'MarkerSize',7)
end


% scatter3(real(complex_eigenvector_angles(:,3)),imag(complex_eigenvector_angles(:,3)), kinematic_direction_angles,'o')
xlabel('real component of angles between eigenvectors')
ylabel('imaginary component of angles between eigenvectors')
% zlabel('kinematic angle differences')
hold off
box off
set(gcf,"Color",'White')
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvector_angles.png']);

close gcf

%% violin plot
reshaped_all_combos_real = reshape(real(complex_eigenvector_angles_all_combos),[],1);
reshaped_all_combos_real_err = std(reshaped_all_combos_real)/sqrt(length(reshaped_all_combos_real));
reshaped_all_combos_imag = reshape(imag(complex_eigenvector_angles_all_combos),[],1);
reshaped_all_combos_imag_err = std(reshaped_all_combos_imag)/sqrt(length(reshaped_all_combos_imag));
reshaped_angles_real = reshape(real(complex_eigenvector_angles),[],1);
reshaped_angles_real_err = std(reshaped_angles_real)/sqrt(length(reshaped_angles_real));
reshaped_angles_imag = reshape(imag(complex_eigenvector_angles),[],1);
reshaped_angles_imag_err = std(reshaped_angles_imag)/sqrt(length(reshaped_angles_imag));

err_bars_real = [
    reshaped_all_combos_real_err
    reshaped_angles_real_err
    ];
err_bars_imag = [
    reshaped_all_combos_imag_err
    reshaped_angles_imag_err
    ];

figure; hold on
subplot(1,2,1); hold on
% bar([1,2],[mean(reshaped_all_combos_real) mean(reshaped_angles_real)])
errorbar([mean(reshaped_all_combos_real) mean(reshaped_angles_real)],err_bars_real,'o')
xlim([0 3])
ylim([-.02 .02])
xticklabels({'','all combo','top transitions',''})
title('real eigenvector angles')

subplot(1,2,2); hold on
% bar([3,4],[mean(reshaped_all_combos_imag) mean(reshaped_angles_imag)])
errorbar([mean(reshaped_all_combos_imag) mean(reshaped_angles_imag)],err_bars_imag,'o')
xlim([0 3])
ylim([-.02 .02])
xticklabels({'','all combo','top transitions',''})
title('imaginary eigenvector angles')
box off
set(gcf,"Color","w")
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvector_angles_comparison.png']);
close gcf

end