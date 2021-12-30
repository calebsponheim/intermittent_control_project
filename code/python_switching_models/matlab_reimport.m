%% Import Data from Python and integrate into matlab struct.

% file_base_base = 'C:\Users\calebsponheim';
file_base_base = 'C:\Users\Caleb (Work)';
filepath_base = [file_base_base '\Documents\git\intermittent_control_project\data\python_switching_models\'];
figure_base = [file_base_base '\Documents\git\intermittent_control_project\figures\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05_sBins_move_window_only\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out_and_RTP1902280.05sBins\'];
% filepath = [filepath_base 'RSCO0.05sBins\'];
filepath = [filepath_base 'RSCO_move_window0.05sBins\'];
% filepath = [filepath_base 'RSRTP0.05sBins\'];
% filepath = [filepath_base 'RJRTP0.05sBins\'];

state_num = 11;
num_states_subject = state_num;
meta.analyze_all_trials = 1;
plot_ll = 0;
use_rslds = 1;
% 
% decoded_data = readmatrix(...
%     [filepath 'decoded_data_hmm.csv']...
%     ) + 1;

files_in_filepath = dir(filepath);
files_in_filepath = {files_in_filepath.name}';

%% RSLDS Section

rslds_check = files_in_filepath(cellfun(@(x) contains(x,'rslds'),files_in_filepath));

if contains(rslds_check{1},'rslds')
    decoded_data_rslds = readmatrix(...
        [filepath 'decoded_data_rslds.csv']...
        )' + 1;
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
state_range = readmatrix(...
    [filepath 'num_states.csv']...
    );
state_range = state_range(2:end);

[decoded_data] = censor_and_threshold_HMM_states(decoded_data);
% Each row is a different state number (going from 2 to 25, I guess). each
% column is a 50ms bin. every 90 bins is a new trial

trial_classification = (readmatrix(...
    [filepath 'trial_classifiction.csv']...
    ,'FileType','text','OutputType','char','Delimiter',','));
trial_classification_catted = {};
for iTrial = 1:size(trial_classification,1)
    trial_classification_catted{iTrial,1} = strrep(trial_classification{iTrial,:},' ','');
end

trial_classification = trial_classification_catted;

%%

if contains(filepath,'190228')
    if contains(filepath, 'Bxcenter_out_and_RTP1902280.05sBins')
        load([filepath 'Bxcenter_out_and_RTP190228CT0.mat']);
    else
        load([filepath '\Bxcenter_out190228CT0.mat'])
    end
    meta.optimal_number_of_states = state_num;
    %     if size(decoded_data,1) == 1
    for iTrial = 1:size(trial_classification,1)
        data(iTrial).trial_classification = trial_classification{iTrial};
        if contains(filepath,'move_window')
            length_of_original_resampled_data = ...
                length(data(iTrial).spikecountresamp(...
                :,int64(data(iTrial).move_relative_to_trial_start)...
                :int64(data(iTrial).target_reach_relative_to_trial_start)));
            
            length_of_original_resampled_prewindow = ...
                length(data(iTrial).spikecountresamp(...
                :,1:int64(data(iTrial).move_relative_to_trial_start))) - 1;
            
            length_of_original_resampled_postwindow = ...
                length(data(iTrial).spikecountresamp(...
                :,int64(data(iTrial).target_reach_relative_to_trial_start):end)) - 1;
            
            length_of_trial(iTrial) = length_of_original_resampled_data + length_of_original_resampled_prewindow + length_of_original_resampled_postwindow;
            
            length_of_original_data(iTrial) = round(length_of_original_resampled_data/(meta.bin_size*1000));
            
            if iTrial == 1
                decoded_trial_temp = decoded_data(state_range == state_num,1:length_of_original_data(iTrial)) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
            else
                decoded_trial_temp = decoded_data(state_range == state_num,((sum(length_of_original_data(1:iTrial-1)):(sum(length_of_original_data(1:iTrial)))))) + 1;
                %                     decoded_trial_temp = [zeros(1,length_of_original_prewindow(iTrial)) actual_states zeros(1,length_of_original_postwindow(iTrial))];
            end
            
            decoded_trial_temp_resamp = zeros(1,length(length_of_original_resampled_data));
            
            for iBin = 1:(length(decoded_trial_temp))
                if iBin == 1
                    resamp_range = 1:(meta.bin_size*1000);
                else
                    resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
                end
                
                decoded_trial_temp_resamp(resamp_range) = decoded_trial_temp(iBin);
            end
            if length_of_original_resampled_data < length(decoded_trial_temp_resamp)
                decoded_trial_temp_resamp = decoded_trial_temp_resamp(1:length_of_original_resampled_data);
                %                     disp('sound the alarm')
            elseif length_of_original_resampled_data > length(decoded_trial_temp_resamp)
                decoded_trial_temp_resamp = [decoded_trial_temp_resamp repmat(decoded_trial_temp_resamp(end),1,(length_of_original_resampled_data - length(decoded_trial_temp_resamp)))];
            end
            
            data(iTrial).states_resamp = [zeros(1,length_of_original_resampled_prewindow) decoded_trial_temp_resamp zeros(1,length_of_original_resampled_postwindow)];
        else
            if contains(filepath,'Bxcenter_out1902280')
                if iTrial == 1
                    decoded_trial_temp = decoded_data(1,1:90) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
                else
                    decoded_trial_temp = decoded_data(1,(((iTrial-1)*90):((iTrial*90)-1))) + 1;
                end
                
                for iBin = 1:(length(decoded_trial_temp))
                    if iBin == 1
                        resamp_range = 1:(meta.bin_size*1000);
                    else
                        resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
                    end
                    
                    data(iTrial).states_resamp(resamp_range) = decoded_trial_temp(iBin);
                end
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % THIS IS FOR FULL TRIAL TASK-NEUTRAL DATA
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                length_of_original_resampled_data = length(data(iTrial).spikecountresamp);
                length_of_trial(iTrial) = length_of_original_resampled_data;
                length_of_original_data(iTrial) = round(length_of_original_resampled_data/(meta.bin_size*1000));
                
                if iTrial == 1
                    decoded_trial_temp = decoded_data(1,1:length_of_original_data(iTrial)) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
                else
                    decoded_trial_temp = decoded_data(1,((sum(length_of_original_data(1:iTrial-1)):(sum(length_of_original_data(1:iTrial)))))) + 1;
                end
                decoded_trial_temp_resamp = zeros(1,length(length_of_original_resampled_data));
                
                for iBin = 1:(length(decoded_trial_temp))
                    if iBin == 1
                        resamp_range = 1:(meta.bin_size*1000);
                    else
                        resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
                    end
                    
                    decoded_trial_temp_resamp(resamp_range) = decoded_trial_temp(iBin);
                end
                if length_of_original_resampled_data < length(decoded_trial_temp_resamp)
                    decoded_trial_temp_resamp = decoded_trial_temp_resamp(1:length_of_original_resampled_data);
                elseif length_of_original_resampled_data > length(decoded_trial_temp_resamp)
                    decoded_trial_temp_resamp = [decoded_trial_temp_resamp repmat(decoded_trial_temp_resamp(end),1,(length_of_original_resampled_data - length(decoded_trial_temp_resamp)))];
                end
                data(iTrial).states_resamp = decoded_trial_temp_resamp;
            end
        end
        
    end
    
    %     else
    %         for iTrial = 1:size(trial_classification,1)
    %             data(iTrial).trial_classification = trial_classification{iTrial};
    %             if iTrial == 1
    %                 decoded_trial_temp = decoded_data(state_num-1,1:90) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
    %             else
    %                 decoded_trial_temp = decoded_data(state_num-1,(((iTrial-1)*90):((iTrial*90)-1))) + 1;
    %             end
    %
    %             for iBin = 1:(length(decoded_trial_temp))
    %                 if iBin == 1
    %                     resamp_range = 1:(meta.bin_size*1000);
    %                 else
    %                     resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
    %                 end
    %
    %                 data(iTrial).states_resamp(resamp_range) = decoded_trial_temp(iBin);
    %             end
    %         end
    %     end
elseif contains(filepath,'RS') || contains(filepath,'RJ')
    if contains(filepath,'RS') && contains(filepath,'RTP')
        load([filepath '\RS_RTP.mat'])
        meta.subject = 'RS';
        meta.task = 'RTP';
        meta.move_only = 0;
    elseif contains(filepath,'RS') && contains(filepath,'CO')
        if contains(filepath,'move')
            load([filepath '\RSCO_move_window.mat'])
            meta.move_only = 1;
        else
            load([filepath '\RSCO.mat'])
        end
        meta.subject = 'RS';
        meta.task = 'CO';
    elseif contains(filepath,'RJ')
        load([filepath '\RJRTP.mat'])
        meta.subject = 'RJ';
        meta.task = 'RTP';
        meta.move_only = 0;   
    end
    
    if size(decoded_data,2) == 1
        state_range = state_num;
    end
    meta.optimal_number_of_states = state_num;
    meta.trials_to_plot = 1:25;
    meta.crosstrain = 0;
    meta.use_rslds = use_rslds;
    if plot_ll == 1
        % Plotting LL
        if length(ll_files) == 1
            figure('visible','off'); hold on
            curve_exp = fit(state_range,select_ll,'exp2');
            figure('visible','off'); hold on
            plot(state_range,curve_exp(state_range))
            plot(state_range,select_ll,'k.')
            title([meta.subject,meta.task,' LL curve fit'])
            legend('Location','southeast')
            if meta.move_only == 1
                meta.figure_folder_filepath = [figure_base meta.subject '\' meta.task '_CT0_move_only\'];
            else
                meta.figure_folder_filepath = [figure_base meta.subject '\' meta.task '_CT0\'];
            end
            saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'_LL_curve_fit.png'));
        else
            state_range_for_fit = repmat(state_range,[size(select_ll,1) 1]);
            state_range_for_diff_fit = repmat(state_range(2:end),[size(select_ll,1) 1]);

            % Plotting LL curves according to Baseline
            select_ll_for_plotting = [];
            select_ll_diff_for_plotting = [];
            for iIter = 1:size(select_ll,1)
                select_ll_for_plotting(iIter,:) = select_ll(iIter,:) - select_ll(iIter,1);
                for iState = 2:size(select_ll,2)
                        select_ll_diff_for_plotting(iIter,iState-1) = select_ll(iIter,iState) - select_ll(iIter,iState - 1);
                end
            end

            select_ll_for_plotting = reshape(select_ll_for_plotting',[size(select_ll_for_plotting,1)*size(select_ll_for_plotting,2) 1]);
            select_ll_diff_for_plotting_reshaped = reshape(select_ll_diff_for_plotting',[size(select_ll_diff_for_plotting,1)*size(select_ll_diff_for_plotting,2) 1]);
            curve_exp = fit(state_range_for_fit,select_ll_for_plotting,'exp2');
            curve_exp_diff = fit(state_range_for_diff_fit,zscore(select_ll_diff_for_plotting_reshaped),'exp2');

            figure('visible','off'); hold on
            plot(state_range(2:end),zscore(mean(select_ll_diff_for_plotting)),'bo')
            plot(state_range(2:end),zscore(select_ll_diff_for_plotting'),'k.')

            state_range_for_optimal = state_range(2:end);
            zscore_above_zero = state_range_for_optimal(zscore(mean(select_ll_diff_for_plotting)) > 0);
            optimal_state_number = zscore_above_zero(end);
            xline(optimal_state_number);
            plot(state_range_for_diff_fit,curve_exp_diff(state_range_for_diff_fit),'r.','markersize',10)
            title([meta.subject,meta.task,' LL curve fit diff'])
            xlabel('Hidden State Number')
            ylabel('Log Likelihood Difference')
            box off
            set(gcf,'color','white')

            if meta.move_only == 1
                meta.figure_folder_filepath = [figure_base meta.subject '\' meta.task '_CT0_move_only\'];
            else
                meta.figure_folder_filepath = [figure_base meta.subject '\' meta.task '_CT0\'];
            end
            saveas(gcf,strcat(meta.figure_folder_filepath,'\',meta.subject,meta.task,'_LL_curve_fit_diff.png'));

        end % multi-fold LL versus single-fold LL
    end % plot_ll
    
    
    trial_bin_range = zeros(size(data(iTrial),2),2);
    for iTrial = 1:size(data,2)
        if iTrial == 1
            trial_bin_range(1,1:2) = [1,size(data(iTrial).spikecount,2)];
        else
            trial_bin_range(iTrial,1:2) = [trial_bin_range(iTrial-1,2)+1, (trial_bin_range(iTrial-1,2))+size(data(iTrial).spikecount,2)];
        end
    end
    
    
    if use_rslds == 1
        decoded_data = decoded_data_rslds;
        decoded_data_selected_state_num = decoded_data;
    else
        decoded_data_selected_state_num = decoded_data(end,:);
    end
    

    
    for iTrial = 1:size(trial_classification,1)
        data(iTrial).trial_classification = trial_classification{iTrial};
        data(iTrial).ms_relative_to_trial_start = 1:length(data(iTrial).x_smoothed);
        decoded_trial_temp = decoded_data_selected_state_num(1,trial_bin_range(iTrial,1):trial_bin_range(iTrial,2));
        decoded_trial_temp_resamp = zeros(1,length(data(iTrial).kinematic_timestamps));
        for iBin = 1:(length(decoded_trial_temp))
            if iBin == 1
                resamp_range = 1:(bin_size*1000);
            else
                resamp_range = ((iBin-1)*(bin_size*1000)+1) : ((iBin)*(bin_size*1000));
            end
            
            decoded_trial_temp_resamp(resamp_range) = decoded_trial_temp(iBin);
        end
        if length(data(iTrial).kinematic_timestamps) < length(decoded_trial_temp_resamp)
            decoded_trial_temp_resamp = decoded_trial_temp_resamp(1:length(data(iTrial).kinematic_timestamps));
        elseif length(data(iTrial).kinematic_timestamps) > length(decoded_trial_temp_resamp)
            decoded_trial_temp_resamp = [decoded_trial_temp_resamp repmat(decoded_trial_temp_resamp(end),1,(length(data(iTrial).kinematic_timestamps) - length(decoded_trial_temp_resamp)))];
        end
        data(iTrial).states_resamp = decoded_trial_temp_resamp;
        
    end   
elseif contains(filepath,'180323')
end % subject selection and dataset filtering
