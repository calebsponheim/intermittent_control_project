fit_to_log_likelihood = fit(num_states_for_plotting',mean(ll_sum,2),'exp2');

curve_range = min(num_states_for_plotting):.1:max(num_states_for_plotting);
% fitted_curve = polyval(fit_to_log_likelihood,curve_range);
% plot(curve_range,fitted_curve);



% ipt = findchangepts(mean(ll_sum,2),'Statistic','linear'); hold on

resamp_fit = fit_to_log_likelihood(curve_range);
ipt = findchangepts(resamp_fit,'Statistic','linear');


figure; plot(num_states_for_plotting,ll_sum,'k.'); hold on
plot(curve_range(ipt),resamp_fit(ipt),'ro')


plot(fit_to_log_likelihood);
% plot(curve_range,fit_to_log_likelihood(curve_range),'go')
% plot(num_states_for_plotting(min(diff(diff(mean(ll_sum,2)))) == diff(diff(mean(ll_sum,2)))),ll_sum(min(diff(diff(mean(ll_sum,2)))) == diff(diff(mean(ll_sum,2))),:),'ro')