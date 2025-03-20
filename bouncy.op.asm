.label mydelay = $6784
.label box = $6786
.label dot = $6788
.label dst = $678A
.label src = $678C
.label i = $678E
.label currentX = $678F
.label currentY = $6791
.label innerX = $6792
.label innerY = $6794
.label deltaX = $6795
.label deltaY = $6796
.label innerDX = $6797
.label innerDY = $6798
.label z = $6799
.label c = $679A
.label l = $679B
* = $0801
BasicUpstart($080D)
* = $080D
	lda #$0C
	sta $D020
	lda #$00
	sta $D021
	lda #$00
	ldx #$01
	sta mydelay
	stx mydelay+1
	lda #$93
	jsr $FFD2
	lda #<STRLBL0
	sta $02
	lda #>STRLBL0
	sta $03
	jsr PRN
	lda #<STRLBL2
	sta $02
	lda #>STRLBL2
	sta $03
	jsr PRN
	lda #<STRLBL3
	sta $02
	lda #>STRLBL3
	sta $03
	jsr PRN
	lda #<LBL1L0
	sta box
	lda #>LBL1L0
	sta box+1
	lda #<LBL1L1
	sta dot
	lda #>LBL1L1
	sta dot+1
	lda #$00
	ldx #$20
	sta dst
	stx dst+1
	lda box
	ldx box+1
	sta src
	stx src+1
	lda #$01
	sta $D027
	sta $D028
	
	//lda $02
	//pha 
	//lda $03
	//pha 
	//php 

	lda #$00
	sta i
LBL1L3:
	lda i
	cmp #$40
	bcs LBL1L6

	ldy #$00
	lda src
	ldx src+1
	sta !+
	stx !++
	.byte $AD
!:
	.byte $00
!:
	.byte $00
	sta LBL2L0-2
	lda dst
	sta !+
	lda dst+1
	sta !++
	lda #$00
	.byte $8D
!:
LBL2L0:
	.byte $00
!:
LBL2L1:
	.byte $00
	clc 
	lda #$01
	adc dst
	sta dst
	lda #$00
	adc dst+1
	sta dst+1
	clc 
	lda #$01
	adc src
	sta src
	lda #$00
	adc src+1
	sta src+1
	inc i
	jmp LBL1L3
LBL1L6:
	lda #$40
	ldx #$20
	sta dst
	stx dst+1
	lda dot
	ldx dot+1
	sta src
	stx src+1
	lda #$00
	sta i
LBL1L8:
	lda i
	cmp #$40
	bcs LBL1L11

	ldy #$00
	lda src
	ldx src+1
	sta !+
	stx !++
	.byte $AD
!:
	.byte $00
!:
	.byte $00
	sta LBL2L2-2
	lda dst
	sta !+
	lda dst+1
	sta !++
	lda #$00
	.byte $8D
!:
LBL2L2:
	.byte $00
!:
LBL2L3:
	.byte $00
	clc 
	lda #$01
	adc dst
	sta dst	
	lda #$00
	adc dst+1
	sta dst+1

	clc 
	lda #$01
	adc src
	sta src
	lda #$00
	adc src+1
	sta src+1
	inc i
	jmp LBL1L8
LBL1L11:
	//plp 
	//pla 
	//sta $03
	//pla 
	//sta $02
	lda #$01
	sta $D01D
	sta $D017

	
	jsr SIDRND // initialize random number generator
	lda $D41B
	ldx #$00
	sta currentX
	stx currentX+1
	lda #$50
	sta currentY
	lda currentX
	ldx currentX+1
	sta innerX
	stx innerX+1
	lda currentY
	sta innerY
	lda currentX
	sta $D000
	lda currentY
	sta $D001
	lda #$01
	bit currentX+1
	beq !+
	lda #$01
	ora $D010
	jmp !++
!:
	lda #$FE
	and $D010
!:
	sta $D010
	lda #$80
	sta $07F8
	lda currentX
	sta $D002
	lda currentY
	sta $D003
	lda #$01
	bit currentX+1
	beq !+
	lda #$02
	ora $D010
	jmp !++
!:
	lda #$FD
	and $D010
!:
	sta $D010
	lda #$81
	sta $07F9
	lda #$FF
	ora $D015
	sta $D015

	lda #$01
	sta deltaX
	sta deltaY
	sta innerDX
	sta innerDY
	sta z
	
	lda #$00
	sta $C6
	lda $CB
	sta c

LBL1L13:			 // Top of WHILE Loop
	lda z
	cmp #$01
	beq !_skip+
	jmp LBL1L15
!_skip:
	lda deltaX
	cmp #$01
	bne LBL2L7
	clc 
	lda #$01
	adc currentX
	sta currentX
	
	lda #$00
	adc currentX+1
	sta currentX+1
	
	clc 
	lda #$01
	adc innerX
	sta innerX
	lda #$00
	adc innerX+1
	sta innerX+1
	
	jmp LBL2L8
LBL2L7:
	lda #$FF
	dcp currentX
	bne !+
	dec currentX+1
!:
	lda #$FF
	dcp innerX
	bne !+
	dec innerX+1
!:
LBL2L8:
	lda innerDX
	cmp #$01
	bne LBL2L12
	clc 
	lda #$01
	adc innerX
	sta innerX
	lda #$00
	adc innerX+1
	sta innerX+1
	jmp LBL2L13
LBL2L12:
	lda #$FF
	dcp innerX
	bne !+
	dec innerX+1
!:
LBL2L13:
	clc 
	lda currentY
	adc deltaY
	sta currentY
	clc 
	lda innerY
	adc deltaY
	sta innerY
	clc 
	lda innerY
	adc innerDY
	sta innerY
	lda currentX
	sta $D000
	lda #$01
	bit currentX+1
	beq !+
	lda #$01
	ora $D010
	jmp !++
!:
	lda #$FE
	and $D010
!:
	sta $D010
	lda currentY
	sta $D001
	lda innerX
	sta $D002
	lda #$01
	bit innerX+1
	beq !+
	lda #$02
	ora $D010
	jmp !++
!:
	lda #$FD
	and $D010
!:
	sta $D010
	lda innerY
	sta $D003
	
	lda currentY
	//cmp #$E6
	cmp #$D1
	bcc LBL2L17
	beq LBL2L17
	lda #$FF
	sta deltaY
LBL2L17:
	lda currentY
	cmp #$30
	bcs LBL2L22
	lda #$01
	sta deltaY
LBL2L22:
	lda currentX+1
	cmp #$01
	bne !+
	lda currentX
	//cmp #$40
	cmp #$29
!:
	bcc LBL2L27
	beq LBL2L27
	lda #$FF
	sta deltaX
LBL2L27:
	lda currentX+1
	cmp #$00
	bne !+
	lda currentX
	cmp #$16
!:
	bcs LBL2L32
	lda #$01
	sta deltaX
LBL2L32:
	clc
	lda #$21
	//lda #$0A
	adc currentX
	sta !++
	lda #$00
	adc currentX+1
	sta !+
	ldx innerX+1
	.byte $E0
!:
	.byte $00
	bne !++
	lda innerX
	.byte $C9
!:
	.byte $00
!:
	bcc LBL2L37
	beq LBL2L37
	lda #$FF
	sta innerDX
LBL2L37:
	sec 
	lda currentX
	sbc #$0B
	pha 
	lda currentX+1
	sbc #$00
	tax 
	pla 
	sta !++
	stx !+
	ldx innerX+1
	.byte $E0
!:
	.byte $00
	bne !++
	lda innerX
	.byte $C9
!:
	.byte $00
!:
	bcs LBL2L42
	lda #$01
	sta innerDX
LBL2L42:
	sec 
	lda currentY
	sbc #$09
	sta $02
	tax 
	lda $02
	tay 
	stx $02
	lda innerY
	cmp $02
	sty $02
	bcs LBL2L47
	lda #$01
	sta innerDY
LBL2L47:
	clc 
	lda currentY
	adc #$1D
	//adc #$09
	sta $02
	tax 
	lda $02
	tay 
	stx $02
	lda innerY
	cmp $02
	sty $02
	bcc LBL2L52
	beq LBL2L52
	lda #$FF
	sta innerDY
LBL2L52:
	jsr delay
	lda $CB
	sta c

	lda c
	// 'Q'
	cmp #$3E
	bne LBL2L57
	lda #$00
	sta z
LBL2L57:
	lda c
	// ' '
	cmp #$3C
	bne LBL2L62
	lda #$FF
	ldx #$01
	sta mydelay
	stx mydelay+1
	jmp LBL2L63
LBL2L62:
	lda #$03
	ldx #$00
	sta mydelay
	stx mydelay+1
LBL2L63:
	jmp LBL1L13 // jump to top of WHILE loop
LBL1L15:
	lda #$00
	sta $C6
	rts 


delay:
	lda #$00
	sta l
	sta l+1
LBL1L17:
	lda l+1
	cmp mydelay+1
	bne !+
	lda l
	cmp mydelay
!:
	bcs LBL1L20

	// nop 

	clc 
	lda #$01
	adc l
	sta l
	lda #$00
	adc l+1
	sta l+1
	jmp LBL1L17
LBL1L20:
	rts 

SIDRND:
	lda #$FF
	sta $D40E
	sta $D40F
	lda #$80
	sta $D412
	rts 
PRN:
	ldy #$00
!:
	lda ($02),Y
	beq !+
	jsr $FFD2
	iny 
	jmp !-
!:
	rts 
STRLBL0:
	.byte  $20, $20, $20, $20, $20, $20, $42, $4F, $55, $4E, $43, $59, $20, $44, $4F, $54, $20, $49, $4E, $20, $41, $20, $42, $4F, $55, $4E, $43, $59, $20, $42, $4F, $58, $0D, $00
STRLBL1: 
	.byte  $20, $20, $20, $20, $20, $20, $20, $42, $59, $3A, $20, $4D, $49, $43, $48, $41, $45, $4C, $20, $4B, $20, $50, $45, $4C, $4C, $45, $47, $52, $49, $4E, $4F, $0D, $00
STRLBL2:
	.byte  $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $32, $30, $32, $35, $20, $30, $33, $20, $32, $30, $0D, $0D, $00
STRLBL3:
	.byte  $27, $53, $50, $41, $43, $45, $27, $20, $54, $4F, $20, $53, $4C, $4F, $57, $20, $44, $4F, $57, $4E, $20, $2D, $20, $50, $52, $45, $53, $53, $20, $27, $51, $27, $20, $54, $4F, $20, $51, $55, $49, $54, $00
LBL1L0: .byte $FF, $FF, $FF, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $80, $00, $01, $FF, $FF, $FF, $00
LBL1L1: .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
