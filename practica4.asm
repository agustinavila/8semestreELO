;*******************************************************************************
;Implementar un programa que realice las siguientes tareas utilizando las
;interrupciones multilíneas del microprocesador 8085.
;;El sistema debe constar de una interrupción de reloj que sirva como base de
;tiempo de 1 seg., la rutina de servicio correspondiente a esta deberá realizar lo
;siguiente:
;a- Generar una onda cuadrada por un bit de una puerta de 4 seg. de
;período.
;b- Generar una onda cuadrada por otro bit cuyo semiperiodo lo indique un
;dato a ingresar (considerar como valor inicial 3).
;El dato a ingresar, se hará mediante otra interrupción producida por el
;teclado. El valor a ingresar es de 1 solo dígito expresado en código ASCII que
;representa el semiperiodo, este valor ASCII debe convertirse a binario.
;El programa principal deberá mostrar por display los segundos transcurridos.
;*******************************************************************************
.org 002CH; RS 5.5
;RUTINA DEL TECLADO
PUSH PSW;
;se supone que el teclado esta conectado en el SA en la direccion 84h
IN 84H;leer dato
ANI 0FH;enmascarar nible bajo
MOV B,A;guardarlo en el registro
MVI C, 00H; REINICIA EL CONTADOR DEL PERIODO ACTUAL PARA EVITAR ERRORES
OUT 20H; SUPONIENDO QUE EN 20H ESTA EL FF DE RESET DE LA INTERRUPCION
POP PSW;
EI
RET

.org 0034H; RS 6.5

.org 003CH; RS 7.5
PUSH PSW;
;esta es la rutina de servicio del reloj
;se supone que genera una interrupcion cada 1seg
;debe incrementar todos los contadores
;cambiar los estados
;etc


.org 1000H; PROGRAMA PRINCIPAL



;variables: estado de puertas - pueden estar en un solo registro(dificil de operar) o en dos(creo que es lo mejor), o en cuatro (innecesario)
;8 bits: estado 1, estado 2, contador 1, contador 1, contador 2(resto de los 4)
