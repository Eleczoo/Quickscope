-- Single-Port Block RAM Read-First Mode for ADC Channel display data
-- channel_ram.vhd
-- source : https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Single-Port-Block-RAM-Write-First-Mode-VHDL


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity channel_ram is
	port(
		clk : 	in 	std_logic;
		we : 	in 	std_logic;
		en : 	in 	std_logic;
		addr : 	in 	std_logic_vector(10 downto 0);
		di : 	in 	std_logic_vector(9 downto 0);
		do : 	out std_logic_vector(9 downto 0)
	);
end channel_ram;

architecture syn of channel_ram is
	type ram_type is array (2047 downto 0) of std_logic_vector(9 downto 0);
	signal RAM : ram_type;

begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			if en = '1' then
				if we = '1' then
					RAM(to_integer(unsigned(addr))) <= di;
				end if;

				do <= RAM(to_integer(unsigned(addr)));
			end if;
		end if;
	end process;

end syn;