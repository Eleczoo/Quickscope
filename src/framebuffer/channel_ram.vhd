-- Simple Dual-Port Block RAM with Single Clock (VHDL) for ADC Channel display data
-- channel_ram.vhd
-- source : https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Simple-Dual-Port-Block-RAM-with-Single-Clock-VHDL


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity channel_ram is
	generic (
		C_CH_DATA_WIDTH : integer := 11;
		C_CH_ADDR_WIDTH : integer := 11
	);
	port(
		clk : in std_logic;
		ena : in std_logic;
		enb : in std_logic;
		wea : in std_logic;
		addra : in std_logic_vector(C_CH_ADDR_WIDTH downto 0);
		addrb : in std_logic_vector(C_CH_ADDR_WIDTH downto 0);
		dia : in std_logic_vector(C_CH_DATA_WIDTH downto 0);
		dob : out std_logic_vector(C_CH_DATA_WIDTH downto 0)
	);
end channel_ram;

architecture syn of channel_ram is
	type ram_type is array (2**C_CH_ADDR_WIDTH-1 downto 0) of std_logic_vector(C_CH_DATA_WIDTH downto 0);
	shared variable RAM : ram_type;
begin
	process(clk)
	begin
		if clk'event and clk = '1' then
			if ena = '1' then
				if wea = '1' then
					RAM(conv_integer(addra)) := dia;
				end if;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if clk'event and clk = '1' then
			if enb = '1' then
				dob <= RAM(conv_integer(addrb));
			end if;
		end if;
	end process;

end syn;