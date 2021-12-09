% Link Kinematics to Neural States

% get test trial indices
% get state info from test trials
% get kinematics for test trials
for iTrial = 1:length(trInd_test)
    speed_plot(iTrial).test_indices = trInd_test(iTrial);
    speed_plot(iTrial).latent_state = dc_thresholded(iTrial).maxprob_state;
    speed_plot(iTrial).speed = data(test_indices(iTrial)).speed;
end
% make colorscale and legend info

% test plot kinematics with state info colors

% implement lag