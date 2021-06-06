# Sistemas para control

En esta materia se realizan aplicaciones practicas de sistemas de control, como tambien algunos protocolos de comunicacion industriales (SCADA, MODBUS, 4-20mA).

## Práctica 1

Consistió en en el control de posicion de un motor. Utilizando una aplicacion, se median los sensores inerciales de un smartphone, mediante el protocolo UDP se enviaban esos datos a una PC corriendo matlab, quien procesaba los datos y enviaba las acciones de control a un arduino via MODBUS sobre rs485. El arduino implementaba un controlador PID con librerias de arduino modificadas, mejorando algunos errores. Se enviaban las acciones a un shield controlador de motores, y se leia la posicion del motor con un potenciometro conectado solidariamente al eje de salida del motor.

## Práctica 2

Muy similar a la practica 1, se utilizo el mismo arduino con algunas modificaciones. Principalmente, se agregó un sensor de corriente hall para observar y controlar las acciones del motor. Ese sensor se midio con un ADC de 16 bits para poder tener una accion de control mas precisa, y el ADC se calibro utilizando un divisor de tension para independizarlo de cambios en la fuente de alimentacion. El arduino estaba conectado mediante rs485 a un conversor de MODBUS RTL a MODBUS TPC. En una pc, se corria un servidor rapidSCADA encargado de medir y procesar los datos actuales enviados por arduino, generar las acciones de control mediante una interfaz web, y registrando todo en un log. Ademas, se realizo una prueba de control externo conectandose desde una pc remota al servidor y controlando el sistema desde alli.

## Parcial

Se realizaron dos proyectos, uno consistia en un sistema de control de un dosificador de cloro para una planta potabilizadora de agua, y el otro en un sistema modular para control y prediccion a corto plazo de heladas en viñedos, registrando datos de la temperatura, velocidad del viento, humedad relativa en aire y en el suelo. Con un modelo se calculan las probabilidades de una helada seca, y se generan alertas para realizar acciones que prevengan daños.
