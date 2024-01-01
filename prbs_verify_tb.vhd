--===============================================
-- prbs_verify_tb.vhd SELF-CHECKING TESTBENCH for PRBS
--===============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prbs_verify_tb is
end prbs_verify_tb;

architecture tb of prbs_verify_tb is
component prbs_verify
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;
        load: in std_logic;
        pass: out std_logic
    );
end component;
signal pass: std_logic;
signal clk: std_logic := '1';
signal reset: std_logic;
signal en: std_logic;
signal load: std_logic;
constant period : time := 10 ns;
begin
    uut: prbs_verify
        port map(
            clk => clk,
            reset => reset,
            en => en,
            load => load,
            pass => pass
        );
    clk <= not clk after period/2;
    process --stimulus
    begin
        reset <= '0';
        load <= '1'; -- loading the seed
        en <= '0'; -- disabling the shift
        wait for (period); -- allowing the load
        load <= '0'; -- deasserting the load signal so that the shifting occurs
        en <= '1'; -- enabling the shift
        wait for (96*period);
        reset <= '1'; -- testing reset
        wait for (period);
    end process;
    process(pass) -- verifier
    begin
        if (load = '0' and en = '1' and reset = '0') then
            assert (pass = '0') -- self checking
                report "test failed"
                severity note;
        end if;
    end process;
end tb;
        
