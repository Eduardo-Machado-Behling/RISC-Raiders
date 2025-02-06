
#TODO: draw sequencial sprite of using drawQuad
__renderer__drawSpr:
	POP.W($t4)    # color
	POP.H($t3)    # heght
	POP.H($t2)    # width
	POP.H($t1)    # y
	POP.H($t0)    # x
	PUSH.W($ra)

	li $t7, BITMAP_DISPLAY_BASE
	li $t5, SCREEN_WIDTH
	sll $t5, $t5, 2
	
	mul $t8, $t5, $t1
	
	add $t7, $t7, $t8
	
	add $t2, $t2, $t0
	add $t3, $t3, $t1
clampY:
	ble $t2, SCREEN_WIDTH, yLoop
	li $t2, SCREEN_WIDTH
yLoop:
	beq $t1, $t3, yLoopEnd
	
    move $t6, $t0
    sll $t9, $t6, 2
	add $t9, $t9, $t7
xLoop:
	beq $t6, $t2, xLoopEnd
	
	sw $t4, ($t9)
	
	addi $t6, $t6, 1
	addi $t9, $t9, 4
	j xLoop
xLoopEnd:
	
	addi $t1, $t1, 1
	add $t7, $t7, $t5

	j yLoop
yLoopEnd:
	POP.W($ra)
	jr $ra
	
 __renderer__drawCall:
	li $t9, BITMAP_DISPLAY_BASE
	sw $t9, -4($t9)
	
	jr $ra

__renderer__drawQuad:
	POP.W($t4)    # sprite
	POP.W($t1)    # y
	POP.W($t0)    # x

	li $t7, BITMAP_DISPLAY_BASE
	li $t5, SCREEN_WIDTH
	
	addi $t3, $t1, QUAD_SIZE
	
	sll $t5, $t5, 2
	mul $t8, $t5, $t1
	add $t7, $t7, $t8
	sll $t8, $t0, 2
	add $t7, $t7, $t8
	
	ble $t3, SCREEN_HEIGHT, __renderer_drawQuad_loop
	li $t3, SCREEN_HEIGHT
	

__renderer_drawQuad_loop:
	beq $t1, $t3, __renderer_drawQuad_loopEnd
	move $t9, $t7

	# unrolled loop for perfomance, I ain't that dumb (made in Python)
	lw $t2, ($t4)
	
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip0
	
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip0:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip1
	sw $t2, ($t9)
	
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip1:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip2
	sw  $t2, ($t9)

	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip2:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip3
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip3:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip4
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip4:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip5
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip5:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip6
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip6:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip7
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip7:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip8
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip8:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip9
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip9:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip10
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip10:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip11
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip11:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip12
	sw $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip12:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip13
	sw  $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip13:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip14
	sw  $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
    
__renderer_drawQuad_skip14:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip15
	sw  $t2, ($t9)
	addi $t9, $t9, 4
	addi $t4, $t4, 4
	
__renderer_drawQuad_skip15:
	lw $t2, ($t4)
	andi $t8, $t2, 0xff000000
	beqz $t8, __renderer_drawQuad_skip15
	sw  $t2, ($t9)

	addi $t1, $t1, 1
	add $t7, $t7, $t5

	j __renderer_drawQuad_loop
__renderer_drawQuad_loopEnd:
	jr $ra
