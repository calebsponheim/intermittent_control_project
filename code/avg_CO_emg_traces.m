function [] = avg_CO_emg_traces(muscle_names,trialwise_states,targets,figure_folder_filepath)
%% Plot Average EMG Traces for Center-out target directions

% Essentially, to replicate Wei's figure

% One figure for each muscle (13)

% Within each figure, one line per tp (8)
                                                                                     
% First, we need to average EMGs across same-tp trials

clear avg_muscle_analysis
clear emg_temp

for iMuscle = 1:length(muscle_names)
    for iTp = unique([trialwise_states.tp])
        trial_count = 1;
        for iTrial = find([trialwise_states.tp] == iTp)
            % before you do anything, crop the muscle traces down, based on
            % the first and last kinematic timestamp timing.
            trial_beginning =       trialwise_states(iTrial).segment_kinematic_timestamps{1}(1);  
            trial_end =             trialwise_states(iTrial).segment_kinematic_timestamps{end}(end);
            trial_beginning_index = find(trialwise_states(iTrial).kinematic_timestamps == trial_beginning);
            trial_end_index =       find(trialwise_states(iTrial).kinematic_timestamps == trial_end);
            emg_temp_temp(1,1:length(trialwise_states(iTrial).(muscle_names{iMuscle}))) = trialwise_states(iTrial).(muscle_names{iMuscle});
            emg_temp(trial_count,1:length(trial_beginning_index:trial_end_index)) = emg_temp_temp(trial_beginning_index:trial_end_index);
            trial_count =           trial_count + 1;
        end
        
        emg_temp(emg_temp == 0) = NaN;
        
        avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_avg']) =     mean(emg_temp,1,'omitnan');
        avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_std_err']) = std(emg_temp,1,'omitnan') / sqrt(size(emg_temp,1));
        clear emg_temp
        clear emg_temp_temp %lol
    end  
end




%% Okay so let's plot!
colors = hsv(length(unique([trialwise_states.tp])));
subplot_dim = ceil(sqrt(length(muscle_names)));

figure('visible','on'); hold on;
for iMuscle = 1:length(muscle_names)
    subplot(subplot_dim,subplot_dim,iMuscle); hold on
    for iTp = unique([trialwise_states.tp])
        t =             1:length(avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_avg']));
        std_err_abv =   avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_avg']) + avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_std_err']);
        std_err_blw =   avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_avg']) - avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_std_err']);
        patch([t fliplr(t)],[std_err_blw fliplr(std_err_abv)],colors(iTp,:),'linestyle','none');
        alpha(.5)
        plot(t,avg_muscle_analysis(iTp).([muscle_names{iMuscle} '_avg']),'Color',colors(iTp,:))
    end
    title(strrep(muscle_names{iMuscle},'_',' '))
    box off
end
subplot(subplot_dim,subplot_dim,iMuscle + 1); hold on

for iTp = unique([trialwise_states.tp])
    plot(targets(iTp,1),targets(iTp,2),'o','Color',colors(iTp,:),'MarkerSize',10)
end
set(gcf,'color','white')
sgtitle('Center Out')


end