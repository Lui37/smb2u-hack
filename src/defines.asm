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

; new ram
!counter_60hz				= $C5
!previous_60hz				= $C6
!force_8x8_sprite_size		= $78
!real_frames_elapsed		= $05C6
!dropped_frames				= $05C7
!level_timer_frames			= $05C8
!level_timer_seconds		= $05C9
!level_timer_minutes		= $05CA
!room_timer_frames			= $05CB
!room_timer_seconds			= $05CC
!room_timer_minutes			= $05CD
!reset_level_timer			= $05CE
!is_first_frame_of_room		= $05CF
!dont_reset_level_timer		= $05D0

; ram
!vram_update_index			= $11
!player_x_velocity			= $3C
!sprite_state				= $51
!player_y_velocity			= $46
!current_character			= $8F
!sprite_id					= $90
!player_holding_item		= $9C
!sprite_grab_timer			= $A8
!nmi_flag					= $EB
!input_abetudlr_frame		= $F5
!input_abetudlr_hold		= $F7
!ppu_ctrl_mirror			= $FF
!game_mode_0100				= $0100
!player_lock				= $041B
!carried_sprite_index		= $042D
!sprite_projectile_timer	= $042F
!is_area_initialized		= $04AE
!carried_over_sprite_index	= $04AF
!is_lock_open				= $04B0
!player_riding_carpet		= $04B2
!door_animation_timer		= $04BD
!player_health				= $04C2
!player_max_health			= $04C3
!sky_flash_timer			= $04C6
!is_player_in_rocket		= $04C7
!star_timer					= $04E0
!player_y_velocity_init		= $04E5
!player_state_init			= $04E6
!current_level_init			= $04E7
!current_room_init			= $04E8
!current_entry_page_init	= $04E9
!transition_type_init		= $04EA
!game_mode					= $04EC
!veggie_thrower_counter		= $04F9
!is_mushroom_1_obtained		= $04FB
!is_mushroom_2_obtained		= $04FC
!stopwatch_timer			= $04FF
!current_level				= $0531
!current_room				= $0532
!current_entry_page			= $0533
!transition_type			= $0534
!music_queue_2				= $0603
!is_1up_obtained			= $0620
!subspace_visit_count		= $0621
!current_level_relative		= $0629
!cherry_count				= $062A
!big_veggies_pulled			= $062C
!current_world				= $0635
!player_size				= $06F6

; sram
!titlecard_level_dots		= $716B
!titlecard_world			= $717D
!titlecard_level			= $717F

; regs
!ppu_ctrl					= $2000

; rom
world_starting_level		= $E012 ; WorldStartingLevel
character_select_menu		= $E425 ; LevelStartCharacterSelectMenu
wait_for_nmi_turn_on_ppu	= $EAA7 ; WaitForNMI_TurnOnPPU
delay_160_frames			= $E94A ; Delay160Frames
hide_all_sprites			= $ECA0 ; HideAllSprites
level_initialization		= $F1E1 ; LevelInitialization
do_area_reset				= $F6DA ; DoAreaReset
load_world_chr_banks		= $FE16 ; LoadWorldCHRBanks

; constants
!counters_base_x_pos		= $68
!counters_base_y_pos		= $5F
!counters_attributes		= %00000001
!level_timer_x_pos			= !counters_base_x_pos
!level_timer_y_pos			= !counters_base_y_pos
!room_timer_x_pos			= !counters_base_x_pos
!room_timer_y_pos			= !counters_base_y_pos+$10
!dropped_frames_x_pos		= !counters_base_x_pos+$20
!dropped_frames_y_pos		= !counters_base_y_pos+$20
!level_select_holdoff		= $09
!level_select_speed			= $02
