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
-- Module Name: Rotary Encoder Testbench
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

library std;
use std.env.finish;

-- ! ENTITY
entity rotary_encoder_tb is
end;

-- ! ARCHITECTURE
architecture bench of rotary_encoder_tb is

    signal clk_i : std_logic := '1';
    signal resetn : std_logic;
    signal i_a : std_logic := '0';
    signal i_b : std_logic := '0';
    signal i_button : std_logic;
    signal i_clear : std_logic;
    signal o_interrupt : std_logic;
    signal o_reg_value : std_logic_vector(2 downto 0);

    constant CLK_T : time := 10 ns; 

begin

    rotary_encoder_inst : entity work.rotary_encoder
        port map (
            clk_i => clk_i,
            resetn => resetn,
            i_a => i_a,
            i_b => i_b,
            i_button => i_button,
            i_clear => i_clear,
            o_interrupt => o_interrupt,
            o_reg_value => o_reg_value
    );

    -- CLK
    clk_i <= not clk_i after CLK_T / 2;

    -- RESET
    resetn <= '0', '1' after CLK_T * 4;

    -- ! TESTER
    proc_tester : process
    begin

        -- Wait for resetted and stable signals
        wait until resetn = '1';
        wait for CLK_T;


        -- ! RIGHT ROTATION
        -- B low, rising edge A
        i_b <= '0';
        i_a <= '0';
        wait for CLK_T;
        i_a <= '1';
        wait for CLK_T;

        -- -- Check if interrupt appears
        if o_interrupt = '0' then
            wait until o_interrupt = '1';
        end if;
        
        assert o_reg_value(1 downto 0) = "01" report "Right rotation was not detected" severity failure;

        -- -- Clear
        i_clear <= '1';
        wait for CLK_T;
        i_clear <= '0';
        wait for CLK_T;

        -- ! LEFT ROTATION
        -- B High, rising edge A
        i_b <= '1';
        i_a <= '0';
        wait for CLK_T;
        i_a <= '1';
        wait for CLK_T;
        
        -- -- Check if interrupt appears
        if o_interrupt = '0' then
            wait until o_interrupt = '1';
        end if;
        
        assert o_reg_value(1 downto 0) = "10" report "Left rotation was no detected" severity failure;
            
        -- -- Clear
        i_clear <= '1';
        wait for CLK_T;
        i_clear <= '0';
        wait for CLK_T;

        -- ! BUTTON
        i_button <= '1';
        wait for CLK_T;
        i_button <= '0';
        wait for CLK_T;
        
        -- -- Check if interrupt appears
        if o_interrupt = '0' then
            wait until o_interrupt = '1';
        end if;

        assert o_reg_value(2) = '1' report "Button was no detected" severity failure;
            
        -- -- Clear
        i_clear <= '1';
        wait for CLK_T;
        i_clear <= '0';
        wait for CLK_T;

        -- ! SIMULTANUOUS BUTTON + LEFT ROTATION
        i_button <= '1';
        i_b <= '1';
        i_a <= '0';
        wait for CLK_T;
        i_a <= '1';
        i_button <= '0';
        wait for CLK_T;

        -- -- Check if interrupt appears
        if o_interrupt = '0' then
            wait until o_interrupt = '1';
        end if;
        
        assert o_reg_value(1 downto 0) = "10" report "Left rotation was not detected" severity failure;
        assert o_reg_value(2) = '1' report "Button was no detected" severity failure;

        wait for CLK_T; -- Wait before finish
        report "FINISHED SIMULATION";
        finish;
        
    end process;

end;