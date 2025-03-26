.include "macros/stack.s"
.include "macros/syscalls.s"

.eqv SCREEN_WIDTH 512
.eqv SCREEN_HEIGHT 256
.eqv BITMAP_DISPLAY_BASE 0x10080000
.eqv RES_ARRAY 0x100E0000

.eqv KEYBOARD_MMIO 0xFFFF0000
.eqv REMOVE_LIST 0x10030000

.eqv VEL_X 3
.eqv VEL_Y 3
.eqv EnemyVel 1

.data
.include "sprites/germany.spr"
.include "sprites/bg.spr"
.include "sprites/bullet.spr"
.include "sprites/enemy.spr"
.include "sprites/player.spr"

playerVelX: .word VEL_X
playerVelY: .word VEL_Y

# 16 B
entitiesArray: .word


bullet_debug: .asciiz "Bulley awpkáek´d\n\n"
entt_debug: .asciiz "Entity count: "

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
	quad: .asciiz "Quad tree: "
	newline: .asciiz "\n"
    space:   .asciiz "  "
    
    	lose: .asciiz "The fastest way to check Axis-Aligned Bounding Box (AABB) collision is to compare the edges of the two rectangles. Given two entities with (x1, y1, w1, h1) and (x2, y2, w2, h2), the collision condition is:\n\n\n"
.text
main:
	move $s1, $gp
	li $s0, KEYBOARD_MMIO         # Load base address of Keyboard MMIO
    jal Physics__QuadTree__init
    
	PUSH.W($s1)
	PUSHI.W(100)
	PUSHI.W(100)
	jal __create_player
	
	PUSH.W($s1)
	PUSHI.W(300)
	PUSHI.W(0)
	jal __create_enemy
	jal __renderer__drawCall

	
gameLoop:
	lb $t0, 16($s0)
	beq $t0, $zero, noRelease # If no key is pressed, skip reading
	PUSH.W($t0)
	PUSH.W($s1)
	jal HandleRelease
	
noRelease:	
    lb $t0, 0($s0)          # Load Keyboard control register
    beq $t0, $zero, noPress # If no key is pressed, skip reading
    PUSH.W($t0)
    PUSH.W($s1)
	jal HandlePress
	
noPress:
	PUSH.W($s1)
	jal __update_entities
	
	jal __renderer__drawCall
	sleepI(16)
  	j gameLoop
	li $v0 10
	syscall
	
#(ent)
__append_remove:
	POP.W($t0)
	li $t3, REMOVE_LIST
	lw $t1, ($t3)
	addi $t2, $t1, 1
	sll $t4, $t2, 2
	add $t5, $t3, $t4
	sw $t0, ($t5)
	addi $t2, $t1, 1
	sw $t2, ($t3)
	jr $ra
	
__cleanup:
	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)

	li $s3, REMOVE_LIST
	move $s2, $s3
	lw $s1, ($s3)
	
	li $s0, 0
__cleanup_for:
	beq $s0, $s1, __cleanup_forEnd
	
	addi $s3, $s3, 4
	lw $t2, ($s3)
	lw $t4, ($t2)
	PUSH.W($t4)
	jal __renderer__remove
	
	lw $t2, ($s3)
	PUSH.W($t2)
	jal __entity__remove
	
	
	addi $s0, $s0, 1
	j __cleanup_for
__cleanup_forEnd:
	sw $zero ($s2)
	printStringI(entt_debug)
	lw $t0, ($gp)
	printInt($t0)
	printCharI('\n')
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra	
# (entArr, x: WORD, y: WORD) -> void
__create_player:
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)

	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	move $s3, $t3
	move $s4, $t4

	la $s3, SPR_PLAYER
	PUSH.H($s1)				# x
  	PUSH.H($s2)				# y
	PUSHI.H(50)             # width
  	PUSHI.H(50)             # height
  	PUSHI.H(0)              # rot
  	PUSH.W($s3)             # spr
	jal __renderer__drawSpr
	POP.W($s4)
	
	PUSH.W($s4)
	jal Physics__QuadTree__insert
	
	la $t9, __update_stop
	PUSH.W($s0)
	PUSH.W($s4)
	PUSHI.W(0)
	PUSHI.W(0)
	PUSH.W($t9)
	PUSHI.W(0)
	jal __append_entities
	
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra

# (entArr, x: WORD, y: WORD) -> void
__create_bullet:
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)

	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	printInt($t1)
	printCharI(',')
	printInt($t2)
	printCharI('\n')
	printStringI(bullet_debug)
	
	move $s0, $t0
	move $s1, $t2
	move $s2, $t1
	move $s3, $t3
	move $s4, $t4

	la $s3, SPR_BULLET
	PUSH.H($s1)				# x
  	PUSH.H($s2)				# y
	PUSHI.H(25)             # width
  	PUSHI.H(25)             # height
  	PUSHI.H(0)              # rot
  	PUSH.W($s3)             # spr
	jal __renderer__drawSpr
	POP.W($s4)
	
	PUSH.W($s4)
	jal Physics__QuadTree__insert
	
	la $t9, __remove_self
	PUSH.W($s0)
	PUSH.W($s4)
	PUSHI.W(-5)
	PUSHI.W(0)
	PUSH.W($t9)
	PUSHI.W(0)
	jal __append_entities
	
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra

__entity__remove:
    POP.W($t0)         # Entity to remove

    lw $t6, ($gp)      # Load entity count
    addi $t8, $t6, -1  # Last valid index

    beqz $t6, __entity__remove_done  # If no entities left, return

    sll $t7, $t8, 4    # Correct index shift (each entity is 16 bytes)
    add $t9, $gp, $t7  # Address of last entity

    # Copy last entity over the one being removed
    lw $t1, 4($t9)
    sw $t1, ($t0)
    lh $t2, 8($t9)
    sh $t2, 4($t0)
    lh $t3, 10($t9)
    sh $t3, 6($t0)
    lw $t4, 12($t9)
    sw $t4, 8($t0)
    lw $t5, 16($t9)
    sw $t5, 12($t0)

    # Decrease entity count
    sw $t8, ($gp)
    
__entity__remove_done:
    jr $ra

__check_colission:
	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)

	li $s0, RES_ARRAY
	lw $s4, 4($gp)
	PUSH.W($s4)
	PUSH.W($s0)
	jal Physics__QuadTree__search

	lw $s1, ($s0)
	li $s2, 0
__check_colission_for:
	beq $s2, $s1, __check_colission_forEnd
	
	addi $s0, $s0, 4
	lw $t3, ($s0)

	beq $t3, $s4, __check_colission_forContinue

	printStringI(quad)
	lh $a0, 0($s4)
	lh $a1, 2($s4)
	lh $a2, 4($s4)
	lh $a3, 6($s4)
	PUSH.W($a0)
	PUSH.W($a1)
	PUSH.W($a2)
	PUSH.W($a3)
	
	lh $a0, 0($t3)
	lh $a1, 2($t3)
	lh $a2, 4($t3)
	lh $a3, 6($t3)
	
	jal AABB_Collision
	beqz $v0, __check_colission_forContinue
	
__check_colission_forContinue:
	printCharI('\n')
	addi $s2, $s2, 1
	j __check_colission_for
__check_colission_forEnd:
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
		
	jr $ra

AABB_Collision:
    # Load x2, y2, w2, h2
    POP.W($t3)  # x2
    POP.W($t2)  # y2
    POP.W($t1)  # w2
    POP.W($t0)  # h2

    # Check x1 + w1 > x2
    add  $t4, $a0, $a2   # x1 + w1
    ble  $t4, $t0, NoCollision  # If x1 + w1 <= x2, no collision

    # Check x1 < x2 + w2
    add  $t5, $t0, $t2   # x2 + w2
    bge  $a0, $t5, NoCollision  # If x1 >= x2 + w2, no collision

    # Check y1 + h1 > y2
    add  $t6, $a1, $a3   # y1 + h1
    ble  $t6, $t1, NoCollision  # If y1 + h1 <= y2, no collision

    # Check y1 < y2 + h2
    add  $t7, $t1, $t3   # y2 + h2
    bge  $a1, $t7, NoCollision  # If y1 >= y2 + h2, no collision

    # Collision detected
    li   $v0, 1
    jr   $ra

NoCollision:
    li   $v0, 0
    jr   $ra

#(entity, velx, vely)
__remove_self:
	printCharI('-')
	POP.W($t3)	
	POP.W($t2)	
	POP.W($t1)
	POP.W($t0)
	
	PUSH.W($ra)
	
	PUSH.W($s0)
	
	move $s0, $t3
	
	printHex($s0)
	PUSH.W($s0)
	jal __append_remove
	
	printCharI('\n')
	POP.W($s0)
	
	POP.W($ra)
	
	PUSHI.W(0)
	PUSHI.W(0)
	jr $ra

# (entArr, x: WORD, y: WORD) -> void
__create_enemy:
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)

	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	move $s3, $t3
	move $s4, $t4

	la $s3, SPR_ENEMY
	PUSH.H($s1)				# x
  	PUSH.H($s2)				# y
	PUSHI.H(50)             # width
  	PUSHI.H(50)             # height
  	PUSHI.H(0)              # rot
  	PUSH.W($s3)             # spr
	jal __renderer__drawSpr
	POP.W($s4)
	
	PUSH.W($s4)
	jal Physics__QuadTree__insert
	
	la $t9, __update_bounce
	PUSH.W($s0)
	PUSH.W($s4)
	PUSHI.W(0)
	PUSHI.W(EnemyVel)
	PUSH.W($t9)
	la $t9, __enemy_spawn
	PUSH.W($t9)
	jal __append_entities
	
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra

# (entArr, ent)
__enemy_spawn:
	POP.W($t0)
	POP.W($t6)
	
	PUSH.W($ra)
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	randRange($t4, 0, 1000)
	
	bge $t4, 20, __enemy_spawn__return
	PUSH.W($t6)
	addi $t1, $t1, -20
	PUSH.W($t1)
	PUSH.W($t2)
	jal __create_bullet
	
__enemy_spawn__return:
	POP.W($ra)
	jr $ra

__append_entities:
	POP.W($t5)
	POP.W($t4)
	POP.W($t3)
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)
	
	lw $t6, ($t0)
	sll $t7, $t6, 4
	add $t9, $t0, $t7
	sw $t1, 4($t9)
	sh $t2, 8($t9)
	sh $t3, 10($t9)
	sw $t4, 12($t9)
	sw $t5, 16($t9)
	
		
	addi $t6, $t6, 1
	sw $t6, ($t0)


	jr $ra

__update_entities:
	POP.W($t0)
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	move $s0, $t0
	move $s4, $s0
	
	lw $s1, ($s0)
	addi $s0, $s0, 4
	
	jal Physics__QuadTree__clear
	
	li $s2, 0
__update_entities_for:
	beq $s2, $s1, __update_entities_forEnd
	
	lw $t2, 0($s0)
	# PUSH.W($t2)
	# jal Physics__QuadTree__delete
	
	lw $t2, 0($s0)
	lh $t3, 4($s0)
	lh $t4, 6($s0)
	lw $t5, 8($s0)
	PUSH.W($t2)
	PUSH.W($t3)
	PUSH.W($t4)
	PUSH.W($t5)
	PUSH.W($s0)
	jal __update_pos
	POP.W($t9)
	POP.W($t8)
	
	sh $t8, 4($s0)
	sh $t9, 6($s0)
	
	lw $t2, 0($s0)
	PUSH.W($t2)
	jal Physics__QuadTree__insert
	
	lw $t6, 12($s0)
	beqz $t6, __update_entities_skip
	
	lw $t2, 0($s0)
	PUSH.W($s4)
	PUSH.W($t2)
	jalr $t6
__update_entities_skip:
	addi $s2, $s2, 1
	addi $s0, $s0, 16
	j __update_entities_for
__update_entities_forEnd:

	jal __cleanup
	jal __check_colission
	
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra


__update_bounce:
	printCharI('~')
	printCharI('\n')
	POP.W($0)
	POP.W($t2)	
	POP.W($t1)	
	POP.W($t0)	
	
	#sub $t1, $0, $t1
	#sub $t2, $0, $t2
	
	neg $t1, $t1
	neg $t2, $t2
	
	#PUSH.W($t1)
	#PUSH.W($t2)
	PUSH.W($t1)
	PUSH.W($t2)
	jr $ra
	

#(entity, velx, vely)
__update_stop:
	printCharI('~')
	printCharI('\n')
	POP.W($t2)	
	POP.W($t1)	
	POP.W($t0)
	POP.W($0)
	
	

	PUSHI.W(0)
	PUSHI.W(0)
	jr $ra

# (ent: Entity, velx: WORD, vely: WORD, corect: func) -> WORD, WORD
__update_pos:
	POP.W($t4)
	POP.W($t3)
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)
	
	PUSH.W($ra)
	
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	PUSH.W($s5)
	PUSH.W($s6)
	PUSH.W($s7)
	
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	move $s3, $t3
	move $k1, $t4
	
	lh $s4, 2($s0)
	lh $s5, 0($s0)
	
	add $s6, $s4, $s1
	add $s7, $s5, $s2
	printCharI('k')
	printCharI(' ')
	printHex($k1)
	printCharI('|')
	printCharI('x')
	printCharI(' ')
	printInt($s1)
	printCharI('|')
	printCharI('y')
	printCharI(' ')
	printInt($s2)
	printCharI('\n')
	printCharI('x')
	printCharI(' ')
	printInt($s6)
	printCharI('|')
	printCharI('y')
	printCharI(' ')
	printInt($s7)
	printCharI('\n')
	
	move $a2, $s1
	move $a3, $s2
	
	li $t9, SCREEN_WIDTH
	lh $t8, 4($s0)
	li $t7, 64
	sub $t8, $t7, $t8
	sub $t9, $t9, $t8
	
	bge $s6, $t9, __update_pos_skipx_bounce
	bltz $s6, __update_pos_skipx_bounce
	j __update_pos_skipx
__update_pos_skipx_bounce:
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($k1)
	jalr $s3
	POP.W($0)
	POP.W($a2)
	add $s6, $s4, $a2
__update_pos_skipx:
	sh $s6, 2($s0)
	
	
	li $t9, SCREEN_HEIGHT
	lh $t8, 6($s0)
	li $t7, 64
	sub $t8, $t7, $t8
	sub $t9, $t9, $t8
	
	bge $s7, $t9, __update_pos_skipy_bounce
	bltz $s7, __update_pos_skipy_bounce
	j __update_pos_skipy
__update_pos_skipy_bounce:
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($k1)
	jalr $s3
	POP.W($a3)
	POP.W($0)
	add $s7, $s5, $a3
__update_pos_skipy:
	sh $s7, 0($s0)
	
	printCharI('x')
	printCharI(' ')
	printInt($a2)
	printCharI('|')
	printCharI('y')
	printCharI(' ')
	printInt($a3)
	printCharI('|')
	printCharI('\n')
	printCharI('\n')

	POP.W($s7)
	POP.W($s6)
	POP.W($s5)
	POP.W($s4)	
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	
	PUSH.W($a2)
	PUSH.W($a3)
	jr $ra

HandlePress:
	POP.W($t9)
	POP.W($t0)
	
	li $t8, KEYBOARD_MMIO
	add $t1, $t8, 1
	
	lh $t4, 8($t9)
	lh $t5, 10($t9)
	
	lw $t6, playerVelX
	lw $t7, playerVelY
	sub $a0, $0, $t6
	sub $a1, $0, $t7
HandlePress__for:
	beqz $t0, HandlePress__forEnd
	lb $t2, ($t1)
	
	# WASD and Arrow movement
	beq $t2, 65, HandlePress__KBD_A
	beq $t2, 37, HandlePress__KBD_A
	beq $t2, 68, HandlePress__KBD_D
	beq $t2, 39, HandlePress__KBD_D
	beq $t2, 87, HandlePress__KBD_W
	beq $t2, 38, HandlePress__KBD_W
	beq $t2, 83, HandlePress__KBD_S
	beq $t2, 40, HandlePress__KBD_S
	beq $t2, 32, HandlePress__KBD_SPACE
	j HandlePress__Handled

HandlePress__KBD_A:
	
	beq  $t4, $a0 HandlePress__Handled
	add $t4, $t4, $a0
	j HandlePress__Handled
HandlePress__KBD_D:
	beq  $t4, $t6, HandlePress__Handled
	add $t4, $t4, $t6
	j HandlePress__Handled
HandlePress__KBD_W:
	beq  $t5, $a1, HandlePress__Handled
	add $t5, $t5, $a1
	j HandlePress__Handled
HandlePress__KBD_S:
	beq  $t5, $t7, HandlePress__Handled
	add $t5, $t5, $t7
	j HandlePress__Handled
	
HandlePress__KBD_SPACE:
	li $a3, 1
	sw $a3, playerVelY
	sw $a3, playerVelX
	j HandlePress__Handled
HandlePress__Handled:

	subi $t0, $t0, 1
	addi $t1, $t1, 1

	j HandlePress__for
HandlePress__forEnd:
	sb $0, ($t8)
	
	sh $t4, 8($t9)
	sh $t5, 10($t9)
	
	jr $ra

HandleRelease:
	POP.W($t9)
	POP.W($t0)
	
	li $t8, KEYBOARD_MMIO
	add $t1, $t8, 0x11
	
	lh $t4, 8($t9)
	lh $t5, 10($t9)
	
	lw $t6, playerVelX
	lw $t7, playerVelY
	
	sub $a0, $0, $t6
	sub $a1, $0, $t7
HandleRelease__for:
	beqz $t0, HandleRelease__forEnd
	lb $t2, ($t1)
	
	beq $t2, 65, HandleRelease__KBD_A
	beq $t2, 37, HandleRelease__KBD_A
	beq $t2, 68, HandleRelease__KBD_D
	beq $t2, 39, HandleRelease__KBD_D
	beq $t2, 87, HandleRelease__KBD_W
	beq $t2, 38, HandleRelease__KBD_W
	beq $t2, 83, HandleRelease__KBD_S
	beq $t2, 40, HandleRelease__KBD_S
	beq $t2, 32, HandleRelease__KBD_SPACE
	
	j HandleRelease__Handled
HandleRelease__KBD_A:
	add $t4, $t4, $t6
	j HandleRelease__Handled
HandleRelease__KBD_D:
	add $t4, $t4, $a0
	j HandleRelease__Handled
HandleRelease__KBD_W:
	add $t5, $t5, $t7
	j HandleRelease__Handled
HandleRelease__KBD_S:
	add $t5, $t5, $a1
	j HandleRelease__Handled
HandleRelease__KBD_SPACE:
	li $a3, 3
	sw $a3, playerVelY
	sw $a3, playerVelX
	j HandlePress__Handled
HandleRelease__Handled:

	subi $t0, $t0, 1
	addi $t1, $t1, 1

	j HandleRelease__for
HandleRelease__forEnd:
	sb $0, 16($t8)
	
	sh $t4, 8($t9)
	sh $t5, 10($t9)
	
	jr $ra




.include "renderer.asm"
.include "physics.asm"
