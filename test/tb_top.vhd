-------------------------------------------------------------------------------
-- Title      : Top Level Test Bench
-- Project    : fpga_logic_analyzer
-------------------------------------------------------------------------------
-- File       : tb_top.vhd
-- Created    : 2016-02-22
-- Last update: 2016-02-22
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench for la_top
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
-- Date          Version    Author        Description
-- 2016-02-22      0.1      henny          Created UART Transmitter
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
end tb_top;

architecture behav of tb_top is
    signal clk : std_logic := '0';
    signal rst : std_logic;
    signal logic_in : std_logic_vector(31 downto 0) := x"deadbeef";
    
    signal msg_finish : std_logic;
        
    signal poll_count : integer;
    signal poll_enable : std_logic;
    signal poll_start : std_logic;
    
    signal uart_rx : std_logic := '1';
    signal uart_tx : std_logic := '1';
    

    constant BAUD_DIVIDER : integer := 100;
    
    -- Data type
    type slv8_arr is array (natural range <>) of std_logic_vector(7 downto 0);
    type cmd_record is record
        mess : slv8_arr(0 to 4);
        length : integer range 0 to 5;
    end record cmd_record;
    
begin

  -- LA Top instance
  la_top_inst : entity work.la_top

    port map (
      clk => clk,
      rst => rst,
      
      --data input. default to zeros so you don't have to hook all 32 lines up.
      din(31 downto 0) => logic_in,
      
      --UART INTERFACES
      uart_rx => uart_rx, -- UART Receive Data
      uart_tx => uart_tx); -- UART Transmit Data
      
   clk_proc : process
   variable counter: natural range 0 to 256;
   begin
        clk <= '0';
        wait for 5ns;
        loop
            wait for 5ns;
            clk <= '1';
            wait for 5ns;
            clk <= '0';
            counter:=(counter+1) mod 256;
            logic_in<=std_logic_vector(to_unsigned(counter,32));
        end loop;
    end process clk_proc;
    
    -------------------------------------------------------
    -- Baudrate Generator 
    -------------------------------------------------------
    output_bl : block is 
        signal baud_counter : integer;
        signal baud_enable : std_logic;
        
        constant c_reset : cmd_record := ((x"00", others => x"00"), 1);
        constant c_run : cmd_record := ((x"01", others => x"00"), 1);
        constant c_test_byte : cmd_record := ((x"A5", others => x"00"), 1);
        constant c_trig_mask : cmd_record := ((x"C0", x"0C", x"00", x"00", x"00", others => x"00"), 5);
        constant c_trig_val : cmd_record := ((x"C1", x"07", x"00", x"00", x"00", others => x"00"), 5);
        constant c_read_cnt : cmd_record := ((x"81", x"04", x"00", x"04", x"00", others => x"00"), 5);
        constant c_set_divide : cmd_record := ((x"80", x"08", x"00", x"00", x"00", others => x"00"), 5);
        signal resp_to_send : cmd_record;
    begin
        baudrate_p : process(clk) is
        begin
            if rising_edge(clk) then
                if rst='1' then
                    baud_enable <= '0';
                    baud_counter <= BAUD_DIVIDER-1;
                else
                    if baud_counter=0 then
                        baud_enable <= '1';
                        baud_counter <= BAUD_DIVIDER-1;
                    else
                        baud_counter <= baud_counter - 1;
                        baud_enable <= '0';
                    end if;
                end if;
            end if;
        end process baudrate_p;
        
    ---------------------------------------------------------------
    -- Rx Control Block
    ---------------------------------------------------------------
        status_out_p : process(clk) is
            variable count : integer range -1 to 9;
            variable byte_count : integer;
            variable resp_count : integer;
        begin
            if rising_edge(clk) then
                if rst='1' then
                    count := 8;
                    byte_count := 0;
                    uart_rx <= '1';
                    resp_count := 0;
                    msg_finish <= '1';
                else
                    -- Where you control what messages are sent
                    case resp_count is
                        when 0 => resp_to_send <= c_reset;
                        when 1 => resp_to_send <= c_trig_mask;
                        when 2 => resp_to_send <= c_trig_val;
                        when 3 => resp_to_send <= c_read_cnt;
                        when 4 => resp_to_send <= c_set_divide;
                        when 5 => resp_to_send <= c_run;
                        when 6 => resp_to_send <= c_trig_mask;
                        when 7 => resp_to_send <= c_reset;
                        when 8 => resp_to_send <= c_reset;
                        when others =>
                    end case;
                    if msg_finish='0' then
                        if baud_enable='1' then
                            if count=8 then
                                uart_rx <= '0'; 
                            elsif count=-1 then
                                uart_rx <= '1';
                                byte_count := byte_count + 1;
                                count := 9;
                                if byte_count=resp_to_send.length then
                                    byte_count := 0;
                                    resp_count := resp_count+1;
                                    msg_finish <= '1';
                                end if;
                            else
                                uart_rx <= resp_to_send.mess(byte_count)(7-count);
                            end if;
                            count := count-1;
                        end if;
                    else
                        poll_start <= '1';
                        if poll_enable='1' then
                            poll_start <= '0';
                            msg_finish <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end process status_out_p;
    end block output_bl;
    
    ---------------------------------------------------------------
    -- How often commands are sent to the LA
    ---------------------------------------------------------------
    polling_p : process(clk) is
        constant poll_max : integer := 100;
    begin
    if rising_edge(clk) then
        if rst='1' then
            poll_enable <= '0';
            poll_count <= poll_max;
        else
            if poll_start='1' then
                if poll_count=0 then
                    poll_enable <= '1';
                    poll_count <= poll_max;
                else
                    poll_enable <= '0';
                    poll_count <= poll_count - 1;
                end if;
            else
                poll_enable <= '0';
                poll_count <= poll_max;
            end if;
        end if;
    end if;
    end process polling_p;  
    
    ---------------------------------------------------------------
    -- Main Control of Testbench
    ---------------------------------------------------------------
    main_p : process
    begin
        rst <= '1';
        wait for 20ns;
        rst <= '0';
        wait;
    end process main_p;
    
end architecture behav;