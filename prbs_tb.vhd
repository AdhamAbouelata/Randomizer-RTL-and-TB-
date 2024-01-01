--===============================================
-- prbs_tb.vhd SELF-CHECKING TESTBENCH for PRBS
--===============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prbs_tb is
end prbs_tb;

architecture self_checking_tb of prbs_tb is
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
signal clk   : std_logic := '1'; -- internal test signals
signal reset : std_logic := '0';
signal en    : std_logic := '0';
signal load  : std_logic := '0';
signal data_in: std_logic;
signal seed: std_logic_vector(14 downto 0);
signal data_out: std_logic;
signal test_vector: std_logic_vector(95 downto 0); -- test vector declaration
signal expected_output: std_logic_vector(95 downto 0);
constant period : time := 10 ns;

begin
   uut: prbs -- instantiating the unit under test
      port map(
         clk => clk,
         reset => reset,
         en => en,
         load => load,
         data_in => data_in,
         seed => seed,
         data_out => data_out
      );
   clk <= not clk after period/2;
   seed <= "101010001110110"; -- initial specified seed
   test_vector <= x"ACBCD2114DAE1577C6DBF4C9"; -- test vector
   expected_output <= x"558AC4A53A1724E163AC2BF9";
   process --stimulus
   begin
      reset <= '0';
      load <= '1'; -- loading the seed
      en <= '0'; -- disabling the shift
      wait for (period); -- allowing the shift
      load <= '0'; -- deasserting the load signal so that the shifting occurs
      en <= '1'; -- enabling the shift
      data_in <= test_vector(95); -- first test case before the loop due to the inital load delay
      for i in 0 to 94 loop -- the rest of the 95 cases
         wait for (period);
         data_in <= test_vector(94-i);
      end loop;
      reset <= '1'; -- testing the reset
      wait for (period);
   end process;

   process -- verifier
   begin
		wait for (period);
      wait until falling_edge(clk);
      for i in 0 to 95 loop -- there are 96 data inputs specified in the document
         assert (expected_output(95-i)=data_out) -- self checking
            report "test failed"
            severity note;
         wait for (period);
      end loop;
      wait for (period);
   end process;
end self_checking_tb;