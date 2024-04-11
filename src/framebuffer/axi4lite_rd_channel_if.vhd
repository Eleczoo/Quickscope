----------------------------------------------------------------------------------
-- Company: hepia // HES-SO
-- Engineer: Laurent Gantel <laurent.gantel@hesge.ch>
-- 
-- Module Name: axi4lite_rd_channel_if - arch 
-- Target Devices: Xilinx Artix7 xc7a100tcsg324-1
-- Tool versions: 2014.2
-- Description: AXI4-Lite Read Channel interface
--
-- Last update: 2022-01-09
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity axi4lite_rd_channel_if is
  generic (
    C_DATA_WIDTH : integer := 32;
    C_ADDR_WIDTH : integer := 10
    );
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    -- Read channel
    s_axi_araddr  : in  std_logic_vector(31 downto 0);  -- Read address
    s_axi_arvalid : in  std_logic;    -- Read address validation
    s_axi_arready : out std_logic;    -- Ready to receive a valid address
    s_axi_rdata   : out std_logic_vector(31 downto 0);  -- Read data
    s_axi_rresp   : out std_logic_vector(1 downto 0);  -- Read response status (not specified)
    s_axi_rvalid  : out std_logic;    -- Indicate that valid data can be read
    s_axi_rready  : in  std_logic;  -- Indicate that the master can accept a read data and response information
-- Data interface
    valid_o         : out std_logic;
    addr_o          : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    data_i          : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0)
    );
end entity axi4lite_rd_channel_if;


architecture arch of axi4lite_rd_channel_if is

  -- AXI4-Lite signals
  signal s_axi_arready_s : std_logic                    := '0';
  signal s_axi_rvalid_s  : std_logic                    := '0';
  signal s_axi_rresp_s   : std_logic_vector(1 downto 0) := (others => '0');

  -- Intermediate signals
  signal rd_addr_latched : std_logic                                     := '0';
  signal addr_s          : std_logic_vector((C_ADDR_WIDTH - 1) downto 0) := (others => '0');
  signal data_s          : std_logic_vector((C_DATA_WIDTH - 1) downto 0) := (others => '0');

begin

  --
  -- Read channel: Generate the arready signal - Latch the address
  --
  -- The arready signal is deasserted at reset and when the arvalid signal is set.
  -- It is reasserted once rready is asserted by the master.
  --
  process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      -- Deassert at reset
      if s_axi_aresetn = '0' then
        s_axi_arready_s <= '0';
        rd_addr_latched   <= '0';
      -- Deassert when arvalid is asserted
      elsif s_axi_arvalid = '1' then
        s_axi_arready_s <= '0';
        rd_addr_latched   <= '1';
      -- Reassert it when rready is asserted
      elsif s_axi_rready = '1' and s_axi_arready_s = '0' then
        s_axi_arready_s <= '1';
        rd_addr_latched   <= '0';
      -- When the address has been latched, keep it LOW until rready is asserted
      elsif rd_addr_latched = '1' then
        s_axi_arready_s <= '0';
      -- By default, arready is HIGH
      else
        s_axi_arready_s <= '1';
        rd_addr_latched   <= rd_addr_latched;
      end if;
    end if;
  end process;

  s_axi_arready <= s_axi_arready_s;


  -- Latch the read channel address
  addr_o <= s_axi_araddr((C_ADDR_WIDTH - 1) downto 0) when s_axi_arvalid = '1' and s_axi_arready_s = '1' else
            addr_s;
  valid_o <= s_axi_arvalid and s_axi_arready_s;

  process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        addr_s <= (others => '0');
      elsif s_axi_arvalid = '1' and s_axi_arready_s = '1' then
        addr_s <= s_axi_araddr((C_ADDR_WIDTH - 1) downto 0);
      else
        addr_s <= addr_s;
      end if;
    end if;
  end process;


  --
  -- Read channel: Generate the rvalid signal - Latch the data
  --
  -- The rvalid signal is asserted once a valid address has been set
  -- on the araddr port.
  --
  -- FIXME: The rresp signal is always "00" to indicate a valid transation.
  --

  -- Generate the rvalid signal
  process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        s_axi_rvalid_s <= '0';
        s_axi_rresp_s  <= "00";
      -- Assert rvalid once a valid address has been set on the araddr port
      elsif s_axi_arvalid = '1' and s_axi_arready_s = '1' then
        s_axi_rvalid_s <= '1';
        s_axi_rresp_s  <= "00";
      -- Deassert rvalid when the read data has been acknowledged 
      elsif s_axi_rready = '1' and s_axi_rvalid_s = '1' then
        s_axi_rvalid_s <= '0';
        s_axi_rresp_s  <= "00";
      else
        s_axi_rvalid_s <= s_axi_rvalid_s;
        s_axi_rresp_s  <= s_axi_rresp_s;
      end if;
    end if;
  end process;

  s_axi_rvalid <= s_axi_rvalid_s;
  s_axi_rresp  <= s_axi_rresp_s;
  s_axi_rdata  <= data_i;

end arch;
