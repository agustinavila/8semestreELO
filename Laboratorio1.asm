;*******************************************************************************
;se debe realizar un teclado de alarma con cuatro zonas basado en el 8085.
;El sistema posee las siguientes interfaces:
;a) 1 teclado
;b) 4 interruptores de entrada de zonas de sensado
;c) 1 display lcd.
;
; Funcionamiento del sistema:
;Con el trclado se ingresa la clave (cuatro digitos) para activar y desactivar la alarma.
;Al estar activada se debe monitorear las zonas. Por display LCD se debe mostrar los
;estados de la alarma: "Act", "Desact" y "Zona X act".
;Las direcciones de los dispositivos seran asignadas de acuerdo a la siguiente tabla:
;Teclado ->	Teclado
;Interruptores de sensores de zona -> puerta 84H, bits 3-0
; Buzzer -> Puerta B (de un 8155)
;*******************************************************************************

	LCD_DATA EQU 1500H
	LXI 	SP,17FFh ; SP EN 17FFH

	MVI	A,01H	 ;CONFIG 8155  
	OUT	70H	 ;BIT 0 = 1(escribo registro comando estado)
	
	CALL	INIC	 ;INICIALIZO LCD


;le entra una interrupcion por segundo
;En cada interrupcion debe incrementar un contador
;o mejor dicho tres:
;uno que cuente hasta 2 y se reinicie (cada 2seg cambiar el estado)
;uno que cuente inicialmente hasta 3, pero que se pueda modificar con un interrupt
;es decir, deberia tener el valor 3 en un registro, y que el interrupt sobreescriba el valor

;funciones que deberia tener:
;rst que incremente los contadores
;normalmente tiene que estar chequeando el valor e invirtiendolo
;rst que lea el valor del teclado (de menor prioridad que el temporal)

;variables: estado de puertas - pueden estar en un solo registro(dificil de operar) o en dos(creo que es lo mejor), o en cuatro (innecesario)
;8 bits: estado 1, estado 2, contador 1, contador 1, contador 2(resto de los 4)

;contadores de puertas
;mostrar valor de tiempo actual





ACT:
	MVI A, 40H;	ASCII "A"
	CALL INFO;
	MVI A, 63H; ASCII "c"
	CALL INFO;
	MVI A, 74H; ASCII "t"
	CALL INFO;
	RET;

DESACT:
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
	RET;

ZONA:
	MVI A, 5AH;	ASCII "Z"
	CALL INFO;
	MVI A, 6FH; ASCII "o"
	CALL INFO;
	MVI A, 64H; ASCII "n"
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
	RET;

	

;-----------------------------------
;De aca para abajo, rutinas del lcd:
;-----------------------------------

INIC:	
	MVI	A,00H
	OUT	71H

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