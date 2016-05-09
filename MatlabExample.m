clear;clc;

%% Please change this path!
TorcsConfigBase = '/home/alex/torcs-matlab/configs/'; % just insert your config path here

%% Initialization
killTorcs       = 'killall torcs ';
killBin         = 'killall torcs-bin ';
gui             = 0;                        % TORCS gui
debug           = 0;                        % DEBUG mode
steps           = 100;                      % Max. simulation time steps (!!)
data            = zeros(33,steps);          % Will contain all sensor data

%% Start the Torcs server
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

%% Start the visualization
figure(1);
title('Current performance');
drawnow;

%% Start the client
c = udp('127.0.0.1', 3001);
fopen(c);
fwrite(c,'SCR(init 90 45 0 -45 -90)');
for i=1:steps
    % The following line contains the command string that is sent to the
    % TORCS server. Ignore the focus for now and concentrate on training a
    % controller that handles acceleration, braking, gear changes, steering
    % and the clutch.
    fwrite(c,'(accel 0.5)(brake 0) )(gear 1)(steer 0)(clutch 0)(focus -90 -45 0 45 90)');
    dat = fscanf(c);
    if i >  1
        % Read the sensor and other data from the UDP port
        s = sscanf(dat,'(angle %f)(curLapTime %f)(damage %f)(distFromStart %f)(distRaced %f)(fuel %f)(gear %f)(lastLapTime %f)(racePos %f)(rpm %f)(speedX %f)(speedY %f)(speedZ %f)(track %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f)(trackPos %f)');
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
            
            % Save the data 
            data(:,i) = s;
            % Text display
            disp(dat)
            % Plot the data (Please label the plot yourself)
            plot(data');
            % Make sure to force drawing, otherwise the plot will only
            % update after the run. If you are using the TORCS gui, the
            % plot is not synchronized to the run.
            %
            % You might also want to get rid of the empty data columns
            drawnow;
        else
            disp('readError');
        end
    end
end

