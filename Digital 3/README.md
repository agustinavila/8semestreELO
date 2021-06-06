# Digital3

Código de los gabinetes y laboratorios de [Electronica Digital 3](http://dea.unsj.edu.ar/mp1/) de ELO en la UNSJ.
Agustin Avila
2019

---

## Práctica 2

Se desea realizar un circuito de control para el toldo de una terraza de una vivienda. El toldo tiene la
función tanto de dar sombra como de proteger del viento y de la lluvia. Así que es un toldo resistente al
viento y a la lluvia, manteniendo la terraza seca en los días de lluvia.
Para el circuito de control tenemos las siguientes entradas:

- Señal S: Indica si hay sol
- Señal L: Indica si llueve
- Señal V: Indica si hay mucho viento
- Señal F: Indica si hace frío en el interior de la casa.

Según los valores de estas entradas se bajará o subirá el toldo.
Esto se realizará mediante la señal de salida BT (Bajar Toldo). Si BT='1' indica que el toldo debe estar extendido (bajado) y si BT='0' indica que el toldo debe estar recogido (subido).
El circuito que acciona el toldo debe funcionar según las siguientes características:

- Independientemente del resto de señales de entrada, siempre que llueva se debe de extender el toldo para evitar que se moje la terraza. No se considerará posible que simultáneamente llueva y haga sol.
- Si hace viento se debe extender el toldo para evitar que el viento moleste. Sin embargo, hay una excepción: aún cuando haya viento, si el día está soleado y hace frío en la casa, se recogerá el toldo para que el sol caliente la casa.
- Por último, si no hace viento ni llueve, sólo se bajará el toldo en los días de sol y cuando haga calor en el interior, para evitar que se caliente mucho la casa.

---

## Práctica 3

En memoria se encuentran almacenados tres datos:

- dato 1: binario MyS 13b total
- dato 2: BCD 12b + 1b Signo SRC10
- dato 3: SRC2 12b

Se debe encontrar el mayor y verificar si se puede representar en SRC2 8b
Se deben llevar 3 ejemplos que verifiquen  desbordes, con num positivos y negativos.

---

## Práctica 4

Implementar un programa que realice las siguientes tareas utilizando las interrupciones multilíneas del microprocesador 8085.
El sistema debe constar de una interrupción de reloj que sirva como base de tiempo de 1 seg., la rutina de servicio correspondiente a esta deberá realizar lo siguiente:

1. Generar una onda cuadrada por un bit de una puerta de 4 seg. de
período.
2. Generar una onda cuadrada por otro bit cuyo semiperiodo lo indique un
dato a ingresar (considerar como valor inicial 3).

El dato a ingresar, se hará mediante otra interrupción producida por el teclado. El valor a ingresar es de 1 solo dígito expresado en código ASCII que representa el semiperiodo, este valor ASCII debe convertirse a binario. El programa principal deberá mostrar por display los segundos transcurridos.

---

## Laboratorio 1

Se debe realizar un teclado de alarma con cuatro zonas basado en el 8085.
El sistema posee las siguientes interfaces:

1. 1 teclado
2. 4 interruptores de entrada de zonas de censado
3. 1 display lcd.

Cabe aclarar que el codigo no está muy prolijo, ya que se tuvo que corregir bugs dentro del laboratorio, y no hubo margen para hacerlo prolijo. Luego no se corrigio, ya que es extremadamente complicado interpretar un codigo en assembler que no este perfectamente documentado.

### Funcionamiento del sistema

Con el teclado se ingresa la clave (cuatro digitos) para activar y desactivar la alarma. Al estar activada se debe monitorear las zonas. Por display LCD se debe mostrar los estados de la alarma: "Act", "Desact" y "Zona X act". Las direcciones de los dispositivos seran asignadas de acuerdo a la siguiente tabla:

- Teclado ->Teclado (in 82h)
- Interruptores de sensores de zona -> puerta 84H, bits 3-0
- Buzzer -> Puerta B (de un 8155)

## Laboratorio 2

Se realizo una implementación en el microcontrolador 8051 utilizando C.
