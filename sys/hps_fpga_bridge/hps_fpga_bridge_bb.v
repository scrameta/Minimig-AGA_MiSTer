
module hps_fpga_bridge (
	avalonirq_avalon_irq_n,
	avalonirq_avalon_sync_clk,
	avalonirq_avalon_reset_n,
	avalonregs_avalon_cacr,
	avalonregs_avalon_sync_clk,
	avalonregs_avalon_vbr,
	clk_clk,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	avalon1_hybridcpu_address,
	avalon1_hybridcpu_byteenable,
	avalon1_hybridcpu_complete,
	avalon1_hybridcpu_read,
	avalon1_hybridcpu_readdata,
	avalon1_hybridcpu_sync_clk,
	avalon1_hybridcpu_write,
	avalon1_hybridcpu_writedata,
	avalon1_hybridcpu_request,
	avalon1_hybridcpu_longword);	

	input	[2:0]	avalonirq_avalon_irq_n;
	input		avalonirq_avalon_sync_clk;
	input		avalonirq_avalon_reset_n;
	output	[3:0]	avalonregs_avalon_cacr;
	input		avalonregs_avalon_sync_clk;
	output	[31:0]	avalonregs_avalon_vbr;
	input		clk_clk;
	output	[14:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[31:0]	memory_mem_dq;
	inout	[3:0]	memory_mem_dqs;
	inout	[3:0]	memory_mem_dqs_n;
	output		memory_mem_odt;
	output	[3:0]	memory_mem_dm;
	input		memory_oct_rzqin;
	output	[22:0]	avalon1_hybridcpu_address;
	output	[1:0]	avalon1_hybridcpu_byteenable;
	input		avalon1_hybridcpu_complete;
	output		avalon1_hybridcpu_read;
	input	[15:0]	avalon1_hybridcpu_readdata;
	input		avalon1_hybridcpu_sync_clk;
	output		avalon1_hybridcpu_write;
	output	[15:0]	avalon1_hybridcpu_writedata;
	output		avalon1_hybridcpu_request;
	output		avalon1_hybridcpu_longword;
endmodule
