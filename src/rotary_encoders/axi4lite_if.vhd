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
-- Author: Laurent Gantel <laurent.gantel@hesge.ch>
--
-- Module Name: axi4lite_if - arch
-- Target Device: digilentinc.com:basys3:part0:1.1 xc7a35tcpg236-1
-- Tool version: 2021.1
-- Description: axi4lite_if
--
-- Last update: 2022-01-12
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4lite_if is
  generic (
    C_DATA_WIDTH : integer := 32;
    C_ADDR_WIDTH : integer := 4
    );
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
    
    -- Write register interface
    wr_valid_o    : out std_logic;
    wr_addr_o     : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    wr_data_o     : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
    -- Read register interface
    rd_valid_o    : out std_logic;
    rd_addr_o     : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    rd_data_i     : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0)
    );
end axi4lite_if;





architecture arch of axi4lite_if is

  ---------------------------------------------------------------------------------
  -- Write interface
  ---------------------------------------------------------------------------------

  component axi4lite_wr_channel_if is
    generic (
      C_DATA_WIDTH : integer;
      C_ADDR_WIDTH : integer
      );
    port (
      s_axi_aclk    : in  std_logic;
      s_axi_aresetn : in  std_logic;
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
      valid_o       : out std_logic;
      addr_o        : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
      data_o        : out std_logic_vector((C_DATA_WIDTH - 1) downto 0)
      );
  end component axi4lite_wr_channel_if;

  signal wr_if_s_axi_aclk    : std_logic;
  signal wr_if_s_axi_aresetn : std_logic;
  signal wr_if_s_axi_awaddr  : std_logic_vector(31 downto 0);
  signal wr_if_s_axi_awvalid : std_logic;
  signal wr_if_s_axi_awready : std_logic;
  signal wr_if_s_axi_wdata   : std_logic_vector(31 downto 0);
  signal wr_if_s_axi_wstrb   : std_logic_vector(3 downto 0);
  signal wr_if_s_axi_wvalid  : std_logic;
  signal wr_if_s_axi_wready  : std_logic;
  signal wr_if_s_axi_bresp   : std_logic_vector(1 downto 0);
  signal wr_if_s_axi_bvalid  : std_logic;
  signal wr_if_s_axi_bready  : std_logic;
  signal wr_if_valid_o       : std_logic;
  signal wr_if_addr_o        : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
  signal wr_if_data_o        : std_logic_vector((C_DATA_WIDTH - 1) downto 0);

  ---------------------------------------------------------------------------------
  -- Read interface
  ---------------------------------------------------------------------------------

  component axi4lite_rd_channel_if is
    generic (
      C_DATA_WIDTH : integer;
      C_ADDR_WIDTH : integer
      );
    port (
      s_axi_aclk    : in  std_logic;
      s_axi_aresetn : in  std_logic;
      s_axi_araddr  : in  std_logic_vector(31 downto 0);
      s_axi_arvalid : in  std_logic;
      s_axi_arready : out std_logic;
      s_axi_rdata   : out std_logic_vector(31 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in  std_logic;
      valid_o       : out std_logic;
      addr_o        : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
      data_i        : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0)
      );
  end component axi4lite_rd_channel_if;

  signal rd_if_s_axi_aclk    : std_logic;
  signal rd_if_s_axi_aresetn : std_logic;
  signal rd_if_s_axi_araddr  : std_logic_vector(31 downto 0);
  signal rd_if_s_axi_arvalid : std_logic;
  signal rd_if_s_axi_arready : std_logic;
  signal rd_if_s_axi_rdata   : std_logic_vector(31 downto 0);
  signal rd_if_s_axi_rresp   : std_logic_vector(1 downto 0);
  signal rd_if_s_axi_rvalid  : std_logic;
  signal rd_if_s_axi_rready  : std_logic;
  signal rd_if_valid_o       : std_logic;
  signal rd_if_addr_o        : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
  signal rd_if_data_i        : std_logic_vector((C_DATA_WIDTH - 1) downto 0);

begin

  ---------------------------------------------------------------------------------
  -- Write interface
  ---------------------------------------------------------------------------------

  axi4lite_wr_channel_if_i : entity work.axi4lite_wr_channel_if
    generic map (
      C_DATA_WIDTH => C_DATA_WIDTH,
      C_ADDR_WIDTH => C_ADDR_WIDTH
      )
    port map (
      s_axi_aclk    => wr_if_s_axi_aclk,
      s_axi_aresetn => wr_if_s_axi_aresetn,
      s_axi_awaddr  => wr_if_s_axi_awaddr,
      s_axi_awvalid => wr_if_s_axi_awvalid,
      s_axi_awready => wr_if_s_axi_awready,
      s_axi_wdata   => wr_if_s_axi_wdata,
      s_axi_wstrb   => wr_if_s_axi_wstrb,
      s_axi_wvalid  => wr_if_s_axi_wvalid,
      s_axi_wready  => wr_if_s_axi_wready,
      s_axi_bresp   => wr_if_s_axi_bresp,
      s_axi_bvalid  => wr_if_s_axi_bvalid,
      s_axi_bready  => wr_if_s_axi_bready,
      valid_o       => wr_if_valid_o,
      addr_o        => wr_if_addr_o,
      data_o        => wr_if_data_o
      );

  wr_if_s_axi_aclk    <= s_axi_aclk;
  wr_if_s_axi_aresetn <= s_axi_aresetn;
  --
  wr_if_s_axi_awaddr  <= s_axi_awaddr;
  wr_if_s_axi_awvalid <= s_axi_awvalid;
  s_axi_awready       <= wr_if_s_axi_awready;
  wr_if_s_axi_wdata   <= s_axi_wdata;
  wr_if_s_axi_wstrb   <= s_axi_wstrb;
  wr_if_s_axi_wvalid  <= s_axi_wvalid;
  s_axi_wready        <= wr_if_s_axi_wready;
  s_axi_bresp         <= wr_if_s_axi_bresp;
  s_axi_bvalid        <= wr_if_s_axi_bvalid;
  wr_if_s_axi_bready  <= s_axi_bready;
  --
  wr_valid_o          <= wr_if_valid_o;
  wr_addr_o           <= wr_if_addr_o;
  wr_data_o           <= wr_if_data_o;

  ---------------------------------------------------------------------------------
  -- Read interface
  ---------------------------------------------------------------------------------

  axi4lite_rd_channel_if_i : entity work.axi4lite_rd_channel_if
    generic map (
      C_DATA_WIDTH => C_DATA_WIDTH,
      C_ADDR_WIDTH => C_ADDR_WIDTH
      )
    port map (
      s_axi_aclk    => rd_if_s_axi_aclk,
      s_axi_aresetn => rd_if_s_axi_aresetn,
      s_axi_araddr  => rd_if_s_axi_araddr,
      s_axi_arvalid => rd_if_s_axi_arvalid,
      s_axi_arready => rd_if_s_axi_arready,
      s_axi_rdata   => rd_if_s_axi_rdata,
      s_axi_rresp   => rd_if_s_axi_rresp,
      s_axi_rvalid  => rd_if_s_axi_rvalid,
      s_axi_rready  => rd_if_s_axi_rready,
      valid_o       => rd_if_valid_o,
      addr_o        => rd_if_addr_o,
      data_i        => rd_if_data_i
      );

  rd_if_s_axi_aclk    <= s_axi_aclk;
  rd_if_s_axi_aresetn <= s_axi_aresetn;
  --
  rd_if_s_axi_araddr  <= s_axi_araddr;
  rd_if_s_axi_arvalid <= s_axi_arvalid;
  s_axi_arready       <= rd_if_s_axi_arready;
  s_axi_rdata         <= rd_if_s_axi_rdata;
  s_axi_rresp         <= rd_if_s_axi_rresp;
  s_axi_rvalid        <= rd_if_s_axi_rvalid;
  rd_if_s_axi_rready  <= s_axi_rready;
  --
  rd_valid_o          <= rd_if_valid_o;
  rd_addr_o           <= rd_if_addr_o;
  rd_if_data_i        <= rd_data_i;

end arch;
