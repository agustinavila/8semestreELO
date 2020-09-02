;*******************************************************************************
;se debe realizar un teclado de alarma con cuatro zonas basado en el 8085.
;El sistema posee las siguientes interfaces:
;a) 1 teclado
;b) 4 interruptores de entrada de zonas de sensado
;c) 1 display lcd.
;
; Funcionamiento del sistema:
;Con el teclado se ingresa la clave (cuatro digitos) para activar y desactivar la alarma.
;Al estar activada se debe monitorear las zonas. Por display LCD se debe mostrar los
;estados de la alarma: "Act", "Desact" y "Zona X act".
;Las direcciones de los dispositivos seran asignadas de acuerdo a la siguiente tabla:
;Teclado ->	Teclado (in 82h)
;Interruptores de sensores de zona -> puerta 84H, bits 3-0
; Buzzer -> Puerta B (de un 8155)
;*******************************************************************************

	.org 1100h
	TECLA2	 EQU 09C8H
	LCD_DATA EQU 1500H
	LXI SP,17FFh ; SP EN 17FFH

;GUARDO LA CONTRASEÑA EN MEMORIA:
	LXI	H, 1400H
	MVI M, 01H;
	INR L;
	MVI M, 02H;
	INR L;
	MVI M, 03H;
	INR L;
	MVI M, 04H;
	MVI L, 00H; LO VUELVE A APUNTAR AL PRIMER DATO

;-------------------------------------------
;Inicializacion de la alarma
;-------------------------------------------

;el bit 0 esta en 1 (PA salida), el bit 1 esta en 1 (PB salida)
;en el bit 0 de la puerta b(72H) esta el buzzer
;en el puerto A esta el lcd
;en la entrada 82h esta el teclado, escribe el nible bajo

	MVI	A,03H	 ;CONFIG 8155  
	OUT	70H	 ;BIT 0 = 1(escribo registro comando estado)
	CALL	INIC	 ;INICIALIZO LCD
	MVI A, 04H;		EN D ESTA EL ESTADO (ON/OFF) Y EN E ESTA EL CONTADOR DE LA CONTRASEÑA
	STA 1410H
	;B CREO QUE LO USA EL LCD
	;C LO USA EL LECTOR DE ZONA PARA MANTENER UNA COPIA
	;D INDICA EL ESTADO ACTUAL
	;E SE UTILIZA PARA CONTROLAR LA CONTRASEÑA
	CALL DESACT
	CALL TECLA2
	MVI D,0FFH
	CALL CAMBIOESTADO
BUCLE:
	CALL LEERTECLA
	MOV A,D; TRAE EL REGISTRO DE ESTADO AL AC
	ADI 00H;
	CNZ LEERZONA;	SI LA ALARMA ESTA ACTIVADA, LEE LA ZONA
	;SUPONIENDO QUE LA ENTRADA DE TECLADO  ES POR INTERRUPCION NO TIENE QUE LEER TECLADO ACA
	JMP BUCLE;

;FUNCIONAMIENTO:
;La alarma llama a tecla1, ese valor lo guarda en el acumulador
;Si es igual al primer digito de la alarma (lo compara con un LUGAR DE MEMORIA)
;incrementa el RP H, carga en el registro de comparacion el siguiente bit, 
;decrementa un contador (en registro D) y vuelve a llamar a tecla1.
;Si no es el bit indicado, reinicia el ciclo (reinicia contador, reinicia lugar en memoria y recarga digito)
;Si es correcto el numero ingresado 4 veces seguidas, la alarma cambia de estado
;On/off. Mientras esté en off, la alarma no sensa las zonas.
;Cuando esta en on, censa las zonas y las muestra por display.


CAMBIOESTADO:			;SE INVOCA ESTA RUTINA CUANDO SE INGRESA CORRECTAMENTE LA CONTRASEÑA
						;LO UNICO QUE HACE ES ACTUALIZAR EL LCD
						;Y EL REGISTRO QUE INDICA ACTIVA/DESACTIVA (REG D)
	PUSH PSW
	MVI L, 00H;			REINICIA PARA LA CONTRASEÑA
	MVI A, 04H;
	STA 1410H;
	XRA A;				PONE EL ACUMULADOR EN 0
	CMP D;				COMPARA CON EL ESTADO ACTUAL
	JZ ACTIVA;			SI EL ESTADO ACTUAL ES CERO, ACTIZA LA ALARMA
	MVI D, 00H;			SI NO, LA DESACTIVA
	MVI A,80H
	CALL COMANDO
	CALL DESACT;		ESCRIBE EN EL LCD QUE LA ALARMA ESTA DESACT
	POP PSW
	RET;
ACTIVA:
	MVI D, 0FFH;
	MVI A,80H
	CALL COMANDO
	CALL ACT;			ESCRIBE EN EL LCD QUE LA ALARMA ESTA ACTIVA
	POP PSW;
	RET;


LEERTECLA:
	PUSH PSW
	PUSH B
	CALL TECLA2; 		INDISTINTO, CARGA EL VALOR
	ANI 0FH
	MVI B, 0FH
	CMP B
	JNZ SIGUIENTE1
	POP B
	POP PSW
	RET
SIGUIENTE1:
	CMP E;
	JNZ  PROX
	POP B
	POP PSW
	RET;
PROX:
	MOV E,A
	CMP M	
	JZ SIGUIENTE; 		SI ES IGUAL, LO ACEPTA Y CARGA EL SIGUIENTE
	MVI E, 11H;
	MVI L, 00H;			SI NO ES IGUAL AL QUE CORRESPONDE VUELVE AL INICIO
	MVI A, 04H;			REINICIA EL CONTADOR
	STA 1410H;			LO GUARDA EN MEMORIA
	POP B
	POP PSW
	RET;
SIGUIENTE:
	INR L;				CARGA EL SIGUIENTE DIGITO DE LA CONTRASEÑA
	LDA 1410H
	DCR A;				SUPONIENDO EN QUE EN E TENGO EL CONTADOR
	STA 1410H
	CZ CAMBIOESTADO;
	POP B
	POP PSW
	RET;


LEERZONA: 				;Rutina que lee los sensores, activa el buzzer y manda al display la zona
	IN 84H;
	ANI 0FH
	MOV C,A; 			GUARDA UNA COPIA DE LA LECTURA EN C
	ANI 08H;			VA ENMASCARANDO BIT A BIT, CON PRIORIDAD A LA ZONA 4
	JNZ ACTCUATRO;		EN EL MOMENTO QUE ENCUENTRA UNA ZONA ACTIVA, LA ESCRIBE EN PANTALLA
	MOV A,C;			Y ACTIVA EL BUZZER
	ANI 04H;
	JNZ ACTRES;
	MOV A,C;
	ANI 02H;
	JNZ ACTDOS;
	MOV A,C;
	ANI 01H;
	JNZ ACTUNO;
	MVI A,80H
	CALL COMANDO
	CALL ACT;			SI NINGUN SENSOR ESTA ACTIVO, SOLO DICE "ACT" (REPOSO)
	CALL BUZZEROFF;		Y APAGA EL BUZZER
	RET;
ACTCUATRO:
	MVI B, 34H;
	MVI A, 80H
	CALL COMANDO;
	CALL ZONA;
	CALL BUZZER;
	RET;
ACTRES:
	MVI B, 33H;
	MVI A, 80H
	CALL COMANDO;
	CALL ZONA;
	CALL BUZZER;
	RET;
ACTDOS:
	MVI B, 32H;
	MVI A, 80H
	CALL COMANDO;
	CALL ZONA;
	CALL BUZZER;
	RET;
ACTUNO:
	MVI B, 31H;
	MVI A, 80H
	CALL COMANDO;
	CALL ZONA;
	CALL BUZZER;
	RET;



BUZZER:					;RUTINA QUE ENCIENDE EL BUZZER
	PUSH PSW; 			GUARDA EL ACUMULADOR
	MVI A, 01H; 		PONE EN 1 EL BIT DEL BUZZER
	OUT 86H;			LO SACA POR LA PUERTA B DEL 8155
	POP PSW; 			LO RECUPERA
	RET;


BUZZEROFF:				;RUTINA QUE APAGA EL BUZZER
	PUSH PSW; 			GUARDA EL ACUMULADOR
	MVI A, 00H; 		PONE EN 0 EL BIT DEL BUZZER
	OUT 86H;			LO SACA POR LA PUERTA B DEL 8155
	POP PSW; 			LO RECUPERA
	RET;








;-------------------------------------------
;Rutinas de cambio de estado de la alarma
;-------------------------------------------

ACT:
	PUSH PSW
	;MVI A, 01H
	;CALL COMANDO;
	;MVI A, 82H;
	;CALL COMANDO;
	MVI A, 40H;	ASCII "A"
	CALL INFO;
	MVI A, 63H; ASCII "c"
	CALL INFO;
	MVI A, 74H; ASCII "t"
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;

	POP PSW
	RET;

DESACT:
	PUSH PSW
	;MVI A, 01H
	;CALL COMANDO;
	;MVI A, 82H;
	;CALL COMANDO;
	MVI A, 44H;	ASCII "D"
	CALL INFO;
	MVI A, 65H; ASCII "e"
	CALL INFO;
	MVI A, 73H; ASCII "s"
	CALL INFO;
	MVI A, 61H;	ASCII "a"
	CALL INFO;
	MVI A, 63H; ASCII "c"
	CALL INFO;
	MVI A, 74H; ASCII "t"
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	POP PSW
	RET;

ZONA:
	PUSH PSW

	;MVI A, 82H;
	;CALL COMANDO;
	MVI A, 5AH;	ASCII "Z"
	CALL INFO;
	MVI A, 6FH; ASCII "o"
	CALL INFO;
	MVI A, 6EH; ASCII "n"
	CALL INFO;
	MVI A, 61H;	ASCII "a"
	CALL INFO;
	MVI A, 20H;	ASCII " "
	CALL INFO;
	MOV A,B; TRAE EL REGISTRO CON LA ZONA QUE SE ACTIVO AL ACUMULADOR
	CALL INFO;
	MVI A, 20H; ASCII " "
	CALL INFO;
	MVI A, 61H;	ASCII "a"
	CALL INFO;
	MVI A, 63H; ASCII "c"
	CALL INFO;
	MVI A, 74H; ASCII "t"
	CALL INFO;
	POP PSW
	RET;

	








;-----------------------------------
;De aca para abajo, rutinas del lcd:
;-----------------------------------

INIC:	
	MVI	A,00H
	OUT	71H; Supongo que es el puerto A del 8155

	CALL	D_LCD
	CALL	D_LCD
	CALL	D_LCD
	CALL	D_LCD
	
	MVI	A,30H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,30H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,030H
	CALL	DATA
	CALL	D_LCD			

	;;;;;;;;;;;;;

	MVI	A,20H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,20H
	CALL	DATA
	CALL	D_LCD			
	
	MVI	A,80H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,00H
	CALL	DATA
	CALL	D_LCD

	MVI	A,80H
	CALL	DATA
	CALL	D_LCD	

	MVI	A,00H
	CALL	DATA
	CALL	D_LCD			
		
	MVI	A,0F0H
	CALL	DATA
	CALL	D_LCD	

	MVI	A,00H
	CALL	DATA
	CALL	D_LCD			
	
	MVI	A,60H
	CALL	DATA
	CALL	D_LCD	

	MVI	A,00H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,10H
	CALL	DATA
	CALL	D_LCD

	MVI	A,00H
	CALL	DATA
	CALL	D_LCD			

	MVI	A,20H
	CALL	DATA
	CALL	D_LCD			
	
	RET		
		

			

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; DELAY LCD ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

D_LCD:
		MVI D,00H
V1:		DCR D
		JNZ V1		
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; ESCRIBIR COMANDO ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA:		
	ANI	0F0H
	ADI	08H
	OUT	71H
	NOP
	NOP
	ANI	0F0H
	OUT	71H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; ESCRIBIR DATO ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

INFO:	
	STA	LCD_DATA
	ANI	0F0H
	ADI	0CH
	OUT	71H
	NOP
	NOP
	ANI	0F0H
	ADI	04H
	OUT	71H

	LDA	LCD_DATA
	RLC
	RLC
	RLC
	RLC
	ANI	0F0H
	ADI	0CH
	OUT	71H
	NOP
	NOP
	ANI	0F0H
	OUT	71H

	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; COMANDO ;;;;;;;;;;;
; 8X -> 1ra FILA - X COLUMNA ;
; CX -> 2da FILA - X COLUMNA ;
; 01 -> LIMPIA DISPLAY       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

COMANDO:
	STA	LCD_DATA
	ANI	0F0H
	ADI	08H
	OUT	71H
	NOP
	NOP
	ANI	0F0H
	ADI	04H
	OUT	71H

	LDA	LCD_DATA
	RLC
	RLC
	RLC
	RLC
	ANI	0F0H
	ADI	08H
	OUT	71H
	NOP
	NOP
	ANI	0F0H
	OUT	71H

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;