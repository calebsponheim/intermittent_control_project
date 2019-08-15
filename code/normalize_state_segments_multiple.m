function [segmentwise_analysis] = normalize_state_segments_multiple(segmentwise_analysis,subject,task,num_states_subject)

% Normalize State Segments (Figure 3)

%% Calculate normalized segments

for iState = 1:size(segmentwise_analysis,2)
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


%% Plot Normalized speed profile (normalized by speed and time) for each state
current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

colors = jet(num_states_subject);
figure('visible','on'); hold on
for iState = [8,2]
avg = segmentwise_analysis(iState).normspeed_avg;
err_abv = segmentwise_analysis(iState).normspeed_avg+segmentwise_analysis(iState).normspeed_std_err;
err_blw = segmentwise_analysis(iState).normspeed_avg-segmentwise_analysis(iState).normspeed_std_err;

x = 0:1/length(avg):(1-1/length(avg));
j{iState} = plot(x,avg,'Color',colors(iState,:),'linewidth',3);
plot(x,err_abv,'Color',colors(iState,:));
plot(x,err_blw,'Color',colors(iState,:));

end
xlim([0 1])
ylim([0 1])
box off
legend([j{8} j{2}],{'state 8','state 2'})
set(gcf,'color','w')
title(['States 8 and 2 normalized speed segments'])
xlabel('time (normalized)')
ylabel('speed (normalized)')
end %ifunction