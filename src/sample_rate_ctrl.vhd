-------------------------------------------------------------------------------
-- Title      : Message Processor
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : msg_processor.vhd
-- Created    : 2016-04-05
-- Last update: 2016-04-05
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: The sample rate control simply recieves the sampling frequency
-- from the message processor and then divides the clock to control the rate
-- that the capture control samples the inputs.
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
-- 2016-04-05    0.0        David       Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity sample_rate_ctrl is
	port(
		-- Global Signals
		clk : in std_logic;  -- Clock
		rst : in std_logic;  -- Synchronous reset

		-- Message Processor Interface
		sample_p : in std_logic_vector(23 downto 0);  -- Sample period
		
		-- Capture Control Interface
		reset     : in std_logic;   -- Reset rate clock
		sample_en : out std_logic;  -- Sample enable
	);  -- port
end entity sample_rate_ctrl;

architecture behave of sample_rate_ctrl is
	signal freq : natural range 0 to 16777216 := 0;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				sample_en <= '0';
				freq <= (others => '0');
			else
				
			end if;
		end if;
	end process;
end architecture;
