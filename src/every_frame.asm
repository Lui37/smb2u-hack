@include

every_frame:
		lda !counter_60hz
		sec
		sbc !previous_60hz
		tay
				
		clc
		adc !real_frames_elapsed
		sta !real_frames_elapsed
		
		dey
		tya
		clc
		adc !dropped_frames
		bcc +
		lda #$FF
	+	sta !dropped_frames
		
		lda !counter_60hz
		sta !previous_60hz
		
	; wait for nmi loop
	-	lda !nmi_flag
		bpl -
		rts
