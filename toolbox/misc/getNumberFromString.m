function n = getNumberFromString(s)
%GETNUMBERFROMSTRING Summary of this function goes here
%   Detailed explanation goes here
arguments
    s string
end
n = double(regexp(s,'\d*','Match'));
end

