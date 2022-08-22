function preCalc = Manakov_Explicit_Exponential_PreCalc(h,kSq,k,M,gamma)
%MANAKOV_LIE_PRECALC Summary of this function goes here
%   Detailed explanation goes here
preCalc = cell(2,1);

tempSpEye = speye(2*M);
tempSpZero = spalloc(2*M,2*M,4*M);
kVec = 1i*[k ; k];
kSqVec = -[kSq ; kSq];
spSecDer =  1i*h/2*spdiags(kSqVec,0,tempSpEye);

pauli1 = spdiags([kVec,kVec],[-M,M],tempSpZero);
pauli2 = spdiags([1i*kVec,-1i*kVec],[-M,M],tempSpZero);
pauli3 = spdiags(1i*[k ; -k],0,tempSpZero);

spFirstDer = @(dW) sqrt(gamma)/2*(...
    dW(1)*pauli1+...
    dW(2)*pauli2+...
    dW(3)*pauli3...
    );

preCalc{1} = @(dW) speye(2*M) - spSecDer + spFirstDer(dW);
preCalc{2} = @(dW) speye(2*M) + spSecDer - spFirstDer(dW);
end

