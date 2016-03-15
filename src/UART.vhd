-------------------------------------------------------------------------------
-- Title      : UART Entity
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : SUMPComms.vhd
-- Created    : 2016-02-22
-- Last update: 2016-03-15
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the UART the sump comms module will use
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
    use ieee.numeric_std.all;
    use ieee.math_real.all;

ENTITY uart_comms IS
	generic (baud_rate : positive;
		 			clock_freq : positive); -- Make sure we keep integer division here

				port(clk						:	in	STD_LOGIC;
             rst						:	in	STD_LOGIC;
             stream_in_stb	:	in	STD_LOGIC;
             stream_out_ack	:	in	STD_LOGIC;
             rx							:	in	STD_LOGIC;
             data_in				: 	in	STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
		
             stream_out_stb	:	out	STD_LOGIC;
             stream_in_ack	:	out	STD_LOGIC;
             tx	        		:	out	STD_LOGIC := '1';
             data_out				: 	out	STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0'));

begin 

ASSERT(clock_freq mod baud_rate = 0) REport ("Non Integer Division") SEVERITY(ERROR);

end ENTITY uart_comms;

ARCHITECTURE pass_through OF uart_comms IS
signal rx_counter, tx_counter : INTEGER RANGE 0 TO 255 := 0;
signal trans_data: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');

signal baud_clock, baud_clock_x16	: STD_LOGIC := '0';
signal baud_counter, baud_counter_x16, sampling_counter, zero_counter : INTEGER RANGE 0 to 255;
signal reset_baud : STD_LOGIC := '0';
constant baud_total : INTEGER := baud_rate/clock_freq;
begin
-- Recieve logic
	baud_clocking_x16 : PROCESS (clk)
		if(clk = '1') then
			if(baud_reset = '1') then
				baud_counter_x16 <= 0;
				baud_clock_x16 <= '0';
			elsif (baud_counter_x16 < baud_total/16) then
				baud_counter_x16 <= baud_counter_x16 + 1;
			else
				baud_clock_x16 <= not baud_clock;
			end if;
		end if;
	end process baud_clocking;

	reciever: process (baud_clock_x16)
	begin
		-- Look for low
		if baud_clock_x16 = '1' and baud_clock_x16'event then
			
			if zero_counter < 9 then
				sampling_counter <= 0;
				rx_counter <= 0;
				if rx = '0' then
					zero_counter <= zero_counter + 1;
				else
					zero_counter <= 0;		
				end if;
			else -- significant low found, done oversampling. Handle new clock
				if sampling_counter < 16 then
					sampling_counter <= sampling_counter + 1;
				else
					sampling_counter <= 0;
				end if;
			end if;		   
			
    	
		  if sampling_counter = 15 then -- sensitive to baud offset clock
				if rx_counter < 8 then
					stream_out_stb <= '0';
					rx_counter <= rx_counter + 1;
					data_out <= rx & data_out(7 downto 1); -- shift right
				
				else
					if rx = '1' then
						rx_counter <= 0;		
						stream_out_stb <= '1';
						zero_counter <= 0;
						
					else
						stream_out_stb <= '0';
						data_out <= (OTHERS => 'X');
						zero_counter <= 0;
					end if;
					
				end if;
			end if;
		end if;
	
	end PROCESS reciever;

-- Transmit logic
	-- Create baud clock
	baud_clocking : PROCESS (clk)
		if(clk = '1') then
			if (baud_counter < baud_total) then
				baud_counter <= baud_counter + 1;
			else
				baud_clock <= not baud_clock;
			end if;
		end if;
	end process baud_clocking;
	
	-- use baud clock and transmit data
	transmitter : PROCESS (baud_clock)
	begin
		if(baud_clock = '1' and baud_clock'event) then
			if tx_counter = '0' and trans_data /= data_in then --wait for data change (last /= current)
				trans_data <= data_in;
				tx_counter <= tx_counter + 1;
				tx <= '0';			
			elsif tx_counter > 0 and tx_counter <= 8 then -- transmit 8 bits
				tx <= trans_data(tx_counter - 1);
				tx_counter <= tx_counter + 1;
			else -- transmit high end bit and wait for more data
				tx <= '1';
				tx_counter <= 0;
			end if;			
		end if;
	end PROCESS transmitter;

end ARCHITECTURE pass_through;









