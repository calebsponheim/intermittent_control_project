%% Plotting single task trials from double-task model



% CO
bin_timestamps = [bin_timestamps_center_out bin_timestamps_RTP];
data = [data_center_out data_RTP];
trInd_test_CO = trInd_test(trInd_test <= length(data_center_out));

[trialwise_states] = segment_analysis(num_states_subject,trInd_test_CO,dc_thresholded,bin_timestamps,data,subject);
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test_CO,subject,num_segments_to_plot,task);
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
% RTP

bin_timestamps = [bin_timestamps_center_out bin_timestamps_RTP];
data = [data_center_out data_RTP];
trInd_test_RTP = trInd_test(trInd_test > length(data_center_out));

[trialwise_states] = segment_analysis(num_states_subject,trInd_test_RTP,dc_thresholded,bin_timestamps,data,subject);
[segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test_RTP,subject,num_segments_to_plot,task);
plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)
