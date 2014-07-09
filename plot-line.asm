!cpu 6502
!to "build/plot-line.prg",cbm

base = $2000
SCROLY = $D011
VMCSB = $D018
colmap = $0400
C2DDRA = $DD02
CI2PRA = $DD00

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

* = $0801                               ; BASIC starts at #2049 = $0801

!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC to load $c000 inserts 
!byte $31,$35,$32,$00,$00,$00           ; BASIC line: 2012 SYS 49152

* = $c000     				            ; start address for 6502 code

jmp start


; address = base + int(y/8) * 320 + (y and 7) + int(x/8) * 8
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
		sta VMCSB

		lda SCROLY
		ora #32
		sta SCROLY

; select graphics bank 1
		lda C2DDRA
		ora #$03
		sta C2DDRA

		lda CI2PRA
		ora #$03
		sta CI2PRA


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


; draw horizontal line
		lda #100
		sta ycoord
		lda #0
		sta xcoord
		sta xcoord+1
agin	jsr plotbit
		inc xcoord
		bne next
		inc xcoord+1
next	lda xcoord+1
		cmp #>320
		bcc agin
		lda xcoord
		cmp #<320
		bcc agin

; draw vertical line
		lda #0
		sta ycoord
point	lda #<160
		sta xcoord
		lda #>160
		sta xcoord+1
		jsr plotbit
		inc xcoord
		bne skip
		inc xcoord+1
skip	jsr plotbit
		ldx	ycoord
		inx
		stx ycoord
		cpx #200
		bcc point


inf		jmp	inf