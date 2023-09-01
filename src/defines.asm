@include

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
