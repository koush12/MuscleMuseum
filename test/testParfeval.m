
a = 1;
y = SineWave;
atom = Alkali("Lithium7");
p = gcp('nocreate');
f = parfeval(p,@andorLoop,0,@(x) callbackFunc(x,atom));

while strcmp(f.State, 'queued')
    pause(0.1);
end

f2 = parfeval(p,@pause,0,4);
wait(f2)
% parfor (ii = 1:5,3)
%     disp(rand(1));
% end

function andorLoop(callbackFunc)
n = 1;
while(n < 11)
    pause(1)
    if mod(n,5) == 0
        callbackFunc([])
    end
    n = n + 1;
end
end

function callbackFunc(~,yy)
    a = yy.D2.NNState;
    imwrite(double(a),string(a) + "callback.tiff")
end