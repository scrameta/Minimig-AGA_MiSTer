	component hps_fpga_bridge is
		port (
			avalonirq_avalon_irq_n       : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- avalon_irq_n
			avalonirq_avalon_sync_clk    : in    std_logic                     := 'X';             -- avalon_sync_clk
			avalonirq_avalon_reset_n     : in    std_logic                     := 'X';             -- avalon_reset_n
			avalonregs_avalon_cacr       : out   std_logic_vector(3 downto 0);                     -- avalon_cacr
			avalonregs_avalon_sync_clk   : in    std_logic                     := 'X';             -- avalon_sync_clk
			avalonregs_avalon_vbr        : out   std_logic_vector(31 downto 0);                    -- avalon_vbr
			clk_clk                      : in    std_logic                     := 'X';             -- clk
			memory_mem_a                 : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n              : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke               : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n              : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n             : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n             : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n              : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n           : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs               : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n             : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt               : out   std_logic;                                        -- mem_odt
			memory_mem_dm                : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin             : in    std_logic                     := 'X';             -- oct_rzqin
			avalon1_hybridcpu_address    : out   std_logic_vector(22 downto 0);                    -- hybridcpu_address
			avalon1_hybridcpu_byteenable : out   std_logic_vector(1 downto 0);                     -- hybridcpu_byteenable
			avalon1_hybridcpu_complete   : in    std_logic                     := 'X';             -- hybridcpu_complete
			avalon1_hybridcpu_read       : out   std_logic;                                        -- hybridcpu_read
			avalon1_hybridcpu_readdata   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- hybridcpu_readdata
			avalon1_hybridcpu_sync_clk   : in    std_logic                     := 'X';             -- hybridcpu_sync_clk
			avalon1_hybridcpu_write      : out   std_logic;                                        -- hybridcpu_write
			avalon1_hybridcpu_writedata  : out   std_logic_vector(15 downto 0);                    -- hybridcpu_writedata
			avalon1_hybridcpu_request    : out   std_logic;                                        -- hybridcpu_request
			avalon1_hybridcpu_longword   : out   std_logic                                         -- hybridcpu_longword
		);
	end component hps_fpga_bridge;

	u0 : component hps_fpga_bridge
		port map (
			avalonirq_avalon_irq_n       => CONNECTED_TO_avalonirq_avalon_irq_n,       --  avalonirq.avalon_irq_n
			avalonirq_avalon_sync_clk    => CONNECTED_TO_avalonirq_avalon_sync_clk,    --           .avalon_sync_clk
			avalonirq_avalon_reset_n     => CONNECTED_TO_avalonirq_avalon_reset_n,     --           .avalon_reset_n
			avalonregs_avalon_cacr       => CONNECTED_TO_avalonregs_avalon_cacr,       -- avalonregs.avalon_cacr
			avalonregs_avalon_sync_clk   => CONNECTED_TO_avalonregs_avalon_sync_clk,   --           .avalon_sync_clk
			avalonregs_avalon_vbr        => CONNECTED_TO_avalonregs_avalon_vbr,        --           .avalon_vbr
			clk_clk                      => CONNECTED_TO_clk_clk,                      --        clk.clk
			memory_mem_a                 => CONNECTED_TO_memory_mem_a,                 --     memory.mem_a
			memory_mem_ba                => CONNECTED_TO_memory_mem_ba,                --           .mem_ba
			memory_mem_ck                => CONNECTED_TO_memory_mem_ck,                --           .mem_ck
			memory_mem_ck_n              => CONNECTED_TO_memory_mem_ck_n,              --           .mem_ck_n
			memory_mem_cke               => CONNECTED_TO_memory_mem_cke,               --           .mem_cke
			memory_mem_cs_n              => CONNECTED_TO_memory_mem_cs_n,              --           .mem_cs_n
			memory_mem_ras_n             => CONNECTED_TO_memory_mem_ras_n,             --           .mem_ras_n
			memory_mem_cas_n             => CONNECTED_TO_memory_mem_cas_n,             --           .mem_cas_n
			memory_mem_we_n              => CONNECTED_TO_memory_mem_we_n,              --           .mem_we_n
			memory_mem_reset_n           => CONNECTED_TO_memory_mem_reset_n,           --           .mem_reset_n
			memory_mem_dq                => CONNECTED_TO_memory_mem_dq,                --           .mem_dq
			memory_mem_dqs               => CONNECTED_TO_memory_mem_dqs,               --           .mem_dqs
			memory_mem_dqs_n             => CONNECTED_TO_memory_mem_dqs_n,             --           .mem_dqs_n
			memory_mem_odt               => CONNECTED_TO_memory_mem_odt,               --           .mem_odt
			memory_mem_dm                => CONNECTED_TO_memory_mem_dm,                --           .mem_dm
			memory_oct_rzqin             => CONNECTED_TO_memory_oct_rzqin,             --           .oct_rzqin
			avalon1_hybridcpu_address    => CONNECTED_TO_avalon1_hybridcpu_address,    --    avalon1.hybridcpu_address
			avalon1_hybridcpu_byteenable => CONNECTED_TO_avalon1_hybridcpu_byteenable, --           .hybridcpu_byteenable
			avalon1_hybridcpu_complete   => CONNECTED_TO_avalon1_hybridcpu_complete,   --           .hybridcpu_complete
			avalon1_hybridcpu_read       => CONNECTED_TO_avalon1_hybridcpu_read,       --           .hybridcpu_read
			avalon1_hybridcpu_readdata   => CONNECTED_TO_avalon1_hybridcpu_readdata,   --           .hybridcpu_readdata
			avalon1_hybridcpu_sync_clk   => CONNECTED_TO_avalon1_hybridcpu_sync_clk,   --           .hybridcpu_sync_clk
			avalon1_hybridcpu_write      => CONNECTED_TO_avalon1_hybridcpu_write,      --           .hybridcpu_write
			avalon1_hybridcpu_writedata  => CONNECTED_TO_avalon1_hybridcpu_writedata,  --           .hybridcpu_writedata
			avalon1_hybridcpu_request    => CONNECTED_TO_avalon1_hybridcpu_request,    --           .hybridcpu_request
			avalon1_hybridcpu_longword   => CONNECTED_TO_avalon1_hybridcpu_longword    --           .hybridcpu_longword
		);

