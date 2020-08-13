% %% Build and Run Model
% if crosstrain > 0
%     [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM([],num_states_subject,data_RTP,data_center_out,crosstrain,seed_to_train,TRAIN_PORTION);
% else
%     [trInd_train,trInd_test,hn_trained,dc,seed_to_train] = train_and_decode_HMM(data,num_states_subject,[],[],crosstrain,seed_to_train,TRAIN_PORTION);
% end
% 

%% Save Model
if ispc
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(strcat('C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\',subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_CT_',num2str(crosstrain),'_',date))
    else
        save(strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\data\',subject,task,'_HMM_classified_test_data_and_output_',num2str(num_states_subject),'_states_CT_',num2str(crosstrain),'_',date))
    end
    %     save(['C:\Users\vpapadourakis\Documents\' subject task '_HMM_classified_test_data_and_output_' num2str(num_states_subject) '_states_' date])
else
    save(['/Volumes/nicho-lab/caleb_sponheim/intermittent_control/data/' subject task '_HMM_classified_test_data_and_output_' num2str(num_states_subject) '_states_' date])
end

%% Create Plot Figure Results Folder
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    file_list = dir('C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\');
else
    file_list = dir('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\');
end

file_list = {file_list.name};
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-6);

if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\',subject,task,num2str(num_states_subject),'_states_',current_date_and_time,'_CT_',num2str(crosstrain)];
else
    figure_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'_states_',current_date_and_time,'_CT_',num2str(crosstrain)];
end
figure_folder_filepath_dupe_comp = [subject,task,num2str(num_states_subject),'_states_',current_date_and_time,'_CT_',crosstrain];
dupe_status = cell2mat(cellfun(@(x,y)strcmp(x,figure_folder_filepath_dupe_comp),file_list,'UniformOutput',false));
if sum(dupe_status) > 0
    figure_folder_filepath = [figure_folder_filepath 'a'];
end
mkdir(figure_folder_filepath)

%% Process HMM output
[dc_thresholded] = censor_and_threshold_HMM_output(dc);

%% Create Snippets and Plot **everything**

if crosstrain == 1 % RTP model, center-out decode
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps_center_out,data,subject,muscle_names,include_EMG_analysis,target_locations);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'center_out',muscle_names,include_EMG_analysis,figure_folder_filepath)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'center_out',muscle_names,include_EMG_analysis,figure_folder_filepath);
elseif crosstrain == 2 % 2: Center-out model, RTP decode
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps_RTP,data,subject,muscle_names,include_EMG_analysis,target_locations);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,'RTP',muscle_names,include_EMG_analysis,figure_folder_filepath)
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,'RTP',muscle_names,include_EMG_analysis,figure_folder_filepath);
elseif crosstrain == 3
    bin_timestamps = [bin_timestamps_center_out bin_timestamps_RTP];
    data = [data_center_out data_RTP];
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps,data,subject,muscle_names,include_EMG_analysis,target_locations);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath)
else
    [trialwise_states] = segment_analysis(trInd_test,dc_thresholded,bin_timestamps,data,subject,muscle_names,include_EMG_analysis,target_locations);
    [segmentwise_analysis] = plot_segments(trialwise_states,num_states_subject,trInd_test,subject,num_segments_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath);
    plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,muscle_names,include_EMG_analysis,figure_folder_filepath)
end

%%
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
