%clean data (and/to detect spikes)

% for each useful task block (either RTP or center-out):
%     read raw data for all channels
%     save in .dat for kilosort

%% params
% addpath(genpath(pwd));
clear;

% sessions = {'190228a'; '190228b'; '190228c'; '190228d'; '190228e'; '190228f'; '190228g'};
sessions = {'190227a'; '190227b'; '190227c'; '190227d'; '190227e'; '190227f'; '190227g'};

nFiles = size(sessions,1);

dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\20' sessions{1}(1:2) '\'  sessions{1}(1:6) '\'];
dataDirLocal = ['C:\Users\calebsponheim\Downloads\' sessions{1}(1:6) '\'];
if ~exist(dataDirLocal,'dir'), mkdir(dataDirLocal); end

arrays = {'M1m';'M1l';'PMm';'PMl'}; nArrays = length(arrays);
chan2read = {'33:96';'1:32,97:128';'1:32,97:128';'33:96'};
nChannels = 64; monkey = 'Bx';

%%
chunkFile = [dataDirServer 'Bx' sessions{1}(1:6) '_chunks.mat'];
save(chunkFile,'sessions');

for iArray = 1:nArrays
    
    file2save = [dataDirLocal 'Bx' sessions{1}(1:6) arrays{iArray} '_binary.dat'];
    fidW = fopen(file2save, 'w');

    chunkData = nan(nFiles,9); fileSizes = nan(nFiles,1);
    for iFile = 1:nFiles
        rawFile = [dataDirServer 'Bx' sessions{iFile} arrays{iArray}(1:2) '.ns6'];
               
        disp(['saving session ' sessions{iFile} ' of array ' arrays{iArray} ' to dat.']);
        
        metadata = openNSx(rawFile,'read','c:1','p:short');
        
        data_length = metadata.MetaTags.DataPoints;
        data_chunks = round(0:data_length/8:data_length);
        data_chunks(end)= data_chunks(end)-103; %readNSx will not read the end of the file(why?), so discard last 103 samples
        data_length = data_length-103;
        
        nChunks = length(data_chunks)-1;
        
        for iChunk = 1:nChunks       
            iData = openNSx(rawFile, 'read',['c:' chan2read{iArray}],...
                ['t:' num2str(data_chunks(iChunk)+1) ':' num2str(data_chunks(iChunk+1))],'sample','p:short'); % short = int16',
        
            d = iData.Data;
            
            count = fwrite(fidW, d, 'int16'); % input should be in channels x time 
            disp(['wrote ' num2str(count/64) ' from chunk' num2str(iChunk) ...
                '(size: ' num2str(data_chunks(iChunk+1) - data_chunks(iChunk)) ')']);
        end%for nChunks
        
        chunkData(iFile,1:nChunks+1) = data_chunks;
        fileSizes(iFile) = data_length;
    end%for nFiles
    fclose(fidW);
    
    eval(['Bx' sessions{iFile}(1:6) arrays{iArray} '_chunks = chunkData;']); 
    eval(['Bx' sessions{iFile}(1:6) arrays{iArray} '_dataLengths = fileSizes;']); 
    save(chunkFile,['Bx' sessions{iFile}(1:6) arrays{iArray} '_chunks'],...
        ['Bx' sessions{iFile}(1:6) arrays{iArray} '_dataLengths'],'-append');
end%for nArrays

disp('saved spikes dat');
