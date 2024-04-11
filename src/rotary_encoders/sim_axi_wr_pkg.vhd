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
-- Module Name: sim_axi_wr_pkg - arch
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

package sim_axi_wr_pkg is

  ---------------------------------------------------------------------------------
  -- Constants
  ---------------------------------------------------------------------------------
  constant SIM_AXI_WR_CLK_PERIOD : time := 10 ns;

  ---------------------------------------------------------------------------------
  -- Types
  ---------------------------------------------------------------------------------
  -- AXI4-Lite Write channels inputs
  type axi4lite_wr_bus_in is record
    -- Address channel
    awready : std_logic;
    -- Data channel
    wready  : std_logic;
    -- Response channel
    bvalid  : std_logic;
    bresp   : std_logic_vector(1 downto 0);
  end record axi4lite_wr_bus_in;

  -- AXI4-Lite Write channels outputs
  type axi4lite_wr_bus_out is record
    -- Address channel
    awvalid : std_logic;
    awaddr  : std_logic_vector(31 downto 0);
    -- Data channel
    wvalid  : std_logic;
    wstrb   : std_logic_vector(3 downto 0);
    wdata   : std_logic_vector(31 downto 0);
    -- Response channel
    bready  : std_logic;
  end record axi4lite_wr_bus_out;

  ---------------------------------------------------------------------------------
  -- Functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Procedures
  ---------------------------------------------------------------------------------

  -- Write to an AXI4-Lite interface
  procedure axi4lite_write (
    constant wr_addr : in  integer;
    constant wr_data : in  std_logic_vector(31 downto 0);
    -- AXI4-Lite interface
    signal s_axi_i   : in  axi4lite_wr_bus_in;
    signal s_axi_o   : out axi4lite_wr_bus_out
    );

end sim_axi_wr_pkg;


package body sim_axi_wr_pkg is

  ---------------------------------------------------------------------------------
  -- Internal functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Functions
  ---------------------------------------------------------------------------------


  ---------------------------------------------------------------------------------
  -- Procedures
  ---------------------------------------------------------------------------------

  -- Write to an AXI4-Lite interface
  procedure axi4lite_write (
    constant wr_addr : in  integer;
    constant wr_data : in  std_logic_vector(31 downto 0);
    -- AXI4-Lite interface
    signal s_axi_i   : in  axi4lite_wr_bus_in;
    signal s_axi_o   : out axi4lite_wr_bus_out
    ) is
  begin
    -- Set the address
    s_axi_o.awvalid <= '1';
    s_axi_o.awaddr  <= std_logic_vector(to_unsigned(wr_addr, 32));
    -- Set the data
    s_axi_o.wvalid  <= '1';
    s_axi_o.wdata   <= wr_data;
    s_axi_o.wstrb   <= "1111";
    wait for SIM_AXI_WR_CLK_PERIOD;

    if s_axi_i.awready = '0' then
      wait until s_axi_i.awready = '1';
      wait for SIM_AXI_WR_CLK_PERIOD;
    end if;
    s_axi_o.awvalid <= '0';
    s_axi_o.awaddr  <= (others => '0');

    if s_axi_i.wready = '0' then
      wait until s_axi_i.wready = '1';
      wait for SIM_AXI_WR_CLK_PERIOD;
    end if;
    s_axi_o.wvalid <= '0';
    s_axi_o.wdata  <= (others => '0');
    s_axi_o.wstrb  <= "0000";

    -- Validate the transaction
    s_axi_o.bready <= '1';
    if s_axi_i.bvalid = '0' then
      wait until s_axi_i.bvalid = '1';
    end if;
    wait for SIM_AXI_WR_CLK_PERIOD;
    s_axi_o.bready <= '0';
    wait for SIM_AXI_WR_CLK_PERIOD;
  end procedure axi4lite_write;


end package body sim_axi_wr_pkg;
