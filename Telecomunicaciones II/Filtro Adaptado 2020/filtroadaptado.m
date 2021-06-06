% archivo auxiliar para practica de filtro adaptado
% Juan Agustin Avila, 22/4/2021
% Telecomunicaciones 2, ELO UNSJ
% Registro 26076

%% Definicion de variables para la simulacion
load_system('FiltroAdaptado.slx')
Canal=600;
Ts=.02+(76/10000);
Tb=50*Ts;
valRuido=1200;
%Referencias: signalOriginal / signalFiltro / signalRuido en este orden
%Ademas, esta "ruido" como una señal, signalRef como la parte inferio del
%muestreo, y salidaCorrelador como la salida final

%% Para modo de operacion 1 = NRZ y modo de operacion 2 = NRZ
varianza=0.2+(76/100);
set_param('FiltroAdaptado/Sw1','sw','0');   %switch 1 en posicion NRZ
set_param('FiltroAdaptado/Sw2','sw','0');   %switch 2 en posicion NRZ
sim('FiltroAdaptado');

f=figure();
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(gcf,"01-NRZ varianza chica.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"01-DiagramaOjo.png");
close(gcf);

%%Cambiando la varianza a 2+ el ultimo digito del registro
varianza=2+6;
sim('FiltroAdaptado');
f=figure();
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(gcf,"02-NRZ varianza media.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"02-DiagramaOjo.png");
close(gcf);

%%Cambiando la varianza a 20:
varianza=20;
sim('FiltroAdaptado');
f=figure();
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(gcf,"03-NRZ varianza grande.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"03-DiagramaOjo.png");
close(gcf);

%% variando la distorsion del canal:
varianza=0.2+(76/100);
Canal=800;
sim('FiltroAdaptado');
f=figure(1);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(1,"04-NRZ canal 800.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"04-DiagramaOjo.png");
close(gcf);

Canal=2400;
sim('FiltroAdaptado');
f=figure(2);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(2,"05-NRZ canal 2400.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"05-DiagramaOjo.png");
close(gcf);

%% Variando el modelo de ruido
Canal=600;
varianza=2+6;

valRuido=6000;
sim('FiltroAdaptado');
f=figure();
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(gcf,"06-NRZ ruido 6000.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"06-DiagramaOjo.png");
close(gcf);

sim('FiltroAdaptado');
f=figure(2);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal NRZ original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(2,"07-NRZ ruido 12000.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"07-DiagramaOjo.png");
close(gcf);
valRuido=12000;


%% Para modo de operacion 1 = Manchester y modo de operacion 2 = NRZ
varianza=0.2+(76/100);
set_param('FiltroAdaptado/Sw1','sw','1');   %switch 1 en posicion Manchester
set_param('FiltroAdaptado/Sw2','sw','0');   %switch 2 en posicion NRZ
sim('FiltroAdaptado');

f=figure(1);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(1,"09-Manchester varianza chica.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"09-DiagramaOjo.png");
close(gcf);

%%Cambiando la varianza a 2+ el ultimo digito del registro
varianza=2+6;
sim('FiltroAdaptado');
f=figure(2);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(2,"10-Manchester varianza media.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"10-DiagramaOjo.png");
close(gcf);

%%Cambiando la varianza a 20:
varianza=20;
sim('FiltroAdaptado');
f=figure(3);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(3,"11-Manchester varianza grande.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"11-DiagramaOjo.png");
close(gcf);

%% variando la distorsion del canal:
varianza=0.2+(76/100);
Canal=800;
sim('FiltroAdaptado');
f=figure(1);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(1,"12-Manchester canal 800.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"12-DiagramaOjo.png");
close(gcf);

Canal=2400;
sim('FiltroAdaptado');
f=figure(2);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(2,"13-Manchester canal 2400.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"13-DiagramaOjo.png");
close(gcf);

%% Variando el modelo de ruido
Canal=600;
varianza=2+6;

valRuido=6000;
sim('FiltroAdaptado');
f=figure(1);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(1,"14-Manchester ruido 6000.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"14-DiagramaOjo.png");
close(gcf);

valRuido=12000;
sim('FiltroAdaptado');
f=figure(2);
title("Gráfica de las señales con una varianza de "+varianza);
subplot(311);plot(signalOriginal),grid,title("Señal RZ bipolar original"),ylim([-1.2 1.2]);
subplot(312);plot(signalFiltro),grid,title("Señal filtrada, canal = "+Canal),ylim([-1.2 1.2]);
subplot(313);plot(signalRuido),grid,title("Señal con ruido agregado, varianza = "+varianza);
f.Position = [100 100 900 1800];
saveas(2,"15-Manchester ruido 12000.png")
close(gcf);
eyediagram(salidaCorrelador.Data,500,Ts,250),grid,title("Diagrama de ojo");
saveas(gcf,"15-DiagramaOjo.png");
close(gcf);


