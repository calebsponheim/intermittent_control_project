function s = randomsample(p,n)
% Random sample from disribution.
% Returns [s] with probability p(s).
% If p is a matrix, random sample is taken for each row.
%
% INPUT:
%   p - Probability vector, or matrix s.t each row is a probability vector
%   n - If n is scalar, its the number of outputs per sample.
%
% OUTPUT:
%   s - array of random values. possible values are 1..length(p)
%       if [p] is a vector, then [s] is a vector of length [n]
%       if [p] is a matrix with m rows, then [s] is a matrix of size m*n

if nargin==1, n=1; end
if length(n)==1, n=[1,n]; end

if size(p,1)>1 && n(1)==1
    s = zeros(size(p,1),n(2));
    for i = 1 : size(p,1)
        s(i,:) = randomsample(p(i,:),n);
    end
    return;
end

cs = cumsum(p);
rnd = rand(n);
s = zeros(n);
for i = 1 : numel(s)
    s(i) = sum(rnd(i)<=cs) ;
end
s = length(p) - s + 1 ;