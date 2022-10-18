%%

if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'C:\Users\calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
    file_base_base = 'C:\Users\Caleb (Work)';
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
    disp('you shouldn''t be here lol');
end

%%
bits_per_spike = [];
ll_files_list = dir(filepath_for_ll_plot);
ll_files_list = {ll_files_list.name}';
ll_files_list = ll_files_list(cellfun(@(x) ~contains(x,'.csv'),ll_files_list));
ll_files_list = ll_files_list(cellfun(@(x) contains(x,'_states'),ll_files_list));
ll_files_list = ll_files_list(cellfun(@(x) contains(x,'_dims'),ll_files_list));

for iFolder = 1:length(ll_files_list)
    temp_bits_files_list = dir(strcat(filepath_for_ll_plot,ll_files_list{iFolder}));
    temp_bits_filename = {temp_bits_files_list.name}';
    temp_bits_folder = temp_bits_files_list(1).folder;
    temp_bits_filename = temp_bits_filename(cellfun(@(x) contains(x,'_emissions_ll'),temp_bits_filename));
    temp_bits_state_num = str2double(extractAfter(extractBefore(temp_bits_folder,'_states'),filepath_for_ll_plot));
    temp_bits_dim_num = str2double(extractAfter(extractBefore(temp_bits_folder,'_dims'),'_states_'));
    if size(temp_bits_filename,1) > 0
        temp_bits_filepath = strcat(temp_bits_folder,'\',temp_bits_filename{1});
        temp = readmatrix(temp_bits_filepath);
        % put data in correct x,y,and x positions based on state, dim, and
        % folds in this given file and path.
%         disp(length(temp(:,1)))
        if length(temp(:,1)) >= 2
            bits_per_spike(temp_bits_dim_num,temp_bits_state_num) = mean(temp(:,1));
        end
    end
end
%%
bits_per_spike(bits_per_spike == 0) = NaN;

%% 3D Non-Marginal
colors = hsv(size(bits_per_spike,2));
figure; hold on;
for iState = 2:size(bits_per_spike,2)
    x = find(bits_per_spike(:,iState)~=0 & ~isnan(bits_per_spike(:,iState)));
    y = bits_per_spike(bits_per_spike(:,iState)~=0,iState);
    y = y(~isnan(y));
    plot3(x,repmat(iState,length(y)),y,'LineWidth',2,'Color',colors(iState,:));
end
view(134,24)
for iDim = 2:size(bits_per_spike,1)
    x = find(bits_per_spike(iDim,:)~=0 & ~isnan(bits_per_spike(iDim,:)));
    y = bits_per_spike(iDim,bits_per_spike(iDim,:)~=0);
    y = y(~isnan(y));
    plot3(repmat(iDim,length(y)),x,y,'LineWidth',2,'Color','#808080');
end
set(gcf,"Renderer","opengl","Color","w")
title(strcat(meta.subject," ",meta.task," Cross-Validated Likelihood"))
xlabel("# Latent Dimensions")
ylabel("# Discrete States")
zlabel("Log Likelihood")
grid on
box off
hold off
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_param_search_surf.png']);
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_param_search_surf_interactive.fig']);

% %% 3D focused
% colors = hsv(size(bits_per_spike,2));
% focused_state_range = 2:20;
% x = focused_state_range;
% y = [];
% state_count = 1;
% for iState = focused_state_range
%     y(state_count,:) = bits_per_spike(5:20,iState);
%     state_count = state_count + 1;
% end
% state_mean_across_dims = mean(y,2,'omitnan');
% figure; hold on;
% plot(x,state_mean_across_dims,'-o','LineWidth',2);
% plot(x,y','.')
% set(gcf,"Color","w")
% title(strcat(meta.subject," ",meta.task," Cross-Validated Likelihood"))
% xlabel("# Discrete States")
% ylabel("Log Likelihood")
% grid on
% box off
% hold off
% saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_param_search_focused_3d.png']);

%%   2D
colors = hsv(size(bits_per_spike,2));
figure; hold on;
for iState = 2:size(bits_per_spike,2)
    x = find(bits_per_spike(:,iState)~=0 & ~isnan(bits_per_spike(:,iState)));
    y = bits_per_spike(bits_per_spike(:,iState)~=0,iState);
    y = y(~isnan(y));
    plot(x,y,'LineWidth',2,'Color',colors(iState,:))
end
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