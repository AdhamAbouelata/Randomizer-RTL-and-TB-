--====================================
-- prbs_verify.vhd HW2 ASIC DESIGN USING CAD
--====================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity prbs_verify is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;
        load: in std_logic;
        pass: out std_logic
    );
    end prbs_verify;
architecture prbs_verifier of prbs_verify is
component prbs 
   port(
    clk: in std_logic;
    reset: in std_logic;
    en: in std_logic;
    load: in std_logic;
    data_in: in std_logic;
    seed: in std_logic_vector(14 downto 0);
    data_out: out std_logic
   );
end component;

constant in_data_rom: std_logic_vector(95 downto 0) := x"ACBCD2114DAE1577C6DBF4C9"; -- "ROM" units
constant out_data_rom: std_logic_vector(95 downto 0) := x"558AC4A53A1724E163AC2BF9";
constant seed_rom: std_logic_vector(14 downto 0) := "101010001110110" ;
signal data_out: std_logic;
signal data_in_reg: std_logic_vector(95 downto 0) := in_data_rom; -- shift registers reading from the ROM units
signal data_in_next: std_logic_vector(95 downto 0);
signal data_out_reg: std_logic_vector(95 downto 0) := out_data_rom; 
signal data_out_next: std_logic_vector(95 downto 0);

begin
    lfsr: prbs -- instantiating the prbs design unit
      port map(
         clk => clk,
         reset => reset,
         en => en,
         load => load,
         data_in => data_in_reg(95),
         seed => seed_rom,
         data_out => data_out
      );
process(clk, reset) -- data_in_register
begin 
    if (reset='1') then
        data_in_reg <= in_data_rom; -- asynchronous reset element
        
    elsif (clk'event and clk='1' and load = '0' and en = '1') then -- inferrence of the register
        data_in_reg <= data_in_next;
        
    end if;
end process;
process(clk, reset) -- data_out_register
begin 
    if (reset='1') then
        data_out_reg <= out_data_rom; -- asynchronous reset element
    elsif (clk'event and clk='1' and load = '0' and en = '1') then
        data_out_reg <= data_out_next;
    end if;
end process;
-- output logic
process(data_out_reg, data_out)
begin
    pass <= data_out_reg(95) xor data_out;
end process;
-- next state logic
process (load, data_in_reg, data_out_reg)
begin
	if (load ='0') then -- data in and out shifts
		data_in_next <= data_in_reg(94 downto 0) & '0';
		data_out_next <= data_out_reg(94 downto 0) & '0';
	else -- retaining the value if the load is active
		data_in_next <= data_in_reg;
		data_out_next <= data_out_reg;
end if;
end process;

end prbs_verifier;