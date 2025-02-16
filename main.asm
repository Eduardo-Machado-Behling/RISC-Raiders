.include "macros/stack.s"
.include "macros/syscalls.s"

.eqv SCREEN_WIDTH 512
.eqv SCREEN_HEIGHT 256
.eqv BITMAP_DISPLAY_BASE 0x10080000

.eqv KEYBOARD_MMIO 0xFFFF0000
.eqv VEL_X 250
.eqv VEL_Y 200

.data
.include "sprites/germany.spr"
.include "sprites/bg.spr"

.macro getTimeFloat(%LW, %HI)
	time($t0, $t1)
	sw $t0, ($sp)
	sw $t1, 4($sp)
	lwc1 %LW, ($sp)
	lwc1 %HI, 4($sp)
	cvt.d.w %LW, %LW
.end_macro

.text
main:
	getTimeFloat($f0, $f1)
	
	li $s0, KEYBOARD_MMIO         # Load base address of Keyboard MMIO
	li $s6, 0
    li $s7, 0
    
    li $s4, 0
    li $s5, 0
    
   
    la $s1, SPR_BG
    
    PUSHI.H(0)				# x
    PUSHI.H(0)				# y
	PUSHI.H(4096)   # width
    PUSHI.H(1024)  # height
    PUSHI.H(0)              # rot
    PUSH.W($s1)             # spr
	jal __renderer__drawSpr
	POP.W($0)

	la $s1, SPR_GERMANY
	PUSH.H($s6)				# x
    PUSH.H($s7)				# y
	PUSHI.H(64)   # width
    PUSHI.H(64)  # height
    PUSHI.H(0)              # rot
    PUSH.W($s1)             # spr
	jal __renderer__drawSpr
	POP.W($s3)
	jal __renderer__drawCall

	li $t0, 1000
	sw $t0, ($sp)
	lwc1 $f30, ($sp)
	cvt.d.w $f30, $f30
	
	li $t0, 1
	sw $t0, ($sp)
	lwc1 $f26, ($sp)
	cvt.d.w $f26, $f26
gameLoop:
	getTimeFloat($f2, $f3)
	
	sub.d $f4, $f2, $f0
	div.d $f6, $f4, $f30
	mov.d $f0, $f2
	div.d $f28, $f26, $f6
	
	printDouble($f28)
	printCharI('\n')
	
	lb $t0, 16($s0)
	beq $t0, $zero, noRelease # If no key is pressed, skip reading
	PUSH.H($t0)
	jal HandleRelease
	
noRelease:	
    lb $t0, 0($s0)          # Load Keyboard control register
    beq $t0, $zero, noPress # If no key is pressed, skip reading
    PUSH.H($t0)
	jal HandlePress
noPress:
	

	sw $s4, ($sp)
    sw $s5, 4($sp)
    lwc1 $f14, ($sp)
    lwc1 $f16, 4($sp)
    cvt.d.w $f8, $f14
    cvt.d.w $f10, $f16
    mul.d $f16, $f8, $f6
    mul.d $f14, $f10, $f6
    
    add.d $f18, $f14, $f18
    add.d $f20, $f16, $f20

    cvt.w.d $f22, $f18
    cvt.w.d $f24, $f20
    swc1 $f22 ($sp)
    swc1 $f24 4($sp)
    
    lw $s6, ($sp)
    lw $s7, 4($sp)
    
    sh $s6,  ($s3)
    sh $s7, 2($s3)
	
	jal __renderer__drawCall
	
	printCharI('\n')
	printCharI('\n')
	sleepI(1)
    j gameLoop
	li $v0 10
	syscall
	

HandlePress:
	POP.H($t0)
	add $t1, $s0, 1
HandlePress__for:
	beqz $t0, HandlePress__forEnd
	lb $t4, ($t1)
	
	beq $t4, 65, HandlePress__KBD_A
	beq $t4, 68, HandlePress__KBD_D
	beq $t4, 87, HandlePress__KBD_W
	beq $t4, 83, HandlePress__KBD_S
	beq $t4, 32, HandlePress__KBD_SPACE
	j HandlePress__Handled

HandlePress__KBD_A:
	beq  $s4, -VEL_X, HandlePress__Handled
	addi $s4, $s4, -VEL_X
	j HandlePress__Handled
HandlePress__KBD_D:
	beq  $s4, VEL_X, HandlePress__Handled
	addi $s4, $s4, VEL_X
	j HandlePress__Handled
HandlePress__KBD_W:
	beq  $s5, -VEL_Y, HandlePress__Handled
	addi $s5, $s5, -VEL_Y
	j HandlePress__Handled
HandlePress__KBD_S:
	beq  $s5, VEL_Y, HandlePress__Handled
	addi $s5, $s5, VEL_Y
	j HandlePress__Handled
	
HandlePress__KBD_SPACE:
	li $s5, 0
	li $s4, 0
	li $s6, 0
	li $s7, 0
	j HandlePress__Handled
HandlePress__Handled:

	subi $t0, $t0, 1
	addi $t1, $t1, 1

	j HandlePress__for
HandlePress__forEnd:
	sb $0, ($s0)
	jr $ra

HandleRelease:
	POP.H($t0)
	add $t1, $s0, 0x11
HandleRelease__for:
	beqz $t0, HandleRelease__forEnd
	lb $t4, ($t1)
	
	beq $t4, 65, HandleRelease__KBD_A
	beq $t4, 68, HandleRelease__KBD_D
	beq $t4, 87, HandleRelease__KBD_W
	beq $t4, 83, HandleRelease__KBD_S
	j HandleRelease__Handled
HandleRelease__KBD_A:
	addi $s4, $s4, VEL_X
	j HandleRelease__Handled
HandleRelease__KBD_D:
	addi $s4, $s4, -VEL_X
	j HandleRelease__Handled
HandleRelease__KBD_W:
	addi $s5, $s5, VEL_Y
	j HandleRelease__Handled
HandleRelease__KBD_S:
	addi $s5, $s5, -VEL_Y
	j HandleRelease__Handled
HandleRelease__Handled:

	subi $t0, $t0, 1
	addi $t1, $t1, 1

	j HandleRelease__for
HandleRelease__forEnd:
	sb $0, 16($s0)
	jr $ra

.include "renderer.asm"
