clc;clear all;
load('medidas hiperimu.mat');    %se carga el archivo con los valores de la simulacion
% para generar cada variable utilice el comando "squeeze(x(var,1,:))"
tmin=110;
tmax=120;
%% Graficacion
figure(1);
plot(t,entrada,t,salida);
grid on;
xlim([tmin tmax]); %Se selecciona un rango con mucho movimiento de la referencia
legend("Entrada","Salida");
title("Comportamiento de la planta ante una referencia");
saveas(1,"entradaysalida.png")
%% grafica con error y accion de control
figure(2);
accioncontrol=(accioncontrol)/10;
plot(t,error,t,accioncontrol);
grid on;
xlim([tmin tmax]); %Se selecciona un rango con mucho movimiento de la referencia
legend("Error","Accion de control");
title("Error y ");
saveas(2,"error y accioncontrol.png")