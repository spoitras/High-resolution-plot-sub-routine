0 rem !to "build/plot-bas.prg"
10 rem **** plot.bas ****
20 base = 8192 : poke 53272,peek(53272) or 8:rem put hires map at 8192
30 poke 53265,peek(53265) or 32 : rem enter bitmap mode
40 for i = base to base + 7999 : poke i,0 : next : rem clear screen
50 for i = 1024 to 2023 : poke i,16 : next : rem set colors
60 goto 200
80 rem **** plot routine ****
90 char = int(hpsn/8)
100 row = int(vpsn/8)
110 line = vpsn and 7
120 byte = base + row * 320 + 8 * char + line
130 bit = 7 - (hpsn and 7)
140 poke byte,peek(byte) or (2^bit)
150 return
200 hpsn=160:vpsn=100:gosub 80:rem one dot in the middle
210 goto 210 : rem forever
