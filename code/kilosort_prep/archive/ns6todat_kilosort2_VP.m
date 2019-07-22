%clean data (and/to detect spikes)

% for each useful task block (either RTP or center-out):
%     read raw data for all channels
%     filter (copy params from kilosort2)
%     save in .dat for kilosort

%% params
clear;

% sessions = {'190228a'; '190228b'; '190228c'; '190228d'; '190228e'; '190228f'; '190228g'};
sessions = {'190227a'; '190227b'; '190227c'; '190227d'; '190227e'; '190227f'; '190227g'};

nFiles = size(sessions,1);

dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\20' sessions{1}(1:2) '\'  sessions{1}(1:6) '\'];
dataDirLocal = ['C:\Users\calebsponheim\Downloads\' sessions{1}(1:6) '\'];
if ~exist(dataDirLocal,'dir'), mkdir(dataDirLocal); end

arrays = {'M1m';'M1l';'PMm';'PMl'}; nArrays = length(arrays);
chan2read = {'33:96';'[1:32 97:128]';'[1:32 97:128]';'33:96'};
nChannels = 64; monkey = 'Bx';

%band pass two-way Best paper: 300 to 7500
f1 = 300; % lo frequency for bandpass
f2 = 7500; % hi frequency for bandpass
fs = 30000; % sampling rate
bw = (f2-f1)/2; f = f1+bw;

%%
for iArray = 1:nArrays
    
    file2save = [dataDirLocal 'Bx' sessions{1}(1:6) arrays{iArray} '_binary.dat'];
    fidW = fopen(file2save, 'w');

    for iFile = 1:nFiles
        rawFile = [dataDirServer 'Bx' sessions{iFile} arrays{iArray}(1:2) '.ns6'];
               
        disp(['saving session ' sessions{iFile} ' of array ' arrays{iArray} ' to dat.']);
        
        metadata = openNSx(rawFile,'read','c:1','p:int16');
        
        data_length = metadata.MetaTags.DataPoints;
        data_chunks = round(1:data_length/8:data_length);
        nChunks = length(data_chunks)-1;
        
        for iChunk = 1%:nChunks
         
            iData = openNSx(rawFile, 'read',['c:' chan2read{iArray}],...
                ['t:' num2str(data_chunks(iChunk)) ':' num2str(data_chunks(iChunk+1))],'sample','p:int16'); % 't:0:10', 'min',
        
%             d = iData.Data/4; % to get real volt
%             d = d'; %time x channels

%             df = filterData(d, f, bw, fs); %two way
% 
%             df = int16(100*df);

            count = fwrite(fidW, iData.Data, 'int16');
        end%for nChunks
        
    end%for nFiles
    fclose(fidW);
    
end%for nArrays

disp('saved spikes dat');