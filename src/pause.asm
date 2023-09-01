@include

; this does not seem to run every frame
pause_tick:
		jsr update_timers
		jmp $E51D

