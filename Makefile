AS := asar.exe
AFLAGS := --no-title-check

all: u1.0

u1.0:
	cp nes/smb2_u1.0.nes target/smb2u_hack.nes && cd src && $(AS) $(AFLAGS) main.asm ../target/smb2u_hack.nes && cd -

.PHONY: all, clean
clean:
	rm -f target/*.nes
