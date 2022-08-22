function coarseProcs = coarseStochProc(finedProc,NVec)
% Using a fine stochstic process with the same length as the last element
% in NVec, calculate all coarser variants

    numN = length(NVec);
    refN = NVec(end);
    coarseProcs = cell(numN,1);
    % If we haven't taken a splitting into account
    
    if size(finedProc,2) == 1
        for n = 1:numN
            currN = NVec(n);
            scalingFactor = refN/currN;
            coarseProcs{n} = zeros(currN,1);
            for i = 1:currN
                indexList = ((i-1)*scalingFactor+1):(i*scalingFactor);
                coarseProcs{n}(i) = sum(finedProc(indexList));
            end
        end
    else
        for n = 1:numN
            currN = NVec(n);
            scalingFactor = refN/currN;
            coarseProcs{n} = zeros(currN,2);
            currIndex = 0;
            for i = 1:currN
                indexList = (currIndex+1):(currIndex+scalingFactor/2);
                coarseProcs{n}(i,1) = sum(sum(finedProc(indexList,:)));
                indexList = (currIndex+scalingFactor/2+1):(currIndex+scalingFactor);
                coarseProcs{n}(i,2) = sum(sum(finedProc(indexList,:)));
                currIndex = currIndex + scalingFactor;
            end
        end
    end
end