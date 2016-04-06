-------------------------------------------------------------------------------
-- Title      : Sample Rate Control
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : sample_rate_ctrl.vhd
-- Created    : 2016-04-05
-- Last update: 2016-04-06
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
-- 2016-04-06    1.0        David       Major functionality complete
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity sample_rate_ctrl is
	generic(clock_freq : positive := 100_000_000);
	port(
		-- Global Signals
		clk : in std_logic;  -- Clock
		rst : in std_logic;  -- Synchronous reset

		-- Message Processor Interface
		sample_p : in std_logic_vector(23 downto 0);  -- Sample period
		
		-- Capture Control Interface
		reset     : in std_logic;  -- Reset rate clock
		armed     : in std_logic;  -- Indicates that capture control is armed
		sample_en : out std_logic  -- Sample enable
	);
end entity sample_rate_ctrl;

architecture behave of sample_rate_ctrl is
	signal freq      : natural := 1;
	signal max_count : natural := 1;
	signal count     : natural := 0;
	signal sample    : std_logic := '0';
	
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				freq      <= 0;
				max_count <= 0;
				count     <= 0;
				sample_en <= '0';
			else
				-- Only update sample rate if cap control isn't armed
				if armed /= '1' then
					freq <= clock_freq / (to_integer(unsigned(sample_p)) + 1);
					max_count <= (clock_freq/freq)/2;
				end if;
				if reset = '1' then
					count <= 0;
				end if;
				if count < (max_count - 1) then
					count <= count + 1;
				else
					count <= 0;
					sample <= not sample;
				end if;				
			end if;
		end if;
	end process;
	sample_en <= sample;
end architecture;
