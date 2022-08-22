function preCalc = Manakov_Lie_PreCalc(h,kSq,k,M,gamma)
%MANAKOV_LIE_PRECALC Summary of this function goes here
%   Detailed explanation goes here
preCalc = cell(5,1);

tempSpEye = speye(2*M);
kSqVec = -[kSq ; kSq];

spSecDer = 1i*h/2*spdiags(kSqVec,0,tempSpEye);
tempSecDer = -1i*h/2*kSq;
tempFirstDer = sqrt(gamma)/2*k;

preCalc{1} = tempSpEye - spSecDer;

% These are the four different parts of the matrix BV4
% We want to solve it without sparse allocation
preCalc{2} = @(dW) 1 + tempSecDer - 1i*tempFirstDer*dW(3);
preCalc{3} = @(dW) 1 + tempSecDer + 1i*tempFirstDer*dW(3);
preCalc{4} = @(dW) -sqrt(gamma)/2*(1i*dW(1) - dW(2))*k;
preCalc{5} = @(dW) -sqrt(gamma)/2*(1i*dW(1) + dW(2))*k;
end

