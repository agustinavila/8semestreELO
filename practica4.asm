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