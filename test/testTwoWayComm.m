q1 = parallel.pool.DataQueue; % this is to retrieve the data
afterEach(q1,@disp);
% this is used to retrive the pollable data q from the worker
q11 = parallel.pool.PollableDataQueue;
p = gcp;
f= parfeval(@worker1,0,q1,q11);
q2 = poll(q11,10); % retrieve the pollable data queue from the worker
for i = 1:10
    send(q2,i); % use the retrieved q to send data / comms to worker
end

function worker1(q1,q11)
nodatacounter = 0;
% create the q and send it back to main thread so that we can use it to rcv
% data from the main thread
q2 = parallel.pool.PollableDataQueue;
send(q11,q2);
while nodatacounter < 10 % kill the worker if no comms for 10 iterations
    [data,datarcvd] = poll(q2,10); % 10 second timeout
    if datarcvd
        send(q1,data);
        nodatacounter = 0;
    else
        nodatacounter = nodatacounter + 1;
    end
end
end