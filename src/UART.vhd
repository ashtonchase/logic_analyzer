-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : UART.vhd
-- Created    : 2016-02-22
-- Last update: 2016-03-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the UART the sump comms module will use. It is capable
-- of taking an input baud rate and clock frequency to run a baud clock using a
-- clock divider. It transmits data when the transmit data (data_out)changes and
-- recieves data when it recieves a low signal on the rx line.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Ashton Johnson, Paul Henny, Ian Swepston, David Hurt
-------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version      Author      Description
-- 2016-02-22      1.0      ian                         Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_comms is
  generic (baud_rate  : positive;
           clock_freq : positive);  -- Make sure we keep integer division here

  port(clk              : in  std_logic;  -- clock
       rst              : in  std_logic;  -- reset logic
       rx_get_more_data : in  std_logic;  -- stop bit found for stream in
       rx_data_ready    : out std_logic;  -- stream out ready
       rx               : in  std_logic;  -- recieve line
       data_in          : in  std_logic_vector(7 downto 0) := (others => '0');  -- data to be transmitted
       tx_data_ready    : in  std_logic;  -- stream out stop bit sent
       tx_data_sent     : out std_logic;  -- ready for rx
       tx               : out std_logic                    := '1';  -- transmit line
       data_out         : out std_logic_vector(7 downto 0) := (others => '0'));  -- data recieved from rx line

begin  --added comment

  assert(clock_freq mod baud_rate = 0) report ("Non Integer Division") severity(error);

end entity uart_comms;

architecture pass_through of uart_comms is
  type states is (Init, Wait_State, Get_Data, Send_Data, Data_Ready, Send_Complete);
  signal rx_current_state, rx_next_state, tx_current_state, tx_next_state : states;

  signal rx_counter, tx_counter : integer range 0 to 255       := 0;
  signal trans_data             : std_logic_vector(7 downto 0) := (others => '0');
  signal data_out_sig           : std_logic_vector(7 downto 0) := (others => '0');


  signal baud_clock, baud_clock_x16     : std_logic              := '0';
  signal baud_counter, baud_counter_x16 : integer range 0 to 255 := 0;
  signal sampling_counter, zero_counter : integer range 0 to 255 := 0;
  signal baud_reset                     : std_logic              := '0';
  constant baud_total                   : integer                := clock_freq/baud_rate;
begin

  -- Create baud clock
  baud_clocking : process (clk)
  begin
    if(clk = '1') then
      if (baud_counter < baud_total) then
        baud_counter <= baud_counter + 1;
      else
        baud_counter <= 0;
        baud_clock   <= not baud_clock;
      end if;
    end if;
  end process baud_clocking;

  baud_clocking_x16 : process (clk)
  begin
    if (clk = '1') then
      if(baud_reset = '1') then
        baud_counter_x16 <= 0;
        baud_clock_x16   <= '0';
        baud_reset       <= '0';
      elsif (baud_counter_x16 < baud_total/16) then
        baud_counter_x16 <= baud_counter_x16 + 1;
      else
        baud_counter_x16 <= 0;
        baud_clock_x16   <= not baud_clock;
      end if;
    end if;
  end process baud_clocking_x16;

  -- State transition logic for RX
  rx_moore : process (baud_clock_x16)
  begin
    if baud_clock_x16 = '1' and baud_clock_x16'event then
      rx_data_ready <= '0';

      case rx_current_state is
        when Init =>
          rx_next_state <= Wait_State;

        when Wait_State =>
          rx_next_state <= Wait_State;

          if zero_counter < 9 then
            if rx = '0' then
              zero_counter <= zero_counter + 1;
            else
              zero_counter <= 0;
            end if;
          else
            rx_next_state    <= Get_Data;
            baud_reset       <= '1';
            sampling_counter <= 0;
            rx_counter       <= 0;
          end if;

        when Get_Data =>
          rx_next_state <= Get_Data;
          if sampling_counter < 15 then
            sampling_counter <= sampling_counter + 1;
          else
            sampling_counter <= 0;
            if rx_counter < 8 then
              rx_counter   <= rx_counter + 1;
              data_out_sig <= rx & data_out_sig(7 downto 1);  -- shift right
            else
              rx_counter    <= 0;
              rx_next_state <= Data_Ready;
            end if;
          end if;

        when Data_Ready =>
          rx_next_state       <= Data_Ready;
          rx_data_ready       <= '1';
          if rx_get_more_data <= '1' then
            rx_next_state <= Wait_State;
          end if;
        when others => null;
      end case;
    end if;
    rx_current_state <= rx_next_state;
  end process rx_moore;
  data_out <= data_out_sig;



  -- State transition logic for TX  tx_moore : process (baud_clock)
  begin
    if baud_clock = '1' and baud_clock'event then
      tx <= '1';

      case tx_current_state is
        when Init =>
          tx_next_state <= Wait_State;
          tx_data_sent  <= '0';

        when Wait_State =>
          tx_next_state <= Wait_State;
          if tx_data_ready = '1' then
            tx_data_sent  <= '0';
            tx_next_state <= Send_Data;
            trans_data    <= data_in;
            tx_counter    <= 0;
            tx            <= '0';
          end if;

        when Send_Data =>
          tx_next_state <= Send_Data;
          if tx_counter < 8 then        -- transmit 8 bits
            tx         <= trans_data(7 - tx_counter);
            tx_counter <= tx_counter + 1;
          else                          -- transmit high end bit
            tx <= '1';
          end if;

        when Send_Complete =>
          tx_next_state <= Wait_State;
          tx_data_sent  <= '1';

        when others => null;
      end case;
    end if;
    tx_current_state <= tx_next_state;
  end process tx_moore;


end architecture pass_through;









