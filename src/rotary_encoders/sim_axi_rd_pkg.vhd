----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: hepia
-- Author: Laurent Gantel <laurent.gantel@hesge.ch>
--
-- Module Name: sim_axi_rd_pkg - arch
-- Target Device: digilentinc.com:basys3:part0:1.1 xc7a35tcpg236-1
-- Tool version: 2023.1
-- Description: UART package
--
-- Last update: 2023-12-19
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library sim_axi;

package sim_axi_rd_pkg is

  ---------------------------------------------------------------------------------
  -- Constants
  ---------------------------------------------------------------------------------

  constant SIM_AXI_RD_CLK_PERIOD : time := 10 ns;

  ---------------------------------------------------------------------------------
  -- Types
  ---------------------------------------------------------------------------------

  -- AXI4-Lite Read channels inputs
  type axi4lite_rd_bus_in is record
    -- Address channel
    arready : std_logic;
    -- Data channel
    rvalid  : std_logic;
    rdata   : std_logic_vector(31 downto 0);
    rresp   : std_logic_vector(1 downto 0);
  end record axi4lite_rd_bus_in;

  -- AXI4-Lite Read channels outputs
  type axi4lite_rd_bus_out is record
    -- Address channel
    arvalid : std_logic;
    araddr  : std_logic_vector(31 downto 0);
    -- Data channel
    rready  : std_logic;
  end record axi4lite_rd_bus_out;

  ---------------------------------------------------------------------------------
  -- Functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Procedures
  ---------------------------------------------------------------------------------

  -- Read from AXI4-Lite interface
  procedure axi4lite_read (
    constant rd_addr : in  integer;
    signal rd_data   : out std_logic_vector(31 downto 0);
    -- AXI4-Lite interface
    signal s_axi_i   : in  axi4lite_rd_bus_in;
    signal s_axi_o   : out axi4lite_rd_bus_out
    );

end sim_axi_rd_pkg;


package body sim_axi_rd_pkg is

  ---------------------------------------------------------------------------------
  -- Internal functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Procedures
  ---------------------------------------------------------------------------------

  -- Read from AXI4-Lite interface
  procedure axi4lite_read (
    constant rd_addr : in  integer;
    signal rd_data   : out std_logic_vector(31 downto 0);
    -- AXI4-Lite interface
    signal s_axi_i   : in  axi4lite_rd_bus_in;
    signal s_axi_o   : out axi4lite_rd_bus_out
    ) is
  begin
    -- Set the address
    s_axi_o.arvalid <= '1';
    s_axi_o.araddr  <= std_logic_vector(to_unsigned(rd_addr, 32));
    if s_axi_i.arready = '0' then
      wait until s_axi_i.arready = '1';
    end if;
    wait for SIM_AXI_RD_CLK_PERIOD;
    s_axi_o.arvalid <= '0';
    s_axi_o.araddr  <= (others => '0');

    -- Get the data
    if s_axi_i.rvalid = '0' then
      wait until s_axi_i.rvalid = '1';
    end if;
    wait for SIM_AXI_RD_CLK_PERIOD;
    s_axi_o.rready <= '1';
    rd_data        <= s_axi_i.rdata;
    wait for SIM_AXI_RD_CLK_PERIOD;
    s_axi_o.rready <= '0';
    wait for SIM_AXI_RD_CLK_PERIOD;
  end procedure axi4lite_read;

end package body sim_axi_rd_pkg;
