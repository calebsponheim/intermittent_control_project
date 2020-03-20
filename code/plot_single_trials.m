function [] = plot_single_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,muscle_names,include_EMG_analysis)

%%
colors = jet(num_states_subject);

%% Ok, so trying to plot a single trial?

current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

for iTrial = trials_to_plot%datasample(1:length(trInd_test),3)
    %% Speed Plot
    clear segment_names
    empty_segment_count = 0;
    state_present = zeros(2,num_states_subject);
    figure('visible','off'); hold on
    %     plot(trialwise_states(iTrial).kinematic_timestamps,trialwise_states(iTrial).speed,'k','LineWidth',2)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}(1),trialwise_states(iTrial).segment_kinematic_speed{iSegment}(1),'ko')
            plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment},...
                trialwise_states(iTrial).segment_kinematic_speed{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:),...
                'DisplayName',num2str(trialwise_states(iTrial).segment_state_number(iSegment)),'LineWidth',2);
            if state_present(trialwise_states(iTrial).segment_state_number(iSegment)) == 0
                state_present(1,trialwise_states(iTrial).segment_state_number(iSegment)) = 1;
                state_present(2,trialwise_states(iTrial).segment_state_number(iSegment)) = iSegment;
            end
            segment_names(iSegment) = str2double(plots{iSegment}.DisplayName);
        else
            empty_segment_count = empty_segment_count + 1;
        end
    end
    if empty_segment_count == size(trialwise_states(iTrial).segment_state_number,2)
    else
        [~,segments_unique_for_legend,~] = unique(segment_names);
        if strcmp(task,'center_out')
            title([subject,' center out Trial ',num2str(iTrial),' speed']);
        else
            title(strcat(subject,strrep(task,'_',' '),'Trial ',num2str(iTrial),' speed'));
        end
        legend([plots{segments_unique_for_legend}],'Location','northwest');
        xlabel('time')
        box off
        set(gcf,'Color','White');
        saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
            ,subject,task,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_speed.png'));
    end
    close(gcf);
    clear plots
    clear segment_names
    
    %% Position Plot
    figure('visible','off'); hold on
    %     plot(trialwise_states(iTrial).x_smoothed,trialwise_states(iTrial).y_smoothed,'k','LineWidth',2)
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            %             plot(trialwise_states(iTrial).segment_kinematic_x{iSegment}(1),trialwise_states(iTrial).segment_kinematic_y{iSegment}(1),'ko')
            plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_x{iSegment},trialwise_states(iTrial).segment_kinematic_y{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:)...
                ,'DisplayName',num2str(trialwise_states(iTrial).segment_state_number(iSegment)),'LineWidth',2);
            segment_names(iSegment) = str2double(plots{iSegment}.DisplayName);
        end
    end
    [~,segments_unique_for_legend,~] = unique(segment_names);
    plot(trialwise_states(iTrial).segment_kinematic_x{1, 1}(1),trialwise_states(iTrial).segment_kinematic_y{1, 1}(1),'ro')
    if strcmp(task,'center_out')
        title([subject,' center out Trial ',num2str(iTrial),' position']);
    else
        title(strcat(subject,strrep(task,'_',' '),' Trial ',num2str(iTrial),' position'));
    end
    legend([plots{segments_unique_for_legend}],'Location','northwest');
    xlabel('x position');
    ylabel('y position');
    set(gcf,'Color','White');
    if strcmp(subject,'RS') == 0
        xlim([min([trialwise_states.x_smoothed]) max([trialwise_states.x_smoothed])])
        ylim([min([trialwise_states.y_smoothed]) max([trialwise_states.y_smoothed])])
    elseif strcmp(subject,'RS')
        xlim([min(vertcat(trialwise_states.x_smoothed)) max(vertcat(trialwise_states.x_smoothed))])
        ylim([min(vertcat(trialwise_states.y_smoothed)) max(vertcat(trialwise_states.y_smoothed))])
    end
    box off
    saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\',subject,task,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_position.png'));
    close(gcf);
    
    
    %% Acceleration Plot
    if strcmp(subject,'RS') == 0
        clear segment_names
        state_present = zeros(2,num_states_subject);
        figure('visible','off'); hold on
        %         plot(trialwise_states(iTrial).kinematic_timestamps,trialwise_states(iTrial).acceleration,'k','LineWidth',2)
        for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
            if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
                plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment}(1),trialwise_states(iTrial).segment_kinematic_acceleration{iSegment}(1),'ko')
                plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment},...
                    trialwise_states(iTrial).segment_kinematic_acceleration{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:),...
                    'DisplayName',num2str(trialwise_states(iTrial).segment_state_number(iSegment)),'LineWidth',2);
                if state_present(trialwise_states(iTrial).segment_state_number(iSegment)) == 0
                    state_present(1,trialwise_states(iTrial).segment_state_number(iSegment)) = 1;
                    state_present(2,trialwise_states(iTrial).segment_state_number(iSegment)) = iSegment;
                end
                segment_names(iSegment) = str2double(plots{iSegment}.DisplayName);
                
            end
        end
        [~,segments_unique_for_legend,~] = unique(segment_names);
        if strcmp(task,'center_out')
            title([subject,' center out Trial ',num2str(iTrial),' acceleration']);
        else
            title(strcat(subject,strrep(task,'_',' '),'Trial ',num2str(iTrial),' acceleration'));
        end
        legend([plots{segments_unique_for_legend}],'Location','northwest');
        xlabel('time')
        box off
        set(gcf,'Color','White');
        saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
            ,subject,task,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_acceleration.png'));
        close(gcf);
        clear plots
    end
    
    %% Plot Muscles
    if include_EMG_analysis == 1
        colors_emg = hsv(length(muscle_names));
        clear segment_names
        empty_segment_count = 0;
        state_present = zeros(2,num_states_subject);
        figure('visible','off'); hold on
        %     plot(trialwise_states(iTrial).kinematic_timestamps,trialwise_states(iTrial).speed,'k','LineWidth',2)
        
        %hidden figures for legend
        for iState = 1:num_states_subject
            legend_figs(iState) = plot(NaN,NaN,'Color',colors(iState,:),'DisplayName',['State ' num2str(iState)]);
        end
       
        for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
            if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
                
                
                
                for iMuscle = 1:length(muscle_names)
                    plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment},trialwise_states(iTrial).(['segment_kinematic_' muscle_names{iMuscle}]){iSegment},'Color',colors_emg(iMuscle,:))
                    legend_figs(num_states_subject+iMuscle) = plot(NaN,NaN,'Color',colors_emg(iMuscle,:),'DisplayName',strrep(strrep(muscle_names{iMuscle},'EMG_',''),'_',' '));
                end
                
                
                plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment},...
                    zeros(length(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})),'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:),...
                    'DisplayName',num2str(trialwise_states(iTrial).segment_state_number(iSegment)),'LineWidth',2);
                
                
                if state_present(trialwise_states(iTrial).segment_state_number(iSegment)) == 0
                    state_present(1,trialwise_states(iTrial).segment_state_number(iSegment)) = 1;
                    state_present(2,trialwise_states(iTrial).segment_state_number(iSegment)) = iSegment;
                end
                
                
            else
                empty_segment_count = empty_segment_count + 1;
            end
        end
        if empty_segment_count == size(trialwise_states(iTrial).segment_state_number,2)
        else
            if strcmp(task,'center_out')
                title([subject,' center out Trial ',num2str(iTrial),' muscle activity']);
            else
                title(strcat(subject,strrep(task,'_',' '),'Trial ',num2str(iTrial),' muscle activity'));
            end
            
            
            legend(legend_figs,'Location','northeastoutside');
            xlabel('time')
            box off
            set(gcf,'Color','White','pos',[100 100 800 500]);
            saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
                ,subject,task,num2str(num_states_subject),'states','_Test_Trial_',num2str(iTrial),'_muscle_activity.png'));
        end
        close(gcf);
        clear plots
        clear segment_names
    end
end

