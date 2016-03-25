-------------------------------------------------------------------------------
-- Title      : Zybo Board Top Level
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : zybo_top_capture_cotnrol_test.vhd
-- Created    : 2016-02-22
-- Last update: 2016-03-25
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity zybo_top is

  port (
    --Clock Source
    GCLK                                    : in  std_logic;  -- 100 MHz clock
    --LED Outputs    
    LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7  : out std_logic;
    --Buttons 
    BTNC, BTND, BTNL, BTNR, BTNU            : in  std_logic;
    --Temporary Data Ouput (JA10-JA7, JA4-JA1) 
    JA10, JA9, JA8, JA7, JA4, JA3, JA2, JA1 : out std_logic;
    --UART SIGNALS
    JB4                                     : in  std_logic := 'H';  --RX
    JB1                                     : out std_logic;  --TX
    --Switches
    SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0  : in  std_logic
    --Fixed Zync Signals
    --DDR_addr          : INOUT STD_LOGIC_VECTOR (14 DOWNTO 0);
    --DDR_ba            : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
    --DDR_cas_n         : INOUT STD_LOGIC;
    --DDR_ck_n          : INOUT STD_LOGIC;
    --DDR_ck_p          : INOUT STD_LOGIC;
    --DDR_cke           : INOUT STD_LOGIC;
    --DDR_cs_n          : INOUT STD_LOGIC;
    --DDR_dm            : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    --DDR_dq            : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    --DDR_dqs_n         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    --DDR_dqs_p         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    --DDR_odt           : INOUT STD_LOGIC;
    --DDR_ras_n         : INOUT STD_LOGIC;
    --DDR_reset_n       : INOUT STD_LOGIC;
    --DDR_we_n          : INOUT STD_LOGIC;
    --FIXED_IO_ddr_vrn  : INOUT STD_LOGIC;
    --FIXED_IO_ddr_vrp  : INOUT STD_LOGIC;
    --FIXED_IO_mio      : INOUT STD_LOGIC_VECTOR (53 DOWNTO 0);
    --FIXED_IO_ps_clk   : INOUT STD_LOGIC;
    --FIXED_IO_ps_porb  : INOUT STD_LOGIC;
    --FIXED_IO_ps_srstb : INOUT STD_LOGIC;
    );

end entity zybo_top;


architecture top of zybo_top is

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component Zynq_BD_wrapper is
    port (
      DDR_addr          : inout std_logic_vector (14 downto 0);
      DDR_ba            : inout std_logic_vector (2 downto 0);
      DDR_cas_n         : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_dm            : inout std_logic_vector (3 downto 0);
      DDR_dq            : inout std_logic_vector (31 downto 0);
      DDR_dqs_n         : inout std_logic_vector (3 downto 0);
      DDR_dqs_p         : inout std_logic_vector (3 downto 0);
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_we_n          : inout std_logic;
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      UART_rxd          : in    std_logic;
      UART_txd          : out   std_logic
      );
  end component;
  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant DATA_WIDTH           : positive                        := 32;
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal   reset, reset_clk_gen : std_logic                       := '1';  -- reset (async high, sync low)
  signal   run_clk              : std_logic                       := '0';  -- clock output of the clocking wizard
  signal   clk_locked           : std_logic                       := '0';  -- indicator if the clocking wizard has locked
  signal   din                  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal   armed                : std_logic;
  signal   triggered            : std_logic;
  signal   rst_cmd              : std_logic                       := '0';
  signal   arm_cmd              : std_logic;
  signal   sample_enable        : std_logic                       := '1';
  signal   sample_cnt_rst       : std_logic;
  signal   delay_cnt_4x         : std_logic_vector(16-1 downto 0) := (others => '0');
  signal   read_cnt_4x          : std_logic_vector(16-1 downto 0) := std_logic_vector(to_unsigned(1000, 16));
  signal   par_trig_msk         : std_logic_vector(32-1 downto 0) := X"00_00_00_03";
  signal   par_trig_val         : std_logic_vector(32-1 downto 0) := (others => '1');
  signal   capture_rdy          : std_logic;
  signal   in_fifo_tdata        : std_logic_vector(31 downto 0);
  signal   in_fifo_tvalid       : std_logic;
  signal   in_fifo_tlast        : std_logic;
  signal   in_fifo_tready       : std_logic;
  signal   in_fifo_tfull        : std_logic;
  signal   in_fifo_tempty       : std_logic;
  signal   in_fifo_tflush       : std_logic;
  --
  signal   out_fifo_tdata       : std_logic_vector(7 downto 0);
  signal   out_fifo_tvalid      : std_logic;
  signal   out_fifo_tlast       : std_logic;
  signal   out_fifo_tready      : std_logic;
  --
  signal   rx_get_more_data     : std_logic;
  signal   rx_data_ready        : std_logic;
  signal   rx                   : std_logic;

  signal tx_data_sent : std_logic;


  -----------------------------------------------------------------------------
  -- Aliases
  -----------------------------------------------------------------------------
  alias reset_btn : std_logic is BTND;
  alias CLK       : std_logic is GCLK;
  alias UART_RX   : std_logic is JB4;
  alias UART_TX   : std_logic is JB1;


  



begin  -- ARCHITECTURE top

    LD7 <= out_fifo_tdata(7);
    LD6<= out_fifo_tdata(6); 
    LD5<= out_fifo_tdata(5); 
    LD4<= out_fifo_tdata(4); 
    LD3<= out_fifo_tdata(3); 
    LD2<= out_fifo_tdata(2); 
    LD1<= out_fifo_tdata(1); 
    LD0<= out_fifo_tdata(0);

  --LED to indicate that the clock is locked
  


  uart_comms_test_blk : entity work.uart_comms
    generic map (
      baud_rate  => 115_200,
      clock_freq => 10_000_000)
    port map (
      clk              => run_clk,
      rst              => reset_clk_gen,
      rx_get_more_data => '1',
      rx               => UART_RX,
      tx_data_ready    => BTNU,
      tx               => UART_TX,
      data_in         => SW7& SW6& SW5& SW4& SW3& SW2& SW1& SW0,
      data_out          =>out_fifo_tdata);


  -----------------------------------------------------------------------------
  -- Component Instatiations
  -----------------------------------------------------------------------------

  -- purpose: this component will generate the desired system clock based on
  -- the 125 MHz input clock. Not the output is already downstream of a global
  -- clock buffer
  -- inputs : clk, reset
  -- outputs: clk_locked
  run_clk_component : entity work.clock_gen
    port map (
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
  run_clk_reset_proc : process (reset_btn, run_clk) is
    variable reset_dly_v : std_logic;
  begin  -- PROCESS reset_proc
    if reset_btn = '1' then
      reset       <= '1';
      reset_dly_v := '1';
    elsif rising_edge(run_clk) then
      if clk_locked = '1' then
        reset       <= reset_dly_v;
        reset_dly_v := '0';
      else
        reset       <= '1';
        reset_dly_v := '1';
      end if;
    end if;
  end process run_clk_reset_proc;


  reset_proc : process (reset_btn, clk) is
    variable reset_dly_v : std_logic;
  begin  -- PROCESS reset_proc
    if reset_btn = '1' then
      reset_clk_gen <= '1';
    elsif rising_edge(clk) then
      reset_clk_gen <= reset_dly_v;
      reset_dly_v   := '0';
    end if;
  end process reset_proc;

--zynq : ENTITY work.Zynq_BD_wrapper
--  PORT MAP (
--    DDR_addr          => DDR_addr,
--    DDR_ba            => DDR_ba,
--    DDR_cas_n         => DDR_cas_n,
--    DDR_ck_n          => DDR_ck_n,
--    DDR_ck_p          => DDR_ck_p,
--    DDR_cke           => DDR_cke,
--    DDR_cs_n          => DDR_cs_n,
--    DDR_dm            => DDR_dm,
--    DDR_dq            => DDR_dq,
--    DDR_dqs_n         => DDR_dqs_n,
--    DDR_dqs_p         => DDR_dqs_p,
--    DDR_odt           => DDR_odt,
--    DDR_ras_n         => DDR_ras_n,
--    DDR_reset_n       => DDR_reset_n,
--    DDR_we_n          => DDR_we_n,
--    FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
--    FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
--    FIXED_IO_mio      => FIXED_IO_mio,
--    FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
--    FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
--    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
--    UART_rxd          => UART_rxd,
--    UART_txd          => UART_txd);

end architecture top;
