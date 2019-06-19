#include <REG51.H>
#include <lcd.h>
//variables especiales C51
sbit Salida1 = P1^6;
sbit Salida2 = P1^7;
//variables globales
unsigned char tiempo[4];
unsigned char tiempototal, tiempo1, tiempo2 , tiempo3 , tiempo4;
//declaracion de funciones
void initT0M1(void);
void cargarValores(void);
void mostrarLCD (unsigned char dato,unsigned char c);

//programa principal
void main(void){
	//inicializaciones
	Salida1 = 0;			//P0.0 como salida
	Salida2 = 0;			//P0.1 como salida
	EX0=1;
	IT1=1;
	initT0M1();
	IniciarLCD();										//Inicializo el LCD
	BorrarLCD();										//Limpio el LCD
	cargarValores();
	EA=1;
	//Loop
 	while (1){
	}
}


//Interrupciones
void intExt(void) interrupt 0 {
	cargarValores();
}

void intT0() interrupt 1 {
	static unsigned char cont = 0;
	static unsigned char cont2 = 0;
	static unsigned char indice = 0;
	TR0=0;
	TH0=0xD8;
	TL0=0xF0;
	TR0=1;
	cont++;
	cont2++;
	if (cont==tiempo[indice])
	{
		if(indice==3){
			indice=0;
		} else indice++;
		cont=0;
		Salida1=~Salida1;
	}

	if(cont2==(tiempototal)){
		if(tiempototal>0){
			Salida2 =~ Salida2;		// toggle
			cont2 = 0;
		}else{
			Salida2 = 0;
			cont2 = 0;
		}
//		#pragma asm
//		lcall monitor
//		#pragma endasm
}}
//Salida2 =~ Salida2;


//Declaracion de funciones

void initT0M1(){
	TR0=0;
	TMOD&=0xF0;
	TMOD|=0x01;
	TH0=0xD8;
	TL0=0xF0;
	//TR0=1;
	TF0=0;
	ET0=1;
}

void cargarValores(void){
	TR0=0;
	SetCursor(1,0);							//Cursor Fila: 1 Col: 0
	EscribirLCD("ingrese tiempo1 en ms");		//Escribo LCD# pragma asm
	# pragma asm
	LCALL 0x003c; 		//direccion de getchr
	# pragma endasm
	tiempo1=0x0F&ACC;
	SetCursor(1,0);							//Cursor Fila: 1 Col: 0
	EscribirLCD("ingrese tiempo2 en ms");		//Escribo LCD# pragma asm
	# pragma asm
	LCALL 003Ch
	# pragma endasm
	tiempo2=0x0F&ACC;
	SetCursor(1,0);							//Cursor Fila: 1 Col: 0
	EscribirLCD("ingrese tiempo3 en ms");		//Escribo LCD# pragma asm
	# pragma asm
	LCALL 003Ch
	# pragma endasm
	tiempo3=0x0F&ACC;
	SetCursor(1,0);							//Cursor Fila: 1 Col: 0
	EscribirLCD("ingrese tiempo4 en ms");		//Escribo LCD# pragma asm
	# pragma asm
	LCALL 003Ch
	# pragma endasm
	tiempo4=0x0F&ACC;
	tiempototal=tiempo1+tiempo2-tiempo3-tiempo4;
	if(tiempototal<0){
		SetCursor(2,0);		//Cursor Fila: 2 Col: 15
		EscribirLCD("Error!");	//Mensaje de error !
		tiempototal=-tiempototal;
	}
	tiempototal=tiempototal/2;
	mostrarLCD(tiempo1,0);
	mostrarLCD(tiempo2,3);
	mostrarLCD(tiempo3,6);
	mostrarLCD(tiempo4,9);
	mostrarLCD(tiempototal,12);
	tiempo[0]=tiempo1;
	tiempo[1]=tiempo2;
	tiempo[2]=tiempo3;
	tiempo[3]=tiempo4;
	TR0=1;
}
void mostrarLCD (unsigned char dato,unsigned char c){
	SetCursor(2,c);
	EscribirNum(dato);	//escribo LCD
}
//Fin
