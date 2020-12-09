#include <AFMotor.h> //solamente si utiliza el shield arduino motor v1. Si se usa algún chip puente H (por ejemplo L293D) se recomienda utilizar la librería TimerThree.zip
#include <TimerOne.h>
#include <PID_v1.h>
#include <Modbus.h>
#include <ModbusSerial.h>
#include <Wire.h>
#include <Adafruit_ADS1015.h>
#pragma region constantes
// Definiciones de constantes
#define tiempo_rx 200						 //tiempo de RX
#define tiempo_tx 200						 //Tiempo de TX
#define TENSION_MAX 5.0						 //Tensión máxima de salida del pwm
#define ZONA_MUERTA 2						 //ZONA MUERTA DEL MOTOR
#define SALIDA_MAX TENSION_MAX - ZONA_MUERTA //Salida máxima del PID (luego se le resta la Zona Muerta del Motor si hace falta)
#define TOLERANCIA 1						 //Tolerancia en grados
#define REF_MAX 90.0						 //posicion maxima en grados
#define REF_MIN -90.0						 //posicion minima en grados
#define SENSOR_MAX 853.0					 //1.78 medio -- 3.72 0.18 -- medidas de manera practica
#define SENSOR_MIN 170.0					 //Tambien medido de manera practica
#define SENSOR_MEDIO ((SENSOR_MAX - SENSOR_MIN) / 2.0 + SENSOR_MIN)
#define POT2GRAD ((REF_MAX - REF_MIN) / (SENSOR_MAX - SENSOR_MIN)) //escalado de potenciómetro a grados
#define Ts 1													   //Periodo de muestreo de 1 ms
#define RS485activo 1											   //Define modbus por serie
#pragma endregion

#pragma region variables
//Definiciones para el PID
double setpoint = 0.0, entrada = 0.0, salida = 0.0;
//Parametros PID
float Kp = .7, Ki = 0.15, Kd = 0.005;
//Variables leídas y error entre ellas
float ref = 0.0, sensor = 0.0, error = 0.0;
int pot = 0;
byte pwm_motor;
bool bandera_control = 0;  //activa tarea lazo de control
float sensibilidad = 0.66; //sensibilidad del sensor hall

//Modbus Registers Offsets (0-9999)
const int SENSOR_IREG = 100;
const int SENSOR_HREG = 200;
const int SENSOR_ADC = 102;
const int SENSOR_REF = 101;
const int COIL_REF = 110;

byte contador_tx = 0; //Para temporizacion
byte contador_rx = 0; //Para temp
bool bandera_tx = 0;  // activa tarea transmisión de datos
bool bandera_rx = 0;  // activa tarea recepción de datos
float dataNumber = 0.0;
int adc0;		 //lectura del adc
float corriente; //Conversion a corriente
float referencia;
int switchref = 0;
const int TxPin485 = 2;

#pragma endregion

#pragma region inicio_objetos
//Declaracion del objeto del motor
AF_DCMotor motor(1, MOTOR12_8KHZ); //define la frecuencia de la señal PWM
//Declaracion del objeto del PID
PID myPID(&entrada, &salida, &setpoint, Kp, Ki, Kd, P_ON_E, DIRECT);
// ModbusSerial object
ModbusSerial mb;
Adafruit_ADS1115 ads;
#pragma endregion

void setup()
{
	if (RS485activo == 1)
	{ //RS485 por COM virtual en PC
		mb.config(&Serial, 115200, SERIAL_8N1, TxPin485);
	}
	else
	{ //RS232 por COM virtual en PC
		mb.config(&Serial, 115200, SERIAL_8N1);
	}
	//configuraciones del modbus
	mb.setSlaveId(10);
	mb.addIreg(SENSOR_IREG);
	mb.addHreg(SENSOR_HREG);
	mb.addIreg(SENSOR_ADC);
	mb.addIreg(SENSOR_REF);
	mb.addCoil(COIL_REF);
	//configuraciones de motor y PID
	motor.setSpeed(0);	//Define vel en 0
	motor.run(RELEASE); //Detiene el motor
	myPID.SetSampleTime(Ts);														//Seteo período de muestreo del PID a 1 ms
	myPID.SetOutputLimits(-(SALIDA_MAX - ZONA_MUERTA), (SALIDA_MAX - ZONA_MUERTA)); //Seteo los límites de salida del PID (teniendo en cuenta la zona muerta del Motor)
	myPID.SetMode(AUTOMATIC);
	ads.setGain(GAIN_ONE);			  // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
	ads.begin();					  //Inicial el objeto del adc
	Timer1.initialize(1000);		  // configura un timer de 1 ms
	Timer1.attachInterrupt(timerIsr); // asocia una la interrupción de un timer a una rutina de servicio de interrupción
}

void loop()
{
	referencia = (float)((float)analogRead(A0) - SENSOR_MEDIO) * POT2GRAD;
	adc0 = ads.readADC_Differential_0_1(); //Lee la entrada diferencial del adc
	corriente = (float)adc0 / (sensibilidad * 8);
	//El adc en GAIN_ONE tiene una resolucion de 0.125mV
	//Por lo tanto al leer la salida dividida en 8 da la lectura en milivolts
	//Ese valor se divide tambien en la sensibilidad del sensor hall
	//dando la lectura en miliamperes
	mb.task();
	if (bandera_control == 1) // Lazo de control
	{
#pragma region sensado
		if (switchref == 1)
		{
			dataNumber = referencia;
		}
		ref = dataNumber; //lee referencia de HyperIMU ([-90,90] en este caso, actualizada en "dataNumber" cada 50ms)
						  // ref= ((float)analogRead(A2)- SENSOR_MEDIO)*POT2GRAD; //Para usar otro pote de ref
		if (ref > REF_MAX)
		{ //opcional, generalmente se utilizan fines de carrera
			ref = REF_MAX;
		}
		if (ref < REF_MIN)
		{
			ref = REF_MIN;
		}

		pot = analogRead(A1);
		// pot = filtroFIR();
		sensor = ((float)pot - SENSOR_MEDIO) * POT2GRAD; //valor actual en grados
		//se pueden agregar filtros digitales a "ref" y "sensor"
		error = ref - sensor; //Calculo de error
#pragma endregion

#pragma region control
		if (abs(error) < TOLERANCIA) //para parar el motor cuando el error es menor a la tolerancia
		{
			motor.run(RELEASE);
		}
		else
		{
			//Controlador PID
			setpoint = ref;	  //actualizo el setpoint al controlador PID
			entrada = sensor; //actualizo la realimentación al controlador PID
			myPID.Compute();  //calculo la acción del controlador PID (escribe la variable "salida")
			if (salida >= 0)
			{
				motor.run(FORWARD);
			}
			else
			{
				motor.run(BACKWARD);
			}
		}
		pwm_motor = (byte)((abs(salida) + ZONA_MUERTA) * (255.0 / SALIDA_MAX)); //mapeo de tension [volt] a PWM de 8 bits
		motor.setSpeed(pwm_motor);												//establece el duty (porcentaje de tiempo en "1") de la señal PWM
		bandera_control = 0;
#pragma endregion
	}

#pragma region comunicacion_serial
	//Chequeo para transmision y recepcion
	if (bandera_tx == 1)
	{
		mb.Ireg(SENSOR_IREG, sensor);	 //referencia acoplada al motor
		mb.Ireg(SENSOR_ADC, corriente);	 //corriente consumida
		mb.Ireg(SENSOR_REF, referencia); //referencia 2, segundo potenciometro
		bandera_tx = 0;
	}
	if (bandera_rx == 1)
	{
		switchref = (int)mb.Coil(COIL_REF);
		dataNumber = (float)(int)(mb.Hreg(SENSOR_HREG));
		bandera_rx = 0;
	}
#pragma endregion
}

void timerIsr()
{
	bandera_control = 1; //activa tarea lazo de control cada 1 ms
	contador_tx++;
	contador_rx++;
	if (contador_tx >= tiempo_tx) //activa tarea transmisión de datos cada 10 ms
	{
		bandera_tx = 1;
		contador_tx = 0;
	}
	if (contador_rx >= tiempo_rx) //activa tarea recepción de datos cada 50 ms
	{
		bandera_rx = 1;
		contador_rx = 0;
	}
}