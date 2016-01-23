#include "stdafx.h"
#include <Windows.h>
#include <windows.h>		// ??

#define RDWR_BUFSZ 1
#define NDRIVES_MASK 0x07
#define DIR_MASK 0x01
#define DIR_POSITION 0x03
#define NSTEPS_MASK 0x7f
#define ONE_BYTE 0xff
#define uart_ack 0xc5

int _tmain(int argc, _TCHAR* argv[])
{
	char file_name[256];
	HANDLE hSerial;
	DCB dcbSerialParams = {0};
	COMMTIMEOUTS timeouts = {0xFFFFFFFF,0,0,0,1500};
	unsigned int DriveN;
	unsigned int Nsteps;
	unsigned int Direction;
	unsigned int GotSmth;

	unsigned char drvN, Nst, rslt;

	printf("Введи название COM-порта. ");
	scanf("%s", file_name);

	/** Начало. открытие порта. настройка **/
	hSerial = CreateFile (file_name, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hSerial == INVALID_HANDLE_VALUE) {
	    FormatMessage(
		           FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		           NULL,
		           GetLastError(),
		           MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		           lastError,
		           1024,
		           NULL);
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    ExitProcess(1);
	};

	// Конфигурирования
	dcbSerialParams.DCBLength = sizeof(dcbSerialParams);
	if (!GetCommState(hSerial, &dcbSerialParams)) {
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    CloseHandle(hSerial);
	    ExitProcess(1);
	};

	dcbSerialParams.BaudRate = CBR_9600;
	dcbSerialParams.fBinary = True;
	dcbSerialParams.fParity = NOPARITY;                     // False
	dcbSerialParams.fOutxCtsFlow = False;                   // no flow control by hardware (CTS)
	dcbSerialParams.fDtrControl = DTR_CONTROL_DISABLE;      // no handshaking
	dcbSerialParams.fDsrSensitivity = False;                // no look at DSR
	dcbSerialParams.fOutX = False;                          // no software flow control (Xon/Xoff) on Tx
	dcbSerialParams.fInX = False;                           // no software flow control (Xon/Xoff) on Rx
	dcbSerialParams.fErrorChar = False;                     // don't change error chars (checked by parity if it is True)
	dcbSerialParams.fNull = False;                          // we'll take even NULL characters
	dcbSerialParams.fRtsControl = RTS_CONTROL_DISABLE;      // no flow control by hardware (RTS)

	// 8 битов данных, без бита четности, два стоповых бита
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.Parity = NOPARITY;
	dcbSerialParams.StopBits = TWOSTOPBITS;

	if(!SetCommState(hSerial, &dcbSerialParams)){
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    CloseHandle(hSerial);
	    ExitProcess(1);
	};

	    // время ожидания
	/*
	timeouts.ReadIntervalTimeout=50;
	timeouts.ReadTotalTimeoutConstant=50;
	timeouts.ReadTotalTimeoutMultiplier=10;

	timeouts.WriteTotalTimeoutConstant=50;
	timeouts.WriteTotalTimeoutMultiplier=10;
	*/
	if(!SetCommTimeouts(hSerial, &timeouts)){
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    CloseHandle(hSerial);
	    ExitProcess(1);
	};

	do {
		printf("Введи номер двигателя (0..7, 8 - выход) - ");
		scanf("%u", &DriveN);
		if (DriveN == 8) break;
		DriveN &= NDRIVES_MASK;

		printf("Число полушагов (0..127) - ");
		scanf("%u", &Nsteps);
		Nsteps &= NSTEPS_MASK;

		printf("Направление (1 - туда, 0 - обратно) - ");
		scanf("%u", &Direction);
		Direction &= DIR_MASK;
		Direction <<= DIR_POSITION;

		Nsteps = Nsteps | Direction;

		drvN = DriveN & ONE_BYTE;
		printf(" Готов к отправке номер двигателя - %x\n", drvN);
		Send(hSerial, &drvN);

		Recv(hSerial, &rslt);
		if (rslt != uart_ack) {
			printf(" Получено неверное подтверждение при отправке номера двигателя - %x\n", rslt);
			break;
		};

		Nst = Nsteps & ONE_BYTE;
		printf(" Готова к отправке команда - %x\n", Nst);
		Send(hSerial, &Nst);

		Recv(hSerial, &rslt);
		if (rslt != uart_ack) {
			printf(" Получено неверное подтверждение при отправке команды - %x\n", rslt);
			break;
		};
	} while (True);

	/** Конец. **/
	CloseHandle(hSerial);

		return 0;
}

void Recv (HANDLE hSerial, char *szBuff)
{
	DWORD dwBytesRW = 0;
	int RdWrResult;
	DWORD i;
	char lastError[1024];
	    // чтение
	RdWrResult = ReadFile(hSerial, szBuff, RDWR_BUFSZ, &dwBytesRW, NULL);
	printf(" Number of bytes read - %u\n", dwBytesRW);
	printf(" Data read - ");
	    for (i = 0; i < dwBytesRW; i ++) {
		   printf("%x ", szBuff[i]);
	    };
	printf("\n");

	if(!RdWrResult){
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    CloseHandle(hSerial);
	    ExitProcess(1);
	}
}

void Send (HANDLE hSerial, char *szBuff)
{
	DWORD dwBytesRW = 0;
	int RdWrResult;
	DWORD i;
	char lastError[1024];
	    // запись
	RdWrResult = WriteFile(hSerial, szBuff, RDWR_BUFSZ, &dwBytesRW, NULL);
	printf(" Number of bytes writen - %u\n", dwBytesRW);
	printf(" Data writen - ");
	    for (i = 0; i < dwBytesRW; i ++) {
		   printf("%x ", szBuff[i]);
	    };
	printf("\n");

	if(!RdWrresult || dwBytesRW != RDWR_BUFSZ) {
	    MessageBox(NULL, lastError, "Error", "MB_OK");
	    CloseHandle(hSerial);
	    ExitProcess(1);
	}
}
