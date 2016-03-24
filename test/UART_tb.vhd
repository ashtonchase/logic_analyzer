-------------------------------------------------------------------------------
-- Title      : UART testbench
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : UART_tb.vhd
-- Created    : 2016-02-22
-- Last update: 2016-03-22
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

architecture test of UART_tb is
  
  signal clk              : std_logic := '1';  -- clock
  signal rst              : std_logic;  -- reset logic
  signal rx_get_more_data : std_logic;  -- stop bit found for stream in
  signal rx_data_ready    : std_logic;  -- stream out ready
  signal rx               : std_logic;  -- recieve line
  signal data_in          : std_logic_vector(7 downto 0) := (others => '0');  -- data to be transmitted
  signal tx_data_ready    : std_logic;  -- stream out stop bit sent
  signal tx_data_sent     : std_logic;  -- ready for rx
  signal tx               : std_logic                    := '1';  -- transmit line
  signal data_out         : std_logic_vector(7 downto 0) := (others => '0');

  signal   baud_clock   : std_logic := '1';
  signal   baud_counter : integer   := 0;
  constant baud_rate    : integer   := 10_000;
  constant clock_freq   : integer   := 10_000_000;
  constant baud_total   : integer   := (clock_freq/baud_rate)/2;
begin
  u1 : entity work.uart_comms
    generic map (clock_freq => clock_freq, baud_rate => baud_rate)
    port map (
      clk              => clk,
      rst              => rst,
      rx_get_more_data => rx_get_more_data,
      rx_data_ready    => rx_data_ready,
      rx               => rx,
      data_in          => data_in,
      tx_data_ready    => tx_data_ready,
      tx_data_sent     => tx_data_sent,
      tx               => tx,
      data_out         => data_out);

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
    rx <= '1';
    rst <= '0';
    wait for 10 ns;
    rx_get_more_data <= '1';
    wait until rising_edge(baud_clock);
    rx <= '1';                          -- nothing
    wait until rising_edge(baud_clock);
    rx <= '0';                          -- stb
    wait until rising_edge(baud_clock);
    rx <= '1';                          -- 1
    wait until rising_edge(baud_clock);
    rx <= '0';                          -- 2
    wait until rising_edge(baud_clock);
    rx <= '0';                          -- 3
    wait until rising_edge(baud_clock);
    rx <= '1';                          -- 4
    wait until rising_edge(baud_clock);
    rx <= '1';                          -- 5
    wait until rising_edge(baud_clock);
    rx <= '1';                          -- 6
    wait until rising_edge(baud_clock);
      rx <= '0';                        -- 7
    wait until rising_edge(baud_clock);
      rx <= '0';                        -- 8
    wait until rising_edge(baud_clock);
      rx <= '1';                        -- end
  end process;

  process
  begin
    wait for 1000 ms;
    data_in <= "10100111";
  end process;
  
end test;






























