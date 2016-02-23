-------------------------------------------------------------------------------
-- Title      : Logic Analzyer Data Capture Controller Entity
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : la_ctrl_e.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This entity module is the primary capture controller of the
-- Analyzer Module.
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
-- Date        Version  Author      Description
-- 2016-02-22      1.0      ashton          Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY capture_ctrl IS

  GENERIC (
    DATA_WIDTH : POSITIVE RANGE 1 TO 32 := 32);

  PORT (
    --top level interafaces
    clk           : IN  STD_LOGIC;      -- Clock
    rst           : IN  STD_LOGIC := '0';  -- syncronous reset
    din           : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);  -- input channels
    --message processing interfaces
    rst_cmd       : IN  STD_LOGIC;
    arm_cmd       : IN  STD_LOGIC;
    trigger_mask  : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    trigger_valiu : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    capture_rdy   : OUT STD_LOGIC;
    --fifo interface
    fifo_tdata    : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);  --captured
                                                                  --data output
    fifo_tvalid   : OUT STD_LOGIC;      -- indicating tdata has valid data
    fifo_tlast    : OUT STD_LOGIC;      -- no planned usage
    fifo_tready   : IN  STD_LOGIC;      -- only used on initial setup
    --dummy placeholder
    placeholder   : IN  STD_LOGIC := '0'

    );

END ENTITY capture_ctrl;
