.include "macros/stack.s"
.include "macros/syscalls.s"
.include "macros/defines.s"

.data
	debug_insert: .asciiz "Inserting rect: "
	debug_insert_ret0.0: .asciiz "RETURN: because node #"
	debug_insert_ret1: .asciiz "RETURN: put on node #"
	debug_insert_ret2: .asciiz "INFO: Turned into leaf node\n"
	debug_insert_ret3: .asciiz "RETURN: calling recursive on node #"
	debug_insert_ret4: .asciiz "INFO: Foward Called"
	debug_insert_ret5: .asciiz "INFO: Forward  called with parent = "
	debug_insert_ret6: .asciiz "INFO: added"
	debug_insert_ret7: .asciiz "INFO: contains - "

.eqv KEYBOARD_MMIO 0xFFFF0000

.eqv VEL_X 250
.eqv VEL_Y 200

.text:
	li $s7, 0
	jal Physics__QuadTree__init
loop:
	beq $s7, 100, loopEnd
	
	printInt($s7)
	printCharI('\n')
	randRange($t3, 0, 200)
	randRange($t4, 0, 200)
	randRange($t0, 0, SCREEN_WIDTH)
	randRange($t1, 0, SCREEN_HEIGHT)
	PUSH.H($t1)
	PUSH.H($t0)
	PUSH.H($t3)
	PUSH.H($t4)
	jal create_hitbox
	POP.W($s0)
	
	PUSH.W($s0)
	jal Physics__QuadTree__insert
	
	addi $s7, $s7, 1
	j loop
loopEnd:
	exit()
	

create_hitbox:
	POP.H($t4)   # h
	POP.H($t3)   # w
	POP.H($t2)   # y
	POP.H($t1)   # x
	
	lw $t0, ($gp)
	addi $t5, $t0, 1
	sw $t5, ($gp)
	
	
	sll $t0, $t0, 3
	addi $t0, $t0, 4
	add $t0, $t0, $gp
	
	sh $t1, ($t0)
	sh $t2, 2($t0)
	sh $t3, 4($t0)
	sh $t4, 6($t0)
	
	PUSH.W($t0)
	jr $ra

.include "physics_clean.asm"
	
	
