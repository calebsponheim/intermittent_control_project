function r = logsumexp(v,dim)
% the "log-sum-exp trick":
% computes: log( sum_i{ exp(v_i) } ) while accounting for numeric accuracy.
% this is usually used for summation when working in log-space.
% INPUT:
%   v - numeric array
%   dim - optional, dimension to sum over. default is none.

if isempty(v), r = -inf; return; end
m = max(v(:));
v = v-m ;
if nargin==2
    r = m + log(nansum(exp(v),dim));
else
    r = m + log(nansum(exp(v)));
end