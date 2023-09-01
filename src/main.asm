norom

macro org(bank, offset)
    org $10+((<offset>-$8000)%$2000)+($2000*<bank>)
    base <offset>
endmacro

macro hex2dec(register)
		ld<register> #0
	?loop
		cmp #10
		bcc ?done
		sbc #10
		in<register>
		bcs ?loop
	?done
endmacro

; ram defines
!counter_60hz			= $C5
!previous_60hz			= $C6
!force_8x8_sprite_size	= $78
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

; constants
!counters_base_x_pos	= $68
!counters_base_y_pos	= $5F
!level_timer_x_pos		= !counters_base_x_pos
!level_timer_y_pos		= !counters_base_y_pos
!room_timer_x_pos		= !counters_base_x_pos
!room_timer_y_pos		= !counters_base_y_pos+$10
!dropped_frames_x_pos	= !counters_base_x_pos+$20
!dropped_frames_y_pos	= !counters_base_y_pos+$20


incsrc "edits.asm"

; NMI_Exit
%org($0F, $EC65)
		jmp nmi
		
; NMI_AfterBackgroundAttributesUpdate
%org($0F, $EC22)
		jmp nmi_sprite_size_fix

; WaitForNMILoop
%org($0F, $EABD)
		jmp every_frame

; PreStartLevel
%org($0F, $E270)
		jsr pre_level_start

; AreaInitialization
%org($02, $801E)
		jsr level_init

; AreaSecondaryRoutine
%org($03, $BE0B)
		jsr level_tick_hijack
		
; PauseScreenLoop
%org($0F, $E548)
		jsr pause_hijack

; StartLevel
%org($0F, $E43B)
		jsr level_load_hijack
		lda #$90
		
%org($0F, $E467)
		nop
		nop
		nop
		
%org($0F, $E470)
		lda #$90
		
; HorizontalLevel_Loop
%org($0F, $E48E)
		jsr level_load_finished_hijack
		
; VerticalLevel_Loop
%org($0F, $E4E2)
		jsr level_load_finished_hijack
		
; EndOfLevelSlotMachine
%org($0F, $E7C0)
		jsr load_bonus_chance_hijack
		
%org($0F, $E7D4)
		jsr enable_nmi_8x8
		
%org($0F, $E7DF)
		jsr disable_nmi_8x8
		
%org($0F, $EA68)
		lda #$40
		sta $0100
		jsr enable_nmi_8x8
		jmp $EAAB
	
; DoWorldWarp	
%org($0F, $E788)
		jsr warp_hijack
		
; InitializeSubArea
%org($0F, $E5A0)
		jsr clear_screen_no_sprite_masking

; loc_BANKF_E606
%org($0F, $E606)
		jsr sub_area_init
		
; loc_BANKF_E627
%org($0F, $E635)
		jsr sub_area_begin_exit
		nop
		nop
		nop
		
; ExitSubArea_Loop
%org($0F, $E65F)
		jsr sub_area_finish_exit
		

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
		
		
level_load_hijack:
		; hide all sprites
		jsr $ECA0
		
		lda !reset_level_timer
		bne .skip_timer_display
		
		inc !force_8x8_sprite_size
		jsr draw_sprite_timers
				
	.skip_timer_display:
		;jmp turn_off_ppu_except_sprites
		
turn_off_ppu_except_sprites:
		lda #$10
		jmp $EAA9
		
load_bonus_chance_hijack:
		;jmp draw_sprite_timers

draw_sprite_timers:
		lda #$3B
		sta $06FA
		
		ldy #$00
		lda #!level_timer_y_pos
		sta $00
		lda #!level_timer_x_pos
		sta $01
		lda #%00100001
		sta $02
		lda !level_timer_minutes
		jsr draw_decimal_counter
		lda !level_timer_seconds
		jsr draw_decimal_counter
		lda !level_timer_frames
		jsr draw_decimal_counter
		
		lda #!room_timer_y_pos
		sta $00
		lda #!room_timer_x_pos
		sta $01
		lda !room_timer_minutes
		jsr draw_decimal_counter
		lda !room_timer_seconds
		jsr draw_decimal_counter
		lda !room_timer_frames
		jsr draw_decimal_counter
		
		lda #!dropped_frames_y_pos
		sta $00
		lda #!dropped_frames_x_pos
		sta $01
		lda !dropped_frames
		; jmp draw_hex_counter
		
draw_hex_counter:
		tax
		lsr
		lsr
		lsr
		lsr
		ora #$50
		sta $0201,y
		txa
		and #$0F
		ora #$50
		sta $0205,y
		
		lda $00
		sta $0200,y
		sta $0204,y
		
		lda $01
		sta $0203,y
		adc #8
		sta $0207,y
		adc #8
		sta $01
		
		lda $02
		sta $0202,y
		sta $0206,y
		
		tya
		adc #8
		tay
		rts

		
; input:
; $00 = y pos
; $01 = x pos
; $02 = attributes
; Y = oam index
draw_decimal_counter:
		%hex2dec(x)
		ora #$50
		sta $0205,y
		txa
		ora #$50
		sta $0201,y
		
		lda $00
		sta $0200,y
		sta $0204,y
		
		lda $01
		sta $0203,y
		adc #8
		sta $0207,y
		adc #8
		sta $01
		
		lda $02
		sta $0202,y
		sta $0206,y
		
		tya
		adc #8
		tay
		rts
		

sub_area_finish_exit:
sub_area_init:
level_load_finished_hijack:
		; reload chr banks
		jsr $FE16

		lda #0
		sta !force_8x8_sprite_size
		
		; hide all sprites
		jsr $ECA0

		; WaitForNMI_TurnOnPPU
		jmp $EAA7


nmi_sprite_size_fix:
		jsr $EC68
		lda !force_8x8_sprite_size
		bne +
		jmp $EC25
	+
		lda #$90
		jmp $EC27
		


warp_hijack:
		jsr draw_sprite_timers
		inc !force_8x8_sprite_size
		;jmp enable_nmi_8x8

enable_nmi_8x8:
		lda #$90
		sta $2000
		sta $FF
		rts

disable_nmi_8x8:
		lda #$10
		sta $2000
		sta $FF
		rts

clear_screen_no_sprite_masking:
		lda #$10
		; rest of ClearNametablesAndSprites
		jsr $EC8C
		lda #$90
		sta $2000
		sta $FF
		inc !force_8x8_sprite_size
		
		jmp draw_sprite_timers


sub_area_begin_exit:
		; hide all sprites
		jsr $ECA0
		inc !force_8x8_sprite_size
		jsr draw_sprite_timers
		jmp turn_off_ppu_except_sprites
		

print pc
warnpc $F000
