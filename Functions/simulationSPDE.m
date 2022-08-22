function simulationSPDE(NVec,T,backupName,u0,batchSize,schemes,preCalc,normFuns,...
    normOfRef,stochProc,sampleOffset,scriptName)
% simulationSPDE - Tracks the evolution of a number of norms given a number
%                  of schemes. Results are saved along with the experiments
%                  specifics (specs) found delineated using '!!' in the
%                  scriptCalling file.
% Syntax: simulationSPDE(NVec,T,backupName,u0,batchSize,schemes,preCalc,...
%    normFuns,normOfRef,stochProc,sampleOffset,scriptName)
% Input:
% NVec         - An integer vector defining time discretization, assuming
%                increasing increments. The last index will be used for the
%                reference solution, and will be assumed to be divisible by
%                all other N values.
% T            - The time horizon for the evolution.
% backupName   - The file name used for the data and specs. Specs will be
%                saved as [backupName 'Specs.mat'].
% u0           - Initial value for the samples.
% batchSize    - Positive integer defining how many samples are sought.
%                Will check (and potentially load) already present samples 
%                based on backupName.
% schemes      - A cell containing anonymous functions mapping 
%                u_n -> u_{n+1} with input (u_n,preCalc,h,dW_n).
% preCalc      - A cell of the same length as the schemes cell. It contains
%                anonymous functions mapping h to a cell array containing 
%                the precalculated values used in the corresponding 
%                numerical scheme.
% normFuns     - A cell containing anonymous functions mapping
%                (u_ref,u_coarse) to a complex scalar.
% normOfRef    - A boolean value. If true, then the norm functions are also
%                called using (u_ref,u_ref). If only one N value is given,
%                then all norms are evaluated using (u_ref^1,u_ref^j), for
%                j = 1:length(normFuns).
% stochProc    - A function that constructs the time discretization of the
%                stochastic processes used in the solutions. Takes the
%                arguments (numTimeSteps,timeStepSize) and yields a matrix
%                of the size (numTimeSteps,numStochProc).
% sampleOffset - Used to offset the initialization of the rng used for the
%                Brownian motion. Called with rng(m+sampleOffset,'twister')
% scriptName   - Name of the file containing the specifics of the
%                experiment. The file will be read as a text file, split
%                it along '!!', and choose the second part of the file to
%                compare with the samples already present. If no '!!'
%                delineation exists, then it will save an empty string.

% Process the parameters
numN = length(NVec); numSchemes = length(schemes); numNorms = length(normFuns);
hVec = T./NVec; refN = NVec(end); refh = hVec(end);

%% Check for previous samples and compare specs
% Get the specs if present (used in backups) - Surround specs with '!!'
specs = fetchSpecs(scriptName);

specFileName = [backupName 'Specs.mat'];
% Check if samples present
if isfile(specFileName)
    % Load the specs
    temp = load(specFileName);
    
    % Inform if spec, sample offset is different, or if batchsize is
    % smaller than the present samples
    if isequal(temp.variable.specs,specs)
        fprintf('\nSpecs for present samples OK.\n')
    else
        error('Specs different for existing samples.')
    end
    
    if temp.variable.indexOffset ~= sampleOffset
        error('Sample offset not same')
    end
    
    if temp.variable.batchSize >= batchSize
        fprintf(['Not asking for more samples than already present.\n' ...
            num2str(batchSize) ' samples with offset ' num2str(sampleOffset) '.\n'])
        return
    end
end

%% Initialize storage
normStorage = cell(batchSize,length(NVec)-1);

% If we are asking for two outputs: Give norms of finest level as well
if normOfRef
    % If we have only one N, then we're obviously interested in all schemes
    if numN == 1
        runAllSchemesAsRef = true;
    else
        runAllSchemesAsRef = false;
    end
    refNormStorage = zeros(batchSize,refN+1,1,numNorms);
else
    runAllSchemesAsRef = false;
end

% Load the already present samples into the norm storage(-s)
backupFileName = [backupName '.mat'];
if isfile(backupFileName)
    % Load the specs
    temp = load(backupFileName);
    numPresSamples = size(normStorage,1);
    normStorage(1:numPresSamples,:) = temp.variable.normStorage;
    if normOfRef
        refNormStorage(1:numPresSamples,:,:) = temp.variable.refNormStorage;
    end
    clear temp
else
    numPresSamples = 0;
end

%% Perform calculations
parfor m = (numPresSamples+1):batchSize
    % Load external variables in order to enable parfor
    normFuns; schemes; NVec; hVec; stochProc;
    
    % Simulate and coarsen the stochastic processes
	rng(m+sampleOffset,'twister')

    % Example for Schrödinger equation using Strang splitting:
%     refW = randn(refN,2)*sqrt(refh/2); retBMs = coarseStochProc(refW,NVec);

    refProc = stochProc(refN,refh);
    numStochProc = size(refProc,2);
    coarseProcs = coarseStochProc(refProc(:,1),NVec);
    for i = 2:numStochProc
        tempRetBMs = coarseStochProc(refProc(:,i),NVec);
        % Append the  processes
        for j = 1:size(coarseProcs,1)
            coarseProcs{j} = [coarseProcs{j}, tempRetBMs{j}];
        end
    end
    
    % Initialize memory - Norm storage
    tempNorms = cell(numN-1,1);
    for i = 1:(numN-1)
        tempNorms{i} = zeros(NVec(i)+1,numSchemes,numNorms);
    end
    if normOfRef
        % If reference norms are asked for
        if runAllSchemesAsRef
            refNorms = zeros(refN+1,numSchemes,numNorms);
        else
            refNorms = zeros(refN+1,1,numNorms);
        end
    end
    
    % Initialize memory - Initial values
    refSol = u0;
    if runAllSchemesAsRef
        refSols = cell(numSchemes,1);
    end
    coarseSol = cell(numN-1,numSchemes);
    
    % Set remaining initial values, and calculate initial value norms
    for k = 1:numNorms
        for j = 1:numSchemes
            for n = 1:(numN-1)
                % Initial values
                coarseSol{n,j} = refSol;
                    tempNorms{n}(1,j,k) = normFuns{k}(refSol,coarseSol{n,j});
            end
            if normOfRef
                if runAllSchemesAsRef
                    refSols{j} = refSol;
                    refNorms(1,j,k) = normFuns{k}(refSols{1},refSols{j});
                else
                    refNorms(1,1,k) = normFuns{k}(refSol,refSol);
                end
            end
        end
    end

    % Precalculate if possible
    preCalcStorage = cell(numN-1,numSchemes);
    refPreCalc =  preCalc{1}(hVec(end));
    for j = 1:numSchemes
        for n = 1:(numN-1)
            preCalcStorage{n,j} = preCalc{j}(hVec(n));
        end
    end

    
    % Simulate at reference precision, but step coarse solutions when the
    % correct time has been passed.
    dWIndex = ones(numN-1,1);
    scalingFactor = refN./NVec;
    for i = 1:refN
        % Step the reference solution/-s
        if runAllSchemesAsRef
            for j = 1:numSchemes
                % First scheme used as reference scheme
                refSols{j} = schemes{j}(refSols{j},refh,refProc(i,:));
                % Calculate norms
                for k = 1:numNorms
                    refNorms(i+1,j,k) = normFuns{k}(refSols{1},refSols{j});
                end
            end
        else
            % First scheme used as reference scheme
            refSol = schemes{1}(refSol,refPreCalc,refh,refProc(i,:));

%             M = length(refSol)/2;
%             figure(1)
%             clf
%             plotProfile(linspace(0,1,M),ifft(refSol(1:M)),false,false)
%             figure(2)
%             clf
%             plotProfile(linspace(0,1,M),ifft(refSol(M+1:end)),false,false)
%             pause(0.01)

            if normOfRef
                % Calculate norms
                for k = 1:numNorms
                    refNorms(i+1,1,k) = normFuns{k}(refSol,refSol);
                end
            end
        end
        
        % Exclude the finest N (which is the reference)
        for n = 1:(numN-1)
            % Step coarse solution if enough steps passed
            if mod(i,scalingFactor(n)) == 0
                for j = 1:numSchemes
                    coarseSol{n,j} = schemes{j}(coarseSol{n,j},preCalcStorage{n,j},hVec(n),...
                        coarseProcs{n}(dWIndex(n),:));
                    % Calculate norms
                    for k = 1:numNorms
                        tempNorms{n}(dWIndex(n)+1,j,k) = normFuns{k}(refSol,coarseSol{n,j});
                    end
                end
                dWIndex(n) = dWIndex(n) + 1;
            end
        end
        fprintf(['-------'...
            '\n Sample: ', num2str(m+sampleOffset), ...
            ' between ', num2str(sampleOffset+1), ' and ', num2str(sampleOffset+batchSize) ...
            '.\n Percentage until max time: ', num2str(i/refN), ...
            '.\n-------\n'])
    end
    normStorage(m,:) = tempNorms;
    if normOfRef
        refNormStorage(m,:,:,:) = refNorms;
    end
end

% Save the results to files (specs and sample ID's separately)
backUpSpecs.specs = specs;
backUpSpecs.batchSize = batchSize;
backUpSpecs.indexOffset = sampleOffset;
% Norms
backUpData.normStorage = normStorage;
if normOfRef
    backUpData.refNormStorage = refNormStorage;
end
% Save
backupSave([backupName 'Specs'],backUpSpecs)
backupSave(backupName,backUpData)
end