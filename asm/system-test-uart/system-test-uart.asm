.include "m8def.inc"
; fosc = 8MHz
; Fuse-bits : MSB ... LSB (76543210)
;   High byte: 11011111
;   Low byte : 11100100

.def temp = r25
.def temp2 = r18
.def dataTemp = r21
.def driveN = r19
.def stepsN = r20
; формируем задержку
.def Razr0 = r22
.def Razr1 = r23
.def Razr2 = r24
; 25 мс
.equ Waiting0 = 0b01000000
.equ Waiting1 = 0b10011100
.equ Waiting2 = 0b00000000

; ----------------------------------
; подтверждение при передаче по uart - C5
.equ UART_ACK = $39

.def tempBaudRateH = r17
.def tempBaudRateL = r16
.equ DDR_SPI = DDRB
.equ DD_SCK = DDB5
.equ DD_MISO = DDB4
.equ DD_MOSI = DDB3

; uart baudrate coeff
.equ uart_baudrate_h = 0b00000000
.equ uart_baudrate_l = 0b00110011

; zero address
rjmp MAIN;
rjmp NILL_INT   ; IRQ0 Handler
rjmp NILL_INT   ; IRQ1 Handler
rjmp NILL_INT   ; Timer2 Compare Handler
rjmp NILL_INT   ; Timer2 Overflow Handler
rjmp NILL_INT   ; Timer1 Capture Handler
rjmp NILL_INT   ; Timer1 CompareA Handler
rjmp NILL_INT   ; Timer1 CompareB Handler
rjmp NILL_INT   ; Timer1 Overflow Handler
rjmp NILL_INT   ; Timer0 Overflow Handler
rjmp NILL_INT   ; SPI Transfer Complete Handler
rjmp USART_RXC  ; USART RX Complete Handler
rjmp USART_UDRE ; UDR Empty Handler
rjmp USART_TXC  ; USART TX Complete Handler
rjmp NILL_INT   ; ADC Conversion Complete Handler
rjmp NILL_INT   ; EEPROM Ready Handler
rjmp NILL_INT   ; Analog Comparator Handler
rjmp NILL_INT   ; Two-wire Serial Interface Handler
rjmp NILL_INT   ; Store Program Memory Ready Handler

; ------------ MAIN --------------
MAIN:
  ; configurations block
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

;    sbi PORTB, 1
main_cycle:
    ; подождем 250 миллисекунд? ;-)

    rcall Waiting_some_ms_proc
    cbi PORTB, 0
  ; ожидаем приема от ПК по uart
  ; посылаем по uart один единственный байт.
    ldi dataTemp, UART_ACK
    rcall UART_Snd
    ; подождем 250 миллисекунд? ;-)

    rcall Waiting_some_ms_proc
    sbi PORTB, 0

    rjmp main_cycle;

; ------------------------------- MAIN FINISHED -----------------------------

; ----------- ints -------------
NILL_INT:
    reti;

USART_RXC:
    reti

USART_UDRE:
    reti

USART_TXC:
    reti

; ----------- PROCS ------------
; configure ports
; In - NONE
; Out - NONE
ConfigPorts:
    ; config drive selector (PORTC) - 0,1,2,3,4,5 - out, 6 - in
    ldi temp, 0b00111111;
    out DDRC, temp;
    ; config (PORTB) - 0, MOSI, SCK, [1, 2 - unused,for safety] - out, MISO - in.
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
    ldi temp, (1<<DD_MOSI)|(1<<DD_SCK)
    out DDR_SPI,temp
    ; Enable SPI, Master, set clock rate fck/4
    ldi temp, (1<<SPE)|(1<<MSTR)
    out SPCR, temp
    ; Double the clock rate! up to fck/2
;    sbi SPSR, SPI2X
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
    rcall Waiting_some_ms_proc
    cbi PORTB, 1
    rcall Waiting_some_ms_proc
    sbi PORTB, 1

    sbis UCSRA, UDRE
    rjmp UART_Snd

;CheckFinishPrevSnd:
;    rcall Waiting_some_ms_proc
;    cbi PORTB, 2
;    rcall Waiting_some_ms_proc
;    sbi PORTB, 2

;    sbis UCSRA, TXC
;    rjmp CheckFinishPrevSnd
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
