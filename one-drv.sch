EESchema Schematic File Version 2  date Вск 03 Мар 2013 23:21:34
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:one-drv-cache
EELAYER 27 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date "3 mar 2013"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ATTINY2313-P IC1
U 1 1 512A2EE8
P 3100 2400
F 0 "IC1" H 2250 3350 60  0000 C CNN
F 1 "ATTINY2313-P" H 3700 1550 60  0000 C CNN
F 2 "DIP20" H 2300 1550 60  0001 C CNN
	1    3100 2400
	1    0    0    -1  
$EndComp
$Comp
L CONN_5X2 P1
U 1 1 512A3054
P 2150 5300
F 0 "P1" H 2150 5600 60  0000 C CNN
F 1 "CONN_5X2" V 2150 5300 50  0000 C CNN
	1    2150 5300
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 512A3063
P 4900 1300
F 0 "R1" H 4930 1400 50  0000 C CNN
F 1 "5k1" H 5150 1400 50  0000 C CNN
	1    4900 1300
	0    -1   -1   0   
$EndComp
$Comp
L R R2
U 1 1 512A3072
P 5300 1300
F 0 "R2" H 5330 1400 50  0000 C CNN
F 1 "5k1" H 5550 1400 50  0000 C CNN
	1    5300 1300
	0    -1   -1   0   
$EndComp
$Comp
L R R3
U 1 1 512A3081
P 5650 1300
F 0 "R3" H 5680 1400 50  0000 C CNN
F 1 "5k1" H 5900 1400 50  0000 C CNN
	1    5650 1300
	0    -1   -1   0   
$EndComp
$Comp
L VCC #PWR1
U 1 1 512A3090
P 5300 700
F 0 "#PWR1" H 5300 800 30  0001 C CNN
F 1 "VCC" H 5300 800 30  0000 C CNN
	1    5300 700 
	1    0    0    -1  
$EndComp
Text GLabel 5850 2300 2    60   Input ~ 0
SCK
Text GLabel 6250 2200 2    60   Output ~ 0
MISO
Text GLabel 5850 2100 2    60   Input ~ 0
MOSI
$Comp
L VCC #PWR5
U 1 1 512A30F5
P 3100 1200
F 0 "#PWR5" H 3100 1300 30  0001 C CNN
F 1 "VCC" H 3100 1300 30  0000 C CNN
	1    3100 1200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR7
U 1 1 512A3113
P 3100 3500
F 0 "#PWR7" H 3100 3500 30  0001 C CNN
F 1 "GND" H 3100 3430 30  0001 C CNN
	1    3100 3500
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 512A3132
P 1800 1350
F 0 "R4" H 1830 1450 50  0000 C CNN
F 1 "5k1" H 2050 1450 50  0000 C CNN
	1    1800 1350
	0    -1   -1   0   
$EndComp
$Comp
L VCC #PWR4
U 1 1 512A3141
P 1800 900
F 0 "#PWR4" H 1800 1000 30  0001 C CNN
F 1 "VCC" H 1800 1000 30  0000 C CNN
	1    1800 900 
	1    0    0    -1  
$EndComp
Text GLabel 1750 1600 0    60   Input ~ 0
RST
$Comp
L VCC #PWR9
U 1 1 512A3188
P 2600 5000
F 0 "#PWR9" H 2600 5100 30  0001 C CNN
F 1 "VCC" H 2600 5100 30  0000 C CNN
	1    2600 5000
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR10
U 1 1 512A31AC
P 2600 5650
F 0 "#PWR10" H 2600 5650 30  0001 C CNN
F 1 "GND" H 2600 5580 30  0001 C CNN
	1    2600 5650
	1    0    0    -1  
$EndComp
Text GLabel 1600 5100 0    60   Output ~ 0
MOSI
Text GLabel 1600 5300 0    60   Input ~ 0
RST
Text GLabel 1250 5400 0    60   Output ~ 0
SCK
Text GLabel 1600 5500 0    60   Input ~ 0
MISO
$Comp
L VCC #PWR3
U 1 1 512A3355
P 850 900
F 0 "#PWR3" H 850 1000 30  0001 C CNN
F 1 "VCC" H 850 1000 30  0000 C CNN
	1    850  900 
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 512A3364
P 850 1150
F 0 "C1" H 900 1250 50  0000 L CNN
F 1 "100n" H 900 1050 50  0000 L CNN
	1    850  1150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR6
U 1 1 512A3373
P 850 1450
F 0 "#PWR6" H 850 1450 30  0001 C CNN
F 1 "GND" H 850 1380 30  0001 C CNN
	1    850  1450
	1    0    0    -1  
$EndComp
$Comp
L CONN_5 P2
U 1 1 512A33C9
P 4250 5350
F 0 "P2" V 4200 5350 50  0000 C CNN
F 1 "CONN_5" V 4300 5350 50  0000 C CNN
	1    4250 5350
	1    0    0    -1  
$EndComp
Text GLabel 3750 5150 0    60   Output ~ 0
MOSI
Text GLabel 3400 5250 0    60   Output ~ 0
SCK
Text GLabel 3750 5350 0    60   Input ~ 0
MISO
Text GLabel 3400 5450 0    60   Output ~ 0
INTR
$Comp
L GND #PWR11
U 1 1 512A33DA
P 3750 5700
F 0 "#PWR11" H 3750 5700 30  0001 C CNN
F 1 "GND" H 3750 5630 30  0001 C CNN
	1    3750 5700
	1    0    0    -1  
$EndComp
Text GLabel 5100 2700 2    60   Input ~ 0
INTR
$Comp
L CONN_7 P3
U 1 1 512A3576
P 5900 5400
F 0 "P3" V 5870 5400 60  0000 C CNN
F 1 "CONN_7" V 5970 5400 60  0000 C CNN
	1    5900 5400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR12
U 1 1 512A3585
P 5500 5800
F 0 "#PWR12" H 5500 5800 30  0001 C CNN
F 1 "GND" H 5500 5730 30  0001 C CNN
	1    5500 5800
	1    0    0    -1  
$EndComp
Text GLabel 4600 2500 2    60   Output ~ 0
EnA
Text GLabel 4850 2600 2    60   Output ~ 0
EnB
Text GLabel 4250 1400 1    60   Output ~ 0
A+
Text GLabel 4350 1200 1    60   Output ~ 0
A-
Text GLabel 4450 1400 1    60   Output ~ 0
B+
Text GLabel 4600 1200 1    60   Output ~ 0
B-
Text GLabel 5450 5100 0    60   Input ~ 0
A+
Text GLabel 5250 5200 0    60   Input ~ 0
EnA
Text GLabel 5000 5300 0    60   Input ~ 0
A-
Text GLabel 5450 5400 0    60   Input ~ 0
B+
Text GLabel 5250 5500 0    60   Input ~ 0
EnB
Text GLabel 5000 5600 0    60   Input ~ 0
B-
$Comp
L R R5
U 1 1 512A9D54
P 6050 1300
F 0 "R5" H 6080 1400 50  0000 C CNN
F 1 "5k1" H 6300 1400 50  0000 C CNN
	1    6050 1300
	0    -1   -1   0   
$EndComp
Text Notes 800  6850 0    60   ~ 0
Работа выполняется в следующем порядке:\n1. Контроллер получает сигнал выбора его (INTR)\n   и данные по SPI интерфейсу (P2).\n   В данные входит - в каком направлении и сколько\n   шагов сделать двигателем.\n2. После получения этих данных контроллер выполняет\n   соответствующие действия, передавая управление\n   двигателем по контактам P3.\nНумерация выводов контроллера ATtiny2313 (IC1)\nприведена для DIP корпуса.
Text GLabel 6150 1450 2    60   Input ~ 0
INTR
$Comp
L VCC #PWR2
U 1 1 5133BEA8
P 6050 850
F 0 "#PWR2" H 6050 950 30  0001 C CNN
F 1 "VCC" H 6050 950 30  0000 C CNN
	1    6050 850 
	1    0    0    -1  
$EndComp
$Comp
L LED D1
U 1 1 5133BF35
P 4400 3400
F 0 "D1" H 4400 3500 50  0000 C CNN
F 1 "LED" H 4400 3300 50  0000 C CNN
	1    4400 3400
	0    1    1    0   
$EndComp
$Comp
L LED D2
U 1 1 5133BF44
P 4700 3400
F 0 "D2" H 4700 3500 50  0000 C CNN
F 1 "LED" H 4700 3300 50  0000 C CNN
	1    4700 3400
	0    1    1    0   
$EndComp
$Comp
L LED D3
U 1 1 5133BF53
P 5000 3400
F 0 "D3" H 5000 3500 50  0000 C CNN
F 1 "LED" H 5000 3300 50  0000 C CNN
	1    5000 3400
	0    1    1    0   
$EndComp
$Comp
L LED D4
U 1 1 5133BF62
P 5300 3400
F 0 "D4" H 5300 3500 50  0000 C CNN
F 1 "LED" H 5300 3300 50  0000 C CNN
	1    5300 3400
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 5133BF71
P 4400 4050
F 0 "R6" H 4430 4150 50  0000 C CNN
F 1 "510" H 4650 4150 50  0000 C CNN
	1    4400 4050
	0    -1   -1   0   
$EndComp
$Comp
L R R7
U 1 1 5133BF80
P 4700 4050
F 0 "R7" H 4730 4150 50  0000 C CNN
F 1 "510" H 4950 4150 50  0000 C CNN
	1    4700 4050
	0    -1   -1   0   
$EndComp
$Comp
L R R8
U 1 1 5133BF8F
P 5000 4050
F 0 "R8" H 5030 4150 50  0000 C CNN
F 1 "510" H 5250 4150 50  0000 C CNN
	1    5000 4050
	0    -1   -1   0   
$EndComp
$Comp
L R R9
U 1 1 5133BF9E
P 5300 4050
F 0 "R9" H 5330 4150 50  0000 C CNN
F 1 "510" H 5550 4150 50  0000 C CNN
	1    5300 4050
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR8
U 1 1 5133BFAD
P 5300 4350
F 0 "#PWR8" H 5300 4350 30  0001 C CNN
F 1 "GND" H 5300 4280 30  0001 C CNN
	1    5300 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 950  4900 850 
Wire Wire Line
	4900 850  5650 850 
Wire Wire Line
	5300 700  5300 950 
Connection ~ 5300 850 
Wire Wire Line
	5650 850  5650 950 
Wire Wire Line
	4250 2100 5850 2100
Wire Wire Line
	4250 2200 6250 2200
Wire Wire Line
	4250 2300 5850 2300
Wire Wire Line
	3100 1200 3100 1300
Wire Wire Line
	3100 3400 3100 3500
Wire Wire Line
	1800 1450 1800 1600
Wire Wire Line
	1750 1600 1950 1600
Connection ~ 1800 1600
Wire Wire Line
	1800 900  1800 1000
Wire Wire Line
	2600 5000 2600 5100
Wire Wire Line
	2600 5100 2550 5100
Wire Wire Line
	2550 5200 2600 5200
Wire Wire Line
	2600 5200 2600 5650
Wire Wire Line
	2550 5300 2600 5300
Connection ~ 2600 5300
Wire Wire Line
	2550 5400 2600 5400
Connection ~ 2600 5400
Wire Wire Line
	2550 5500 2600 5500
Connection ~ 2600 5500
Wire Wire Line
	1600 5100 1750 5100
Wire Wire Line
	1750 5300 1600 5300
Wire Wire Line
	1250 5400 1750 5400
Wire Wire Line
	1750 5500 1600 5500
Wire Wire Line
	850  900  850  950 
Wire Wire Line
	850  1350 850  1450
Wire Wire Line
	3850 5150 3750 5150
Wire Wire Line
	3850 5250 3400 5250
Wire Wire Line
	3850 5350 3750 5350
Wire Wire Line
	3850 5450 3400 5450
Wire Wire Line
	3850 5550 3750 5550
Wire Wire Line
	3750 5550 3750 5700
Wire Wire Line
	4250 2700 5100 2700
Wire Wire Line
	4250 2500 4600 2500
Wire Wire Line
	4850 2600 4250 2600
Wire Wire Line
	4250 1400 4250 1600
Wire Wire Line
	4350 1200 4350 1700
Wire Wire Line
	4350 1700 4250 1700
Wire Wire Line
	4450 1400 4450 1800
Wire Wire Line
	4450 1800 4250 1800
Wire Wire Line
	4600 1200 4600 1900
Wire Wire Line
	4600 1900 4250 1900
Wire Wire Line
	4900 1400 4900 2100
Connection ~ 4900 2100
Wire Wire Line
	5300 1400 5300 2200
Connection ~ 5300 2200
Wire Wire Line
	5650 1400 5650 2300
Connection ~ 5650 2300
Wire Wire Line
	5550 5100 5450 5100
Wire Wire Line
	5550 5200 5250 5200
Wire Wire Line
	5550 5300 5000 5300
Wire Wire Line
	5450 5400 5550 5400
Wire Wire Line
	5550 5500 5250 5500
Wire Wire Line
	5550 5600 5000 5600
Wire Wire Line
	5550 5700 5500 5700
Wire Wire Line
	5500 5700 5500 5800
Wire Wire Line
	6150 1450 6050 1450
Wire Wire Line
	6050 1450 6050 1400
Wire Wire Line
	6050 850  6050 950 
Wire Wire Line
	4250 3100 4400 3100
Wire Wire Line
	4400 3100 4400 3200
Wire Wire Line
	4250 3000 4700 3000
Wire Wire Line
	4700 3000 4700 3200
Wire Wire Line
	5000 3200 5000 2900
Wire Wire Line
	5000 2900 4250 2900
Wire Wire Line
	4250 2800 5300 2800
Wire Wire Line
	5300 2800 5300 3200
Wire Wire Line
	5300 3600 5300 3700
Wire Wire Line
	5000 3700 5000 3600
Wire Wire Line
	4700 3600 4700 3700
Wire Wire Line
	4400 3700 4400 3600
Wire Wire Line
	4400 4150 4400 4250
Wire Wire Line
	4400 4250 5300 4250
Wire Wire Line
	5300 4150 5300 4350
Wire Wire Line
	5000 4150 5000 4250
Connection ~ 5000 4250
Wire Wire Line
	4700 4150 4700 4250
Connection ~ 4700 4250
Connection ~ 5300 4250
$EndSCHEMATC
