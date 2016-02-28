-------------------------------------------------------------------------------
-- Title      : Logic Analzyer Data Capture Controller Entity
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : la_ctrl_e.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-27
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
-- 2016-02-22  1.0      ashton      Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY capture_ctrl IS

  GENERIC (
    DATA_WIDTH : POSITIVE RANGE 1 TO 32 := 8);

  PORT (
    --top level interafaces
    clk       : IN  STD_LOGIC;          -- Clock
    rst       : IN  STD_LOGIC := '0';   -- syncronous reset
    din       : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);  -- input channels
    --status indicators
    armed     : OUT STD_LOGIC;          --latched indicator when armed. 
    triggered : OUT STD_LOGIC;          --latched indicator when triggerd.


    ------message processing interfaces
    --serially received reset command. one clock cycle required
    rst_cmd        : IN  STD_LOGIC                       := '0';
    --serially received arm command. one clock cycle required.
    arm_cmd        : IN  STD_LOGIC;
    --sample enable trigger. for subsampling data. 
    sample_enable  : IN  STD_LOGIC                       := '1';
    --send a reset pulse to the sample rate clock
    sample_cnt_rst : OUT STD_LOGIC;
    --number of sample_rate cycles to delay captureing data after trigger has occured.
    delay_cnt_4x : IN  STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '0');
    --number of samples to read, times four. max==262,140 samples
    read_cnt_4x    : IN  STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '1');
    --parallel trigger bit mask for par_trig_val. latched in on arm_cmd
    par_trig_msk   : IN  STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '0');
    --parallel triger values, latched in on arm_cmd
    par_trig_val   : IN  STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '1');
    --ready_to_arm indicator
    capture_rdy    : OUT STD_LOGIC;


    --fifo interface
    fifo_tdata  : OUT STD_LOGIC_VECTOR(32-1 DOWNTO 0);  --captured
                                                        --data output
    fifo_tvalid : OUT STD_LOGIC;        -- indicating tdata has valid data
    fifo_tlast  : OUT STD_LOGIC;        -- no planned usage
    fifo_tready : IN  STD_LOGIC := '1';  -- only used on initial setup
    fifo_tfull  : IN  STD_LOGIC := '0';
    --dummy placeholder
    placeholder : IN  STD_LOGIC := '0'

    );

BEGIN


  -----------------------------------------------------------------------------
  -- Architecture Independent Port Assertions
  -----------------------------------------------------------------------------
  --confirm clk is connected
  ASSERT IS_X(clk) = FALSE REPORT "clock is undefined" SEVERITY ERROR;

  
  PROCESS (clk) IS
  BEGIN  -- PROCESS
    IF rising_edge(clk) THEN            -- rising clock edge
      --cofirm arm_cmd is connected
      ASSERT IS_X(arm_cmd) = FALSE REPORT "arm_cmd is undefined" SEVERITY ERROR;
    END IF;
  END PROCESS;


END ENTITY capture_ctrl;


--See capture_ctrl_a for architecture
