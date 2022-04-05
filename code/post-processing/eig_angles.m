function eig_angles(meta,snippet_direction,colors)

for iState = 1:meta.optimal_number_of_states
    real_eigenvectors_temp = readmatrix([meta.filepath 'real_eigenvectors_state_' num2str(iState) '.csv']);
    real_eigenvectors{iState} = real_eigenvectors_temp(2:end,:);
    imaginary_eigenvectors_temp = readmatrix([meta.filepath 'imaginary_eigenvectors_state_' num2str(iState) '.csv']);
    imaginary_eigenvectors{iState} = imaginary_eigenvectors_temp(2:end,:);
end

%% Calculating the complex vectors

for iState = 1:size(real_eigenvectors, 2)
    complex_eigenvectors{iState} = complex(real_eigenvectors{iState},imaginary_eigenvectors{iState});
end
% Step 1: calculate the lengths of each eigenvector.

% Square root of the sum of the squares of each vector's elements.
for iState = 1:size(complex_eigenvectors,2)
    complex_eigenvector_lengths(iState) = sqrt(sum(complex_eigenvectors{iState}.^2,'all'));
end

% Step 2: identify the kinematic directionality of each state
for iState = 1:size(snippet_direction,2)
    avg_direction(iState) = circ_mean(snippet_direction(snippet_direction(:,iState) ~= 0,iState));
end
% Step 3: figure out combinatorics of different state combinations

state_combos = nchoosek(1:size(snippet_direction,2),2);

% All combo loop
complex_eigenvector_angles = [];
for iCombo = 1:size(state_combos,1)
    %%%%%%%%%%%%%%%%% Real
    normalized_complex_eigenvector_temp_one = complex_eigenvectors{state_combos(iCombo,1)}/norm(complex_eigenvectors{state_combos(iCombo,1)});
    normalized_complex_eigenvector_temp_two = complex_eigenvectors{state_combos(iCombo,2)}/norm(complex_eigenvectors{state_combos(iCombo,2)});
    
    % Step 4: calculate dot products between all state eigenvector combos
    complex_dot_product_temp = dot(normalized_complex_eigenvector_temp_one,normalized_complex_eigenvector_temp_two);
    
    % Step 5: calculate product of vector length combos
    complex_vector_length_product_temp = complex_eigenvector_lengths(state_combos(iCombo,1))*complex_eigenvector_lengths(state_combos(iCombo,2));
    
    % Step 6: calculate arcosine((X.Y)/(|X||Y|)) = theta
    complex_eigenvector_angles(iCombo,:) = acos(complex_dot_product_temp ./ complex_vector_length_product_temp);
    kinematic_direction_angles(iCombo) = circ_dist(avg_direction(state_combos(iCombo,1)),avg_direction(state_combos(iCombo,2)));
end

% Step 7: plot
figure('Visible','off');
% scatter3(real(complex_eigenvector_angles(:,3)),imag(complex_eigenvector_angles(:,3)), kinematic_direction_angles,'o')
plot(real(complex_eigenvector_angles(:,3)),imag(complex_eigenvector_angles(:,3)),'o')
xlabel('real component of angles between eigenvectors')
ylabel('imaginary component of angles between eigenvectors')
% zlabel('kinematic angle differences')
hold off
saveas(gcf,[meta.figure_folder_filepath,'\',meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_eigvector_angles.png']);
close gcf

end