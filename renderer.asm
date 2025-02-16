
#TODO: draw sequencial sprite of using drawQuad
__renderer__drawQuad:
	POP.W($t5)    # color
	POP.H($t4)	  # rotation
	POP.H($t3)    # heght
	POP.H($t2)    # width
	POP.H($t1)    # y
	POP.H($t0)    # x

	li $t7, BITMAP_DISPLAY_BASE
	lw $t9, ($t7)
	
	sll $t6, $t9, 4
	add $t6, $t6, $t7
	addi $t6, $t6, 4
	
	sh $t1,  ($t6)
	sh $t0, 2($t6)
	sh $t3, 4($t6)
	sh $t2, 6($t6)
	sh $t4, 8($t6)
	sh $0 , 10($t6)
	sw $t5, 12($t6)
	
	addi $t9, $t9, 1
	sw $t9 ($t7)
	
	PUSH.W($t6)
	jr $ra
	
__renderer__drawSpr:
	POP.W($t5)    # spr_addr (use la)
	POP.H($t4)	  # rotation
	POP.H($t3)    # heght
	POP.H($t2)    # width
	POP.H($t1)    # y
	POP.H($t0)    # x

	li $t7, BITMAP_DISPLAY_BASE
	lw $t9, ($t7)
	
	sll $t6, $t9, 4
	add $t6, $t6, $t7
	addi $t6, $t6, 4
	
	sh $t1,  ($t6)
	sh $t0, 2($t6)
	sh $t3, 4($t6)
	sh $t2, 6($t6)
	sh $t4, 8($t6)
	
	li $t8, 1
	sh $t8, 10($t6)
	
	sw $t5, 12($t6)
	
	addi $t9, $t9, 1
	sw $t9 ($t7)
	
	PUSH.W($t6)
	jr $ra


__renderer__drawCall:
	li $t7, BITMAP_DISPLAY_BASE
	sw $zero, -4($t7)
	jr $ra