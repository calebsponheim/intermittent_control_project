function [dc,data,meta] = decode_trials(hn_trained,data,meta)
% Needed functionality: adding dc results to "data" 
% Maybe add tag for "cleaning/thresholding" the dc, with the "threshold"
% function nested in here? just a "0" or "1".


dc = ehmmDecode(hn_trained,testset);

end
