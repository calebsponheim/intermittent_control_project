%clean data (and/to detect spikes)

% for each useful task block (either RTP or center-out):
%     read raw data for all channels
%     filter (butter HP to be similar to typical spike shapes OR two way and median filter)
%     clean with PCA noise thing (I don't know what this is)
%     save in .dat for kilosort
%
%% params

clearvars;

session = {'190228a'; '190228b'; '190228c'; '190228d'; '190228e'; '190228f'; '190228g'};
dataDir = ['D:\vassilis\data\Breaux\' session{1}(1:6) '\'];
dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\20' session{1}(1:2) '\'  session{1}(1:6) '\'];
array = {'M1m';'M1l';'PMm';'PMl'};
chan2read = {'33:96';'1:32,97:128';'1:32,97:128';'33:96'};
nChannels = 64; monkey = 'Bx';
% % correctVideo = true;

%band pass two-way Best paper: 300 to 7500
f1 = 300; % lo frequency for bandpass
f2 = 7500; % hi frequency for bandpass
fs = 30000; % sampling rate
bw = (f2-f1)/2; f = f1+bw;

%%
%spike detection params (for wave_clus)
% par = set_parametersVP();
for iArray = 1:length(array)
    
    file2save = [dataDirServer 'Bx' session{1}(1:6) array{iArray} '_binary.dat'];
    fidW = fopen(file2save, 'w');

    for iBlock = 1%:size(session,1)
        rawFile = [dataDirServer 'Bx' session{iBlock} array{iArray}(1:2) '.ns6'];
        
        % ADD EVENTS FILE SITUATION HERE (actually we won't need that at all)
        % eventsFile = [dataDirServer session(1:6) '\Bx' session '_events.mat'];
        
        
        % load behavior
        % load trial start and trial end depending on array
        
        
        
        % nTrials = numel(trial_start);
        
        %
        % msBeforePeriOn = 1500; msAfterPeriOn = 3500; %for instructed delay
        % msBefore_trial_start = 1000; msAfter_trial_end = 3000; %for no delay
        % iBefore = msBefore_trial_start*30; iAfter = msAfter_trial_end*30 -1;
        %
        % nSamples() = ;
        
        %par = set_parametersVP();
        
        %for one direction filter
        halfOrd = 4;
        nyq = fs/2;   % nyquist frequency
        % Wn = [(f - bw)/nyq (f + bw)/nyq];  % band definition
        % [b,a] = butter(halfOrd, Wn); % get butterworth filter
        
        
        
        disp(['saving session ' session{iBlock} ' of array ' array{iArray} ' to dat.']);
        
        %     iStart = periOn_30k(iTrial) - iBefore;
        %     iEnd = periOn_30k(iTrial) + iAfter;
        metadata = openNSx(rawFile,'read','c:1','p:double');
        data_length = metadata.MetaTags.DataPoints;
        data_chunks = round(0:data_length/8:data_length);
        for iChunk = 1:length(data_chunks)-1
         eventdata = openNSx(rawFile, 'read',['c:' chan2read{iBlock}],['t:' num2str(data_chunks(iChunk)) ':' num2str(data_chunks(iChunk+1))],'sample','p:double'); % 't:0:10', 'min',
        
            d = eventdata.Data/4; % to get real volt
            d = d'; %time x channels

            %     dm = d - medfilt1(d,90);

            %     df = filter(b, a, d); %one way
            %     df = df - medfilt1(df,30); %this good for 1-way filtering. removes the afterspike dip of big spikes

            df = filterData(d, f, bw, fs); %two way
            df = df - medfilt1(df,31);

            df = int16(100*df);

            fwrite(fidW, df', 'int16');
        end
    end%for nBlocks
    fclose(fidW);
end%for nArrays

disp('saved spikes dat');
