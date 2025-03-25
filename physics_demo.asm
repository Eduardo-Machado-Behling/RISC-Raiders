.include "macros/stack.s"
.include "macros/syscalls.s"
.include "macros/defines.s"

.data
	array_res: .space 100000

	debug_insert: .asciiz "Inserting rect: "
	debug_insert_ret0.0: .asciiz "RETURN: because node #"
	debug_insert_ret1: .asciiz "RETURN: put on node #"
	debug_insert_ret2: .asciiz "INFO: Turned into leaf node\n"
	debug_insert_ret3: .asciiz "RETURN: calling recursive on node #"
	debug_insert_ret4: .asciiz "INFO: Foward Called"
	debug_insert_ret5: .asciiz "INFO: Forward  called with parent = "
	debug_insert_ret6: .asciiz "INFO: added"
	debug_insert_ret8: .asciiz "INFO: skipped"
	debug_insert_ret7: .asciiz "INFO: contains - "
	
	debug_search_0: .asciiz "INFO: Forward  called with parent = "
	debug_search_1: .asciiz "INFO: added"
	debug_search_2: .asciiz "INFO: contains - "
	
	newline: .asciiz "\n"
    space:   .asciiz "  "

.eqv KEYBOARD_MMIO 0xFFFF0000
.eqv RES_ARRAY 0x100E0000

.eqv VEL_X 250
.eqv VEL_Y 200

.text:
	li $s7, 0
	jal Physics__QuadTree__init
loop:
	beq $s7, 100, loopEnd
	
	printInt($s7)
	printCharI('\n')
	randRange($s3, 0, 50)
	randRange($s4, 0, 50)
	randRange($s0, 0, SCREEN_WIDTH)
	randRange($s1, 0, SCREEN_HEIGHT)
	PUSH.H($s0)
	PUSH.H($s1)
	PUSH.H($s3)
	PUSH.H($s4)
	jal create_hitbox
	POP.W($s6)
	
	PUSH.W($s6)
	jal Physics__QuadTree__insert
	
	la $t0, array_res
	PUSH.W($s6)
	PUSH.W($t0)
	jal Physics__QuadTree__search
	printCharI('P')
	printCharI(' ')
	printInt($s3)
	printCharI('x')
	printInt($s4)
	printCharI('\n')
	
	jal Print
	sw $zero, array_res
	
	addi $s7, $s7, 1
	ble $s7, 50, loop
	PUSH.W($s6)
	jal Physics__QuadTree__delete
	j loop
loopEnd:

	exit()

Print:
	la $t0, array_res
	lw $t1, ($t0)

	li $t2, 0
print_for:
	beq $t2, $t1, print_forEnd
	
	addi $t0, $t0, 4
	lw $t4, ($t0)
	lh $t5, ($t4)
	lh $t6, 2($t4)
	
	printInt($t2)
	printCharI(':')
	printHex($t4)
	printCharI(' ')
	printInt($t5)
	printCharI('x')
	printInt($t6)
	printCharI('\n')
	
	addi $t2, $t2, 1
	j print_for
print_forEnd:
	jr $ra

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
	
	
