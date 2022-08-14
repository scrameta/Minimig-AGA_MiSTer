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

-- expose 68k cacr and vbr

ENTITY arm_regs_avalon IS
PORT 
( 
	CLK : IN STD_LOGIC;
	RESET_N : IN STD_LOGIC;
	
	-- avalon signals
	WRITE: IN STD_LOGIC;
	ADDRESS : IN STD_LOGIC_VECTOR(0 downto 0); --0=vbr, 1==cache
	WRITEDATA : IN STD_LOGIC_VECTOR(31 downto 0);
	
	-- expose a slow clock too, aligned with CLK
	AVALON_SYNC_CLK : IN STD_LOGIC;
	AVALON_CACR : OUT STD_LOGIC_VECTOR(3 downto 0);
	AVALON_VBR : OUT STD_LOGIC_VECTOR(31 downto 0)
);
END arm_regs_avalon;

ARCHITECTURE vhdl OF arm_regs_avalon IS
	signal AVALON_CACR_NEXT : STD_LOGIC_VECTOR(3 downto 0);
	signal AVALON_VBR_NEXT : STD_LOGIC_VECTOR(31 downto 0);
	signal AVALON_CACR_REG : STD_LOGIC_VECTOR(3 downto 0);
	signal AVALON_VBR_REG : STD_LOGIC_VECTOR(31 downto 0);

	signal AVALON_CACR_SNEXT : STD_LOGIC_VECTOR(3 downto 0);
	signal AVALON_VBR_SNEXT : STD_LOGIC_VECTOR(31 downto 0);
	signal AVALON_CACR_SREG : STD_LOGIC_VECTOR(3 downto 0);
	signal AVALON_VBR_SREG : STD_LOGIC_VECTOR(31 downto 0);
BEGIN
	process(clk,reset_n)
	begin
		if (reset_n='0') then
			AVALON_CACR_REG <= (others=>'0');
			AVALON_VBR_REG <= (others=>'0');
		elsif (clk'event and clk='1') then
			AVALON_VBR_REG <= AVALON_VBR_NEXT;
			AVALON_CACR_REG <= AVALON_CACR_NEXT;
		end if;
	end process;

	process(avalon_sync_clk,reset_n)
	begin
		if (reset_n='0') then
			AVALON_CACR_SREG <= (others=>'0');
			AVALON_VBR_SREG <= (others=>'0');
		elsif (avalon_sync_clk'event and avalon_sync_clk='1') then
			AVALON_VBR_SREG <= AVALON_VBR_REG;
			AVALON_CACR_SREG <= AVALON_CACR_REG;
		end if;
	end process;

	process(write,writedata,address)
	begin
		AVALON_VBR_NEXT <= AVALON_VBR_REG;
		AVALON_CACR_NEXT <= AVALON_CACR_REG;

		if (write='1') then
			case address is
			when "0" =>
				AVALON_VBR_NEXT <= WRITEDATA;
			when "1" =>
				AVALON_CACR_NEXT <= WRITEDATA(3 downto 0);
			when others =>
			end case;
		end if;
	end process;

	AVALON_CACR <= AVALON_CACR_SREG;
	AVALON_VBR <= AVALON_VBR_SREG;
END vhdl;
