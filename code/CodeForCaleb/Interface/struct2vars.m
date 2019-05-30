function struct2vars(s,prfx)
% Create variables and set their values for a structure.
% 
% INPUT:
%   s - struct
%   prfx - optional prefix of variable names. see example below.
%
% EXAMPLE:
%   s.name = 'Joe'
%   s.id = 123;
%
%	struct2vars(s)
%       will create variables called 'name' and 'id' with their
%       corrisponding values.
%
%   struct2vars(s,'data_') 
%       will create variables called 'data_name' and 'data_id' with their
%       corrisponding values.

assert( length(s)==1 , 'function does not support structs with length>1');
if ~exist('prfx','var'), prfx=''; end

flds = fields(s);
for i = 1:length(flds)
    assignin( 'caller' , [ prfx flds{i} ] , s.(flds{i}) ) ;
end