function eig_angles(meta,colors)

for iState = 1:meta.optimal_number_of_states
    real_eigenvectors_temp = readmatrix([meta.filepath 'real_eigenvectors_state_' num2str(iState) '.csv']);
    real_eigenvectors{iState} = real_eigenvectors_temp(2:end,:);
    imaginary_eigenvectors_temp = readmatrix([meta.filepath 'imaginary_eigenvectors_state_' num2str(iState) '.csv']);
    imaginary_eigenvectors{iState} = imaginary_eigenvectors_temp(2:end,:);
end

% Step 1: calculate the lengths of each eigenvector. 

    % Square root of the sum of the squares of each vector's elements. 

% Step 2: identify the kinematic directionality of each state

% Step 3: figure out combinatorics of different state combinations

% Step 4: calculate dot products between all state eigenvector combos

% Step 5: calculate product of vector length combos

% Step 6: calculate arcosine((X.Y)/(|X||Y|)) = theta

% Step 7: plot


end