library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library sim_axi;
use sim_axi.sim_axi_wr_pkg.all;
use sim_axi.sim_axi_rd_pkg.all;


library std;
use std.env.finish;

entity tb_axi4lite_rotary is
--  Port ( );
end tb_axi4lite_rotary;

architecture Behavioral of tb_axi4lite_rotary is

signal rd_bus_in : axi4lite_rd_bus_in;
signal rd_bus_out : axi4lite_rd_bus_out;

signal wr_bus_in : axi4lite_wr_bus_in;
signal wr_bus_out : axi4lite_wr_bus_out;

signal s_axi_aclk : std_logic := '1';
signal s_axi_aresetn : std_logic := '1';

-- Write register interface
signal tx_valid_o : std_logic;
signal tx_data_o : std_logic_vector(7 downto 0);
signal tx_busy_i : std_logic;

-- Read register interface
signal rx_valid_i : std_logic;
signal rx_data_i : std_logic_vector(7 downto 0);


constant CLK_T : time := 10 ns;

constant test_data : std_logic_vector(7 downto 0) := "01010101";

constant CR_BASEADDR : integer := 0; -- Control Register
constant SR_BASEADDR : integer := 4; -- Status Register

signal read_value : std_logic_vector(31 downto 0);

signal s_interrupt : std_logic;
signal s_a : std_logic;
signal s_b : std_logic;
signal s_button : std_logic;


begin

    axi4lite_rotary_inst : entity work.axi4lite_rotary
    port map (
        s_axi_aclk => s_axi_aclk,
        s_axi_aresetn => s_axi_aresetn,
        
        s_axi_awaddr => wr_bus_out.awaddr,
        s_axi_awvalid => wr_bus_out.awvalid,
        s_axi_awready => wr_bus_in.awready,
        s_axi_wdata => wr_bus_out.wdata,
        s_axi_wstrb => wr_bus_out.wstrb,
        s_axi_wvalid => wr_bus_out.wvalid,
        s_axi_wready => wr_bus_in.wready,
        s_axi_bresp => wr_bus_in.bresp,
        s_axi_bvalid => wr_bus_in.bvalid,
        s_axi_bready => wr_bus_out.bready,
        
        -- AXI4-Lite Read interface
        s_axi_araddr => rd_bus_out.araddr,
        s_axi_arvalid => rd_bus_out.arvalid,
        s_axi_arready => rd_bus_in.arready,
        s_axi_rdata => rd_bus_in.rdata,
        s_axi_rresp => rd_bus_in.rresp,
        s_axi_rvalid => rd_bus_in.rvalid,
        s_axi_rready => rd_bus_out.rready,


        o_interrupt => s_interrupt,
        i_a => s_a,
        i_b => s_b,
        i_button => s_button
    );


    -- CLK
    s_axi_aclk <= not s_axi_aclk after CLK_T / 2;

    -- RESET
    s_axi_aresetn <= '0', '1' after CLK_T * 4;


    proc_stimu : process
    begin

        -- Wait for resetted and stable signals
        wait until s_axi_aresetn = '1';
        wait for CLK_T;
        
        wait for CLK_T * 10;
        
        report "STARTED  !!!!!!!!!!!!!!";


        -- ------------------------------------------------------
        
        -- ! RIGHT ROTATION
        -- B low, rising edge A
        s_b <= '0';
        s_a <= '0';
        wait for CLK_T;
        s_a <= '1';
        wait for CLK_T;

        -- -- Check if interrupt appears
        if s_interrupt = '0' then
            wait until s_interrupt = '1';
        end if;

        report "READING RIGHT";
        axi4lite_read(  SR_BASEADDR,
                        read_value,
                        rd_bus_in,
                        rd_bus_out);
        
        assert read_value(1 downto 0) = "01" report "CHKPT 1: NOT A RIGHT ROTATION" severity failure;

        -- -- Clear
        axi4lite_write( CR_BASEADDR, 
                        (others => '1'), 
                        wr_bus_in,
                        wr_bus_out);

        -- ------------------------------------------------------
        -- ! LEFT ROTATION
        -- B High, rising edge A
        s_b <= '1';
        s_a <= '0';
        wait for CLK_T;
        s_a <= '1';
        wait for CLK_T;
        
        -- -- Check if interrupt appears
        if s_interrupt = '0' then
            wait until s_interrupt = '1';
        end if;

        report "READING LEFT";
        axi4lite_read(  SR_BASEADDR,
                        read_value,
                        rd_bus_in,
                        rd_bus_out);
        
        assert read_value(1 downto 0) = "10" report "CHKPT 2: NOT A LEFT ROTATION" severity failure;
        
        -- -- Clear
        axi4lite_write( CR_BASEADDR, 
                        (others => '1'), 
                        wr_bus_in,
                        wr_bus_out);

        -- ! BUTTON
        s_button <= '1';
        wait for CLK_T;
        s_button <= '0';
        wait for CLK_T;
        
        -- -- Check if interrupt appears
        if s_interrupt = '0' then
            wait until s_interrupt = '1';
        end if;

        report "READING BUTTON";
        axi4lite_read(  SR_BASEADDR,
                        read_value,
                        rd_bus_in,
                        rd_bus_out);
        
        assert read_value(2) = '1' report "CHKPT 3: NOT A BUTTON PRESS" severity failure;

                        
        wait for CLK_T;
        tx_valid_o <= '1';
        wait for CLK_T;
        tx_valid_o <= '0';
        
        wait for CLK_T; 
        report "FINISHED SIMULATION";
        finish;
      
  end process;





end Behavioral;
