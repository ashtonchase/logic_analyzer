-------------------------------------------------------------------------------
-- Title      : Logic Analyzer Top Module
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : la_top.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-27
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is the top instatiting modue of the logic analyzer. This
-- will define the generic I/O interfaces to the system. Ideally, all modules
-- below this will be portable to whatever your targer hardware will be. 
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
-- 2016-02-22      1.0      ashton	    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY la_top IS
  
  GENERIC (
    INPUT_CLK_RATE_HZ : POSITIVE RANGE 10_000_000 TO 200_000_000 := 100_000_000);

  PORT (
    --COMMON INTERFACES
    clk     : IN  STD_LOGIC;            --clock
    rst     : IN  STD_LOGIC := '0';     --reset, (async high/ sync low)
    --data input. defaulte to zeroes so you don't have to hook all 32 lines up.
    din     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    --UART INTERFACES
    uart_rx : IN  STD_LOGIC;                     -- UART Receive Data
    uart_tx : OUT STD_LOGIC);                    -- UART Transmit Data

END ENTITY la_top;

ARCHITECTURE structural OF la_top IS

  SIGNAL clk            : STD_LOGIC;
  SIGNAL rst            : STD_LOGIC                       := '0';
  SIGNAL din            : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
  SIGNAL armed          : STD_LOGIC;
  SIGNAL triggered      : STD_LOGIC;
  SIGNAL rst_cmd        : STD_LOGIC                       := '0';
  SIGNAL arm_cmd        : STD_LOGIC;
  SIGNAL sample_enable  : STD_LOGIC                       := '1';
  SIGNAL sample_cnt_rst : STD_LOGIC;
  SIGNAL delay_cnt_4x   : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL read_cnt_4x    : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL par_trig_msk   : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL par_trig_val   : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL capture_rdy    : STD_LOGIC;
  SIGNAL fifo_tdata     : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL fifo_tvalid    : STD_LOGIC;
  SIGNAL fifo_tlast     : STD_LOGIC;
  SIGNAL fifo_tready    : STD_LOGIC                       := '1';
  SIGNAL fifo_tfull     : STD_LOGIC                       := '0';
  SIGNAL placeholder    : STD_LOGIC                       := '0';

  

BEGIN  -- ARCHITECTURE structural

  capture_ctrl_1: ENTITY work.capture_ctrl
    GENERIC MAP (
      DATA_WIDTH => DATA_WIDTH)
    PORT MAP (
      clk            => clk,
      rst            => rst,
      din            => din,
      armed          => armed,
      triggered      => triggered,
      rst_cmd        => rst_cmd,
      arm_cmd        => arm_cmd,
      sample_enable  => sample_enable,
      sample_cnt_rst => sample_cnt_rst,
      delay_cnt_4x   => delay_cnt_4x,
      read_cnt_4x    => read_cnt_4x,
      par_trig_msk   => par_trig_msk,
      par_trig_val   => par_trig_val,
      capture_rdy    => capture_rdy,
      fifo_tdata     => fifo_tdata,
      fifo_tvalid    => fifo_tvalid,
      fifo_tlast     => fifo_tlast,
      fifo_tready    => fifo_tready,
      fifo_tfull     => fifo_tfull,
      placeholder    => placeholder);

END ARCHITECTURE structural;
  
