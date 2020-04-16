function [] = plot_all_trials(trialwise_states,num_states_subject,subject,trials_to_plot,task,figure_folder_filepath)

%%
colors = jet(num_states_subject);

%% Ok, so trying to plot a single trial?

for iTrial = trials_to_plot%datasample(1:length(trInd_test),3)
    state_present = zeros(2,num_states_subject);
    figure(1); hold on
%     plot(trialwise_states(iTrial).x_smoothed,trialwise_states(iTrial).y_smoothed,'k')
    for iSegment = 1:size(trialwise_states(iTrial).segment_state_number,2)
        if ~isempty(trialwise_states(iTrial).segment_kinematic_timestamps{iSegment})
            plots{iSegment} = plot(trialwise_states(iTrial).segment_kinematic_x{iSegment},trialwise_states(iTrial).segment_kinematic_y{iSegment},'Color',colors(trialwise_states(iTrial).segment_state_number(iSegment),:)...
                ,'LineWidth',2,'DisplayName',['State ' num2str(trialwise_states(iTrial).segment_state_number(iSegment))]);
            plots{iSegment}.Color(4) = 0.35;
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
title(strcat(subject,' ',strrep(task,'_',' '),' all trials position'));
% legend([plots{state_present(2,state_present(1,:)>0)}]);
saveas(gcf,strcat(figure_folder_filepath,'\',subject,task,num2str(num_states_subject),'states','_all_trials_position.png'));

end

