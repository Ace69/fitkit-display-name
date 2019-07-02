library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port ( -- Sem doplnte popis rozhrani obvodu.
  SMCLK   : in std_logic;
  RESET   : in std_logic;
  ROW     : out std_logic_vector(0 to 7);
  LED     : out std_logic_vector(0 to 7)
);
end ledc8x8;

architecture main of ledc8x8 is

    -- Sem doplnte definice vnitrnich signalu.
    signal ce : std_logic;
    signal ce_cnt : std_logic_vector(11 downto 0) :="000000000000";
    signal rad : std_logic_vector(7 downto 0)  :="00000000";
    signal ledk : std_logic_vector(7 downto 0) :="00000000";
	 signal stav : std_logic_vector(1 downto 0) :="00";
	 signal change : std_logic_vector(20 downto 0) :="000000000000000000000";

begin

    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.s

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.
    

		
	 --rotacak
pos_reg: process(RESET,SMCLK,ce)
	begin
		if (RESET = '1') then --inicializace, v pripade absence neni odkud pocitat
			rad <= "00000001";
			elsif (rising_edge(SMCLK) and ce ='1') then --pokud je nabezna hrana
						rad <= rad(0) & rad(7 downto 1); -- provede se posuv o jedno dolu konkatenaci
				ROW <= rad;
			end if;
	end process pos_reg;
	
delic : process(RESET,SMCLK) 
	begin
		if (RESET = '1') then
			ce_cnt <= "000000000000";
		elsif (rising_edge(SMCLK)) then
			ce_cnt<=ce_cnt+1;
		end if;
	end process delic;
	ce <= '1' when ce_cnt = "111000010000" else '0';
	
	
stavy : process (RESET,SMCLK)
	begin
		if (RESET = '1') then
			change <= (others => '0');
		elsif (rising_edge(SMCLK)) then
			change <= change + 1;
			if(change = "111000010000000000000") then
				stav <= stav +1;
				change <= (others => '0');
			end if;
		end if;
	end process stavy;
		
	--dekoder ledek
led_dec1: process(RESET,SMCLK, rad)
	begin
			if(SMCLK'event and SMCLK = '1') then
				if (RESET = '1') then
					ledk <= "11111111";
					else 
						if(stav = "00") then
							case rad is
								when "10000000" => ledk <= "11110111"; --1 
								when "01000000" => ledk <= "11110111"; --2
								when "00100000" => ledk <= "11110111"; --3
								when "00010000" => ledk <= "11110111"; --4
								when "00001000" => ledk <= "10110111"; --5
								when "00000100" => ledk <= "10110111"; --6
								when "00000010" => ledk <= "10000111"; --7
								when "00000001" => ledk <= "11111111"; --8
								when others =>		 ledk <= "11111111"; -- ostatni, zhasnute ledky
							end case;
							elsif (stav = "01") then
								case rad is
								when "10000000" => ledk <= "11111111"; --1
								when "01000000" => ledk <= "11111111"; --2
								when "00100000" => ledk <= "11111111"; --3
								when "00010000" => ledk <= "11111111"; --4
								when "00001000" => ledk <= "11111111"; --5
								when "00000100" => ledk <= "11111111"; --6
								when "00000010" => ledk <= "11111111"; --7
								when "00000001" => ledk <= "11111111"; --8
								when others => 	 ledk <= "11111111"; -- ostatni, zhasnute ledky
							end case;
							elsif (stav = "10") then
								case rad is
								when "10000000" => ledk <= "11111111"; --1
								when "01000000" => ledk <= "10011111"; --2
								when "00100000" => ledk <= "10101111"; --3
								when "00010000" => ledk <= "10110111"; --4
								when "00001000" => ledk <= "10110111"; --5
								when "00000100" => ledk <= "10101111"; --6
								when "00000010" => ledk <= "10011111"; --7
								when "00000001" => ledk <= "10111111"; --8
								when others => 	 ledk <= "11111111"; -- ostatni, zhasnute ledky
							end case;
							elsif (stav = "11") then
								case rad is
								when "10000000" => ledk <= "11111111"; --1
								when "01000000" => ledk <= "11111111"; --2
								when "00100000" => ledk <= "11111111"; --3
								when "00010000" => ledk <= "11111111"; --4
								when "00001000" => ledk <= "11111111"; --5
								when "00000100" => ledk <= "11111111"; --6
								when "00000010" => ledk <= "11111111"; --7
								when "00000001" => ledk <= "11111111"; --8
								when others => 	 ledk <= "11111111"; -- ostatni, zhasnute ledky
							end case;
					end if;
				end if;
			end if;
	end process led_dec1;					
LED <= ledk;
	
	
--	led_dec2: process(RESET,SMCLK, rad)
--	begin
--			if(SMCLK'event and SMCLK = '1') then
--				case rad is
--					when "10000000" => ledk <= "11111111"; --1
--					when "01000000" => ledk <= "10011111"; --2
--					when "00100000" => ledk <= "10101111"; --3
--					when "00010000" => ledk <= "10110111"; --4
--					when "00001000" => ledk <= "1011011"; --5
--					when "00000100" => ledk <= "10101111"; --6
--					when "00000010" => ledk <= "10011111"; --7
--					when "00000001" => ledk <= "10111111"; --8
--					when others => 	 ledk <= "11111111"; -- ostatni, zhasnute ledky
--				end case;
--			end if;
--	end process led_dec2;	
	
end main;
