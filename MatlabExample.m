%% Initialization
clear;
clc;
killTorcs = 'killall torcs ';
killBin = 'killall torcs-bin ';
TorcsConfigBase = '~/Documents/MATLAB/torcs/configs/'; % just insert your config path here
gui=0;
debug =0;
steps=60;
data={zeros(1,steps)};
%% start server
system(killTorcs);
system(killBin);
if gui == 1
    startServer = 'torcs &';
    system(startServer);
    pause(10);
else
    startServer = ['torcs -t 1000000 -r ' TorcsConfigBase '3001.xml &'];
    disp(startServer)
    system(startServer);
    pause(.2);  % wait for the server to come up
    disp('server started')
end
%% startclient

i=0;
c = udp('127.0.0.1', 3001);
fopen(c);
fwrite(c,'SCR(init 90 45 0 -45 -90)');
while ( i<=steps)
    i = i + 1;
    fwrite(c,'(accel 0.5)(brake 0) )(gear 1)(steer 0)(clutch 0)(focus -90 -45 0 45 90)');
    data{i} = fscanf(c);
    if i >  1
        s = sscanf(data{i},'(angle %f)(curLapTime %f)(damage %f)(distFromStart %f)(distRaced %f)(fuel %f)(gear %f)(lastLapTime %f)(racePos %f)(rpm %f)(speedX %f)(speedY %f)(speedZ %f)(track %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f)(trackPos %f)');
        sizeS = (size(s));
        if(sizeS(1) == 33)
            angle=(s(1)+pi);
            curLapTime=s(2);
            damage=s(3);
            distFromStart=s(4);
            distRaced=s(5);
            fuel=s(6);
            gear=(s(7)+1);
            lastLapTime=s(8);
            racePos=s(9);
            rpm=s(10);
            speedX=(s(11)+30);
            speedY=(s(12)+20);
            speedZ=(s(13)+20);
            trackSensors=s(14:32);
            trackPos=(s(33)+1);
        else
            disp('readError');
        end
    end
    disp(fscanf(c))
end


