% Compare log likelihood values between models

if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'C:\Users\calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
    file_base_base = 'C:\Users\Caleb (Work)';
end
filepath_base = [file_base_base '\Documents\git\intermittent_control_project\data\python_switching_models\'];

% filepath = [filepath_base 'RSCO_move_window0.05sBins\'];
filepath = [filepath_base 'RSRTP0.05sBins\'];
% filepath = [filepath_base 'RJRTP0.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out_and_RTP1902280.05sBins\'];
% filepath = [filepath_base 'BxRTP0.05sBins\'];
% filepath = [filepath_base 'Bx18CO0.05sBins\'];

if contains(filepath,'RS') && contains(filepath,'RTP')
    meta.subject = 'RS';
    subject = meta.subject;
    meta.task = 'RTP';
    task = meta.task;
    num_latent_dims_rslds = 25;
    num_discrete_states_rslds = 10;
    num_latent_dims_slds = 2;
    num_discrete_states_slds = 2;
    num_latent_dims_lds = 40;
    num_discrete_states_hmm = 28;
elseif contains(filepath,'RJ') && contains(filepath,'RTP')
    meta.subject = 'RJ';
    subject = meta.subject;
    meta.task = 'RTP';
    task = meta.task;
    num_latent_dims_rslds = 25;
    num_discrete_states_rslds = 10;
    num_latent_dims_slds = 2;
    num_discrete_states_slds = 2;
    num_latent_dims_lds = 80;
    num_discrete_states_hmm = 16;
elseif contains(filepath,'Bx') && contains(filepath,'RTP')
    meta.subject = 'Bx';
    subject = meta.subject;
    meta.task = 'RTP';
    task = meta.task;    
    num_latent_dims_rslds = 30;
    num_discrete_states_rslds = 10;
    num_latent_dims_lds = 46;
    num_discrete_states_hmm = 43;
end



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

%% Load Data

lds_ll = readmatrix(strcat(filepath_for_ll_plot,'lds_ll.csv'));
rslds_ll = readmatrix(strcat(filepath_for_ll_plot,'rslds_ll.csv'));

%% Plot
colors = hsv(size(rslds_ll,2));
figure; hold on;
for iState = num_discrete_states_rslds
    x = find(rslds_ll(:,iState)~=0 & ~isnan(rslds_ll(:,iState)));
    y = rslds_ll(rslds_ll(:,iState)~=0,iState);
    y = y(~isnan(y));
    plot(x,y,'LineWidth',3,'Color',colors(iState,:))
end
plot(2:(length(lds_ll)),lds_ll(2:end),'color','k','linewidth',3)

set(gcf,"Renderer","opengl","Color","w",'Position',[200 200 300 500])
% title(strcat(meta.subject," ",meta.task," Cross-Validated Likelihood"))
xlabel("# Latent Dimensions")
ylabel("Log Likelihood")
xlim([0 40])
grid on
box off
hold off
saveas(gcf,strcat(meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_lds_vs_rslds.png'));
