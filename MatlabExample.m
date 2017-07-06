clear;clc;

%% Please change this path!
TorcsConfigBase = '/home/alex/torcs-matlab/configs/'; % just insert your config path here

%% Initialization
killTorcs       = 'killall torcs ';
killBin         = 'killall torcs-bin ';
gui             = 1;                        % TORCS gui
runstats        = 0;                        % RUN statistics
statframe       = 1;                        % Show run statistics every n frame
debug           = 0;                        % DEBUG mode
steps           = 100000;                      % Max. simulation time steps (!!)
data            = zeros(33,1);          % Will contain all sensor data

timeout         = 1000000;

%% Start the Torcs server
system(killTorcs);
system(killBin);
if gui == 1
    %startServer = 'torcs &';
    startServer = ['torcs -t ' timeout ' ' TorcsConfigBase '3001.xml &'];
    disp(startServer)
    system(startServer);
    pause(12);
else
    startServer = ['torcs -t ' timeout ' -r ' TorcsConfigBase '3001.xml &'];
    disp(startServer)
    system(startServer);
    pause(.2);  % wait for the server to come up
    disp('server started')
end

%% Start the client
c = udp('127.0.0.1', 3001);
fopen(c);
fwrite(c,'SCR(init 90 45 0 -45 -90)');
for i=1:steps
    % The following line contains the command string that is sent to the
    % TORCS server. Ignore the focus for now and concentrate on training a
    % controller that handles acceleration, braking, gear changes, steering
    % and the clutch.
    if i < 500
        fwrite(c,'(accel 1.0)(brake 0) )(gear 3)(steer 0)(clutch 0)(focus -90 -45 0 45 90)');
    else
        fwrite(c,'(accel 0.0)(brake 1.0) )(gear 3)(steer 1.0)(clutch 0)(focus -90 -45 0 45 90)');
    end
    dat = fscanf(c);
    if i >  1
        % Read the sensor and other data from the UDP port
        s = sscanf(dat,'(angle %f)(curLapTime %f)(damage %f)(distFromStart %f)(distRaced %f)(fuel %f)(gear %f)(lastLapTime %f)(racePos %f)(rpm %f)(speedX %f)(speedY %f)(speedZ %f)(track %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f)(trackPos %f)');
        sizeS = (size(s));
        if(sizeS(1) == 33)
            angle=(s(1)+pi);curLapTime=s(2);damage=s(3);distFromStart=s(4);distRaced=s(5);fuel=s(6);gear=(s(7)+1);
            lastLapTime=s(8);racePos=s(9);rpm=s(10);speedX=(s(11)+30);speedY=(s(12)+20);speedZ=(s(13)+20);
            trackSensors=s(14:32);trackPos=(s(33)+1);
            
            % Save the data
            data(:,end+1) = s;
            % Text display
            %disp(dat)
            disp(size(data));
            % Plot the data (Please label the plot yourself)
            if runstats == 1 && mod(i,statframe) == 0
                figure(1);
                subplot(2,2,1);
                plot(data([2,4,5,8],:)');
                legend('Current Lap Time', 'Dist. from Start', 'Dist. Raced', 'Last Lap Time', 'Location', 'NorthEast');
                title(['Current Position: ' num2str(data(9,end)')]);
                
                subplot(2,2,2);
                plot(data([3,6],:)');
                title(['Gear: ' num2str(data(7,end)')]);
                legend('Damage', 'Fuel', 'Location', 'NorthEast');                
                
                subplot(2,2,3);
                semilogy(data([1,10,11,12,13],:)');
                legend('Angle', 'RPM', 'Speed X', 'Speed Y', 'Speed Z', 'Location', 'SouthEast');
                
                subplot(2,2,4);
                plot(data(33,:)');
                legend('Track Position', 'Location', 'SouthEast');
                
                %legend('Angle', 'Current Lap Time', 'Damage', 'Dist. from Start', 'Dist. Raced', 'Fuel', ...
                %'Gear', 'Last Lap Time', 'Race Position', 'RPM', 'Speed X', 'Speed Y', 'Speed Z', 'Track Sensors', 'Track Position');
                
                % Make sure to force drawing, otherwise the plot will only
                % update after the run.
                drawnow;
            end
        else
            %disp('readError (which you can probably ignore)');
        end
        %pause(timeout/1000000000);
    end
end

