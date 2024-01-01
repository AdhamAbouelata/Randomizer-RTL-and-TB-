--====================================
-- prbs.vhd HW2 ASIC DESIGN USING CAD
--====================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity prbs is
    port(
       clk: in std_logic;
       reset: in std_logic;
       en: in std_logic;
       load: in std_logic;
       data_in: in std_logic;
       seed: in std_logic_vector(14 downto 0);
       data_out: out std_logic
    );
 end prbs;

architecture lfsr of prbs is
-- signal declaration
    signal r_reg: std_logic_vector(14 downto 0);
    signal r_next: std_logic_vector(14 downto 0);
    signal lsb: std_logic;
begin
-- inferring the register
    process(clk,reset)
    begin
        if (reset='1') then
            r_reg <= (others=>'0'); -- asynchronous reset element
        elsif (clk'event and clk='1') then
            if (load = '1') then -- inferring a multiplexer to load the seed
                r_reg <= seed;
            elsif(en = '1') then
                r_reg <= r_next;
            end if;
        end if;
    end process;
    -- next state logic
    lsb <= r_reg (13) xor r_reg(14); -- next_state LSB
    r_next <= r_reg (13 downto 0) & lsb; -- next_state register value
    -- output logic
    data_out <= lsb xor data_in; -- psuedo-random bit output
end lfsr;