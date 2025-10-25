 //  Variable Labels
.label scrollindex1 = $FB
.label scrollindex2 = $FC
.label scrollindex3 = $FD
.label scrollindex4 = $FE
.label c = $B0
.label direction = $B1	
.label timer1 = $52	
.label timer2 = $04	
.label timer3 = $05	
.label timer4 = $2A
* = $0801
BasicUpstart($0810)
* = $0810

	// direction flag for region 1
	lda #$00
	sta direction
	
	// set the scroll index
	// to 0 for each of the
	// different regions
	lda #$00
	sta scrollindex1	
	sta scrollindex2	
	sta scrollindex3	
	sta scrollindex4

	// setup a "timer" for
	// each of the different
	// regions
	lda #$1F
	sta !t1+ +1
	sta timer1
	
	lda #$17
	sta !t2+ +1
	sta timer2

	lda #$0D
	sta !t3+ +1
	sta timer3

	lda #$07
	sta !t4+ +1
	sta timer4

	// save important registers
	// like screen colour, etc.
	jsr saveregs

	// 38 column mode
	lda $D016
	and #$F7
	sta $D016

	// fill the screen with waves
	jsr fillscreen

	// display instructions at column 2, row 25
	clc 
	ldx #$18
	ldy #$02
	jsr $FFF0
	lda #<INSTR
	sta $02
	lda #>INSTR
	sta $03
	jsr PRN

	// setup the split screen
	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D
	lda #$01
	sta $D01A
	lda #$30 // scan line #48
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region0
	sta $0315
	lda #<region0
	sta $0314
	cli

	lda #$00
	sta c

	// a loop that waits for eiter Q or O to be pressed
while0:	lda c
	cmp #$3E // Q
	bne !skip+
	jmp !+
!skip:	
	// read KB buffer
	lda $CB
	sta c

	cmp #$26 // O
	bne while0
	
// START OF SHIFTING
	lda timer4
	bne !skip+
	// reset timer 4
!t4:
	lda #$0B
	sta timer4

	// update the scroll index
	// it won't be updated on screen
	// until the irq "region4"
	// takes the value of scrollindex4
	// and puts it into $D016
	lda scrollindex4
	sec
	sbc #$01
	and #$07
	sta scrollindex4

	// if the scroll is at position 7
	// copy all the bytes over on the screen
	// using Hard Scroll routine: hsRegion4
	cmp #$07
	bne !skip+
	jsr hsRegion4R2L

!skip:
	lda timer3
	bne !skip+
!t3:
	lda #$05
	sta timer3

	lda scrollindex3
	sec
	sbc #$01
	and #$07
	sta scrollindex3
	
	cmp #$07
	bne !skip+
	jsr hsRegion3R2L

!skip:
	lda timer2
	bne !skip+
!t2:
	lda #$07
	sta timer2
	
	lda scrollindex2
	sec
	sbc #$01
	and #$07
	sta scrollindex2
	
	cmp #$07
	bne !skip+
	jsr hsRegion2R2L

!skip:	
	lda timer1
	bne !skip+
!t1:
	lda #$03
	sta timer1

	//lda scrollindex1

	lda direction
	beq !rt+
	
	lda scrollindex1
	clc
	adc #$01	
	and #$07
	sta scrollindex1
	bne !skip+
	jsr hsRegion1L2R
	jmp !skip+

!rt:
	lda scrollindex1
	clc
	adc #$FF	
	and #$07
	sta scrollindex1	
	cmp #$07
	bne !skip+
	jsr hsRegion1R2L
	
!skip:
	dec timer1
	dec timer2
	dec timer3
	dec timer4
	
	jmp while0
!:

	// restore original IRQ routine
	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D
	lda #$01
	sta $D01A
	lda #$30 // scan line #49
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>irqrestore
	sta $0315
	lda #<irqrestore
	sta $0314
	cli

	
	// clear kb buffer
	lda #$00
	sta $C6
	jsr $FFE4

	// restore important registers
	jsr restoreregs
	rts

region0:asl $D019
	lda $D016
	ora #$07
	sta $D016
	
	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$4A // scan line # (74)
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region1
	sta $0315
	lda #<region1
	sta $0314
	cli
	jmp $EA31

region1:asl $D019
	
	lda $D016
	and #$F8
	ora scrollindex1
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$6A // scan line #106
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region2
	sta $0315
	lda #<region2
	sta $0314
	cli
	jmp $EA31

region2:asl $D019
	
	lda $D016
	and #$F8
	ora scrollindex2
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$92 // scan line #146
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

region3:asl $D019
	lda $D016
	and #$F8
	ora scrollindex3
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$C2 // scan line #194
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region4
	sta $0315
	lda #<region4
	sta $0314
	cli
	jmp $EA31

region4:asl $D019
	lda $D016
	and #$F8
	ora scrollindex4
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$30 // scan line #49
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>region0
	sta $0315
	lda #<region0
	sta $0314
	cli
	jmp $EA31

hsRegion1R2L:
	lda $04F0
	pha
	lda $04C8
	pha
	lda $04A0
	pha
	lda $0478
	pha
	ldx #$00

!:	lda $0479,X
	sta $0478,X	
	lda $04A1,X
	sta $04A0,X	
	lda $04C9,X
	sta $04C8,X
	lda $04F1,X
	sta $04F0,X
	
	inx
	cpx #$27
	bne !-

	pla
	sta $049F
	pla
	sta $04C7
	pla
	sta $04EF
	pla
	sta $0517
	rts

hsRegion1L2R: // line 03 - 06
	
	lda $0517 // 1303
	pha
	lda $04EF // 1263
	pha
	lda $04C7 // 1223
	pha
	lda $049F // 1183
	pha
	ldx #$26

!:	lda $0478,X // 1302
	sta $0479,X // 1303	

	lda $04A0,X // 1262
	sta $04A1,X // 1263

	lda $04C8,X // 1222
	sta $04C9,X // 1223
	
	lda $04F0,X // 1182
	sta $04F1,X // 1183	
	dex
	bpl !-

	pla
	sta $0478 // 1144
	pla
	sta $04A0 // 1184
	pla
	sta $04C8 // 1224
	pla
	sta $04F0 // 1264
	rts
	
hsRegion2R2L:
	lda $05B8
	pha
	lda $0590
	pha
	lda $0568
	pha
	lda $0540
	pha
	lda $0518
	pha
	
	ldx #$00
!:
	lda $0519,X
	sta $0518,X	
	lda $0541,X
	sta $0540,X	
	lda $0569,X
	sta $0568,X
	lda $0591,X
	sta $0590,X
	lda $05B9,X
	sta $05B8,X
	inx
	cpx #$27
	bne !-

	pla
	sta $053F
	pla
	sta $0567
	pla
	sta $058F
	pla
	sta $05B7
	pla
	sta $05DF
	rts
	
hsRegion3R2L:
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
	lda $05E0
	pha
	ldx #$00

!:	lda $05E1,X
	sta $05E0,X	
	lda $0609,X
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
	sta $0607
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
	
hsRegion4R2L:
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


	// the function that fills the screen with waves
fillscreen:
	lda #$00
	sta c

!: // Top of FOR Loop
	lda c
	cmp #$68
	bcs !+
	ldx $02
	lda $03
	pha 
	lda #<SQUIG
	sta $02
	lda #>SQUIG
	sta $03
	jsr PRN
	pla 
	sta $03
	stx $02
	inc c
	jmp !-
!:
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

	// TEXT definitions	
INSTR:	.text "PRESS THE LETTER O TO MOVE Q TO QUIT"
	.byte $00
SQUIG:	.byte $D2, $66, $63, $64, $65, $B7, $65, $64, $63, $66, $00
