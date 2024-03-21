-- video_generator.vhd
-- Reads channel data from ram and generates an axi stream video

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity video_generator is
	generic (
		C_CH_DATA_WIDTH: integer := 11;
		C_CH_ADDR_WIDTH: integer := 11
	);
	port (
		pxlclk  : in std_logic;
		rst_n   : in std_logic;

		-- Channels RAM Output for video generator
		ch_enb			: out std_logic_vector(3 downto 0);
		-- Channel 0
		ch0_addrb		: out std_logic_vector((C_CH_ADDR_WIDTH-1) downto 0);
		ch0_dob			: in  std_logic_vector((C_CH_DATA_WIDTH-1) downto 0);
		-- Channel 0
		ch1_addrb		: out std_logic_vector((C_CH_ADDR_WIDTH-1) downto 0);
		ch1_dob			: in  std_logic_vector((C_CH_DATA_WIDTH-1) downto 0);
		-- Channel 0
		ch2_addrb		: out std_logic_vector((C_CH_ADDR_WIDTH-1) downto 0);
		ch2_dob			: in  std_logic_vector((C_CH_DATA_WIDTH-1) downto 0);
		-- Channel 0
		ch3_addrb		: out std_logic_vector((C_CH_ADDR_WIDTH-1) downto 0);
		ch3_dob			: in  std_logic_vector((C_CH_DATA_WIDTH-1) downto 0);

		-- Video out
		hsync	: out std_logic;
		vsync	: out std_logic;
		vde		: out std_logic;
		vdata	: out std_logic_vector(23 downto 0)


	);
end entity video_generator;

architecture rtl of video_generator is

	component video_ctrl
	generic (
		freq_clk : integer;
		H_sync_polarity : std_logic;
		V_sync_polarity : std_logic;
		H_Visible : integer;
		H_Front_porch : integer;
		H_Sync_pulse : integer;
		H_Back_porch : integer;
		V_Visible : integer;
		V_Front_porch : integer;
		V_Sync_pulse : integer;
		V_Back_porch : integer
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		Hcount : out std_logic_vector(12 downto 0);
		Vcount : out std_logic_vector(12 downto 0);
		H_sync : out std_logic;
		V_sync : out std_logic;
		vde : out std_logic;
		frame : out std_logic
	);
	end component;

	signal vcount: std_logic_vector(12 downto 0);
	signal hcount: std_logic_vector(12 downto 0);
	signal hcount_i: integer;
	signal vcount_i: integer;
	signal frame: std_logic;

	signal rst: std_logic;

begin

	rst <= not rst_n;

	hcount_i <= to_integer(unsigned(hcount));
	vcount_i <= to_integer(unsigned(vcount));

	video_ctrl_inst : entity work.video_ctrl
	generic map (
		freq_clk => 148500000,
		H_sync_polarity => '1',
		V_sync_polarity => '1',
		H_Visible => 1920,
		H_Front_porch => 88,
		H_Sync_pulse => 44,
		H_Back_porch => 148,
		V_Visible => 1080,
		V_Front_porch => 4,
		V_Sync_pulse => 5,
		V_Back_porch => 36
	)
	port map (
		clk => pxlclk,
		rst => rst,
		Hcount => hcount,
		Vcount => vcount,
		H_sync => hsync,
		V_sync => vsync,
		vde => vde,
		frame => frame
	);
	
	-- Map pixel counter to addresses
	-- counter starts at 1, so we should get the right pixel at the right time
	ch0_addrb <= hcount((C_CH_ADDR_WIDTH-1) downto 0);
	ch1_addrb <= hcount((C_CH_ADDR_WIDTH-1) downto 0);
	ch2_addrb <= hcount((C_CH_ADDR_WIDTH-1) downto 0);
	ch3_addrb <= hcount((C_CH_ADDR_WIDTH-1) downto 0);

	process (pxlclk)
	begin
		if rising_edge(pxlclk) then
			-- Display signals
			if (hcount_i >= 110 and hcount_i <= 1810) and (vcount_i >= 140 and vcount_i <= 940) then
				ch_enb <= (others => '1');
				if to_integer(unsigned(ch0_dob)) = vcount_i then
					vdata <= x"FF0000";
				elsif to_integer(unsigned(ch1_dob)) = vcount_i then
					vdata <= x"00FF00";
				-- elsif to_integer(unsigned(ch2_dob)) = vcount_i then
				-- 	vdata <= x"0000FF";
				-- elsif to_integer(unsigned(ch3_dob)) = vcount_i then
				-- 	vdata <= x"FFFF00";
				-- problemes de timings -10ns WNS
				-- elsif (((vcount_i-140) mod 80) = 0) or (((hcount_i-110) mod 170) = 0) then
				-- 	vdata <= x"808080";
				else
					vdata <= x"000000";
				end if;
			else
				ch_enb <= (others => '0');
				vdata <= x"F0F0F0";
			end if;	
		end if;
	end process;

	-- vdata <= x"808080" when (to_integer(unsigned(hcount)) >= 110 and to_integer(unsigned(hcount)) <= 1810) and (to_integer(unsigned(vcount)) >= 140 and to_integer(unsigned(vcount)) <= 940) else x"000000";
	

end architecture;