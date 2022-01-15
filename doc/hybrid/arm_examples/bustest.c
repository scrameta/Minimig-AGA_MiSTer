#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <stdlib.h>

#include "mem_init.h"

void speedtest(char const * item, void * addr, unsigned long bytes)
{
	volatile unsigned char * byte_addr;
	volatile unsigned short * word_addr;
	volatile unsigned int * longword_addr;

	clock_t pre,post;
	double mb = ((double)bytes)/1024/1024;
	printf("%s:%0.0fMB\n",item,mb);
	// Byte read
	pre = clock();
	byte_addr = (unsigned char *) addr;
	for (unsigned long i=0;i!=bytes;++i)
	{
		byte_addr[i];
	}
	post = clock();
	clock_t byte_read = post-pre;
	printf("%s:read 1+0:%fMB/s\n",item,mb/(((double)byte_read)/CLOCKS_PER_SEC));

	// word read
	pre = clock();
	word_addr = (unsigned short *) addr;
	unsigned long words = bytes/2;
	for (unsigned long i=0;i!=words;++i)
	{
		word_addr[i];
	}
	post = clock();
	clock_t word_read = post-pre;
	printf("%s:read 2+0:%fMB/s\n",item,mb/(((double)word_read)/CLOCKS_PER_SEC));

	// long read
	pre = clock();
	longword_addr = (unsigned int *) addr;
	unsigned long longwords = bytes/4;
	for (unsigned long i=0;i!=longwords;++i)
	{
		longword_addr[i];
	}
	post = clock();
	clock_t longword_read = post-pre;
	printf("%s:read 4+0:%fMB/s\n",item,mb/(((double)longword_read)/CLOCKS_PER_SEC));

	// Byte write
	pre = clock();
	for (unsigned long i=0;i!=bytes;++i)
	{
		byte_addr[i]=0;
	}
	post = clock();
	clock_t byte_write = post-pre;
	printf("%s:write 1+0:%fMB/s\n",item,mb/(((double)byte_write)/CLOCKS_PER_SEC));

	// Aligned word write
	pre = clock();
	for (unsigned long i=0;i!=words;++i)
	{
		word_addr[i]=0;
	}
	post = clock();
	clock_t word_write = post-pre;
	printf("%s:write 2+0:%fMB/s\n",item,mb/(((double)word_write)/CLOCKS_PER_SEC));

	// Aligned long write
	pre = clock();
	for (unsigned long i=0;i!=longwords;++i)
	{
		longword_addr[i]=0;
	}
	post = clock();
	clock_t longword_write = post-pre;
	printf("%s:write 4+0:%fMB/s\n",item,mb/(((double)longword_write)/CLOCKS_PER_SEC));
}

int main(void)
{
    mem_init(1);

    speedtest("chipram",chipram_addr,chipram_bytes);
    speedtest("fastram",z3fastram_addr,z3fastram_bytes);
    speedtest("rom",rom_addr_orig,rom_bytes);
    speedtest("rom_copy",rom_addr_fast,rom_bytes);
    speedtest("rtg",rtgcard_addr,rtgcard_bytes);
    speedtest("irq",irqs,4);
    return 0;
}


