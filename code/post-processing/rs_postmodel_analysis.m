function rs_postmodel_analysis(meta,data)

file_base_base = 'C:\Users\Caleb (Work)';


%% Create Plot Figure Results Folder
if meta.crosstrain == 0
    if meta.move_only == 1
        meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0_move_only\'];
    else
        meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0\'];
    end
else
    meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\CT' num2str(meta.crosstrain) '\'];
end

if meta.use_rslds == 1
    meta.figure_folder_filepath = [meta.figure_folder_filepath 'rslds\'];
elseif meta.use_rslds == 0
    meta.figure_folder_filepath = [meta.figure_folder_filepath 'hmm\'];
end
%% Create Snippet Timing

% Segment Analysis
[meta,data,snippet_data] = segment_analysis_v2(meta,data);

%% Plot Everything

% Plot Single Trials
plot_single_trials_v2(meta,data)
% Plot Segments
plot_state_snippets(meta,data,snippet_data)
% Plot State Direction
plot_state_direction(meta,data,snippet_data)

% Plot all Trials
plot_all_trials_v2(meta,data);

% Plot num extrema versus num transitions
plot_extrema_vs_transitions(meta,data)

% Plot normalized velocity
plot_state_normalized_velocity(meta,data,snippet_data)

% Plot Mean Snippet Lengths

plot_state_lengths(meta,snippet_data)

% Compare Extrema Timing to Transition Timing

extrema_vs_transition_timing(data,meta)

end