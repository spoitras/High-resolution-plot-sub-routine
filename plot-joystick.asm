!cpu 6502
!to "build/plot-joy.prg",cbm

base = $2000
SCROLY = $D011
VMCSB = $D018
colmap = $0400
C2DDRA = $DD02
CI2PRA = $DD00
TIME = $a2
CIAPRA = $DC00

delay = 1 	; wait delay/60 seconds

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

vector	!byte	$00,$00,$00,$00,$00,$00,$00,$00
		!byte	$00,$00,$01,$01,$01,$ff,$01,$00
		!byte	$00,$00,$ff,$01,$ff,$ff,$ff,$00
		!byte	$00,$00,$00,$01,$00,$ff,$00,$00

wait  lda #0
      sta TIME
.loop lda TIME
      cmp #delay 	
      bne .loop
      rts

readJS	lda	CIAPRA
		and	#$0f
		asl
		tax
		lda	vector,x
		cmp #$ff
		beq xSus
		clc
		adc xcoord
		sta xcoord
		lda #0
		adc xcoord+1
		sta xcoord+1
		lda xcoord+1
		cmp #>320
		bcc	sety
		lda xcoord
		cmp #<320
		bcc sety
		lda #0
		sta xcoord
		sta xcoord+1
		jmp sety
xSus	sec
		lda	xcoord
		sbc #1
		sta xcoord
		lda xcoord+1
		sbc #0
		sta xcoord+1
		cmp #0
		bne sety
		lda xcoord
		cmp #0
		bne sety
		lda #<319
		sta xcoord
		lda #>319
		sta xcoord+1
sety	lda vector+1,x
		cmp #$ff
		beq ySus
		clc
		adc ycoord
		cmp #200
		bcc done
		lda #0
		jmp done
ySus    clc
		adc ycoord
		cmp #200
		bcc done
		lda #199	
done	sta ycoord
		rts

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
		ldx	tabsiz+1
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
start 	lda #$0
		lda #$20
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
; set horizontal and vertical position
		lda #<160
		sta xcoord
		lda #>160
		sta xcoord+1
		lda #100
		sta ycoord
		jsr plotbit

inf		jsr readJS	
		jsr plotbit
		jsr wait
		jmp	inf