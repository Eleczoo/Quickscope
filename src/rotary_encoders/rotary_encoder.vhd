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
-- Module Name: Rotary Encoder
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rotary_encoder is
    port (
        clk_i       : in std_logic;
        resetn      : in std_logic;
        i_a         : in std_logic; -- Quadrature A
        i_b         : in std_logic; -- Quadrature B
        i_button    : in std_logic; -- Rotary encode button
        i_clear     : in std_logic; -- Clear the register and interrupt
        o_interrupt : out std_logic; -- Interrupt telling us there is new rotation
        o_reg_value : out std_logic_vector(2 downto 0)

        );
    end rotary_encoder;
    
architecture Behavioral of rotary_encoder is
        signal s_a      : std_logic_vector(1 downto 0) := (others => '0');
        signal s_b      : std_logic := '0';
        signal s_button : std_logic_vector(1 downto 0) := (others => '0');
begin

    -- ! EDGES DETECTION
    proc_rotation : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if resetn = '0' then
                o_reg_value <= (others => '0'); 
            else
                -- 2 bits register for edge detection
                s_a(1) <= s_a(0);
                s_a(0) <= i_a;
                
                s_b <= i_b;

                s_button(1) <= s_button(0);
                s_button(0) <= i_button;
            end if;
        end if;
    end process;

    -- ! CLEAR
    proc_clear : process
    begin
        if rising_edge(clk_i) then
            if resetn = '0' then
                o_reg_value <= (others => '0'); 
            else
                if i_clear = '1' then 
                    o_reg_value <= (others => '0'); 
                    o_interrupt <= '0'; 
            end if;
    end process;

    -- ! ROTATION SETTER
    proc_rotation : process(s_a, s_b)
    begin
        -- ! Set the rotatation according to B when a is rising
        -- A : Rising edge
        if s_a = "01" then 
            o_interrupt <= '1';
            if s_b = '1' then
                o_reg_value(1 downto 0) <= "01";
            elsif s_b = '0' then
                o_reg_value(1 downto 0) <= "10";
            end if;
         end if;
    end process;

    -- ! Set the button pressed bit when falling edge id detected
    o_reg_value(2) <= '1' when s_button = "10" else '0';
    
end Behavioral;