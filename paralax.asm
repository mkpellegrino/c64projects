 //  Variable Labels
.label scrollindex = $FB
.label direction = $2001
.label moving = $2002
.label c = $2003
.label delayLength = $2004
.label del = $2006
.label toggle = $2008	
* = $0801
BasicUpstart($080D)
* = $080D
	lda #$00
	sta scrollindex	
	
	jsr saveregs

	// 38 column mode
	lda $D016
	and #$F7
	sta $D016


	clc 
	ldx #$0E
	ldy #$01
	jsr $FFF0

	lda #<STRLBL2
	sta $02
	lda #>STRLBL2
	sta $03
	jsr PRN

	clc 
	ldx #$15
	ldy #$00
	jsr $FFF0

	lda #<STRLBL0
	sta $02
	lda #>STRLBL0
	sta $03
	jsr PRN
	
	clc 
	ldx #$16
	ldy #$00
	jsr $FFF0
	
	lda #<STRLBL1
	sta $02
	lda #>STRLBL1
	sta $03
	jsr PRN


	clc 
	ldx #$17
	ldy #$00
	jsr $FFF0

	lda #<STRLBL0
	sta $02
	lda #>STRLBL0
	sta $03
	jsr PRN
	
	clc 
	ldx #$18
	ldy #$00
	jsr $FFF0
	
	lda #<STRLBL1
	sta $02
	lda #>STRLBL1
	sta $03
	jsr PRN

	// setup the split screen
	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D
	lda #$01
	sta $D01A
	lda #$08 // scan line #
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>bottomPart
	sta $0315
	lda #<bottomPart
	sta $0314
	cli

	lda #$00
	sta c

while0:	lda c
	cmp #$3E
	beq !++

	lda #$80
	pha
	lda #$00
	pha
	jsr delay
	lda $CB
	sta c

	cmp #$26
	bne while0

	lda $52
	sec
	sbc #$01
	and #$07
	sta $52
	
	cmp #$07
	bne !skip+
	jsr hardScrollR2L
!skip:
	lda toggle
	bne !+
	lda $FB
	sec
	sbc #$01
	and #$07
	sta $FB

	
	cmp #$07
	bne !+
	jsr hardScrollR2lb
	//jmp !+	
	
!:	lda toggle
	eor #$FF
	sta toggle

	jmp while0
!:
	// clear kb buffer
	lda #$00
	sta $C6
	jsr $FFE4

	//jsr restoreregs
	rts

topPart:
	asl $D019

	// set smooth scroll
	// to 7 always
	lda $D016
	ora #$07
	sta $D016
	
	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$D9 // scan line # (225)
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>middlePart
	sta $0315
	lda #<middlePart
	sta $0314
	cli

	asl $D019

	jmp $EA31

middlePart:
	// set the smooth scroll
	// to whatever is in $0052
	asl $D019
	
	lda $D016
	and #$F8
	ora $FB
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$E9 // scan line #
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>bottomPart
	sta $0315
	lda #<bottomPart
	sta $0314
	cli

	//asl $D019

	jmp $EA31


	

bottomPart:
	// set the smooth scroll
	// to whatever is in $0052
	asl $D019
	
	lda $D016
	and #$F8
	ora $52
	sta $D016

	sei 
	lda #$7F
	sta $DC0D
	sta $DD0D	
	lda #$01
	sta $D01A
	lda #$08 // scan line #
	sta $D012
	lda $D011
	and #$7F
	sta $D011
	lda #>topPart
	sta $0315
	lda #<topPart
	sta $0314
	cli

	//asl $D019

	jmp $EA31

hardScrollR2lb:
	sei
	lda $0770
	pha
	lda $0748
	pha
	//lda $0720
	//pha
	ldx #$00

!:	lda $0771,X
	sta $0770,X
	lda $0749,X
	sta $0748,X
	//lda $0721,X
	//sta $0720,X
	inx
	cpx #$27
	bne !-

	//pla
	//sta $0747
	pla
	sta $076F
	pla
	sta $0797
	cli
	rts
	
hardScrollR2L:
	sei
	lda $07C0
	pha
	lda $0798
	pha
	//lda $0770
	//pha
	//lda $0748
	//pha
	//lda $0720
	//pha
	ldx #$00

!:	lda $07C1,X
	sta $07C0,X
	lda $0799,X
	sta $0798,X
	//lda $0771,X
	//sta $0770,X
	//lda $0749,X
	//sta $0748,X
	//lda $0721,X
	//sta $0720,X
	inx
	cpx #$27
	bne !-

	//pla
	//sta $0747
	//pla
	//sta $076F
	//pla
	//sta $0797
	pla
	sta $07BF
	pla
	sta $07E7
	cli
	rts

delay:
	pla
	tax
	pla
	tay
	pla 
	sta delayLength +1
	pla 
	sta delayLength
	tya
	pha
	txa
	pha
	
	lda #$00
	sta del
	sta del +1
LBL1L55: // Top of FOR Loop
	lda del +1
	cmp delayLength +1
	bne !+
	lda del
	cmp delayLength
!:	bcs LBL1L58 // jump out of FOR
	clc 
	lda del
	adc #$01
	sta del
	lda del +1
	adc #$00
	sta del +1
	jmp LBL1L55
LBL1L58:
	rts 

	
PRN:
	ldy #$00
!:	lda ($02),Y
	beq !+
	jsr $FFD2
	iny 
	jmp !-
!:	rts 
STRLBL0:.text "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
	.byte  $00
STRLBL1:.text "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ABC"
	.byte $00
STRLBL2:.text "PRESS THE LETTER O TO MOVE Q TO QUIT"
	.byte $00
	
!arg0:	.byte $00
!arg1:	.byte $00
!arg2:	.byte $00

	// clearmem( PG, # or loops );
clearmem:
	pla 
	tax 
	pla 
	tay

	pla
	sta !arg1-

	// arg0
	pla
	sta $03

	tya 
	pha 
	txa 
	pha 

	ldx !arg1-
	
	lda #$00
	sta $02
	tay
	//ldy #$00
!:
	sta ($02),Y
	iny
	bne !-
	inc $03
	dex
	bne !-

	rts


	// fillmem( PG, char, # or loops );
fillmem:
	pla 
	tax 
	pla 
	tay

	pla
	sta !arg2-

	pla
	sta !arg1-
	
	// arg0
	pla
	sta $03

	tya 
	pha 
	txa 
	pha 

	ldx !arg2-
	
	ldy #$00
	sty $02
	
	lda !arg1-
!:
	sta ($02),Y
	iny
	bne !-
	inc $03
	dex
	bne !-

	rts


clearsid:	
	lda #$D4
	sta $03	
	lda #$18
	sta $02	
	ldx #$18
	lda #$00
	tay
!:
	sta ($02),Y
	dex
	bne !-
	rts

irqrestore:
	asl $D019
	jmp $EA31
	
// store the random values here
!mem0:  .byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00

!mem1:  .byte $00, $00 // ptr to rnd values
!mem2:  .byte $00 // flag to tell if the init process has already been run (rndinit)
!mem3:  .byte $00 // rvindex
!mem4:	.byte $00 // mySeedi
!mem5:	.byte $00 // my random return value
mySeed:	
	lda !mem2- // rndinit
	cmp #$00
	bne !+++++

	// SID RNG
	lda #$FF
	sta $D40E
	sta $D40F
	lda #$80
	sta $D412
	
	lda #$00
	sta !mem3-
	sta !mem4-

	lda #<!mem0-
	sta !mem1-
	lda #>!mem0-
	sta !mem1- +1
	
	//lda #$00
	//sta !mem4-
!:			 // Top of FOR Loop
	lda !mem4-
	cmp #$40
	bcs !+++

	clc 
	lda !mem1-
	adc !mem4-
	sta !+
	lda #$00
	adc !mem1- +1
	sta !++
	lda $D41B
	tay 
	.byte $8C	 // <-- STY absolute
!:
	.byte $00
!:
	.byte $00
	jsr shortDelay
	inc !mem4-
	jmp !---
!:
	lda #$01
	sta !mem2-
!:
	rts



	
myRand:	clc 
	lda !mem1- // ptr (LB) to random values
	
	adc !mem3- // rvindex
	tay
	
	lda #$00
	adc !mem1- +1  // ptr (HB) to rnd values
	tax
		
	lda $02
	pha 
	lda $03
	pha 

	sty $02
	ldy #$00
	stx $03
	lda ($02),Y

	sta !mem5- // the return value
	
	pla 
	sta $03
	pla 
	sta $02

	inc !mem3- // bump the index up by 1

// top of if
	lda !mem3-  // rvindex
	cmp #$40
	bne !+
	lda #$00
	sta !mem3-
!:	pla 
	tax 
	pla 
	tay 
	lda !mem5-
	pha 
	lda #$01
	pha 
	tya 
	pha 
	txa 
	pha 
	rts 


!mem0:	.byte $00, $00
shortDelay:
	lda #$00
	sta !mem0-
	sta !mem0- +1
	
!:	lda !mem0- +1
	cmp #$01
	bne !+
	lda !mem0-
	cmp #$FF
!:	bcs !+

	nop

	clc 
	lda !mem0-
	adc #$01
	sta !mem0-
	lda !mem0- +1
	adc #$00
	sta !mem0- +1
	jmp !--
!:	rts 
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
!mem:	.byte $00
pause:	
	lda #$00
	sta $C6
	jsr $FFE4
	sta !mem-
!:	lda !mem- // this $00 will change
//	cmp #$00
	bne !+
	jsr $FFE4
	sta !mem-
	jmp !-
!:	rts 
