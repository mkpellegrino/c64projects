 //  Variable Labels
.label filename = $6590
.label currentD011 = $6592
.label bmpaddr = $6593
.label bmpaddrX = $6595
.label scraddr = $6597
.label scraddrX = $6599
.label i = $659B
.label pausev = $659D
.label oldD011 = $659E
.label oldD016 = $659F
.label oldD018 = $65A0
.label oldD020 = $65A1
.label oldD021 = $65A2
.label oldChar = $65A3
* = $0801
BasicUpstart($080D)
* = $080D
	lda #<STRLBL0
	sta filename
	lda #>STRLBL0
	sta filename+1
	
	jsr saveregs

	lda #$03
	ora $DD02
	sta $DD02
	
	lda #$01
	sta $02
	lda $DD00
	and #$FC
	ora $02
	sta $DD00

	
	lda $D011
	sta currentD011
	lda #$30
	ora currentD011
	sta $D011
	lda #$18
	sta $D016
	sta $D018
	
	sei 
	lda $01
	and #$F8
	ora #$06
	sta $01
	lda $D018
	and #$08
	asl 
	asl 
	sta $FF
	lda $DD00
	eor #$FF
	and #$03
	asl 
	asl 
	asl 
	asl 
	asl 
	asl 
	adc $FF
	tax 
	lda #$00
	cli
	
	sta bmpaddr
	stx bmpaddr+1

	clc 
	lda bmpaddr
	adc #$F8
	sta bmpaddrX
	lda bmpaddr+1
	adc #$1F
	sta bmpaddrX+1

	lda #$00
	sta $03
	jsr SCRMEM

	pla 
	clc 
	adc $03
	sta $03
	jsr BNKMEM
	pla 
	adc $03
	tax 
	lda #$00
	sta scraddr
	stx scraddr+1
	clc 
	lda scraddr
	adc #$EF
	sta scraddrX
	lda scraddr+1
	adc #$03
	sta scraddrX+1
	lda filename
	ldx filename+1
	sta !++
	stx !+++
	pha 
	txa 
	pha 
	ldx #$00
!:
	.byte $BD
!:
	.byte $00
!:
	.byte $00
	cmp #$00
	beq !+
	inx 
	jmp !---
!:
	stx !--
	
	pla 
	tay 
	pla 
	tax 

	lda !--
	jsr $FFBD
	lda #$03
	ldx #$08
	//
	tay
	//ldy #$03
	jsr $FFBA
	jsr $FFC0
	ldx #$03
	jsr $FFC6
	
	lda $02
	pha 
	lda $03
	pha
	
	php 
	lda #$00
	ldx #$A0
	sta i
	stx i+1
LBL1L1:			 // Top of FOR Loop
	lda i+1
	cmp #$BF
	bne !+
	lda i
	cmp #$40
!:
	bcs LBL1L4 // jump out of FOR ()
// - - - - - - - moved iterator from here to down below
	jsr $FFCF
	sta LBL2L0-2
	lda i
	sta !+
	lda i+1
	sta !++
	lda #$00
	.byte $8D // <-- STA absolute
!:
LBL2L0:			 // <-- low byte
	.byte $00
!:
LBL2L1:			 // <-- hi byte
	.byte $00
// v v v v v v v moved iterator to here from above
	clc 
	lda i
	adc #$01
	sta i
	lda i+1
	adc #$00
	sta i+1
// ^ ^ ^ ^ ^ ^ moved iterator to here from above
	jmp LBL1L1
LBL1L4:
	//clc 
	lda #$00
	ldx #$84
	sta i
	stx i+1
LBL1L6:			 // Top of FOR Loop
	lda i+1
	cmp #$87
	bne !+
	lda i
	cmp #$E8
!:
	bcs LBL1L9 // jump out of FOR ()
// - - - - - - - moved iterator from here to down below
	jsr $FFCF
	sta LBL2L2-2 //--//
	lda i            //
	sta !+           //
	lda i+1          //
	sta !++          //
	lda #$00 // <----/
	.byte $8D // <-- STA absolute
!:
LBL2L2:			 // <-- low byte
	.byte $00
!:
LBL2L3:			 // <-- hi byte
	.byte $00
// v v v v v v v moved iterator to here from above
	clc 
	lda i
	adc #$01
	sta i
	lda i+1
	adc #$00
	sta i+1
// ^ ^ ^ ^ ^ ^ moved iterator to here from above
	jmp LBL1L6
LBL1L9:
	//clc 
LBL1L10:
	lda #$00
	ldx #$D8
	sta i
	stx i+1
LBL1L11:			 // Top of FOR Loop
	lda i+1
	cmp #$DB
	bne !+
	lda i
	cmp #$E8
!:
	bcs LBL1L14 // jump out of FOR ()
LBL1L12:
// - - - - - - - moved iterator from here to down below
LBL1L13:
	jsr $FFCF
	sta LBL2L4-2
	lda i
	sta !+
	lda i+1
	sta !++
	lda #$00
	.byte $8D // <-- STA absolute
!:
LBL2L4:			 // <-- low byte
	.byte $00
!:
LBL2L5:			 // <-- hi byte
	.byte $00
// v v v v v v v moved iterator to here from above
	clc 
	lda i
	adc #$01
	sta i
	lda i+1
	adc #$00
	sta i+1
// ^ ^ ^ ^ ^ ^ moved iterator to here from above
	jmp LBL1L11
LBL1L14:
	plp

	
	pla 
	sta $03
	pla 
	sta $02


	lda #$03
	jsr $FFC3
	jsr $FFCC
	jsr pause

	sei 
	lda #$37 // Default Value
	sta $01
	cli
	
	lda #$03
	ora $DD02
	sta $DD02
	lda $02
	pha 
	lda #$03
	sta $02
	lda $DD00
	and #$FC
	ora $02
	sta $DD00
	pla 
	sta $02
	jsr restoreregs
	rts 
pause:
	lda #$00
	sta $C6
	jsr $FFE4
	sta pausev
LBL1L16:			 // Top of WHILE Loop
	lda pausev
	cmp #$00
	bne LBL1L18 // jump to ELSE ()
	jsr $FFE4
	sta pausev
	jmp LBL1L16 // jump to top of WHILE loop
LBL1L18:
	rts 
saveregs:
	lda $D011
	sta oldD011
	lda $D016
	sta oldD016
	lda $D018
	sta oldD018
	lda $D020
	sta oldD020
	lda $D021
	sta oldD021
	lda $0286
	sta oldChar
	rts 
restoreregs:
	lda oldD011
	sta $D011
	lda oldD016
	sta $D016
	lda oldD018
	sta $D018
	lda oldD020
	sta $D020
	lda oldD021
	sta $D021
	lda oldChar
	sta $0286
	rts 
SCRMEM:		 // Get the screen mem location from the vic II
	pla 
	jsr PUSH
	pla 
	jsr PUSH
	lda $D018
	and #$F0
	//clc 
	lsr 
	lsr 
	pha 
	jsr POP
	pha 
	jsr POP
	pha 
	rts 
BNKMEM:		 // Get the bank memory from the vic II
	pla 
	jsr PUSH
	pla 
	jsr PUSH
	lda $DD00
	eor #$FF
	and #$03
	//clc 
	asl 
	asl 
	asl 
	asl 
	asl 
	asl 
	pha 
	jsr POP
	pha 
	jsr POP
	pha 
	rts 
!:
	.byte $00
PUSH:
	stx !-
	ldx $CF00
	inx 
	sta $CF00,X
	stx $CF00
	ldx !-
	rts 
POP:
	stx !-
	ldx $CF00
	lda $CF00,X
	dex 
	stx $CF00
	ldx !-
	rts 
 // ; $af4			"GARDEN,S,R"
STRLBL0:
	.byte  $47, $41, $52, $44, $45, $4E, $2C, $53, $2C, $52, $00
