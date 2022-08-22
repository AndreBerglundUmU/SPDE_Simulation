function printToPDF(myHandle,name,varargin)
% printToPDF    - Save the figure to PDF format in the folder "Plots".
% Syntax: printToPDF(myHandle,name)
%
% Input:
% myHandle  - The handle to the figure which is to be saved
% name      - A string containing the file name
% move      - An optional boolean value. Default true. Enables move to plot
%             folder.
% image     - An optional boolean value. Default false. Changes renderer,
%             which may make the plot smaller (though no longer vector 
%             based).
%
% Output:
% A file 'name.pdf' in the folder 'Plots' with quality level r800.
%
% See AMSFontSize.m and AMSFormatScreenSize.m

    [figWidth,figHeight] = AMSFormatScreenSize;
    figPos = [0, 0, figWidth, figHeight];
    set(myHandle,'Units','Inches','Position', figPos)

    % Set the height such thath the ratio is preserved
    set(myHandle,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',figPos(3:4))
    pause(0.1)
    print(myHandle,name,'-dpdf','-r800')
    pause(0.1)
    if nargin == 2 || varargin{1}
        % Move to plots folder. If folder does not exist, create it.
        if ~exist('Plots', 'dir')
            mkdir('Plots');
        end
        movefile([name '.pdf'],'Plots')
    end
end