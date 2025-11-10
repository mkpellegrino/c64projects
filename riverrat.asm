	//  Variable Labels
.label scrollindex3 = $C000
.label scrollindex4 = $C001
.label c = $C002
.label direction = $C003
.label timer3 = $C004
.label timer4 = $C005

//.label scrollindex3 = $FD
//.label scrollindex4 = $FE
//.label c = $B0
//.label direction = $B1
//.label timer3 = $05
//.label timer4 = $2A
* = $0801
BasicUpstart($0810)
* = $0810
	// save important registers
	// like screen colour, etc.
	jsr saveregs

	// set to 25 line text mode and turn on the screen
	lda #$1B
	sta $d011

	// set screen memory ($0400) and charset bitmap offset ($2000)
	lda #$18
	sta $d018

	// set multicolor mode with 40 col and no X offset
	lda #$D8
	sta $d016

	jsr clearscreen
	
	// initialise direction flag
	lda #$00
	sta direction

	// set the scroll index
	// to 0 for each of the
	// different regions
	//lda #$00 // A is already 0
	sta scrollindex3
	sta scrollindex4

	// setup timers
	// TOP REGION (3)
	lda #$0A
	sta !t3+ +1
	sta !t3++ +1
	sta timer3

	// BOTTOM REGION (4)
	lda #$01
	sta !t4+ +1
	sta !t4++ +1
	sta timer4

	// 38 column mode
	lda $D016
	and #$F7
	sta $D016

	// fill the screen with stuff
	jsr fillscreen

	// setup the interrupts
	sei
	lda #$7F
	sta $DC0D
	and $D011
	sta $D011
	sta $DC0D
	sta $DD0D
	lda #$00 // scanline
	sta $D012
	lda #>region0
	sta $0315
	lda #<region0
	sta $0314
	lda #$01
	sta $D01A
	cli

	lda #$00
	sta c

while0:
	lda $CB
	sta c

	cmp #$3E // Q (Program exit)
	beq !else+

	cmp #$21 // I (shift right)
	bne !+

	lda #$01
	sta direction
	jmp while0

!:	cmp #$26 // O
	beq !+

	lda #$00
	sta direction


	beq while0   // speed optimisation
	//jmp while0

!:	lda #$FF
	sta direction
	bmi while0   // speed optimisation
	//jmp while0

!else:

	// restore original IRQ routine
	sei
	lda #$7F
	sta $DC0D
	and $D011
	sta $D011
	sta $DC0D
	sta $DD0D
	lda #$01 // scan line #01
	sta $D012
	lda #>irqrestore
	sta $0315
	lda #<irqrestore
	sta $0314
	lda #$01
	sta $D01A
	cli

	// clear kb buffer
	lda #$00
	sta $C6
	jsr $FFE4

	// restore important registers
	jsr restoreregs
	jsr clearscreen
	rts



region0: asl $D019 // ack int
#if DEBUG
	lda #$0E
	sta $D020
#endif

	lda $D016 // set scroll register
	ora #$07
	sta $D016

	lda #$09 // set multicolor 01
	sta $d022
	lda #$05 // set multicolor 10
	sta $d023

shift_region4:
	
	lda direction
	beq setup_region3 // if there's no need to scroll then exit the routine

	php
	dec timer4
	dec timer3
	plp
	
	bpl checkR2L

	

checkL2R:
	lda timer3
	bne !nextregion+
!t3:	lda #$00 // reset the timer
	sta timer3
	
	lda scrollindex3
	cmp #$07
	bne !nomove+
	jsr moveRegion3L2R
!nomove:
	inc scrollindex3


	
!nextregion:
	lda timer4
	bne setup_region3

!t4:	lda #$00 // reset the timer
	sta timer4
	
	lda scrollindex4
	cmp #$07
	bne !nomove+
	jsr moveRegion4L2R
!nomove:
	inc scrollindex4
	jmp setup_region3


	

checkR2L:
	lda timer3
	bne !nextregion+
	
!t3:	lda #$00
	sta timer3
	
	lda scrollindex3
	bne !nomove+
	jsr moveRegion3R2L
!nomove:
	dec scrollindex3

!nextregion:
	lda timer4
	bne setup_region3
	
!t4:	lda #$00 // reset the timer
	sta timer4
	
	lda scrollindex4
	bne !nomove+
	jsr moveRegion4R2L
!nomove:
	dec scrollindex4

setup_region3:
	lda #$07
	and scrollindex3
	sta scrollindex3
	lda #$07
	and scrollindex4
	sta scrollindex4

	sei
	lda #$7F
	sta $DC0D
	sta $DD0D

	lda #$01
	sta $D01A

	lda #$91 // scan line
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region3
	sta $0315
	lda #<region3
	sta $0314
	cli
	jmp $EA31

moveRegion4R2L:
	lda $07C0
	pha
	lda $0798
	pha
	lda $0770
	pha
	lda $0748
	pha
	lda $0720
	pha
	lda $06F8
	pha
	lda $06D0
	pha
	ldx #$00
!:	lda $06D1,X
	sta $06D0,X
	lda $06F9,X
	sta $06F8,X
	lda $0721,X
	sta $0720,X
	lda $0749,X
	sta $0748,X
	lda $0771,X
	sta $0770,X
	lda $0799,X
	sta $0798,X
	lda $07C1,X
	sta $07C0,X
	inx
	cpx #$27
	bne !-
	pla
	sta $06F7
	pla
	sta $071F
	pla
	sta $0747
	pla
	sta $076F
	pla
	sta $0797
	pla
	sta $07BF
	pla
	sta $07E7
	rts

moveRegion4L2R:
	lda $07E7
	pha
	lda $07BF
	pha
	lda $0797
	pha
	lda $076F
	pha
	lda $0747
	pha
	lda $071F
	pha
	lda $06F7
	pha
	ldx #$26
!:	lda $06D0,X
	sta $06D1,X
	lda $06F8,X
	sta $06F9,X
	lda $0720,X
	sta $0721,X
	lda $0748,X
	sta $0749,X
	lda $0770,X
	sta $0771,X
	lda $0798,X
	sta $0799,X
	lda $07C0,X
	sta $07C1,X
	dex
	bpl !-
	pla
	sta $06D0
	pla
	sta $06F8
	pla
	sta $0720
	pla
	sta $0748
	pla
	sta $0770
	pla
	sta $0798
	pla
	sta $07C0
	rts

moveRegion3L2R:
	lda $06CF
	pha
	lda $06A7
	pha
	lda $067F
	pha
	lda $0657
	pha
	lda $062F
	pha
	ldx #$26	

!:	lda $0608,X
	sta $0609,X
	lda $0630,X
	sta $0631,X
	lda $0658,X
	sta $0659,X
	lda $0680,X
	sta $0681,X
	lda $06A8,X
	sta $06A9,X
	dex
	bpl !-
	pla
	sta $0608
	pla
	sta $0630
	pla
	sta $0658
	pla
	sta $0680
	pla
	sta $06A8
	rts

moveRegion3R2L:
	lda $06A8
	pha
	lda $0680
	pha
	lda $0658
	pha
	lda $0630
	pha
	lda $0608
	pha
	ldx #$00	
!:	lda $0609,X
	sta $0608,X
	lda $0631,X
	sta $0630,X
	lda $0659,X
	sta $0658,X
	lda $0681,X
	sta $0680,X
	lda $06A9,X
	sta $06A8,X
	inx
	cpx #$27
	bne !-
	pla
	sta $062F
	pla
	sta $0657
	pla
	sta $067F
	pla
	sta $06A7
	pla
	sta $06CF
	rts
	
region3:asl $D019
#if DEBUG
	lda #$02
	sta $D020
#endif
	lda $D016
	and #$F8
	ora scrollindex3
	sta $D016

region3end:
	sei
	lda #$7F
	sta $DC0D
	and $D011
	sta $D011
	sta $DC0D
	sta $DD0D
	lda #$C1 // scan line
	sta $D012
	lda #>region4
	sta $0315
	lda #<region4
	sta $0314
	lda #$01
	sta $D01A
	cli

	jmp $EA31

	
region4:asl $D019
#if DEBUG
	lda #$00
	sta $D020
#endif
	lda $D016
	and #$F8
	ora scrollindex4
	sta $D016

region4end:
	sei
	lda #$7F
	sta $DC0D
	and $D011
	sta $D011
	sta $DC0D
	sta $DD0D
	lda #$00 // scan line #00
	sta $D012
	lda #>region0
	sta $0315
	lda #<region0
	sta $0314
	lda #$01
	sta $D01A
	cli

	jmp $EA31

	// the function that fills the screen
fillscreen:
	lda #<TITLE
	sta $04
	lda #>TITLE
	sta $05
	lda #$00
	sta $02
	lda #$04
	sta $03
	jsr PRN40

	lda #<SQUIG
	sta $04
	lda #>SQUIG
	sta $05
	lda #$C0
	sta $02
	lda #$07
	sta $03

	jsr PRN40

	lda #<MOUNT0
	sta $04
	lda #>MOUNT0
	sta $05
	lda #$A8
	sta $02
	lda #$06
	sta $03

	jsr PRN40


	lda #<MOUNT1
	sta $04
	lda #>MOUNT1
	sta $05
	lda #$80
	sta $02
	lda #$06
	sta $03

	jsr PRN40

	lda #<MOUNT2
	sta $04
	lda #>MOUNT2
	sta $05
	lda #$58
	sta $02
	lda #$06
	sta $03

	jsr PRN40


	lda #<TREE0
	sta $04
	lda #>TREE0
	sta $05
	lda #$D0
	sta $02
	lda #$06
	sta $03

	jsr PRN40

	lda #<TREE1
	sta $04
	lda #>TREE1
	sta $05
	lda #$F8
	sta $02
	lda #$06
	sta $03
	jsr PRN40


	lda #<TREE2
	sta $04
	lda #>TREE2
	sta $05
	
	lda #$20
	sta $02
	lda #$07
	sta $03

	jsr PRN40

	

	ldx #$77
	lda #$09
!:	sta $D800,X
	dex
	bpl !-

	ldx #$4F
	lda #$0D
!:	sta $DAD0,X
	dex
	bpl !-

	rts

PRN40: 	ldy #$27
!:	lda ($04),Y
	sta ($02),Y
	dey
	bpl !-
	rts


	// display a string
PRN:	ldy #$00
!:	lda ($02),Y
	beq !+
	jsr $FFD2
	iny
	jmp !-
!:	rts

irqrestore:
	asl $D019
	jmp $EA31


saveregs:
	lda $D011
	sta !reg1+
	lda $D020
	sta !reg2+
	lda $D021
	sta !reg3+
	lda $D016
	sta !reg4+
	lda $D018
	sta !reg5+
	lda $0286
	sta !reg6+
	rts

!reg1:	.byte $00
!reg2:	.byte $00
!reg3:	.byte $00
!reg4:	.byte $00
!reg5:	.byte $00
!reg6:	.byte $00

restoreregs:
	lda !reg1-
	sta $D011
	lda !reg2-
	sta $D020
	lda !reg3-
	sta $D021
	lda !reg4-
	sta $D016
	lda !reg5-
	sta $D018
	lda !reg6-
	sta $0286
	rts


!lv_mem0: .byte $00
keyup:
	lda #$00
	sta $C6
	jsr $FFE4
	lda $CB
	sta !lv_mem0-
!:	lda !lv_mem0-
	cmp #$40
	beq !+
	lda $CB
	sta !lv_mem0-
	jmp !-
!:	rts


clearscreen:
	ldx #$04
	stx $03

	lda #$00
	sta $02
	tay
	//ldy #$00
	//lda #$00
!:
	sta ($02),Y
	iny
	bne !-
	inc $03
	dex
	bne !-

	rts

	// TEXT definitions
INSTR:	.text "PRESS THE LETTERS O AND I TO MOVE Q TO QUIT"
	.byte $00

ALPHA:	.text "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	.byte $00
	//    0123456789012345678901234567890123456789
TITLE:	.text "RIVER RAT        BY MICHAEL PELLEGRINO"
	.byte $00

SQUIG:	.byte $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01

MOUNT2:	.byte $FF, $FF, $FF, $FF, $05, $08, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $05, $08, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $05, $08, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $05, $08, $FF, $FF, $FF, $FF, $FF
MOUNT1:	.byte $FF, $FF, $05, $06, $04, $04, $07, $08, $FF, $FF, $FF, $FF, $05, $06, $04, $04, $07, $08, $FF, $FF, $FF, $FF, $05, $06, $04, $04, $07, $08, $FF, $FF, $FF, $FF, $05, $06, $04, $04, $07, $08, $FF, $FF
MOUNT0:	.byte $05, $06, $04, $04, $04, $04, $04, $04, $07, $08, $05, $06, $04, $04, $04, $04, $04, $04, $07, $08, $05, $06, $04, $04, $04, $04, $04, $04, $07, $08, $05, $06, $04, $04, $04, $04, $04, $04, $07, $08

TREE0:	.byte $09, $0A, $0B, $0C, $0B, $0C, $09, $0D, $0E, $0D, $0E, $0F, $09, $0A, $0B, $0C, $0B, $0C, $09, $0D, $0E, $0D, $0E, $0F, $09, $0A, $0B, $0C, $0B, $0C, $09, $0D, $0E, $0D, $0E, $0F, $09, $0A, $0B, $0C
TREE1:	.byte $19, $1A, $1B, $1C, $1B, $1C, $19, $1D, $1E, $1D, $1E, $1F, $19, $1A, $1B, $1C, $1B, $1C, $19, $1D, $1E, $1D, $1E, $1F, $19, $1A, $1B, $1C, $1B, $1C, $19, $1D, $1E, $1D, $1E, $1F, $19, $1A, $1B, $1C
TREE2:	.byte $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01, $02, $03, $02, $02, $03, $01, $01, $01

	// Character bitmap definitions 2k
	*=$2000
	.byte $00, $00, $00, $00, $00, $00, $00, $00 // $00
	.byte $54, $55, $55, $59, $57, $D5, $55, $5D //
	.byte $15, $55, $55, $57, $55, $95, $55, $5D //
	.byte $45, $55, $55, $55, $75, $D5, $55, $5B //
	.byte $55, $55, $55, $55, $55, $55, $55, $55 //
	.byte $00, $00, $00, $00, $01, $05, $15, $55 //
	.byte $01, $05, $15, $55, $55, $55, $55, $55 //
	.byte $40, $50, $54, $55, $55, $55, $55, $55 //
	.byte $00, $00, $00, $00, $40, $50, $54, $55 //
	.byte $5A, $5B, $7A, $6B, $AA, $AE, $EB, $BA //
	.byte $95, $95, $E5, $B5, $B9, $A9, $BD, $E9 //
	.byte $57, $56, $57, $56, $5E, $5A, $5B, $5A //
	.byte $55, $55, $55, $55, $95, $95, $95, $95 //
	.byte $D5, $D6, $DA, $FA, $FA, $FA, $FA, $FA //
	.byte $55, $55, $95, $97, $97, $97, $97, $97 //
	.byte $55, $D5, $E5, $F9, $E9, $F9, $ED, $E9 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 // $10
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $AE, $BA, $AB, $6A, $59, $FD, $FD, $F5 // $19
	.byte $A9, $B9, $E9, $A5, $A5, $FF, $FF, $7F //
	.byte $7B, $6A, $6A, $AE, $EA, $AA, $FD, $F5 //
	.byte $A5, $E5, $B5, $A9, $ED, $AB, $FF, $7F //
	.byte $FA, $FA, $FA, $FE, $FD, $FD, $FD, $75 //
	.byte $B7, $BF, $BF, $BB, $FF, $EF, $FF, $F7 //
	.byte $E9, $F9, $E9, $ED, $F9, $EB, $7F, $77 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 // $20 (SPACE)
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $FC, $CC, $CC, $CC, $CC, $CC, $FC // $30 (DIGITS 0-9)
	.byte $00, $30, $F0, $30, $30, $30, $30, $FC //
	.byte $00, $FC, $0C, $0C, $FC, $C0, $C0, $FC //
	.byte $00, $FC, $0C, $0C, $3C, $0C, $0C, $FC //
	.byte $00, $0C, $CC, $CC, $FC, $0C, $0C, $0C //
	.byte $00, $FC, $C0, $FC, $0C, $CC, $CC, $FC //
	.byte $00, $FC, $CC, $C0, $FC, $CC, $CC, $FC //
	.byte $00, $FC, $0C, $0C, $0C, $0C, $0C, $0C //
	.byte $00, $FC, $CC, $CC, $FC, $CC, $CC, $FC //
	.byte $00, $FC, $CC, $CC, $FC, $0C, $0C, $0C //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 // $40
	.byte $00, $30, $CC, $CC, $FC, $CC, $CC, $CC // $41 (A-Z)
	.byte $00, $F0, $CC, $CC, $F0, $CC, $CC, $F0 //
	.byte $00, $30, $CC, $CC, $C0, $CC, $CC, $30 //
	.byte $00, $F0, $CC, $CC, $CC, $CC, $CC, $F0 //
	.byte $00, $FC, $C0, $C0, $F0, $C0, $C0, $FC //
	.byte $00, $FC, $C0, $C0, $F0, $C0, $C0, $C0 //
	.byte $00, $FC, $CC, $CC, $CC, $FC, $0C, $FC //
	.byte $00, $CC, $CC, $CC, $FC, $CC, $CC, $CC //
	.byte $00, $FC, $30, $30, $30, $30, $30, $FC //
	.byte $00, $0C, $0C, $0C, $0C, $CC, $CC, $30 //
	.byte $00, $C0, $CC, $CC, $F0, $CC, $CC, $CC //
	.byte $00, $C0, $C0, $C0, $C0, $C0, $C0, $FC //
	.byte $00, $CC, $FC, $FC, $CC, $CC, $CC, $CC //
	.byte $00, $00, $C0, $F0, $CC, $CC, $CC, $CC //
	.byte $00, $30, $CC, $CC, $CC, $CC, $CC, $30 //
	.byte $00, $F0, $CC, $CC, $F0, $C0, $C0, $C0 // $50
	.byte $00, $30, $CC, $CC, $CC, $CC, $F0, $3C //
	.byte $00, $F0, $CC, $CC, $F0, $CC, $CC, $CC //
	.byte $00, $30, $CC, $C0, $30, $0C, $CC, $30 //
	.byte $00, $FC, $30, $30, $30, $30, $30, $30 //
	.byte $00, $CC, $CC, $CC, $CC, $CC, $CC, $FC //
	.byte $00, $CC, $CC, $CC, $CC, $CC, $30, $30 //
	.byte $00, $CC, $CC, $CC, $CC, $FC, $FC, $CC //
	.byte $00, $CC, $CC, $CC, $30, $CC, $CC, $CC //
	.byte $00, $CC, $CC, $CC, $30, $30, $30, $30 //
	.byte $00, $FC, $0C, $0C, $30, $C0, $C0, $FC // (end of alphabet)
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00 // $60
	.byte $00, $00, $00, $00, $00, $00, $00, $00 //
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00


