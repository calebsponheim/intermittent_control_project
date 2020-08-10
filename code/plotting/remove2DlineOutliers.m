function [x,idx] = remove2DlineOutliers(x,prc)
 
%input: x: trials(rows) x samples(columns)
%       prc: percentage of trials to exclude. 
%
%output: x: data without nans and outliers
%        idx: original indices of remaining trials      
 
if prc>0
    idx = 1:size(x,1);
    
    %remove nans before removing data
    removeThese = isnan(x(:,1)); 
    idx(removeThese) = [];
    x(removeThese,:) = [];
    
    %remove outliers
    nTrials = size(x,1); nRemove = ceil(nTrials*prc/100);   
    dFromMean = sum(abs(x-median(x)),2);
    [~,b] = sort(dFromMean,'descend');
    
    idx(b(1:nRemove))  = [];
    x(b(1:nRemove),:)  = [];
end
 
end %function
