-------------------------------------------------------------------------------
-- Title      : UART testbench
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : UART_tb.vhd
-- Created    : 2016-02-22
-- Last update: 2016-04-06
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the UART testbench
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
-- 2016-03-16      1.0      ian                         Created
-------------------------------------------------------------------------------

use WORK.all;
library ieee;
use IEEE.std_logic_1164.all;

entity UART_tb is
end entity;

library ieee;
use IEEE.std_logic_1164.all;

architecture test of sump_commsT_tb is

  signal clk        : std_logic;        -- clock
  signal rst        : std_logic;        -- reset
  signal rx         : std_logic;        -- data line from top level
  signal tx         : std_logic;
  signal tx_command : std_logic_vector(31 downto 0);  -- data from storage

  signal command_ready : std_logic;     -- flags for data message collect

  signal data_ready : std_logic;        -- flag for transmit message
  signal data_sent  : std_logic;        -- flag for transmit message
                                        -- 
  signal command    : std_logic_vector(7 downto 0);  -- commands for message handler

  constant baud_rate  : integer := 9600;
  constant clock_freq : integer := 10_000_000;

  signal recieve_data : std_logic_vector(7 downto 0);

begin
  u1 : entity work.uart_comms
    generic map (clock_freq => clock_freq,
                 baud_rate  => baud_rate)
    port map (clk           => clk,
              rst           => rst,
              tx            => tx,
              rx            => rx,
              tx_command    => tx_command,
              command_ready => command_ready,
              data_ready    => data_ready,
              data_sent     => data_sent,
              command       => command);

  process (clk)
  begin
    clk <= not clk after 50 ns;         -- 10 MHz clock
  end process;

  baud_clocking : process (clk)
  begin
    if(clk = '1' and clk'event) then
      if (baud_counter < baud_total-1) then
        baud_counter <= baud_counter + 1;
      else
        baud_counter <= 0;
        baud_clock   <= not baud_clock;
      end if;
    end if;
  end process baud_clocking;

  process
  begin
    rx               <= '1';
    rst              <= '0';
    wait for 10 ns;
    receive_data     <= "10011100";
    wait until rising_edge(baud_clock);
 
    wait until rising_edge(baud_clock);
    rx               <= '1';            -- nothing
    wait until rising_edge(baud_clock);
    rx               <= '0';            -- stb
    wait until rising_edge(baud_clock);
    rx               <= receive_data(0);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(1);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(2);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(3);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(4);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(5);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(6);
    wait until rising_edge(baud_clock);
    rx               <= receive_data(7);
    wait until rising_edge(baud_clock);
    rx               <= '1';            -- end
    assert data_out = receive_data report "data out does not match UART data in" severity failure;
    wait for 100 us;
    wait until rising_edge(baud_clock);
    rx_get_more_data <= '1';
  end process;

  process
  begin
    data_ready <= '0';
    wait until rising_edge(baud_clock);
    wait until rising_edge(baud_clock);
    wait until rising_edge(baud_clock);
    wait until rising_edge(baud_clock);

    tx_command    <= "10100111"&"00001111"&"10101010"&"01010101";
    data_ready <= '1';

    wait for 100 ms;
  end process;
  
end test;






























