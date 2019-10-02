function [segmentwise_analysis] = normalize_state_segments(segmentwise_analysis,subject,task,num_states_subject)

% Normalize State Segments (Figure 3)

%% Plot Segments together by state (separate figures), with direction histograms in the top right corner

% not sure that this is necessary:

% for istate = 1:size(segmentwise_analysis,2)
%     figure;hold on
%     cellfun(@plot,segmentwise_analysis(istate).x,segmentwise_analysis(istate).y)
%
%     x_start = cellfun(@(v)v(1),segmentwise_analysis(istate).x(~cellfun('isempty',segmentwise_analysis(istate).x)));
%     y_start = cellfun(@(v)v(1),segmentwise_analysis(istate).y(~cellfun('isempty',segmentwise_analysis(istate).y)));
%     plot(x_start,y_start,'ro');
%
%     title(strcat(subject,' state ',num2str(istate),'snippets (random subset)'));
%     xlabel('x position');
%     ylabel('y position');
%     box off
%     xlim([min(vertcat(trialwise_states.x_smoothed)) max(vertcat(trialwise_states.x_smoothed))])
%     ylim([min(vertcat(trialwise_states.y_smoothed)) max(vertcat(trialwise_states.y_smoothed))])
%     set(gcf,'Color','White');
%     saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\'...
%           ,subject,num2str(num_states_subject),'states','_state_',num2str(istate),'_snippets_random_subset.png'));
%     close(gcf);
% end

%% Calculate normalized segments

for iState = 1:size(segmentwise_analysis,2)
    if ~isempty(segmentwise_analysis(iState).x)
        segmentwise_analysis(iState).normspeed = cellfun(@(x) (normalize(x,'range')),segmentwise_analysis(iState).speed,'UniformOutput',false);
        %    segmentwise_analysis(iState).interp_factor = arrayfun(@(x) (max(segmentwise_analysis(iState).length)/x),segmentwise_analysis(iState).length);
        for iCell = 1:size(segmentwise_analysis(iState).normspeed,2)
            if sum(segmentwise_analysis(iState).normspeed{iCell}) ~= 0
                segmentwise_analysis(iState).normspeed_interp(iCell,:) = interp1(...
                    1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1/length(segmentwise_analysis(iState).kinetic_timestamps{iCell}):1,... %input 1
                    segmentwise_analysis(iState).normspeed{iCell},... %input 2
                    1/max(segmentwise_analysis(iState).length):1/max(segmentwise_analysis(iState).length):1); %input 3
            end
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
end


%% Plot Normalized speed profile (normalized by speed and time) for each state
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

colors = jet(num_states_subject);

for iState = 1:size(segmentwise_analysis,2)
    if ~isempty(segmentwise_analysis(iState).x)
        figure('visible','on'); hold on
        avg = segmentwise_analysis(iState).normspeed_avg;
        err_abv = segmentwise_analysis(iState).normspeed_avg+segmentwise_analysis(iState).normspeed_std_err;
        err_blw = segmentwise_analysis(iState).normspeed_avg-segmentwise_analysis(iState).normspeed_std_err;
        
        x = 0:1/length(avg):(1-1/length(avg));
        % x2 = [x, fliplr(x)];
        % inBetween = [err_abv, fliplr(err_blw)];
        % fill(x2, inBetween,colors(iState,:));
        %
        plot(x,avg,'Color',colors(iState,:),'linewidth',3);
        plot(x,err_abv,'Color',colors(iState,:));
        plot(x,err_blw,'Color',colors(iState,:));
        xlim([0 1])
        ylim([0 1])
        box off
        set(gcf,'color','w')
        title(['State ' num2str(iState) 'normalized speed segments'])
        xlabel('time (normalized)')
        ylabel('speed (normalized)')
        hold off
        if ispc
        saveas(gcf,['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\' subject '_' task '_' num2str(num_states_subject) ...
            '_states_state_' num2str(iState) '_normalized_speed_segments.png']);
        else
        saveas(gcf,[subject '_' task '_' num2str(num_states_subject) ...
            '_states_state_' num2str(iState) '_normalized_speed_segments.png']);
        end
        close(gcf)
    end
end


end %ifunction