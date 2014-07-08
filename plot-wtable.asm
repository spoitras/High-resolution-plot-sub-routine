!cpu 6502
!to "build/plot-asm.prg",cbm

* = $8000     				            ; start address for 6502 code
; SYS 32768

base = $2000
scroly = $d011
vmcsb = $d018
colmap = $0400

scrlen = 8000
maplen = 1000

tempa = $fb
address = tempa+2

tabptr = tempa
tabsiz = $9000
hpsn = tabsiz+2
vpsn = hpsn+2
filval = vpsn + 1

!source "tables.asm"

jmp start

; plot routine
plot	lda ytablelow,y
		clc
		adc xtablelow,x
		sta address

		lda ytablehigh,y
		adc xtablehigh,x
		sta address+1

		lda address
		clc
		adc #<base
		sta address

		lda address+1
		adc #>base
		sta address+1

		ldy #$00
		lda (address),y
		ora mask,x
		sta (address),y
		rts

; fill routine
blkfil	lda	filval
		ldx	tabsiz + 1
		beq	partpg
		ldy	#0
fullpg	sta (tabptr),y
		iny
		bne fullpg
		inc tabptr+1
		dex
		bne fullpg
partpg	ldx	tabsiz
		beq	fini
		ldy	#0
partlp	sta (tabptr),y
		iny
		dex
		bne partlp
fini	rts

; main routine
; define bit map and enable high-res
start 	lda #$18
		sta vmcsb

		lda scroly
		ora #32
		sta scroly

; select graphics bank 1
		lda $dd02
		ora #$03
		sta $dd02

		lda $dd00
		ora #$03
		sta $dd00


; clear bit map
		lda	#0
		sta filval
		lda #<base
		sta tabptr
		lda	#>base
		sta tabptr+1
		lda #<scrlen
		sta tabsiz
		lda #>scrlen
		sta tabsiz+1
		jsr blkfil


; set bg and line colors
		lda #$10 		
		sta filval
		lda #<colmap
		sta tabptr
		lda #>colmap
		sta tabptr+1
		lda #<maplen
		sta tabsiz
		lda #>maplen
		sta tabsiz+1
		jsr blkfil


; set horizontal and vertical position
		ldx 0
		ldy 0
		jsr plot

inf		jmp	inf