---------------------------------------------------------------------------
-- (c) 2021 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_misc.all;

--000000-1FFFFF: Chip ram
--BF0000-BFFFFF: CIAs
--DF0000-DFFFFF: Custom chips
-- i.e. 16MB space, or 8Million 16-bit addresses

-- TODO: address space and data width -> generic

ENTITY arm_avalon IS
PORT 
( 
	CLK : IN STD_LOGIC;
	RESET_N : IN STD_LOGIC;
	
	-- avalon signals
	CHIPSELECT : IN STD_LOGIC;
	ADDRESS : IN STD_LOGIC_VECTOR(22 downto 0);
	READ: IN STD_LOGIC;
	READDATA : OUT STD_LOGIC_VECTOR(15 downto 0);
	WRITE : IN STD_LOGIC;
	WRITEDATA : IN STD_LOGIC_VECTOR(15 downto 0);
	BYTEENABLE : IN STD_LOGIC_VECTOR(1 downto 0);
	WAITREQUEST : OUT STD_LOGIC;
	

	-- talk to cpu wrapper
	HYBRIDCPU_ADDRESS : OUT STD_LOGIC_VECTOR(22 downto 0);
	HYBRIDCPU_READ: OUT STD_LOGIC;
	HYBRIDCPU_READDATA : IN STD_LOGIC_VECTOR(15 downto 0);
	HYBRIDCPU_WRITE : OUT STD_LOGIC;
	HYBRIDCPU_WRITEDATA : OUT STD_LOGIC_VECTOR(15 downto 0);
	HYBRIDCPU_BYTEENABLE : OUT STD_LOGIC_VECTOR(1 downto 0);
	HYBRIDCPU_COMPLETE : IN STD_LOGIC;
	HYBRIDCPU_REQUEST : OUT STD_LOGIC;

	-- expose a slow clock too, aligned with CLK
	HYBRIDCPU_SYNC_CLK : IN STD_LOGIC
);
END arm_avalon;

ARCHITECTURE vhdl OF arm_avalon IS
	signal READDATA_REG : STD_LOGIC_VECTOR(15 downto 0);
	signal COMPLETE_REG : STD_LOGIC;

	signal HYBRIDCPU_REQUEST_NEXT : STD_LOGIC;
	signal HYBRIDCPU_REQUEST_REG : STD_LOGIC;
	signal HYBRIDCPU_ADDRESS_REG : STD_LOGIC_VECTOR(22 downto 0);
	signal HYBRIDCPU_READ_REG: STD_LOGIC;
	signal HYBRIDCPU_READDATA_REG : STD_LOGIC_VECTOR(15 downto 0);
	signal HYBRIDCPU_WRITE_REG : STD_LOGIC;
	signal HYBRIDCPU_WRITEDATA_REG : STD_LOGIC_VECTOR(15 downto 0);
	signal HYBRIDCPU_BYTEENABLE_REG : STD_LOGIC_VECTOR(1 downto 0);

	signal STATE_REG : STD_LOGIC_VECTOR(1 downto 0);
	signal STATE_NEXT : STD_LOGIC_VECTOR(1 downto 0);
	constant STATE_INIT : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant STATE_WAIT_HYBRIDCPU_SEEN : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant STATE_WAIT_HYBRIDCPU_COMPLETE : STD_LOGIC_VECTOR(1 downto 0) := "10";

	signal WATCHDOG_REG : UNSIGNED(15 downto 0);
	signal WATCHDOG_NEXT : UNSIGNED(15 downto 0);
BEGIN
	process(hybridcpu_sync_clk,reset_n)
	begin
		if (reset_n='0') then
			COMPLETE_REG <= '0';
			READDATA_REG <= (others=>'0');
			--IRQ_N <= HYBRIDCPU_IRQ_N;
		
			HYBRIDCPU_REQUEST_REG <= '0';
			HYBRIDCPU_ADDRESS_REG <= (others=>'0');
			HYBRIDCPU_READ_REG <= '0';
			HYBRIDCPU_WRITE_REG <= '0';
			HYBRIDCPU_WRITEDATA_REG <= (others=>'0');
			HYBRIDCPU_BYTEENABLE_REG <= (others=>'0');
		elsif (hybridcpu_sync_clk'event and hybridcpu_sync_clk='1') then
			COMPLETE_REG <= HYBRIDCPU_COMPLETE;
			READDATA_REG <= HYBRIDCPU_READDATA;
			--IRQ_N <= HYBRIDCPU_IRQ_N;
		
			HYBRIDCPU_REQUEST_REG <= HYBRIDCPU_REQUEST_NEXT;
			HYBRIDCPU_ADDRESS_REG <= ADDRESS;
			HYBRIDCPU_READ_REG <= READ;
			HYBRIDCPU_WRITE_REG <= WRITE;
			HYBRIDCPU_WRITEDATA_REG <= WRITEDATA;
			HYBRIDCPU_BYTEENABLE_REG <= BYTEENABLE;
		end if;
	end process;


	process(clk,reset_n)
	begin
		if (reset_n='0') then
			state_reg <= state_init;
			watchdog_reg <= (others=>'0');
		elsif (clk'event and clk='1') then
			state_reg <= state_next;
			watchdog_reg <= watchdog_next;
		end if;
	end process;

	process(state_reg, chipselect, COMPLETE_REG, hybridcpu_request_reg, watchdog_reg) is
	begin
		state_next <= state_reg;
		hybridcpu_request_next <= hybridcpu_request_reg;
		waitrequest <= '0';
		watchdog_next <= watchdog_reg+1;
		case state_reg is
			when STATE_INIT =>
				watchdog_next <= (others=>'0');
				if (CHIPSELECT='1') then
					state_next <= state_wait_hybridcpu_seen;
					hybridcpu_request_next <= '1';
					waitrequest <= '1';
				end if;
			when STATE_WAIT_HYBRIDCPU_SEEN =>
				waitrequest <= '1';
				hybridcpu_request_next <= '1';
				if (hybridcpu_request_reg='1') then
					state_next <= state_wait_hybridcpu_complete;
					hybridcpu_request_next <= '0';
				end if;
			when STATE_WAIT_HYBRIDCPU_COMPLETE =>
				waitrequest <= '1';
				hybridcpu_request_next <= '0';
				if (complete_reg='1' or and_reduce(std_logic_vector(watchdog_reg))='1') then
					waitrequest <= '0';
					state_next <= state_init;
				end if;
			when others =>
				state_next <= state_init;
		end case;
	end process;

	READDATA <= READDATA_REG;

	HYBRIDCPU_REQUEST <= HYBRIDCPU_REQUEST_REG;

	HYBRIDCPU_ADDRESS <= HYBRIDCPU_ADDRESS_REG;
	HYBRIDCPU_READ <= HYBRIDCPU_READ_REG;
	HYBRIDCPU_WRITE <= HYBRIDCPU_WRITE_REG;
	HYBRIDCPU_WRITEDATA <= HYBRIDCPU_WRITEDATA_REG;
	HYBRIDCPU_BYTEENABLE <= HYBRIDCPU_BYTEENABLE_REG;
END vhdl;
