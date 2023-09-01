@include

pause_init:
		; draw PAUSE text which will be static
		lda #$0D
		sta $11
		; initalize selected level
		lda $0635
		sta $0E
		lda $0531
		sta $0F
		; initialize up/down hold counters
		lda #!level_select_holdoff
		sta $0C
		sta $0D
		rts
		
		
pause_tick:
		jsr update_timers
		
		; press up/down to select a level
		lda #$08
		bit $F7
		beq .not_holding_up
		bit $F5
		bne .inc_level
		; increase level every so often when holding up
		dec $0C
		bpl .not_holding_down
		lda #!level_select_speed
		sta $0C
	.inc_level:
		sta $06FF
		ldx $0F
		inx
		cpx #$14
		bcc +
		ldx #0
	+	stx $0F
		lda world_number_by_level,x
		sta $0E
		jmp .selected_level_changed
		
	.not_holding_up:
		lda #!level_select_holdoff
		sta $0C
		
		lda #$04
		bit $F7
		beq .not_holding_down
		bit $F5
		bne .dec_level
		; decrease level every so often when holding down
		dec $0D
		bpl .check_warp
		lda #!level_select_speed
		sta $0D
	.dec_level:
		ldx $0F
		dex
		bpl +
		ldx #$13
	+	stx $0F
		lda world_number_by_level,x
		sta $0E
		
	.selected_level_changed:
		jsr update_level_text
		bne .check_warp
		
	.not_holding_down:
		lda #!level_select_holdoff
		sta $0D
		
		; press select to warp to selected level
	.check_warp
		lda $F5
		and #$20
		beq .done
		
		; set world and level numbers
		ldx $0E
		stx $0635
		ldy $0F
		sty $0531
		
		; LevelStartCharacterSelectMenu
		jmp $E425
		
	.done:
		jmp $E521


; $0E: selected world number
; $0F: selected level number
; uses $03 and $0B
update_level_text:
		; world number
		ldx $0E
		inx
		txa
		ora #$D0
		sta $717D
		
		; clear level dots
		ldy #$06
		lda #$FB
	-	sta $716B,y
		dey
		bpl -
		
		; level number
		ldy $0E
		lda $0F
		sec
		sbc $E012,y
		sta $0B
		clc
		adc #$D1
		sta $717F
		
		; level dots
		lda $E012+1,y
		sec
		sbc $E012,y
		sta $03
		ldx #0
		ldy #0
	-	lda #$FD
		cpx $0B
		bne +
		lda #$F6
	+	sta $716B,y
		iny
		iny
		inx
		cpx $03
		bcc -
		
		; screen update
		lda #$08
		sta $11
		rts
		
		
world_number_by_level:
		db 0, 0, 0, 1, 1, 1, 2, 2
		db 2, 3, 3, 3, 4, 4, 4, 5
		db 5, 5, 6, 6
		