-------------------------------------------------------------------------------
-- Title      : Top module for serial comms with sump gui
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : SUMPComms.vhd
-- Created    : 2016-02-22
-- Last update: 2016-04-04
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the top module for comms between the SUMP module and
-- the logic analyzer. It will handle the RS232 communication. It will handle
-- coordination with the message passing and memory modules using data lines
-- and handshaking.
-- The clock rate and baud rate need to be specified in this module.
-- This will be converted to a state machine
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
use work.all;

entity SUMPComms is
  port(clk           : in  std_logic;   -- clock
       rst           : in  std_logic;   -- reset
       rx            : in  std_logic;   -- data line from top level
       tx            : out std_logic;
       tx_command    : in  std_logic_vector(31 downto 0);  -- data from storage
       --  ready_for_command : in  std_logic;  -- flag for data message collect
       command_ready : out std_logic;  -- flags for data message collect

       data_ready : in  std_logic;      -- flag for transmit message
       data_sent  : out std_logic;      -- flag for transmit message

       command : out std_logic_vector(7 downto 0));  -- commands for message handler

end entity SUMPComms;

architecture comms of SUMPComms is
  type states is (Init, Wait_State, Drop_Wait, Command_Received, Wait_For_Ready,
                  Send_Data, Send_Complete);
  signal rx_curr_state, rx_next_state, tx_curr_state, tx_next_state : states;


  signal rx_get_more_data : std_logic;  -- stop bit found for stream in
  signal rx_data_ready    : std_logic;  -- stream out ready
  signal data_out         : std_logic_vector(7 downto 0) := (others => '0');

  signal tx_data_in    : std_logic_vector(7 downto 0) := (others => '0');  -- data to be transmitted
  signal tx_data_ready : std_logic;     -- stream out stop bit sent
  signal tx_data_sent  : std_logic;     -- ready for rx

  signal comm_signal : std_logic_vector(7 downto 0);  -- commands for message handler

  constant baud_rate  : integer := 9600;      -- sorta normal baud
  constant clock_freq : integer := 10000000;  -- 10MHz

begin
  u1 : entity work.uart_comms
    generic map (clock_freq => clock_freq, baud_rate => baud_rate)
    port map (
      clk              => clk,
      rst              => rst,
      rx_get_more_data => rx_get_more_data,
      rx_data_ready    => rx_data_ready,
      rx               => rx,
      data_in          => tx_data_in,
      tx_data_ready    => tx_data_ready,
      tx_data_sent     => tx_data_sent,
      tx               => tx,
      data_out         => data_out);


  command_reciever : process (clk)
  begin
    clock_entry : if rst = '1' then
      rx_next_state <= Init;

    elsif (clk = '1' and clk'event) then
      rx_get_more_data <= '1';
      command_ready = '0';
      state_selector : case rx_curr_state is
        when Init =>
          rx_next_state <= Wait_State;
          command_ready <= '0';

        when Wait_State =>
          rx_next_state <= Wait_State;

          if rx_data_ready = '1' then
            rx_next_state <= Command_Received;
            comm_signal   <= data_out;
            command <= comm_signal;
            command_ready = '1';
          end if;

        when Command_Recieved =>
          rx_next_state <= Command_Received;

          if rx_data_ready = '0' then
            rx_next_state <= Wait_State;
          end if;

        when others =>
          rx_next_state <= Init;

      end case state_selector;
    end if clock_entry;
  end process command_reciever;


  --command_sender : process (clk)
  --begin
  --  clock_entry : if rst = '1' then
  --    rx_next_state <= Init;

  --  elsif (clk = '1' and clk'event) then
  --    data_sent <= '0';
  --    state_selector : case rx_curr_state is
  --      when Init =>
  --        rx_next_state <= Wait_State;
  --        command_ready <= '0';

  --      when Wait_State =>
  --        rx_next_state <= Wait_State;

  --        if rx_data_ready = '1' then
  --          rx_next_state <= Command_Received;
  --          comm_signal   <= data_out;
  --          command <= comm_signal;
  --          command_ready = '1';
  --        end if;

  --      when Command_Recieved =>
  --        rx_next_state <= Command_Received;

  --        if rx_data_ready = '0' then
  --          rx_next_state <= Wait_State;
  --        end if;

  --      when others =>
  --        rx_next_state <= Init;

  --    end case state_selector;
  --  end if clock_entry;
  --end process command_sender;



end architecture comms;





