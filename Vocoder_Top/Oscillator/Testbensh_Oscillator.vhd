library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Oscillator_tb is
end Oscillator_tb;

architecture testbench of Oscillator_tb is

    -- Component Declaration for the DUT (Device Under Test)
    component Oscillator is
        port(
            CLK     : in  std_logic;
            RSTn    : in  std_logic;
            step    : in  unsigned(15 downto 0);
            ready_i : in  std_logic;
            yout    : out signed(15 downto 0)
        );
    end component;

    
    constant CLK_FREQ_HZ : real :=44100.0; 
    constant CLK_PERIOD  : time := 1.0 / CLK_FREQ_HZ * 1 sec; 

   
    constant PHASE_WIDTH : integer := 16; 
    constant TABLE_SIZE  : integer := 256; 
    
    -- Desired Output Frequency (Fout)
    constant FOUT_HZ     : real := 292.57; 
    
    -- Formula for the STEP value: STEP = (FOUT * 2^PHASE_WIDTH) / Fclk
    -- STEP = (195312.5 * 2^16) / 50,000,000 = (195312.5 * 65536) / 50,000,000 = 256.0
    -- The integer part of 256.0 is 256.
    constant STEP_CALCULATED : real := FOUT_HZ * real(2**PHASE_WIDTH) / CLK_FREQ_HZ;
    constant STEP_INTEGER    : natural := integer(STEP_CALCULATED);

    -- Testbench Signals
    signal CLK     : std_logic := '0';
    signal RSTn    : std_logic := '0';
    signal ready_i : std_logic := '1'; -- Keep ready active for continuous output
    signal step    : unsigned(15 downto 0) := (others => '0');
    signal yout    : signed(15 downto 0);


begin

    -- 1. DUT Instantiation
    DUT : Oscillator
        port map (
            CLK     => CLK,
            RSTn    => RSTn,
            step    => step,
            ready_i => ready_i,
            yout    => yout
        );

    -- 2. Clock Generation Process
    CLK_PROCESS : process
    begin
        loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- 3. Stimulus Process
    STIM_PROCESS : process
    begin
        
        RSTn <= '0';
        step <= (others => '0');
        wait for CLK_PERIOD * 10;
        RSTn <= '1';
        wait for CLK_PERIOD * 5;
        
        step <= to_unsigned(STEP_INTEGER, 16);
      
        wait for 10 ms;
        wait;
    end process;

end testbench;