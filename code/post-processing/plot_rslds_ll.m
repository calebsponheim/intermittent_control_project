function plot_rslds_ll(data,meta)

if strcmp(meta.subject,'RS')
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'model_select'));
else
    available_test_trials = find(ismember({data.trial_classification},'test'));
end

if meta.analyze_all_trials == 1
    available_test_trials = find(ismember({data.trial_classification},'test') | ismember({data.trial_classification},'train') | ismember({data.trial_classification},'model_select'));
end


test_trial_count = 0;
for iTrial = 1:size(data,2)
    if ismember(iTrial,available_test_trials)
        test_trial_count = test_trial_count + 1;
        if test_trial_count == 1
            ll_for_sum = data(iTrial).rslds_ll_noresamp;
        else
            ll_for_sum = [ll_for_sum data(iTrial).rslds_ll_noresamp];         
        end
    end
end
ll_for_plot = sum(ll_for_sum,2);


figure('visible','off','color','w'); hold on
plot(ll_for_plot)
box off
xlabel('state number (I think?)')
ylabel('Summed Log Likelihood (test trials)')

% Save the plot

saveas(gcf,[meta.figure_folder_filepath,meta.subject,meta.task,'CT',num2str(meta.crosstrain),'_rslds_LL.png']);
close gcf

end