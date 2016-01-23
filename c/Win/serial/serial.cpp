//#include <stdafx.h>
#include <Windows.h>
#include <stdio.h>
#include <windows.h>        // ??

#define RDWR_BUFSZ 1
#define NDRIVES_MASK 0x07
#define DIR_MASK 0x01
#define DIR_POSITION 0x07
#define NSTEPS_MASK 0x7f
#define ONE_BYTE 0xff
#define uart_ack 0xc5

#define TESTER_UART_ATMEGA
#undef TESTER_UART_ATMEGA

void Recv (HANDLE, unsigned char *);
void Send (HANDLE, unsigned char *);


int main(int argc, char* argv[])
{
    char file_name[256];
    wchar_t wFlName[256];
    LPCWSTR flName;
    HANDLE hSerial;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0xFFFFFFFF,0,0,0,1500};
    unsigned int DriveN;
    unsigned int Nsteps;
    unsigned int Direction;
    unsigned int GotSmth;
    wchar_t lastError[1024];
    unsigned char drvN, Nst, rslt;
    const WCHAR FileFullPath[] = {L"COM1"};

    printf("Type in COM-port name. ");
    wscanf(L"%s", wFlName);
    //swprintf(wFlName, L"%s", file_name);
    printf("port - %s\n", wFlName);    

    /** Начало. открытие порта. настройка **/
    hSerial = CreateFile (FileFullPath, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hSerial == INVALID_HANDLE_VALUE) {
        printf(" Can't open port.\n");
        system("pause");
        ExitProcess(1);
    };

    // Конфигурирования
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hSerial, &dcbSerialParams)) {
        printf(" Can't get port parameters\n");
        CloseHandle(hSerial);
        ExitProcess(1);
    };

    dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.fBinary = true;
    dcbSerialParams.fParity = NOPARITY;                     // False
    dcbSerialParams.fOutxCtsFlow = false;                   // no flow control by hardware (CTS)
    dcbSerialParams.fDtrControl = DTR_CONTROL_DISABLE;      // no handshaking
    dcbSerialParams.fDsrSensitivity = false;                // no look at DSR
    dcbSerialParams.fOutX = false;                          // no software flow control (Xon/Xoff) on Tx
    dcbSerialParams.fInX = false;                           // no software flow control (Xon/Xoff) on Rx
    dcbSerialParams.fErrorChar = false;                     // don't change error chars (checked by parity if it is True)
    dcbSerialParams.fNull = false;                          // we'll take even NULL characters
    dcbSerialParams.fRtsControl = RTS_CONTROL_DISABLE;      // no flow control by hardware (RTS)

    // 8 битов данных, без бита четности, 1 стоповых бита, 8N1 @ 9600 bps
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.Parity = 0;
    dcbSerialParams.StopBits = ONESTOPBIT;
    // BuildCommDCB("9600,n,8,2", &dcbSerialParams)
    if(!SetCommState(hSerial, &dcbSerialParams)){
        printf(" Can't set port parameters.\n");
        CloseHandle(hSerial);
        system("pause");
        ExitProcess(1);
    };

        // время ожидания
    timeouts.ReadIntervalTimeout=500;
    timeouts.ReadTotalTimeoutConstant=500;
    timeouts.ReadTotalTimeoutMultiplier=10;

    timeouts.WriteTotalTimeoutConstant=500;
    timeouts.WriteTotalTimeoutMultiplier=10;

    if(!SetCommTimeouts(hSerial, &timeouts)){
        printf(" Can't set port timeout.\n");
        CloseHandle(hSerial);
        ExitProcess(1);
    };

#ifndef TESTER_UART_ATMEGA
    do {
        printf("Type in drive No (0..7, 8 - exit) - ");
        scanf("%u", &DriveN);
        if (DriveN == 8) break;
        DriveN &= NDRIVES_MASK;

        printf("Number of halfsteps (0..127, 128 - exit) - ");
        scanf("%u", &Nsteps);
        if (Nsteps == 128) break;
        Nsteps &= NSTEPS_MASK;

        printf("Direction (1 - to there, 0 - from there) - ");
        scanf("%u", &Direction);
        Direction &= DIR_MASK;
        Direction <<= DIR_POSITION;

        Nsteps = Nsteps | Direction;

        drvN = DriveN & ONE_BYTE;
        printf(" Drive number is ready to be sent - %x\n", drvN);
        Send(hSerial, &drvN);

        Recv(hSerial, &rslt);
        //if (rslt != uart_ack) {
        //    printf(" Wrong acknowledge got - %x\n", rslt);
        //    break;
        //};

        Nst = Nsteps & ONE_BYTE;
        printf(" Command is ready to be sent - %x\n", Nst);
        Send(hSerial, &Nst);

        Recv(hSerial, &rslt);
        //if (rslt != uart_ack) {
        //    printf(" Wrong acknowledge - %x\n", rslt);
        //    break;
        //};
    } while (true);
#else
    do {
        printf("Type in byte to send (hex, 100 - exit) - ");
        scanf("%x", &DriveN);
		if (DriveN == 0x100) break;

        drvN = DriveN & ONE_BYTE;
        printf(" Byte is ready to be sent - %x\n", drvN);
        Send(hSerial, &drvN);

        Recv(hSerial, &rslt);
        printf(" Result got - %x\n", rslt);
    } while (true);
#endif

    /** Конец. **/
    CloseHandle(hSerial);

    system("pause");
    return 0;
}

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
        printf("Fail on recieve.\n");
        CloseHandle(hSerial);
        system("pause");
        ExitProcess(1);
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
        printf("Fail on send.\n");
        CloseHandle(hSerial);
        system("pause");
        ExitProcess(1);
    }
}
