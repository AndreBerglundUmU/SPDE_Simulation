function nextU = Manakov_Explicit_Exponential(currU,preCalc,h,dW,M,sigma)
        tempReal1 = ifft(currU(1:M));
        tempReal2 = ifft(currU(M+1:end));
        tempSq = h*1i*(absSq(tempReal1).^sigma + absSq(tempReal2).^sigma);
        % Full nonlinear step
        nonLinU = currU + [fft(tempSq.*tempReal1) ; fft(tempSq.*tempReal2)];
        % Full linear step (implicitly calculated)
        nextU = preCalc{1}(dW)\(preCalc{2}(dW)*nonLinU);
end



