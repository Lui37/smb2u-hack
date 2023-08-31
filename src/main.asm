norom

macro org(bank, offset)
    org $10+((<offset>-$8000)%$2000)+($2000*<bank>)
    base <offset>
endmacro

; ram defines
!counter_60hz			= $C5
!previous_60hz			= $C6
!real_frames_elapsed	= $05C6
!dropped_frames			= $05C7
!level_timer_frames		= $05C8
!level_timer_seconds	= $05C9
!level_timer_minutes	= $05CA
!room_timer_frames		= $05CB
!room_timer_seconds		= $05CC
!room_timer_minutes		= $05CD


%org($0F, $EC65)
		jmp nmi_hijack

%org($0F, $EABD)
		jmp every_frame

%org($03, $BE0B)
		jsr level_hijack

org $26010
		incbin "gfx.chr"

; unused space		
%org($0F, $ED4D)
nmi_hijack:
		inc !counter_60hz
		pla
		plp
		rti

every_frame:
		lda !counter_60hz
		sec
		sbc !previous_60hz
		tay
		
	; check if we're not in a level if needed
		
		clc
		adc !real_frames_elapsed
		sta !real_frames_elapsed
		
		tya
		sec
		sbc #1
		clc
		adc !dropped_frames
		sta !dropped_frames
		
		lda !counter_60hz
		sta !previous_60hz
		
	; wait for nmi loop
	-	lda $EB
		bpl -
		rts

level_hijack:
	.level_timer_tick:
		lda !level_timer_frames
		clc
		adc !real_frames_elapsed
		sta !level_timer_frames
		cmp #60
		bcc ..done
		
		sbc #60
		sta !level_timer_frames
		lda !level_timer_seconds
		adc #0
		sta !level_timer_seconds
		cmp #60
		bcc ..done
		
		sbc #60
		sta !level_timer_seconds
		lda !level_timer_minutes
		adc #0
		cmp #10
		bcc ..no_cap
		lda #59
		sta !level_timer_frames
		sta !level_timer_seconds
		lda #9
	..no_cap:
		sta !level_timer_minutes
	..done:
		
	.room_timer_tick:
		lda !room_timer_frames
		clc
		adc !real_frames_elapsed
		sta !room_timer_frames
		cmp #60
		bcc ..done
		
		sbc #60
		sta !room_timer_frames
		lda !room_timer_seconds
		adc #0
		sta !room_timer_seconds
		cmp #60
		bcc ..done
		
		sbc #60
		sta !room_timer_seconds
		lda !room_timer_minutes
		adc #0
		cmp #10
		bcc ..no_cap
		lda #59
		sta !room_timer_frames
		sta !room_timer_seconds
		lda #9
	..no_cap:
		sta !room_timer_minutes
	..done:
	
		lda #0
		sta !real_frames_elapsed
	
		lda $04C6
		rts

warnpc $F000
