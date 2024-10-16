# Project Laoshi (老師)

This is a simple ROM bank switcher for certain Amiga ROMs that allows switching between two ROM banks through reads from the host side.

There are three versions for your heart's delight: An SMD version, a through hole version, and a flat version to fit in space limited devices like the A590:

## Through Hole
<p float="center">
  <img src="images/laoshi_thruhole_front.png?raw=True" alt="TOP" width="45%" />
  <img src="images/laoshi_thruhole_back.png?raw=True" alt="BOTTOM" width="45%" />
</p>

## SMD
<p float="center">
  <img src="images/laoshi_smd_front.png?raw=True" alt="TOP" width="45%" />
  <img src="images/laoshi_smd_back.png?raw=True" alt="BOTTOM" width="45%" />
</p>

## A590
<p float="center">
  <img src="images/laoshi_a590_front.png?raw=True" alt="TOP" width="45%" />
  <img src="images/laoshi_a590_back.png?raw=True" alt="BOTTOM" width="45%" />
</p>


# Implementation / BOM

Gerbers will be in each subdirectory under hardware. An ATF16V8 is needed
(either through hole or TSSOP) and should be programmed with laoshi.pld which
can be found under logic/

During assembly you need to cut pins 1 and 27 of the ROM socket.

When assembling the A590 version, don't use a socket for the flash chip. It is
also recommended to cut the pins of the pin headers flat to the PCB surface
before soldering, and covering the top with kapton tape to prevent shorts.

# Example pictures

## Through Hole version
<p float=center">
  <img src="images/photo_thruhole_GALpins.jpg?raw=True" alt="TOP" width="45%" />
  <img src="images/photo_thruhole_GALpins_cut.jpg?raw=True" alt="TOP" width="45%" />
  <img src="images/photo_thruhole_bottom.jpg?raw=True" alt="TOP" width="45%" />
</p>

## A590 version
<p float=center">
  <img src="images/photo_a590_bottom.jpg?raw=True" alt="TOP" width="45%" />
  <img src="images/photo_a590_installed.jpg?raw=True" alt="TOP" width="45%" />
  <img src="images/photo_a590_top.jpg?raw=True" alt="TOP" width="45%" />
  <img src="images/photo_a590_top_kapton.jpg?raw=True" alt="TOP" width="45%" />
</p>
