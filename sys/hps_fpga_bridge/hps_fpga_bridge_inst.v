	hps_fpga_bridge u0 (
		.avalonirq_avalon_irq_n       (<connected-to-avalonirq_avalon_irq_n>),       //  avalonirq.avalon_irq_n
		.avalonirq_avalon_sync_clk    (<connected-to-avalonirq_avalon_sync_clk>),    //           .avalon_sync_clk
		.avalonirq_avalon_reset_n     (<connected-to-avalonirq_avalon_reset_n>),     //           .avalon_reset_n
		.avalonregs_avalon_cacr       (<connected-to-avalonregs_avalon_cacr>),       // avalonregs.avalon_cacr
		.avalonregs_avalon_sync_clk   (<connected-to-avalonregs_avalon_sync_clk>),   //           .avalon_sync_clk
		.avalonregs_avalon_vbr        (<connected-to-avalonregs_avalon_vbr>),        //           .avalon_vbr
		.clk_clk                      (<connected-to-clk_clk>),                      //        clk.clk
		.memory_mem_a                 (<connected-to-memory_mem_a>),                 //     memory.mem_a
		.memory_mem_ba                (<connected-to-memory_mem_ba>),                //           .mem_ba
		.memory_mem_ck                (<connected-to-memory_mem_ck>),                //           .mem_ck
		.memory_mem_ck_n              (<connected-to-memory_mem_ck_n>),              //           .mem_ck_n
		.memory_mem_cke               (<connected-to-memory_mem_cke>),               //           .mem_cke
		.memory_mem_cs_n              (<connected-to-memory_mem_cs_n>),              //           .mem_cs_n
		.memory_mem_ras_n             (<connected-to-memory_mem_ras_n>),             //           .mem_ras_n
		.memory_mem_cas_n             (<connected-to-memory_mem_cas_n>),             //           .mem_cas_n
		.memory_mem_we_n              (<connected-to-memory_mem_we_n>),              //           .mem_we_n
		.memory_mem_reset_n           (<connected-to-memory_mem_reset_n>),           //           .mem_reset_n
		.memory_mem_dq                (<connected-to-memory_mem_dq>),                //           .mem_dq
		.memory_mem_dqs               (<connected-to-memory_mem_dqs>),               //           .mem_dqs
		.memory_mem_dqs_n             (<connected-to-memory_mem_dqs_n>),             //           .mem_dqs_n
		.memory_mem_odt               (<connected-to-memory_mem_odt>),               //           .mem_odt
		.memory_mem_dm                (<connected-to-memory_mem_dm>),                //           .mem_dm
		.memory_oct_rzqin             (<connected-to-memory_oct_rzqin>),             //           .oct_rzqin
		.avalon1_hybridcpu_address    (<connected-to-avalon1_hybridcpu_address>),    //    avalon1.hybridcpu_address
		.avalon1_hybridcpu_byteenable (<connected-to-avalon1_hybridcpu_byteenable>), //           .hybridcpu_byteenable
		.avalon1_hybridcpu_complete   (<connected-to-avalon1_hybridcpu_complete>),   //           .hybridcpu_complete
		.avalon1_hybridcpu_read       (<connected-to-avalon1_hybridcpu_read>),       //           .hybridcpu_read
		.avalon1_hybridcpu_readdata   (<connected-to-avalon1_hybridcpu_readdata>),   //           .hybridcpu_readdata
		.avalon1_hybridcpu_sync_clk   (<connected-to-avalon1_hybridcpu_sync_clk>),   //           .hybridcpu_sync_clk
		.avalon1_hybridcpu_write      (<connected-to-avalon1_hybridcpu_write>),      //           .hybridcpu_write
		.avalon1_hybridcpu_writedata  (<connected-to-avalon1_hybridcpu_writedata>),  //           .hybridcpu_writedata
		.avalon1_hybridcpu_request    (<connected-to-avalon1_hybridcpu_request>),    //           .hybridcpu_request
		.avalon1_hybridcpu_longword   (<connected-to-avalon1_hybridcpu_longword>)    //           .hybridcpu_longword
	);

