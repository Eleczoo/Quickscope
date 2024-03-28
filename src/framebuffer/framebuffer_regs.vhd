-- Description : Counts all the time, can be read and written via axi 4 lite

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framebuffer_regs is
	generic (
		C_DATA_WIDTH : integer := 32;
		C_ADDR_WIDTH : integer := 17;
		C_CH_DATA_WIDTH : integer := 11;
		C_CH_ADDR_WIDTH : integer := 11;
		C_ASSETS_DATA_WIDTH : integer := 1;
		C_ASSETS_ADDR_WIDTH : integer := 14
	);
	port (
		aclk: 	in 	std_logic;
		pxlclk:	in	std_logic;
		rst_n: 	in 	std_logic;
		
		-- AXI4-Lite 
		-- Write register interface
		wr_valid_i		: in std_logic;
		wr_addr_i 		: in std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		wr_data_i 		: in std_logic_vector((C_DATA_WIDTH - 1) downto 0);

		-- Channels RAM Output for video generator
		ch_enb			: in std_logic_vector(3 downto 0);
		assets_enb		: in std_logic;
		-- Channel 0
		ch0_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch0_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 1
		ch1_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch1_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 2
		ch2_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch2_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 3
		ch3_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch3_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Assets
		assets_addrb	: in  std_logic_vector((C_ASSETS_ADDR_WIDTH - 1) downto 0);
		assets_dob		: out std_logic_vector((C_ASSETS_DATA_WIDTH - 1) downto 0)
	);

end entity framebuffer_regs;

architecture rtl of framebuffer_regs is
	

	-- RAM Channels signals
	signal ch_wea: std_logic_vector(3 downto 0);

	-- Channel 0
	signal ch0_addra: std_logic_vector(C_CH_ADDR_WIDTH-1 downto 0);
	signal ch0_dia: std_logic_vector(C_CH_DATA_WIDTH-1 downto 0);
	-- Channel 1
	signal ch1_addra: std_logic_vector(C_CH_ADDR_WIDTH-1 downto 0);
	signal ch1_dia: std_logic_vector(C_CH_DATA_WIDTH-1 downto 0);
	-- Channel 2
	signal ch2_addra: std_logic_vector(C_CH_ADDR_WIDTH-1 downto 0);
	signal ch2_dia: std_logic_vector(C_CH_DATA_WIDTH-1 downto 0);
	-- Channel 3
	signal ch3_addra: std_logic_vector(C_CH_ADDR_WIDTH-1 downto 0);
	signal ch3_dia: std_logic_vector(C_CH_DATA_WIDTH-1 downto 0);

	-- Assets RAM
	signal assets_wea: 	 std_logic;
	signal assets_addra: std_logic_vector(C_ASSETS_ADDR_WIDTH-1 downto 0);
	signal assets_dia: 	 std_logic_vector(C_ASSETS_DATA_WIDTH-1 downto 0);

	-- AXI4-Lite
	constant CH0_BASEADDR : integer :=    0; -- Channel 1 Data Register
	constant CH1_BASEADDR : integer := 2048; -- Channel 2 Data Register
	constant CH2_BASEADDR : integer := 4096; -- Channel 3 Data Register
	constant CH3_BASEADDR : integer := 6144; -- Channel 4 Data Register
	constant ASSETS_BASEADDR : integer := 8192; -- Assets Data Register

	-- Write address integer
	signal wr_addr_s : integer := 0;

begin

	-- RAM Channels
	-- Port A is write only, Port B is read only

	inst_ch0_ram : entity work.channel_ram
	generic map (
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH
	)
	port map (
		clka => aclk,
		clkb => pxlclk,
		ena => ch_wea(0),
		wea => ch_wea(0),
		enb => ch_enb(0),
		addra => ch0_addra,
		addrb => ch0_addrb,
		dia => ch0_dia,
		dob => ch0_dob
	);

	inst_ch1_ram : entity work.channel_ram
	generic map (
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH
	)
	port map (
		clka => aclk,
		clkb => pxlclk,
		ena => ch_wea(1),
		wea => ch_wea(1),
		enb => ch_enb(1),
		addra => ch1_addra,
		addrb => ch1_addrb,
		dia => ch1_dia,
		dob => ch1_dob
	);

	inst_ch2_ram : entity work.channel_ram
	generic map (
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH
	)
	port map (
		clka => aclk,
		clkb => pxlclk,
		ena => ch_wea(2),
		wea => ch_wea(2),
		enb => ch_enb(2),
		addra => ch2_addra,
		addrb => ch2_addrb,
		dia => ch2_dia,
		dob => ch2_dob
	);

	inst_ch3_ram : entity work.channel_ram
	generic map (
		C_CH_DATA_WIDTH => C_CH_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_CH_ADDR_WIDTH
	)
	port map (
		clka => aclk,
		clkb => pxlclk,
		ena => ch_wea(3),
		wea => ch_wea(3),
		enb => ch_enb(3),
		addra => ch3_addra,
		addrb => ch3_addrb,
		dia => ch3_dia,
		dob => ch3_dob
	);

	inst_assets_ram : entity work.channel_ram
	generic map (
		C_CH_DATA_WIDTH => C_ASSETS_DATA_WIDTH,
		C_CH_ADDR_WIDTH => C_ASSETS_ADDR_WIDTH
	)
	port map (
		clka => aclk,
		clkb => pxlclk,
		ena => assets_wea,
		wea => assets_wea,
		enb => assets_enb,
		addra => assets_addra,
		addrb => assets_addrb,
		dia => assets_dia,
		dob => assets_dob
	);



	-- ----------------------------------------------
	--  AXI4-Lite Registers (Read only)
	-- ----------------------------------------------

	wr_addr_s <= to_integer ( unsigned ( wr_addr_i((C_ADDR_WIDTH - 1) downto 2) ));
	-- Write register process
	wr_regs_proc : process ( aclk )
	begin
		if rising_edge ( aclk ) then
			if rst_n = '0' then
				ch_wea <= (others => '0');
			else
				assets_wea <= '0';
				ch_wea <= (others => '0');
				if wr_valid_i = '1' then
					
					case wr_addr_s is
						-- Channels
						when CH0_BASEADDR to CH0_BASEADDR+2047 =>
							ch_wea <= (0 => '1', others => '0');
							ch0_addra <= std_logic_vector(to_unsigned((wr_addr_s - CH0_BASEADDR), C_CH_ADDR_WIDTH));
							ch0_dia <= wr_data_i(10 downto 0);
							
						when CH1_BASEADDR to CH1_BASEADDR+2047 =>
							ch_wea <= (1 => '1', others => '0');
							ch1_addra <= std_logic_vector(to_unsigned(wr_addr_s - CH1_BASEADDR, C_CH_ADDR_WIDTH));
							ch1_dia <= wr_data_i(10 downto 0);

						when CH2_BASEADDR to CH2_BASEADDR+2047 =>
							ch_wea <= (2 => '1', others => '0');
							ch2_addra <= std_logic_vector(to_unsigned(wr_addr_s - CH2_BASEADDR, C_CH_ADDR_WIDTH));
							ch2_dia <= wr_data_i(10 downto 0);

						when CH3_BASEADDR to CH3_BASEADDR+2047 =>
							ch_wea <= (3 => '1', others => '0');
							ch3_addra <= std_logic_vector(to_unsigned(wr_addr_s - CH3_BASEADDR, C_CH_ADDR_WIDTH));
							ch3_dia <= wr_data_i(10 downto 0);
						
						when ASSETS_BASEADDR to ASSETS_BASEADDR+16384 =>
							assets_wea <= '1';
							assets_addra <= std_logic_vector(to_unsigned(wr_addr_s - ASSETS_BASEADDR, C_ASSETS_ADDR_WIDTH));
							assets_dia <= wr_data_i(0 downto 0);

						when others =>
							ch_wea <= (others => '0');

					end case;
				end if;
			end if;
		end if;
	end process wr_regs_proc;


end architecture;