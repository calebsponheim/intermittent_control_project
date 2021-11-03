function rs_postmodel_analysis(meta,data)

%% Create Plot Figure Results Folder
if meta.crosstrain == 0
    if meta.move_only == 1
        meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0_move_only\'];
    else
        meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0\'];
    end
else
    meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\CT' num2str(meta.crosstrain) '\'];
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

end