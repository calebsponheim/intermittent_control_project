function data = detect_movement_time(data)


for iTrial = 1:size(data,2)
% get avg and sd of speed from the beginning of the hold period to the go + 100ms
speed_mean = mean(data(iTrial).speed(round(data(iTrial).periOn_relative_to_trial_start):round((data(iTrial).go_relative_to_trial_start))));
speed_std = std(data(iTrial).speed(round(data(iTrial).periOn_relative_to_trial_start):(round(data(iTrial).go_relative_to_trial_start))));
% detect the first moment the speed goes beyond 1 sd of that baseline
temp_speed = data(iTrial).speed;
temp_speed(1:(round((data(iTrial).go_relative_to_trial_start))+100)) = 0;
move_time_ms = find(temp_speed > speed_mean+(speed_std), 1 );
data(iTrial).move_relative_to_trial_start = move_time_ms;
end


end