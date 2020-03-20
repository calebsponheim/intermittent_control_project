BX_new_data = load('Bx_center_out_HMM_analysis_16_states_18-Sep-2019.mat');


% These don't really help because of the different numbers of units in each
% of these.
BX_new_data.spike_count_hist = histcounts([BX_new_data.data.spikecount]);
BX_old_data.spike_count_hist = histcounts([BX_old_data.data.spikecount]);
RS_data.spike_count_hist = histcounts([RS_data.data.spikecount]);

figure; hold on
plot(BX_new_data.spike_count_hist);
plot(BX_old_data.spike_count_hist);
plot(RS_data.spike_count_hist);
legend('BX new data','BX old data','RS')

% These do help a little more.
unique([BX_new_data.data.spikecount])
unique([BX_old_data.data.spikecount])
unique([RS_data.data.spikecount])


% Okay, what if we plot spike counts for all of the units across time, for
% individual trials??

figure; hold on
for iTrial = 1:25%size(BX_new_data.data,2)
    %     for iUnit = 1:size(RS_data.data(iTrial).spikecount,2)
    subplot(5,5,iTrial)
    plot(mean(RS_data.data(iTrial).spikecount',2));
    %     end
end

%% PSTHs of each unit for the new datasets. do they look weird tho

for iUnit = 1:size(data(1).spikecount,1)
    %     unit_analysis(iUnit).trials = zeros(size(data,2),size(data(1).spikecount(1),2));
    for iTrial = 1:size(data,2)
        unit_analysis(iUnit).trials(iTrial,1:size(data(iTrial).spikecount(iUnit,:),2)) = data(iTrial).spikecount(iUnit,:);
    end %iTrial
    
    unit_analysis(iUnit).average = mean(unit_analysis(iUnit).trials,1);
    unit_analysis(iUnit).std_err = std(unit_analysis(iUnit).trials,1) / sqrt(size(unit_analysis(iUnit).trials,1));
    
end %iUnit

% Plotting

figure; hold on
for iUnit = 1:size(unit_analysis,2)
    subplot(13,13,iUnit); hold on;
    plot(unit_analysis(iUnit).average, 'k')
    plot(unit_analysis(iUnit).average + unit_analysis(iUnit).std_err, 'b')
    plot(unit_analysis(iUnit).average - unit_analysis(iUnit).std_err, 'b')
    axis tight
    ylim([0 max([unit_analysis.average])])
    box off
end %iUnit
sgtitle([subject ' ' session ' center out psths'])
set(gcf,'color','w','pos',[0 0 1500 1000]);
hold off
%% trying to find the location and occurences of high spike counts in Breaux datasets
max_spikecount = max(unique([data.spikecount]));
for iTrial = 1:size(data,2)
    if ~isempty(find([data(iTrial).spikecount]>=10, 1))
        [max_spikecount_location{iTrial}(1,:),max_spikecount_location{iTrial}(2,:)] = find([data(iTrial).spikecount]>=10);
    else
        max_spikecount_location{iTrial}(1) = 0;
        max_spikecount_location{iTrial}(2) = 0;
        
    end
end

%% setting a ceiling on spikecounts to see if that does anything at all

for iTrial = 1:size(data,2)

    data(iTrial).spikecount(data(iTrial).spikecount > spikecount_ceiling) = spikecount_ceiling;
    
end

%% Finding location of unique high spike count bins in the data. 

% look. I know there's a faster better more efficient way to do this but
% I'm tired. So it's going to be a shit-ton of for loops. Get over it.
spikecount_ceiling = 8;

iCount = 1;
for iTrial = 1:size(data,2)
    for iUnit = 1:size(data(iTrial).spikecount,1)
        for iBin = 1:size(data(iTrial).spikecount(iUnit,:),2)
            if data(iTrial).spikecount(iUnit,iBin) >= spikecount_ceiling
                exuberant_spikes(iCount).num_spikes = data(iTrial).spikecount(iUnit,iBin);
                exuberant_spikes(iCount).Unit = iUnit;
                exuberant_spikes(iCount).Trial = iTrial;
                exuberant_spikes(iCount).Time_ms = iBin*50;
                iCount = iCount + 1;
            end
        end %iBin
    end %iUnit
end %iTrial
%%
for iTrial = 1:size(units,1)
    max_time_diff(iTrial) = cpl_st_trial_rew_relative(iTrial,2) - max(cell2mat(units(iTrial,:)'));
end