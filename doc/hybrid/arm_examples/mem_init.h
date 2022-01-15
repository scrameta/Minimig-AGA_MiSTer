#pragma once

extern int chipram_bytes;
extern void * chipram_addr;

extern int z3fastram_bytes;
extern unsigned int z3fast_physical;
extern void * z3fastram_addr;

extern int rtgcard_bytes;
extern void * rtgcard_addr;

extern int hardware_bytes;
extern void * hardware_addr;

extern int rom_bytes;
extern void * rom_addr_orig;
extern void * rom_addr_fast;
extern void * irqs;

void mem_init(int copy_rom);

