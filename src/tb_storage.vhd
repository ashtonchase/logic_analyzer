-------------------------------------------------------------------------------
-- Title      : Logic Analyzer Storage Testbench
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : storage.vhd
-- Created    : 2016-02-29
-- Last update: 2016-02-29
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench for storage.vhd
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
-- 2016-03-07    1.0      Henny	    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity tb_storage is
end entity tb_storage;

architecture behave of tb_storage is
    signal clk : std_logic;
    signal reset : std_logic;
    
    -- In side of the storage
    signal data_in : std_logic_vector(31 downto 0);
    signal valid_in : std_logic := '0';
    signal last_in : std_logic := '0';
    signal ready_in : std_logic := '0';
    signal full_in : std_logic := '0';
    signal empty : std_logic := '0';
    signal flush : std_logic := '0';

    -- Out side of storage
    signal data_out : std_logic_vector(7 downto 0);
    signal valid_out : std_logic := '0';
    signal last_out : std_logic := '0';
    signal ready_out : std_logic := '0';
    
    -- Parameters to change to test
    signal data : unsigned(31 downto 0) := x"A5A51234";
    
    signal data_at_out : unsigned(31 downto 0) := (others => '0');
    signal correct_data_value : unsigned(31 downto 0) := data;
begin


   clk_proc : process
   begin
        clk <= '0';
        wait for 5ns;
        loop
            wait for 5ns;
            clk <= '1';
            wait for 5ns;
            clk <= '0';
        end loop;
    end process clk_proc;
    
    -- Calling Instance of Storage
    storage : entity work.storage
        generic map ( FIFO_SIZE=>32 )
        port map (
        clk   => clk,
        reset => reset,
        
        in_fifo_tdata => data_in,
        in_fifo_tvalid => valid_in,
        in_fifo_tlast  => last_in,
        in_fifo_tready  => ready_in,
        in_fifo_tfull => full_in,
        in_fifo_tempty => empty,
        in_fifo_tflush => flush,
                
        --Output FIFO interface to UART
        out_fifo_tdata => data_out,
        out_fifo_tvalid => valid_out,
        out_fifo_tlast  => last_out,
        out_fifo_tready  => ready_out 
    );
        
    ----------------------------------------------
    -- inputs words into the "storage"
    ----------------------------------------------
    input_main_pr : process
        -- Puts an incrementing word into storage, delay conctrols how often
        procedure store_word(delay : integer := 0) is 
        begin
            valid_in <= '0'; -- will be overwritten if delay=0
            data_in <= std_logic_vector(data);
            data <= data + x"01010101";
            -- will wait that many clock cycles before writing another word
            for i in 1 to delay loop 
                wait until rising_edge(clk);
            end loop;
            valid_in <= '1';
            wait until ready_in='1' and rising_edge(clk);
            if delay/=0 then
                valid_in <= '0';
            end if;
        end procedure;
        
    begin
        reset <= '1';
        wait for 20ns;
        report "De-asserting reset";
        reset <= '0';
        -- Quick Storage
        for idx in 0 to 4 loop
            store_word(0);
        end loop;
        -- Sweeps Slow Storage
        for idx in 0 to 15 loop
            store_word(idx);
        end loop;
        wait for 50ns;
        
        ------------------------------------
        -- Test last
        last_in <= '1';
        store_word(3);
        wait for 100ns;
        last_in <= '0';
        
        ------------------------------------
        -- Try to Store Data before last word has been outputted
        store_word(7);
        
        ------------------------------------
        wait for 6us; -- wait for out to finish its pull tests
        
        wait;
    end process input_main_pr;
    
    ----------------------------------------------
    -- outputs words into the "storage"
    ----------------------------------------------
    output_main_pr : process
        -- Pulls words out of storage
        --**************** Cannot handle a delay of 0 maybe 1
        procedure pull_word(delay : integer := 0) is 
        begin
            wait until rising_edge(clk);
            for idx in 0 to 3 loop
                ready_out <= '1';
                wait until rising_edge(clk) and valid_out='1';
                data_at_out(7+idx*8 downto idx*8) <= unsigned(data_out);
                ready_out <= '0';
                -- will wait that many clock cycles before writing another word
                for i in 1 to delay loop 
                    wait until rising_edge(clk);
                end loop;
            end loop;
            if data_at_out/=correct_data_value then
                report "**************Pulled wrong value out " severity error;
            end if;
            correct_data_value <= correct_data_value + x"01010101";
        end procedure;
        
    begin
        wait until empty='0';
        ------------------------------------
        -- Pulling at different rates
        for idx in 22 downto 2 loop
            wait for 50ns;
            pull_word(idx);
        assert empty='0' report "FIFO should not be empty, pulled tlast" severity error;
        end loop;
        
        ------------------------------------
        -- Testing handling of last word
        wait for 300ns;
        pull_word(5);
        assert empty='1' report "FIFO should be empty, pulled tlast" severity error;
        
        
        ------------------------------------
        -- Testing handling of last word
        wait for 300ns;
        pull_word(5);
        -- Should it say empty in our scheme, without giving a last
        --assert empty='1' report "FIFO should be empty, pulled tlast" severity error;
        
        
        --*********** tests still needed
        -- Flush
        -- Fast read out, I didn't design it to work
        -- Full being accurate
        
        
        wait;
    end process output_main_pr;

end architecture behave;
































