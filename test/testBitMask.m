enabledChannel = 1:2;

bitAll = int64(2.^(enabledChannel-1));
bitMask = bitAll(1);
for ii = 1:(numel(bitAll)-1)
    bitMask = bitor(bitMask,bitAll(ii+1));
end
bitMaskH = int32(0);
bitList = find(bitget(bitMask,33:64));
for ii = 1:numel(bitList)
    bitMaskH = bitset(bitMaskH,bitList(ii));
end
bitMaskL = uint32(0);
bitList = find(bitget(bitMask,1:32));
for ii = 1:numel(bitList)
    bitMaskL = bitset(bitMaskL,bitList(ii));
end

disp(bitMaskH)
disp(bitMaskL)