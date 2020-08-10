function strct = StructInit(varargin)
% Initialize struct.
% Create a struct with specefied fields and size, where values are empty.
%
% EXAMPLES:
%   StructInit(field1,field2,...)       % 1d struct with given fields
%   StructInit([n m],field1,field2,...) % struct size n*m
%   StructInit(srcStrct)                % take field-names from [srcStrct] 
%
% INPUT:
%   - List of fields, or a structure to replicate its field names.
%   - Optional: First input can be the wanted struct size. Defualt = 1x1.
%     * Scalar size-input [n] is the same as [n,1] (i.e- column vector)
%
% EXAMPLE:
%
%   struct of size [1,1]:
%       strct = StructInit(field1,field2,...)
%
%   struct of size [n,m]:
%       strct = StructInit([n m],field1,field2,...)
%
%   struct of size [n,1]:
%       strct = StructInit(n,field1,field2,...)
%
%   replicate field names from an existing struct:
%       strct = StructInit(srcStrct)
%       strct = StructInit([n,m],srcStrct)

if isnumeric(varargin{1})
	% if first argument is size
    if length(varargin{1})==1
        % scalar --> coloumn vector
        sz = [varargin{1},1];
    else
        sz = varargin{1};
    end
	varargin = varargin(2:end);
else
    % default size is 1
	sz = [1,1];
end

if isstruct(varargin{1})
    flds = fields(varargin{1});
else
    flds = varargin;
end

% prepare struct:
v = cell(length(flds)*2,1) ;
v(1:2:end) = flds ;
strct = repmat( struct(v{:}) , sz );
