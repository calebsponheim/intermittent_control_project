function data_velocity_aligned = align_to_velocity_peak_and_crop(data,crop_window)

for iTrial = 1:size(data,2)
    [vel_peak_vals,velocity_peak_indices] = findpeaks(data(iTrial).speed);
    velocity_peak_index = velocity_peak_indices(vel_peak_vals == max(vel_peak_vals));
    if velocity_peak_index+crop_window(2) <= length(data(iTrial).speed)
        data_velocity_aligned(iTrial).spikecountresamp = data(iTrial).spikecountresamp(:,velocity_peak_index+crop_window(1) : velocity_peak_index+crop_window(2));
        data_velocity_aligned(iTrial).speed = data(iTrial).speed(velocity_peak_index+crop_window(1) : velocity_peak_index+crop_window(2));
        data_velocity_aligned(iTrial).ms_relative_to_trial_start = 1:(abs(crop_window(1)) + abs(crop_window(2))+1);
    end
end