-------------------------------------------------------------------------------
-- Title      : Testbench for design "capture_ctrl" and "storage"
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : capture_ctrl+storage_tb.vhd
-- Created    : 2016-03-11
-- Last update: 2016-03-11
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Functional testbench for the integeration of the capture
-- control block and the storage FIFO. 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Ashton Johnson, Paul Henny, Ian Swepston, David Hurt
-----------------------------------------------------------------------------
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
-- 2016-03-11      1.0      ashton          Created
-------------------------------------------------------------------------------
USE std.textio.ALL;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;

---------------------------------------------

ENTITY capture_ctrl_storage_tb IS

END ENTITY capture_ctrl_storage_tb;

-------------------------------------------------------------------------------

ARCHITECTURE acj_func_test OF capture_ctrl_storage_tb IS

  -- component generics
  CONSTANT DATA_WIDTH : POSITIVE RANGE 1 TO 32 := 8;

  -- component ports
  SIGNAL rst             : STD_LOGIC                               := '1';
  SIGNAL din             : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL armed           : STD_LOGIC;
  SIGNAL triggered       : STD_LOGIC;
  SIGNAL rst_cmd         : STD_LOGIC                               := '0';
  SIGNAL arm_cmd         : STD_LOGIC                               := '0';
  SIGNAL sample_enable   : STD_LOGIC                               := '0';
  SIGNAL sample_cnt_rst  : STD_LOGIC;
  SIGNAL read_cnt_4x     : STD_LOGIC_VECTOR(16-1 DOWNTO 0)         := STD_LOGIC_VECTOR(to_unsigned(1000, 16));
  SIGNAL par_trig_msk    : STD_LOGIC_VECTOR(32-1 DOWNTO 0)         := X"FE_6B_28_40";
  SIGNAL par_trig_val    : STD_LOGIC_VECTOR(32-1 DOWNTO 0)         := (OTHERS => '1');
  SIGNAL capture_rdy     : STD_LOGIC;
  --
  SIGNAL in_fifo_tdata   : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL in_fifo_tvalid  : STD_LOGIC;
  SIGNAL in_fifo_tlast   : STD_LOGIC;
  SIGNAL in_fifo_tready  : STD_LOGIC;
  SIGNAL in_fifo_tfull   : STD_LOGIC;
  SIGNAL in_fifo_tempty  : STD_LOGIC;
  SIGNAL in_fifo_tflush  : STD_LOGIC;
  --
  SIGNAL out_fifo_tdata  : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL out_fifo_tvalid : STD_LOGIC;
  SIGNAL out_fifo_tlast  : STD_LOGIC;
  SIGNAL out_fifo_tready : STD_LOGIC;
  -- clock
  SIGNAL Clk             : STD_LOGIC                               := '1';

BEGIN  -- ARCHITECTURE acj_func_test

  -- component instantiation
  DUT : ENTITY work.capture_ctrl
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
      --sample_enable  => sample_enable,
      sample_cnt_rst => sample_cnt_rst,
      delay_cnt_4x   => read_cnt_4x,
      read_cnt_4x    => read_cnt_4x,
      par_trig_msk   => par_trig_msk,
      par_trig_val   => par_trig_val,
      capture_rdy    => capture_rdy,
      --
      fifo_tdata     => in_fifo_tdata,
      fifo_tvalid    => in_fifo_tvalid,
      fifo_tlast     => in_fifo_tlast,
      fifo_tready    => in_fifo_tready,
      fifo_tfull     => in_fifo_tfull,
      fifo_tempty    => in_fifo_tempty,
      fifo_aresetn   => in_fifo_tflush);

  sample_storage_block : ENTITY work.storage
--    GENERIC MAP (
--      FIFO_SIZE => SAMPLE_DEPTH)
    PORT MAP (
      clk             => clk,
      reset           => rst,
      --
      in_fifo_tdata   => in_fifo_tdata,
      in_fifo_tvalid  => in_fifo_tvalid,
      in_fifo_tlast   => in_fifo_tlast,
      in_fifo_tready  => in_fifo_tready,
      in_fifo_tfull   => in_fifo_tfull,
      in_fifo_tempty  => in_fifo_tempty,
      in_fifo_tflush  => in_fifo_tflush,
      --
      out_fifo_tdata  => out_fifo_tdata,
      out_fifo_tvalid => out_fifo_tvalid,
      out_fifo_tlast  => out_fifo_tlast,
      out_fifo_tready => out_fifo_tready);

  rst <= '0'     AFTER 5 US;
  -- clock generation
  Clk <= NOT Clk AFTER 2 NS;

  -- waveform generation
  WaveGen_Proc : PROCESS
  BEGIN
    -- insert signal assignments here


    WAIT UNTIL rst = '0';
    WAIT UNTIL capture_rdy='1';
    WAIT UNTIL rising_edge(clk);
    arm_cmd <= '1';
    WAIT UNTIL rising_edge(clk);
    arm_cmd <= '0';
    WAIT;


  END PROCESS WaveGen_Proc;


  din_gen : PROCESS (clk) IS
  BEGIN  -- PROCESS din_gen
    IF rising_edge(clk) THEN            -- rising clock edge
      IF rst = '1' THEN                 -- synchronous reset (active high)
        din <= (OTHERS => '0');
      ELSE
        din <= STD_LOGIC_VECTOR(UNSIGNED(din)+1);
      END IF;
    END IF;
  END PROCESS din_gen;


  PROCESS (armed) IS
  BEGIN  -- PROCESS
    IF rising_edge(armed) THEN
      REPORT "system has armed" SEVERITY NOTE;
    END IF;

  END PROCESS;

  PROCESS (triggered) IS
  BEGIN  -- PROCESS
    IF rising_edge(triggered) THEN
      REPORT "system has triggered" SEVERITY NOTE;
      ASSERT din = X"40" REPORT "system triggered on incorrect value" SEVERITY ERROR;

    END IF;

  END PROCESS;


  PROCESS IS
  BEGIN  -- PROCESS
    WAIT UNTIL falling_edge(rst);
    WAIT FOR 1 US;
    out_fifo_tready <= '1';
    WAIT;
  END PROCESS;

END ARCHITECTURE acj_func_test;

-------------------------------------------------------------------------------
------------------------------------------------
