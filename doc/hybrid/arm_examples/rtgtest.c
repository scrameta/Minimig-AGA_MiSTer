#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <stdlib.h>
#include <byteswap.h>

#include "mem_init.h"

unsigned int rtg_register_base = 0xb80100;
const int REG_ADDRESS = 0;
const int REG_FORMAT  = 4;
const int REG_ENABLE  = 6;
const int REG_HSIZE   = 8;
const int REG_VSIZE   = 10;
const int REG_STRIDE  = 12;
const int REG_ID      = 14;
const int REG_PALETTE = 0x300;

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

unsigned int hpeekl(int hwaddr)
{
	int hwaddrraw = hwaddr;
	hwaddr = hwaddr - 0x200000;
	unsigned int volatile * a = (unsigned int *)(((unsigned char *)hardware_addr)+hwaddr);
	unsigned int res = *a;
	res = bswap_32(res);
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

void hpokel(int hwaddr, unsigned int val)
{
	val = bswap_32(val);
	//printf("Poking:%x:%x\n",hwaddr,(int)val);
	hwaddr = hwaddr - 0x200000;
	unsigned int volatile * a = (unsigned int *)(((unsigned char *)hardware_addr)+hwaddr);
	*a = val;
}

void dump_rtg_regs()
{
	unsigned int addr = hpeekl(rtg_register_base+REG_ADDRESS);
	unsigned short format = hpeek(rtg_register_base+REG_FORMAT);
	unsigned short enable = hpeek(rtg_register_base+REG_ENABLE);
	unsigned short hsize = hpeek(rtg_register_base+REG_HSIZE);
	unsigned short vsize = hpeek(rtg_register_base+REG_VSIZE);
	unsigned short stride = hpeek(rtg_register_base+REG_STRIDE);
	unsigned short id = hpeek(rtg_register_base+REG_ID);

	printf("Addr  :%d\n",addr);
	printf("Format:%d\n",(int)format);
	printf("Enable:%d\n",(int)enable);
	printf("Hsize :%d\n",(int)hsize);
	printf("Vsize :%d\n",(int)vsize);
	printf("Stride:%d\n",(int)stride);
	printf("Id    :%d\n",(int)id);
}

void set_rtg_mode()
{
	hpokel(rtg_register_base+REG_ADDRESS,0x2700000);
	hpoke(rtg_register_base+REG_FORMAT,0);
	hpoke(rtg_register_base+REG_ENABLE,1);
	hpoke(rtg_register_base+REG_HSIZE,800);
	hpoke(rtg_register_base+REG_VSIZE,600);
	hpoke(rtg_register_base+REG_STRIDE,800*4);
}

int main(void)
{
    mem_init(1);

/*    speedtest("chipram",chipram_addr,chipram_bytes);
    speedtest("fastram",z3fastram_addr,z3fastram_bytes);
    speedtest("rom",rom_addr_orig,rom_bytes);
    speedtest("rom_copy",rom_addr_fast,rom_bytes);
    speedtest("rtg",rtgcard_addr,rtgcard_bytes);
    speedtest("irq",irqs,4);*/

    dump_rtg_regs();

    set_rtg_mode();

    dump_rtg_regs();

    return 0;
}


