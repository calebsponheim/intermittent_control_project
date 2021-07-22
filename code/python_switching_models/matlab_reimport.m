%% Import Data from Python and integrate into matlab struct.
filepath = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\Bxcenter_out1902280.05sBins\';
move_window = 0;


decoded_data = readmatrix(...
    [filepath 'decoded_test_data.csv']...
    );

% Each row is a different state number (going from 2 to 25, I guess). each
% column is a 50ms bin. every 90 bins is a new trial

trial_classification = (readmatrix(...
    [filepath 'trial_classifiction.csv']...
    ,'FileType','text','OutputType','char','Delimiter',' '));
trial_classification_catted = {};
for iTrial = 1:size(trial_classification,1)
    trial_classification_catted{iTrial,1} = strcat(trial_classification{iTrial,:});
end

trial_classification = trial_classification_catted;

%%

if contains(filepath,'190228')
    load([filepath '\Bxcenter_out190228CT0.mat'])
    state_num = 8;
    meta.optimal_number_of_states = state_num;
    test_trial_count = 1;
    
    for iTrial = 1:size(data,2)
        if iTrial == 1
            if move_window == 1
                trial_bin_range(1,1:2) = [1,size(data(iTrial).spikecount,2)];
            else
                trial_bin_range(1,1:2) = [1,size(data(iTrial).spikecount,2)];
            end
        else
            trial_bin_range(iTrial,1:2) = [trial_bin_range(iTrial-1,2)+1, (trial_bin_range(iTrial-1,1)+1)+size(data(iTrial).spikecount,2)];
        end
    end
    
    
    for iTrial = 1:size(trial_classification,1)
        data(iTrial).trial_classification = trial_classification{iTrial};
        if test_trial_count == 1
            decoded_trial_temp = decoded_data(state_num-1,1:90) + 1;
            test_trial_count = test_trial_count + 1;
        else
            decoded_trial_temp = decoded_data(state_num-1,(((test_trial_count-1)*90):((test_trial_count*90)-1))) + 1;
            test_trial_count = test_trial_count + 1;
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