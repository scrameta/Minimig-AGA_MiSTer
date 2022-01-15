---------------------------------------------------------------------------
-- (c) 2021 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_misc.all;

-- expose 68k irq for polling for now!

ENTITY arm_irq_avalon IS
PORT 
( 
	CLK : IN STD_LOGIC;
	RESET_N : IN STD_LOGIC;
	
	-- avalon signals
	READ: IN STD_LOGIC;
	READDATA : OUT STD_LOGIC_VECTOR(7 downto 0);
	WAITREQUEST : OUT STD_LOGIC;
	--IRQ_N : OUT STD_LOGIC_VECTOR(2 downto 0);
	
	-- expose a slow clock too, aligned with CLK
	AVALON_SYNC_CLK : IN STD_LOGIC;
	AVALON_IRQ_N : IN STD_LOGIC_VECTOR(2 downto 0);
	AVALON_RESET_N : IN STD_LOGIC
);
END arm_irq_avalon;

ARCHITECTURE vhdl OF arm_irq_avalon IS
	signal AVALON_IRQ_N_REG : STD_LOGIC_VECTOR(2 downto 0);
	signal AVALON_RESET_N_REG : STD_LOGIC;
BEGIN
	process(avalon_sync_clk,reset_n)
	begin
		if (reset_n='0') then
			AVALON_IRQ_N_REG <= (others=>'1');
			AVALON_RESET_N_REG <= '1';
		elsif (avalon_sync_clk'event and avalon_sync_clk='1') then
			AVALON_IRQ_N_REG <= AVALON_IRQ_N;
			AVALON_RESET_N_REG <= AVALON_RESET_N;
		end if;
	end process;
	WAITREQUEST <= '0';
	READDATA <= "0000"&AVALON_RESET_N_REG&AVALON_IRQ_N_REG;
END vhdl;
