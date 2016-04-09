-------------------------------------------------------------------------------
-- Title      : Sample Rate Control
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : sample_rate_ctrl.vhd
-- Created    : 2016-04-05
-- Last update: 2016-04-09
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version      Author      Description
-- 2016-04-05    0.0        David       Created
-- 2016-04-06    1.0        David       Major functionality complete
-- 2016-04-07    1.1        David       Correcting errors in divider generation
-- 2016-04-09    1.2        Ashton      removed geneic, updated port x->divder_rate
--                                      corrected castin from divider rate to integer
--                                      beautified.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_rate_ctrl is
  
  port(
    -- Global Signals
    clk : in std_logic;  -- Clock
    rst : in std_logic;  -- Synchronous reset

    -- Message Processor Interface
    divider_rate : in std_logic_vector(23 downto 0);  -- Division factor - 1

    -- Capture Control Interface
    reset     : in  std_logic;  -- Reset rate clock
    armed     : in  std_logic;  -- Indicates that capture control is armed
    sample_en : out std_logic   -- Sample enable
    );
end entity sample_rate_ctrl;

architecture behave of sample_rate_ctrl is
  signal div    : natural   := 1;  -- Division factor
  signal count  : natural   := 0;
  signal sample : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        div    <= 0;
        count  <= 0;
        sample <= '0';
      else
                                   -- Only update sample rate if cap control isn't armed
        if armed /= '1' then
          div <= to_integer(unsigned(divider_rate));
        end if;
        if reset = '1' then
          count <= 0;
        elsif div = 1 then         -- No division
          sample <= '1';
        elsif count < div then     -- f = clock/div
          count <= count + 1;
        else
          count  <= 0;
          sample <= not sample;
        end if;
      end if;
    end if;
  end process;
  sample_en <= sample;
end architecture;
