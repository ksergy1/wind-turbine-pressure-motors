#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */
#include <stdlib.h>

#define RDWR_BUFSZ 1
#define NDRIVES_MASK 0x07
#define DIR_MASK 0x01
#define DIR_POSITION 0x07
#define NSTEPS_MASK 0x7f
#define ONE_BYTE 0xff
#define uart_ack 0xc5

#define TESTER_UART_ATMEGA
#undef TESTER_UART_ATMEGA

void Read_port (int fd, char* data, int size)
{
 int nBytes;
 nBytes = read(fd, data, size);
 if (nBytes > 0) {
    perror("While read");
    exit(1);
 };
}

void Send_port (int fd, char* data, int size)
{
 int n;
 n = write(fd, data, size);
 if (n < 0) {
    perror("while send");
    exit(1);
 };
}

int main (int argc, char** argv)
{
 char fl_name[256];
 struct termios PortOpts, result;
 int fd; /* File descriptor for the port */
 unsigned int DriveN;
 unsigned int Nsteps;
 unsigned int Direction;
 unsigned int GotSmth;
 unsigned char drvN, Nst, rslt;

/* Open port */
 printf(" Type in serial port name:");
 scanf("%s", fl_name);

 fd = open(fl_name, O_RDWR | O_NOCTTY);
 printf("fd = %d\n", fd);
 if (fd < 0) {
  perror("open_port: Unable to open - ");
  return 1;
 };// else fcntl(fd, F_SETFL, 0);

/* Configure Port */
 if (tcgetattr(fd, &PortOpts) < 0) {
    perror("While getting serial port parameters");
    return 1;
 };
 // BaudRate - 9600
 cfsetispeed(&PortOpts, B9600);
 cfsetospeed(&PortOpts, B9600);
 // enable reciever and set local mode, frame format - 8N1 (~CSTOPB) @ 9600 BPS, no H/W flow control
 PortOpts.c_cflag &= (~(CLOCAL | CREAD | CSIZE | CSTOPB | PARENB | CRTSCTS));
 PortOpts.c_cflag |= (CLOCAL | CREAD | CS8);
// PortOpts.c_cflag &= ~PARENB
// PortOpts.c_cflag |= CSTOPB
// PortOpts.c_cflag &= ~CSIZE;
// PortOpts.c_cflag |= CS8;
 // no parity check, no software flow control on input
 PortOpts.c_iflag |= IGNPAR;
 PortOpts.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON | IXOFF | IXANY | INPCK);
 // raw data input mode
 PortOpts.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
 // raw data output
 PortOpts.c_oflag &= ~OPOST;
 // setting timeouts
 PortOpts.c_cc[VMIN] = 1; // minimum number of chars to read in noncanonical (raw mode)
 PortOpts.c_cc[VTIME] = 5; // time in deciseconds to wait for data in noncanonical mode (raw mode)

 if (tcsetattr(fd, TCSANOW, &PortOpts) ==  0) {
    tcgetattr(fd, &result);
    if ( (result.c_cflag != PortOpts.c_cflag) ||
         (result.c_oflag != PortOpts.c_oflag) ||
         (result.c_iflag != PortOpts.c_iflag) ||
         (result.c_cc[VMIN] != PortOpts.c_cc[VMIN]) ||
         (result.c_cc[VTIME] != PortOpts.c_cc[VTIME]) ) {
        perror("While configuring port1");
        close(fd);
        return 1;
    }
 } else {
    perror("While configuring port2");
    close(fd);
    return 1;
 };

/* main proc */
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
        Send_port(fd, &drvN, 1);

        Read_port(fd, &rslt, 1);
        //if (rslt != uart_ack) {
        //    printf(" Wrong acknowledge got - %x\n", rslt);
        //    break;
        //};

        Nst = Nsteps & ONE_BYTE;
        printf(" Command is ready to be sent - %x\n", Nst);
        Send_port(fd, &Nst, 1);

        Read_port(fd, &rslt, 1);
        //if (rslt != uart_ack) {
        //    printf(" Wrong acknowledge - %x\n", rslt);
        //    break;
        //};
    } while (1);
#else
    do {
        printf("Type in byte to send (hex, 100 - exit) - ");
        scanf("%x", &DriveN);
        if (DriveN == 0x100) break;

        drvN = DriveN & ONE_BYTE;
        printf(" Byte is ready to be sent - %x\n", drvN);
        Send_port(fd, &drvN, 1);

        Read_port(fd, &rslt, 1);
        printf(" Result got - %x\n", rslt);
    } while (1);
#endif

 close(fd);
 return 0;
}

