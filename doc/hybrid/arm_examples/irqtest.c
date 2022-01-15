#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <sys/ioctl.h>

#include "mem_init.h"
#include "minimig_ioctl.h"

const unsigned int INTENAR=0xdff01c; 
const unsigned int INTREQR=0xdff01e;
const unsigned int INTENA =0xdff09a; // bit 14 global enable
const unsigned int INTREQ =0xdff09c; // Need to set bit 15 to if I want to set to 1 or 0

const unsigned short INT_SET         = 0x8000;
const unsigned short INT_INTEN       = 0x4000;
const unsigned short INT_EXTER       = 0x2000;
const unsigned short INT_DSKSYN      = 0x1000;
const unsigned short INT_RBF         = 0x0800;
const unsigned short INT_AUD3        = 0x0400;
const unsigned short INT_AUD2        = 0x0200;
const unsigned short INT_AUD1        = 0x0100;
const unsigned short INT_AUD0        = 0x0080;
const unsigned short INT_BLIT        = 0x0040;
const unsigned short INT_VERTB       = 0x0020;
const unsigned short INT_COPER       = 0x0010;
const unsigned short INT_PORTS       = 0x0008;
const unsigned short INT_SOFT        = 0x0004;
const unsigned short INT_DSKBLK      = 0x0002;
const unsigned short INT_TBE         = 0x0001;

clock_t volatile pre=0;

unsigned short hpeek(int hwaddr)
{
	int hwaddrraw = hwaddr;
	hwaddr = hwaddr - 0x200000;
	unsigned short volatile * a = (unsigned short *)(((unsigned char *)hardware_addr)+hwaddr);
	unsigned short res = *a;
	res = ((res&0xff)<<8) | (res>>8);
	//printf("Peeking:%x:%x\n",hwaddrraw,(int)res);
	return res;
}

void hpoke(int hwaddr, unsigned short val)
{
	val = ((val&0xff)<<8) | (val>>8);
	//printf("Poking:%x:%x\n",hwaddr,(int)val);
	hwaddr = hwaddr - 0x200000;
	unsigned short volatile * a = (unsigned short *)(((unsigned char *)hardware_addr)+hwaddr);
	*a = val;
}

double elapsed[256];
int elpos = 0;

static void * mythreadfunc(void * opaque)
{
    static int first = 1;
    if (first)
    {
	    first =0;
	    fprintf(stderr,"ioctl thread:%d\n",gettid());
    }

    int fd = open ("/sys/kernel/debug/minimig_irq/ioctl_dev",O_RDONLY);
    int current1 = *(int volatile *)irqs;
    printf("Waiting for IRQs:%x\n",current1);
    while (1)
    {
	int res = ioctl(fd, MINIMIG_IOC_WAIT_IRQ, 1);
	if (res<0)
		perror("arg:");

    	int current = *(int volatile *)irqs;
	//fprintf(stderr,"i");
	  //  FILE *logfile = qemu_log_lock();
	//    qemu_fprintf(logfile,"IRQ on ioctl:%d:%ld\n",current,clock());
	   // qemu_log_unlock(logfile);
        int irq_val = 7&(~current);
	clock_t post = clock();
	elapsed[elpos++] = ((double)post-pre)/CLOCKS_PER_SEC;
	//printf("IRQ:%d:%f\n", irq_val,((double)post-pre)/CLOCKS_PER_SEC);

	pre = 0;
    }
    return 0;
}

int main(void)
{
	mem_init(0);
  	pthread_t * mythread = malloc(sizeof(pthread_t));
  	memset(mythread,0,sizeof(pthread_t));
	pthread_attr_t attr;
	pthread_attr_init (&attr);
	pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED);
	pthread_attr_setschedpolicy (&attr, SCHED_FIFO);
	struct sched_param param;
	pthread_attr_getschedparam (&attr, &param);
	param.sched_priority = 99;
	pthread_attr_setschedparam (&attr, &param);
  	pthread_create(mythread,&attr,&mythreadfunc,0);
	sleep(1);

	hpoke(INTREQ,0);
	hpoke(INTENA,0x7fff);
	printf("ENA:%x\n",(int)hpeek(INTENAR));
	hpoke(INTENA,INT_SET|INT_INTEN|INT_SOFT);
	printf("ENA:%x\n",(int)hpeek(INTENAR));
	elpos = 0;
	for (int i=0;i!=10;++i)
	{
		// Raise an interrupt, time how long until I receive it
		pre = clock();
		hpoke(INTREQ,INT_SET|INT_SOFT); // enable irq
		while (pre);
		pre = clock();
		hpoke(INTREQ,INT_SOFT); // clear irq
		while (pre);

		usleep(100000);
	}
	for (int i=0;i!=elpos;++i)
	{
		printf("%d:%f\n",i,elapsed[i]);
	}

	hpoke(INTREQ,INT_SOFT); // clear irq
	hpoke(INTENA,0x7fff);
	return 0;
}


