function bx_postmodel_analysis(meta,data)

%% Create Plot Figure Results Folder
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    if meta.crosstrain == 0
        meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0\'];
    else
        meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\CT' num2str(meta.crosstrain) '\'];        
    end
else
    if meta.crosstrain == 0
        meta.figure_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' meta.subject '\' meta.task '_CT0\'];
    else
        meta.figure_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' meta.subject '\CT' num2str(meta.crosstrain) '\'];        
    end
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

% Plot normalized velocity
plot_state_normalized_velocity(meta,data,snippet_data)

% Plot all Trials
plot_all_trials_v2(meta,data);

% Plot Transition Matrix
% plot_transition_matrix_v2(meta);

%% State-to-state comparison


% direction_comparison_matrix = direction_comparison(meta,data,snippet_data,second_dataset,second_dataset_meta);


% direction_comparison_matrix = direction_comparison(data,snippet_data,meta);
% 
% velocity_compare_single_task = velocity_comparison(data,snippet_data,meta);
% 


end