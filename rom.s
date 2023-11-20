; inspired by Lameguy64/n00brom
; and JonathanDotCel/RomProd

.psx

.create "stoppable.rom", 0x1f000000

header:
	.word postboot
	.ascii "Licensed by Sony Computer Entertainment Inc."
	.align 0x80

	.word preboot
	.ascii "Licensed by Sony Computer Entertainment Inc."
	.align 0x80

postboot:
	j postboot
	nop

preboot:
	; overwrite debug isr
	li	v0, 0x80000040	; isr address
	li	a0, 0x3c1a1f00	; lui k0, 0x1fuu
	sw	a0, 0(v0)
	la	a1, midboot
	andi	a1, 0xffff
	lui	a0, 0x375a	; ori k0, midboot
	or	a0, a1
	sw	a0, 4(v0)
	li	a0, 0x03400008	; jr k0
	sw	a0, 8(v0)
	sw	$0, 12(v0)	; nop

	; set breakpoint
	li	v0, 0x80030000	; shell address
	mtc0	v0, $3		; BPC
	li	v0, 0xffffffff
	mtc0	v0, $11		; BPCM
	li	v0, 0xe1800000
	mtc0	v0, $7		; DCIC

	; back to bios
	jr ra
	nop

IO	equ 0x1f800000
GP0	equ 0x1810
GP1	equ 0x1814

midboot:
	; remove breakpoint
	mtc0	$0, $7		; DCIC
	mtc0	$0, $3		; BPC
	mtc0	$0, $11		; BPCM

	; print a message
	la	a0, message
	jal	puts
	nop

	li	a0, IO

	; reset gpu
	li	t0, 0x00000000
	sw	t0, GP1(a0)
	; display enable
	li	t0, 0x03000000
	sw	t0, GP1(a0)
	; display mode
	li	t0, 0x08000001
	sw	t0, GP1(a0)
	; horizontal range
	li	t0, 0x06c60260
	sw	t0, GP1(a0)
	; vertical range
	li	t0, 0x07042018
	sw	t0, GP1(a0)
	; draw mode
	li	t0, 0xe1000400
	sw	t0, GP0(a0)
	; area top left
	li	t0, 0xe3000000
	sw	t0, GP0(a0)
	; area bottom right
	li	t0, 0xe403bd3f
	sw	t0, GP0(a0)
	; offset
	li	t0, 0xe5000000
	sw	t0, GP0(a0)

	; grey
	li	t0, 0x604b4b4b
	sw	t0, GP0(a0)
	li	t0, 0x00000000
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; yellow
	li	t0, 0x6000ffff
	sw	t0, GP0(a0)
	li	t0, 0x0000002e
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; cyan
	li	t0, 0x60ffff00
	sw	t0, GP0(a0)
	li	t0, 0x0000005c
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; green
	li	t0, 0x6000ff00
	sw	t0, GP0(a0)
	li	t0, 0x0000008a
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; magenta
	li	t0, 0x60ff00ff
	sw	t0, GP0(a0)
	li	t0, 0x000000b8
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; red
	li	t0, 0x600000ff
	sw	t0, GP0(a0)
	li	t0, 0x000000e6
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; blue
	li	t0, 0x60ff0000
	sw	t0, GP0(a0)
	li	t0, 0x00000114
	sw	t0, GP0(a0)
	li	t0, 0x00f0002e
	sw	t0, GP0(a0)

	; wait a bit
	li	t0, 0xffffff
delay:
	subi	t0, 1
	bnez	t0, delay
	nop

	; load executable
	la	a0, executable
	lw	t1, 0x18(a0)	; destinaion
	lw	t2, 0x1c(a0)	; length
	addiu	t3, a0, 0x800	; source, header is 800h bytes
copy_loop:
	lb	t4, 0x0(t3)
	nop
	addiu	t3, t3, 1
	sb	t4, 0x0(t1)
	nop
	addiu	t1, t1, 1
	subi	t2, 1
	bnez	t2, copy_loop
	nop

	lw	t1, 0x10(a0)	; initial pc
	lw	t2, 0x30(a0)	; sp base
	lw	t3, 0x34(a0)	; sp offset
	lw	gp, 0x14(a0)	; initial gp
	add	sp, t2, t3
	li	sp, 0x801FFFF0

	jr t1
	nop

end:
	j end
	nop

putc:
	addiu   t2, r0, 0xa0
	jr      t2
	addiu   t1, r0, 0x09

puts:
	addiu	t2, r0, 0xa0
	jr	t2
	addiu	t1, r0, 0x3e

message: .ascii "call me, beep me!"

	.align 4
executable:
	.incbin "template/build/template.exe"
	.align 4

.close
