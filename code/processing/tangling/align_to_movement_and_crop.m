function data_movement_aligned = align_to_movement_and_crop(data,crop_window)
[data] = detect_movement_time(data);
for iTrial = 1:size(data,2)
    movement_index = round(data(iTrial).move_relative_to_trial_start);
    data_movement_aligned(iTrial).spikecountresamp = data(iTrial).spikecountresamp(:,movement_index+crop_window(1) : movement_index+crop_window(2));
    data_movement_aligned(iTrial).speed = data(iTrial).speed(movement_index+crop_window(1) : movement_index+crop_window(2));
    data_movement_aligned(iTrial).ms_relative_to_trial_start = 1:(abs(crop_window(1)) + abs(crop_window(2))+1);
end