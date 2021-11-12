%%
for iTrial = 1:20:length(data)
    figure; hold on
    plot(data(iTrial).speed)
    hold off
end