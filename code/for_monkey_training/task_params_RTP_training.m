% generating TPs and target and blocks for Breaux RTP task

target_nums = [1:16];

target_skip = 2;

for iTP = 1:64
    for iTarget = 1:target_skip:7-target_skip
        target_order(iTP,iTarget) = datasample(target_nums,1);
        if iTarget > target_skip && target_order(iTP,iTarget) == target_order(iTP,iTarget-target_skip)
            protection = 0;
            while target_order(iTP,iTarget) == target_order(iTP,iTarget-target_skip) && protection < 1000
                target_order(iTP,iTarget) = datasample(target_nums,1);
                protection = protection + 1;
            end
        end
        target_order(iTP,iTarget:iTarget+target_skip) =  target_order(iTP,iTarget);
    end
end

possible_tps = 1:64;

for iBlock = 1:10
    tp_order(iBlock,:) = datasample(target_nums,24);
    allOneString{iBlock} = sprintf('%.0f,' , tp_order(iBlock,:));
    allOneString{iBlock} = allOneString{iBlock}(1:end-1);
end


