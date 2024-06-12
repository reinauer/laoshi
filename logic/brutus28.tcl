#!/usr/bin/expect
#
# This is a small test framework to test GALs with Brutus28:
#          https://github.com/cdhooper/brutus28
#
# It uses TCL's expect, and Chris Hooper's "Brutus28" hardware and
# "term" terminal program.
#

set debug 0
set timeout -1

# Don't spew all serial communication onto the user's console
log_user 0

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

# Function to list devices matching a pattern
proc list_devices {pattern} {
  set devices [glob -nocomplain $pattern]
  return $devices
}

proc detect_serial_port {} {
  # Define the potential device paths
  set patterns [list "/dev/ttyACM*" "/dev/tty.usbmodem*"]
  set existing_devices {}

  # Check which devices exist
  foreach pattern $patterns {
    set devices [list_devices $pattern]
    foreach device $devices {
      lappend existing_devices $device
    }
  }

  # Determine the device to use
  set device_to_use ""
  switch [llength $existing_devices] {
    0 {
      send_user "Error: No valid serial devices found.\n"
      exit 1
    }
    1 {
      set device_to_use [lindex $existing_devices 0]
    }
    default {
      send_user "Multiple serial devices found:\n"
      for {set i 0} {$i < [llength $existing_devices]} {incr i} {
        send_user "[expr {$i + 1}]. [lindex $existing_devices $i]\n"
      }
      send_user "Please select a device by number: "
      expect_user -re {(\d+)} {
        set selection $expect_out(1,string)
        if {$selection >= 1 && $selection <= [llength $existing_devices]} {
          set device_to_use [lindex $existing_devices [expr {$selection - 1}]]
        } else {
          send_user "Invalid selection.\n"
          exit 1
        }
      }
    }
  }

  send_user "Using device: $device_to_use\n"
  return $device_to_use
}
