%%

if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'C:\Users\calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
     file_base_base = 'C:\Users\Caleb (Work)';
end

[~, colors] = colornames('xkcd','windows blue', 'red', 'amber', 'faded green', ...
    'deep aqua', 'fresh green', 'indian red', 'orangeish', 'old rose', 'azul', ...
    'barney', 'blood orange', 'cerise', 'orange', 'red', 'salmon', 'lilac');

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
    meta.figure_folder_filepath = [meta.figure_folder_filepath 'hmm\'];
end

%%
dim_skip = 5;
state_skip = 2;

ll_files_list = dir(filepath);
ll_files_list = {ll_files_list.name}';
ll_files_list = ll_files_list(cellfun(@(x) contains(x,'_states_ll'),ll_files_list));
for iFile = 1:length(ll_files_list)
    temp = readmatrix([filepath ll_files_list{iFile}]);
    for iRow = 1:size(temp,1)
        bits_per_spike(temp(iRow,2),str2double(extractBefore(ll_files_list{iFile},'_states_ll'))) = temp(iRow,1);
    end
end

bits_per_spike(bits_per_spike == 0) = NaN;

plot_row = 1;
rows_for_plot = 2:dim_skip:size(bits_per_spike,1);
columns_for_plot = 2:state_skip:size(bits_per_spike,2);
for iRow = rows_for_plot
    plot_column = 1;
    for iColumn = columns_for_plot
        bits_per_spike_for_plot(plot_row,plot_column) = bits_per_spike(iRow,iColumn);
        plot_column = plot_column + 1;
    end
    plot_row = plot_row + 1;
end



bits_per_spike_for_plot_filled = fillmissing(bits_per_spike_for_plot,'linear',2,'EndValues','nearest');


for iRow = 1:size(bits_per_spike_for_plot_filled,1)
    for iColumn = 2:size(bits_per_spike_for_plot_filled,2)
        marginal_bits_per_spike_for_plot_filled(iRow,iColumn-1) = bits_per_spike_for_plot_filled(iRow,iColumn) - bits_per_spike_for_plot_filled(iRow,iColumn-1);
    end
end

[surf_dims,surf_states] = meshgrid(rows_for_plot,columns_for_plot(2:end));



figure; hold on;
surf(surf_dims,surf_states,marginal_bits_per_spike_for_plot_filled')
view(-45,45) 
hold off
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trial_',num2str(iTrial),'_param_search_surf.png']);


figure; hold on;
for iState = 2:size(bits_per_spike,2)
    x = find(bits_per_spike(:,iState)>0);
    plot(x(2:end),diff(bits_per_spike(bits_per_spike(:,iState)>0,iState)),'LineWidth',2)
end
hold off
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_trial_',num2str(iTrial),'_param_search_2D.png']);
