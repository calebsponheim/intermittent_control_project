function data_smoothed = gaussian_filt(data,kernel_size)

for iTrial = 1:size(data,2)
    for iUnit = 1:size(data(iTrial).spikecountresamp,1)
        x = data(iTrial).spikecountresamp(iUnit,:);
        x_padded = [zeros(1,1000) x zeros(1,1000)];
        w = gausswin(kernel_size);
%         y = conv(x_padded,w);
        y = filtfilt(w,1,x_padded);
%         y = smoothdata(x_padded,'gaussian',kernel_size);
       
%         figure;hold on;plot(x);plot(y);
%         close gcf
        y(y<0) = 0;
        y_cropped = y(1001:end-1000);
        data_smoothed(iTrial).spikecountresamp(iUnit,:) = y_cropped;
    end
end

end
