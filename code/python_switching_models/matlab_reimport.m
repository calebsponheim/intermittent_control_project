%% Import Data from Python and integrate into matlab struct.
% filepath = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\Bxcenter_out1902280.05_sBins_move_window_only\';
% filepath = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\Bxcenter_out1902280.05sBins\';
filepath = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\Bxcenter_out_and_RTP1902280.05sBins\';
move_window = 0;
state_num = 8;


decoded_data = readmatrix(...
    [filepath 'decoded_test_data.csv']...
    );

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
    if size(decoded_data,1) == 1
        for iTrial = 1:size(trial_classification,1)
            data(iTrial).trial_classification = trial_classification{iTrial};
            if move_window == 1
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
                    decoded_trial_temp = decoded_data(1,1:length_of_original_data(iTrial)) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
                else
                    decoded_trial_temp = decoded_data(1,((sum(length_of_original_data(1:iTrial-1)):(sum(length_of_original_data(1:iTrial)))))) + 1;
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
                % Current project: reconstruct the 1k sample rate state
                % decode, but with the correct length (4500 ms) 100% of the
                % time.
                
                
                %                 for iBin = 1:(length(decoded_trial_temp))
                %                     if iBin == 1
                %                         resamp_range = 1:(meta.bin_size*1000);
                %                     else
                %                         resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
                %                     end
                %
                %                     data(iTrial).states_resamp(resamp_range) = decoded_trial_temp(iBin);
                %                 end
            elseif move_window == 0
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
        
    else
        for iTrial = 1:size(trial_classification,1)
            data(iTrial).trial_classification = trial_classification{iTrial};
            if iTrial == 1
                decoded_trial_temp = decoded_data(state_num-1,1:90) + 1; %adding 1 because python data is zero indexed, so state "0" in python is really state "1" in matlab
            else
                decoded_trial_temp = decoded_data(state_num-1,(((iTrial-1)*90):((iTrial*90)-1))) + 1;
            end
            
            for iBin = 1:(length(decoded_trial_temp))
                if iBin == 1
                    resamp_range = 1:(meta.bin_size*1000);
                else
                    resamp_range = ((iBin-1)*(meta.bin_size*1000)+1) : ((iBin)*(meta.bin_size*1000));
                end
                
                data(iTrial).states_resamp(resamp_range) = decoded_trial_temp(iBin);
            end
        end
    end
elseif contains(filepath,'RS')
    load([filepath '\RS_HMM_analysis_for_python8_states_22-Apr-2021.mat'])
    num_states_subject = 11;
    state_num = num_states_subject;
    test_trial_count = 1;
    for iTrial = 1:size(data,2)
        if iTrial == 1
            trial_bin_range(1,1:2) = [1,size(data(iTrial).spikecount,2)];
        else
            trial_bin_range(iTrial,1:2) = [trial_bin_range(iTrial-1,2)+1, (trial_bin_range(iTrial-1,1)+1)+size(data(iTrial).spikecount,2)];
        end
    end
    
    for iTrial = 1:size(trial_classification,1)
        data(iTrial).trial_classification = trial_classification{iTrial};
        decoded_trial_temp = decoded_data(state_num-1,trial_bin_range(iTrial)) + 1;
        
        for iBin = 1:(length(decoded_trial_temp))
            if iBin == 1
                resamp_range = 1:(bin_size*1000);
            else
                resamp_range = ((iBin-1)*(bin_size*1000)+1) : ((iBin)*(9*1000));
            end
            
            data(iTrial).states_resamp(resamp_range) = decoded_trial_temp(iBin);
        end
    end
    
elseif contains(filepath,'180323')
end