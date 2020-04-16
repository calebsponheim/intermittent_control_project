function [segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject,include_EMG_analysis,muscle_names,figure_folder_filepath)

% Normalize State Segments (Figure 3)

%% Calculate normalized segments

for iState = 1:size(segmentwise_analysis,2)
    if ~isempty(segmentwise_analysis(iState).x)
        segmentwise_analysis(iState).normspeed = cellfun(@(x) (normalize(x,'range')),segmentwise_analysis(iState).speed,'UniformOutput',false);
        for iCell = 1:size(segmentwise_analysis(iState).normspeed,2)
            if sum(segmentwise_analysis(iState).normspeed{iCell}) ~= 0
                segmentwise_analysis(iState).normspeed_interp(iCell,:) = interp1(...
                    1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1,... %input 1
                    segmentwise_analysis(iState).normspeed{iCell},... %input 2
                    1/max(segmentwise_analysis(iState).length):1/max(segmentwise_analysis(iState).length):1); %input 3
            end
        end %iCell
        
        if include_EMG_analysis == 1
            for iMuscle = 1:length(muscle_names)
                segmentwise_analysis(iState).(['norm' muscle_names{iMuscle}]) = cellfun(@(x) (normalize(x,'range')),segmentwise_analysis(iState).(muscle_names{iMuscle}),'UniformOutput',false);
                for iCell = 1:size(segmentwise_analysis(iState).(['norm' muscle_names{iMuscle}]),2)
                    if sum(segmentwise_analysis(iState).(['norm' muscle_names{iMuscle}]){iCell}) ~= 0
                        segmentwise_analysis(iState).(['norm' muscle_names{iMuscle} '_interp'])(iCell,:) = interp1(...
                            1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1,... %input 1
                            segmentwise_analysis(iState).(['norm' muscle_names{iMuscle}]){iCell},... %input 2
                            1/max(segmentwise_analysis(iState).length):1/max(segmentwise_analysis(iState).length):1); %input 3
                    end
                end %iCell
            end %iMuscle
            
        end
        
        if strcmp(subject,'RS') == 0
            if sum(cell2mat([segmentwise_analysis(iState).normspeed])) ~= 0
                segmentwise_analysis(iState).normspeed_avg = mean(segmentwise_analysis(iState).normspeed_interp,1);
                segmentwise_analysis(iState).normspeed_std_err = std(segmentwise_analysis(iState).normspeed_interp,1)/(sqrt(size(segmentwise_analysis(iState).normspeed_interp,1)));
            end
        elseif strcmp(subject,'RS')
            if sum(cell2mat([segmentwise_analysis(iState).normspeed'])) ~= 0
                segmentwise_analysis(iState).normspeed_avg = mean(segmentwise_analysis(iState).normspeed_interp,1);
                segmentwise_analysis(iState).normspeed_std_err = std(segmentwise_analysis(iState).normspeed_interp,1)/(sqrt(size(segmentwise_analysis(iState).normspeed_interp,1)));
            end
        end
    end
end %iState


%% Plot Normalized speed profile (normalized by speed and time) for each state

colors = jet(num_states_subject);

for iState = 1:size(segmentwise_analysis,2)
    if ~isempty(segmentwise_analysis(iState).x)
        figure('visible','off'); hold on
        avg = segmentwise_analysis(iState).normspeed_avg;
        err_abv = segmentwise_analysis(iState).normspeed_avg+segmentwise_analysis(iState).normspeed_std_err;
        err_blw = segmentwise_analysis(iState).normspeed_avg-segmentwise_analysis(iState).normspeed_std_err;
        
        x = 0:1/length(avg):(1-1/length(avg));
        plot(x,avg,'Color',colors(iState,:),'linewidth',3);
        plot(x,err_abv,'Color',colors(iState,:));
        plot(x,err_blw,'Color',colors(iState,:));
        xlim([0 1])
        ylim([0 1])
        box off
        set(gcf,'color','w')
        title([strrep(task,'_',' ') 'State ' num2str(iState) 'normalized speed segments'])
        xlabel('time (normalized)')
        ylabel('speed (normalized)')
        hold off
        if ispc
            saveas(gcf,[figure_folder_filepath,'\' subject '_' task '_' num2str(num_states_subject) ...
                '_states_state_' num2str(iState) '_normalized_speed_segments.png']);
        else
            saveas(gcf,[subject '_' task '_' num2str(num_states_subject) ...
                '_states_state_' num2str(iState) '_normalized_speed_segments.png']);
        end
        close(gcf)
        
        % Plotting AVG Muscle Activation
        
        if include_EMG_analysis == 1
            figure('visible','off'); hold on
            colors_emg = hsv(length(muscle_names));
            for iMuscle = 1:length(muscle_names)               
                legend_figs(iMuscle) = plot(NaN,NaN,'Color',colors_emg(iMuscle,:),'DisplayName',strrep(strrep(muscle_names{iMuscle},'EMG_',''),'_',' '));
            end
            for iMuscle = 1:length(muscle_names)
                avg = mean(segmentwise_analysis(iState).(['norm' muscle_names{iMuscle} '_interp']),1);
                
                x = 0:1/length(avg):(1-1/length(avg));
                plot(x,avg,'Color',colors_emg(iMuscle,:),'linewidth',2);
                
                
            end
            
            xlim([0 1])
            ylim([0 1])
            box off
            set(gcf,'color','w','pos',[50 50 800 400])
            title([strrep(task,'_',' ') 'State ' num2str(iState) 'normalized EMG signals'])
            xlabel('time (normalized)')
            ylabel('EMG signal (normalized)')
            legend(legend_figs,'Location','northeastoutside');
            hold off
            if ispc
                saveas(gcf,[figure_folder_filepath,'\' subject '_' task '_' num2str(num_states_subject) ...
                    '_states_state_' num2str(iState) '_normalized_muscle_activity_segments.png']);
            else
                saveas(gcf,[subject '_' task '_' num2str(num_states_subject) ...
                    '_states_state_' num2str(iState) '_normalized_muscle_activity_segments.png']);
            end

            close(gcf)
            clear legend_figs
        end
        
        %
    end
end


end %ifunction