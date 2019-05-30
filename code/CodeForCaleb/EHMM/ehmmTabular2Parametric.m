function b = ehmmTabular2Parametric(b,parametric)

if parametric==0
    return
elseif parametric==1
    nObs = size(b,2);
    b = sum( b .* dimfit(0:nObs-1,b) , 2 );
end