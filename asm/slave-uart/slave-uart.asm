.include "tn2313def.inc"

; fosc = 8MHz
; Fuse-bits
;	High byte: 0b11011111
;	Low byte : 0b11100100

.def tempBaudRateH = r17
.def tempBaudRateL = r16
; uart baudrate coeff
.equ uart_baudrate_h = 0b00000000
.equ uart_baudrate_l = 0b00110011

; формируем задержку
.def Razr0 = r22
.def Razr1 = r23
.def Razr2 = r24
; 25 мс
.equ Waiting0 = 0b01000000
.equ Waiting1 = 0b10011100
.equ Waiting2 = 0b00000000

.equ SPI_ACK = 0b11100001

.equ LowTestC = 0b00000000
.equ MidTestC = 0b00110101
.equ HighTestC = 0b00000011

.equ SpiPort = PORTB
.equ DDR_SPI = DDRB
.equ SPI_PINS = PINB
.equ SpiSCK = PORTB7
.equ SpiDO = PORTB6
.equ SpiDI = PORTB5

.def temp = r17
; для передачи данных по SPI
.def dataTemp = r16
; счетчик для формирования задержки в коммутации обмоток ШД
.def WaitingCounter0 = r18
.def WaitingCounter1 = r19
.def WaitingCounter2 = r20
; значение счетчиков (для частоты коммутации = 20кГц и частоты МК = 8МГц)
.equ LowCounter = 0b01100011
.equ MidCounter = 0b00000000
;.equ HighCounter = 0b00000000
; начало отсчета состояний (основание ОЗУ)
.equ RAM_BASE = 0x60
.equ RAM_FINISH = 0x67
; маска для порта обмоток
.equ WIND_MASK = 0b00000000
; маска для порта разрешения обмоток
.equ WENB_MASK = 0b00000011

; состояния обмоток
.equ State1 = 0b00000101
.equ State2 = 0b00000001
.equ State3 = 0b00001001
.equ State4 = 0b00001000
.equ State5 = 0b00001010
.equ State6 = 0b00000010
.equ State7 = 0b00000110
.equ State8 = 0b00000100

; биты состояния
.equ StateMCU1 = 3
.equ StateMCU2 = 4
.equ StateMCU3 = 5
.equ StateMCU4 = 6
.equ StateMCUPort = PORTD
.equ ClearStateMCU = 0b00000011

; 1. конфигурирование
; 2. ожидание приема по SPI. Направление, число полушагов.
; 3. выполнение принятого
; 3.1 чтение следующего состояния обмоток
; 3.2 применение следующего состояния обмоток
; 3.3 текущее состояние = следующее состояние

; LD R, X+ ; R <- [X], X++
; ST X+, R ; [X] <- R, X++

; векторы прерываний
	rjmp MAIN;
	rjmp CrystalSelected	; External Interrupt0 Handler
	rjmp NILL_INT			; External Interrupt1 Handler
	rjmp NILL_INT			; Timer1 Capture Handler
	rjmp NILL_INT			; Timer1 CompareA Handler
	rjmp NILL_INT			; Timer1 Overflow Handler
	rjmp NILL_INT			; Timer0 Overflow Handler
	rjmp NILL_INT			; USART0 RX Complete Handler
	rjmp NILL_INT			; USART0,UDR Empty Handler
	rjmp NILL_INT			; USART0 TX Complete Handler
	rjmp NILL_INT			; Analog Comparator Handler
	rjmp NILL_INT			; Pin Change Interrupt
	rjmp NILL_INT			; Timer1 Compare B Handler
	rjmp NILL_INT			; Timer0 Compare A Handler
	rjmp NILL_INT			; Timer0 Compare B Handler
	rjmp NILL_INT			; USI Start Handler
	rjmp NILL_INT			; USI Overflow Handler
	rjmp NILL_INT			; EEPROM Ready Handler
	rjmp NILL_INT			; Watchdog Overflow Handler

; инициализация
MAIN:
; 1. конфигурирование
	cli
; выделяем под стек всю оперативную память
	ldi temp, Low(RAMEND);
	out SPL, temp;
; Запонение оперативной памяти
	ldi XL, RAM_BASE
	clr XH
	ldi temp, State1
	st X+, temp
	ldi temp, State2
	st X+, temp
	ldi temp, State3
	st X+, temp
	ldi temp, State4
	st X+, temp
	ldi temp, State5
	st X+, temp
	ldi temp, State6
	st X+, temp
	ldi temp, State7
	st X+, temp
	ldi temp, State8
	st X+, temp
; инициализация SPI (Fck/4) и портов ввода-вывода (SPI - без прерываний)
;	ldi temp, (1<<SpiDO)|(1<<PORTB0)|(1<<PORTB1)|(1<<PORTB2)|(1<<PORTB3)
;	out DDRB, temp;
;	ldi temp, (1<<USIWM0)|(1<<USICS1);
;	out USICR, temp;
; инициализация uart
	rcall UART_Init
; включение spi - по прерыванию
; сначала разрешим прерывания внешние int0 и int1
	; включение Crystal select (int1) - по срезу, SyncMotor (int0) - по спаду
	; (+отключение sleepmode, sleepmode = power-down)
	ldi temp, (1<<SM1)|(1<<SM0)|(1<<ISC01)
	out MCUCR, temp;
	; разрешение external-INT0 и отключение PinChange прерываний
	ldi temp, (1<<INT0);
	out GIMSK, temp;
	; Отключение pin change прерываний (по одному, в довесок)
	clr temp;
; ATtiny2313
	out PCMSK, temp;

; Настраиваем порты 
; PORTB
	;сделано раньше
; PORTD
	ldi temp, 0b00111011	; на выход - все
	out DDRD, temp
	ldi temp, ClearStateMCU
	out StateMCUPort, temp

	; Инициализация ШД
	; разрешение обмоток
	clr temp
	ldi temp, WENB_MASK
	out PORTD, temp
	; конфигурация обмоток
	clr XH;
	ldi XL, RAM_BASE
	ld temp, X
	ori temp, WIND_MASK
	out PORTB, temp
	; разрешаем прерывания...
	sei;

	; Выполняем цикл
; 2. ожидание приема по SPI. Направление, число полушагов.
  main_cycle:
	ldi temp, ClearStateMCU
	out StateMCUPort, temp
	rjmp main_cycle;

; пустое прерывание
NILL_INT:
	reti;

; 3.1 чтение следующего состояния обмоток
; 3.2 применение следующего состояния обмоток
; 3.3 текущее состояние = следующее состояние
; Прерывание на выбор кристала (прием команды от ведущего и выполнение ее сразу же)
CrystalSelected:
	sbi StateMCUPort, StateMCU1
	; очищаем флаги прерываний
	ldi temp, 0b11111111
	out GIFR, temp
	; ожидаем передачи по UART
;	clr dataTemp;

	rcall UART_Rcv

	ldi temp, ClearStateMCU
	out StateMCUPort, temp
	sbi StateMCUPort, StateMCU2

	; выработка необходимых последовательностей
	; старший бит dataTemp = 1 - в сторону "-"
	; старший бит dataTemp = 0 - в сторону "+"
	sbrs dataTemp, 7
	rjmp to_plus;

 to_minus:
	ldi temp, ClearStateMCU
	out StateMCUPort, temp
	sbi StateMCUPort, StateMCU3

	cbr dataTemp, 7
	cpi XL, RAM_BASE
	brne ok_to_decrement
	ldi XL, RAM_FINISH
	rjmp finished_X_dec
 ok_to_decrement:
	dec XL
 finished_X_dec:
	ld temp, X
	; меняем состояние обмоток
	ori temp, WIND_MASK
	out PORTB, temp
	; временная задержка для драйвера ШД - частота смены состояний должна быть не более, чем 40 кГц.
	; возьмем частоту = 20кГц -> T = 0.00005 секунд.(или 400 тактов при 8МГц тактовой частоте МК)
	; и еще разок (счетчик - dataTemp - до обнуления!)
	rcall CommutationDelay
	dec dataTemp
	brne	to_minus; еще есть куда продолжать (dataTemp != 0)
	rjmp escape_from_irq;

 to_plus:
	ldi temp, ClearStateMCU
	out StateMCUPort, temp
	sbi StateMCUPort, StateMCU4

	cbr dataTemp, 7
	cpi XL, RAM_FINISH
	brne ok_to_increment
	ldi XL, RAM_BASE
	rjmp finished_X_inc
 ok_to_increment:
	inc XL
 finished_X_inc:
	ld temp, X
	; меняем состояние обмоток
	ori temp, WIND_MASK
	out PORTB, temp
	; временная задержка для драйвера ШД - частота смены состояний должна быть не более, чем 40 кГц.
	; возьмем частоту = 20кГц -> T = 0.00005 секунд.(или 400 тактов при 8МГц тактовой частоте МК)
	; и еще разок (счетчик - dataTemp - до обнуления!)
	rcall CommutationDelay
	dec dataTemp
	brne	to_minus; еще есть куда продолжать (dataTemp != 0)
 escape_from_irq:
	; очищаем флаги прерываний
	ldi temp, 0b11111111
	out GIFR, temp
	reti;

TesterDelay:
	ldi WaitingCounter0, LowTestC
	ldi WaitingCounter1, MidTestC
	ldi WaitingCounter2, HighTestC
	TesterDelay_do:
	subi WaitingCounter0, 1
	sbci WaitingCounter1, 0
	sbci WaitingCounter2, 0
	brcc TesterDelay_do
	ret

CommutationDelay:
	ldi WaitingCounter0, LowCounter
	ldi WaitingCounter1, MidCounter
	CommutationDelay_do:
	subi WaitingCounter0, 1
	sbci WaitingCounter1, 0
	brcc CommutationDelay_do
	ret


; функция приеме-передачи данных по SPI
; IN - dataTemp - byte to send
; OUT - dataTemp - recieved byte
SPI_xfer:
	out USIDR, dataTemp;
	sbi USISR, USIOIF;
  xfer_complete_check:
	sbic USISR, USIOIF;
	rjmp xfer_complete_check;
	in dataTemp, USIDR;
	ret;

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
    ldi dataTemp, (1<<USBS)|(3<<UCSZ0)
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
    rcall Waiting_some_ms_proc
    cbi PORTB, 1
    rcall Waiting_some_ms_proc
    sbi PORTB, 1

    sbis UCSRA, UDRE
    rjmp UART_Snd

    out UDR, dataTemp
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
