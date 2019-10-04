% Plotting log-likelihood

clear ll_train
clear ll_test

for iStatenum = 2:length(dc)
    for iRep = 1:size(dc,2)
        ll_test_temp(iStatenum-1,iRep,:) = [dc{iStatenum,iRep}.ll];
    end
end

ll_test_mean = reshape(mean(ll_test_temp,2),size(ll_test_temp,1),size(ll_test_temp,3));
ll_test_std_err = reshape(std(ll_test_temp,0,2) / sqrt(size(ll_test_temp,2)),size(ll_test_temp,1),size(ll_test_temp,3));

for iStatenum = 2:length(hn_trained)
    for iRep = 1:size(dc,2)
        ll_train(iStatenum-1,iRep) = [hn_trained{iStatenum,iRep}.last_ll];
    end
end
%%
figure; hold on
plot(ll_train,'k.','markersize',20)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('LL 190227 Medial+Lateral Array, *training data*')
hold off

figure; hold on
plot(ll_test_mean,'k.')
plot(mean(ll_test_mean,2),'b')
plot(mean(ll_test_mean,2) + mean(ll_test_std_err,2),'r')
plot(mean(ll_test_mean,2) - mean(ll_test_std_err,2),'r')
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('Log Likelihood 190227 Medial+Lateral Array, *test data*')

%% Plot Together

figure; hold on
plot(ll_train,'r.')
plot(ll_test_mean,'k.')
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('test data (black) and training data (red)')

%% distribution
figure; hold on
histogram(ll_train)
histogram(ll_test_mean,10)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('test data (black) and training data (red)')
