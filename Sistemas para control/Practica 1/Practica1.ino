#include <AFMotor.h> //solamente si utiliza el shield arduino motor v1. Si se usa algún chip puente H (por ejemplo L293D) se recomienda utilizar la librería TimerThree.zip
#include <TimerOne.h>
#include <PID_v1.h>
#include <Modbus.h>
#include <ModbusSerial.h>

#pragma region constantes
// Definiciones de constantes
#define tiempo_rx 30						 //tiempo de RX
#define tiempo_tx 10						 //Tiempo de TX
#define TENSION_MAX 5.0						 //Tensión máxima de salida del pwm
#define ZONA_MUERTA 1.0						 //ZONA MUERTA DEL MOTOR
#define SALIDA_MAX TENSION_MAX - ZONA_MUERTA //Salida máxima del PID (luego se le resta la Zona Muerta del Motor si hace falta)
#define TOLERANCIA 1						 //Tolerancia en grados
#define REF_MAX 90.0						 //posicion maxima en grados
#define REF_MIN -90.0						 //posicion minima en grados
#define SENSOR_MAX 853.0					 //1.78 medio -- 3.72 0.18 -- medidas de manera practica
#define SENSOR_MIN 170.0					 //Tambien medido de manera practica
#define SENSOR_MEDIO ((SENSOR_MAX - SENSOR_MIN) / 2.0 + SENSOR_MIN)
#define POT2GRAD ((REF_MAX - REF_MIN) / (SENSOR_MAX - SENSOR_MIN)) //escalado de potenciómetro a grados
#define Ts 1													   //Periodo de muestreo de 1 ms
#pragma endregion

#pragma region variables
//Definiciones para el PID
double setpoint = 0.0, entrada = 0.0, salida = 0.0;
//Parametros PID
float Kp = 0.7, Ki = 0.1, Kd = 0.005;
//Variables leídas y error entre ellas
float ref = 0.0, sensor = 0.0, error = 0.0;
int pot = 0;

byte pwm_motor;
bool bandera_control = 0; //activa tarea lazo de control

//Variables para la transmision y recepcion
byte contador_tx = 0; //Para temporizacion
byte contador_rx = 0; //Para temp
bool bandera_tx = 0;  // activa tarea transmisión de datos
bool bandera_rx = 0;  // activa tarea recepción de datos
char buffer_tx[20];
char buffer_rx[20];
const byte numChars = 20; //
char receivedChars[20];	  // Arreglo donde se guardan los bytes recibidos
float dataNumber = 0.0;
int N = 3;
//numerador y denominador del filtro IIR pasabajo de 40Hz:
//const float num[N] = {0.5, 0.2, 0.15, 0.1, 0.05};
// const float num[N] = {0.0001832160, 0.0007328641, 0.0010992961, 0.0007328641, 0.0001832160};
// const float den[N] = {0.5174781998, -2.4093428566, 4.2388639509, -3.3440678377, 1.0000000000};

#pragma endregion

#pragma region inicio_objetos
//Declaracion del objeto del motor
AF_DCMotor motor(4, MOTOR34_8KHZ); //define la frecuencia de la señal PWM
//Declaracion del objeto del PID
PID myPID(&entrada, &salida, &setpoint, Kp, Ki, Kd, P_ON_E, DIRECT);
#pragma endregion

float filtroFIR()
{
	int N = 3; //cantidad de puntos	
	int k;
	static float ent[3] = {analogRead(A1)}; //inicializa arreglo en el primer valor del pote
	float out = 0;
	for (k = 1; k < N; k++)
	{
		ent[k - 1] = ent[k]; //desplaza los valores
	}
	ent[N-1] = analogRead(A1); //lee la nueva entrada
	for (k = 0; k < N; k++)
	{
		out = out + ent[k]; //Sumatoria de las ultimas entradas
	}
	return (float)out / N; //devuelve el promedio de las ultimas N muestras
}

void setup()
{
	motor.setSpeed(0);	//Define vel en 0
	motor.run(RELEASE); //Detiene el motor

	Serial.begin(115200); //Inicializa comunicación serie a 115200 bits por segundo

	myPID.SetSampleTime(Ts);														//Seteo período de muestreo del PID a 1 ms
	myPID.SetOutputLimits(-(SALIDA_MAX), (SALIDA_MAX)); //Seteo los límites de salida del PID (teniendo en cuenta la zona muerta del Motor)
	myPID.SetMode(AUTOMATIC);														//Inicia el PID en modo auto?

	Timer1.initialize(1000);		  // configura un timer de 1 ms
	Timer1.attachInterrupt(timerIsr); // asocia una la interrupción de un timer a una rutina de servicio de interrupción
	Serial.println("Referenca,Sensor,AccionControl,Error");
}

void loop()
{
	int i;
	static float reff[3] = {0};
	if (bandera_control == 1) // Lazo de control
	{
#pragma region sensado
		for (i = 1; i < N; i++)
		{
			reff[i - 1] = reff[i]; //desplaza los valores
		}
		reff[0]=dataNumber;
		ref = reff[N-1]; //lee referencia de HyperIMU ([-90,90] en este caso, actualizada en "dataNumber" cada 50ms)
						  // ref= ((float)analogRead(A2)- SENSOR_MEDIO)*POT2GRAD; //Para usar otro pote de ref
		
		if (ref > REF_MAX)
		{ //opcional, generalmente se utilizan fines de carrera
			ref = REF_MAX;
		}
		if (ref < REF_MIN)
		{
			ref = REF_MIN;
		}
		// pot = analogRead(A1);
		pot = filtroFIR();
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
		// sprintf(buffer_tx, "%d,%d", (int)(ref * 100.0), (int)(sensor * 100.0));
		sprintf(buffer_tx, "%d,%d,%d,%d", (int)(ref * 100.0), (int)(sensor * 100.0), (int)(salida * 1000), (int)(error * 100));
		Serial.println(buffer_tx);
		bandera_tx = 0;
	}
	if (bandera_rx == 1)
	{
		recvWithEndMarker();
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

void recvWithEndMarker()
{
	static byte ndx = 0;
	char endMarker = '\n';
	char rc;
	while (Serial.available() > 0)
	{
		rc = Serial.read();
		if (rc != endMarker)
		{
			receivedChars[ndx] = rc;
			ndx++;
			if (ndx >= numChars)
				ndx = numChars - 1;
		}
		else
		{
			receivedChars[ndx] = '\0'; // terminate the string
			ndx = 0;
			dataNumber = atof(receivedChars); // new for this version
		}
	}
}
