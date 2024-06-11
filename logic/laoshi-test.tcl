#!/usr/bin/expect
#
# This is a small test script for the laoshi rom bank switcher GAL.
# It uses TCL's expect, and Chris Hooper's "Brutus28" hardware and
# "term" terminal program.
#

set debug 0

#
# Pin mapping for the GAL under test
#
# Pins 1-10 have no offset in Brutus28.
# Pins 11-20 have an offset of 8 bits in Brutus28.
#
# This is because Brutus28 is counting the pins of the DIP28 socket
# rather than the pins of the DIP20 GAL.

# Pin 19 is an output used to clock the flip-flops. Therefore you
# need to connect pin 1 and pin 19 of the GAL (Or pin 1 and pin 27
# on Brutus)

array set PINs {
	CLK    0x00001
	A12    0x00002
	A7     0x00004
	A6     0x00008
	A5     0x00010
	IMG    0x00020
	A11    0x00040
	A1     0x00080
	A0     0x00100
	GND    0x00200
	GALOE  0x0040000
	A15    0x0080000
	A10    0x0100000
	OE     0x0200000
	A9     0x0400000
	A8     0x0800000
	A13    0x1000000
	A14    0x2000000
	CLKOUT 0x4000000
	VCC    0x8000000
}

#
# Convert binary numbers to integers:
#
proc binary_to_int {binary} {
    set result 0
    set power 0
    set length [string length $binary]
    
    # Iterate through each character of the binary string in reverse order
    for {set i [expr $length - 1]} {$i >= 0} {incr i -1} {
        set bit [string index $binary $i]
        
        # Convert character '0' or '1' to integer and add to result
        set bit_value [expr {$bit eq "1" ? 1 : 0}]
        set result [expr {$result + ($bit_value * pow(2, $power))}]
        
        # Increment power for next bit position
        incr power
    }
    
    return $result
}

#
# Get the combined hex value of given pins
#
proc pins_to_hex {args} {
    set result 0  ;# Initialize result to 0 (all bits off)

    foreach pin $args {
        if {[info exists ::PINs($pin)]} {
            set bit_position $::PINs($pin)
            incr result $bit_position
        } else {
            puts "WARNING: Pin '$pin' not found in PINs array"
        }
    }
    # Format result as hex string with leading zeros
    return [format %x $result]
}

#
# Get human readable pin names from a hex number
#
proc hex_to_pins {hex_number} {
    set result [list]  ;# Initialize result as an empty list

    # Convert the hex number to an integer
    set int_number [scan $hex_number %x]

    # Iterate over the array and check which pins are set
    foreach pin [array names ::PINs] {
        set bit_position $::PINs($pin)
        if {($int_number & $bit_position) != 0} {
            lappend result $pin
        }
    }

    return $result
}

#
# Shortcuts for talking to Brutus28 with term.
#

proc nxt {} {
  send "\r"
  expect "CMD>"
}

proc setup {} {
  expect "<< Type ^X to exit."
  nxt
  send "reset\r"
  expect "<< Reopened "
  nxt
}

proc cleanup {} {
  send ""
  interact
}

proc pld_on {} {
  send "pld enable"
  nxt
}

proc pld_off {} {
  send "pld disable"
  nxt
  nxt
}

#
# Read all current inputs from Brutus as a hex number
#

proc inputs {} {
  global debug
  send "pld input\r"
  expect -re "Input=(\[01\]\*)?\r" {
    set result  $expect_out(1,string)
  }

  set float_result [binary_to_int $result]
  set decimal_result [expr {int($float_result)}]
  set hex_result [format "%x" $decimal_result]

  set pin_names [hex_to_pins $hex_result]
  #send_user "State: $result -> HEX: $hex_result -> [join $pin_names ", "]\n"
  if { $debug == 1 } {
    send_user "State: $result -> HEX: $hex_result -> $pin_names\n"
  }

  expect "CMD>"

  return $hex_result
}

#
# Set pin outputs on Brutus as a hex number
#

proc outputs {value} {
  send "pld output $value"
  nxt
}

#
# Main test program
#

# Don't spew all serial communication onto the user's console
log_user 0

# Connect to Brutus28. Adjust to your device of choice:
#spawn term /dev/ttyACM0
spawn term /dev/tty.usbmodem101

# Turn on the GAL
setup
pld_on

# Sanity check the power on default
#
if { [inputs] == [pins_to_hex VCC A15 A14] } {
  puts "OK: Power on default is VCC, A15, A14."
} else {
  set debug 1
  inputs
  puts "Error: Power on default is not VCC, A15, A14."
  exit 1
}

# Simulate a read from 0x1000. A14/A15 should be 0
puts "Setting !A0 !A1 A12"
outputs [pins_to_hex A12]
if { [inputs] == [pins_to_hex VCC CLKOUT CLK A12] } {
  puts "OK: CLKOUT+CLK detected, A0/A1/A14 is LOW."
} else {
  set debug 1
  inputs
  puts "Error: expected VCC CLKOUT CLK A12\n"
  exit 1
}

# Now turn A12 off. A14 and A15 shouldn't change
puts "Setting !A0 !A1 !A12"
outputs 0
if { [inputs] == [pins_to_hex VCC] } {
  puts "OK: Everything but VCC low."
} else {
  set debug 1
  inputs
  puts "Error: expected VCC\n"
  exit 1
}

# Simulate a read from 0x1001. A14 should go to 1
puts "Setting A0 !A1 A12"
outputs [pins_to_hex A0 A12]
if { [inputs] == [pins_to_hex VCC A0 CLKOUT CLK A12 A14] } {
  puts "OK: CLKOUT+CLK is HIGH, A14 is HIGH"
} else {
  set debug 1
  inputs
  puts "Error: expected VCC A0 CLKOUT CLK A12 A14\n"
  exit 1
}

# Now turn A12 off. A14 and A15 shouldn't change
puts "Setting !A0 !A1 !A12"
outputs 0
if { [inputs] == [pins_to_hex VCC A14] } {
  puts "OK: CLKOUT+CLK low again, A14 remains."
} else {
  set debug 1
  inputs
  puts "Error: expected VCC A14\n"
  exit 1
}

# Read from 0x1000 again. A14 should turn off.
puts "Resetting to VCC only"
outputs [pins_to_hex A12]
outputs 0
if { [inputs] == [pins_to_hex VCC] } {
  puts "OK: VCC only"
} else {
  set debug 1
  inputs
  puts "Error: expected VCC\n"
  exit 1
}

# Testing A15 as well
puts "Enabling A15 flipflop (Setting A1)"
outputs [pins_to_hex A1 A12]
outputs 0
if { [inputs] == [pins_to_hex VCC A15] } {
  puts "OK: VCC A15"
} else {
  set debug 1
  inputs
  puts "Error: expected VCC A15\n"
  exit 1
}

# Read from 0x1000 again. A15 should turn off.
puts "Resetting to VCC only"
outputs [pins_to_hex A12]
outputs 0
if { [inputs] == [pins_to_hex VCC] } {
  puts "OK: VCC only"
} else {
  set debug 1
  inputs
  puts "Error: expected VCC\n"
  exit 1
}

# And finally, test both A14 and A15:
puts "Enabling A14 and A15 flipflop (Setting A0 and A1)"
outputs [pins_to_hex A0 A1 A12]
outputs 0
if { [inputs] == [pins_to_hex VCC A14 A15] } {
  puts "OK: VCC A14 A15"
} else {
  set debug 1
  inputs
  puts "Error: expected VCC A14 A15\n"
  exit 1
}

# Show final state, print Brutus28 output
set debug 1
inputs

# Turn off the GAL and clean up
pld_off
cleanup

