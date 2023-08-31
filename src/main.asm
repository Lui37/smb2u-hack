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
!reset_level_timer		= $05CE
!is_first_frame_of_room	= $05CF

incsrc "edits.asm"

%org($0F, $EC65)
		jmp nmi

%org($0F, $EABD)
		jmp every_frame

%org($0F, $E270)
		jsr pre_level_start

; %org($0F, $E46D)
		; jsr level_init
%org($02, $801E)
		jsr level_init

%org($03, $BE0B)
		jsr level_tick_hijack
		
%org($0F, $E548)
		jsr pause_hijack

org $26010
		incbin "gfx.chr"

; unused space
%org($0F, $ED4D)
nmi:
		inc !counter_60hz
		pla
		plp
		rti

every_frame:
		lda !counter_60hz
		sec
		sbc !previous_60hz
		tay
				
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


pre_level_start:
		inc !reset_level_timer
		jmp $E1F4


level_init:
		lda #0
		sta !dropped_frames
		sta !room_timer_frames
		sta !room_timer_seconds
		sta !room_timer_minutes
		inc !is_first_frame_of_room
		
		ldy !reset_level_timer
		beq +
		sta !real_frames_elapsed
		sta !level_timer_frames
		sta !level_timer_seconds
		sta !level_timer_minutes
		sta !reset_level_timer
	+
		inc $04AE
		rts
		

level_tick:
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
		lda !is_first_frame_of_room
		bne ..done
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
		sta !is_first_frame_of_room
		rts
		
level_tick_hijack:
		jsr level_tick
		lda $04C6
		rts
		
pause_hijack:
		jsr level_tick
		jmp $E51D
		

warnpc $F000
