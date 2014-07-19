High resolution plot sub-routine
================================

Sub-routine in CBMBasic and ACME 6502 assembly to turn on any pixel in C64 high resolution mode.

|        File       |                    Description                   |
|:-----------------:|:------------------------------------------------:|
| plot.asm          | ACME assembly code for plot routine              |
| plot-line.asm     | Plotting lines with ACME assembler routine       |
| plot-joystick.asm | Joystick movements plot points across the screen |
| plot.bas          | CBM Basic code for plot routine (slow)           |

In high resolution bit map mode, the Commodore 64 programmer has access to all 200x320 pixels on the screen. 
However, these pixels are still arranged in 8x8 character blocks and plotting a specific point requires a complex
calculation that makes high resolution graphics impractical for BASIC programmers.

Reference
---------
The code for the clear and fill routine is adapted to ACME crossassembler from *Commodre 64/128 Assembly Language Programming* (Mark Andrews).

The code for the plot routine is adapted from Advanced Macine Code Programming for the Commodore 64 (Stephenson & Stephenson).

