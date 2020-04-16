function [EMG_signals_out] = process_CO_EMGs_CS(EMG_signals_in)

%% EMG Processing
%Steps
% 1. Record at 10k
% 2. Notch filter at 60hz
% 3. Lowpass at 1k hz (due to downsampling)
% 4. Downsample
% 5. Maybe highpass at 10-15hz
% 6. Rectify
% 7. Lowpass (to smooth)
% 8. Format for HMM


for iMuscle = 1:length(EMG_signals_in)
    for iTrial = 1:length(EMG_signals_in{iMuscle})
        %% Lowpass at 1k hz
        sampling_rate = 2000;
% 
%         dt=1/sampling_rate; % defining timestep size
%         fN=sampling_rate/2; 
% 
%         fhs=1000;           % lowpass frequency?
% 
%         [b,a]=butter(2,fhs/fN);
% 
%         filt_lowpass_1k = filtfilt(b,a,EMG_signals_in{iMuscle}{iTrial}); % running bandpass filter.
        %% downsample

        %% highpass at 10-15 hz
        dt=1/sampling_rate; % defining timestep size
        fN=sampling_rate/2; 

        fhs=10;           % highpass frequency filter?

        [b,a]=butter(2,fhs/fN,'high');

        lo1k_resamp_hi10 = filtfilt(b,a,EMG_signals_in{iMuscle}{iTrial}); % running bandpass filter.

        %% Rectify
        rectified_filtered_resampled = abs(lo1k_resamp_hi10);

        %% Smooth (another lowpass)

        fhs=10; % lowpass frequency

        [b,a]=butter(2,fhs/fN);

        final_lowpass_data = filtfilt(b,a,rectified_filtered_resampled); % running bandpass filter.
        
        %% Move into EMG_out
        
        EMG_signals_out{iMuscle}{iTrial} = final_lowpass_data;
    end %iTrial
end %iMuscle
end 