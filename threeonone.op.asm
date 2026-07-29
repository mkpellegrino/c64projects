 //  Variable Labels
//.label g1 = $C000
.label ii = $C001
.label a1fire = $C029
.label a2fire = $C02A
.label a3fire = $C02B
.label level = $C02C
.label kills = $C02D
.label firey = $C02E
.label timer = $C02F
.label aspeed1 = $C030
.label aspeed2 = $C031
.label aspeed3 = $C032
.label amspeed = $C033
.label plyvel = $C034
.label missvel = $C035
.label y = $FB
.label x = $FC
.label x2 = $FD
.label x3 = $C039	
.label x4 = $C03A
.label y2 = $FE
.label y3 = $C03C
.label y4 = $C03D
.label adir1 = $C03E
.label adist1 = $C03F
.label adir2 = $C040
.label adist2 = $C041
.label adir3 = $C042
.label adist3 = $C043
.label s = $C044
.label score = $C045
.label i = $C04A
.label c = $C04B
.label f = $C04C
.label saddr = $C04D
* = $0801
BasicUpstart($080D)
* = $080D
	jsr saveregs

	// screen colours
	lda #$00
	sta $D020
	sta $D021

	// init some variables
	sta a1fire
	sta a2fire
	sta a3fire
	sta level
	sta kills
	sta firey
	sta timer

	// clear all high bits for
	// all sprites
	sta $D010

	//lda #$00
	sta $19
	sta $1A
	sta $1B
	sta $1C
	sta $1D
	tay
	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM

	
	// initialize RNG
	jsr SIDRND 
	lda $D41B
	
	jsr intro

	// copy sprites to location
	jsr cpyspr

	// set sprite pointers
	lda #$C0 // ship
	sta $07F8
	lda #$C1 // missle
	sta $07F9 
	lda #$C2 // alien ship
	sta $07FA
	sta $07FB
	sta $07FC
	lda #$C3 // alien missle
	sta $07FD
	sta $07FE
	sta $07FF

	// init some more variables
	
	lda #$02
	sta aspeed1
	sta aspeed2
	sta aspeed3
	
	//lda #$04
	asl
	sta amspeed
	
	lda #$05
	sta plyvel
	sta missvel
	
	lda #$E6
	sta y
	
	lda #$50
	sta x
	sta x2
	sta x3
	sta x4
	
	lda #$3C
	sta y2
	
	lda #$55
	sta y3
	
	lda #$6E
	sta y4
	
	lda #$14
	sta adir1
	sta adist1

	//lda #$28
	asl
	sta adir3
	sta adist3

	
	lda #$1E
	sta adir2
	sta adist2
		
	lda $D41B
	sta s
	
	
	lda #$0F
	sta $D027
	
	lda #$0F
	sta $D028

	lda #$02
	sta i

	// Top of FOR Loop
LBL1L1: lda i
	cmp #$08
	bcs LBL1L4
	tax
	lda #$0A
	sta $D027,X
	inc i
	jmp LBL1L1
	
LBL1L4:
	jsr levelup
	
	// turn off player_missle sprite
	lda #$FD
	sta $D015
	
	lda x
	sta $D000
	lda y
	sta $D001
	
	lda #$50
	sta $D002
	lda #$C8
	sta $D003
	
	lda x2
	sta $D004
	lda y2
	sta $D005

	lda x3
	sta $D006
	lda y3
	sta $D007
		
	lda x4
	sta $D008
	lda y4
	sta $D009

	// clear all high bits
	// for all  sprites
	//lda #$E0
	//and $D010
	//sta $D010
	
	lda $CB
	sta c
					// main game loop
LBL1L6:
	lda c
	cmp #$3E
	beq LBL1L8
					// inner game loop
	lda timer
	bne !else+
	
	jsr checkLeft
	jsr checkRight
	jsr checkFire
	jsr uMissPos
	jsr uAMissPos
	jsr alienFire
	jsr updateAlienPosition
	jsr updateStats
	jsr checkAlienHit
	
!else:	inc timer
	lda $CB
	sta c
	jmp LBL1L6 // jump to top of main game loop
	
LBL1L8:	lda #$00
	sta $D015
	jsr clearkb
	jsr _cls
	lda #$0E
	sta $0286
	
	clc
	ldx #$0B
	ldy #$0F
	jsr $FFF0
	lda #<gameOverString
	ldx #>gameOverString
	jsr displayText
	
	jmp restoreregs

	
checkFire:
	lda c
	cmp #$3C
	bne !else+ // jump to ELSE [35]
	lda firey
	bne !else+ // jump to ELSE [30]
	
	lda #$02
	ora $D015
	sta $D015
	
	lda x
	sta $D002

	lda #$F0
	sta $D003
	sta firey

	lda #$FD
	and $D010
	sta $D010
!else:	rts

checkAlienHit:
	lda $D01E // MOB-MOB Collision Register
	sta f
	cmp #$12
	bne !else1+ // jump to ELSE [74]
	
	jsr cleanscore
	lda #$87
	sta $19
	lda #$48
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00
	lda #$19
	jsr $BBA2 // MEM -> FAC

	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	jsr $B86A // ARG + FAC -> FAC
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM

	inc kills
	lda #$00
	sta $D003
	sta firey
	
	lda #$FD
	and $D015
	sta $D015
	
	lda $D41B
	clc
	adc x2
	sta x2
	jmp done_checking
	
!else1:	cmp #$0A
	bne !else1+ // jump to ELSE [74]

	jsr cleanscore
	lda #$88
	sta $19
	lda #$16
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00
	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	jsr $B86A // ARG + FAC -> FAC
	
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM

	inc kills
	
	lda #$00
	sta $D003
	sta firey
	
	lda #$FD
	and $D015
	sta $D015
	
	lda $D41B
	
	clc
	adc x3
	sta x3

	jmp done_checking

	
!else1:	cmp #$06
	bne !else1+ // jump to ELSE [74]
	
	jsr cleanscore

	lda #$88
	sta $19
	lda #$48
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00
	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	
	jsr $B86A // ARG + FAC -> FAC
	
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM
	
	inc kills
	
	lda #$00
	sta $D003
	sta firey
	
	lda #$FD
	and $D015
	sta $D015

	lda $D41B
	clc
	adc x4
	sta x4

	jmp done_checking


	
!else1:	cmp #$21
	bne !else1+ // jump to ELSE [63]
	jsr cleanscore
	
	lda #$87
	sta $19
	lda #$48
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00
	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	
	jsr $B853 // ARG - FAC -> FAC
	
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM
	
	lda #$FE
	sta a1fire
	
	lda #$DF
	and $D015
	sta $D015
	
	lda #$FE
	sta $D00B

	jmp done_checking

	
!else1:	cmp #$41
	bne !else+ // jump to ELSE [63]
	
	jsr cleanscore
	lda #$88
	sta $19
	lda #$16
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00

	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	
	jsr $B853 // ARG - FAC -> FAC

	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM
	
	lda #$FE
	sta a2fire
	sta $D00D

	lda #$BF
	and $D015
	sta $D015

	jmp done_checking

	
!else:	cmp #$81
	bne !else1+ // jump to ELSE [63]

	jsr cleanscore

	lda #$88
	sta $19
	lda #$48
	sta $1A
	//lda #$00
	//sta $1B
	//sta $1C
	//sta $1D
	//tay
	ldy #$00
	lda #$19
	jsr $BBA2 // MEM -> FAC
	
	lda #<score
	ldy #>score
	jsr $BA8C // MEM -> ARG (+)
	
	jsr $B853 // ARG - FAC -> FAC
	
	ldx #<score
	ldy #>score
	jsr $BBD4 // FAC -> MEM
	
	lda #$FE
	sta a1fire
	sta $D00F
	
	lda #$7F
	and $D015
	sta $D015

done_checking:
!else1:	lda kills
	cmp #$08
	bne !else1+ // jump to ELSE [13]

	lda #$00
	sta kills
	jsr levelup
	
	lda #$FF
	sta $D015
	
!else1:	rts
	
updateAlienPosition:
	sec
	lda adist1
	bcc !else1+ // if c==0 jump to ELSE
	beq !else1+
	
	lda adir1
	cmp #$80
	bcc !else2+ // if c==0 jump to ELSE
	beq !else2+
	
	lda x2
	clc
	adc aspeed1
	sta x2
	jmp !else2++
	
!else2:	lda x2
	sec 
	sbc aspeed1
	sta x2
!else2:	dec adist1
	lda x2
	sta $D004
	lda #$FB
	and $D010
	sta $D010
	jmp !else1++
	
!else1:	lda $D41B
	sta adist1
	lda $D41B
	sta adir1
!else1: sec
	lda adist2
	bcc !else1+ // if c==0 jump to ELSE
	beq !else1+
	lda adir2
	cmp #$80
	bcc !else2+ // if c==0 jump to ELSE
	beq !else2+
	
	lda x3
	clc
	adc aspeed2
	sta x3
	jmp !else2++
!else2:	lda x3
	sec 
	sbc aspeed2
	sta x3
!else2:	dec adist2
	lda x3
	sta $D006
	lda #$F7
	and $D010
	sta $D010
	jmp !else1++
!else1:	lda $D41B
	sta adist2
	lda $D41B
	sta adir2
!else1: sec
	lda adist3
	bcc !else1+ // if c==0 jump to ELSE
	beq !else1+
	lda adir3	
	cmp #$80
	// could we use the bpl or bmi instruction here?
	bcc !else2+ // if c==0 jump to ELSE
	beq !else2+
	lda x4
	
	clc
	adc aspeed3
	sta x4
	jmp !else2++
	
!else2:	lda x4
	sec 
	sbc aspeed3
	sta x4
!else2:	dec adist3
	lda x4
	sta $D008
	lda #$EF
	and $D010
	sta $D010
	rts

!else1:	lda $D41B
	sta adist3
	lda $D41B
	sta adir3
!else1:	rts

checkLeft:
	lda c
	cmp #$1E
	bne !else+ // jump to ELSE [36]
	lda x
	cmp #$19
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	
	lda x
	sec 
	sbc plyvel
	sta x
	sta $D000
	
	lda #$FE
	and $D010
	sta $D010
!else:	rts

checkRight:
	lda c
	cmp #$26
	bne !else+ // jump to ELSE [38]
	lda x
	cmp #$F0
	bcs !else+

	lda x
	clc
	adc plyvel
	sta x
	sta $D000
	
	lda #$FE
	and $D010
	sta $D010
!else:	rts

updateStats:	
	lda timer
	beq !body+
	rts

	
!body:	clc
	ldx #$03
	ldy #$1F
	jsr $FFF0
	lda #<scoreString
	ldx #>scoreString
	jsr displayText
	
	clc
	ldx #$04
	ldy #$1F
	jsr $FFF0
	lda #<score
	ldy #>score
	jsr $BBA2 // MEM -> FAC
	jsr $BDDD // FAC -> PETSCII (Stored at $0100)
	
	lda #$00
	sta $02
	lda #$01
	sta $03
	jsr _prn
	
	clc
	ldx #$06
	ldy #$1F
	jsr $FFF0
	lda #<killsString
	ldx #>killsString
	jsr displayText
	
	clc
	ldx #$07
	ldy #$21
	jsr $FFF0
	
	lda kills
	jsr _byte_to_string
		
	clc
	ldx #$09
	ldy #$1F
	jsr $FFF0
	lda #<levelString
	ldx #>levelString
	jsr displayText
	
	clc
	ldx #$0A
	ldy #$21
	jsr $FFF0
	lda level
	jmp _byte_to_string

	
uMissPos:
	sec
	lda firey
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda firey
	sec 
	sbc missvel
	sta firey
	sta $D003
!else:	rts

alienFire:
	lda a1fire
	cmp #$F0
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda $D41B
	cmp #$FA
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda #$20
	ora $D015
	sta $D015
	lda x2
	sta $D00A
	lda #$DF
	and $D010
	sta $D010
	lda #$3C
	sta a1fire

	
!else:	lda a2fire
	cmp #$F0
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda $D41B
	cmp #$FA
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda #$40
	ora $D015
	sta $D015
	lda x3
	sta $D00C
	lda #$BF
	and $D010
	sta $D010
	lda #$55
	sta a2fire

	
!else:	lda a3fire
	cmp #$FA
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda $D41B
	cmp #$F0
	bcc !else+ // if c==0 jump to ELSE
	beq !else+
	lda #$80
	ora $D015
	sta $D015
	lda x4
	sta $D00E
	lda #$7F
	and $D010
	sta $D010
	lda #$6E
	sta a3fire
!else:	rts

uAMissPos:
	lda a1fire
	cmp #$F0
	bcs !else+
	
	lda a1fire
	clc
	adc amspeed
	sta a1fire	
	sta $D00B
	jmp !next+
	
!else:	lda #$FE
	sta a1fire
	sta $D00B

	lda #$DF
	and $D015
	sta $D015
		
!next:	lda a2fire
	cmp #$F0
	bcs !else+
	
	lda a2fire
	clc
	adc amspeed
	sta a2fire
	sta $D00D
	jmp !next+
	
!else:	lda #$FE
	sta a2fire
	sta $D00D
	
	lda #$BF
	and $D015
	sta $D015
	
!next:	lda a3fire
	cmp #$F0
	bcs !else+
	lda a3fire
	
	clc
	adc amspeed
	sta a3fire
	sta $D00F

	rts
	
!else:	lda #$FE
	sta a3fire
	sta $D00F
	
	lda #$7F
	and $D015
	sta $D015
	rts

cleanscore:
	clc
	ldx #$04
	ldy #$1F
	jsr $FFF0
	lda #<spacesString
	ldx #>spacesString
	jsr displayText
	
	clc
	ldx #$07
	ldy #$22
	jmp $FFF0

	
levelup:inc level
	lda #$00
	sta $D015
	jsr _cls
	
	clc
	ldx #$06
	ldy #$10
	jsr $FFF0

	lda level
	pha
	lda #$00 // Uint Type
	ldy #<STRLBL11
	ldx #>STRLBL11
	jsr _new_formatted_printf

	jsr longdelay
	
	clc
	ldx #$0A
	ldy #$0D
	jsr $FFF0
	lda #<pakString
	ldx #>pakString
	jsr displayText
	
	jsr pause
	jsr _cls
	inc amspeed
	inc aspeed1
	inc aspeed2
	inc aspeed3
	
	lda y2
	clc
	adc #$05
	sta y2
	
	lda y3
	clc
	adc #$05
	sta y3
	
	lda y4
	clc
	adc #$05
	sta y4
	
	rts

intro:	jsr _cls
	lda #$01
	sta $0286
	
	clc
	ldx #$06
	ldy #$0D
	jsr $FFF0
	lda #<titleString
	ldx #>titleString
	jsr displayText
	
	clc
	ldx #$08
	ldy #$08
	jsr $FFF0
	lda #<authorString
	ldx #>authorString
	jsr displayText
	
	clc
	ldx #$0D
	ldy #$0B
	jsr $FFF0
	lda #<instrString0
	ldx #>instrString0
	jsr displayText

	clc
	ldx #$0F
	ldy #$08
	jsr $FFF0
	lda #<instrString1
	ldx #>instrString1
	jsr displayText
	
	jsr longdelay
	
	clc
	ldx #$11
	ldy #$06
	jsr $FFF0
	lda #<instrString2
	ldx #>instrString2
	jsr displayText	
	jmp pause

longdelay:
	jsr clearkb

	lda #$00
	sta ii
	sta ii +1
	
	// Top of FOR Loop
LBL1L10:lda ii +1
	cmp #$0C
	bne !+
	lda ii
	cmp #$04
!:	bcs LBL1L13
	clc
	lda ii
	adc #$01
	sta ii
	lda ii +1
	adc #$00
	sta ii +1
	jmp LBL1L10
LBL1L13:rts

clearkb:lda #$00
	sta $C6
	jmp $FFE4

cpyspr:	lda #<player_ship
	ldx #>player_ship
	sta saddr
	stx saddr +1
	lda #$00
	ldx #$30
	sta ii
	stx ii +1
	
LBL1L15: // Top of FOR Loop
	lda ii +1
	cmp #$31
	bne !+
	sec
	lda ii
!:	bcs LBL1L18
	
	lda saddr
	ldx saddr +1
	sta !+
	stx !++
	.byte $AD // <-- LDA abs
!:	.byte $00 // lo byte
!:	.byte $00 // hi byte
	ldy ii
	sty !+
	ldy ii +1
	sty !++
	.byte $8D // <-- STA abs
!:	.byte $00
!:	.byte $00
	clc
	lda saddr
	adc #$01
	sta saddr
	lda saddr +1
	adc #$00
	sta saddr +1
	clc
	lda ii
	adc #$01
	sta ii
	lda ii +1
	adc #$00
	sta ii +1
	jmp LBL1L15
LBL1L18:rts
	
displayText:
	sta $02
	stx $03
	jmp _prn
	
SIDRND:	lda #$FF
	sta $D40E
	sta $D40F
	lda #$80
	sta $D412
	rts
	
_byte_to_string:
	ldy #$2F
	ldx #$3A
	sec 
!:	iny
	sbc #$64
	bcs !-
!:	dex 
	adc #$0A
	bmi !-
	adc #$2F
	sta $62
	stx $61
	tya
	ldx $62
	ldy $61

	cmp #$30
	beq !+++
	jsr $FFD2
	tya
!:	jsr $FFD2
!:	txa	
	jmp $FFD2

!:	tya
	cmp #$30
	beq !--
	jmp !---


_cls:	lda #$20
	ldx #$00
!:	sta $0400,X
	sta $0500,X
	sta $0600,X
	sta $06E8,X
	dex 
	bne !-
	rts
	

!rx:	.byte $00
!ry:	.byte $00
_new_formatted_printf:
	sty $02
	stx $03
	tax // save the type until later
	ldy #$00
!:	lda ($02),Y
	beq !+++
	cmp #$25 // (%)
	beq !+
	jsr $FFD2
	iny
	jmp !-
!:	iny
	lda ($02),Y
	cmp #$75 // (u)
	bne !+
	sty $04
	cpx #$00
	bne _back_to_printf

	pla
	sta !rx-
	pla
	sta !ry-
	
	pla // the byte to display
	jsr _byte_to_string
	
	lda !ry-
	pha
	lda !rx-
	pha
	
_back_to_printf:
	ldy $04
	iny
	jmp !--
!:	lda #$25
	jsr $FFD2
	jmp !---
!:	rts
	
_prn:	ldy #$00
!:	lda ($02),Y
	beq !+
	jsr $FFD2
	iny
	jmp !-
!:	rts
	
titleString: .text "THREE-ON-ONE"
	     .byte $00
	
authorString: .text "BY MICHAEL PELLEGRINO"
	      .byte $00
	
instrString0: .text "<-- (U) (O) -->"
	      .byte $00
	
instrString1: .text "(Q)UIT   (SPACE) FIRE"
	      .byte $00
	
instrString2: .text "PRESS ANY KEY TO BEGIN!!!"
	      .byte $00
	
gameOverString: .text "GAME OVER"
 	        .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $00
	
scoreString: .text "SCORE"
	.byte $00
	
killsString: .text "KILLS"
	 .byte $00
	
levelString: .text "LEVEL"
	 .byte $00
	
spacesString: .text "           "
	 .byte $00
	
pakString: .text "PRESS ANY KEY"
	  .byte $00
	
STRLBL11: .text "LEVEL "
	  .byte $25, $75, $00
	
player_ship:
	.byte $00, $18, $00, $00, $18, $00, $00, $24, $00, $00, $24, $00, $00, $42, $00, $00, $42, $00, $00, $99, $00, $00, $99, $00, $00, $99, $00, $11, $18, $88, $12, $00, $48, $14, $00, $28, $18, $00, $18, $10, $00, $08, $20, $00, $04, $40, $00, $02, $40, $66, $02, $3F, $99, $FC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
player_missle:
	.byte $00, $60, $00, $00, $60, $00, $00, $00, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00, $20, $00, $00, $40, $00, $00
alien_ship:
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $00, $60, $06, $00, $60, $01, $81, $80, $01, $81, $80, $07, $FF, $E0, $07, $FF, $E0, $1E, $7E, $78, $1E, $7E, $78, $7F, $FF, $FE, $7F, $FF, $FE, $66, $00, $66, $66, $00, $66, $66, $00, $66, $66, $00, $66, $01, $E7, $80, $01, $E7, $80, $00
alien_missle:
	.byte $00, $24, $00, $00, $24, $00, $00, $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $24, $00, $00, $24, $00, $00, $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $24, $00, $00, $24, $00, $00, $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $24, $00, $00, $24, $00, $00, $24, $00, $00

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

pause:	lda #$00
	sta $C6
	jsr $FFE4
!:	bne !+
	jsr $FFE4
	jmp !-
!:	rts 
