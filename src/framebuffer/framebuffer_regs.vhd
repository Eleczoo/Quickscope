-- Description : Counts all the time, can be read and written via axi 4 lite

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framebuffer_regs is
	generic (
		C_DATA_WIDTH : integer := 32;
		C_ADDR_WIDTH : integer := 13
	);
	port (
		aclk: 	in 	std_logic;
		rst_n: 	in 	std_logic;
		
		-- AXI4-Lite 
		-- Write register interface
		wr_valid_i    : in std_logic;
		wr_addr_i     : in std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		wr_data_i     : in std_logic_vector((C_DATA_WIDTH - 1) downto 0);
		-- Read register interface
		rd_valid_i    : in std_logic;
		rd_addr_i     : in std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
		rd_data_o     : out std_logic_vector((C_DATA_WIDTH - 1) downto 0)
	);

end entity framebuffer_regs;

architecture rtl of framebuffer_regs is
	
	-- Components
	component channel_ram
		port (
			clk : in std_logic;
			we : in std_logic;
			en : in std_logic;
			addr : in std_logic_vector(10 downto 0);
			di : in std_logic_vector(15 downto 0);
			do : out std_logic_vector(15 downto 0)
		);
	end component;

	-- RAM Channels signals
	signal ch_we: std_logic_vector(3 downto 0);
	signal ch_en: std_logic_vector(3 downto 0);

	-- Channel 0
	signal ch0_addr: std_logic_vector(10 downto 0);
	signal ch0_di: std_logic_vector(9 downto 0);
	signal ch0_do: std_logic_vector(9 downto 0);
	-- Channel 1
	signal ch1_addr: std_logic_vector(10 downto 0);
	signal ch1_di: std_logic_vector(9 downto 0);
	signal ch1_do: std_logic_vector(9 downto 0);
	-- Channel 2
	signal ch2_addr: std_logic_vector(10 downto 0);
	signal ch2_di: std_logic_vector(9 downto 0);
	signal ch2_do: std_logic_vector(9 downto 0);
	-- Channel 3
	signal ch3_addr: std_logic_vector(10 downto 0);
	signal ch3_di: std_logic_vector(9 downto 0);
	signal ch3_do: std_logic_vector(9 downto 0);

	-- AXI4-Lite
	constant CH0_BASEADDR : integer :=    0; -- Channel 1 Data Register
	constant CH1_BASEADDR : integer := 2048; -- Channel 2 Data Register
	constant CH2_BASEADDR : integer := 4096; -- Channel 3 Data Register
	constant CH3_BASEADDR : integer := 6144; -- Channel 4 Data Register

	-- Write address integer
	signal wr_addr_s : integer := 0;
	-- Read address integer
	signal rd_addr_s : integer := 0;
	-- Read data
	signal rd_data_s : std_logic_vector (( C_DATA_WIDTH - 1) downto 0) := ( others => '0');

begin

	-- RAM Channels

	channel_0_ram_inst : entity channel_ram
	port map (
		clk  => aclk,
		we 	 => ch_we(0),
		en   => ch_en(0),
		addr => ch0_addr,
		di 	 => ch0_di,
		do 	 => ch0_do
	);

	channel_1_ram_inst : entity channel_ram
	port map (
		clk  => aclk,
		we 	 => ch_we(1),
		en   => ch_en(1),
		addr => ch1_addr,
		di 	 => ch1_di,
		do 	 => ch1_do
	);

	channel_2_ram_inst : entity channel_ram
	port map (
		clk  => aclk,
		we 	 => ch_we(2),
		en   => ch_en(2),
		addr => ch2_addr,
		di 	 => ch2_di,
		do 	 => ch2_do
	);

	channel_3_ram_inst : entity channel_ram
	port map (
		clk  => aclk,
		we 	 => ch_we(3),
		en   => ch_en(3),
		addr => ch3_addr,
		di 	 => ch3_di,
		do 	 => ch3_do
	);

	



	-- ----------------------------------------------
	--  AXI4-Lite Registers 
	-- ----------------------------------------------

	wr_addr_s <= to_integer ( unsigned ( wr_addr_i ));
	-- Write register process
	wr_regs_proc : process ( aclk )
	begin
		if rising_edge ( aclk ) then
			if rst_n = '0' then
				ch_en <= (others => '0');
				ch_we <= (others => '0');
			else
				if wr_valid_i = '1' then
					case wr_addr_s is
						ch_en <= (others => '0');
						ch_we <= (others => '0');
						
						-- Channels
						when CH0_BASEADDR to CH0_BASEADDR+2047 =>
							ch_en <= (0 => '1', others => '0');
							ch_we <= (0 => '1', others => '0');
							ch0_addr <= std_logic_vector(unsigned(wr_addr_s - CH0_BASEADDR, 10));
							ch0_di <= wr_data_i(9 downto 0);
							
						when CH1_BASEADDR to CH1_BASEADDR+2047 =>
							ch_en <= (1 => '1', others => '0');
							ch_we <= (1 => '1', others => '0');
							ch1_addr <= std_logic_vector(unsigned(wr_addr_s - CH1_BASEADDR, 10));
							ch1_di <= wr_data_i(9 downto 0);

						when CH2_BASEADDR to CH2_BASEADDR+2047 =>
							ch_en <= (2 => '1', others => '0');
							ch_we <= (2 => '1', others => '0');							
							ch2_addr <= std_logic_vector(unsigned(wr_addr_s - CH2_BASEADDR, 10));
							ch2_di <= wr_data_i(9 downto 0);

						when CH3_BASEADDR to CH3_BASEADDR+2047 =>
							ch_en <= (3 => '1', others => '0');
							ch_we <= (3 => '1', others => '0');
							ch3_addr <= std_logic_vector(unsigned(wr_addr_s - CH3_BASEADDR, 10));
							ch3_di <= wr_data_i(9 downto 0);


						when others =>
					end case;
				end if;
			end if;
		end if;
	end process wr_regs_proc;


	rd_addr_s <= to_integer ( unsigned ( rd_addr_i ));
	-- Read register process
	rd_regs_proc : process ( aclk )
	begin
		if rising_edge ( aclk ) then
			if rst_n = '0' then
				rd_data_s <= ( others => '0');
			else
				rd_data_s <= rd_data_s;
				if rd_valid_i = '1' then
					case rd_addr_s is
						when others =>
							rd_data_s <= ( others => '0');
					end case;
				end if;
			end if;
		end if;
	end process rd_regs_proc;
	rd_data_o <= rd_data_s;

end architecture;