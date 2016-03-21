-------------------------------------------------------------------------------
-- Title      : Zybo Board Top Level
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : zybo_top.vhd
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

ENTITY zybo_top IS

  PORT (
    clk : IN  STD_LOGIC;                      -- 125 MHz clock
    je  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- PMOD JE inputs
    led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  --LED outputs
    sw  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Switches
    btn : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)   --Buttons
    );

END ENTITY zybo_top;


ARCHITECTURE top OF zybo_top IS

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  COMPONENT clock_gen
    PORT
      (                                 -- Clock in ports
        clk_in1   : IN  STD_LOGIC;
        -- Clock out ports
        clk_25mhz : OUT STD_LOGIC;
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
  ALIAS reset_btn   : STD_LOGIC IS btn(0);

BEGIN  -- ARCHITECTURE top




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
      clk_out1 => run_clk,
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


END ARCHITECTURE top;
