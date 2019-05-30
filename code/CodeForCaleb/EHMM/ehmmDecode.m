function r = ehmmDecode(hn,o,varargin)
% Decode Extended-HMM.
% For a given EHMM network, and observed sequences, computes the
% probability of each latent state in each time bin.
%
% INPUT:
%   hn - ehmm struct with fields:
%       prior - prior(i) == P( Q(t=1) = i )  **See Notation below
%       a - a(i,j) == P( Q(t+1)=j | Q(t)=i )
%       b - b(i,j,k) == P( O(t)=j | Q(t)=i  ) for emission-node k
%
%   o - Option 1: 
%        matrix of observed values. rows = emission-node, cols = time-bin.
%        o(k,t) is the obsevred value at time t in emission node k.
%
%       Option 2:
%        cell array where each cell contains a matrix as defined in 
%        Option 1. each cell is decoded seperately.
%
%   **Notation:
%       Q(t) is the hidden state at time t,
%       O(t) is obverved value at time t.
%
%
% OUTPUT:
%   r- struct with fields:
%       prob - prob(i,t) is the probability of state i at time-bin t
%       maxprob_state - maxprob_state(t) is the state with the highest
%           probability at time-bin t
%       maxprob_prob - maxprob_prob(t) is the highest prob. at time-bin t
%       ll - the log-liklihood obtained by the decoding
%
%   ** if multiple seqeunces are given (i.e o is given a cell array), then
%       r(i) corrisponds to o{i}.


if iscell(o)
    for i = 1 : length(o)
        r(i) = ehmmDecode(hn,o{i},varargin{:});
        if i==1, r = repmat(r(i),size(o)); end
    end
    return;
end

defaults.neurons = [];
params = parseinput(defaults,varargin);

% expand values and transform to log-space:
a = log(hn.a);
b = log(hn.b);
prior = log(hn.prior);

% re-enumerate data values
[unq,~,unqinds] = unique(o);
o = reshape(unqinds,size(o));

% use specefied neurons
% @ Keep after unique(o) to make sure all o-values are considered.
if ~isempty(params.neurons)
    b = b(:,:,params.neurons);
    o = o(params.neurons,:);
end

T = size(o,2);
nStates = size(b,1);
nEmissions = size(b,3);

assert(size(o,1) == nEmissions, ...
    'Number of rows in data must match number of emission nodes.');
assert(length(unq) <= size(b,2), ...
    'Number of observed values is larger than in training set.');

% compute sum of b:
% bs(i,t) is the total log-probability of the observed emissions at time t,
% given that the hidden state was i at that time. i.e:
% bs(i,t) = P( o(1,t) , o(2,t) , .. , o(nEmissions,t) | Qt = i )
ii = reshape(repmat(1:nStates,nEmissions,1),1,[]) ;
kk = repmat(1:nEmissions,1,nStates) ;
sz = size(b);
bs = nan(nStates,T);
bInd = zeros(T,nStates*nEmissions);
for t = 1 : T
    jj = repmat(o(:,t)',1,nStates) ;
    bInd(t,:) = sub2ind(sz,ii,jj,kk) ;
    bs(:,t) = sum(reshape(b(bInd(t,:)),nEmissions,[]),1) ;
end

% allocate memory:
aa = nan(nStates,T); % log-alpha
bb = nan(nStates,T); % log-beta

% *
% forward-backward:
% set log-alpha & log-beta values, and start iterating:
aa(:,1) = prior+bs(:,1);
bb(:,T) = 0;
for t = 1 : T-1
    bt = T-t;
    for j = 1 : nStates
        % forward process (log-alpha):
        aa(j,t+1) = bs(j,t+1)+logsumexp(aa(:,t)+a(:,j)) ;
        % backward process (log-beta):
        bb(j,bt) = logsumexp(bb(:,bt+1)+a(j,:)'+bs(:,bt+1)) ;
    end
end

% log-prob of state given data and params (log-gamma)
cc = aa+bb;
for t = 1 : T
    cc(:,t) = cc(:,t)-logsumexp(aa(:,t)+bb(:,t)) ;
end

% output:
r.prob = exp(cc);
[r.maxprob_prob,r.maxprob_state] = max(r.prob,[],1);
r.ll = logsumexp(aa(:,T));
