#ignore any timing regarding the LEDs
#set_false_path -from [get_pins -hierarchical -filter { NAME =~  "*" }] -to [get_ports -filter { NAME =~  "*LD*" }]
#set_false_path -from [get_pins -hierarchical -filter { NAME =~  "*" }] -to [get_ports -filter { NAME =~  "*LD*" }]
#set_false_path -from [get_pins -hierarchical -filter { NAME =~  "*" }] -to [get_ports -filter { NAME =~  "*LD*" }]
#set_false_path -from [get_pins -hierarchical -filter { NAME =~  "*" }] -to [get_ports -filter { NAME =~  "*LD*" }]

#define external clock to 100MHz
create_clock -period 10.000 -name GCLK -waveform {0.000 5.000} [get_ports GCLK]
#define output of clock generator to 100MHz
create_clock -period 10.000 -name VIRTUAL_clk_out1_clock_gen -waveform {0.000 5.000}
#define baud rate clocks
create_generated_clock -name la_top_inst/SUMP_UART_block/u1/baud_clock -source [get_pins run_clk_component/inst/mmcm_adv_inst/CLKOUT0] -divide_by 16 [get_pins la_top_inst/SUMP_UART_block/u1/baud_clock_reg/Q]
create_generated_clock -name la_top_inst/SUMP_UART_block/u1/baud_clock_x16_reg_0 -source [get_pins run_clk_component/inst/mmcm_adv_inst/CLKOUT0] -divide_by 54 [get_pins la_top_inst/SUMP_UART_block/u1/baud_clock_x16_reg/Q]
#define min/max delay of reset button (BTND)
set_input_delay -clock [get_clocks GCLK] -min -add_delay 4.000 [get_ports BTND]
set_input_delay -clock [get_clocks GCLK] -max -add_delay 6.000 [get_ports BTND]
#define min/max delay of input switches (SW0-SW7)
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW0]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW0]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW1]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW1]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW2]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW2]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW3]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW3]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW4]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW4]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW5]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW5]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW6]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW6]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay 4.000 [get_ports SW7]
#set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 6.000 [get_ports SW7]
##define output min/max delay for LEDs (LD0-LD3)
#set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay -10.000 [get_ports LD0]
#set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 30.000 [get_ports LD0]
#set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -min -add_delay -10.000 [get_ports LD2]
#set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clock_gen] -max -add_delay 30.000 [get_ports LD2]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -min -add_delay 5.000 [get_ports LD1]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -max -add_delay 5.000 [get_ports LD1]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -min -add_delay 5.000 [get_ports LD4]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -max -add_delay 5.000 [get_ports LD4]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -min -add_delay 5.000 [get_ports LD5]
#set_output_delay -clock [get_clocks run_clk_component/inst/clk_in1] -max -add_delay 5.000 [get_ports LD5]
##ignore any timing paths related to the LEDs
#set_false_path -from [get_pins la_top_inst/capture_control_block/triggered_o_reg/C] -to [get_ports LD2]
#set_false_path -from [get_pins la_top_inst/capture_control_block/capture_rdy_o_reg/C] -to [get_ports LD0]
