%% 50/50 to 50/25/25


[~,random_indices] = datasample(1:length(dc{end}),floor(length(dc{end})/2));

rowcount = 1;
columncount = 1;
for iStruct = 1:numel(dc)
    if rowcount == 31 ; rowcount = 1; columncount = columncount + 1; end
    if ~isempty(dc{iStruct})
        dc_ll_eval{rowcount,columncount} = dc{iStruct}(random_indices);
    end
    rowcount = rowcount + 1;
end



for iStatenum = 2:length(dc)
    for iRep = 1:size(dc,2)
        ll_test_temp(iStatenum-1,iRep,:) = [dc_ll_eval{iStatenum,iRep}.ll];
    end
end

ll_test_sum = sum(ll_test_temp,3);
ll_test = mean(ll_test_sum,2);


figure; hold on
plot(ll_test_sum,'ro')
plot(ll_test)
box off
set(gcf,'color','white')
xlabel('number of hidden states')
ylabel('log likelihood')
title('Bx RTP Log Likelihood *test data (25% of data)*') 
