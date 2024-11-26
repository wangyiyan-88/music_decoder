library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity symb_det is
    Port (  clk: in STD_LOGIC; -- input clock 96kHz
            clr: in STD_LOGIC; -- input synchronized reset
            adc_data: in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid: out STD_LOGIC; -- HIGH for every 6000 cycles
            symbol_out: out STD_LOGIC_VECTOR(2 DOWNTO 0)-- output 3-bit detection symbol
            );
end symb_det;

architecture Behavioral of symb_det is
    type state_type is (s_idle, s_detecting);
    
    signal state, next_state : state_type;
    signal wave_zero_period_obtain : std_logic;
    signal c_samp, p_samp : std_logic;
    shared variable time_between_zero_cnt : integer; -- Count time between two zero points
    signal start_new_count : std_logic:='0'; -- Count time between two zero points
    
begin
    sync : process (clk, clr)
    begin
        if clr = '1' then
            state <= s_idle;
            wave_zero_period_obtain <= '0';
            start_new_count <= '0';
            c_samp <= '0';
            time_between_zero_cnt := 0;
        elsif rising_edge (clk) then
            p_samp <= c_samp;
            c_samp <= adc_data(11);
            state <= next_state;
       end if;

    end process;
    
    state_logic : process (state)
    begin
    case state is 
        when s_idle =>
            symbol_valid <= '0';
            next_state <= s_detecting;
           
        when s_detecting =>
            if start_new_count = '0' then
                time_between_zero_cnt := time_between_zero_cnt + 1;
                start_new_count <= '1'; -- Initialize counter
                wave_zero_period_obtain <= '0';
                symbol_out <= "000";
                symbol_valid <= '1';
                next_state <= s_detecting;
            else
                time_between_zero_cnt := time_between_zero_cnt + 1;
                symbol_out <= "001";
                if (c_samp='0' and p_samp='1') or (c_samp='1' and p_samp='0')then
                    wave_zero_period_obtain <= '1';
                    start_new_count <= '0';               
                end if;
            end if;
            
                   
           if wave_zero_period_obtain = '1' then
                if   20< time_between_zero_cnt and time_between_zero_cnt< 25 then
                    symbol_out <= "001";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 25< time_between_zero_cnt and  time_between_zero_cnt<230 then
                    symbol_out <= "001";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 32< time_between_zero_cnt and  time_between_zero_cnt<37 then
                    symbol_out <= "010";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 38< time_between_zero_cnt and  time_between_zero_cnt<43 then
                    symbol_out <= "011";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 46< time_between_zero_cnt and  time_between_zero_cnt<51 then
                    symbol_out <= "100";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 59< time_between_zero_cnt and  time_between_zero_cnt<64 then
                    symbol_out <= "101";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 70< time_between_zero_cnt and  time_between_zero_cnt<75 then
                    symbol_out <= "110";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                elsif 89 < time_between_zero_cnt and  time_between_zero_cnt<94 then
                    symbol_out <= "110";
                    symbol_valid <= '1';
                    next_state <= s_detecting;
                else
                    symbol_out <= "001"; 
                    symbol_valid <= '0';
                    next_state <= s_idle;
                end if;
                time_between_zero_cnt :=0;
           end if;
   
    end case;
    
    end process;


end Behavioral;
