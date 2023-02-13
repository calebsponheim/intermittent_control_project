%% Import Data from Python and integrate into matlab struct.
%clear

if strcmp(getenv('USERNAME'),'calebsponheim')
    file_base_base = 'C:\Users\calebsponheim';
elseif strcmp(getenv('USERNAME'),'caleb_work')
    file_base_base = 'C:\Users\Caleb (Work)';
end
filepath_base = [file_base_base '\Documents\git\intermittent_control_project\data\python_switching_models\'];
figure_base = [file_base_base '\Documents\git\intermittent_control_project\figures\'];
% filepath = [filepath_base 'RSCO0.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05_sBins_move_window_only\'];

% filepath = [filepath_base 'RSCO_move_window0.05sBins\'];
filepath = [filepath_base 'RSRTP0.05sBins\'];
% filepath = [filepath_base 'RJRTP0.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out_and_RTP1902280.05sBins\'];
% filepath = [filepath_base 'BxRTP0.05sBins\'];
% filepath = [filepath_base 'Bx18CO0.05sBins\'];

% OPTIONS
if contains(filepath,'RS') && contains(filepath,'RTP')
    num_desired_states = 8;
    num_desired_dims = 25;
elseif contains(filepath,'RS') && contains(filepath,'CO')
elseif contains(filepath,'RJ')
    num_desired_states = 8;
    num_desired_dims = 25;
%     num_desired_states = 5;
%     num_desired_dims = 10;
elseif contains(filepath, 'Bx') || contains(filepath,'center_out')
    if contains(filepath,'Bx18')
    elseif contains(filepath,'BxRTP0.05sBins')
%         num_desired_states = 18;
%         num_desired_dims = 38;
        num_desired_states = 8;
        num_desired_dims = 30;
    elseif contains(filepath,'190228')
    end
end


filepath_for_ll_plot = filepath;
filepath = strcat(filepath,num2str(num_desired_states),"_states_",num2str(num_desired_dims),"_dims\");

analyze_all_trials = 1;
plot_ll_hmm = 0;
plot_ll_rslds = 0;
use_rslds = 1;

%
meta.filepath = filepath;
decoded_data_hmm = readmatrix(...
    strcat(filepath,'decoded_data_hmm.csv')...
    ) + 1;
decoded_data_hmm = decoded_data_hmm(2:end,:);
state_num = max(unique(decoded_data_hmm));
num_states_subject = state_num;

files_in_filepath = dir(filepath);
files_in_filepath = {files_in_filepath.name}';

%% RSLDS Section

rslds_check = files_in_filepath(cellfun(@(x) contains(x,'rslds'),files_in_filepath));

if contains(rslds_check{1},'rslds')
    decoded_data_rslds = readmatrix(...
        strcat(filepath,'decoded_data_rslds.csv')...
        ) + 1;
    decoded_data_rslds = decoded_data_rslds(2:end,:);
    %     ll_rslds = readmatrix(...
    %         [filepath 'rslds_likelihood.csv']...
    %         );
    %     ll_rslds = ll_rslds(2:end,:);
end
[decoded_data_rslds] = censor_and_threshold_HMM_states(decoded_data_rslds);

%%
ll_files = files_in_filepath(cellfun(@(x) contains(x,'select_ll'),files_in_filepath));

select_ll = [];
file_count = 1;
if length(ll_files) == 1
    select_ll_temp = readmatrix(...
        [filepath ll_files{1}]...
        );
    select_ll = select_ll_temp(2:end);
else
    for iFile = 1:length(ll_files)
        if strcmp('select_ll.csv',ll_files{iFile})
        else
            select_ll_temp = readmatrix(...
                [filepath ll_files{iFile}]...
                );
            select_ll(file_count,:) = select_ll_temp(2:end);
            file_count = file_count + 1;
        end
    end
end
% state_range = readmatrix(...
%     [filepath 'num_states.csv']...
%     );
% state_range = state_range(2:end);

[decoded_data_hmm] = censor_and_threshold_HMM_states(decoded_data_hmm);
% Each row is a different state number (going from 2 to 25, I guess). each
% column is a 50ms bin. every 90 bins is a new trial

trial_classification = (readmatrix(...
    strcat(filepath,'trial_classifiction.csv')...
    ,'FileType','text','OutputType','char','Delimiter',','));
trial_classification_catted = {};
for iTrial = 1:size(trial_classification,1)
    trial_classification_catted{iTrial,1} = strrep(trial_classification{iTrial,:},' ','');
end

trial_classification = trial_classification_catted;

%%

meta.optimal_number_of_states = state_num;
if contains(filepath,'RS') || contains(filepath,'RJ') || contains(filepath, 'Bx')
    if contains(filepath,'RS') && contains(filepath,'RTP')
        load(strcat(filepath,'..\RS_RTP.mat'))
        meta.subject = 'RS';
        meta.task = 'RTP';
        meta.session = '1050211';
        meta.move_only = 0;

    elseif contains(filepath,'RS') && contains(filepath,'CO')
        if contains(filepath,'move')
            load(strcat(strrep(filepath,strcat(num2str(num_desired_states),"_states_",num2str(num_desired_dims),"_dims\"),''),'RSCO_move_window.mat'))
            meta.move_only = 1;
        else
            load([filepath '\RSCO.mat'])
        end
        meta.subject = 'RS';
        meta.task = 'CO';
    elseif contains(filepath,'RJ')
        load(strcat(filepath,'..\','RJRTP.mat'))
        meta.subject = 'RJ';
        meta.task = 'RTP';
        meta.move_only = 0;
        meta.session = '1031206';
    elseif contains(filepath, 'Bxcenter_out_and_RTP1902280.05sBins')
        load(['..\' filepath 'Bxcenter_out_and_RTP190228CT0.mat']);
        meta.subject = 'Bx';
        meta.task = 'CO+RTP';
        meta.move_only = 0;
        meta.filepath = filepath;
        meta.analyze_all_trials = analyze_all_trials;
        bin_size = meta.bin_size;
    elseif contains(filepath, 'Bx') || contains(filepath,'center_out')
        if contains(filepath,'Bx18')
            load(strcat(filepath,'..\','Bxcenter_out180323CT0.mat'))
            meta.task = 'CO';
        elseif contains(filepath,'BxRTP0.05sBins')
            load(strcat(filepath,'..\','\BxRTP190228CT0.mat'))
            meta.task = 'RTP';
        elseif contains(filepath,'190228')
            load(['..\' filepath '\Bxcenter_out190228CT0.mat'])
            meta.task = 'CO';
        end
        meta.filepath = filepath;
        meta.analyze_all_trials = analyze_all_trials;
        meta.subject = 'Bx';
        bin_size = meta.bin_size;
        if contains(filepath, 'move_window')
            meta.move_only = 1;
        else
            meta.move_only = 0;
        end
    end

    if size(decoded_data_hmm,2) == 1
        state_range = state_num;
    end
    meta.optimal_number_of_states = state_num;
    meta.num_dims = num_desired_dims;
    meta.trials_to_plot = 1:10;
    meta.crosstrain = 0;
    meta.use_rslds = use_rslds;
    meta.plot_ll_rslds = plot_ll_rslds;
    meta.analyze_all_trials = analyze_all_trials;
    meta.filepath = filepath;
    %%
    if use_rslds == 1
        decoded_data_selected_state_num = decoded_data_rslds;
    else
        decoded_data_selected_state_num = decoded_data_hmm;
    end

    for iTrial = 1:size(trial_classification,1)
        data(iTrial).trial_classification = trial_classification{iTrial};
        data(iTrial).ms_relative_to_trial_start = 1:length(data(iTrial).x_smoothed);
        decoded_trial_temp = decoded_data_selected_state_num(iTrial,~isnan(decoded_data_selected_state_num(iTrial,:)));
        decoded_trial_temp_resamp = [];
        %       decoded_trial_temp_resamp = nan(1,length(data(iTrial).kinematic_timestamps));
        if (meta.move_only == 1) && strcmp(meta.subject,'bx')
        else
            for iBin = 1:(length(decoded_trial_temp))
                if iBin == 1
                    resamp_range = 1:(bin_size*1000);
                else
                    resamp_range = ((iBin-1)*(bin_size*1000)+1) : ((iBin)*(bin_size*1000));
                end
                decoded_trial_temp_resamp(resamp_range) = decoded_trial_temp(iBin);
            end
        end
        if length(data(iTrial).kinematic_timestamps) < length(decoded_trial_temp_resamp)
            decoded_trial_temp_resamp = decoded_trial_temp_resamp(1:length(data(iTrial).kinematic_timestamps));
        elseif length(data(iTrial).kinematic_timestamps) > length(decoded_trial_temp_resamp)
            decoded_trial_temp_resamp = [decoded_trial_temp_resamp repmat(decoded_trial_temp_resamp(end),1,(length(data(iTrial).kinematic_timestamps) - length(decoded_trial_temp_resamp)))];
        end
        data(iTrial).states_resamp = decoded_trial_temp_resamp;
        data(iTrial).states_noresamp = decoded_trial_temp;
    end

    %% Bringing in Continuous State Values
    if use_rslds == 1
        if contains(meta.session,"180323")
        else
            continuous_state_files = files_in_filepath(cellfun(@(x) contains(x,'continuous_states_trial_'),files_in_filepath));
            if ~isempty(continuous_state_files)
                for iTrial = 1:size(data,2)
                    file = readmatrix(strcat(filepath,'continuous_states_trial_',num2str(iTrial),'.csv'));
                    data(iTrial).continuous_states = file;
                end
            end
        end
    end

    % elseif contains(filepath,'180323')
end % subject selection and dataset filtering
