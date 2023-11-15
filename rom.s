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

	; red square
	li	t0, 0x600000ff
	sw	t0, GP0(a0)
	li	t0, 0x00080020
	sw	t0, GP0(a0)
	li	t0, 0x002a002a
	sw	t0, GP0(a0)

	; green square
	li	t0, 0x6000ff00
	sw	t0, GP0(a0)
	li	t0, 0x00080060
	sw	t0, GP0(a0)
	li	t0, 0x002a002a
	sw	t0, GP0(a0)

	; blue square
	li	t0, 0x60ff0000
	sw	t0, GP0(a0)
	li	t0, 0x000800a0
	sw	t0, GP0(a0)
	li	t0, 0x002a002a
	sw	t0, GP0(a0)

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

.close
