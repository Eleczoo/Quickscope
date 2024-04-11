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
-- 
-- This module debounces an input :
-- It has to be high long enough to be set as high

-- Inpired by https://github.com/Yourigh/Rotary-encoder-VHDL-design/blob/master/src/debouncer.vhd
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity debounce is
    generic (
        count_size : integer := 15 -- Count to reach before triggering a 1 (15 bits @ 100 Mhz = 327us)
    );
    port (
        clk   : in std_logic;
        i_input : in std_logic;
        o_output: out std_logic;
        resetn : in std_logic
    );
end entity debounce;

architecture rtl of debounce is
    signal ff : std_logic_vector(1 downto 0); -- input flip flops
    signal edge : std_logic;           -- sync reset to zero
    signal counter : unsigned(count_size downto 0) := (others => '0'); --counter output
begin

    edge <= ff(0) xor ff(1);   -- Start or reset counter ?
  
    process(clk)
    begin
        if resetn = '0' then
            counter <= (others => '0');
            o_output <= '0'; 
        else        
            if(clk'event and clk = '1') then
                ff(0) <= i_input;
                ff(1) <= ff(0);

                -- ! reset counter because input is changing
                if(edge = '1') then                  
                    counter <= (others => '0');
                
                -- ! Goal count not reached yet (Only Checking last bit)
                elsif(counter(count_size) = '0') then 
                    counter <= counter + 1;
                
                -- ! Input has been high long enough
                else                                        --stable input time is met
                    o_output <= ff(1);

                end if;    
            end if;
        end if;
    end process;

    
end architecture;