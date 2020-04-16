% Plotting log-likelihood

clear ll_train
clear ll_test
clear ll_train
clear k_test

for iStatenum = 2:length(dc)
    for iRep = 1:size(dc,2)
        ll_test_temp(iStatenum-1,iRep,:) = [dc{iStatenum,iRep}.ll];
    end
    k_test(iStatenum) = numel(hn_trained{iStatenum,iRep}.a(2:end,:));
end

ll_test_mean_across_iters = mean(ll_test_temp,2);
ll_test = sum(ll_test_mean_across_iters,3);

% for iStatenum = 2:length(hn_trained)
%     for iRep = 1:size(dc,2)
%         ll_train(iStatenum-1,iRep) = [hn_trained{iStatenum,iRep}.last_ll];
%     end
% end
% 
% ll_train = mean(ll_train,2);


for iStatenum = 2:length(dc_trainset)
    for iRep = 1:size(dc_trainset,2)
        ll_train_temp(iStatenum-1,iRep,:) = [dc_trainset{iStatenum,iRep}.ll];
    end
end

ll_train_mean_across_iters = mean(ll_train_temp,2);
ll_train = sum(ll_train_mean_across_iters,3);

%% Calculate AIC


AIC = 2*k_test(2:end)' - 2*ll_test;
quad_fit_to_AIC = polyfit(1:length(AIC),AIC',3);
quad_fit_to_AIC = polyval(quad_fit_to_AIC,1:.1:length(AIC));
figure; hold on;
plot(1:length(AIC),AIC,'o')
plot(1:.1:length(AIC),quad_fit_to_AIC)
box off
set(gcf,'color','white')
xlabel('Number of Hidden States')
ylabel('AIC')
%%
figure; hold on
plot(ll_train,'k.','markersize',20)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('LL 190228 Medial+Lateral Array, *training data*')
hold off

figure; hold on
% plot(ll_test_sum,'k.')
plot(ll_test,'b')
% plot(mean(ll_test_sum,2) + mean(ll_test_std_err,2),'r')
% plot(mean(ll_test_sum,2) - mean(ll_test_std_err,2),'r')
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('Log Likelihood 190228 Medial+Lateral Array, *test data*')

%% Plot Together

figure; hold on
plot(ll_train,'r-','linewidth',3)
plot(ll_test,'k-','linewidth',3)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('test data (black) and training data (red)')


% figure; hold on
% plot([ll_train_mean_across_iters],'r-','linewidth',3)
% plot(ll_test_mean_across_iters(:,:,:),'k-','linewidth',3)
% box off
% set(gcf,'color','white')
% xlabel('number of hidden states')
% ylabel('log likelihood')
% title('test data (black) and training data (red)')



%% distribution
figure; hold on
histogram(ll_train)
histogram(ll_test)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('test data (black) and training data (red)')
