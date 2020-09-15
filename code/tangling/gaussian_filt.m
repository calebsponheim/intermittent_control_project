function data_smoothed = gaussian_filt(data,kernel_size)

for iTrial = 1:size(data,2)
    for iUnit = 1:size(data(iTrial).spikecountresamp,1)
        x = data(iTrial).spikecountresamp(iUnit,:);
        w = gausswin(kernel_size);
        y = filtfilt(w,1,x);
%         figure;hold on;plot(x);plot(y);
%         close gcf
        y(y<0) = 0;
        data_smoothed(iTrial).spikecountresamp(iUnit,:) = y;
    end
end

end
