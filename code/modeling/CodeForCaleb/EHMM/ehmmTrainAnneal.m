function r = ehmmTrainAnneal(datasets,nStates,varargin)
% Train "extended" HMM model (HMM with multiple emissions per state).
% Use EM algorithm to learn the parameters of a dynamic naive bayesian
% network with HMM-like structure, with multiple emission nodes.
%
% INPUT:
%
%   datasets - cell array of data sets (observed sequences).
%       each cell contains a matrix of observed values.
%       rows = emission-node, cols = time-bin.
%       datasets{i}(k,t) is the obsevred value at time t in emission node k
%           in dataset i.
%	nStates - number of possible hidden-state values
%
% Optionals (give as 'property','value' pairs):
%
%   gibbs - use Gibbs sampling instead of EM. true \ {false}
%   nGibbsItrPcnt - If using Gibbs sampling- the number of sampling
%       iterations is [nGibbsItrPcnt]*[sequnece length]. default = 0.8
%   anneal - name of annealing schedule: 'none' \ {'log'} \ 'linear'
%   parametric - code of parametric disribution. {0=tabular} \ 1=Poisson
%   maxItr - max number of iterations (default = 500)
%   convergeEps - convergance delta (default = 10^-6)
%   initprobs - inital parameters.
%       struct with fields 'a','b','prior'. (default = rand)
%   persistBias - bias of the initial transition matrix to prefer
%       transitions from a state to itself. [persistBias] should be between
%       [0,1]. The transition matrix [a] is initialized such that a(i,i) is
%       at least [persistBias]. that is: a(i,i)>=[persistBias] for any i.
%       default = 0. (this is overrideden if [initprobs] are given).
%
% OUTPUT:
%
%   sturct with fields:
%       meta - meta data
%       prior - prior(i) == P( Q(t=1) = i )  **See Notation below
%       a - a(i,j) == P( Q(t+1)=j | Q(t)=i )
%       b - b(i,j,k) == P( O(t)=j | Q(t)=i  ) for emission-node k
%       ll - ll(m) is the log-liklihood after the m-th iteration
%       last_ll - is the log-liklihood after convergance or break
%       itr - number of itertations it took to converge
%
%   **Notation:
%       Q(t) is the hidden state at time t,
%       O(t) is obverved value at time t.

ACCURACY_EPS = log(10^-190) ;
CNVRG_DT = 2 ; 

% parse input:
defaultparams.gibbs = false;
defaultparams.nGibbsItrPcnt = 0.8;
defaultparams.annealParams = {};
defaultparams.maxItr = 500;
defaultparams.convergeEps = 10^-6 ;
defaultparams.minItr = 5;
defaultparams.parametric = 0;
defaultparams.initprobs = [];
defaultparams.persistBias = 0;
defaultparams.obsVals = [];
params = parseinput(defaultparams,varargin) ;
struct2vars(params);

if gibbs
    if iscell(datasets), datasets = [datasets{:}]; end
    maxItr = round(length(datasets)/2);
end
if ~iscell(datasets), datasets={datasets}; end
nSets = length(datasets);
sz = cell2mat(cellfun(@size,datasets,'UniformOutput',false)');
T_per_set = sz(:,2);
nEmissions = sz(1,1);

% re-enumerate training values, to make sure the value are 1,2,..nObs
ds_mat = horzcat(datasets{:});
[unqvals,~,unqinds] = unique(ds_mat);
datasets= mat2cell(reshape(unqinds,size(ds_mat)),nEmissions,T_per_set);
if isempty(obsVals)
    obsVals = unqvals(:)' ;
elseif ~all(ismember(unqvals(:),obsVals))
    error('Input observables must cover actual observable domain');
end
nObs = length(obsVals) ;

% get training set size:

fprintf('EM for %d states, %d emission nodes. %d observed values.\n',...
    nStates,nEmissions,nObs);
disp(params);

% initial parameters:
if isempty(initprobs)
    % random:
    a = biasedstochastic(nStates,nStates,persistBias,1:nStates);
    b = rand(nStates,nObs,nEmissions);
    prior = 1/nStates+0.3*(1/nStates)*(0.5-rand(nStates,1));
else
    % from input:
    a = initprobs.a ;
    b = initprobs.b ;
    prior = initprobs.prior ;
end
a = log(renorm(a,3,'rows'));
b = log(renorm(b,3,'rows'));
prior = log(renorm(prior,3));
startpoint = struct('a',exp(a),'b',exp(b),'prior',exp(prior));

% compute sum of b:
% bs(i,t) is the total log-probability of the observed emissions at time t,
% given that the hidden state was i at that time. i.e:
% bs(i,t) = P( o(1,t) , o(2,t) , .. , o(nEmissions,t) | Qt = i )

% dataset parameters struct:
dsparams=StructInit(nSets,'aa','bb','cc','ee','T','o','bs','bInd','cInd');

Confine.open; % all variables created in confined area are later cleared
for iSet = 1 : nSets
    ii = reshape(repmat(1:nStates,nEmissions,1),1,[]) ;
    kk = repmat(1:nEmissions,1,nStates) ;
    sz = size(b);
    T = T_per_set(iSet);
    bs = nan(nStates,T);
    bInd = zeros(T,nStates*nEmissions);
    o = datasets{iSet};
    for t = 1 : T
        jj = repmat(o(:,t)',1,nStates) ;
        bInd(t,:) = sub2ind(sz,ii,jj,kk) ;
        bs(:,t) = sum(reshape(b(bInd(t,:)),nEmissions,[]),1) ;
    end
    
    cInds = false(nEmissions,nObs,T);
    for k = 1 : nEmissions
        for v = 1 : nObs
            cInds(k,v,:) = o(k,:)==v ;
        end
    end
    dsparams(iSet).cInds = cInds ;
    dsparams(iSet).bInd = bInd ;
    dsparams(iSet).bs = bs;
    dsparams(iSet).o = o;
    dsparams(iSet).T = T;
    
    if gibbs
        dsparams(iSet).nGibbsItr = round(nGibbsItrPcnt*T);
        dsparams(iSet).Q = randi(nStates,[1,T]);
    else
        dsparams(iSet).nGibbsItr = [];
        dsparams(iSet).Q = [];
    end
    
    dsparams(iSet).aa = nan(nStates,dsparams(iSet).T); % log-alpha
    dsparams(iSet).aa(:,1) = prior+bs(:,1);
    dsparams(iSet).bb = nan(nStates,dsparams(iSet).T); % log-beta
    dsparams(iSet).bb(:,end) = 0;
end
Confine.close % clear variables from confined area



% -------------------------------------------------------------------------
% CORE:
sam = SimulatedAnnealingManager(annealParams{:});
annealMsg = '';
msgclr = 'k';
action = 0 ;
ll = nan(1,maxItr); % log-liklihood
for itr = 1 : maxItr
    
    if ~gibbs
    
    % filter current parameters and get likelihood:
    [dsparams,current_ll] = nested_forwardBackward(a,b,dsparams);
    
    % ---------------------------------------------------------------------
    % Anneal-Step:
    
    if sam.isAnneal
        % perturb currnet parameters:
        [cand.a,cand.b,cand.prior] = nested_perturbeParams(a,b,prior);
        
        % filter perturbed parameters and get "perturbed" likelihood:
        [cand.dsparams,cand_ll] = ...
            nested_forwardBackward(cand.a,cand.b,dsparams);
        
        dE = current_ll - cand_ll ;
        [action,msg] = sam.step(dE);
        annealMsg = [ 'Anneal status: ' msg ];
        clrs = { 'cyan' 'm' 'y' 'g' };
        msgclr = clrs{action+2};
    else
        annealMsg = '';
        msgclr = 'k';
        action = 0 ;
    end
    
    if action>0
        a = cand.a;
        b = cand.b;
        prior = cand.prior;
        dsparams = cand.dsparams ;
        ll(itr) = cand_ll;
    else
        ll(itr) = current_ll;
    end
    
    
    
    % ---------------------------------------------------------------------
    % E-Step:
    
    for iSet = 1 : nSets
        struct2vars(dsparams(iSet));
        
        % log-gamma:
        cc = aa+bb - repmat( logsumexp(aa+bb,1) , nStates , 1 );
        
        
        % log-eta:
        ee = nan(nStates,nStates,T); % log-eta
        tt = 1 : T-1 ;
        for i = 1 : nStates
            for j = 1 : nStates
                ee(i,j,tt)=cc(i,tt)+a(i,j)+bs(j,tt+1)+bb(j,tt+1)-bb(i,tt);
            end
        end
        
        dsparams(iSet).cc = cc;
        dsparams(iSet).ee = ee;
    end
    
        
    % ---------------------------------------------------------------------
    % M-Step
    
    % transitions & emissions:
    ee_sum = nan(nStates,nStates,nSets);
    prior_sum = nan(nStates,nSets);
    cc_sum = nan(nStates,nStates,nSets);
    cc2 = nan(nStates,nObs,nEmissions,nSets);
    cc3 = nan(nStates,nObs,nEmissions,nSets);
    parfor iSet = 1 : nSets
        cc = dsparams(iSet).cc;
        ee = dsparams(iSet).ee;
        cInds = dsparams(iSet).cInds;
        
        prior_sum(:,iSet) = cc(:,1);
        
        cc_sum(:,:,iSet) = repmat(logsumexp(cc(:,1:end-1),2),1,nStates);
        ee_sum(:,:,iSet) = logsumexp(ee(:,:,1:end-1),3) ;
        
        cc3(:,:,:,iSet) = repmat(logsumexp(cc,2),1,nObs,nEmissions);

        for i = 1 : nStates
            for k = 1 : nEmissions
                for v = 1 : nObs
                    cc2(i,v,k,iSet) = logsumexp(cc(i,cInds(k,v,:)));
                end
            end
        end
        
    end
    a = logsumexp(ee_sum,3) - logsumexp(cc_sum,3) ;
    b = logsumexp(cc2,4) - logsumexp(cc3,4) ;
    prior = logsumexp(prior_sum,2) - log(nSets);
    
    else % TODO: check & complete by Jordan's
        
        aaa = nan(nStates,nStates,nSets);
        bbb = nan(nStates,nEmissions,nSets);
        for iSet = 1 : nSets
            struct2vars(dsparams(iSet));
            if itr < 3
                t_rands = randi(T-2,[1,1*nGibbsItr])+1;
            else
                t_rands = randi(T-2,[1,nGibbsItr])+1;
            end
            for iGibbs = 1 : length(t_rands)
                t = t_rands(iGibbs);
                pGibbs = stochnorm(exp(a(Q(t+1),:)'+a(:,Q(t-1))+bs(:,t)));
                Q(t) = randomsample(pGibbs',1);
            end
            dsparams(iSet).Q = Q ;
            
            for i = 1 : nStates
                Qi_inds = Q(1:end-1)==i ;
                Qi_mean = mean(Qi_inds) ;
                for j = 1 : nStates
                    aaa(i,j,iSet) = mean(Qi_inds & Q(2:end)==j);
                end
                aaa(i,:,iSet) = aaa(i,:,iSet)/Qi_mean;
                
                for k = 1 : nObs
                    bbb(i,k,iSet) = mean(Qi_inds & o(1:end-1)==k);
                end
                bbb(i,:,iSet) = bbb(i,:,iSet)/Qi_mean;
            end
        end
            a = log(mean(aaa,3));
            b = log(mean(bbb,3));
    end
    if parametric==1
        lmbda = ehmmTabular2Parametric(exp(b),parametric);
        b = log(nested_Poisson2Tabular(lmbda,obsVals));
    end
    b(b(:)<ACCURACY_EPS) = ACCURACY_EPS ;
    b(b(:)>0) = 0;
    if parametric==0
        b = stochnorm(b);
    end

    a(a(:)<ACCURACY_EPS) = ACCURACY_EPS ;
    a(a(:)>0) = 0;
    a = log(renorm(exp(a),3,'rows'));
    

    prior(prior(:)<ACCURACY_EPS) = ACCURACY_EPS ;
    prior(prior(:)>0) = 0;
    prior = log(renorm(exp(prior),3));
    
    dsparams = nested_sumOfEmissionProbs(b,dsparams);
    
    % ---------------------------------------------------------------------
    % Assess progress
    
    if itr >= CNVRG_DT+2
        dll = 1 - (ll(itr+(-CNVRG_DT:0))./ll(itr-1+(-CNVRG_DT:0)));
    else
        dll = inf;
    end
    fprintf(...
        'Itr %d, LL= %f (%f). %s',...
        itr,ll(itr),dll(end)/convergeEps...
        );
    cprintf(msgclr,[ annealMsg '\n' ]);
    if (itr >= minItr) && (all(abs(dll) < convergeEps)), break; end
    
end

% -------------------------------------------------------------------------
% PREPARE OUTPUT:

[~,si] = sort(diag(a),'descend');

% prepare output:
r.meta.type = 'trained' ;
r.meta.params = params ; % input parameters
r.meta.startpoint = startpoint ; % actual starting conditions
r.annealing = sam.getHistory(); % annealing's energy (LL) diff

r.prior = exp(prior(si)); % estimated prior
r.a = exp(a(si,si)); % estimated transitions
if parametric==0
    r.b = exp(b(si,:,:)); % estimated emissions
elseif parametric==1
    r.b = lmbda(si,:,:);
end
r.ll = ll(1:itr) ; % log-likelihood per iteration
r.last_ll = ll(itr); % final log-likelihood
r.nItr = itr ; % number of iterations

nested_annealStats(sam);

return;


% -------------------------------------------------------------------------
% NESTED FUNCTIONS:

function b = nested_Poisson2Tabular(lmbda,obsVals)
nStates = size(lmbda,1);
nEmissions = size(lmbda,3);
[nn,ii] = meshgrid(obsVals,1:nStates);
nn = nn(:);
ii = ii(:);
b = nan(nStates,length(obsVals),nEmissions);
for k = 1 : nEmissions
    tmp = lmbda(ii,:,k).^nn./factorial(nn).*exp(-lmbda(ii,:,k)) ;
    b(:,:,k) = reshape(tmp,nStates,length(obsVals)) ;
end

return

function dsparams = nested_sumOfEmissionProbs(b,dsparams)
% compute "sum of b"
nEmissions = size(b,3);
for iSet = 1 : length(dsparams)
    bInd = dsparams(iSet).bInd ;
    T = dsparams(iSet).T;
    dsparams(iSet).bs = ...
        squeeze(sum(reshape(b(bInd)',nEmissions,[],T),1));
end

function [a,b,prior] = nested_perturbeDiag(a,b,prior)
nStates = size(a,1);
Kd = 5; % the steepness of the possible increase in diag
Ko = 5; % the steepness of the possible increase outside diag
FCTR = nStates ;
nChanges = round(nStates*0.5) ;
p = exp(a);
% the probability to choosing a coloumn to increase, given a row. i.e:
% P( j | i ) = M(i,j)
M = stochnorm(eye(nStates)*FCTR + ~eye(nStates));
K = eye(nStates)*Kd + ~eye(nStates)*Ko; % steepnesses (for easier access)

% rows to perturb this round:
ii = randperm(nStates,nChanges);

% cols to perturb.
% there's more chance of chosing a column on the diagonal.
jj = randomsample(M(ii,:));

% increase the value of the chosen parameters. the increase is done such
% that the lower the value is, the greater the increase it can get. i.e- in
% the extreme case where a value is equal to 1, no increase can be made.
rnds = rand(1,nChanges);
for ind = 1 : nChanges
    i = ii(ind); j = jj(ind);
    currentval = p(i,j) ;
    maxval = log(1+K(i,j)*currentval)./log(1+K(i,j)) ;
    inc = (maxval-currentval)*rnds(ind) ;
    p(i,j) = currentval + inc ;
end
p = stochnorm(p);
a = log(p);

function [a,b,prior] = nested_perturbeParams(a,b,prior)
[a,b,prior] = nested_perturbeDiag(a,b,prior);
return
UNIFORM_PROB = 0.2 ;
PERTURBE_ONLY_TRANSITIONS = true ;
persistent pertube_a sig_a sig_b nPermutes_a nPermutes_b
if isempty(pertube_a)
    pertube_a = true;
    sig_a = 0.2;
    sig_b = 0.2;
    nPermutes_a = ceil(numel(a)*0.1) ;
    nPermutes_b = ceil(numel(b)*0.1) ;
end
pertube_a = PERTURBE_ONLY_TRANSITIONS || ~pertube_a ;
if pertube_a
    p = exp(a) ;
    sig = sig_a;
    nPermutes = nPermutes_a ;
else
    p = exp(b);
    sig = sig_b;
    nPermutes = nPermutes_b ;
end
inds = randperm(numel(p),nPermutes);
for ind = inds(:)'
    new_val = -1;
    while new_val>1 || new_val<0
        new_val = p(ind)+sig*randn;
    end
    p(ind) = new_val;
end
if pertube_a
    nStates = size(p,1);
    for i = 1 : nStates
        [~,ii] = max(p(i,:));
        if ii~=i
            if rand < UNIFORM_PROB
                p(i,:) = 1/nStates+0.3*(1/nStates)*(0.5-rand(nStates,1));
            else
                p(i,:) = p(i,circshift(1:nStates,[1,i-ii])) ;
            end
        end
    end
end
p = log(renorm(p,3,'row'));
if pertube_a
    a = p ;
else
    b = p;
end


function [dsparams,ll] = nested_forwardBackward(a,b,dsparams)

dsparams = nested_sumOfEmissionProbs(b,dsparams);
nStates = size(a,1);
ll = 0;
for iSet = 1 : length(dsparams)
    struct2vars(dsparams(iSet));
    for t = 1 : T-1
        bt = T-t;
        for j = 1 : nStates
            % forward process (log-alpha):
            aa(j,t+1) = bs(j,t+1)+logsumexp(aa(:,t)+a(:,j)) ;
            % backward process (log-beta):
            bb(j,bt) = logsumexp(bb(:,bt+1)+a(j,:)'+bs(:,bt+1)) ;
        end
    end
    dsparams(iSet).aa = aa;
    dsparams(iSet).bb = bb;
    ll = ll + logsumexp(aa(:,end));
end



function nested_annealStats(sam)
if ~sam.isAnneal, return; end
ah = sam.getHistory();
pBetter = mean( ah.action == 2 );
pChance = mean( ah.action == 1 );
disp('-- Annealing statistics:');
fprintf('Portion of times candidate was better: %f\n',pBetter);
fprintf('Portion of times candidate was chosen by chance: %f\n',pChance);
disp('--');





