%%

figure; hold on; 

for iTrial = 1:length(data)
    plot(data(iTrial).speed); 
    plot(data(iTrial).move_relative_to_trial_start,data(iTrial).speed(round(data(iTrial).move_relative_to_trial_start)),'ro');
end