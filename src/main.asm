norom

incsrc "defines.asm"

incsrc "edits.asm"
incsrc "hijacks.asm"

%org($0F, $ED4D)
incsrc "nmi.asm"
incsrc "every_frame.asm"
incsrc "load_screens.asm"
incsrc "level.asm"
incsrc "pause.asm"
incsrc "ending.asm"

print pc
warnpc $F000
