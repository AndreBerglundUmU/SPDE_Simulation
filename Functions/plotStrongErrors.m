function plotStrongErrors(meanMat,hVec,...
    schemeMarkers,colMat,schemeNames,normNames,hPows,lineChoice,varargin)
% Dimension 1: Time step
% Dimension 2: Scheme
% Dimension 3: Norm
numN = size(meanMat,1);
numSchemes = size(meanMat,2);
numLogPlots = size(meanMat,3);
numHPows = length(hPows);

% Optional argument: Enforcing uniform axis
if nargin > 8
    uniformAxis = true;
    yAxisLabel = varargin{1};
    axisLim = [min(meanMat(:)),max(meanMat(:))];
else
    uniformAxis = false;
end
% Optional argument: Disable title
if nargin > 9
    enableCustomTitle = true;
    customTitle = varargin{2};
else
    enableCustomTitle = false;
end

[~,desiredMarkerSize,desiredLineWidth] = AMSFontSize;

clf
tiledlayout(1,numLogPlots,"TileSpacing","tight","Padding","tight")

for i = 1:numLogPlots
    nexttile()
    % Plot support lines - With extended lines
    hVecExt = [hVec(1)*2 hVec(1:numN) hVec(numN)/2];
    % Normalize the translation constant
    normConst = zeros(numHPows,1);
    lineLeg = cell(numHPows,1);
    hold on
    for j = 1:numHPows
        normConst(j) = meanMat(1,lineChoice(j),i)/(hVec(1)^hPows(j));
        plot(hVecExt,hVecExt.^hPows(j)*normConst(j),'LineWidth',2.5)
        lineLeg{j} = ['$h^{' num2str(hPows(j)) '}$'];
    end
    % Plot scheme errors
    for s = 1:numSchemes
        plot(hVec(1:numN),meanMat(:,s,i),['-' schemeMarkers{s}],...
            'Color',colMat(s,:),'MarkerSize',desiredMarkerSize,'LineWidth',desiredLineWidth)
    end
    
    % Optional axis enforcement
    if uniformAxis
        ylim(axisLim)
        if i == 1
            ylabel(yAxisLabel,'Interpreter','latex')
        else
            set(gca,'YTickLabel',[])
        end
    end

    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')

    if i == 1
        legend(lineLeg{:},schemeNames{:},'Location','north','Interpreter','latex')
    end
    % Optional title modification
    if enableCustomTitle
        title(customTitle{i},'Interpreter','latex')
    else
        title([normNames{i} ' error'],'Interpreter','latex')
    end
    % Automatic choice failing to show more than one tick
    XPow = ceil(log10(gca().XLim));
    XPow = ceil(linspace(XPow(1),XPow(2),3));
    set(gca,'XTick',10.^XPow)
    xlabel('$h$',"Interpreter","latex")
    
    set(gca,'FontSize',AMSFontSize)
end
end