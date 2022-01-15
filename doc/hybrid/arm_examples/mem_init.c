#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <stdlib.h>

int chipram_bytes;
void * chipram_addr;

int z3fastram_bytes;
unsigned int z3fast_physical;
void * z3fastram_addr;

int rtgcard_bytes;
void * rtgcard_addr;

int hardware_bytes;
void * hardware_addr;

int rom_bytes;
void * rom_addr_orig;
void * rom_addr_fast;
void * irqs;

void mem_init(int copy_rom)
{
    unsigned int hpsbridgeaddr = 0xc0000000;
    int fduncached = open("/dev/mem",(O_RDWR|O_SYNC));
    int fdcached = open("/sys/kernel/debug/minimig_irq/mmap_cached",(O_RDWR));

    chipram_bytes = 2*1024*1024;
    chipram_addr = mmap(NULL,chipram_bytes,(PROT_READ|PROT_WRITE),MAP_SHARED,fduncached,hpsbridgeaddr+0); //cached?

    z3fastram_bytes = 384*1024*1024;
    unsigned int z3fast_physical = 0x28000000; // physical ddr address, shared with f2h bridge
    z3fastram_addr = mmap(NULL,z3fastram_bytes,(PROT_READ|PROT_WRITE),MAP_SHARED,fdcached,z3fast_physical);

    rtgcard_bytes = 16*1024*1024;
    unsigned int rtg_physical = 0x27000000; // physical ddr address, shared with f2h bridge
    rtgcard_addr = mmap(NULL,rtgcard_bytes,(PROT_READ|PROT_WRITE),MAP_SHARED,fdcached,rtg_physical);

    hardware_bytes =  13*1024*1024;
    hardware_addr = mmap(NULL,hardware_bytes,(PROT_READ|PROT_WRITE),MAP_SHARED,fduncached,hpsbridgeaddr + 0x200000);

    rom_bytes = 1*1024*1024;
    rom_addr_orig = mmap(NULL,rom_bytes,(PROT_READ|PROT_WRITE),MAP_SHARED,fdcached,hpsbridgeaddr+0xf00000);
    rom_addr_fast = malloc(rom_bytes);
    if (copy_rom)
    {
	for (int i=0;i!=rom_bytes;i+=4)
	{
		    *((unsigned int *)(rom_addr_fast+i)) = *((unsigned int *)(rom_addr_orig+i));
    	}
    }
    unsigned int irqoffset = 0x1000000;

    irqs = mmap(NULL,1,(PROT_READ|PROT_WRITE),MAP_SHARED,fduncached,hpsbridgeaddr+irqoffset); //cached?

    printf("chipram:%p fastram:%p rtg:%p hardware:%p rom:%p irqs:%p\n",chipram_addr,z3fastram_addr,rtgcard_addr,hardware_addr,rom_addr_orig,irqs);
}


