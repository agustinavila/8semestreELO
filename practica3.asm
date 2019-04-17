;************************************************************************************
; en memoria se encuentran almacenados tres datos:
; dato 1: binario MyS 13b total
; dato 2: BCD 12b + 1b Signo SRC10
; dato 3: SRC2 12b
;
; Se debe encontrar el mayor y verificar si se puede representar en SRC2 8b
; se deben llevar 3 ejemplos que verifiquen  desbordes, con num positivos y negativos.
;************************************************************************************

.data 0200h
dB 00h,ffh,32h,22h,45h,12h
;  N1H,N1L,N2H,N2L,N3H,N3L
;necesito 2bytes para cada numero
;numero 1: xxxS MMMM MMMM MMMM 	<- parte alta y despues parte baja
;numero 2: xxxS CCCC DDDD UUUU	<- parte alta y despues parte baja
;numero 3: xxxx MMMM MMMM MMMM	<- parte alta y etc.
;0200 0201 <- N1
;0202 0203 <- N2
;0204 0205 <- N3

.org 0100h

		LXI H,0200h;Carga el puntero apuntando al primer dato
		MOV A,M;	Carga la parte alta del dato 1 AL ACUMULADOR
;convertir numero 1 a src2
		ANI 10; 	enmascara el bit de signo
		MOV B,M; 	y guarda la parte alta en el registro b
		INR L;		apunta a la parte baja del dato
		MOV C, M;
		JZ pos1; 	si el numero es positivo evita esta parte
; en este momento tenemos en BC el dato entero
		ORI FFH; 	CARGA EL ACUMULADOR CON FF
		SUB C; 		a ff le resta la parte baja
		INR A; 		le suma 1 para que sea complemento a la base
		MOV C,A; 	guarda la parte baja del complemento
		ORI FFH; 	vuelvo a ponerlo en ff
		SBI B; 		LE RESTA A LA PARTE BAJA FF con carry
		MOV B, A; 	Guarda el dato en B
		JMP PRIM;
pos1:	MOV A,B; 	Carga el dato en 
		ANI 0Fh; 	se asegura de que quede en src2 de 16bits
		MOV B,A;
PRIM:	MVI L, 10h; Carga el puntero con la direccion 0210h
		MOV M, B; 	guarda la parte alta del n1 en 0210h
		INR L;
		MOV M, C; 	guarda la parte baja en 0211h
;queda guardado el dato 1 convertido en 0210 y 0211 como src2 16bits


;a partir de aca empieza a convertir el segundo dato:		
		MVI L, 02H; carga el puntero con 0202, donde esta la parte alta del segundo dato
		MOV A, M; 	trae la parte alta
		ANI 10;		enmascara el bit de signo
		MOV B,M;	trae la parte alta al reg b
		INR L;		incrementa el puntero
		MOV C,M;	trae la parte baja al reg c
		JZ CONV2;	si es cero no lo complementa
		MVI A 99;	carga el acumulador con 99 para complementar
		SUB B;		le resta b (obtiene el complemento)
		MOV B, A;	guarda el resultado en b
		MVI A 99;	repite lo mismo para c
		SUB C;
		ADI 01H;	a la parte baja le suma 1
		;DAA?
		MOV C,A;	guarda la parte baja en c	
		MOV A,B;	trae la parte alta al acumulador
		ACI 00H;	le suma si hay algun carry de la parte baja
		MOV B,A;	lo guarda de vuelta en b
CONV2:	ANI 0F;
		RAL;
		RAL;
		MOV D,A; 	X4 GUARDADO EN D
		RAL;
		RAL;
		RAL;		X32(PARTE BAJA) CON UN BIT EN EL CARRY
		MOV E,A;	GUARDO EL BIT BAJO EN E
		MVI A 00H;	PONGO EL ACUMULADOR EN 0
		RAL;		LE METE EL BIT QUE ESTABA EN EL CARRY
		MOV C,A;	GUARDA ESTA PARTE ALTA EN C
		MOV A,E;	TRAE DE VUELTA LA PARTE BAJA
		RAL;		
		ADD D;
		ADD E;		SUMO TODAS LAS PARTES BAJAS
		MOV E,A;	GUARDO LA PARTE BAJA EN E
		MOV A,C;	TRAIGO LA PARTE ALTA
		ACI 00H;	LE SUMO SI HUBO CARRY
		MOV D,A;	LO GUARDO EN D
		MOV A,B;	TRAIGO EL DATO ORIGINAL
		RAR;		LO ROTO DOS VECES PARA OBTENER
		RAR;		LA PARTE ALTA DEL X64
		ANI 0F;		ENMASCARO LOS 4 BITS BAJOS PARA EVITAR QUE SE METAN DATOS AL ROTAR
		ADD D;		LE SUMO LA PARTE ALTA
		MOV D,A;	LO GUARDO EN D
;EN ESTE MOMENTO ESTARIA EL DATO DE LAS CENTENAS EN EL REG PAR DE
;DEBERIA GUARDARLAS EN MEMORIA???
		MOV A,M;	TRAE LA PARTE BAJA AL ACUMULADOR
		ANI F0H;	ENMASCARA LAS DECENAS
		RAR;		TENGO LAS DECENAS X8
		MOV C,A;	GUARDO ESO EN C
		RAR;		DECENAS X4
		RAR;		DECENAS X2
		ADD C;		LE SUMO LAS DECENAS X8
		MOV A,C;	GUARDO EL DATO EN C
		MOV A,M;	TRAIGO DE VUELTA LA PARTE BAJA
		ANI 0FH;	ENMASCARLO LAS UNIDADES
		ADD C;		SUMO UNIDADES Y DECENAS
		ADD E;		SUMO PARTE BAJA DE CENTENAS
		MOV C,A;	GUARDO ESO EN C
		MOV A,D;	TRAIGO LA PARTE ALTA
		ACI 00H;	LE SUMO SI HAY CARRY;
		MOV B,A;	GUARDO LA PARTE ALTA EN B
;EN ESTE MOMENTO TENGO EL BCD (UNSIGNED) CONVERTIDO A BINARIO UNSIGNED
;A CONTINUACION TENGO QUE VER EL BIT DE SIGNO PARA VER SI COMPLEMENTO O NO
		DCR L;		VUELVO EL PUNTERO A LA PARTE ALTA
		MOV A,M;	TRAIGO EL DATO
		ANI 10;		ENMASCARO EL BIT DE SIGNO
		JZ POS2;	SI ES POSITIVO EVITA LA CONVERSION
		ORI FFH; 	CARGA EL ACUMULADOR CON FF
		SUB C; 		a ff le resta la parte baja
		INR A; 		le suma 1 para que sea complemento a la base
		MOV C,A; 	guarda la parte baja del complemento
		ORI FFH; 	vuelvo a ponerlo en ff
		SBI B; 		LE RESTA A LA PARTE BAJA FF con carry
		MOV B, A; 	Guarda el dato en B
		JMP SEGUND;
POS2:	MOV A,B; 	Carga el dato en 
		ANI 0Fh; 	se asegura de que quede en src2 de 16bits
		MOV B,A;
SEGUND:	MVI L, 20h; Carga el puntero con la direccion 0220h
		MOV M, B; 	guarda la parte alta del n1 en 0220h
		INR L;
		MOV M, C; 	guarda la parte baja en 0221h
;EN ESTE MOMENTO TENEMOS GUARDADO EN MEMORIA:
;DATO 1 CONVERTIDO A SRC2 EN 0210 Y 0211
;DATO 2 CONVERTIDO A SRC2 EN 0220 Y 0221
;EL TERCER DATO NO NECESITA SER CONVERTIDO

;A PARTIR DE ACA COMIENZA A COMPARAR VALORES


;
;Primer, convertirlos a los tres a SRC2
;Para el primero, simplemente ver el bit de signo a ver si hay que obtener el complemento
;		Este seria sencillo

;Para el segundo, convertir de bcd a SRC2, deberia quedar de 9 bits mas o menos
;		Analizar el bit de signo (enmascararlo), segun eso ver si obtener el complemento?
;Para el tercero, no hacer nada.
;
;Luego, analizar los bytes altos (compararlos). Posibles situaciones:
;1 > 2 -> comparar 1 y 3, el mayor es mayor
;1 = 2 -> comparar con 3, si tambien es igual analizar partes bajas
;1 < 2 -> comparar 2 y 3, el mayor es mayor.
;
;teniendo el mayor, comprobar si se puede representar en 8bits
;para eso, habria que chequear el byte alto? A ver si es ff o 00?