function [meta] = model_select_HMM(data,meta)
%% MODEL SELECT HMM

% Get list of files in data_midway/hn-trained
% filter list by crosstrain type (so, pull in meta)
file_list = dir('.\data_midway\hn_trained');
folder = file_list(1).folder;
file_list = {file_list.name};

if (meta.crosstrain == 0) || (meta.crosstrain == 3) % 0: none || 3: both tasks together
    model_files = cellfun(@(x)[folder '\' x],file_list(...
        endsWith(file_list,['CT' num2str(meta.crosstrain) '.mat'])),'UniformOutput',false);
    
    model_files = model_files(contains(model_files,[meta.subject meta.task]));
elseif meta.crosstrain == 1 %1: RTP model, center-out decode
    model_files = cellfun(@(x)[folder '\' x],file_list(endsWith(file_list,'CT0.mat')),'UniformOutput',false);
    model_files = model_files(contains(model_files,[meta.subject 'RTP']));
elseif meta.crosstrain == 2 %2: Center-out model, RTP decode
    model_files = cellfun(@(x)[folder '\' x],file_list(endsWith(file_list,'CT0.mat')),'UniformOutput',false);
    model_files = model_files(contains(model_files,[meta.subject 'center_out']));
end
model_files = sort(model_files);

state_num_range = 2:(numel(model_files)+1);
% load the correct CT data file

trInd_model_select = cellfun(@(x) strcmp(x,'model_select'),[data.trial_classification]);

for iStateNum = state_num_range % for each state num
    hn_trained_temp = load(model_files{iStateNum-1},'hn_trained'); % load their models
    hn_trained_temp = hn_trained_temp.hn_trained;
    num_states_temp = size(hn_trained_temp{1}.a,1);
    num_params(num_states_temp-1) = numel(hn_trained_temp{1}.a);
    num_states_for_plotting(num_states_temp-1) = num_states_temp;
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
ll_sum = sum(dc_temp_ll_model_select,3);

ll_sum(num_states_for_plotting == 0,:) = [];
num_params(num_states_for_plotting == 0) = [];
num_states_for_plotting(num_states_for_plotting == 0) = [];

%% Plotting
% plot all the "model-select" trials dc ll together
figure('color','white','visible','on'); hold on

% plot(num_states_for_plotting,ll_sum,'k.'); hold on
% fit a curve to that CHAOS
quad_fit_to_log_likelihood = polyfit(num_states_for_plotting,mean(ll_sum,2),2);
curve_range = min(num_states_for_plotting):.1:max(num_states_for_plotting);
quad_fit_to_log_likelihood = ...
    polyval(quad_fit_to_log_likelihood,curve_range);
% plot(curve_range,quad_fit_to_log_likelihood);
% findchangepts(mean(ll_sum,2),'Statistic','linear'); hold on
% ipt = findchangepts(mean(ll_sum,2),'Statistic','linear');
% best_num_states = num_states_for_plotting(ipt);
best_num_states = round(curve_range(quad_fit_to_log_likelihood == max(quad_fit_to_log_likelihood)));

% fit_to_log_likelihood = fit(num_states_for_plotting',mean(ll_sum,2),'exp2');
% curve_range = min(num_states_for_plotting):.1:max(num_states_for_plotting);
% resamp_fit = fit_to_log_likelihood(curve_range);
% ipt = findchangepts(resamp_fit,'Statistic','linear');
% % findchangepts(resamp_fit,'Statistic','linear'); hold on
% plot(num_states_for_plotting,ll_sum,'k.'); hold on
% plot(curve_range(ipt),resamp_fit(ipt),'ro')
% plot(fit_to_log_likelihood);
% best_num_states = round(curve_range(ipt));
% 


fit_to_log_likelihood = fit(num_states_for_plotting',mean(ll_sum,2),'exp2');
curve_range = min(num_states_for_plotting):.1:max(num_states_for_plotting);
resamp_fit = fit_to_log_likelihood(curve_range);
percent_change_threshold = .10; %proportion
a=abs(diff(resamp_fit)) ./ abs(diff(resamp_fit(1:2)));
xvalSat=curve_range(find(a<percent_change_threshold,1));

plot(num_states_for_plotting,ll_sum,'k.'); 
plot(fit_to_log_likelihood);
legend off
plot(xvalSat,resamp_fit(find(a<percent_change_threshold,1)),'go')
% yyaxis right
% plot(curve_range,resamp_AIC_fit)
% plot(curve_range(resamp_AIC_fit == min(resamp_AIC_fit)),min(resamp_AIC_fit),'go')
% best_num_states = round(xvalSat);
legend off
% xticks(1:2:30);
% xticklabels(2:2:31);
box off
ylabel('Log Likelihood Across Trials')
xlabel('Number of States')
title([meta.subject ' ' meta.task ' CT' num2str(meta.crosstrain) ' log-likelihood'],'Interpreter', 'none')
% find a maximum point there or something
% best_num_states = round(curve_range(quad_fit_to_log_likelihood == max(quad_fit_to_log_likelihood)));
% plot(curve_range(quad_fit_to_log_likelihood == max(quad_fit_to_log_likelihood)),max(quad_fit_to_log_likelihood),'r*')
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