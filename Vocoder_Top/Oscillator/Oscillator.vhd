library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;  

entity Oscillator is
    port(
        CLK     : in  std_logic;
        RSTn    : in  std_logic;
        step    : in  unsigned(15 downto 0);
        ready_i : in  std_logic;
        yout    : out signed(15 downto 0)
    );
end Oscillator;

architecture RTL of Oscillator is

    constant TABLE_SIZE : integer := 256;
    type sine_table_t is array (0 to TABLE_SIZE-1) of signed(15 downto 0);
    
    function generate_sine_table return sine_table_t is
        variable table      : sine_table_t;
        variable phase      : real;
        variable sine_value : real;
    begin
        for i in 0 to TABLE_SIZE-1 loop
            phase      := real(i) * 2.0 * MATH_PI / real(TABLE_SIZE);
            sine_value := sin(phase);
            table(i)   := to_signed(integer(sine_value * 32767.0), 16);
        end loop;
        return table;
    end function;
    
    constant SINE_LUT   : sine_table_t := generate_sine_table;
    signal phase_acc    : unsigned(15 downto 0);
    signal table_index  : natural range 0 to TABLE_SIZE-1;  
    signal sine_value   : signed(15 downto 0);
    
begin

    Phase_accumulator: process(CLK, RSTn)
    begin
        if RSTn = '0' then
            phase_acc <= (others => '0');
        elsif rising_edge(CLK) then
            if ready_i = '1' then
                phase_acc <= phase_acc + step;
            end if;
        end if;
    end process;
    
    table_index <= to_integer(phase_acc(15 downto 8));

    Phase_amplitude_converter: process(CLK, RSTn)
    begin
        if RSTn = '0' then
            sine_value <= (others => '0');
        elsif rising_edge(CLK) then
            if ready_i = '1' then
                sine_value <= SINE_LUT(table_index);
            end if;
        end if;
    end process;
    
    yout <= sine_value;
end RTL;