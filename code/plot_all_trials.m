function [] = plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task)

%%
colors = hsv(num_states_subject);

%% Ok, so trying to plot a single trial?
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

for iTrial = trials_to_plot%datasample(1:length(trInd_test),3)
    state_present = zeros(2,num_states_subject);
    figure(1); hold on
    plot(trialwise_states(iTrial).x_smoothed,trialwise_states(iTrial).y_smoothed,'k')
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_x{iSegment},trialwise_states(iTrial).segment_kinematic_y{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:)...
                ,'DisplayName',['State ' num2str(trialwise_states(iTrial).segment_state_number(iSegment))]);
        end
    end
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
    
    
end
title(strcat(subject,task,' all trials position'));
% legend([plots{state_present(2,state_present(1,:)>0)}]);
saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\',subject,task,num2str(num_states_subject),'states','_all_trials_position.png'));

end

