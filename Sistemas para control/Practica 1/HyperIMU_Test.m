%***** Test para probar el funcionamiento de HyperIMU *****
%Configurar la app HyperIMU de la siguiente manera:
%Stream Protocol: UDP
%Sampling rate (ms): 50 (o > 50 modificando igualmente la variable Ts)
%Server IP address: IP de su PC (conectada al celular mediante hotspot)
%Server Port number: 2055 (u otro modificando igualmente la variable LPort)
%En el menú "Sensor List" elegir solo el acelerómetro (accelerometer)


LPort = 2055;
Ts=0.03;
DataStream = 9999;
UDPComIn = udp('0.0.0.0','LocalPort',LPort);
set(UDPComIn,'DatagramTerminateMode','on','InputBufferSize',DataStream);
fopen(UDPComIn);

clf;

figure(1);
hold on;
H1 = cube_plot(5,2.5,0.5,'r');
axis equal;
axis([-2.75 2.75 -2.75 2.75 -2.75 2.75]);
grid on;
xlabel('X','FontSize',14);
ylabel('Y','FontSize',14)
zlabel('Z','FontSize',14)
material metal
alpha('color');
alphamap('rampup');
view(-135,30);

kfiltro = 0.25;
pitch_ant = 0;
roll_ant = 0;

Time = 30;
tic;
for i=1:Time/Ts
    while(toc < Ts)
    end
    tic;
    readout = fscanf(UDPComIn,'%s');
    scandata = textscan(readout,'%s','Delimiter',',');
    scan = scandata{1};
    apparray = cellfun(@str2num,scan)
    sensorMat = vec2mat(apparray,3);
    Gx=sensorMat(1);
    Gy=sensorMat(2);
    Gz=sensorMat(3);
    roll = atan2(Gy,sign(Gz)*sqrt(Gz*Gz+0.01*Gx*Gx));
    roll = kfiltro*roll + (1-kfiltro)*roll_ant;
    roll_ant = roll;
    pitch = atan(-Gx/sqrt(Gy*Gy+Gz*Gz));
    pitch = kfiltro*pitch + (1-kfiltro)*pitch_ant;
    pitch_ant = pitch;
    delete(H1);
    H1 = cube_plot(5,2.5,0.5,'r');
    rotate(H1,[1 0 0],rad2deg(pitch));
    rotate(H1,[0 1 0],rad2deg(-roll));
    drawnow;
end
fclose(UDPComIn);

function h = cube_plot(dx,dy,dz,color)
% CUBE_PLOT plots a cube with dimension of dx, dy, dz.
%
% INPUTS:
% dx      = cube length along x direction.
% dy      = cube length along y direction.
% dz      = cube length along z direction.
% color  = STRING, the color patched for the cube.
%         List of colors
%         b blue
%         g green
%         r red
%         c cyan
%         m magenta
%         y yellow
%         k black
%         w white
% OUPUTS:
% Plot a figure in the form of cubics.
%
% EXAMPLES
% cube_plot(2,3,4,'red')
%
if nargin < 4
    color = [0.5 0.5 0.5];
end 

% ------------------------------Code Starts Here------------------------------ %
% Define the vertexes of the unit cubic
ver = [1 1 0;
    0 1 0;
    0 1 1;
    1 1 1;
    0 0 1;
    1 0 1;
    1 0 0;
    0 0 0];
%  Define the faces of the unit cubic
fac = [1 2 3 4;
    4 3 5 6;
    6 7 8 5;
    1 2 8 7;
    6 7 1 4;
    2 3 5 8];

ver(:,1) = ver(:,1)*dx - 0.5*dx;
ver(:,2) = ver(:,2)*dy - 0.5*dy;
ver(:,3) = ver(:,3)*dz - 0.5*dz;

cube = [ver(:,1),ver(:,2),ver(:,3)];
h = patch('Faces',fac,'Vertices',cube,'FaceColor',color);
end
% ------------------------------Code Ends Here-------------------------------- %
