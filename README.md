# Project Laoshi (老師)

This is a simple ROM bank switcher for certain Amiga ROMs that allows switching between two ROM banks through reads from the host side.

There are two versions, an SMD version and a through hole version:

## Through Hole
<p float="center">
  <img src="images/laoshi_thruhole_front.png?raw=True" alt="TOP" width="45%" />
  <img src="images/laoshi_thruhole_back.png?raw=True" alt="BOTTOM" width="45%" />
</p>

## SMD
![TOP](images/laoshi_smd_front.png?raw=True)
![BOTTOM](images/laoshi_smd_back.png?raw=True)

# Implementation / BOM

Gerbers will be in each subdirectory under hardware. An ATF16V8 is needed
(either through hole or TSSOP) and should be programmed with laoshi.pld which
can be found under logic/

During assembly you need to cut pins 1 and 27 of the ROM socket.


