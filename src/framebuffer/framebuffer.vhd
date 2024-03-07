----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 15:28:22
-- Design Name: 
-- Module Name: axi4lite_counter - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi4lite_framebuffer is
	port(
		s_axi_aclk: in std_logic;
		s_axi_aresetn: in std_logic;
		-- AXI4-Lite Write interface
		s_axi_awaddr : in std_logic_vector(31 downto 0);
		s_axi_awvalid : in std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata : in std_logic_vector(31 downto 0);
		s_axi_wstrb : in std_logic_vector(3 downto 0);
		s_axi_wvalid : in std_logic;
		s_axi_wready : out std_logic;
		s_axi_bresp : out std_logic_vector(1 downto 0);
		s_axi_bvalid : out std_logic;
		s_axi_bready : in std_logic;
		-- AXI4-Lite Read interface
		s_axi_araddr : in std_logic_vector(31 downto 0);
		s_axi_arvalid : in std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata : out std_logic_vector(31 downto 0);
		s_axi_rresp : out std_logic_vector(1 downto 0);
		s_axi_rvalid : out std_logic;
		s_axi_rready : in std_logic;

		-- Channels RAM Output for video generator
		ch_enb			: in std_logic_vector(3 downto 0);
		-- Channel 0
		ch0_addrb		: in  std_logic_vector(10 downto 0);
		ch0_dob			: out std_logic_vector(10 downto 0);
		-- Channel 0
		ch1_addrb		: in  std_logic_vector(10 downto 0);
		ch1_dob			: out std_logic_vector(10 downto 0);
		-- Channel 0
		ch2_addrb		: in  std_logic_vector(10 downto 0);
		ch2_dob			: out std_logic_vector(10 downto 0);
		-- Channel 0
		ch3_addrb		: in  std_logic_vector(10 downto 0);
		ch3_dob			: out std_logic_vector(10 downto 0)
	);
end axi4lite_framebuffer;

architecture Behavioral of axi4lite_framebuffer is

	component axi4lite_if
	  generic (
		C_DATA_WIDTH : integer;
		C_ADDR_WIDTH : integer
	  );
	  port (
		s_axi_aclk : in std_logic;
		s_axi_aresetn : in std_logic;
		-- AXI4-Lite Write interface
		s_axi_awaddr : in std_logic_vector(31 downto 0);
		s_axi_awvalid : in std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata : in std_logic_vector(31 downto 0);
		s_axi_wstrb : in std_logic_vector(3 downto 0);
		s_axi_wvalid : in std_logic;
		s_axi_wready : out std_logic;
		s_axi_bresp : out std_logic_vector(1 downto 0);
		s_axi_bvalid : out std_logic;
		s_axi_bready : in std_logic;
		-- AXI4-Lite Read interface
		s_axi_araddr : in std_logic_vector(31 downto 0);
		s_axi_arvalid : in std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata : out std_logic_vector(31 downto 0);
		s_axi_rresp : out std_logic_vector(1 downto 0);
		s_axi_rvalid : out std_logic;
		s_axi_rready : in std_logic;
		-- Write register interface
		wr_valid_o : out std_logic;
		wr_addr_o : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		wr_data_o : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
		-- Read register interface
		rd_valid_o : out std_logic;
		rd_addr_o : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		rd_data_i : in std_logic_vector((C_DATA_WIDTH - 1) downto 0)
	  );
	end component;

	component framebuffer_regs
		generic (
			C_DATA_WIDTH : integer;
			C_ADDR_WIDTH : integer;
			C_CH_DATA_WIDTH : integer;
			C_CH_ADDR_WIDTH : integer
		);
		port (
			aclk 		: in std_logic;
			rst_n 		: in std_logic;
			wr_valid_i 	: in std_logic;
			wr_addr_i 	: in std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
			wr_data_i 	: in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
			ch_enb 		: in std_logic_vector(3 downto 0);
			ch0_addrb 	: in std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
			ch0_dob 	: in std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
			ch1_addrb 	: in std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
			ch1_dob 	: in std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
			ch2_addrb 	: in std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
			ch2_dob 	: in std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
			ch3_addrb 	: in std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
			ch3_dob 	: in std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0)
		);
	end component;

	constant C_DATA_WIDTH: integer := 32;
	constant C_ADDR_WIDTH: integer := 13;
	constant C_CH_DATA_WIDTH: integer := 11;
	constant C_CH_ADDR_WIDTH: integer := 11;
	
	signal wr_valid_s: std_logic;
	signal wr_addr_s: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	signal wr_data_s: std_logic_vector(C_DATA_WIDTH-1 downto 0);
	-- signal rd_valid_s: std_logic;
	-- signal rd_addr_s: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
	-- signal rd_data_s: std_logic_vector(C_DATA_WIDTH-1 downto 0);
	
begin
	axi4lite_if_inst : entity work.axi4lite_if
	generic map (
		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH
	)
	port map (
		s_axi_aclk => s_axi_aclk,
		s_axi_aresetn => s_axi_aresetn,
		s_axi_awaddr => s_axi_awaddr,
		s_axi_awvalid => s_axi_awvalid,
		s_axi_awready => s_axi_awready,
		s_axi_wdata => s_axi_wdata,
		s_axi_wstrb => s_axi_wstrb,
		s_axi_wvalid => s_axi_wvalid,
		s_axi_wready => s_axi_wready,
		s_axi_bresp => s_axi_bresp,
		s_axi_bvalid => s_axi_bvalid,
		s_axi_bready => s_axi_bready,
		s_axi_araddr => s_axi_araddr,
		s_axi_arvalid => s_axi_arvalid,
		s_axi_arready => s_axi_arready,
		s_axi_rdata => s_axi_rdata,
		s_axi_rresp => s_axi_rresp,
		s_axi_rvalid => s_axi_rvalid,
		s_axi_rready => s_axi_rready,
		wr_valid_o => wr_valid_s,
		wr_addr_o => wr_addr_s,
		wr_data_o => wr_data_s,
		-- rd_valid_o => rd_valid_s,
		-- rd_addr_o => rd_addr_s,
		rd_data_i => (others => '0')
	);
	
	framebuffer_regs_inst : entity work.framebuffer_regs
	generic map (
		C_DATA_WIDTH => C_DATA_WIDTH,
		C_ADDR_WIDTH => C_ADDR_WIDTH,
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH
	)
	port map (
		aclk => s_axi_aclk,
		rst_n => s_axi_aresetn,
		wr_valid_i => wr_valid_s,
		wr_addr_i => wr_addr_s,
		wr_data_i => wr_data_s,
		-- Channels
		ch_enb => ch_enb,
		ch0_addrb => ch0_addrb,
		ch0_dob => ch0_dob,
		ch1_addrb => ch1_addrb,
		ch1_dob => ch1_dob,
		ch2_addrb => ch2_addrb,
		ch2_dob => ch2_dob,
		ch3_addrb => ch3_addrb,
		ch3_dob => ch3_dob
	);
  


end Behavioral;
