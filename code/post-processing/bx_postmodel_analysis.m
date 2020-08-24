%% Create Plot Figure Results Folder
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    if meta.crosstrain == 0
        file_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0\'];
    else
        file_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\_CT' meta.crosstrain '\'];        
    end
else
    if meta.crosstrain == 0
        file_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' meta.subject '\' meta.task '_CT0\'];
    else
        file_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' meta.subject '\_CT' meta.crosstrain '\'];        
    end
end

%% Create Snippets and Plot **everything**

% Segment Analysis
% Plot Single Trials
% Plot Segments

%% Plot all Trials
% trials_to_plot = datasample(1:length(trialwise_states),100);
% trials_to_plot = trials_to_plot(randperm(length(trials_to_plot)));
% trials_to_plot = [20:25];
trials_to_plot = 1:length(trialwise_states);
plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,figure_folder_filepath)
%%
transition_matrix_for_plot = hn_trained.a;

for iState = 1:num_states_subject
    transition_matrix_for_plot(iState,iState) = 0;
end

figure('visible','off'); hold on;
imagesc(transition_matrix_for_plot)
colormap(gca,jet)
axis square
axis tight
colorbar
if strcmp(task,'center_out')
    title([subject,' center out transition matrix']);
else
    title([subject,task,' transition matrix']);
end
box off
set(gcf,'Color','White');
saveas(gcf,strcat(figure_folder_filepath,'\'...
    ,subject,task,num2str(num_states_subject),'states_transition_matrix.png'));

%% normalized segments

[segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject,include_EMG_analysis,muscle_names,figure_folder_filepath);

%% Plot Avg EMG Center Out stuff

if strcmp(task,'center_out')
    avg_CO_emg_traces(muscle_names,trialwise_states,targets,figure_folder_filepath,subject,task)
end

%% Save Result

% save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
% save(strcat('C:\Users\vpapadourakis\Documents\',subject,'_',task,'_HMM_analysis_',num2str(num_states_subject),'_states_',date))
