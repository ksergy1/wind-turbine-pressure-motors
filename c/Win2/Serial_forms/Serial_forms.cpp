// Serial_forms.cpp : Defines the entry point for the application.
//
#include <windows.h>
#include "stdafx.h"
#include "Serial_forms.h"

#define MAX_LOADSTRING 100

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY _tWinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPTSTR    lpCmdLine,
                     int       nCmdShow)
{
	connected = 0x00;
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

 	// TODO: Place code here.
	MSG msg;
	HACCEL hAccelTable;

	// Initialize global strings
	LoadString(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadString(hInstance, IDC_SERIAL_FORMS, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_SERIAL_FORMS));

	// Main message loop:
	while (GetMessage(&msg, NULL, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return (int) msg.wParam;
}



//
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
//  COMMENTS:
//
//    This function and its usage are only necessary if you want this code
//    to be compatible with Win32 systems prior to the 'RegisterClassEx'
//    function that was added to Windows 95. It is important to call this function
//    so that the application will get 'well formed' small icons associated
//    with it.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEX wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style			= CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc	= WndProc;
	wcex.cbClsExtra		= 0;
	wcex.cbWndExtra		= 0;
	wcex.hInstance		= hInstance;
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_SERIAL_FORMS));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_SERIAL_FORMS);
	wcex.lpszClassName	= szWindowClass;
	wcex.hIconSm		= LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassEx(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   HWND hWnd;

   hInst = hInstance; // Store instance handle in our global variable

   hWnd = CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE:  Processes messages for the main window.
//
//  WM_COMMAND	- process the application menu
//  WM_PAINT	- Paint the main window
//  WM_DESTROY	- post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	int wmId, wmEvent;
	PAINTSTRUCT ps;
	HDC hdc;
	switch (message)
	{
	case WM_COMMAND:
		wmId    = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		// Parse the menu selections:
		switch (wmId)
		{
		case IDM_ABOUT:
			DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
			break;
		case IDM_EXIT:
			if (connected) {
				CloseHandle(hSerial);
				connected = 0x00;
			};
			DestroyWindow(hWnd);
			break;
		case IDC_CONNECT_BUTTON:
			if (connected) {
				MessageBox(NULL, L"Уже и так подсоединен.", L"Error", MB_ICONERROR);
				break;
			};
			SendMessage(hWndEdit_PortName, WM_GETTEXT, 256, reinterpret_cast<LPARAM>(wFlName));
//			MessageBox(NULL, wFlName, L"Information", MB_ICONINFORMATION);
			hSerial = CreateFile (wFlName, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
			if (hSerial == INVALID_HANDLE_VALUE) {
				FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
					NULL,
					GetLastError(),
					MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
					lastError,
					1024,
					NULL);
				MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
				break;
			};
			// Конфигурирования
			dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
			if (!GetCommState(hSerial, &dcbSerialParams)) {
				FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
					NULL,
					GetLastError(),
					MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
					lastError,
					1024,
					NULL);
				MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
				CloseHandle(hSerial);
				break;
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
				FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
					NULL,
					GetLastError(),
					MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
					lastError,
					1024,
					NULL);
				MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
				CloseHandle(hSerial);
				break;
			};

			// время ожидания
			timeouts.ReadIntervalTimeout=500;
			timeouts.ReadTotalTimeoutConstant=500;
			timeouts.ReadTotalTimeoutMultiplier=10;

			timeouts.WriteTotalTimeoutConstant=500;
			timeouts.WriteTotalTimeoutMultiplier=10;

			if(!SetCommTimeouts(hSerial, &timeouts)){
				FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
					NULL,
					GetLastError(),
					MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
					lastError,
					1024,
					NULL);
				MessageBox(NULL, lastError, L"Error", MB_ICONERROR);
				CloseHandle(hSerial);
				break;
			};
			connected = 0x01;
			MessageBox(NULL, L"Подсоединились.", L"Information", MB_ICONINFORMATION);
			break;
		case IDC_SEND_BUTTON:
#ifndef TESTER_UART_ATMEGA
			SendMessage(hWndEdit_Ndrv, WM_GETTEXT, 256, reinterpret_cast<LPARAM>(buftext));
			DriveN = _wtoi(buftext);
			//if (DriveN == 8) break;
			DriveN &= NDRIVES_MASK;

			SendMessage(hWndEdit_Nstep, WM_GETTEXT, 256, reinterpret_cast<LPARAM>(buftext));
			Nsteps = _wtoi(buftext);
			//if (Nsteps == 128) break;
			Nsteps &= NSTEPS_MASK;

			SendMessage(hWndEdit_Dir, WM_GETTEXT, 256, reinterpret_cast<LPARAM>(buftext));
			Direction = _wtoi(buftext);
			Direction &= DIR_MASK;
			Direction <<= DIR_POSITION;

			Nsteps = Nsteps | Direction;
			//wsprintf(buftext, L"Command to be sent? - %#x\nDirection - %#x", Nsteps, Direction);
			//MessageBox(NULL, buftext, L"Information", MB_ICONINFORMATION);

			drvN = DriveN & ONE_BYTE;
			wsprintf(buftext, L"Drive number to be sent - %#x", drvN);
//			MessageBox(NULL, buftext, L"Information", MB_ICONINFORMATION);
			printf(" Drive number is ready to be sent - %x\n", drvN);
			Send(hSerial, &drvN);

			Recv(hSerial, &rslt);
			//if (rslt != uart_ack) {
			//    printf(" Wrong acknowledge got - %x\n", rslt);
			//    break;
			//};

			Nst = Nsteps & ONE_BYTE;
			wsprintf(buftext, L"Command to be sent - %#x", Nst);
//			MessageBox(NULL, buftext, L"Information", MB_ICONINFORMATION);
			printf(" Command is ready to be sent - %x\n", Nst);
			Send(hSerial, &Nst);

			Recv(hSerial, &rslt);
			//if (rslt != uart_ack) {
			//    printf(" Wrong acknowledge - %x\n", rslt);
			//    break;
			//};
#else
			SendMessage(hWndEdit_Ndrv, WM_GETTEXT, 256, reinterpret_cast<LPARAM>(buftext));
			DriveN = _wtoi(buftext);
			if (DriveN == 8) break;
			DriveN &= NDRIVES_MASK;

			drvN = DriveN & ONE_BYTE;
			printf(" Byte is ready to be sent - %x\n", drvN);
			Send(hSerial, &drvN);

			Recv(hSerial, &rslt);
			printf(" Result got - %x\n", rslt);
			wsprintf(buftext, L"Data recieved - %#x", rslt);
			MessageBox(NULL, buftext, L"Information", MB_ICONINFORMATION);
#endif
			break;
		case IDC_DISCONNECT_BUTTON:
			if (connected) {
				CloseHandle(hSerial);
				connected = 0x00;
			};
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;
	case WM_CREATE:
		{
			hWndButton_Connect = CreateWindowEx (NULL,
				L"BUTTON", 
				L"Соединиться с СOM",
				WS_TABSTOP|WS_VISIBLE|WS_CHILD|BS_DEFPUSHBUTTON,
				250,
				5,
				150,
				24,
				hWnd,
				(HMENU)IDC_CONNECT_BUTTON,
				GetModuleHandle(NULL),
				NULL);
			hWndButton_Send = CreateWindowEx (NULL,
				L"BUTTON", 
				L"Отправить",
				WS_TABSTOP|WS_VISIBLE|WS_CHILD|BS_DEFPUSHBUTTON,
				50,
				170,
				150,
				24,
				hWnd,
				(HMENU)IDC_SEND_BUTTON,
				GetModuleHandle(NULL),
				NULL);
			hWndButton_Disconnect = CreateWindowEx (NULL,
				L"BUTTON", 
				L"Отсоединиться",
				WS_TABSTOP|WS_VISIBLE|WS_CHILD|BS_DEFPUSHBUTTON,
				400,
				5,
				150,
				24,
				hWnd,
				(HMENU)IDC_DISCONNECT_BUTTON,
				GetModuleHandle(NULL),
				NULL);
			hWndEdit_PortName = CreateWindowEx (NULL,
				L"EDIT",
				L"COM1",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				150,
				5,
				75,
				40,
				hWnd,
				(HMENU)IDC_PORTNAME_EDIT,
				GetModuleHandle(NULL),
				NULL);
			hWndEdit_Ndrv = CreateWindowEx (NULL,
				L"EDIT",
				L"0",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				150,
				45,
				75,
				40,
				hWnd,
				(HMENU)IDC_NDRV_EDIT,
				GetModuleHandle(NULL),
				NULL);
			hWndEdit_Nstep = CreateWindowEx (NULL,
				L"EDIT",
				L"0",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				150,
				85,
				75,
				40,
				hWnd,
				(HMENU)IDC_NSTEP_EDIT,
				GetModuleHandle(NULL),
				NULL);
			hWndEdit_Dir= CreateWindowEx (NULL,
				L"EDIT",
				L"0",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				150,
				125,
				75,
				40,
				hWnd,
				(HMENU)IDC_DIR_EDIT,
				GetModuleHandle(NULL),
				NULL);
			hWndLabel_PortName = CreateWindowEx (NULL,
				L"STATIC",
				L"COM-порт",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				5,
				5,
				125,
				40,
				hWnd,
				(HMENU)IDC_PORTNAME_LABEL,
				GetModuleHandle(NULL),
				NULL);
			hWndLabel_Ndrv = CreateWindowEx (NULL,
				L"STATIC",
				L"Номер двигателя [0-7]",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				5,
				45,
				125,
				40,
				hWnd,
				(HMENU)IDC_NDRV_LABEL,
				GetModuleHandle(NULL),
				NULL);
			hWndLabel_Nstep = CreateWindowEx (NULL,
				L"STATIC",
				L"Число полушагов [1-128]",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				5,
				85,
				125,
				40,
				hWnd,
				(HMENU)IDC_NSTEP_LABEL,
				GetModuleHandle(NULL),
				NULL);
			hWndLabel_Dir = CreateWindowEx (NULL,
				L"STATIC",
				L"Направление [0 - туда, 1 - обратно]",
				WS_CHILD|WS_VISIBLE|WS_BORDER,
				5,
				125,
				125,
				40,
				hWnd,
				(HMENU)IDC_DIR_LABEL,
				GetModuleHandle(NULL),
				NULL);
		};
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

// Message handler for about box.
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);
	switch (message)
	{
	case WM_INITDIALOG:
		return (INT_PTR)TRUE;

	case WM_COMMAND:
		if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
		{
			EndDialog(hDlg, LOWORD(wParam));
			return (INT_PTR)TRUE;
		}
		break;
	}
	return (INT_PTR)FALSE;
}
