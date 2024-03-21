----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: Hepia // HES-SO
-- Author: Jonas Stirnemann
--
-- Module Name: Rotary Encoder axi4lite
-- Target Device: 
-- Tool version: 2024.1

-- Description: 
-- Rotary encoder sends quadrature signal on A and B:
-- A comes before B : Clockwise rotation
-- B comes before A : Counter Clockwise rotation
-- We can check the rising edge on A signal and check B to determine the rotation

 
-- Output register
-- MSB - LSB
-- [BUTTON], [ROTATE LEFT], [ROTATE RIGHT]
-- 
-- Note : The register part should clear the rotation bits when read 
---------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi4lite_rotary is
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    -- AXI4-Lite Write interface
    s_axi_awaddr  : in  std_logic_vector(31 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    -- AXI4-Lite Read interface
    s_axi_araddr  : in  std_logic_vector(31 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;
    
    -- ROTARY REGS
    o_interrupt : out std_logic;    -- Interrupt
    i_a         : in std_logic;     -- Quadrature A
    i_b         : in std_logic;     -- Quadrature B
    i_button    : in std_logic     -- Rotary encode button

    
    );
end axi4lite_rotary;


architecture Behavioral of axi4lite_rotary is

-----------------------------------------
-- COMMON SIGNALS
-----------------------------------------

constant C_DATA_WIDTH : integer := 32;
constant C_ADDR_WIDTH : integer := 4;

signal wr_valid_s : std_logic;
signal wr_addr_s : std_logic_vector(3 downto 0);
signal wr_data_s : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

signal rd_valid_s : std_logic;
signal rd_addr_s : std_logic_vector(3 downto 0);
signal rd_data_s : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

signal clear_s : std_logic;
signal reg_value_s : std_logic_vector(C_DATA_WIDTH - 1 downto 0);


begin

    -----------------------------------------
    -- ROTARY REGS DIRECT INSTANCITAION
    -----------------------------------------
    rotary_regs_inst : entity work.rotary_regs
    generic map (
        C_DATA_WIDTH => C_DATA_WIDTH,
        C_ADDR_WIDTH => C_ADDR_WIDTH
    )
    port map (
        clk_i => s_axi_aclk,
        resetn => s_axi_aresetn,
        wr_valid_i => wr_valid_s,
        wr_addr_i => wr_addr_s,
        wr_data_i => wr_data_s,
        rd_valid_i => rd_valid_s,
        rd_addr_i => rd_addr_s,
        rd_data_o => rd_data_s, -- NOT SURE
        o_clear => clear_s,     -- NOT SURE
        i_reg_value => reg_value_s -- NOT SURE
    );

    -----------------------------------------
    -- ROTARY ENCODER DIRECT INSTANCITAION
    -----------------------------------------
    rotary_encoder_inst : entity work.rotary_encoder
    port map (
        clk_i => s_axi_aclk,
        resetn => s_axi_aresetn,
        i_a => i_a,
        i_b => i_b,
        i_button => i_button,
        i_clear => clear_s,
        o_interrupt => o_interrupt,
        o_reg_value => reg_value_s
    );



    axi4lite_if_inst : entity work.axi4lite_if
    generic map (
        C_DATA_WIDTH => 32,
        C_ADDR_WIDTH => 4
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
        rd_valid_o => rd_valid_s,
        rd_addr_o => rd_addr_s,
        rd_data_i => rd_data_s
    );



end Behavioral;