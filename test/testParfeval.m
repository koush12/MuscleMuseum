
a = 1;
y = SineWave;
atom = Alkali("Lithium7");
% pool = parpool(1);
f = parfeval(@andorLoop,0,@(x) callbackFunc(x,atom));


function andorLoop(callbackFunc)
n = 1;
while(n < 11)
    pause(0.1)
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