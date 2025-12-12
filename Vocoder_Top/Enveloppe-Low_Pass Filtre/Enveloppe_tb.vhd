library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Enveloppe_tb is
end Enveloppe_tb;

architecture testbench of Enveloppe_tb is

    component Enveloppe is
        port(
            CLK, RSTn              : in  std_logic;
            xin                    : in  signed(15 downto 0);
            valid_in               : in  std_logic;
            yout                   : out signed(15 downto 0);
            valid_out              : out std_logic;
            b0, b1, b2, a1, a2     : in  signed(15 downto 0)
        );
    end component;

    signal CLK        : std_logic := '0';
    signal RSTn       : std_logic := '0';
    signal xin        : signed(15 downto 0) := (others => '0');
    signal valid_in   : std_logic := '0';
    signal yout       : signed(15 downto 0);
    signal valid_out  : std_logic;
    signal b0, b1, b2 : signed(15 downto 0);
    signal a1, a2     : signed(15 downto 0);

    -- Clock 100 kHz (period = 10 us)
    constant CLK_PERIOD : time := 22.6757 us;

    constant Fs : real := 44100.0;

    constant CARRIER_FREQ     : real := 1000.0;
    constant MODULATION_FREQ  : real := 5.0;
    constant MODULATION_DEPTH : real := 0.8;
    constant DURATION         : real := 3.0;

    constant NUM_SAMPLES : integer := integer(Fs * DURATION);

    function generate_am_signal(n : integer; fs : real) return signed is
        variable t         : real;
        variable envelope  : real;
        variable carrier   : real;
        variable sample    : real;
        variable scaled    : integer;
    begin
        t := real(n) / fs;

        envelope := 1.0 + MODULATION_DEPTH * cos(2.0 * MATH_PI * MODULATION_FREQ * t);
        carrier  := cos(2.0 * MATH_PI * CARRIER_FREQ * t);

        sample := envelope * carrier;

        scaled := integer(sample * 16383.0);

        return to_signed(scaled, 16);
    end function;

begin

    CLK <= not CLK after CLK_PERIOD/2;


    DUT : Enveloppe
        port map (
            CLK       => CLK,
            RSTn      => RSTn,
            xin       => xin,
            valid_in  => valid_in,
            yout      => yout,
            valid_out => valid_out,
            b0        => b0,
            b1        => b1,
            b2        => b2,
            a1        => a1,
            a2        => a2
        );

 
    stim_proc : process
    begin
        -- Reset
        RSTn <= '0';
        valid_in <= '0';
        wait for 4 * CLK_PERIOD;

        RSTn <= '1';
        wait for 2 * CLK_PERIOD;


        b0 <= to_signed(1638, 16);        
        b1 <= to_signed(0,    16);
        b2 <= to_signed(0,     16);
        a1 <= to_signed(-31130, 16);       
        a2 <= to_signed(0, 16);

        wait for 2 * CLK_PERIOD;

        valid_in <= '1';

        for i in 0 to NUM_SAMPLES-1 loop
            xin <= generate_am_signal(i, Fs);
            wait for CLK_PERIOD;
        end loop;

        valid_in <= '0';
        xin <= (others => '0');

        wait;
    end process;

end testbench;
