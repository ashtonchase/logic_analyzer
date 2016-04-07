-------------------------------------------------------------------------------
-- Title      : Message Processor
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : msg_processor.vhd
-- Created    : 2016-03-17
-- Last update: 2016-04-07
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: The message processor waits for the UART module to provide 
-- commands and data from the SUMP software. When the command is ready, it is
-- read, the ready flag is driven low, and the command is decoded. After the
-- command is decoded, appropiate lines are set to control the sample rate,
-- trigger mask, and sample counts.
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
-- 2016-03-17    0.0        David       Created
-- 2016-03-31    0.1        David       Entity done
-- 2016-04-04    0.2        David       State machine in progress
-- 2016-04-05    1.0        David       Complete
-- 2016-04-07    1.1        David       Handles unrecognized commands
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity msg_processor is
	port(
		-- Global Signals
		clk : in std_logic;  -- Clock
		rst : in std_logic;  -- Synchronous reset		
		
		-- UART Interface
		byte_in	 : in std_logic_vector(7 downto 0);  -- Byte of command/data from UART
		byte_new : in std_logic;  -- Strobe to indicate new byte

		-- Sample Rate Control Interface
		sample_f : out std_logic_vector(23 downto 0);  -- Sampling frequency to Sample Rate Control
		
		-- Capture Control Interface
		reset     : out std_logic;  -- Reset capture control
		armed     : out std_logic;  -- Arm capture control
		read_cnt  : out std_logic_vector(15 downto 0);  -- Number of samples (divided by 4) to send to memory
		delay_cnt : out std_logic_vector(15 downto 0);  -- Number of samples (divided by 4) to capture after trigger
		trig_msk  : out std_logic_vector(31 downto 0);  -- Define which trigger values must match
		trig_vals : out std_logic_vector(31 downto 0)  -- Set the trigger's individual bit values
	);  -- port
end entity msg_processor;

architecture behave of msg_processor is
	signal cmd_in  : std_logic_vector(7 downto 0) := (others => '0');
	signal data_in : std_logic_vector(31 downto 0) := (others => '0');

	type state_t is (INIT, READ_CMD, DO_CMD, BYTE1, BYTE2, BYTE3, BYTE4);
	signal state : state_t;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			reset <= '0';
			armed <= '0';
			if rst = '1' then
				read_cnt  <= x"0000";
				delay_cnt <= x"0000";
				sample_f  <= x"000000";				
				trig_msk  <= x"00000000";
				trig_vals <= x"00000000";
				state     <= INIT;
			else
				case state is
					when INIT =>
						if byte_new = '1' then
							cmd_in <= byte_in;
							state <= READ_CMD;
						end if;
					when READ_CMD =>
						if cmd_in = x"C0" | x"C4" | x"C8" | x"CC" |  -- Trig Mask
												x"C1" | x"C5" | x"C9" | x"CD" |  -- Trig Vals
												x"C2" | x"C6" | x"CA" | x"CE" |  -- Trig Config
												x"80" | x"81" | x"82" then       -- Div, Rd & Dly Cnt, Flgs
							state <= BYTE1;  -- Recognized long command
						else
							state <= DO_CMD  -- Unrecognized command or short command
						end if;  
					when BYTE1 =>
						if byte_new = '1' then
							data_in(7 downto 0) <= byte_in;
							state <= BYTE2;
						end if;
					when BYTE2 =>
						if byte_new = '1' then
							data_in(15 downto 8) <= byte_in;
							state <= BYTE3;
						end if;
					when BYTE3 =>
						if byte_new = '1' then
							data_in(23 downto 16) <= byte_in;
							state <= BYTE4;
						end if;
					when BYTE4 =>
						if byte_new = '1' then
							data_in(31 downto 24) <= byte_in;
							state <= DO_CMD;
						end if;
					when DO_CMD =>
						case cmd_in is
							when x"00" =>		-- Reset
								reset <= '1';
							when x"01" =>		-- Run
								armed <= '1';
							when x"02" =>		-- ID (unimplemented)
							when x"11" =>		-- XON (unimplemented)
							when x"13" =>   -- XOFF (unimplemented)
							when x"C0" | x"C4" | x"C8" | x"CC" =>  -- Set Trigger Mask
								trig_msk <= data_in;
							when x"C1" | x"C5" | x"C9" | x"CD" =>  -- Set Trigger Values
								trig_vals <= data_in;
							when x"C2" | x"C6" | x"CA" | x"CE" =>  -- Set Trigger Configuration (unimplemented)
							when x"80" =>                          -- Set Divider
								sample_f <= data_in(23 downto 0);
							when x"81" =>                          -- Set Read & Delay Count
								read_cnt <= data_in(15 downto 0);
								delay_cnt <= data_in(31 downto 16);
							when x"82" =>                          -- Set Flags (unimplemented)
							when others =>
						end case;
						state <= INIT;
				end case;
			end if;
		end if;
	end process;
end architecture;
