clc;clear all;
load('medidas hiperimu.mat');    %se carga el archivo con los valores de la simulacion
% para generar cada variable utilice el comando "squeeze(x(var,1,:))"
entrada=squeeze(x(1,1,:));
salida=squeeze(x(2,1,:));
salida=salida(4:end);
salida=[salida; 0;0;0;];
accioncontrol=squeeze(x(3,1,:)/10); %Se divide en 10 para que quede en volts
for i=1:length(accioncontrol)
    if accioncontrol(i)>0
        accioncontrol(i)=accioncontrol(i)+2; %le suma la zona muerta
    elseif accioncontrol(i)<0
        accioncontrol(i)=accioncontrol(i)-2; %si es negativa le resta la zona muerta
    end
end
error=squeeze(x(4,1,:));
tmin=0;
tmax=10;
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
plot(t,error,t,accioncontrol);
grid on;
xlim([tmin tmax]); %Se selecciona un rango con mucho movimiento de la referencia
legend("Error","Accion de control");
title("Error y accion de control");
saveas(2,"error y accioncontrol.png")