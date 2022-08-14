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
	ADDRESS : IN STD_LOGIC_VECTOR(21 downto 0);
	READ: IN STD_LOGIC;
	READDATA : OUT STD_LOGIC_VECTOR(31 downto 0);
	READDATAVALID : OUT STD_LOGIC;
	WRITE : IN STD_LOGIC;
	WRITEDATA : IN STD_LOGIC_VECTOR(31 downto 0);
	BYTEENABLE : IN STD_LOGIC_VECTOR(3 downto 0);
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
	HYBRIDCPU_LONGWORD : OUT STD_LOGIC; 

	-- expose a slow clock too, aligned with CLK
	HYBRIDCPU_SYNC_CLK : IN STD_LOGIC
);
END arm_avalon;

ARCHITECTURE vhdl OF arm_avalon IS
	signal hps_readvalid_reg : std_logic;
	signal hps_readvalid_next : std_logic;

	signal SYS_STATE_REG : STD_LOGIC_VECTOR(1 downto 0);
	signal SYS_STATE_NEXT : STD_LOGIC_VECTOR(1 downto 0);
	constant SYS_STATE_WAIT_REQUEST : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant SYS_STATE_WAIT_COMPLETE : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant SYS_STATE_WAIT_COMPLETE1 : STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant SYS_STATE_WAIT_COMPLETE2 : STD_LOGIC_VECTOR(1 downto 0) := "11";

	signal active_word : std_logic;
	signal read_word : std_logic_vector(1 downto 0);

	signal to_hps_read : std_logic;
	signal to_hps_empty : std_logic;
	signal to_hps_write : std_logic;

	signal to_hps_readdata : std_logic_vector(31 downto 0);
	signal to_hps_readdata_next : std_logic_vector(31 downto 0);
	signal to_hps_readdata_reg : std_logic_vector(31 downto 0);

	signal from_hps_readack : std_logic;
	signal from_hps_empty : std_logic;
	signal from_hps_write : std_logic;
	signal from_hps_read : std_logic;
	signal from_hps_byteenable : std_logic_vector(3 downto 0);
	signal from_hps_writedata : std_logic_vector(31 downto 0);
	signal from_hps_writereq : std_logic;
	signal from_hps_full : std_logic;

	COMPONENT fifo_from_hps IS
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (59 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (59 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	END COMPONENT;

	COMPONENT fifo_to_hps IS
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	END COMPONENT;

BEGIN
	to_hps : fifo_to_hps
	port map
	(
		rdclk=>clk,
		rdreq=>to_hps_read,
		rdempty=>to_hps_empty,
		q=>READDATA,

		wrclk=>hybridcpu_sync_clk,
		data =>to_hps_readdata,
		wrreq=>to_hps_write,
		wrfull=>open
	);

	from_hps : fifo_from_hps
	port map
	(
		rdclk=>hybridcpu_sync_clk,
		rdreq=>from_hps_readack,
		rdempty=>from_hps_empty,
		q(59)=>from_hps_write,
		q(58)=>from_hps_read,
		q(57 downto 54)=>from_hps_byteenable,
		q(53 downto 32)=>HYBRIDCPU_ADDRESS(22 downto 1), -- 0 needs setting...
		q(31 downto 0)=>from_hps_writedata,

		wrclk=>clk,
		data(59) => WRITE,
		data(58) => READ, 
		data(57 downto 54) => BYTEENABLE, 
		data(53 downto 32) => ADDRESS, 
		data(31 downto 0) => WRITEDATA, 

		wrreq=>from_hps_writereq,
		wrfull=>from_hps_full
	);

	-------------------
	-- HPS side
	process(clk,reset_n)
	begin
		if (reset_n='0') then
			hps_readvalid_reg <= '0';
		elsif (clk'event and clk='1') then
			hps_readvalid_reg <= hps_readvalid_next;
		end if;
	end process;

	process(hps_readvalid_reg, from_hps_full, to_hps_empty, READ, WRITE) is
	begin
		hps_readvalid_next <= hps_readvalid_reg;
		waitrequest <= from_hps_full;

		READDATAVALID <= hps_readvalid_reg;

		from_hps_writereq <= '0';
		to_hps_read <= '0';

		from_hps_writereq <= READ or WRITE;

		hps_readvalid_next <= not(to_hps_empty);
		to_hps_read<=not(to_hps_empty);
	end process;

	-------------------
	-- sys side
	process(HYBRIDCPU_SYNC_CLK,reset_n)
	begin
		if (reset_n='0') then
			sys_state_reg <= SYS_STATE_WAIT_REQUEST;
			to_hps_readdata_reg <= (others=>'0');
		elsif (HYBRIDCPU_SYNC_CLK'event and HYBRIDCPU_SYNC_CLK='1') then
			sys_state_reg <= sys_state_next;
			to_hps_readdata_reg <= TO_HPS_READDATA_NEXT;
		end if;
	end process;

	---- I need to handle reads and populate these
	--to_hps_readdata, --DONE
	--to_hps_write, -- DONE

	---- I need to handle these
	--from_hps_readack, -- DONE
	--from_hps_empty, -- DONE
	--from_hps_byteenable, --DONE
	--from_hps_writedata, -- DONE

	---- I need to send this to minimig
	--HYBRIDCPU_ADDRESS(0), -- DONE -- 0 needs setting...
	--HYBRIDCPU_BYTEENABLE -- DONE
	--HYBRIDCPU_REQUEST --DONE
	--HYBRIDCPU_WRITEDATA -- DONE
	--HYBRIDCPU_LONGWORD --DONE

	---- + this from minimig
	--HYBRIDCPU_COMPLETE; --DONE
	--HYBRIDCPU_READDATA --DONE


	HYBRIDCPU_WRITE <= from_hps_write;
	HYBRIDCPU_READ <= from_hps_read;

	process(sys_state_reg,
		from_hps_byteenable, from_hps_read, from_hps_empty,
		HYBRIDCPU_COMPLETE
		) is
		variable word : std_logic_vector(1 downto 0);
		variable longword : std_logic;
	begin
		sys_state_next <= sys_state_reg;

		word(0) := from_hps_byteenable(0) or from_hps_byteenable(1);
		word(1) := from_hps_byteenable(2) or from_hps_byteenable(3);

		case word is
		when "01" => 
			active_word <= '0';
			read_word <= "11";
			longword:='0';
		when "10" => 
			active_word <= '1';
			read_word <= "11";
			longword:='0';
		when others => 
			active_word <= '0';
			read_word <= "01";
			longword:='1';
		end case;

		from_hps_readack<='0';
		to_hps_write<='0';

		HYBRIDCPU_LONGWORD <= '0'; 
		HYBRIDCPU_REQUEST <= '0'; 

		case sys_state_reg is
			when SYS_STATE_WAIT_REQUEST =>
				if (from_hps_empty='0') then
					HYBRIDCPU_REQUEST <= '1'; 
					HYBRIDCPU_LONGWORD <= longword;
					if (HYBRIDCPU_COMPLETE='1') then
						to_hps_write<=from_hps_read and not(longword);
						sys_state_next <= SYS_STATE_WAIT_REQUEST;
						if (longword='1') then
							sys_state_next <= SYS_STATE_WAIT_COMPLETE2;
						else
							from_hps_readack<='1';
						end if;
					else
						if (longword='0') then
							sys_state_next <= SYS_STATE_WAIT_COMPLETE;
						else
							sys_state_next <= SYS_STATE_WAIT_COMPLETE1;
						end if;
					end if;
				end if;
			when SYS_STATE_WAIT_COMPLETE =>
				HYBRIDCPU_REQUEST <= '1'; 
				if (HYBRIDCPU_COMPLETE='1') then
					to_hps_write<=from_hps_read;
					sys_state_next <= SYS_STATE_WAIT_REQUEST;
					from_hps_readack<='1';
				end if;
			when SYS_STATE_WAIT_COMPLETE1 =>
				HYBRIDCPU_REQUEST <= '1'; 
				HYBRIDCPU_LONGWORD <= '1'; 
				if (HYBRIDCPU_COMPLETE='1') then
					sys_state_next <= SYS_STATE_WAIT_COMPLETE2;
				end if;
			when SYS_STATE_WAIT_COMPLETE2 =>
				HYBRIDCPU_REQUEST <= '1'; 
				read_word <= "10";
				active_word <= '1';
				if (HYBRIDCPU_COMPLETE='1') then
					to_hps_write<=from_hps_read;
					sys_state_next <= SYS_STATE_WAIT_REQUEST;
					from_hps_readack<='1';
				end if;

			when others =>
				sys_state_next <= SYS_STATE_WAIT_REQUEST;
		end case;
	end process;

	process(active_word,ADDRESS)
	begin
		HYBRIDCPU_ADDRESS(0) <= active_word;
	end process;

	process(active_word,from_hps_writedata,from_hps_byteenable)
	begin
		if active_word='0' then
			HYBRIDCPU_WRITEDATA <= from_hps_writedata(15 downto 0);
			HYBRIDCPU_BYTEENABLE <= from_hps_byteenable(1 downto 0);
		else
			HYBRIDCPU_WRITEDATA <= from_hps_writedata(31 downto 16);
			HYBRIDCPU_BYTEENABLE <= from_hps_byteenable(3 downto 2);
		end if;
	end process;

	process(read_word,HYBRIDCPU_READDATA,TO_HPS_READDATA_REG)
	begin
		TO_HPS_READDATA_NEXT <= TO_HPS_READDATA_REG;

		if read_word(0)='1' then
			TO_HPS_READDATA_NEXT(15 downto 0) <= HYBRIDCPU_READDATA;
		end if;
		if read_word(1)='1' then
			TO_HPS_READDATA_NEXT(31 downto 16) <= HYBRIDCPU_READDATA;
		end if;
	end process;
	to_hps_readdata <= TO_HPS_READDATA_NEXT;

END vhdl;
