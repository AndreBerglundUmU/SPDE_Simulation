function nextU = Manakov_Lie_Splitting(currU,preCalc,h,dW,M,sigma,gamma,PauliMats)

% Full nonlinear step
tempReal1 = ifft(currU(1:M));
tempReal2 = ifft(currU(M+1:end));
tempSq = h*1i*(absSq(tempReal1).^sigma + absSq(tempReal2).^sigma);
nonLinU1 = exp(tempSq).*tempReal1;
nonLinU2 = exp(tempSq).*tempReal2;

U1 = fft(nonLinU1);
U2 = fft(nonLinU2);

% Full linear step
% Derivative information
spFirstDer = sqrt(gamma)/2*(...
	dW(1)*PauliMats{1}+...
	dW(2)*PauliMats{2}+...
	dW(3)*PauliMats{3}...
	);
AV4 = preCalc{1} + spFirstDer;

nextU = AV4\[preCalc{2}(dW).*U1 + preCalc{5}(dW).*U2;...
	preCalc{3}(dW).*U2 + preCalc{4}(dW).*U1];
end