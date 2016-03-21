-------------------------------------------------------------------------------
-- Title      : Zybo Board Top Level
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : zybo_top_capture_cotnrol_test.vhd
-- Created    : 2016-02-22
-- Last update: 2016-03-21
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
    GCLK : IN  STD_LOGIC;                     -- 100 MHz clock
    --Fixed Zync Signals
    DDR_addr          : INOUT STD_LOGIC_VECTOR (14 DOWNTO 0);
    DDR_ba            : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    DDR_cas_n         : INOUT STD_LOGIC;
    DDR_ck_n          : INOUT STD_LOGIC;
    DDR_ck_p          : INOUT STD_LOGIC;
    DDR_cke           : INOUT STD_LOGIC;
    DDR_cs_n          : INOUT STD_LOGIC;
    DDR_dm            : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    DDR_dq            : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    DDR_dqs_n         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    DDR_dqs_p         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    DDR_odt           : INOUT STD_LOGIC;
    DDR_ras_n         : INOUT STD_LOGIC;
    DDR_reset_n       : INOUT STD_LOGIC;
    DDR_we_n          : INOUT STD_LOGIC;
    FIXED_IO_ddr_vrn  : INOUT STD_LOGIC;
    FIXED_IO_ddr_vrp  : INOUT STD_LOGIC;
    FIXED_IO_mio      : INOUT STD_LOGIC_VECTOR (53 DOWNTO 0);
    FIXED_IO_ps_clk   : INOUT STD_LOGIC;
    FIXED_IO_ps_porb  : INOUT STD_LOGIC;
    FIXED_IO_ps_srstb : INOUT STD_LOGIC;
    --LED Outputs    
    LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7 : OUT STD_LOGIC;
    --Buttons 
    BTNC, BTND, BTNL, BTNR, BTNU : IN  STD_LOGIC;  
    --Temporary Data Ouput (JA10-JA7, JA4-JA1) 
    JA10,JA9,JA8,JA7,JA4,JA3,JA2,JA1 : OUT STD_LOGIC
    );

END ENTITY zybo_top;


ARCHITECTURE top OF zybo_top IS

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  alias CLK : std_logic is GCLK;
  SIGNAL reset, reset_clk_gen : STD_LOGIC := '1';  -- reset (async high, sync low)
  SIGNAL run_clk              : STD_LOGIC := '0';  -- clock output of the clocking wizard
  SIGNAL clk_locked           : STD_LOGIC := '0';  -- indicator if the clocking wizard has locked
  -----------------------------------------------------------------------------
  -- Aliases
  -----------------------------------------------------------------------------
  ALIAS reset_btn             : STD_LOGIC IS BTND;


  CONSTANT DATA_WIDTH : POSITIVE := 8;

  SIGNAL din             : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
  SIGNAL armed           : STD_LOGIC;
  SIGNAL triggered       : STD_LOGIC;
  SIGNAL rst_cmd         : STD_LOGIC                       := '0';
  SIGNAL arm_cmd         : STD_LOGIC;
  SIGNAL sample_enable   : STD_LOGIC                       := '1';
  SIGNAL sample_cnt_rst  : STD_LOGIC;
  SIGNAL delay_cnt_4x    : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL read_cnt_4x     : STD_LOGIC_VECTOR(16-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(1000, 16));
  SIGNAL par_trig_msk    : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := X"00_00_00_03";
  SIGNAL par_trig_val    : STD_LOGIC_VECTOR(32-1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL capture_rdy     : STD_LOGIC;
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
  
  
  COMPONENT Zynq_BD_wrapper IS
    PORT (
      DDR_addr          : INOUT STD_LOGIC_VECTOR (14 DOWNTO 0);
      DDR_ba            : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
      DDR_cas_n         : INOUT STD_LOGIC;
      DDR_ck_n          : INOUT STD_LOGIC;
      DDR_ck_p          : INOUT STD_LOGIC;
      DDR_cke           : INOUT STD_LOGIC;
      DDR_cs_n          : INOUT STD_LOGIC;
      DDR_dm            : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      DDR_dq            : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      DDR_dqs_n         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      DDR_dqs_p         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      DDR_odt           : INOUT STD_LOGIC;
      DDR_ras_n         : INOUT STD_LOGIC;
      DDR_reset_n       : INOUT STD_LOGIC;
      DDR_we_n          : INOUT STD_LOGIC;
      FIXED_IO_ddr_vrn  : INOUT STD_LOGIC;
      FIXED_IO_ddr_vrp  : INOUT STD_LOGIC;
      FIXED_IO_mio      : INOUT STD_LOGIC_VECTOR (53 DOWNTO 0);
      FIXED_IO_ps_clk   : INOUT STD_LOGIC;
      FIXED_IO_ps_porb  : INOUT STD_LOGIC;
      FIXED_IO_ps_srstb : INOUT STD_LOGIC;
      UART_rxd          : IN    STD_LOGIC;
      UART_txd          : OUT   STD_LOGIC
      );
  END COMPONENT;


  SIGNAL uart_txd, uart_rxd : STD_LOGIC := '0';

BEGIN  -- ARCHITECTURE top

  JA10<=out_fifo_tdata(7);
  JA9<=out_fifo_tdata(6);
  JA8<=out_fifo_tdata(5);
  JA7<=out_fifo_tdata(4);
  JA4<=out_fifo_tdata(3);
  JA3<=out_fifo_tdata(2);
  JA2<=out_fifo_tdata(1);
  JA1<=out_fifo_tdata(0);
  
  LD1 <= clk_locked;
  capture_ctrl_1 : ENTITY work.capture_ctrl
    GENERIC MAP (
      DATA_WIDTH => DATA_WIDTH)
    PORT MAP (
      clk            => run_clk,
      rst            => reset,
      din            => "00000" & btnl & btnc & btnr,
      armed          => ld3,
      triggered      => ld2,
      rst_cmd        => btnd,
      arm_cmd        => btnu,
      --   sample_enable  => sample_enable,
      sample_cnt_rst => sample_cnt_rst,
      --  delay_cnt_4x   => delay_cnt_4x,
      read_cnt_4x    => read_cnt_4x,
      par_trig_msk   => par_trig_msk,
      par_trig_val   => par_trig_val,
      capture_rdy    => ld0,
      fifo_tdata     => in_fifo_tdata,
      fifo_tvalid    => in_fifo_tvalid,
      fifo_tlast     => in_fifo_tlast,
      fifo_tready    => in_fifo_tready,
      fifo_tfull     => in_fifo_tfull,
      fifo_tempty    => in_fifo_tempty,
      fifo_aresetn   => in_fifo_tflush);



  sample_storage_block : ENTITY work.storage
    GENERIC MAP (
      FIFO_SIZE => 2**4)
    PORT MAP (
      clk             => run_clk,
      reset           => reset,
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
      out_fifo_tready => '1');

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
    VARIABLE reset_dly_v : STD_LOGIC;
  BEGIN  -- PROCESS reset_proc
    IF reset_btn = '1' THEN
      reset       <= '1';
      reset_dly_v := '1';
    ELSIF rising_edge(run_clk) THEN
      IF clk_locked = '1' THEN
        reset       <= reset_dly_v;
        reset_dly_v := '0';
      ELSE
        reset       <= '1';
        reset_dly_v := '1';
      END IF;
    END IF;
  END PROCESS run_clk_reset_proc;


  reset_proc : PROCESS (reset_btn, clk) IS
    VARIABLE reset_dly_v : STD_LOGIC;
  BEGIN  -- PROCESS reset_proc
    IF reset_btn = '1' THEN
      reset_clk_gen <= '1';
    ELSIF rising_edge(clk) THEN
      reset_clk_gen <= reset_dly_v;
      reset_dly_v   := '0';
    END IF;
  END PROCESS reset_proc;

zynq : ENTITY work.Zynq_BD_wrapper
  PORT MAP (
    DDR_addr          => DDR_addr,
    DDR_ba            => DDR_ba,
    DDR_cas_n         => DDR_cas_n,
    DDR_ck_n          => DDR_ck_n,
    DDR_ck_p          => DDR_ck_p,
    DDR_cke           => DDR_cke,
    DDR_cs_n          => DDR_cs_n,
    DDR_dm            => DDR_dm,
    DDR_dq            => DDR_dq,
    DDR_dqs_n         => DDR_dqs_n,
    DDR_dqs_p         => DDR_dqs_p,
    DDR_odt           => DDR_odt,
    DDR_ras_n         => DDR_ras_n,
    DDR_reset_n       => DDR_reset_n,
    DDR_we_n          => DDR_we_n,
    FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
    FIXED_IO_mio      => FIXED_IO_mio,
    FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
    UART_rxd          => UART_rxd,
    UART_txd          => UART_txd);

END ARCHITECTURE top;
