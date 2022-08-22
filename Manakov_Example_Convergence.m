 addpath(genpath(pwd))
currFileName = [mfilename '.m'];

batchSize = 8;
smallerBatchSize = 4;
numSmallerBatches = batchSize/smallerBatchSize;

mkdir('Data')

%% !! Experiment Specs - Identifies unique experiment
% Time info
T = 1; % Time horizon
NVec = 2.^[9:13,14]; % Number of time steps

% Spatial info
M = 2^10; % Number of spatial points / Fourier modes
L = 20*pi; % Interval radius
XInt = [-L,L]; % Interval
dx = (XInt(2)-XInt(1))/M; % Spatial grid step size
x = XInt(1) + dx*(0:M-1); % Spatial grid
k = 2*pi/(XInt(2)-XInt(1))*[0:M/2, -M/2+1:-1]'; % Fourier modes

% Initial value
iv1 = @(x) exp(-3*x.^2);
iv2 = @(x) exp(-3*(x-3).^2);
u0 = [fft(iv1(x)),fft(iv2(x))].';

% Misc. model info
sigma = 1; % Nonlinearity power
gamma = 1; % Noise power
stochProc = @(N,h) randn(N,3)*sqrt(h);
backupName = 'Data/ManakovExample'; % Data file name

% Pauli matrices (sparse)
tempSpZero = spalloc(2*M,2*M,4*M);
kVec = 1i*[k ; k];
kSq = absSq(k);
PauliMats = {spdiags([kVec,kVec],[-M,M],tempSpZero);
    spdiags([1i*kVec,-1i*kVec],[-M,M],tempSpZero);
    spdiags(1i*[k ; -k],0,tempSpZero)};

% Scheme info
schemes = {@(currU,preCalc,h,dW) Manakov_Lie_Splitting(currU,preCalc,h,dW,M,sigma,gamma,PauliMats),...
    @(currU,preCalc,h,dW) Manakov_Explicit_Exponential(currU,preCalc,h,dW,M,sigma)};
preCalc = {@(h) Manakov_Lie_PreCalc(h,kSq,k,M,gamma),...
    @(h) Manakov_Explicit_Exponential_PreCalc(h,kSq,k,M,gamma)};
numSchemes = length(schemes);
schemeNames = {'LT','EE'};
colMat = [1,0,0;1,1,0];
schemeMarkers = {'v','x'};

% Norms: L2, H1, LInf
Manakov_L2Norm = @(currU) sum(absSq(currU))/M^2*L;
Manakov_H1Norm = @(currU) Manakov_L2Norm(currU) + Manakov_L2Norm(kVec.*currU);
normNames = {'L2','H1','L2'};
logScaleNorms = [true,true,false];
normFuns = {@(x,y) sqrt(Manakov_L2Norm(x-y)),...
    @(x,y) sqrt(Manakov_H1Norm(x-y)),...
    @(x,y) sqrt(Manakov_L2Norm(y)),...
    };

% !! End of experiment specs
%% Simulate experiment
for i = 1:numSmallerBatches
    indexOffset = (i-1)*smallerBatchSize;
    currBackupName = [backupName '(' num2str(i) ')'];
    % Samples are saved, so no need to store them for now
    simulationSPDE(NVec,T,currBackupName,u0,smallerBatchSize,schemes,...
        preCalc,normFuns,false,stochProc,indexOffset,currFileName);
end
%% Load available samples and extract, H1 norm drift and convergences
hVec = T./NVec;

numLogPlots = sum(logScaleNorms);
numNorms = length(normFuns);
numN = length(NVec)-1;

% Assuming that it's the first ones that are log scale plots
schemeErrors = zeros(batchSize,numN,numSchemes,numLogPlots);
L2NormDrift = zeros(batchSize,numN,numSchemes);

% Load each smaller saple set and load into memory
for sm = 1:numSmallerBatches
    load([backupName '(' num2str(sm) ')']); % Stored in variable
    sampleFloor = (sm-1)*smallerBatchSize;
    
    for m = 1:smallerBatchSize
        for n = 1:numN
            for i = 1:numSchemes
                % Load all the maximum errors
                for norm = 1:numLogPlots
                    schemeErrors(sampleFloor+m,n,i,norm) = ...
                        max(variable.normStorage{m,n}(:,i,norm)); 
                end
                L2NormDrift(sampleFloor+m,n,i) = ...
                    max(abs(variable.normStorage{m,n}(:,i,3) ...
                    -variable.normStorage{m,n}(1,i,3)));
            end
        end
    end
end
clear variable

%% Mean-square convergence
plotName = 'Plots/Manakov_Example_Convergence';
figure(1)
hPows = 1/2; lineChoice = 1;
meanMat = mean(schemeErrors);
matSize = size(meanMat);
meanMat = reshape(meanMat,[matSize(2:end),1]);

plotStrongErrors(meanMat,hVec,...
    schemeMarkers,colMat,schemeNames,normNames,hPows,lineChoice)
% Save figure
pause(1)
printToPDF(gcf,plotName,false)

%% L2 drift
plotName = 'Plots/Manakov_Example_Drift';
figure(2)
tiledlayout(numN-1,numSchemes)
for i = 1:numN-1
    for j = 1:numSchemes
        nexttile()
        histogram(L2NormDrift(:,i,j))
    end
end
% Save figure
pause(1)
printToPDF(gcf,plotName,false)