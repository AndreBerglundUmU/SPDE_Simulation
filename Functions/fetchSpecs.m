function [specs] = fetchSpecs(fileName)
% Load the calling file as text and extract the experiment specification
% The specs are assumed to be the second partition, and if there is no
% second partition then the check will be excluded
scriptString = fileread(fileName);
splitScript = strsplit(scriptString,'!!');

if length(splitScript) > 1
    specs = splitScript{2};
else
    specs = '';
end
end

