library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity TB_Vocoder_top is
end TB_Vocoder_top;

architecture TB of TB_Vocoder_top is

    -- Déclaration du DUT (Device Under Test)
    component Vocoder_top is
        port(
            CLK, RSTn        : in std_logic;
            xin              : in signed(15 downto 0);
            valid_in         : in std_logic;
            vocoder_out      : out signed(15 downto 0);
            valid_out        : out std_logic
        );
    end component;

    -- Signaux et Constantes d'Horloge
    signal CLK      : std_logic := '0';
    signal RSTn     : std_logic := '0';
    

    signal xin      : signed(15 downto 0) := (others => '0');
    signal valid_in : std_logic := '0';
    
    signal vocoder_out : signed(15 downto 0);
    signal valid_out   : std_logic;

   constant CLK_PERIOD : time := 22.6757 us;
    constant Fs : real := 44100.0;

    constant CARRIER_FREQ     : real := 1500.0;
    constant MODULATION_FREQ  : real := 5.0;
    constant MODULATION_DEPTH : real := 0.8;
    constant DURATION         : real := 2.0;

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

    DUT: entity work.Vocoder_top
        port map(
            CLK          => CLK,
            RSTn         => RSTn,
            xin          => xin,
            valid_in     => valid_in,
            vocoder_out  => vocoder_out,
            valid_out    => valid_out
        );

    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    rst_proc : process
    begin
        RSTn <= '0';
        wait for 200 ns;
        RSTn <= '1';
        wait;
    end process;

    stimulus_proc : process
        variable sample_index : integer := 0;
    begin
        wait until RSTn = '1';
        wait for 50 ns;

        valid_in <= '1';
        
        for i in 0 to NUM_SAMPLES-1 loop
            xin <= generate_am_signal(i, Fs);
            wait for CLK_PERIOD;
        end loop;

        
        valid_in <= '0';
        xin <= (others => '0');
        wait for 5000 ns;
        wait;
    end process;

end TB;