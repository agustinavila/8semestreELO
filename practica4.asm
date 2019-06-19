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
;se supone que el teclado esta en 84h y el display en 80h y 81h
;*******************************************************************************


;en B y en C tengo los estados de las SALIDAS
;en d y en e tengo los semiperiodos
;se supone que el teclado esta conectado en el SA en la direccion 84h
;se sabe que al ser un digito, sus codigos ascii van de 30 a 39


.data 1200h;
.dB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H;DATOS DEL LCD


.org 0034H; 	RS 6.5 BANDERA 1
JMP 0200H
.ORG 0200H
PUSH PSW
MVI A, 01H; 	CARGA EL AC CON 1
STA SALIDA1;
OUT 70H
POP PSW
EI
RET


.ORG 00228H; 	RS 5 BANDERA 2
JMP 0150H
.ORG0150H
PUSH PSW 
MVI A, 01H;
STA BANDERA2;
OUT 71H
POP PSW
EI
RET



.org 002CH; 	RS 5.5
;RUTINA DEL TECLADO
	PUSH PSW;
	JMP 0100H
	.ORG 0100H
	IN 84H;		leer dato
	ANI 0FH;enmascarar nible bajo
	STA PERIODO2;	SOBREESCRIBE EL SEMIPERIODO
	OUT 73H; SUPONIENDO QUE EN 73H ESTA EL FF DE RESET DE LA INTERRUPCION
	POP PSW;
	EI
	RET


.org 003CH; RS 7.5 rutina servicio del reloj
	PUSH PSW;
	LDA BANDERA1;
	JZ BAND2;
	DCR D;		CONTADOR DE 4SEG
	JNZ BAND2;	SI NO LLEGO A CERO, CONTINUA CON LA OTRA TAREA
	MVI E, 04H;	VUELVE A CARGAR EL CONTADOR
	MOV A,B;	TRAIGO EL ESTADO DE LA SALIDA
	JZ INVIERTE1;
	XRA A;
	OUT 85H;
	MOV B,A;	GUARDA LA IMAGEN DE LA SALIDA
	JMP BAND2;
INVIERTE1:
	INR A;		SI ES CERO LA PONE EN 1
	OUT 85H;	
	MOV B,A;	GUARDA LA IMAGEN DE LA SALIDA
BAND2:
	LDA BANDERA2
	JZ SALIR
	DCR E;		CONTADOR DE 3SEG(VARIABLE)
	JNZ SALIR;
	LDA PERIODO2;
	MOV E,A;
	MOV A,C;
	JZ INVIERTE2:
	XRA A;
	OUT 86H;
	MOV C,A;	GUARDA LA IMAGEN DE LA SALIDA
	JMP SALIR;
INVIERTE2:
	INR A;		SI ES CERO LA PONE EN 1
	OUT 86H;	
	MOV C,A;	GUARDA LA IMAGEN DE LA SALIDA
SALIR:
	INR L;
	DAA;
	MOV A,H;
	ACI 00H;
	DAA;
	MVI A, 01H
	STA BANDERAT;
	RET


.org 1000H; PROGRAMA PRINCIPAL

	BANDERA1 EQU 1300H;
	BANDERA2 EQU 1301H;
	PERIODO2 EQU 1305H;
	BANDERAT EQU 1306H;
	MVI D, 04H;
	DRC A;				PONE EL AC EN 3
	MOV E, A;			GUARDA EL CONTADOR EN E
	STA PERIODO2;		LO GUARDA EN EL SEGUNDO SEMIPERIODO
	XRA A;
	STA BANDERA1;
	STA BANDERA2;
	OUT 85H;			PONE LAS SALIDAS EN 0
	OUT 86H;

	
BUCLE:
	LDA BANDERA1;
	ADI 00H;
	CNZ TIEMPO;
	JMP BUCLE;

BANDERA1:
	MOV A, H;
	ANI 10H;	ENMASCARA EL BIT DE BANDERA
	JZ PRENDE;
	MOV A,H;	TRAE DE VUELTA PARA CAMBIAR ESE BIT
	ANI EFH;	FUERZA EL BIT A CERO
	MOV H,A;	LO GUARDA NUEVAMENTE EN H
	XRA A;		LO PONE EN CERO
	OUT 85H;
	RET
PRENDE:
	MOV A,H;	TRAE DE VUELTA PARA CAMBIAR ESE BIT
	ORI 10H;	FUERZA EL BIT A UNO
	MOV H,A;	LO GUARDA NUEVAMENTE EN H
	OUT 85H;
	RET;


BANDERA2:
	MOV A, H;
	ANI 01H;	ENMASCARA EL BIT DE BANDERA
	JZ PRENDE2;
	MOV A,H;	TRAE DE VUELTA PARA CAMBIAR ESE BIT
	ANI FEH;	FUERZA EL BIT A CERO
	MOV H,A;	LO GUARDA NUEVAMENTE EN H
	XRA A;		LO PONE EN CERO
	OUT 86H;
	RET
PRENDE2:
	MOV A,H;	TRAE DE VUELTA PARA CAMBIAR ESE BIT
	ANI 01H;	FUERZA EL BIT A CERO
	MOV H,A;	LO GUARDA NUEVAMENTE EN H
	OUT 85H;
	RET;

TIEMPO:
	PUSH D;		GUARDA EL RP
	PUSH H;		GUARDA EL RP
	MVI H,13H;	CARGA LA PARTE ALTA DEL PUNTERO
	MOV A,D		;TRAE EL CONTADOR EN BCD
	ANI F0H;
	RAR;		LO ROTA 4 VECES PARA APUNTAR A LA TABLA DE CONVERSION
	RAR;
	RAR;
	RAR;
	MOV L,A;	PONE EL PUNTERO
	MOV A,M;	TRAE EL DATO DE UNA TABLA
	RAL;		LO ROTA A LA IZQUIERDA PARA PONERLO EN LAS DECENAS NUEVAMENTE
	RAL;
	RAL;
	RAL;
	MOV C,A;	LO MUEVE A OTRO REGISTRO
	MOV A,D;	VUELVE A TRAER EL DATO ORIGINAL
	ANI 0FH;	ENMASCARA EL NIBLE BAJO
	MOV L,A;	LO PONE COMO PUNTERO
	MOV A,M;	TRAE EL DATO
	ADD C;		SUMA LA PARTE BAJA Y ALTA
	OUT 88H;	LO SACA POR LA COMPUERTA
	POP H
	POP D;
	RET;
;variables: estado de puertas - pueden estar en un solo registro(dificil de operar) o en dos(creo que es lo mejor), o en cuatro (innecesario)
;8 bits: estado 1, estado 2, contador 1, contador 1, contador 2(resto de los 4)
