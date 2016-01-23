#pragma once
#include <stdio.h>
#include "resource.h"

/* GUI part */

HWND hWndButton_Connect, hWndButton_Send, hWndButton_Disconnect;
HWND hWndEdit_PortName, hWndEdit_Ndrv, hWndEdit_Nstep, hWndEdit_Dir;
HWND hWndLabel_PortName, hWndLabel_Ndrv, hWndLabel_Nstep, hWndLabel_Dir;

/* communication part */

#define RDWR_BUFSZ 1
#define NDRIVES_MASK 0x07
#define DIR_MASK 0x01
#define DIR_POSITION 0x07
#define NSTEPS_MASK 0x7f
#define ONE_BYTE 0xff
#define uart_ack 0xc5

#define TESTER_UART_ATMEGA
#undef TESTER_UART_ATMEGA

char connected;
wchar_t wFlName[256];
wchar_t buftext[256];
HANDLE hSerial;
DCB dcbSerialParams = {0};
COMMTIMEOUTS timeouts = {0xFFFFFFFF,0,0,0,1500};
unsigned int DriveN;
unsigned int Nsteps;
unsigned int Direction;
unsigned int GotSmth;
wchar_t lastError[1024];
unsigned char drvN, Nst, rslt;

/* PROCEDURES */
void Recv (HANDLE hSerial, unsigned char *szBuff)
{
	DWORD dwBytesRW = 0;
	int RdWrResult;
	DWORD i;
	wchar_t lastError[1024];
	// чтение
	RdWrResult = ReadFile(hSerial, szBuff, RDWR_BUFSZ, &dwBytesRW, NULL);
	printf(" Number of bytes read - %u\n", dwBytesRW);
	printf(" Data read - ");
	for (i = 0; i < dwBytesRW; i ++) {
		printf("%x ", szBuff[i]);
	};
	printf("\n");

	if(!RdWrResult){
		FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			lastError,
			1024,
			NULL);
		MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
	}
}

void Send (HANDLE hSerial, unsigned char *szBuff)
{
	DWORD dwBytesRW = 0;
	int RdWrResult;
	DWORD i;
	wchar_t lastError[1024];
	// запись
	RdWrResult = WriteFile(hSerial, szBuff, RDWR_BUFSZ, &dwBytesRW, NULL);
	printf(" Number of bytes writen - %u\n", dwBytesRW);
	printf(" Data writen - ");
	for (i = 0; i < dwBytesRW; i ++) {
		printf("%x ", szBuff[i]);
	};
	printf("\n");

	if(!RdWrResult || dwBytesRW != RDWR_BUFSZ) {
		FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			lastError,
			1024,
			NULL);
		MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
	}
}
