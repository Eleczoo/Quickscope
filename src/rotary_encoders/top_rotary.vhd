library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_rotary is
    port (
        clk_i   : in std_logic;
        resetn : in std_logic;
        i_a         : in std_logic; -- Quadrature A
        i_b         : in std_logic; -- Quadrature B
        i_button    : in std_logic; -- Rotary encode button
        i_clear     : in std_logic; -- Clear the register and interrupt
        interrupt_led : out std_logic; -- Interrupt telling us there is new rotation
        leds : out std_logic_vector(2 downto 0) -- Status LEDs  
    );
end entity top_rotary;


architecture rtl of top_rotary is

    signal reg_leds : std_logic_vector(31 downto 0);

begin

    leds <= reg_leds(2 downto 0); 

    rotary_encoder_inst : entity work.rotary_encoder
    port map (
        clk_i => clk_i,
        resetn => resetn,
        i_a => i_a,
        i_b => i_b,
        i_button => i_button,
        i_clear => i_clear,
        o_interrupt => interrupt_led,
        o_reg_value => reg_leds
    ); 

end architecture;