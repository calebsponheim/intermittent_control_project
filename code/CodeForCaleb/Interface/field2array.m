function [v,c] = field2array(fld,varargin)
% Collect all values from a field in structure array to a single array.
% INPUT:
%   field name , struct array
%
% OUTPUT:
%   v - numeric array if possible, otherwise- cell array.
%   c - cell array.

s = [varargin{:}] ;
c = cell(size(s));
for i = 1 : length(s)
    c{i} = s(i).(fld);
end
if all(cellfun(@isnumeric,c))
    if (length(c)==1) || (isrow(c{1})==isrow(c))
    	v = cell2mat(c) ;
    else
        v = cell2mat(c')' ;
    end
end