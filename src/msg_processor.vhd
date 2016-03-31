-------------------------------------------------------------------------------
-- Title      : Message Processor
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : msg_processor.vhd
-- Created    : 2016-03-17
-- Last update: 2016-03-31
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
-- 2016-03-17      0.0      David	      Created
-- 2016-03-31      0.1      David	      Entity done
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity msg_processer is
	port(
		-- Global Signals
		clk : in std_logic;  -- Clock
		rst : in std_logic;  -- Synchronous reset		
		
		-- UART Interface
		data_in	 : in std_logic_vector(7 downto 0);  -- Byte of command/data from UART
		data_new : in std_logic;  -- Strobe to indicate new byte

		-- Sample Rate Control Interface
		sample_f : out std_logic_vector(31 downto 0);  -- Sampling frequency to Sample Rate Control
		
		-- Capture Control Interface
		reset     : out std_logic;  -- Reset capture control
		arm       : out std_logic;  -- Arm capture control
		read_cnt  : out std_logic(15 downto 0);  -- Number of samples (divided by 4) to send to memory
		delay_cnt : out std_logic(15 downto 0);  -- Number of samples (divided by 4) to capture after trigger
		trig_msk  : out std_logic(31 downto 0);  -- Define which trigger values must match
		trig_vals : out std_logic(31 downto 0);  -- Set the trigger's individual bit values
		
	);  -- port

end entity msg_processor;

architecture behave of msg_processor is
	



















