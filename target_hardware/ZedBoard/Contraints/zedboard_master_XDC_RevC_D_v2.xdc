# ----------------------------------------------------------------------------
#     _____
#    / #   /____   \____
#  / \===\   \==/
# /___\===\___\/  AVNET Design Resource Center
#      \======/         www.em.avnet.com/drc
#       \====/
# ----------------------------------------------------------------------------
#
#  Created With Avnet UCF Generator V0.4.0
#     Date: Saturday, June 30, 2012
#     Time: 12:18:55 AM
#
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
#
#  Please direct any questions to:
#     ZedBoard.org Community Forums
#     http://www.zedboard.org
#
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2012 Avnet, Inc.
#                              All rights reserved.
#
# ----------------------------------------------------------------------------
#
#  Notes:
#
#  10 August 2012
#     IO standards based upon Bank 34 and Bank 35 Vcco supply options of 1.8V,
#     2.5V, or 3.3V are possible based upon the Vadj jumper (J18) settings.
#     By default, Vadj is expected to be set to 1.8V but if a different
#     voltage is used for a particular design, then the corresponding IO
#     standard within this UCF should also be updated to reflect the actual
#     Vadj jumper selection.
#
#  09 September 2012
#     Net names are not allowed to contain hyphen characters '-' since this
#     is not a legal VHDL87 or Verilog character within an identifier.
#     HDL net names are adjusted to contain no hyphen characters '-' but
#     rather use underscore '_' characters.  Comment net name with the hyphen
#     characters will remain in place since these are intended to match the
#     schematic net names in order to better enable schematic search.
#
#  17 April 2014
#     Pin constraint for toggle switch SW7 was corrected to M15 location.
#
#  16 April 2015
#     Corrected the way that entire banks are assigned to a particular IO
#     standard so that it works with more recent versions of Vivado Design
#     Suite and moved the IO standard constraints to the end of the file
#     along with some better organization and notes like we do with our SOMs.
#
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Audio Codec - Bank 13
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y9 [get_ports GCLK]

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# JB Pmod - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN W12 [get_ports JB1]
set_property PACKAGE_PIN W8 [get_ports JB4]

# ----------------------------------------------------------------------------
# JC Pmod - Bank 13
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# OLED Display - Bank 13
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# HDMI Output - Bank 33
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports LD0]
set_property PACKAGE_PIN T21 [get_ports LD1]
set_property PACKAGE_PIN U22 [get_ports LD2]
set_property PACKAGE_PIN U21 [get_ports LD3]
set_property PACKAGE_PIN V22 [get_ports LD4]
set_property PACKAGE_PIN W22 [get_ports LD5]
set_property PACKAGE_PIN U19 [get_ports LD6]
set_property PACKAGE_PIN U14 [get_ports LD7]

# ----------------------------------------------------------------------------
# VGA Output - Bank 33
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN R16 [get_ports BTND]

# ----------------------------------------------------------------------------
# USB OTG Reset - Bank 34
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# XADC GIO - Bank 34
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Miscellaneous - Bank 34
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# USB OTG Reset - Bank 35
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# User DIP Switches - Bank 35
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN F22 [get_ports SW0]
set_property PACKAGE_PIN G22 [get_ports SW1]
set_property PACKAGE_PIN H22 [get_ports SW2]
set_property PACKAGE_PIN F21 [get_ports SW3]
set_property PACKAGE_PIN H19 [get_ports SW4]
set_property PACKAGE_PIN H18 [get_ports SW5]
set_property PACKAGE_PIN H17 [get_ports SW6]
set_property PACKAGE_PIN M15 [get_ports SW7]

# ----------------------------------------------------------------------------
# XADC AD Channels - Bank 35
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 13
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 33
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 34
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# FMC Expansion Connector - Bank 35
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are
# evaluated prior to other PACKAGE_PIN constraints being applied, then
# the IOSTANDARD specified will likely not be applied properly to those
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed
# within the XDC file in a location that is evaluated AFTER all
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ----------------------------------------------------------------------------

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]]

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]]

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]]



