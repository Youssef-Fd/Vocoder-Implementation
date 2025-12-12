library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


entity Enveloppe is

  port
    (
       CLK, RSTn              : in std_logic;
       xin                    : in signed(15 downto 0);
       valid_in               : in std_logic;
       yout                   : out signed(15 downto 0);
       valid_out              : out std_logic;
       b0, b1, b2, a1, a2     : in  signed(15 downto 0)
	);

end Enveloppe;


architecture RTL of Enveloppe is

  type t_mult is array(0 to 4) of signed(31 downto 0);
  signal x_z1, x_z2, y_z1, y_z2 : signed(15 downto 0) ;
  
 

begin
    
    process(CLK, RSTn)
        variable mult_v   : t_mult;
        variable acc_v    : signed(31 downto 0);
        variable abs_data : signed(15 downto 0);
    begin
    
        if RSTn = '0' then
         
            x_z1 <= (others => '0');
            x_z2 <= (others => '0');
            y_z1 <= (others => '0');
            y_z2 <= (others => '0');
            yout <= (others => '0');
            valid_out <= '0';
            
        elsif rising_edge(CLK) then
        
             if xin < 0 then
                    abs_data := -xin;
            else
                    abs_data := xin;
            end if;
            
            valid_out <= valid_in;
            if valid_in = '1' then
                mult_v(0) := abs_data  *  b0;
                mult_v(1) := x_z1 *  b1;
                mult_v(2) := x_z2 *  b2;
                mult_v(3) := y_z1 *  a1;
                mult_v(4) := y_z2 *  a2;

                acc_v := mult_v(0) + mult_v(1) + mult_v(2) - mult_v(3) - mult_v(4);

                yout <= acc_v(30 downto 15);

                x_z2 <= x_z1;
                x_z1 <= abs_data;

                y_z2 <= y_z1;
                y_z1 <= acc_v(30 downto 15);
                
            end if;
        end if;
    end process;

end RTL;
