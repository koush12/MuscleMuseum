function tOut = updateTableFromTable(tIn,tOrigin,prop)
%UPDATETABLEFROMTABLE Summary of this function goes here
%   Detailed explanation goes here
arguments
    tIn table
    tOrigin table
    prop string
end
tOut = tIn;
tPropList = string(tIn.Properties.VariableNames);
tOriginPropList = string(tOrigin.Properties.VariableNames);
for ii = 1:numel(prop)
    if ismember(prop(ii),tPropList) && ismember(prop(ii),tOriginPropList)
        tOut.(prop(ii)) = tOrigin.(prop(ii));
    end
end
end

