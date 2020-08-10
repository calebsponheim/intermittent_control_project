function hn = ehmmParametric2Tabular(hn)

if isfield(hn.meta.params,'parametric')
    parametric = hn.meta.params.parametric ;
else
    parametric = 0;
end

if parametric==0
    return
elseif parametric==1
    NMAX = 10 ;
    EPS = 0.5*10^-2 ;
    lmbda = hn.b ;
    nStates = size(hn.b,1);
    nEmissions = size(hn.b,3);
    b = nan(nStates,NMAX,nEmissions);
    for i = 1 : nStates
        for k = 1 : nEmissions
            for n=0:NMAX-1
                b(i,n+1,k) = ...
                    lmbda(i,:,k).^n ./factorial(n) .*exp(-lmbda(i,:,k));
            end
        end
    end
    b = b(:,any(any(b>EPS,1),3),:);
    hn.b = stochnorm(b);
end