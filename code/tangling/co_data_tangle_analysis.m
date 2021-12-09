%% Transform center_out data into trial-averaged firing rates for trajectory tangling analysis.

% From The Demo:

% Data should be formatted as for jPCA. Each data structure (e.g. D_m1,
% located in M1_sampleData.mat) contains C elements corresponding to the
% number of conditions (here, 2). The t x n matrix 'A' contains the
% trial-averaged firing rates as a function of time for each neuron. All
% other fields are optional. The 'times' field indicates the time course of
% each sample in A and the 'analyzeTimes' field indicates which of these
% times should be analyzed for tangling.

%% Collect 1ms - bin un-averaged trial data, aligned on movement
clear
%%%%%%%% User-defined Variables %%%%%%%%%%%%%%%
subject = 'Bx'; % Subject

if strcmp(subject,'Bx')
    meta.subject = 'Bx'; % Subject
    meta.arrays = {'M1m';'M1l'}; % Which M1 Arrays to analyze
    meta.session = '190228'; % Which day of data
    meta.task = 'center_out';       % Choose one of the three options here
    % meta.task = 'RTP';              % Choose one of the three options here
    % meta.task = 'center_out_and_RTP'; % Choose one of the three options here
    
    meta.bin_size = .001; %seconds
    meta.muscle_lag = 0.100; %seconds
    meta.center_out_trial_window = ''; % If center-out, what event to bound analysis window? (can be 'go' or 'move' or ' ')
    
    % in "events" ; this is the window that the HMM will actually analyze, inside of the bigger center-out window.
    %     meta.CO_HMM_analysis_window = {'move','reward'}; % TIMING IS RELATIVE TO "TRIAL START". THIS IS USUALLY -1000ms FROM PERION
    
    if ispc
        meta.subject_filepath_base = ...
            ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2019\' meta.session '\'];
    elseif ismac
        meta.subject_filepath_base = ...
            ['/Volumes/nicho-lab/Data/all_raw_datafiles_7/Breaux/2019/' meta.session '/'];
    end
    
    meta.subject_events = [meta.subject_filepath_base 'Bx' meta.session 'x_events'];
    meta.bad_trials = [];
    meta.spike_hz_threshold = 0; % Minimum required FR for units
    
    if strcmp(meta.task,'RTP')
        meta.subject_filepath = ...
            cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_RTP_units'] ,meta.arrays,'UniformOutput',0);
        meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
        meta.trial_event_cutoff = ''; % supersedes trial_length if active
    elseif strcmp(meta.task,'center_out')
        meta.subject_filepath = ...
            cellfun(@(x) [meta.subject_filepath_base 'Bx' meta.session x '_CO_units'] ,meta.arrays,'UniformOutput',0);
        meta.trial_length = [-1 3.5]; %seconds. defaults is [-1 4];
        meta.trial_event_cutoff = meta.center_out_trial_window; % supersedes trial_length if active
    end
    
    [data,meta.targets] = CS_spiketimes_to_bins_v2(meta);
    [data] = process_kinematics_v2(meta,data);
    
    meta.target_locations = {'N','NE','E','SE','S','SW','W','NW'};
elseif strcmp(subject,'RS')
    subject_filepath = '\\prfs.cri.uchicago.edu\nicho-lab\nicho\ANALYSIS\rs1050211\rs1050211_clean_spikes_SNRgt4';
    task = 'CO';
    meta.task = task;
    bin_size = .002; %seconds
    bad_trials = [2;92;151;167;180;212;244;256;325;415;457;508;571;662;686;748];
    
    % Scripts to run:
    
    %% Structure Spiking Data
    [data,cpl_st_trial_rew,bin_timestamps] = nicho_data_to_organized_spiketimes_for_HMM(subject_filepath,bad_trials,task,bin_size);
    load(subject_filepath,'x','y');
    
    %% bidirectionally filter x and y traces separately
    
    sampling_rate = 500;
    
    dt=1/sampling_rate; % defining timestep size
    fN=sampling_rate/2;
    
    fc = 6;
    fs = sampling_rate;
    
    [b,a] = butter(6,fc/(fs/2));
    
    filt_lowpass_x = filtfilt(b,a,x(:,2)); % running lowpass filter.
    filt_lowpass_y = filtfilt(b,a,y(:,2)); % running lowpass filter.
    
    %% calculate speed/velocity/acceleration
    
    x_speed = diff(filt_lowpass_x);
    y_speed = diff(filt_lowpass_y);
    
    % velocity
    velocity = sqrt(x_speed.^2 + y_speed.^2);
    
    % Acceleration
    acceleration = diff(velocity);
    
    %% segment position and speed vectors into trials
    
    % for each trial
    for iTrial = 1:size(cpl_st_trial_rew,1)
        data(iTrial).x_smoothed = filt_lowpass_x(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        %Note: Hacky hack here: there is , for some reason, a difference with this line, causing each trial of y_smoothed to be al ittle
        %longer than the x. Idk why this is; it's the same code.
        %data(iTrial).y_smoothed = filt_lowpass_y(y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        data(iTrial).y_smoothed = filt_lowpass_y(x(:,1) >= (cpl_st_trial_rew(iTrial,1)) & x(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        data(iTrial).speed = velocity(y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2)));
        data(iTrial).kinematic_timestamps = x((y(:,1) >= (cpl_st_trial_rew(iTrial,1)) & y(:,1) <= (cpl_st_trial_rew(iTrial,2))),1);
    end
    
end

%% save real quick
if strcmp(subject,'RJ')
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\tangling\' subject task '_1ms_struct_for_tangling'],'-v7.3')
    end
elseif strcmp(subject,'Bx')
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\tangling\' meta.subject meta.task meta.session '_1ms_struct_for_tangling'], 'meta', 'data','-v7.3')
    end
elseif strcmp(subject,'RS')
    if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
        save(['C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\tangling\' subject task '_1ms_struct_for_tangling'],'-v7.3')
    end
end
%% find velocity peaks, and crop around them
kernel_size = 100; %ms
align = 'move';

if strcmp(meta.task,'center_out') || strcmp(meta.task,'CO')
    if strcmp(align,'vel')
        crop_window = [-300 299];
        data_aligned = align_to_velocity_peak_and_crop(data,crop_window,subject);
        data_aligned_and_smoothed = gaussian_filt(data_aligned,kernel_size);
    elseif strcmp(align,'move')
        crop_window = [-100 699];
        data_aligned = align_to_movement_and_crop(data,crop_window);
        data_aligned_and_smoothed = gaussian_filt(data_aligned,kernel_size);
    end
end

%% Soft Normalize
normalize = 0;

if normalize == 1
    for iTrial = 1:size(data_aligned_and_smoothed,2)
        for iUnit = 1:size(data_aligned_and_smoothed(iTrial).spikecountresamp,1)
            if sum(data_aligned_and_smoothed(iTrial).spikecountresamp(iUnit,:)) > 0
                smoothed_spikes = data_aligned_and_smoothed(iTrial).spikecountresamp(iUnit,:);
                normalized_unit = smoothed_spikes ./ max(smoothed_spikes);
                data_aligned_and_smoothed(iTrial).spikecountresamp(iUnit,:) = normalized_unit;
            end
        end
    end
end

%% Crop in by 50ms to avoid edge effects of filtering
data_aligned_and_smoothed_and_cropped = struct();
for iTrial = 1:size(data_aligned_and_smoothed,2)
    for iUnit = 1:size(data_aligned_and_smoothed(iTrial).spikecountresamp,1)
        uncropped = data_aligned_and_smoothed(iTrial).spikecountresamp(iUnit,:);
        cropped = uncropped(50:end-51);
        data_aligned_and_smoothed_and_cropped(iTrial).spikecountresamp(iUnit,:) = cropped;
        
        uncropped = data_aligned(iTrial).speed;
        cropped = uncropped(50:end-51);
        data_aligned_and_smoothed_and_cropped(iTrial).speed = cropped;
    end
end

%% average across trials, but not across units
breakout = 1;
breakouts = {'A','B','C'};
if strcmp(meta.task,'center_out') || strcmp(meta.task,'CO')
    times = data_aligned(1).ms_relative_to_trial_start(50:end-51);
    analyzeTimes = times; %we wanna analyze the whole dang thing, bobby;
    data_to_average = struct();
    for iTP = unique([data.tp])
        data_to_average(iTP). data = zeros(size(data_aligned_and_smoothed_and_cropped(1).spikecountresamp,1),size(data_aligned_and_smoothed_and_cropped(1).spikecountresamp,2),sum([data.tp] == iTP));
    end
    trial_count = zeros(1,numel(unique([data.tp])));
    
    for iTrial = 1:size(data,2)
        trial_count(data(iTrial).tp) = trial_count(data(iTrial).tp) + 1;
        data_to_average(data(iTrial).tp).data(:,:,trial_count(data(iTrial).tp)) = data_aligned_and_smoothed_and_cropped(iTrial).spikecountresamp;
        data_to_average(data(iTrial).tp).speed(:,:,trial_count(data(iTrial).tp)) = data_aligned_and_smoothed_and_cropped(iTrial).speed;
    end %iTrial
    
    D_m1_CO = struct();
    for iTP = unique([data.tp])
        if breakout == 1
            D_m1_CO(iTP).A = mean(data_to_average(iTP).data(:,:,1:round(size(data_to_average(iTP).data,3)/3)),3)';
            D_m1_CO(iTP).B = mean(data_to_average(iTP).data(:,:,round(size(data_to_average(iTP).data,3)/3):round((size(data_to_average(iTP).data,3)/3)*2)),3)';
            D_m1_CO(iTP).C = mean(data_to_average(iTP).data(:,:,round((size(data_to_average(iTP).data,3)/3)*2):size(data_to_average(iTP).data,3)),3)';
        else
            D_m1_CO(iTP).A = mean(data_to_average(iTP).data,3)';
        end
        D_m1_CO(iTP).speed = mean(data_to_average(iTP).speed,3)';
        D_m1_CO(iTP).speed_std_err = (std(data_to_average(iTP).speed,[],3) / sqrt(size(data_to_average(iTP).speed,3)))';
        D_m1_CO(iTP).times = times';
        D_m1_CO(iTP).analyzeTimes = analyzeTimes';
        D_m1_CO(iTP).condition = meta.target_locations{iTP};
    end
elseif strcmp(meta.task,'RTP')
    disp('you have not written code for this condition yet')
end

%% Perform Actual Tangling Analysis
timestep = 2; % sample number
[ Q, out] = tangleAnalysis( D_m1_CO, meta.bin_size,'timeStep',timestep);


%% curvature

% curvature from tangle analysis
% timepoints = 0:length(D_m1_CO(1).A):length(out.X);
%
% for iTP = unique([data.tp])
%     [L{iTP},R{iTP},k{iTP}] = curvature(out.X((timepoints(iTP)+1):timepoints(iTP+1),1:3));
% end

% curvature from individual PCA for each reach:
if breakout == 1
    for iGroup = 1:3
        for iTP = unique([data.tp])
            [PCs{iGroup,iTP}, ~, v{iGroup,iTP}] = pca(D_m1_CO(iTP).(breakouts{iGroup}));
            topPCs{iGroup,iTP} = PCs{iGroup,iTP}(:,1:3);
            X{iGroup,iTP} = D_m1_CO(iTP).(breakouts{iGroup}) * topPCs{iGroup,iTP};
            [L{iGroup,iTP},R{iGroup,iTP},k{iGroup,iTP}] = curvature(X{iGroup,iTP});
        end
    end
else
    for iTP = unique([data.tp])
        [PCs{iTP}, ~, v{iTP}] = pca(D_m1_CO(iTP).A);
        topPCs{iTP} = PCs{iTP}(:,1:3);
        X{iTP} = D_m1_CO(iTP).A * topPCs{iTP};
        [L{iTP},R{iTP},k{iTP}] = curvature(X{iTP});
    end
end

%% Create Plot Figure Results Folder Filepath
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    meta.figure_folder_filepath = ['C:\Users\calebsponheim\Documents\git\intermittent_control_project\figures\' meta.subject '\' meta.task '_Tangling\'];
else
    meta.figure_folder_filepath = ['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\' meta.subject '\' meta.task '_Tangling\'];
end

%% Visualize
colors = hsv(numel(unique([data.tp])));
timepoints = 0:length(D_m1_CO(1).A):length(out.X);
timepoints_q = timepoints/timestep;
Q_for_plotting = (Q/max(Q))*100;
Q_for_plotting(Q_for_plotting == 0) = .0001;
figure('visible','off','color','white');
hold on
for iTP = unique([data.tp])
    scatter3(out.X((timepoints(iTP)+1):timestep:timepoints(iTP+1),1),out.X((timepoints(iTP)+1):timestep:timepoints(iTP+1),2),out.X((timepoints(iTP)+1):timestep:timepoints(iTP+1),3),Q_for_plotting((timepoints_q(iTP)+1):timepoints_q(iTP+1)),colors(iTP,:),'filled');
    scatter3(out.X((timepoints(iTP)+1),1),out.X((timepoints(iTP)+1),2),out.X((timepoints(iTP)+1),3),100,'k','filled');
end

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
view(0,90);
title('Avg Neural Trajectories, center-out. size = tangling')
grid on
hold off;
saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'_PC-traj_with_tangling_aligned_on' align '.png']);
close gcf

%% Plot Tangling
Q_for_plotting = Q;
Q_for_plotting(Q_for_plotting == 0) = .0001;

for iTP = unique([data.tp])
    figure('visible','off','color','white'); hold on
    yyaxis left
    patch([(1:size(D_m1_CO(iTP).speed,1)) flip(1:size(D_m1_CO(iTP).speed,1))],[(D_m1_CO(iTP).speed+D_m1_CO(iTP).speed_std_err)' flip(D_m1_CO(iTP).speed-D_m1_CO(iTP).speed_std_err)'],colors(iTP,:),'edgecolor','none');
    alpha(0.4)
    ylabel('Speed')
    plot(1:size(D_m1_CO(iTP).speed),D_m1_CO(iTP).speed,'color',colors(iTP,:),'linewidth',2);
    yyaxis right
    plot(1:timestep:length(D_m1_CO(iTP).speed),Q_for_plotting((timepoints_q(iTP)+1):timepoints_q(iTP+1)),'-o','color',colors(iTP,:),'linewidth',2,'markersize',3)
    ylabel('Tangling Amount')
    xticklabels(crop_window(1)+50:50:crop_window(2)-50)
    xlabel('Time(ms)')
    ylim([min(Q_for_plotting) max(Q_for_plotting)])
    title(['Velocity vs Tangling ; ' meta.target_locations{iTP} ' Target; Subject ' meta.subject])
    hold off
    saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'_Target_',meta.target_locations{iTP},'_speed_vs_tangling_aligned_on' align '.png']);
    close gcf
    
end

%% Plot Curvature
for iTP = unique([data.tp])
    figure('visible','off','color','white'); hold on
    yyaxis left
    patch([(1:size(D_m1_CO(iTP).speed,1)) flip(1:size(D_m1_CO(iTP).speed,1))],[(D_m1_CO(iTP).speed+D_m1_CO(iTP).speed_std_err)' flip(D_m1_CO(iTP).speed-D_m1_CO(iTP).speed_std_err)'],colors(iTP,:),'edgecolor','none');
    alpha(0.4)
    ylabel('Speed')
    plot(1:size(D_m1_CO(iTP).speed),D_m1_CO(iTP).speed,'color',colors(iTP,:),'linewidth',2);
    yyaxis right
    if breakout == 1
        for iGroup = 1:3
            plot(1:size(D_m1_CO(iTP).speed),R{iGroup,iTP},'color',colors(iTP,:),'linewidth',2);   
        end
    else
        plot(1:size(D_m1_CO(iTP).speed),R{iTP},'color',colors(iTP,:),'linewidth',2);
    end
    ylabel('Curvature Amount')
    xticklabels(crop_window(1)+50:50:crop_window(2)-50)
    xlabel('Time(ms)')
    ylim([min(min([R{:}])) max(max([R{:}]))/3])
    title(['Velocity vs Curvature ; ' meta.target_locations{iTP} ' Target; Subject ' meta.subject])
    hold off
    saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'_Target_',meta.target_locations{iTP},'_speed_vs_curvature_aligned_on' align '.png']);
    close gcf
    
end


%%
% tangle_visualize_cs( out )

