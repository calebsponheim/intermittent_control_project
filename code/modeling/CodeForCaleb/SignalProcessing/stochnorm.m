function a_nrm = stochnorm(a,dim)
% Normalize stochastic array.
%
% Normalize [a] such that the sum along [dim] will be 1. By default
%   normalizes alog rows.
%
% If all [a]'s value are non-positive, it is assumed that [a] is in 
%   log-space and result is also given in log-space.
%
% If [a] is a vector and [dim] is not given, normalizes the whole vector
%   (not per row).
%
% INPUT:
%   a - Array to normalize
%   dim - Dimension to normalize along.
%       By defualt dim=2, i.e- each row is normalized to sum to 1.
%       dim=0 or dim='all' will normalize such that sum(a(:))==1.


if nargin==1
    if ~iscolumn(a)
        dim=2;
    else
        dim=1;
    end
elseif dim(1)==0 || (ischar(dim) && strcmpi(dim,'all'))
    a_nrm = reshape(stochnorm(a(:)),size(a));
    return;
end
islog = all(a(:)<=0) ;
assert(islog ||  all(a(:)>=0) , ...
    [ 'Cannot determine if input is in log-space or not. ' ...
    'Values must be either all non-negative, or all non-positive.' ]);
if islog, a = exp(a); end
repdims = ones(size(size(a)));
repdims(dim) = size(a,dim);
a_nrm = a./repmat(sum(a,dim),repdims) ;
if islog, a_nrm = log(a_nrm); end