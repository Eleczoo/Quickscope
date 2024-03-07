-- Description : Counts all the time, can be read and written via axi 4 lite

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framebuffer_regs is
	generic (
		C_DATA_WIDTH : integer := 32;
		C_ADDR_WIDTH : integer := 13;
		C_CH_DATA_WIDTH : integer := 11;
		C_CH_ADDR_WIDTH : integer := 11
	);
	port (
		aclk: 	in 	std_logic;
		rst_n: 	in 	std_logic;
		
		-- AXI4-Lite 
		-- Write register interface
		wr_valid_i		: in std_logic;
		wr_addr_i 		: in std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		wr_data_i 		: in std_logic_vector((C_DATA_WIDTH - 1) downto 0);

		-- Channels RAM Output for video generator
		ch_enb			: in std_logic_vector(3 downto 0);
		-- Channel 0
		ch0_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch0_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 0
		ch1_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch1_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 0
		ch2_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch2_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
		-- Channel 0
		ch3_addrb		: in  std_logic_vector((C_CH_ADDR_WIDTH - 1) downto 0);
		ch3_dob			: out std_logic_vector((C_CH_DATA_WIDTH - 1) downto 0);
	);

end entity framebuffer_regs;

architecture rtl of framebuffer_regs is
	
	-- Components
	component channel_ram
		generic (
			C_CH_DATA_WIDTH : integer := 11;
			C_CH_ADDR_WIDTH : integer := 11
		);
		port (
			clk : in std_logic;
			ena : in std_logic;
			enb : in std_logic;
			wea : in std_logic;
			addra : in std_logic_vector(C_CH_ADDR_WIDTH downto 0);
			addrb : in std_logic_vector(C_CH_ADDR_WIDTH downto 0);
			dia : in std_logic_vector(C_CH_DATA_WIDTH downto 0);
			dob : out std_logic_vector(C_CH_DATA_WIDTH downto 0)
		);
	end component;

	-- RAM Channels signals
	signal ch_wea: std_logic_vector(3 downto 0);
	signal ch_enb: std_logic_vector(3 downto 0);

	-- Channel 0
	signal ch0_addra: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	signal ch0_dia: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- Channel 1
	signal ch1_addra: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	-- signal ch1_addrb: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	signal ch1_dia: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- signal ch1_dob: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- Channel 2
	signal ch2_addra: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	-- signal ch2_addrb: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	signal ch2_dia: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- signal ch2_dob: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- Channel 3
	signal ch3_addra: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	-- signal ch3_addrb: std_logic_vector(C_CH_ADDR_WIDTH downto 0);
	signal ch3_dia: std_logic_vector(C_CH_DATA_WIDTH downto 0);
	-- signal ch3_dob: std_logic_vector(C_CH_DATA_WIDTH downto 0);

	-- AXI4-Lite
	constant CH0_BASEADDR : integer :=    0; -- Channel 1 Data Register
	constant CH1_BASEADDR : integer := 2048; -- Channel 2 Data Register
	constant CH2_BASEADDR : integer := 4096; -- Channel 3 Data Register
	constant CH3_BASEADDR : integer := 6144; -- Channel 4 Data Register

	-- Write address integer
	signal wr_addr_s : integer := 0;

begin

	-- RAM Channels
	-- Port A is write only, Port B is read only

	inst_ch0_ram : entity channel_ram
	port map (
		clk => aclk,
		ena => ch_wea(0),
		wea => ch_wea(0),
		enb => ch_enb(0),
		addra => ch0_addra,
		addrb => ch0_addrb,
		dia => ch0_dia,
		dob => ch0_dob
	);

	inst_ch1_ram : entity channel_ram
	port map (
		clk => aclk,
		ena => ch_wea(1),
		wea => ch_wea(1),
		enb => ch_enb(1),
		addra => ch1_addra,
		addrb => ch1_addrb,
		dia => ch1_dia,
		dob => ch1_dob
	);

	inst_ch2_ram : entity channel_ram
	port map (
		clk => aclk,
		ena => ch_wea(2),
		wea => ch_wea(2),
		enb => ch_enb(2),
		addra => ch2_addra,
		addrb => ch2_addrb,
		dia => ch2_dia,
		dob => ch2_dob
	);

	inst_ch3_ram : entity channel_ram
	port map (
		clk => aclk,
		ena => ch_wea(3),
		wea => ch_wea(3),
		enb => ch_enb(3),
		addra => ch3_addra,
		addrb => ch3_addrb,
		dia => ch3_dia,
		dob => ch3_dob
	);

	



	-- ----------------------------------------------
	--  AXI4-Lite Registers (Read only)
	-- ----------------------------------------------

	wr_addr_s <= to_integer ( unsigned ( wr_addr_i ));
	-- Write register process
	wr_regs_proc : process ( aclk )
	begin
		if rising_edge ( aclk ) then
			if rst_n = '0' then
				ch_wea <= (others => '0');
			else
				if wr_valid_i = '1' then
					case wr_addr_s is
						-- Channels
						when CH0_BASEADDR to CH0_BASEADDR+2047 =>
							ch_wea <= (0 => '1', others => '0');
							ch0_addra <= std_logic_vector(unsigned(wr_addr_s - CH0_BASEADDR, 10));
							ch0_dia <= wr_data_i(10 downto 0);
							
						when CH1_BASEADDR to CH1_BASEADDR+2047 =>
							ch_wea <= (1 => '1', others => '0');
							ch1_addra <= std_logic_vector(unsigned(wr_addr_s - CH1_BASEADDR, 10));
							ch1_dia <= wr_data_i(10 downto 0);

						when CH2_BASEADDR to CH2_BASEADDR+2047 =>
							ch_wea <= (2 => '1', others => '0');
							ch2_addra <= std_logic_vector(unsigned(wr_addr_s - CH2_BASEADDR, 10));
							ch2_dia <= wr_data_i(10 downto 0);

						when CH3_BASEADDR to CH3_BASEADDR+2047 =>
							ch_wea <= (3 => '1', others => '0');
							ch3_addra <= std_logic_vector(unsigned(wr_addr_s - CH3_BASEADDR, 10));
							ch3_dia <= wr_data_i(10 downto 0);

						when others =>
							ch_wea <= (others => '0');

					end case;
				end if;
			end if;
		end if;
	end process wr_regs_proc;


end architecture;