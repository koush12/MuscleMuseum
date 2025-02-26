function s = table2str(t)
%TABLE2STRING Convert a table to a string
%   The string representation of the table will be transposed. Each string
%   segment separated by ";" represents a column in the table. The first
%   element in the string segment is the variable name of the column.
arguments
    t table
end
if isempty(t)
    s = string.empty;
    return
end
% Find table variables
varName = string(t.Properties.VariableNames);
if any(contains(varName,",")) || any(contains(varName,";"))
    error("Table variable names can not contain "","" or "";"" ")
end

% Check table contents
for ii = 1:numel(varName)
    tData = t.(varName(ii));
    if ischar(tData(1,:))
        t.(varName(ii)) = string(tData);
    elseif ~isstring(tData(1,:))
        error("All table contents must be strings or chars")
    end
end

% Create the string
s = arrayfun(@(x) x + "," + strjoin(t.(x),","),varName);
s = strjoin(s,";");
end

