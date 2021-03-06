.include "m8def.inc"
; fosc = 8MHz
; Fuse-bits : MSB ... LSB (76543210)
;   High byte: 11011111
;   Low byte : 11100100

.equ FIRST_STEP_SPI = $84
.equ SECOND_STEP_SPI = $03

.def temp = r22
.def temp2 = r18
.def dataTemp = r21
.def driveN = r19
.def stepsN = r20
; формируем задержку
.def Razr0 = r25
.def Razr1 = r23
.def Razr2 = r24
; 25 мс
.equ Waiting0 = 0b01000000
.equ Waiting1 = 0b10011100
.equ Waiting2 = 0b00000001

; ----------------------------------
; подтверждение при передаче по uart - C5
.equ UART_ACK = 0b11000101

.def tempBaudRateH = r17
.def tempBaudRateL = r16
.equ DDR_SPI = DDRB
.equ DD_SCK = DDB5
.equ DD_MISO = DDB4
.equ DD_MOSI = DDB3
.equ DD_SS = DDB2
.equ PORT_SPI = PORTB

; uart baudrate coeff
.equ uart_baudrate_h = 0b00000000
.equ uart_baudrate_l = 0b00110011

; zero address
rjmp MAIN;

; ------------ MAIN --------------
MAIN:
  ; configurations block
	; сразу же отключаем прерывания
	cli
  ; stack init
	ldi temp, low(RAMEND);
	ldi temp2, high(RAMEND);
	out SPH, temp2;
	out SPL, temp;

  ; communications configuration
	rcall ConfigPorts;
	rcall SPI_MasterInit;
	rcall UART_Init;

main_cycle:
  ; ожидаем приема от ПК по uart
;	rcall UART_Rcv
;	mov driveN, dataTemp ; номер двигателя

	; немного выжидаем
	rcall Waiting_some_ms_proc

	; отправляем подтверждение
;	ldi dataTemp, UART_ACK
;	rcall UART_Snd

	; немного выжидаем
;	rcall Waiting_some_ms_proc

	; получаем число (полушагов)
;	rcall UART_Rcv
;	mov stepsN, dataTemp ; число шагов

	ldi dataTemp, $00
	; включаем ведомый МК
	rcall select_Drive
	; немного выжидаем
	rcall Waiting_some_ms_proc
	; передаем число шагов для выполнения
	ldi dataTemp, $84
	rcall SPI_MasterTransmit
; CHECK TRANSMITTER OF SLAVE
	cpi dataTemp, SECOND_STEP_SPI;0b11100001
	brne Got_Wrong1
	rjmp Got_Ok1
	Got_Wrong1:
	sbi PORTB, 0
	rjmp Next_Step1
	Got_Ok1:
	cbi PORTB, 0
	Next_Step1:
	; немного выжидаем
	rcall Waiting_some_ms_proc
	; отключаем ведомый МК
	rcall deselect_Drives
	; немного выжидаем
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	; и в обратную сторону...
	ldi dataTemp, $00
	; включаем ведомый МК
	rcall select_Drive
	; немного выжидаем
	rcall Waiting_some_ms_proc
	; передаем число шагов для выполнения
	ldi dataTemp, SECOND_STEP_SPI
	rcall SPI_MasterTransmit
; CHECK TRANSMITTER OF SLAVE
	cpi dataTemp, FIRST_STEP_SPI;0b11100001
	brne Got_Wrong2
	rjmp Got_Ok2
	Got_Wrong2:
	sbi PORTB, 1
	rjmp Next_Step2
	Got_Ok2:
	cbi PORTB, 1
	Next_Step2:
	; немного выжидаем
	rcall Waiting_some_ms_proc
	; отключаем ведомый МК
	rcall deselect_Drives
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	rcall Waiting_some_ms_proc
	; говорим ПК, что мы передали ведомому МК данные
;	ldi dataTemp, UART_ACK
;	rcall UART_Snd
	rjmp main_cycle;

; ------------------------------- MAIN FINISHED -----------------------------

; ----------- PROCS ------------
; configure ports
; In - NONE
; Out - NONE
ConfigPorts:
	; config drive selector (PORTC) - 0,1,2,3,4,5 - out, 6 - in
	ldi temp, 0b00111111;
	out DDRC, temp;
	; config (PORTB) - 0, MOSI, SCK, [0, 1, 2 - unsused,for safety] - out, MISO - in.
	ldi temp, 0b00101111;
	out DDRB, temp;
	; config UART (PORTD) - 1,2,3,4,5,6,7 - out, 0 - in
	ldi temp, 0b11111110;
	out DDRD, temp;
	; globaly disable interrupts
	cli;
	ret

; allow SPI
; In - NONE
; Out - NONE
SPI_MasterInit:
; Set MOSI and SCK direction to output, all others are set to input
	ldi temp, (1<<DD_MOSI)|(1<<DD_SCK)|(1<<DD_SS)
	out DDR_SPI,temp
	ldi temp, (1<<DD_MISO)|(1<<DD_SS)
	out PORT_SPI, temp
	; Enable SPI, Master, set clock rate fck/4
	ldi temp, (1<<SPE)|(1<<MSTR);|(1<<SPR0);|(1<<SPR1)|(1<<SPR0)
	out SPCR, temp
	ret

; SPI tranmition as master
; In - dataTemp - byte to be tranmitted
; Out - NONE
SPI_MasterTransmit:
; Start transmission of data (r16)
	out SPDR, dataTemp
  Wait_Transmit:
; Wait for transmission complete
	sbis SPSR,SPIF
	rjmp Wait_Transmit
	in dataTemp, SPDR
	ret

; SPI recieve routine (it uses FIFO-ed SPI with 0b00000000 data to be sent)
; In - NONE
; Out - dataTemp - retrieved byte
SPI_Recieve:
	clr dataTemp
	rcall SPI_MasterTransmit
	in dataTemp, SPDR
	ret

; UART initialization @ 9600 bps
; In - NONE
; Out - NONE
UART_Init:
  ; setting baudrate
	ldi tempBaudRateH, uart_baudrate_h
	ldi tempBaudRateL, uart_baudrate_l
	out UBRRH, tempBaudRateH
	out UBRRL, tempBaudRateL
  ; Enable reciever and transmitter
	ldi dataTemp, (1<<RXEN)|(1<<TXEN)
	out UCSRB, dataTemp
  ; setting frame format: 8data bits, 2 stop bits
	ldi dataTemp, (1<<URSEL)|(0<<USBS)|(1<<UCSZ1)|(1<<UCSZ0)
	out UCSRC, dataTemp
	ret

; UART recieve proc
; In - NONE
; Out - dataTemp - recieved byte
UART_Rcv:
	sbis UCSRA, RXC
	rjmp UART_Rcv
	in dataTemp, UDR
	ret

; UART send proc
; In - dataTemp - byte to be transmitted over UART
; Out - NONE
UART_Snd:
	sbis UCSRA, UDRE
	rjmp UART_Snd
;CheckFinishPrevSnd:
;	sbis UCSRA, TXC
;	rjmp CheckFinishPrevSnd
	out UDR, dataTemp
	ret

; select drive
; In - dataTemp - drive to select
; Out - NONE
select_Drive:
	andi dataTemp, 0b00000111
	ori dataTemp, 0b00001000
	out PORTC, dataTemp
	nop;
	nop;
	ret

; deselect drives
; In - NONE
; Out - dataTemp = 0
deselect_Drives:
	clr dataTemp
	ori dataTemp, 0b00110000
	out PORTC, dataTemp
	nop;
	nop;
	ret

Waiting_some_ms_proc:
	; подождем xxx миллисекунд? ;-)
	ldi Razr0, Waiting0
	ldi Razr1, Waiting1
	ldi Razr2, Waiting2
  Waiting_some_ms:
	subi Razr0, 1
	sbci Razr1, 0
	sbci Razr2, 0
	brcc Waiting_some_ms
	ret
