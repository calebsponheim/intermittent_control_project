function p = biasedstochastic(n,m,bias,preferinds)
% creates a [n,m] stochastic matrix [p] with a bias in each row.
% [p] is generated such that in each row i there is some j for which
% p(i,j)>=bias
% if [preferinds] is not given then j is chosen at random for each i.
% if [preferinds] is given then for each i, j = preferinds(i).
%
% EXAMPLE 1:
%   Generate a transition 3x3 matrix such that the tendancy to
%   stay in the same state is at least 0.5, i.e- a(i,i)>=0.5
%       a = biasedrand(3,3,0.5,1:3)
%
% EXAMPLE 2:
%   Generate a transition 3x3 matrix such that:
%       a(1,3)>=0.7 , a(2,1)>=0.7 , a(3,2)>=0.7
%       a = biasedrand(3,3,0.7,[3,1,2])

if bias==0
    p = renorm(rand(n,m),3,'rows');
    return;
end

if ~exist('preferinds','var'), preferinds=[]; end

p = zeros(n,m);
for i = 1 : n
    if isempty(preferinds)
        ind = randperm(m,1) == 1:m;
    else
        ind = preferinds(i) == 1:m ;
    end
    p(i,ind) = (1-bias)*rand + bias ;
    p(i,~ind) = renorm(rand(1,m-1),3)*(1-p(i,ind));
end