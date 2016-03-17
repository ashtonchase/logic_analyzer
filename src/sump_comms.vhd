-------------------------------------------------------------------------------
-- Title      : Top module for serial comms with sump gui
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : SUMPComms.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the top module for comms between the SUMP module and
-- the logic analyzer. It will handle the RS232 communication.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Ashton Johnson, Paul Henny, Ian Swepston, David Hurt
-------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version      Author      Description
-- 2016-02-22      1.0      ian	   			Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity SUMPComms is
	port( 
		rst					: in	STD_LOGIC;
		clk					: in	STD_LOGIC;
		rx					: in	STD_LOGIC; -- data line from top level
		tx_data				: in	STD_LOGIC_VECTOR(7 downto 0); -- data from storage
		ready_for_command	: in STD_LOGIC;	-- flag for data message collect
		command_ready		: out STD_LOGIC;	-- flag for data message collect
		
		data_ready			: in STD_LOGIC;	-- flag for transmit message
		data_sent			: out STD_LOGIC;	-- flag for transmit message
		
		command 			: out STD_LOGIC_VECTOR(7 downto 0)); -- commands for message handler
		command_data 		: out STD_LOGIC_VECTOR(31 downto 0)); -- commands for message handler

end entity SUMPComms;

architecture comms of SUMPComms is

	signal stream_in_done, stream_read_done, stream_trans_ready, stream_out_ready : std_logic;
	signal rx_data : std_logic_vector(7 downto 0);
	signal tx_line : std_logic;
	signal command_count : integer range 0 to 15 := 0;
	
	constant baud_rate : integer := 9600; -- sorta normal baud
	constant clock_freq : integer := 10000000; -- 10MHz

begin
	uart : entity work.uart_comms port map(clk => clk;
										rst => rst;
										stream_tx_stb => stream_in_done;
										stream_rx_ack => stream_out_ready;
										rx => rx;
										data_in => tx_data;																
										stream_rx_stb => stream_read_done;
										stream_tx_ack => stream_trans_ready;
										tx => tx_line;
										data_out => rx_data);

	transmit : process (clk)
	begin
	if clk = '1' and data_ready

	end process transmit;
	
	recieve : process (clk)
	begin
		if clk = '1' then
			if stream_read_done = '1' and command_count < 5 then
				if command_count = 0 and ready_for_command = '1' then
					command <= rx_data;
				else
					command_data <= command_data(23 downto 0) & rx_data;
				end if;
				command_count <= command_count + 1;
				command_ready <= '0';
			end if;
		else if command_count >= 5 then;
			if ready_for_command = '0';
				command_ready <= '1';
			else
				
			end if;
		end if;
	end process recieve;
	
	
																												
end architecture comms;





