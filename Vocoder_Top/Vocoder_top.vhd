library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity Vocoder_top is 
    port(
        CLK                  : in std_logic ;
        RSTn                 : in std_logic ;
        xin                  : in signed(15 downto 0);
        valid_in             : in std_logic;
        vocoder_out          : out signed(15 downto 0);
        valid_out            : out std_logic
    );
end Vocoder_top;

architecture RTL of Vocoder_top is


    type Data_out_t is array (0 to 7) of signed(15 downto 0);
	type valid_out_t is array (0 to 7) of std_logic;
	
    signal filtre_out            : Data_out_t ;
    signal filtre_valid_out      : valid_out_t;
   
    signal Envelope_out          : Data_out_t;
    signal Envelope_valid_out    : valid_out_t ;
    
    type Envelope_coefficient_t is array (0 to 4) of signed(15 downto 0);
    
    signal Envelope_coefficient : Envelope_coefficient_t := (to_signed(1638, 16),    
                                                             to_signed(0, 16),        
                                                             to_signed(0, 16),       
                                                             to_signed(-31130, 16),   
                                                             to_signed(0, 16));
															 
    
	type Filters_coefficient_t is array (0 to 7) of signed(15 downto 0);
    signal Filters_coefficient_a1 : Filters_coefficient_t := (to_signed(-65477, 16), 
	                                                          to_signed(-64083, 16),
															  to_signed(-61404, 16),
															  to_signed(-57513, 16),
															  to_signed(-52488, 16),
															  to_signed(-46373, 16),
															  to_signed(-39442, 16),
															  to_signed(-31695, 16));
															  
    signal Filters_coefficient_a2 : Filters_coefficient_t := (to_signed(30455, 16), 
	                                                          to_signed(30481, 16),
															  to_signed(30506, 16),
															  to_signed(30553, 16),
															  to_signed(30615, 16),
															  to_signed(30688, 16),
															  to_signed(30774, 16),
															  to_signed(30874, 16));
															  
    signal Filters_coefficient_b0 : Filters_coefficient_t := (to_signed(25448, 16), 
	                                                          to_signed(25159, 16),
															  to_signed(24878, 16),
															  to_signed(24366, 16),
															  to_signed(23681, 16),
															  to_signed(22888, 16),
															  to_signed(21933, 16),
															  to_signed(20833, 16));
															  
    signal Filters_coefficient_b1 : Filters_coefficient_t := (to_signed(0, 16),
	                                                          to_signed(0, 16),
	                                                          to_signed(0, 16),
															  to_signed(0, 16),
															  to_signed(0, 16),
															  to_signed(0, 16),
															  to_signed(0, 16),
															  to_signed(0, 16));
															  
    signal Filters_coefficient_b2 : Filters_coefficient_t := (to_signed(-25448, 16), 
	                                                          to_signed(-25159, 16),
															  to_signed(-24878, 16),
															  to_signed(-24366, 16),
															  to_signed(-23681, 16),
															  to_signed(-22888, 16),
															  to_signed(-21933, 16),
															  to_signed(-20833, 16));
															  
    
	type Step_t is array (0 to 7) of unsigned(15 downto 0);
	
    signal step  : Step_t := (to_unsigned(435, 16), 
                              to_unsigned(2206,16),	
	                          to_unsigned(3725,16),
							  to_unsigned(5217,16),
							  to_unsigned(6699,16),
							  to_unsigned(8177, 16),
							  to_unsigned(9654,16),
							  to_unsigned(11129,16));
							 
    signal osc_data_out        : Data_out_t;
     
    signal modulated_out       : Data_out_t ;
    signal modulation_valid_out: valid_out_t ;
    
	signal vocoder_output : signed(16 + 3 - 1  downto 0);
	
    component Filtre is
        port(
            CLK, RSTn              : in std_logic;
            xin                    : in signed(15 downto 0);
            valid_in               : in std_logic;
            yout                   : out signed(15 downto 0);
            valid_out              : out std_logic;
            b0, b1, b2, a1, a2     : in  signed(15 downto 0));
    end component;
     
    component Enveloppe is
        port(
            CLK, RSTn              : in std_logic;
            xin                    : in signed(15 downto 0);
            valid_in               : in std_logic;
            yout                   : out signed(15 downto 0);
            valid_out              : out std_logic;
            b0, b1, b2, a1, a2     : in  signed(15 downto 0));
    end component;
     
    component Oscillator is
        port(
            CLK, RSTn    : in  std_logic;
            step         : in  unsigned(15 downto 0);
            ready_i      : in  std_logic;
            yout         : out signed(15 downto 0));
    end component;
    
begin

    Channel_Gen: for i in 0 to 7 generate
	begin 
	    
		--Filters
		Filters: Filtre port map
		(
            CLK        => CLK,
            RSTn       => RSTn,
            xin        => xin,
            valid_in   => valid_in,
            yout       => filtre_out(i),
            valid_out  => filtre_valid_out(i),
            b0         => Filters_coefficient_b0(i),
            b1         => Filters_coefficient_b1(i),
            b2         => Filters_coefficient_b2(i),
            a1         => Filters_coefficient_a1(i),
            a2         => Filters_coefficient_a2(i)
        );
    
        --Envelopes
        Envelopes: Enveloppe port map
        (
            CLK        => CLK,
            RSTn       => RSTn,
            xin        => filtre_out(i),
            valid_in   => filtre_valid_out(i),
            yout       => Envelope_out(i),
            valid_out  => Envelope_valid_out(i),
            b0         => Envelope_coefficient(0),
            b1         => Envelope_coefficient(1),
            b2         => Envelope_coefficient(2),
            a1         => Envelope_coefficient(3),
            a2         => Envelope_coefficient(4)
        );
   
        --Oscillators
        Oscillators: Oscillator port map
        (
            CLK       => CLK,
            RSTn      => RSTn,
            step      => step(i),
            ready_i   => Envelope_valid_out(i),
            yout      => osc_data_out(i)
        );
		
        
        --Modulation
        Modulation: process(CLK, RSTn)
           variable mult : signed(31 downto 0);
        begin
            if RSTn = '0' then
                modulated_out(i)     <= (others => '0');
                modulation_valid_out(i) <= '0';
            elsif rising_edge(CLK) then
                if Envelope_valid_out(i) = '1' then
				
                    mult := Envelope_out(i) * osc_data_out(i);				
				    modulated_out(i) <= mult(30 downto 15);
                    modulation_valid_out(i) <= '1';

                else
                    modulation_valid_out(i) <= '0'; 
                end if;
            end if;
		end process;
		
	end generate Channel_Gen;
		
   
   vocoder_output <=  resize(modulated_out(0), 19) 
                    + resize(modulated_out(1), 19) 
					+ resize(modulated_out(2), 19)
					+ resize(modulated_out(3), 19)
					+ resize(modulated_out(4), 19)
					+ resize(modulated_out(5), 19)
					+ resize(modulated_out(6), 19) 
                    + resize(modulated_out(7), 19);
					
   vocoder_out    <= vocoder_output(18 downto 3);
   
   valid_out      <= modulation_valid_out(0) or 
                     modulation_valid_out(1) or
                     modulation_valid_out(2) or
                     modulation_valid_out(4) or
                     modulation_valid_out(5) or
                     modulation_valid_out(6) or
                     modulation_valid_out(7) ;
    
end RTL;  