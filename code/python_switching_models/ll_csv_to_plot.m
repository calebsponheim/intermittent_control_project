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


ll_files_list = dir(filepath);
ll_files_list = {ll_files_list.name}';
ll_files_list = ll_files_list(cellfun(@(x) contains(x,'_states_ll'),ll_files_list));
for iFile = 1:length(ll_files_list)
    temp = readmatrix([filepath ll_files_list{iFile}]);
    for iRow = 1:size(temp,1)
        bits_per_spike(temp(iRow,2),str2double(extractBefore(ll_files_list{iFile},'_states_ll'))) = temp(iRow,1);
    end
end

[surf_dims,surf_states] = meshgrid(2:(size(bits_per_spike,1)),2:(size(bits_per_spike,2)));

bits_per_spike(bits_per_spike == 0) = NaN;

figure; hold on;
surf(surf_dims,surf_states,bits_per_spike(2:end,2:end)')