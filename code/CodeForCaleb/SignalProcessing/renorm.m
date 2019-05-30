function a = renorm(a,method,dim)
% Normalize values in array.
%
% EXAMPLES:
%
%   renorm(M,'std','col')  - Standartize each coloum in M
%   renorm(M,'sum','row')  - Normalize such that each row sums to 1
%   renorm(M,'max','full') - Normalize whole array between 0 and 1
%
% INPUT:
%
%   a - Array to normalize
%
%   method - String. Normalization method:
%          'max' - Subtract min,  divide by max
%          'std' - Subtract mean, divide by std
%          'sum' - Divide by sum
%
%   dim - Optional. Dimension to normalize.
%         Either numeric, or string: 'row'/'col'/{'full'}
%         * Can be given also by first letters: 'r'/'c'/'f'
%

% Hande normalization along rows/cols:
sz = [];
if ~exist('dim','var') || dim(1)=='f'
    sz = size(a);
    a = a(:);
    dim = 1;
elseif ischar(dim)
    dim = find(dim(1)=='cr');
end

% Convert string method to index:
if ischar(method)
    method = find(strcmpi(method,{'max','std','sum'}));
end

% Core:
if method==1
    a = a - dimfit(nanmin(a,[],dim),a);
    a = a ./ (dimfit(nanmax(a,[],dim),a)+eps);
elseif method==2
    a = a - dimfit(nanmean(a,dim),a);
    a = a ./ (dimfit(nanstd(a,[],dim),a)+eps);
elseif method==3
    a = a ./ dimfit(nansum(a,dim),a);
end

% If array was resized- convert back to original size:
if ~isempty(sz), a = reshape(a,sz); end
