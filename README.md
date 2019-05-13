# Digital3

Programas de los trabajos de Electronica Digital 3 de ELO en la UNSJ.

## Práctica 2

coso

## Práctica 3

En memoria se encuentran almacenados tres datos:
dato 1: binario MyS 13b total
dato 2: BCD 12b + 1b Signo SRC10
dato 3: SRC2 12b
Se debe encontrar el mayor y verificar si se puede representar en SRC2 8b
Se deben llevar 3 ejemplos que verifiquen  desbordes, con num positivos y negativos.

## Práctica 4

Implementar un programa que realice las siguientes tareas utilizando las
interrupciones multilíneas del microprocesador 8085.
El sistema debe constar de una interrupción de reloj que sirva como base de
tiempo de 1 seg., la rutina de servicio correspondiente a esta deberá realizar lo
siguiente:
a- Generar una onda cuadrada por un bit de una puerta de 4 seg. de
período.
b- Generar una onda cuadrada por otro bit cuyo semiperiodo lo indique un
dato a ingresar (considerar como valor inicial 3).
El dato a ingresar, se hará mediante otra interrupción producida por el
teclado. El valor a ingresar es de 1 solo dígito expresado en código ASCII que
representa el semiperiodo, este valor ASCII debe convertirse a binario.
El programa principal deberá mostrar por display los segundos transcurridos.

## Laboratorio 1

Se debe realizar un teclado de alarma con cuatro zonas basado en el 8085.
El sistema posee las siguientes interfaces:
a) 1 teclado
b) 4 interruptores de entrada de zonas de sensado
c) 1 display lcd.

### Funcionamiento del sistema

Con el teclado se ingresa la clave (cuatro digitos) para activar y desactivar la alarma.
Al estar activada se debe monitorear las zonas. Por display LCD se debe mostrar los
estados de la alarma: "Act", "Desact" y "Zona X act".
Las direcciones de los dispositivos seran asignadas de acuerdo a la siguiente tabla:
Teclado ->	Teclado (in 82h)
Interruptores de sensores de zona -> puerta 84H, bits 3-0
 Buzzer -> Puerta B (de un 8155)