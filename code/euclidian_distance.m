%% Calculating Euclidian Distance Between Neural Bins.


% load data, specific variables.

% State Bin Size
bin_size = 50; %ms

% Define Window Size
window_size = 50; %ms

%comparison bin
base_bin = 1;

%normalize spike counts?
normalize_spike_counts = 1;

num_bins_in_window = window_size/bin_size;

for iTrial = 1:size(data,2)% For Each Trial
    num_bins = size(data(iTrial).spikecount,2);
    for iTimestep = 1:(num_bins - num_bins_in_window)%For Each TimeStep, up till final_timestep - Window Size
        
        if normalize_spike_counts == 0
            neural_distance(iTrial).pt_one(:,iTimestep) = data(iTrial).spikecount(:,iTimestep);
            neural_distance(iTrial).pt_two(:,iTimestep) = data(iTrial).spikecount(:,iTimestep + num_bins_in_window);
        elseif normalize_spike_counts == 1
            peak_fr_pop = max(data(iTrial).spikecount,[],2);
            neural_distance(iTrial).pt_one(:,iTimestep) = data(iTrial).spikecount(:,iTimestep)./peak_fr_pop;
            
            neural_distance(iTrial).pt_one(isnan(neural_distance(iTrial).pt_one(:,iTimestep)),iTimestep) = 0;
            
            neural_distance(iTrial).pt_two(:,iTimestep) = data(iTrial).spikecount(:,iTimestep + num_bins_in_window)./peak_fr_pop;
            
            neural_distance(iTrial).pt_two(isnan(neural_distance(iTrial).pt_two(:,iTimestep)),iTimestep) = 0;
            
        end
        %calculate distance, store in data.distance
        neural_distance(iTrial).distance(iTimestep) = norm(neural_distance(iTrial).pt_one(:,iTimestep) - neural_distance(iTrial).pt_two(:,iTimestep));
        
        %calculate distance from fixed point (first bin)
        neural_distance(iTrial).distance_from_baseline(iTimestep) = norm(neural_distance(iTrial).pt_one(:,base_bin) - neural_distance(iTrial).pt_two(:,iTimestep));
        
        % Calculating cosine of the angle
        neural_distance(iTrial).angle(iTimestep) = dot(neural_distance(iTrial).pt_one(:,iTimestep),neural_distance(iTrial).pt_two(:,iTimestep))/(norm(neural_distance(iTrial).pt_one) * norm(neural_distance(iTrial).pt_two));
        
    end %iTimestep
end %iTrial

%% Figure out how to plot these distances in time with kinematics!

% Make Plot

for iTrial = 1:size(neural_distance,2)
    speed_temp = data(iTrial).speed/max(data(iTrial).speed);
    acc_temp = data(iTrial).acceleration/max(data(iTrial).acceleration);
    dist_temp = neural_distance(iTrial).distance/max(neural_distance(iTrial).distance);
    dist_from_base_temp = neural_distance(iTrial).distance_from_baseline/max(neural_distance(iTrial).distance_from_baseline);
    angle_temp = neural_distance(iTrial).angle/max(neural_distance(iTrial).angle);
    
    figure('visible','off');hold on
    plot(data(iTrial).kinematic_timestamps,speed_temp,'LineWidth',2);
    plot(data(iTrial).kinematic_timestamps,acc_temp,'LineWidth',2);
    plot(bin_timestamps{iTrial}(1:size(neural_distance(iTrial).distance,2))+.10,dist_temp,'LineWidth',2);
    plot(bin_timestamps{iTrial}(1:size(neural_distance(iTrial).distance,2))+.10,dist_from_base_temp,'LineWidth',2);
    plot(bin_timestamps{iTrial}(1:size(neural_distance(iTrial).distance,2))+.10,angle_temp,'LineWidth',2);
    xlim([bin_timestamps{iTrial}(1) bin_timestamps{iTrial}(size(neural_distance(iTrial).distance,2))+ window_size*.001])
    legend({'speed','acceleration','euc dist','euc dist from baseline','cosine of angle'},'Location','southwest')
    xlabel('time (seconds)')
    ylabel('normalized magnitude');
    
    if normalize_spike_counts == 1
        if strcmp(task,'center_out')
            title([subject ' ' session ' center out ' num2str(window_size) 'ms difference, normalized spikes, trial' num2str(iTrial)]);
        else
            title([subject ' ' session task num2str(window_size) 'ms difference, normalized spikes, trial' num2str(iTrial)]);
        end
    else
        if strcmp(task,'center_out')
            title([subject ' ' session ' center out ' num2str(window_size) 'ms difference trial' num2str(iTrial)]);
        else
            title([subject ' ' session task num2str(window_size) 'ms difference trial' num2str(iTrial)]);
        end
    end
    
    hold off
    box off
    set(gcf,'Color','White');
    
    if normalize_spike_counts == 1
        saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,'trial',num2str(iTrial),'normalized_spikes','.png'))
    else
        saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,'trial',num2str(iTrial),'.png'))
    end
    close(gcf)
end %iTrial


