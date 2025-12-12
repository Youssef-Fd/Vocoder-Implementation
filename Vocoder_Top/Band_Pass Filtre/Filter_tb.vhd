library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Filtre_tb is
end Filtre_tb;

architecture testbench of Filtre_tb is

 
    component Filtre is
       
        port(
             CLK, RSTn              : in std_logic;
             xin                    : in signed(15 downto 0);
             valid_in               : in std_logic;
             yout                   : out signed(15 downto 0);
             valid_out              : out std_logic;
             b0, b1, b2, a1, a2     : in  signed(15 downto 0)
        );
    end component;

 
    signal CLK  : std_logic := '0';
    signal RSTn : std_logic := '0';

    signal xin        : signed(15 downto 0) := (others => '0');
    signal valid_in   : std_logic := '0';
    
    signal b0, b1, b2 : signed(15 downto 0);
    signal a1, a2     : signed(15 downto 0);

    signal yout        : signed(15 downto 0);
    signal valid_out   : std_logic;

    constant Fs          : real := 44100.0;
    constant CLK_PERIOD  : time := 1 sec / 44100; 

    -- Paramètres des Signaux de Test
    constant AMPLITUDE_SC : real := 0.8; 
    constant TEST_DURATION : real := 0.5;
    constant TEST_SAMPLES : integer := integer(TEST_DURATION * Fs);
    
    constant FREQ_PASS : real := 292.57;


    -- Génération d'échantillons sinusoïdaux
    function generate_test_signal(n : integer; fs : real; sine_freq : real) return signed is
        variable t        : real;
        variable phase    : real;
        variable sine_val : real;
        variable scaled   : integer;
    begin
        t := real(n) / fs;
        phase := 2.0 * MATH_PI * sine_freq * t;
        sine_val := sin(phase);
        scaled := integer(sine_val * 32767.0 * AMPLITUDE_SC); 
        return to_signed(scaled, 16);
    end function;

begin

    -- Horloge
    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    
    DUT : Filtre
        port map (
            CLK                => CLK,
            RSTn               => RSTn,
            xin                => xin,
            valid_in           => valid_in,
            yout               => yout,
            valid_out          => valid_out,
            b0 => b0, b1 => b1, b2 => b2, a1 => a1, a2 => a2
        );


    stim_process : process
    begin
     
        RSTn <= '0';
        valid_in <= '0';
        wait for CLK_PERIOD*10;
        RSTn <= '1';
        wait for CLK_PERIOD*5;
        
        -- Chargement des coefficients du filtre Passe-Bande
        b0 <= to_signed(2313, 16); 
        b1 <= to_signed(0, 16);  
        b2 <= to_signed(-2313, 16);  
        a1 <= to_signed(-65477, 16);
        a2 <= to_signed(30455, 16);
        
        valid_in <= '1';
        wait for CLK_PERIOD*2;
        
        
        for i in 0 to TEST_SAMPLES-1 loop
            xin <= generate_test_signal(i, Fs, FREQ_PASS);
            wait for CLK_PERIOD;
        end loop;
  
  
        valid_in <= '0';
        xin <= (others => '0');
        wait for CLK_PERIOD*200;

        wait;
    end process;

end testbench;