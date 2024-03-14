library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity video_ctrl is
	generic (
		freq_clk: 			integer 	:= 50000000; 
		H_sync_polarity: 	std_logic 	:= '1'; 	-- Sync polarity - 1 positive, 0 negative
		V_sync_polarity: 	std_logic 	:= '1'; 	-- Sync polarity - 1 positive, 0 negative
		H_Visible: 			integer 	:= 10; 	-- nombre de pixels visibles
		H_Front_porch: 		integer		:= 2; 		-- nombre de cycles porch
		H_Sync_pulse: 		integer 	:= 2;		-- nombre de cycles H_sync
		H_Back_porch: 		integer 	:= 2;		-- nombre de cycles porch
		V_Visible: 			integer 	:= 5;		-- nombre de lignes visibles
		V_Front_porch: 		integer 	:= 2;		-- nombre de lignes porch
		V_Sync_pulse: 		integer 	:= 2;		-- nombre de lignes V_sync
		V_Back_porch: 		integer 	:= 2		-- nombre de lignes porch
	);
	port (
		clk 	: in std_logic;				-- clk d'entr?e
		rst 	: in std_logic;				-- reset
		Hcount 	: out std_logic_vector(12 downto 0);	-- Cordonn?e du pixel horizontale ? afficher
		Vcount 	: out std_logic_vector(12 downto 0);	-- Cordonn?e du pixel horizontale ? afficher
		H_sync  : out std_logic;			-- Signal de synchronization
		V_sync  : out std_logic;			-- Signal de synchronization
		vde   : out std_logic;			    -- 1 si pixel visible, 0 si non visible (porch ou sync)
		frame   : out std_logic
	);
	
end video_ctrl;

architecture Behavioral of video_ctrl is

	signal hcount_sig, vcount_sig: 	integer 	:= 1;

begin

	hsync_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				hcount_sig <= 1;
			else

				if hcount_sig = (H_Visible + H_Front_porch + H_Sync_pulse + H_Back_porch) then
					hcount_sig <= 1;				-- reset the horizontal counter
				else 
					hcount_sig <= hcount_sig + 1;	-- increment the horizontal counter
				end if;
				
			end if;
		end if;
	end process;


	vsync_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				vcount_sig <= 1;
			else
			
				if hcount_sig = (H_Visible + H_Front_porch + H_Sync_pulse + H_Back_porch) then
					if vcount_sig = (V_Visible + V_Front_porch + V_Sync_pulse + V_Back_porch) then
						vcount_sig <= 1;				-- reset the vertical counter
					else 
						vcount_sig <= vcount_sig + 1;	-- increment the horizontal counter
					end if;
				end if;
				
			end if;
		end if;
	end process;

	ctrl_proc: process(hcount_sig, vcount_sig)
	begin

		-- Generate hsync
		if (hcount_sig > (H_Visible + H_Front_porch)) and (hcount_sig <= (H_Visible + H_Front_porch + H_Sync_pulse)) then
			H_sync <= '1' xnor H_sync_polarity;
		else
			H_sync <= '0' xnor H_sync_polarity;
		end if;
		
		-- Generate vsync
		if (vcount_sig > (V_Visible + V_Front_porch)) and (vcount_sig <= (V_Visible + V_Front_porch + V_Sync_pulse)) then
			V_sync <= '1' xnor V_sync_polarity;
		else
			V_sync <= '0' xnor V_sync_polarity;
		end if;

		-- generate vde
		if (hcount_sig <= H_Visible) and (vcount_sig <= V_Visible) then
			vde <= '1';
		else
			vde <= '0';
		end if;
		
		-- generate frame
		if hcount_sig = (H_Visible + H_Front_porch + H_Sync_pulse + H_Back_porch) and vcount_sig = (V_Visible + V_Front_porch + V_Sync_pulse + V_Back_porch) then
			frame <= '1';
		else
			frame <= '0';
		end if;

		
		Hcount <= std_logic_vector(to_unsigned(hcount_sig, 13));
		Vcount <= std_logic_vector(to_unsigned(vcount_sig, 13));
	end process;
	
	
end Behavioral;
