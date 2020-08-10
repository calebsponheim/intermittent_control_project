% generating TPs and target and blocks for Breaux RTP task

target_nums = [1:16];
tps = 1:64;

for iTP = 1:64
    for iTarget = 1:6
        target_order(iTP,iTarget) = datasample(target_nums,1);
        if iTarget > 1 && target_order(iTP,iTarget) == target_order(iTP,iTarget-1)
            protection = 0;
            while target_order(iTP,iTarget) == target_order(iTP,iTarget-1) && protection < 1000
                target_order(iTP,iTarget) = datasample(target_nums,1);
                protection = protection + 1;
            end
        end
    end
    target_order(iTP,7:7) = target_order(iTP,6);
end

possible_tps = 1:64;

for iBlock = 1:10
    tp_order(iBlock,:) = datasample(tps,24);
    allOneString{iBlock} = sprintf('%.0f,' , tp_order(iBlock,:));
    allOneString{iBlock} = allOneString{iBlock}(1:end-1);
end


