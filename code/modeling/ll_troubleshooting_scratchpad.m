% exponential fit
fit_to_log_likelihood = fit(num_states_for_plotting',mean(ll_sum,2),'exp2');
curve_range = min(num_states_for_plotting):.1:max(num_states_for_plotting);
resamp_fit = fit_to_log_likelihood(curve_range);
percent_change_threshold = .10; %proportion
a=abs(diff(resamp_fit)) ./ abs(diff(resamp_fit(1:2)));
xvalSat=curve_range(find(a<percent_change_threshold,1));

% Calc AIC
% AIC = nan(size(ll_sum));
% mean_ll_sum = mean(ll_sum,2);
% % mean_params = mean(num_params,2);
% % mean_ll_sum = mean_ll_sum(num_states_for_plotting-1);
% % mean_params = mean_params(num_states_for_plotting-1);
% AIC= aicbic(mean_ll_sum,num_params);    
%  
% fit_to_AIC = fit(num_states_for_plotting',mean(AIC,2),'exp2');
% resamp_AIC_fit = fit_to_AIC(curve_range);
% 
% optimal_state_num_from_AIC = round(xvalSat);




%Plotting
figure; hold on
plot(num_states_for_plotting,ll_sum,'k.'); 
plot(fit_to_log_likelihood);
legend off
plot(xvalSat,resamp_fit(find(a<percent_change_threshold,1)),'go')
yyaxis right
plot(curve_range,resamp_AIC_fit)
plot(curve_range(resamp_AIC_fit == min(resamp_AIC_fit)),min(resamp_AIC_fit),'go')
hold off

% fitted_curve = polyval(fit_to_log_likelihood,curve_range);
% plot(curve_range,fitted_curve);
% ipt = findchangepts(mean(ll_sum,2),'Statistic','linear'); hold on
% ipt = findchangepts(resamp_fit,'Statistic','linear');
% plot(curve_range(ipt),resamp_fit(ipt),'ro')
% plot(curve_range,fit_to_log_likelihood(curve_range),'go')
% plot(num_states_for_plotting(min(diff(diff(mean(ll_sum,2)))) == diff(diff(mean(ll_sum,2)))),ll_sum(min(diff(diff(mean(ll_sum,2)))) == diff(diff(mean(ll_sum,2))),:),'ro')