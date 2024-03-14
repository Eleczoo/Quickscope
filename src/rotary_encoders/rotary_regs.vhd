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
-- Module Name: Rotary Encoder Register
-- Target Device: 
-- Tool version: 2024.1
-- Description: 
-- Rotary encoder sends quadrature signal on A and B:
-- A comes before B : Clockwise rotation
-- B comes before A : Counter Clockwise rotation
-- We can check the rising edge on A signal and check B to determine the rotation
-- 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rotary_regs is
    generic(
        C_DATA_WIDTH : integer := 32;
        C_ADDR_WIDTH : integer := 32
    );
    
    port(
        clk_i : in std_logic;
        resetn : in std_logic; 
        
        wr_valid_i : in std_logic;
        wr_addr_i : in std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        wr_data_i : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        
        rd_valid_i : in std_logic;
        rd_addr_i : in std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        rd_data_o : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
            
        -- ROTARY SPECIFIC
        o_clear     : out std_logic; -- Clear the register and interrupt
        i_reg_value : in  std_logic_vector(2 downto 0)
    );
end rotary_regs;

architecture Behavioral of rotary_regs is

    -- Control register (CR) @ 0x00 - RW
    -- [0] : Clear the Status Register + Interrupt
    signal control_reg : std_logic_vector(31 downto 0) := (others=>'0');

    -- Status register (SR) @ 0x04 - RO
    -- [0] : Rotate Right
    -- [1] : Rotate Left
    -- [2] : Rotate Button
    signal status_reg : std_logic_vector(31 downto 0) := (others=>'0');

    -- Registers addresses
    constant CR_BASEADDR : integer := 0; -- Control Register
    constant SR_BASEADDR : integer := 4; -- Status Register

    -- Write address integer
    signal wr_addr_s : integer := 0;

    -- Read address integer
    signal rd_addr_s : integer := 0;
    
    -- Read data
    signal rd_data_s : std_logic_vector (( C_DATA_WIDTH - 1) downto 0) := ( others => '0');
    
begin

    wr_addr_s <= to_integer(unsigned(wr_addr_i));

    -- Write register process
    wr_regs_proc : process ( clk_i )
    begin
        if rising_edge ( clk_i ) then
            if resetn = '0' then
                control_reg <= (others => '0');
            else
                control_reg <= control_reg;
                if wr_valid_i = '1' then
                    case wr_addr_s is
                        -- -------------------------------------------------------------------------------
                        when CR_BASEADDR=>
                            control_reg <= wr_data_i;
                        -- -------------------------------------------------------------------------------
                        when others =>
                            control_reg <= control_reg ;
                    end case;
                else
                    -- ! Not sure about this
                    -- Clear control signals that should be set for one cycle only ( pulse )
                    control_reg(0) <= '0';
                end if;
            end if;
        end if;
        
    end process wr_regs_proc ;

    rd_addr_s <= to_integer ( unsigned ( rd_addr_i ));
    -- Read register process
    rd_regs_proc : process ( clk_i )
    begin
        if rising_edge ( clk_i ) then
            if resetn = '0' then
                rd_data_s <= ( others => '0');
            else
                rd_data_s <= rd_data_s;
                if rd_valid_i = '1' then
                    case rd_addr_s is
                        -- -------------------------------------------------------------------------------
                        when CR_BASEADDR =>
                            rd_data_s <= control_reg;
                            -- -------------------------------------------------------------------------------
                        when SR_BASEADDR =>
                            rd_data_s <= status_reg;
                            -- -------------------------------------------------------------------------------
                        when others =>
                            rd_data_s <= ( others => '0');
                    end case ;
                end if;
            end if;
        end if;
    end process rd_regs_proc ;
    
    rd_data_o <= rd_data_s;
    
    
    --
    -- Map I/O to registers
    --
    
    -- Control register
    o_clear <= control_reg(0);

    --  Status Register
    status_reg(2 downto 0) <= i_reg_value;




end Behavioral;
