s = serialport("COM6",115200);
configureTerminator(s,"CR");
writeline(s,"BNTGT 800.13453424124245")
writeline(s,"BNTGT 801.13453424124245")
readline(s)
% delete(s)