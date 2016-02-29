-------------------------------------------------------------------------------
-- Title      : Human Readable Name for the module in this file.
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : storage.vhd
-- Created    : 2016-02-29
-- Last update: 2016-02-29
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This is where you will describe this file
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
-- 2016-02-29      1.0      Henny	    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity storage is
    generic ();
    port(
    clk   --! global clock, ?? MHz
            : in std_logic;
    reset --! Global reset
            : in std_logic;

    -- If we are not always 32 channels of storage, need an input telling me how many channels
            
    --Input FIFO interface from capture
    in_fifo_tdata --! Captured Data
            : in std_logic_vector(31 downto 0);
    in_fifo_tvalid -- indicating tdata has valid data
            : in std_logic;
    in_fifo_tlast  -- no planned usage
            : in std_logic;
    in_fifo_tready  -- outputted by FIFO saying it is ready
            : out  std_logic;
    in_fifo_tfull -- tell capture to stop capturing data
            : out  std_logic;
    in_fifo_tempty -- indicating all data has been transmitted to GUI, can do another capture
            : out  std_logic;
            
            
    --Output FIFO interface to UART
    out_fifo_tdata --! Captured Data, fed LSByte to UART
            : out std_logic_vector(7 downto 0);
    out_fifo_tvalid -- indicating tdata has valid data to transmit out
            : out std_logic;
    out_fifo_tlast  -- indicating that the end of this capture data
            : out std_logic;
    out_fifo_tready  -- received from UART, indicating to feed next byte out
            : in  std_logic

    );

end storage;

architecture behave of storage is


begin


-- Possible FIFOs from primitives, or use a core to maximize space (prob start with core)
-- I want to store 262140k Samples max, I think from what Ashton said
-- For Xilinx, implement a FIFO36E1 primitive. using AXI-Stream interface
-- For Altera, SCFIFO primitive. Is not AXI interface


--  ******* Need to decide hardware/software before I really start


-- Process to take Deep FIFO output, break it down to 8-bit stream to UART


end architecture behave;

