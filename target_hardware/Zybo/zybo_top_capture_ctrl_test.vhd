-------------------------------------------------------------------------------
-- Title      : Zybo Board Top Level
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : zybo_top_capture_cotnrol_test.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Xilinx Zynq 7000 on a Digilent Zybo Board Top Level Module, 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Ashton Johnson, Paul Henny, Ian Swepston, David Hurt
-------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
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
ENTITY zybo_top IS

  PORT (
    clk : IN  STD_LOGIC;                     -- 125 MHz clock
    je  : out  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- PMOD JE inputs
    led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  --LED outputs
  --  sw  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Switches
    btn : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)   --Buttons
    );

END ENTITY zybo_top;


ARCHITECTURE top OF zybo_top IS

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
 
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  SIGNAL reset,reset_clk_gen      : STD_LOGIC := '1';  -- reset (async high, sync low)
  SIGNAL run_clk    : STD_LOGIC := '0';  -- clock output of the clocking wizard
  SIGNAL clk_locked : STD_LOGIC := '0';  -- indicator if the clocking wizard has locked
  -----------------------------------------------------------------------------
  -- Aliases
  -----------------------------------------------------------------------------
  ALIAS reset_btn   : STD_LOGIC IS btn(0);


  CONSTANT DATA_WIDTH : POSITIVE := 8;

  SIGNAL din            : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
  SIGNAL armed          : STD_LOGIC;
  SIGNAL triggered      : STD_LOGIC;
  SIGNAL rst_cmd        : STD_LOGIC                       := '0';
  SIGNAL arm_cmd        : STD_LOGIC;
  SIGNAL sample_enable  : STD_LOGIC                       := '1';
  SIGNAL sample_cnt_rst : STD_LOGIC;
  SIGNAL delay_cnt_4x   : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL read_cnt_4x    : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(1000,16));
  SIGNAL par_trig_msk   : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := X"00_00_00_03";
  SIGNAL par_trig_val   : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL capture_rdy    : STD_LOGIC;
  SIGNAL fifo_tdata     : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL fifo_tvalid    : STD_LOGIC;
  SIGNAL fifo_tlast     : STD_LOGIC;
  SIGNAL fifo_tready    : STD_LOGIC                       := '1';
  SIGNAL fifo_tfull     : STD_LOGIC                       := '0';
  SIGNAL placeholder    : STD_LOGIC                       := '0';



BEGIN  -- ARCHITECTURE top

  je<=fifo_tdata(7 downto 0);
  led(1)<=clk_locked;
  capture_ctrl_1 : ENTITY work.capture_ctrl
    GENERIC MAP (
      DATA_WIDTH => DATA_WIDTH)
    PORT MAP (
      clk            => run_clk,
      rst            => reset,
      din            => "000000"&btn(2)&btn(1),
      armed          => led(3),
      triggered      => led(2),
      rst_cmd        => reset_btn,
      arm_cmd        => btn(3),
   --   sample_enable  => sample_enable,
      sample_cnt_rst => sample_cnt_rst,
    --  delay_cnt_4x   => delay_cnt_4x,
      read_cnt_4x    => read_cnt_4x,
      par_trig_msk   => par_trig_msk,
      par_trig_val   => par_trig_val,
      capture_rdy    => led(0),
      fifo_tdata     => fifo_tdata,
      fifo_tvalid    => fifo_tvalid,
      fifo_tlast     => fifo_tlast,
      fifo_tready    => fifo_tready,
      fifo_tfull     => fifo_tfull,
      placeholder    => placeholder);
  -----------------------------------------------------------------------------
  -- Component Instatiations
  -----------------------------------------------------------------------------

  -- purpose: this component will generate the desired system clock based on
  -- the 125 MHz input clock. Not the output is already downstream of a global
  -- clock buffer
  -- inputs : clk, reset
  -- outputs: clk_locked
  run_clk_component : ENTITY work.clock_gen
    PORT MAP (
      -- Clock in ports
      clk_in1  => clk,
      -- Clock out ports  
      clk_out1 => run_clk,
      -- Status and control signals                
      reset    => reset_clk_gen,
      locked   => clk_locked
      );




  -- purpose: this process will reset the system when btn0 is pressed
  -- type   : combinational
  -- inputs : reset_btn, clk, clk_locked
  -- outputs: reset
  run_clk_reset_proc : PROCESS (reset_btn, run_clk) IS
  variable reset_dly_v : std_logic;
  BEGIN  -- PROCESS reset_proc
    IF reset_btn = '1' THEN
      reset <= '1';
      reset_dly_v := '1';
    ELSIF rising_edge(run_clk) THEN
    if clk_locked='1' then 
      reset <= reset_dly_v;
      reset_dly_v:='0';
     else 
      reset <= '1';
      reset_dly_v := '1';
      end if;
    END IF;
  END PROCESS run_clk_reset_proc;
  
  
  reset_proc : PROCESS (reset_btn, clk) IS
    variable reset_dly_v : std_logic;
    BEGIN  -- PROCESS reset_proc
      IF reset_btn = '1' THEN
        reset_clk_gen <= '1';
      ELSIF rising_edge(clk)  THEN
        reset_clk_gen <= reset_dly_v;
        reset_dly_v:='0';
      END IF;
    END PROCESS reset_proc;



END ARCHITECTURE top;
