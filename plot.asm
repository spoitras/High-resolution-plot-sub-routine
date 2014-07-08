!cpu 6502
!to "build/plot-asm.prg",cbm

base = $2000
scroly = $d011
vmcsb = $d018
colmap = $0400

scrlen = 8000
maplen = 1000

xcoord = $fb
ycoord = $fd

tabptr = xcoord
tabsiz = $9000
filval = tabsiz+2

bmpage = $ff
mask = $59
loc = $5a
store = $5c

* = $8000     				            ; start ycoord for 6502 code
; sys 32768
jmp start

plotbit	lda	xcoord
		and	#7
		tax
		sec
		lda	#0
		sta loc
shift	ror
		dex
		bpl shift
		sta mask
		lda xcoord
		and #$f8
		sta store
		lda ycoord
		lsr
		lsr
		lsr
		sta loc+1
		lsr
		ror	loc
		lsr
		ror	loc
		adc loc+1
		sta loc+1
		lda ycoord
		and #7
		adc loc
		adc store
		sta loc
		lda loc+1
		adc xcoord+1
		adc bmpage
		sta loc+1
		ldy	#0
		lda (loc),y
		ora mask,y
		sta (loc),y
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
start 	lda #$20
		sta bmpage
		lda #$18
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
		lda #<160
		sta xcoord
		lda #>160
		sta xcoord+1
		lda #100
		sta ycoord
		jsr plotbit

inf		jmp	inf