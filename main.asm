.include "macros/stack.s"
.include "macros/syscalls.s"

.eqv SCREEN_WIDTH 512
.eqv SCREEN_HEIGHT 256
.eqv BITMAP_DISPLAY_BASE 0x10000004

.eqv KEYBOARD_MMIO 0x10080000
.eqv UNITS_PER_FRAME 16

# DON'T CHANGE
# perfomance reasons
.eqv QUAD_SIZE 16

.data
.include "sprites/germany.spr"
.include "sprites/bg.spr"

.text
main:
	li $s2, BITMAP_DISPLAY_BASE
	li $s0, KEYBOARD_MMIO         # Load base address of Keyboard MMIO
	li $s6, 0
    li $s7, 0
    li $s5, UNITS_PER_FRAME
    
    sub $s5, $s5, 25
    
    la $s4, SPR_GERMANY
    la $s1, SPR_BG
    PUSHI.W(0)
    PUSHI.W(0)
    PUSH.W($s4)
	jal __renderer__drawQuad
	jal __renderer__drawCall
    
gameLoop:
	
    lw $s3, 0($s0)        # Load Keyboard control register
    beq $s3, $zero, noKBD # If no key is pressed, skip reading
	
	move $t0, $s7
	move $t1, $s6
	PUSH.B($s3)
    jal HandleKBD
    
    PUSH.W($t0)
    PUSH.W($t1)
    PUSH.W($s1)
	jal __renderer__drawQuad
	
	PUSH.H($s7)
	PUSH.H($s6)
	PUSH.W($s4)
	jal __renderer__drawQuad
	
	jal __renderer__drawCall
noKBD:
    j gameLoop
	li $v0 10
	syscall
	

HandleKBD:
	POP.B($t4)    # ASCII
	PUSH.W($ra)
	beq $t4, 65,  KBD_A
	beq $t4, 68, KBD_D
	beq $t4, 87, KBD_W
	beq $t4, 83, KBD_S

KBD_A:
	addi $s7, $s7, -UNITS_PER_FRAME
	bgtz  $s7, Handled
	li $s7, 0
	j Handled
KBD_D:
	addi $s7, $s7, UNITS_PER_FRAME
	bltu $s7, SCREEN_WIDTH, Handled
	rem $s7, $s7, SCREEN_WIDTH
	j Handled
KBD_W:
	addi $s6, $s6, -UNITS_PER_FRAME
	bgtz  $s6, Handled
	li $s6, 0
	j Handled
KBD_S:
	addi $s6, $s6, UNITS_PER_FRAME
	bltu $s6, SCREEN_HEIGHT, Handled
	rem $s6, $s6, SCREEN_HEIGHT
Handled:
	POP.W($ra)
	jr $ra

.include "renderer.asm"
