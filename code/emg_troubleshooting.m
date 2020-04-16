%% EMG Sanity Check

% Goal: Plot single-segment velocity traces and single-muscle activations as well.
num_segments = 25;
colors_emg = hsv(length(muscle_names));

for iMuscle = 1:length(muscle_names)
    for iState = 1:num_states_subject
        
        max_speed_state = max([segmentwise_analysis(iState).speed{:}]);
        max_speed_muscle = max([segmentwise_analysis(iState).([muscle_names{iMuscle}]){:}]);
        %create figure, calculate subplot grid
        figure('Name',num2str(iState),'visible','off'); hold on;
        for iSegment = 1:num_segments
            if length(segmentwise_analysis(iState).kinetic_timestamps) >= num_segments
                subplot(sqrt(num_segments),sqrt(num_segments),iSegment); hold on
                %same subplot
                %plot velocity
                p1 = plot(segmentwise_analysis(iState).kinetic_timestamps{iSegment},segmentwise_analysis(iState).speed{iSegment}/max_speed_state,'k');
                %plot EMG
                p2 = plot(segmentwise_analysis(iState).kinetic_timestamps{iSegment},segmentwise_analysis(iState).([muscle_names{iMuscle}]){iSegment}/max_speed_muscle,'Color',colors_emg(iMuscle,:));
                
                box off
                axis tight
                xlabel('time')
                title(num2str(segmentwise_analysis(iState).target_location{iSegment}))
            end
        end
        set(gcf,'color','w','pos',[0 0 800 800])
        %save figure
        if ispc
            saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,'state_',num2str(iState),'_',muscle_names{iMuscle},'.png'));
        else
            saveas(gcf,['~/git/intermittent_control_project/figures/' subject task 'state_' num2str(iState) '_' muscle_names{iMuscle} '.png']);
        end
        close gcf
    end
end