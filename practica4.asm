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
;se supone que el teclado esta en 00h y el display en 80h y 81h
;*******************************************************************************


;en B y en C tengo los estados de las SALIDAS
;en d y en e tengo los semiperiodos
;se supone que el teclado esta conectado en el SA en la direccion 84h
;se sabe que al ser un digito, sus codigos ascii van de 30 a 39


.data 1200h;
dB 77H,44H,3EH,6EH,4DH,6BH,7BH,47H,7FH,4FH
;DATOS DEL LCD
.ORG 0000H
JMP 1000H;

.org 0034H; 	RS 6.5 BANDERA 1
JMP 0200H
.ORG 0200H
PUSH PSW
MVI A, 01H; 	CARGA EL AC CON 1
STA 1300H;
OUT 70H
POP PSW
EI
RET


.ORG 0024H; 	TRAP BANDERA 2
JMP 0150H
.ORG 0150H
PUSH PSW 
MVI A, 01H;
STA 1301H;
OUT 71H
POP PSW
EI
RET



.org 002CH; 		RS 5.5
;RUTINA DEL TECLADO
	PUSH PSW;
	JMP 0100H
	.ORG 0100H
	IN 00H;			leer dato de teclado
	ANI 0FH;		enmascarar nible bajo
	STA 1305H;	SOBREESCRIBE EL SEMIPERIODO
	OUT 73H; 		SUPONIENDO QUE EN 73H ESTA EL FF DE RESET DE LA INTERRUPCION
	POP PSW;
	EI
	RET


.org 003CH; 		RS 7.5 rutina servicio del reloj
	PUSH PSW;
	LDA 1300H;
	ADI 00H;
	JZ BAND2;		SI ES CERO, COMPRUEBA LA BANDERA 2
	DCR E;			CONTADOR DE 4SEG
	JNZ BAND2;		SI NO LLEGO A CERO, CONTINUA CON LA OTRA TAREA
	MVI E, 04H;		VUELVE A CARGAR EL CONTADOR
	MOV A,B;		TRAIGO EL ESTADO DE LA SALIDA
	ADI 00H;
	JZ INVIERTE1;	SI LA SALIDA ES 1, LA LLEVA A CERO
	XRA A;			PONE EL AC EN CERO
	OUT 85H;		LO SACA POR 85H
	MOV B,A;		GUARDA LA IMAGEN DE LA SALIDA
	JMP BAND2;		SIGUE CON LA OTRA BANDERA
INVIERTE1:
	INR A;			SI ES CERO LA PONE EN 1
	OUT 85H;		LA SACA POR LA COMPUERTA
	MOV B,A;		GUARDA LA IMAGEN DE LA SALIDA
BAND2:
	LDA 1301H;	TRAE LA BANDERA 2
	ADI 00H;
	JZ SALIR;		SI ES CERO, SIGUE
	DCR D;			CONTADOR DE 3SEG(VARIABLE)
	JNZ SALIR;		SI TODAVIA NO LLEGA A CERO, SALE
	LDA 1305H;	SI ES CERO, CARGA EL VALOR INGRESADO
	MOV D,A;		LO RECARGA EN D
	MOV A,C;		TRAE EL VALOR DE C (IMAGEN DE LA SALIDA 2)
	ADI 00H;
	JZ INVIERTE2;	SI ES CERO LO LLEVA A UNO
	XRA A;			SI ES UNO SE LLEVA A 0
	OUT 86H;		Y SE SACA POR EL PUERTO 86
	MOV C,A;		GUARDA LA IMAGEN DE LA SALIDA
	JMP SALIR;
INVIERTE2:
	INR A;			SI ES CERO LA PONE EN 1
	OUT 86H;		LA SACA POR 86
	MOV C,A;		GUARDA LA IMAGEN DE LA SALIDA
SALIR:
	MOV A, L;
	ADI 01H;
	DAA;
	MOV L, A;
	MVI A, 01H;		PONE EN 1 LA BANDERA DE TIEMPO
	STA 1310H;
	POP PSW
	EI;
	RET


.org 1000H; 		PROGRAMA PRINCIPAL
	LXI SP, 3000H
	LXI B,0000H;
	LXI H,0000H;
	MVI E, 04H;
	MVI D, 03H;
	MOV A,E;
	CALL TIEMPO;
	MVI A,03H;
	STA 1305H;		LO GUARDA EN EL SEGUNDO SEMIPERIODO
	XRA A;
	STA 1300H;
	STA 1301H;
	OUT 85H;			PONE LAS SALIDAS EN 0
	OUT 86H;
	EI;

	
BUCLE:
	LDA 1310H;
	ADI 00H;
	CNZ TIEMPO;
	JMP BUCLE;

TIEMPO:;			RUTINA QUE MUESTRA SEGUNDOS TRANSCURRIDOS
	PUSH D;			GUARDA EL RP
	PUSH H;			GUARDA EL RP
	MVI H,12H;		CARGA LA PARTE ALTA DEL PUNTERO
	MOV A,L;		TRAE EL CONTADOR EN BCD
	MOV D,L;
	ANI F0H;
	RAR;			LO ROTA 4 VECES PARA APUNTAR A LA TABLA DE CONVERSION
	RAR;
	RAR;
	RAR;
	MOV L,A;		PONE EL PUNTERO
	MOV A,M;		TRAE EL DATO DE UNA TABLA
	OUT 00H;		LO SACA POR LA PUERTA 1
	MOV A,D;		VUELVE A TRAER EL DATO ORIGINAL
	ANI 0FH;		ENMASCARA EL NIBLE BAJO
	MOV L,A;		LO PONE COMO PUNTERO
	MOV A,M;		TRAE EL DATO
	OUT 01H;		LO SACA POR LA COMPUERTA
	XRA A;
	STA 1310H;
	POP H
	POP D;
	RET;
