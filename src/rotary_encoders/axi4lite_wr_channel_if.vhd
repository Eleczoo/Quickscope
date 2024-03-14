----------------------------------------------------------------------------------
-- Company: hepia // HES-SO
-- Engineer: Laurent Gantel <laurent.gantel@hesge.ch>
-- 
-- Module Name: axi4lite_wr_channel_if - arch 
-- Target Devices: Xilinx Artix7 xc7a100tcsg324-1
-- Tool versions: 2014.2
-- Description: AXI4-Lite Write Channel interface
--
-- Last update: 2022-01-09
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity axi4lite_wr_channel_if is
  generic (
    C_DATA_WIDTH : integer := 32;
    C_ADDR_WIDTH : integer := 10
    );
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    ---------------------------------------------------------------------------------
    -- Write interface
    ---------------------------------------------------------------------------------
    -- Write Address channel
    s_axi_awaddr  : in  std_logic_vector(31 downto 0);  -- Write address
    s_axi_awvalid : in  std_logic;      -- Write address validation
    s_axi_awready : out std_logic;      -- Ready to receive a valid address
    -- Write Data channel
    s_axi_wdata   : in  std_logic_vector(31 downto 0);  -- Data to be written
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);  -- Write data byte enable
    s_axi_wvalid  : in  std_logic;      -- Write data validation
    s_axi_wready  : out std_logic;      -- Ready to receive data
    -- Write Response channel
    s_axi_bresp   : out std_logic_vector(1 downto 0);  -- Write response status (not specified)
    s_axi_bvalid  : out std_logic;      -- Write response validation
    s_axi_bready  : in  std_logic;  -- Indicate that the master can accept a write response
    -- Data interface
    valid_o       : out std_logic;
    addr_o        : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    data_o        : out std_logic_vector((C_DATA_WIDTH - 1) downto 0)
    );
end entity axi4lite_wr_channel_if;


architecture arch of axi4lite_wr_channel_if is

  -- AXI4-Lite signals
  signal s_axi_awready_s : std_logic := '0';
  signal s_axi_wready_s  : std_logic := '0';

  signal s_axi_bvalid_s : std_logic                    := '0';
  signal s_axi_bresp_s  : std_logic_vector(1 downto 0) := (others => '0');

  -- Intermediate signals
  signal aw_en   : std_logic                                     := '0';
  signal valid_s : std_logic                                     := '0';
  signal addr_s  : std_logic_vector((C_ADDR_WIDTH - 1) downto 0) := (others => '0');
  signal data_s  : std_logic_vector((C_DATA_WIDTH - 1) downto 0) := (others => '0');

begin

  ---------------------------------------------------------------------------------
  -- Write address channel:
  ---------------------------------------------------------------------------------
  -- Generate the awready signal
  --
  awready_gen_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      -- Deassert at reset
      if s_axi_aresetn = '0' then
        s_axi_awready_s <= '0';
        aw_en           <= '1';
      else
        s_axi_awready_s <= '0';
        aw_en           <= aw_en;

        -- Assert awready when the slave is ready to accept an address AND when there is 
        -- a valid write address AND write data on the address and data bus.
        if s_axi_awvalid = '1' and s_axi_wvalid = '1' and aw_en = '1' then  -- and s_axi_awready_s = '0' ??
          s_axi_awready_s <= '1';
          aw_en           <= '0';
        -- Deassert awready when a write response has been given
        elsif s_axi_bready = '1' and s_axi_bvalid_s = '1' then
          aw_en           <= '1';
        end if;
      end if;
    end if;
  end process awready_gen_proc;

  s_axi_awready <= s_axi_awready_s;

  -- Latch the write channel address
  --
  latch_awaddr_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        addr_s <= (others => '0');
      else
        if s_axi_awvalid = '1' and s_axi_wvalid = '1' and aw_en = '1' then  -- and s_axi_awready_s = '0' ??
          addr_s <= s_axi_awaddr((C_ADDR_WIDTH - 1) downto 0);
        else
          addr_s <= addr_s;
        end if;
      end if;
    end if;
  end process latch_awaddr_proc;

  addr_o <= addr_s;


  ---------------------------------------------------------------------------------
  -- Write Data channel:
  ---------------------------------------------------------------------------------
  -- Generate the wready signal
  --
  -- The wready signal is asserted once both awvalid and awready signals have been asserted
  -- due to a valid address on the awaddr port.
  --

  -- Generate the wready signal
  wready_gen_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        s_axi_wready_s <= '0';
      else
        -- Slave is ready to accept write data when there is a valid write address and write data
        -- on the write address and data bus.
        -- Keep the signal high for one cycle
        if s_axi_wready_s = '0' and s_axi_awvalid = '1' and s_axi_wvalid = '1' and aw_en = '1' then
          s_axi_wready_s <= '1';
        else
          s_axi_wready_s <= '0';
        end if;
      end if;
    end if;
  end process wready_gen_proc;

  s_axi_wready <= s_axi_wready_s;

  -- Latch and Write the data
  --
  latch_wdata_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        valid_s <= '0';
        data_s  <= (others => '0');
      else
        -- Slave register write enable is asserted when valid address and data are available
        -- and the slave is ready to accept the write address and write data.
        if s_axi_wvalid = '1' and s_axi_wready_s = '1' then
          valid_s <= '1';
          data_s  <= s_axi_wdata((C_DATA_WIDTH - 1) downto 0);
        else
          valid_s <= '0';
          data_s  <= (others => '0');
        end if;
      end if;
    end if;
  end process latch_wdata_proc;

  valid_o <= valid_s;
  data_o  <= data_s;


  --
  -- Write Response channel: Generate the bvalid signal and the bresp signal
  --
  -- The write response and response valid signals are asserted by the slave
  -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  -- This marks the acceptance of address and indicates the status of
  -- write transaction.
  --


  response_proc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        s_axi_bvalid_s <= '0';
        s_axi_bresp_s  <= (others => '0');
      else
        if s_axi_wvalid = '1' and s_axi_wready_s = '1' then
          s_axi_bvalid_s <= '1';
          s_axi_bresp_s  <= (others => '0');
        elsif (s_axi_bready = '1' and s_axi_bvalid_s = '1') then  --check if bready is asserted while bvalid is high)
          s_axi_bvalid_s <= '0';  -- (there is a possibility that bready is always asserted high)
        else
          s_axi_bvalid_s <= s_axi_bvalid_s;
          s_axi_bresp_s  <= s_axi_bresp_s;
        end if;
      end if;
    end if;
  end process response_proc;

  s_axi_bvalid <= s_axi_bvalid_s;
  s_axi_bresp  <= s_axi_bresp_s;

end arch;

