----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 14:35:44
-- Design Name: 
-- Module Name: uart_regs_tb - testbench
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

-- library std;
-- use std.env.finish;

-- entity uart_regs_tb is
-- end uart_regs_tb;

-- architecture testbench of uart_regs_tb is

-- 	component uart_regs is
-- 		generic (
-- 			C_ADDR_WIDTH: integer := 32;
-- 			C_DATA_WIDTH: integer := 32
-- 		);
-- 		port ( 
-- 			clk_i: 	in std_logic;
-- 			rst_n: in std_logic;
			
-- 			-- AXI4 Lite Write interface
-- 			wr_valid_i: in std_logic;
-- 			wr_addr_i: in std_logic_vector(C_ADDR_WIDTH-1 downto 0);
-- 			wr_data_i: in std_logic_vector(C_DATA_WIDTH-1 downto 0);
			
-- 			-- AXI4 Lite Read interface
-- 			rd_valid_i: in std_logic;
-- 			rd_addr_i: 	in std_logic_vector(C_ADDR_WIDTH-1 downto 0);
-- 			rd_data_o: 	out std_logic_vector(C_DATA_WIDTH-1 downto 0);
			
-- 			-- UART TX Interface
-- 			tx_valid_o: out std_logic;
-- 			tx_data_o: out std_logic_vector(7 downto 0);
-- 			tx_busy_i: in std_logic;
			
-- 			-- UART RX Interface
-- 			rx_valid_i: in std_logic;
-- 			rx_data_i: in std_logic_vector(7 downto 0)
-- 		);
-- 	end component;

-- 	constant C_ADDR_WIDTH: integer := 32;
-- 	constant C_DATA_WIDTH: integer := 32;
-- 	constant CR_BASEADDR  : integer := 0; -- Control Register
-- 	constant SR_BASEADDR  : integer := 4; -- Status Register
-- 	constant TDR_BASEADDR : integer := 8; -- Transmit Data Register


-- 	constant clk_period: time := 10ns;

-- 	signal clk_i: std_logic := '1';
-- 	signal rst_n: std_logic := '1';
	
-- 	-- AXI4 Lite Write interface
-- 	signal wr_valid_i: std_logic := '0';
-- 	signal wr_addr_i: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
-- 	signal wr_data_i: std_logic_vector(C_DATA_WIDTH-1 downto 0);
	
-- 	-- AXI4 Lite Read interface
-- 	signal rd_valid_i: std_logic := '0';
-- 	signal rd_addr_i: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
-- 	signal rd_data_o: std_logic_vector(C_DATA_WIDTH-1 downto 0);
	
-- 	-- UART TX Interface
-- 	signal tx_valid_o: std_logic := '0';
-- 	signal tx_data_o: std_logic_vector(7 downto 0);
-- 	signal tx_busy_i: std_logic := '0';
	
-- 	-- UART RX Interface
-- 	signal rx_valid_i: std_logic := '0';
-- 	signal rx_data_i: std_logic_vector(7 downto 0);

	

-- begin

-- 	dut: uart_regs
-- 	port map(
-- 		clk_i => clk_i,
-- 		rst_n => rst_n,
		
-- 		wr_valid_i => wr_valid_i,
-- 		wr_addr_i => wr_addr_i,
-- 		wr_data_i => wr_data_i,
		
-- 		rd_valid_i => rd_valid_i,
-- 		rd_addr_i => rd_addr_i,
-- 		rd_data_o => rd_data_o,
		
-- 		tx_valid_o => tx_valid_o,
-- 		tx_data_o => tx_data_o,
-- 		tx_busy_i => tx_busy_i,
		
-- 		rx_valid_i => rx_valid_i,
-- 		rx_data_i => rx_data_i
-- 	);

-- 	clk_i <= not clk_i after clk_period/2;
	
-- 	reset_proc: process
-- 	begin
-- 		rst_n <= '0';
-- 		wait for clk_period * 5;
-- 		rst_n <= '1';
		
-- 		wait;
-- 	end process;
	
-- 	stimuli_proc: process
-- 	begin
-- 		wait until rst_n = '1';
		
-- 		wr_addr_i <= std_logic_vector(to_unsigned(TDR_BASEADDR, 32));
-- 		wr_data_i <= x"000000A5";
-- 		wait for clk_period;
-- 		wr_valid_i <= '1';
		
-- 		wait for clk_period;
-- 		wr_addr_i <= std_logic_vector(to_unsigned(CR_BASEADDR, 32));
-- 		wr_data_i <= x"00000001";
-- 		wait for clk_period;
-- 		wr_valid_i <= '1';
-- 		wait for clk_period;
-- 		wr_valid_i <= '0';
		
-- 		wait for clk_period;
-- 		tx_busy_i <= '1';
		
-- 		wait for clk_period * 100;
-- 		tx_busy_i <= '0';
		
		
-- 		wait;
-- 	end process;
	
-- 	check_proc: process
-- 	begin
-- 		wait until tx_valid_o = '1';
-- 		assert tx_data_o = x"A5" report "Wrong tx_data received" severity failure;
		
-- 		wait for clk_period;
-- 		rd_addr_i <= std_logic_vector(to_unsigned(SR_BASEADDR, 32));
-- 		wait for clk_period;
-- 		rd_valid_i <= '1';
-- 		wait for clk_period;
-- 		assert rd_data_o = x"00000000" report "Status Register wrong" severity failure;
-- 		rd_valid_i <= '0';
-- 		wait for clk_period * 110;
-- 		rd_valid_i <= '1';
-- 		wait for clk_period*2;
-- 		assert rd_data_o = x"00000001" report "Status Register wrong" severity failure;
		
-- 		report "Test Done" severity note;
-- 		finish;
-- 	end process;

-- end testbench;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.env.finish;

entity tb_framebuffer_regs is
end;

architecture bench of tb_framebuffer_regs is
	-- Clock period
	constant clk_period : time := 10 ns;
	constant clk_period2 : time := 5 ns;
	-- Generics
	constant C_DATA_WIDTH : integer := 32;
	constant C_ADDR_WIDTH : integer := 17;
	constant C_CH_DATA_WIDTH : integer := 11;
	constant C_CH_ADDR_WIDTH : integer := 11;

	constant CH0_BASEADDR : integer :=    0; -- Channel 1 Data Register
	constant CH1_BASEADDR : integer := 2048; -- Channel 2 Data Register
	constant CH2_BASEADDR : integer := 4096; -- Channel 3 Data Register
	constant CH3_BASEADDR : integer := 6144; -- Channel 4 Data Register
	constant ASSETS_BASEADDR : integer := 8192; -- Assets Data Register
	-- Ports
	signal aclk : std_logic := '1';
	signal pxlclk : std_logic := '1';
	signal rst_n : std_logic;
	signal wr_valid_i : std_logic;
	signal wr_addr_i : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
	signal wr_data_i : std_logic_vector((C_DATA_WIDTH - 1) downto 0);
	signal ch_enb : std_logic_vector(3 downto 0);
	signal ch0_addrb : std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal ch0_dob : std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
	signal ch1_addrb : std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal ch1_dob : std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
	signal ch2_addrb : std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal ch2_dob : std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
	signal ch3_addrb : std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal ch3_dob : std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
	signal assets_enb: std_logic;
	signal assets_addrb: std_logic_vector((14 - 1) downto 0);
	signal assets_dob: std_logic_vector((1 - 1) downto 0);
begin

	framebuffer_regs_inst : entity work.framebuffer_regs
	generic map (
		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH,
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH,
		c_ASSETS_DATA_WIDTH => 1,
		c_ASSETS_ADDR_WIDTH => 14
	)
	port map (
		aclk => aclk,
		pxlclk => pxlclk,
		rst_n => rst_n,
		wr_valid_i => wr_valid_i,
		wr_addr_i => wr_addr_i,
		wr_data_i => wr_data_i,
		-- Channels
		ch_enb => ch_enb,
		assets_enb => assets_enb,
		ch0_addrb => ch0_addrb,
		ch0_dob => ch0_dob,
		ch1_addrb => ch1_addrb,
		ch1_dob => ch1_dob,
		ch2_addrb => ch2_addrb,
		ch2_dob => ch2_dob,
		ch3_addrb => ch3_addrb,
		ch3_dob => ch3_dob,
		assets_addrb => assets_addrb,
		assets_dob => assets_dob
	);

	aclk <= not aclk after clk_period/2;
	pxlclk <= not pxlclk after clk_period2/2;

	reset_proc: process
	begin
		rst_n <= '0';
		wait for clk_period * 5;
		rst_n <= '1';
		
		wait;
	end process;
	
	stimuli_proc: process
	begin
		wait until rst_n = '1';
		
		wr_addr_i <= std_logic_vector(to_unsigned(CH0_BASEADDR, C_ADDR_WIDTH));
		wr_data_i <= x"00000005";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';
		
		wait for clk_period * 5;
		
		wr_addr_i <= std_logic_vector(to_unsigned(CH0_BASEADDR + 4, C_ADDR_WIDTH));
		wr_data_i <= x"00000001";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';


		wait for clk_period * 10;


		wr_addr_i <= std_logic_vector(to_unsigned(CH1_BASEADDR*4, C_ADDR_WIDTH));
		wr_data_i <= x"00000002";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';
		
		
		wait for clk_period * 5;
		
		
		wr_addr_i <= std_logic_vector(to_unsigned(CH1_BASEADDR*4 + 4, C_ADDR_WIDTH));
		wr_data_i <= x"00000003";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';

	
		wait for clk_period * 5;
		
		
		wr_addr_i <= std_logic_vector(to_unsigned(ASSETS_BASEADDR*4, C_ADDR_WIDTH));
		wr_data_i <= x"00000000";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';

		wait for clk_period * 5;
		
		
		wr_addr_i <= std_logic_vector(to_unsigned(ASSETS_BASEADDR*4 + 4, C_ADDR_WIDTH));
		wr_data_i <= x"00000001";
		wait for clk_period;
		wr_valid_i <= '1';
		wait for clk_period;
		wr_valid_i <= '0';

		wr_addr_i <= (others => '1');


		wait;
	end process;


	check_proc: process
	begin
		wait until rst_n = '1';

		ch_enb <= "1111";
		assets_enb <= '1';
		wait for clk_period * 100;

		-- Channel 0
		ch0_addrb <= std_logic_vector(to_unsigned(0, 11));
		wait for clk_period;
		assert ch0_dob = std_logic_vector(to_unsigned(5, 11)) report "ch0 addr 0, wrong data" severity failure;

		wait for clk_period * 5;

		ch0_addrb <= std_logic_vector(to_unsigned(1, 11));
		wait for clk_period;
		assert ch0_dob = std_logic_vector(to_unsigned(1, 11)) report "ch0 addr 1, wrong data" severity failure;
		
			
		wait for clk_period * 5;

		-- Channel 1
		ch1_addrb <= std_logic_vector(to_unsigned(0, 11));
		wait for clk_period;
		assert ch1_dob = std_logic_vector(to_unsigned(2, 11)) report "ch1 addr 0, wrong data" severity failure;
		
			
		wait for clk_period * 5;

		ch1_addrb <= std_logic_vector(to_unsigned(1, 11));
		wait for clk_period;
		assert ch1_dob = std_logic_vector(to_unsigned(3, 11)) report "ch1 addr 1, wrong data" severity failure;
				
			
		wait for clk_period * 5;

		-- ASSETS
		assets_addrb <= std_logic_vector(to_unsigned(0, 14));
		wait for clk_period;
		assert assets_dob = std_logic_vector(to_unsigned(0, 1)) report "assets addr 0, wrong data" severity failure;
		
			
		wait for clk_period * 5;

		assets_addrb <= std_logic_vector(to_unsigned(1, 14));
		wait for clk_period;
		assert assets_dob = std_logic_vector(to_unsigned(1, 1)) report "assets addr 1, wrong data" severity failure;
		
		report "--- Test Done ---";
		finish;
	end process;

end;