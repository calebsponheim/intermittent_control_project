%%

if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'C:\Users\calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
    file_base_base = 'C:\Users\Caleb (Work)';
end
filepath_base = [file_base_base '\Documents\git\intermittent_control_project\data\python_switching_models\'];

% filepath = [filepath_base 'RSCO_move_window0.05sBins\'];
% filepath = [filepath_base 'RSRTP0.05sBins\'];
% filepath = [filepath_base 'RJRTP0.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out_and_RTP1902280.05sBins\'];
filepath = [filepath_base 'BxRTP0.05sBins\'];
% filepath = [filepath_base 'Bx18CO0.05sBins\'];

meta.subject = 'Bx';
meta.task = 'RTP';
meta.crosstrain = 0;
meta.move_only = 0;
meta.use_rslds = 0;
if strcmp(meta.subject,'RS')
    meta.session = '';
end
%% Create Plot Figure Results Folder
if meta.crosstrain == 0 
    if meta.move_only == 1
        meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0_move_only\'];
    elseif contains(meta.session,'180323')
        meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '18_CT0\'];
    else
        meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_CT0\'];
    end
else
    meta.figure_folder_filepath = [file_base_base '\Documents\git\intermittent_control_project\figures\' meta.subject '\CT' num2str(meta.crosstrain) '\'];
end

if meta.use_rslds == 1
    meta.figure_folder_filepath = [meta.figure_folder_filepath 'rslds\'];
elseif meta.use_rslds == 0
    meta.figure_folder_filepath = [meta.figure_folder_filepath 'lds\'];
end

filepath_for_ll_plot = filepath;
%%
bits_per_spike = [];
ll_files_list = dir(filepath);
ll_files_list = {ll_files_list.name}';
ll_files_list = ll_files_list(cellfun(@(x) ~contains(x,'.csv'),ll_files_list));
ll_files_list = ll_files_list(cellfun(@(x) ~contains(x,'_states'),ll_files_list));
ll_files_list = ll_files_list(cellfun(@(x) contains(x,'_dims'),ll_files_list));

for iFolder = 1:length(ll_files_list)
    temp_bits_files_list = dir(strcat(filepath_for_ll_plot,ll_files_list{iFolder}));
    temp_bits_filename = {temp_bits_files_list.name}';
    temp_bits_folder = temp_bits_files_list(1).folder;
    temp_bits_filename = temp_bits_filename(cellfun(@(x) contains(x,'_emissions_ll_'),temp_bits_filename));
    temp_bits_dim_num = str2double(extractAfter(extractBefore(temp_bits_folder,'_dims'),filepath_for_ll_plot));
    if size(temp_bits_filename,1) > 0
        for iFile = 1:size(temp_bits_filename,1)
            temp_bits_filepath = strcat(temp_bits_folder,'\',temp_bits_filename{iFile});
            temp(iFile,:) = readmatrix(temp_bits_filepath);
        % put data in correct x,y,and x positions based on state, dim, and
        % folds in this given file and path.
%         disp(length(temp(:,1)))
        end
        if length(temp(:,1)) >= 1
            bits_per_spike(temp_bits_dim_num) = mean(temp(:,1));
        end
        
    end
end
%%
bits_per_spike(bits_per_spike == 0) = NaN;
writematrix(bits_per_spike,strcat(filepath_for_ll_plot,'lds_ll.csv'))

%%   2D
colors = hsv(size(bits_per_spike,2));
figure; hold on;
    plot(2:size(bits_per_spike,2),bits_per_spike(2:end),'LineWidth',2)
set(gcf,"Renderer","opengl","Color","w")
title(strcat(meta.subject," ",meta.task," Cross-Validated Likelihood"))
xlabel("# Latent Dimensions")
ylabel("Log Likelihood")
grid on
box off
hold off
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_param_search_2D.png']);
%%
% close all