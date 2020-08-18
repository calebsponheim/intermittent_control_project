function [meta] = model_select_HMM(data,meta)
%% MODEL SELECT HMM

% Get list of files in data_midway/hn-trained
% filter list by crosstrain type (so, pull in meta)
file_list = dir('.\data_midway\hn_trained');
folder = file_list(1).folder;
file_list = {file_list.name};
model_files = cellfun(@(x)[folder '\' x],file_list(...
    endsWith(file_list,['CT' num2str(meta.crosstrain) '.mat'])),'UniformOutput',false);

if meta.crosstrain == 0
    model_files = model_files(contains(model_files,[meta.subject meta.task]));
end
model_files = sort(model_files);

state_num_range = 2:(numel(model_files)+1);
% load the correct CT data file

trInd_model_select = cellfun(@(x) strcmp(x,'model_select'),[data.trial_classification]);

for iStateNum = state_num_range % for each state num
    hn_trained_temp = load(model_files{iStateNum-1},'hn_trained'); % load their models
    hn_trained_temp = hn_trained_temp.hn_trained;
    num_states_temp = size(hn_trained_temp{1}.a,1);
    % decode ALL trials
    for iIter = 1:numel(hn_trained_temp)
        dc_temp = decode_trials(hn_trained_temp{iIter},data,meta);
        dc_temp_ll = [dc_temp.ll];
        dc_temp_ll_model_select(num_states_temp-1,iIter,:) = dc_temp_ll(trInd_model_select);
    end
    % label each dc trial by group (from array_data)
    % if the trial is "model select", then pull those trials aside alongside their state num
    disp(['processed models for ' num2str(num_states_temp) ' states'])
end
%% Plotting
% plot all the "model-select" trials dc ll together
figure('color','white','visible','off'); plot(state_num_range,sum(dc_temp_ll_model_select,3),'k.'); hold on
% fit a curve to that CHAOS
quad_fit_to_log_likelihood = polyfit(state_num_range,mean(sum(dc_temp_ll_model_select,3),2),2);
curve_range = min(state_num_range):.1:max(state_num_range);
quad_fit_to_log_likelihood = ...
    polyval(quad_fit_to_log_likelihood,curve_range);
plot(curve_range,quad_fit_to_log_likelihood);
box off
ylabel('Log Likelihood Across Trials')
xlabel('Number of States')
title([meta.subject ' ' meta.task ' CT' num2str(meta.crosstrain) ' log-likelihood'],'Interpreter', 'none')
% find a maximum point there or something
best_num_states = round(curve_range(quad_fit_to_log_likelihood == max(quad_fit_to_log_likelihood)));
plot(curve_range(quad_fit_to_log_likelihood == max(quad_fit_to_log_likelihood)),max(quad_fit_to_log_likelihood),'r*')
annotation('textbox',[.5 .5 0 0],'String',['Optimal Number of States: ' num2str(best_num_states)],'FitBoxToText','on')

% saving this to meta params
meta.optimal_number_of_states = best_num_states;
%% Saving
if startsWith(matlab.desktop.editor.getActiveFilename,'C:\Users\calebsponheim\Documents\')
    saveas(gcf,['C:\Users\calebsponheim\Documents\git\intermittent_control_project\code\modeling\ll_plots\' meta.subject ' ' meta.task ' CT' num2str(meta.crosstrain) ' log-likelihood.png']);
else
    saveas(gcf,[meta.subject ' ' meta.task ' CT' num2str(meta.crosstrain) ' log-likelihood.png']');
end

close(gcf);


end