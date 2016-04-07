-------------------------------------------------------------------------------
-- Title      : ZED Board Top Level
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : zed_top.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Xilinx Zynq 7000 on a Digilent Zed Board Top Level Module, 
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

ENTITY zed_top IS

  PORT (
    GCLK                                    : in  std_logic;  -- 100 MHz clock
     --LED Outputs    
     LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7  : out std_logic;
     --Buttons 
      BTND           : in  std_logic;
     --Temporary Data Ouput (JA10-JA7, JA4-JA1) 
    --JA10, JA9, JA8, JA7, JA4, JA3, JA2, JA1 : out std_logic;
     --UART SIGNALS
     JB4                                     : in  std_logic := 'H';  --RX
     JB1                                     : out std_logic;  --TX
     --Switches
     SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0  : in  std_logic
    );

END ENTITY zed_top;


ARCHITECTURE top OF zed_top IS

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  COMPONENT clock_gen
    PORT
      (                                 -- Clock in ports
        clk_in1   : IN  STD_LOGIC;
        -- Clock out ports
        clk_out1 : OUT STD_LOGIC;
        -- Status and control signals
        reset     : IN  STD_LOGIC;
        locked    : OUT STD_LOGIC
        );
  END COMPONENT;
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  SIGNAL reset      : STD_LOGIC := '1';  -- reset (async high, sync low)
  SIGNAL run_clk    : STD_LOGIC := '0';  -- clock output of the clocking wizard
  SIGNAL clk_locked : STD_LOGIC := '0';  -- indicator if the clocking wizard has locked
  -----------------------------------------------------------------------------
  -- Aliases
  -----------------------------------------------------------------------------
    alias reset_btn : std_logic is BTND;
    alias CLK       : std_logic is GCLK;
    alias UART_RX   : std_logic is JB4;
    signal UART_TX   : std_logic; 
  

BEGIN  -- ARCHITECTURE top

      LD3<=clk_locked;
      LD7<=not UART_RX;--just activity indicator
      LD6<=not UART_TX;--just activity indicator
      JB1<=UART_TX;--send UART_TX out
  


  -----------------------------------------------------------------------------
  -- Component Instatiations
  -----------------------------------------------------------------------------

  -- purpose: this component will generate the desired system clock based on
  -- the 125 MHz input clock. Not the output is already downstream of a global
  -- clock buffer
  -- inputs : clk, reset
  -- outputs: clk_locked
  run_clk_component : clock_gen
    PORT MAP (
      -- Clock in ports
      clk_in1  => clk,
      -- Clock out ports  
      clk_out1 => run_clk, -- FIXIT: Port map doesn't match component, can't open IP to see what is right
      -- Status and control signals                
      reset    => reset_btn,
      locked   => clk_locked
      );

  -- purpose: this process will reset the system when btn0 is pressed
  -- type   : combinational
  -- inputs : reset_btn, clk, clk_locked
  -- outputs: reset
  reset_proc : PROCESS (reset_btn, clk) IS
  BEGIN  -- PROCESS reset_proc
    IF reset_btn = '1' THEN
      reset <= '1';
    ELSIF rising_edge(clk) THEN
      reset <= '0';
    END IF;
  END PROCESS reset_proc;

  la_top_inst : entity work.la_top
    generic map (
      BAUD_RATE => 115_200,
      INPUT_CLK_RATE_HZ => 10_000_000,
      DATA_WIDTH  => 8,
      SAMPLE_DEPTH  => 2**8)
    port map (
      --COMMON INTERFACES
      clk => run_clk,
      rst => reset, --reset, (async high/ sync low)
      
      --data input. default to zeros so you don't have to hook all 32 lines up.
      din(31 downto 8) => (others => '0'),
      din(7) => SW7,
      din(6) => SW6,
      din(5) => SW5,
      din(4) => SW4,
      din(3) => SW3, 
      din(2) => SW2,
      din(1) => SW1,
      din(0) => SW0,
      
      --UART INTERFACES
      uart_rx => UART_RX, -- UART Receive Data
      uart_tx => UART_TX, -- UART Transmit Data
      armed => LD1, 
      triggered => LD2,
      capture_rdy=>LD0);
      
  

END ARCHITECTURE top;
