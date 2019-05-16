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
.data 1200h;
.dB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H;DATOS DEL LCD

.org 002CH; RS 5.5
;RUTINA DEL TECLADO
	PUSH PSW;
;se supone que el teclado esta conectado en el SA en la direccion 84h
	IN 84H;leer dato
;se sabe que al ser un digito, sus codigos ascii van de 30 a 39
	ANI 0FH;enmascarar nible bajo
	MOV L,A;guardarlo en el registro
	MVI E, 00H; REINICIA EL CONTADOR DEL PERIODO ACTUAL PARA EVITAR ERRORES
	OUT 20H; SUPONIENDO QUE EN 20H ESTA EL FF DE RESET DE LA INTERRUPCION
	POP PSW;
	EI
	RET

.org 0034H; RS 6.5


.org 003CH; RS 7.5
	PUSH PSW;
	INR D;		CONTADOR DE 4SEG	
	INR E;		CONTADOR DE 3SEG(VARIABLE)
	MOV A,E;	TRAE EL CONTADOR
	ADI 01H;	SUPONGO QUE PUEDO USAR UN INR
	DAA;		SE ASEGURA DE QUE CUENTE EN BCD
	MOV E,A;	LO GUARDA DE VUELTA
	CALL TIEMPO;
	POP PSW
	EI;
	RET


;en H y en L tengo los dos valores de los semiperiodos
;en B y en C tengo los estados de las banderas


.org 1000H; PROGRAMA PRINCIPAL
	LXI D, 23H; CARGA D CON 2 Y E CON 3
	LXI H, 00H;	PONE LAS BANDERAS EN 0

BUCLE:
	MOV A,B;
	CMP D;
	CZ BANDERA1;
	MOV A,C;
	CMP E;
	CZ BANDERA2;
	CALL TIEMPO;
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
