function [fontSize,varargout] = AMSFontSize
% Standard AMS font size are 10pt.
% Source: https://texdoc.org/serve/amsclass/0 , page 7, code row 166.
% Information checked 08/06/2022 (dd/mm/yyyy).
%
% Resizing text to fit common screen sizes
% Currently the most common screen ratio is 16:9
% Taking 12.8/7.2 as a 'smaller' screen
%
% AMS format use a textwidth of 30pc. 
% Source: https://texdoc.org/serve/amsclass/0 , page 10. 
% Information checked 08/06/2022 (dd/mm/yyyy).
%
% Converting from pc to in has the ratio 6.0225.
% Source: https://tex.stackexchange.com/questions/8260/
% what-are-the-various-units-ex-em-in-pt-bp-dd-pc-expressed-in-mm
% Information checked 08/06/2022 (dd/mm/yyyy).
%
% When called with 3 outputs, it also returns the marker size and line 
% width (in that order).
    fontSize = 10;
    figWidth = 12.8;
    % Manual resizing to fit with document
    fontSize = fontSize*0.8;

    numpc = 30;
    pcToIn = 6.0225;
    printInchWidth = numpc/pcToIn;
    
    fontSize = fontSize*figWidth/printInchWidth;
    if nargout == 3
        varargout{1} = fontSize*0.65; % Marker size
        varargout{2} = fontSize*0.1; % Line width
    end
end