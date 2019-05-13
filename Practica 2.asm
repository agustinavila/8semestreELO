;-------------------------------------------------------------------------------------------------------
;Se desea realizar un circuito de control para el toldo de una terraza de una vivienda. El toldo tiene la
;función tanto de dar sombra como de proteger del viento y de la lluvia. Así que es un toldo resistente al
;viento y a la lluvia, manteniendo la terraza seca en los días de lluvia.
;Para el circuito de control tenemos las siguientes entradas:
;Señal S: Indica si hay sol
;Señal L: Indica si llueve
;Señal V: Indica si hay mucho viento
;Señal F: Indica si hace frío en el interior de la casa.
;Según los valores de estas entradas se bajará o subirá el toldo. Esto se realizará mediante la señal de
;salida BT (Bajar Toldo). Si BT='1' indica que el toldo debe estar extendido (bajado) y si BT='0' indica
;que el toldo debe estar recogido (subido).
;El circuito que acciona el toldo debe funcionar según las siguientes características:
;Independientemente del resto de señales de entrada, siempre que llueva se debe de extender el toldo
;para evitar que se moje la terraza. No se considerará posible que simultáneamente llueva y haga sol.
;Si hace viento se debe extender el toldo para evitar que el viento moleste. Sin embargo, hay una
;excepción: aún cuando haya viento, si el día está soleado y hace frío en la casa, se recogerá el toldo para
;que el sol caliente la casa.
;Por último, si no hace viento ni llueve, sólo se bajará el toldo en los días de sol y cuando haga calor en
;el interior, para evitar que se caliente mucho la casa.
;-----------------------------------------------------------------------------------------------------------

;para resolver el problema, se genero una tabla de verdad con las distintas combinaciones de entradas
;se guaro esas combinaciones en memoria y directamente el estado de las entradas genera el estado
;de las salidas.

.data 0200h
dB 00h,FFh,00h,FFh,FFh,FFh,FFh,FFh,00h,FFh,00h,00h,FFh,FFh,FFh,FFh
.org 00H
	LXI H,0200H;	MVI H,02H; 		FIJA LA PARTE ALTA DE LA MEMORIA
LEE:	IN 00h;		LEE LAS DISTINTAS ENTRADAS
	CMP L;			PARA EVITAR TANTAS LECTURAS, SE FIJA QUE EL DATO
	JZ LEE;			NO HAYA CAMBIADO, SI NO SIGUE LEYENDO
	MOV L, A;		ESA LECTURA LA GUARDA EN LA PARTE BAJA DE MEMORIA
	MOV A, M;		LEE LA RESPUESTA SEGUN LA TABLA DE VERDAD
	OUT 00h;		ESCRIBE EL RESULTADO EN LA SALIDA
	JMP LEE;		VUELVE A LEER LA ENTRADA
	HLT