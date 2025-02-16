.eqv QUAD_TREE_LOCATION 0x100C0000
.eqv QUAD_TREE_MAX_DEPTH 8

.eqv QUAD_TREE_THREESHOLD 7
.eqv QUAD_TREE_THREESHOLD_OVERALL 8
.eqv QUAD_TREE_SHIFT 5

__physics__QuadTree__insert:
	POP.W($t0) # addr of collider
	PUSH.W($ra)
	PUSH.W($zero)
	PUSH.W($t0)
	
	jal __physics__QuadTree__implInsert
	
	POP.W($ra)
	jr $ra
	

__physics__QuadTree__implInsert:
	POP.W($t1)  # addr of collider
	POP.W($t0)  # parent
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	PUSH.W($s5)


	move $s5, $t0
	move $s0, $t1
	
	lh $s1, ($s0)
	lh $s2, 2($s0)
	lh $s3, 4($s0)
	lh $s4, 6($s0)
	
	add $s3, $s3, $s1
	add $s4, $s4, $s2
	
	PUSH.W($s5)   # parent
	PUSH.W($s2)     # y
	PUSH.W($s1)     # x
	PUSH.W($s0)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	
	PUSH.W($s5)   # parent
	PUSH.W($s2)     # y
	PUSH.W($s3)     # x
	PUSH.W($s0)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	
	PUSH.W($s5)   # parent
	PUSH.W($s4)     # y
	PUSH.W($s1)     # x
	PUSH.W($s0)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	
	PUSH.W($s5)   # parent
	PUSH.W($s4)     # y
	PUSH.W($s3)     # x
	PUSH.W($s0)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	
	POP.W($s5)
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra

__physics__QuadTree__insertRecursive:
	POP.W($t3)   # addr of collider
	POP.W($t2)   # x
	POP.W($t1)   # y
	POP.W($t0)   # index (int)
	
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
	
	printStringI(debug_insert)
	printInt($s2)
	printCharI('|')
	printInt($s1)
	printCharI('|')
	printInt($s0)
	printCharI('|')
	printHex($s3)
	printCharI('\n')
	
	li $s4, QUAD_TREE_LOCATION
	sll $t1, $s0, QUAD_TREE_SHIFT
	add $s5, $t1, $s4
	
	lw $s6, ($s5)
	
	beq $s6, 0xffff, __physics__QuadTree__insertRecursiveNoSpace
	PUSH.W($s5) # addrNode
	PUSH.W($s6) # sizeNode
	PUSH.W($s3) # addrCollider
	jal __physics__QuadTree__nodeHas
	POP.W($t4)
	beq $t4, 1, __physics__QuadTree__insertRecursiveSkipHas
	beq $s6, QUAD_TREE_THREESHOLD, __physics__QuadTree__insertRecursiveNoSpace
	
	addi $t8, $s6, 1
	sll $t9, $t8, 2
	add $t9, $t9, $s5
	sw $s3, ($t9)
	sw $t8, ($s5)
	
	printStringI(debug_insert_ret0.0)
	printInt($s0)
	printStringI(debug_insert_ret0.1)
	printInt($s6)
	printCharI('\n')
	j __physics__QuadTree__insertRecursiveReturn
__physics__QuadTree__insertRecursiveSkipHas:
	printStringI(debug_insert_ret1)
	printInt($s0)
	printCharI('\n')
	j __physics__QuadTree__insertRecursiveReturn
	
__physics__QuadTree__insertRecursiveNoSpace:
	li $s4, 1
__physics__QuadTree__insertRecursiveFor:
	beq $s4, 5, __physics__QuadTree__insertRecursiveForEnd
	add $t9, $s0, $s4

	PUSH.W($s2)   # x
	PUSH.W($s1)   # y
	PUSH.W($t9)   # i
	jal __physics__QuadTree__contains
	POP.W($t2)

	beqz $t2, __physics__QuadTree__insertRecursiveSkip
	beq $s6, 0xffff, __physics__QuadTree__insertRecursiveForInnerEnd
	
	li $t4, 0xffff
	sw $t4, ($s5)
	printStringI(debug_insert_ret2)
	printInt($s0)
	printCharI('\n')
	li $s7, 0
__physics__QuadTree__insertRecursiveForInner:
	beq $s7, $s6, __physics__QuadTree__insertRecursiveForInnerEnd
	
	addi $t7, $s7, 1
	sll $t7, $t7, 2
	add $t7, $t7, $s5

	lw $t7, ($t7)
	
	beq $t7, $s3, __physics__QuadTree__insertRecursiveForInnerSkip
	
	PUSH.W($s0)
	PUSH.W($t7)
	jal __physics__QuadTree__implInsert

__physics__QuadTree__insertRecursiveForInnerSkip:
	addi $s7, $s7, 1
	j __physics__QuadTree__insertRecursiveForInner
__physics__QuadTree__insertRecursiveForInnerEnd:
	sll $t0, $s0, 2
	add $t0, $t0, $s4
	
	printStringI(debug_insert_ret3)
	printInt($t0)
	printCharI('\n')
	
	PUSH.W($t0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	jal __physics__QuadTree__insertRecursive
	j __physics__QuadTree__insertRecursiveReturn

__physics__QuadTree__insertRecursiveSkip:
	addi $s4, $s4, 1
	j __physics__QuadTree__insertRecursiveFor
__physics__QuadTree__insertRecursiveForEnd:
__physics__QuadTree__insertRecursiveReturn:
	POP.W($s7)
	POP.W($s6)
	POP.W($s5)
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	printCharI('\n')
	printCharI('\n')
	jr $ra
	
__physics__QuadTree__contains:
	POP.W($t0)   # i
	POP.W($t3)   # y
	POP.W($t2)   # x
	
	subi $t0, $t0, 1        #$t0 = i - 1
	srl $t1, $t0, 2         #$t1 = P
	li $t7, SCREEN_WIDTH
	srlv $t7, $t7, $t1      #$t7 = W(p)
	
	li $t8, SCREEN_HEIGHT   #$t8 = H(p)
	srlv $t8, $t8, $t1
	
	srl $t4, $t7, 1
	mul $t4, $t4, $t0
	div $t4, $t7       #$t4 = startBound x (Box)
	mfhi $t4
	
	srl $t5, $t8, 1
	srl $t9, $t0, 1
	mul $t5, $t9, $t5
	div $t5, $t8       #$t4 = startBound x (Box)
	mfhi $t5
	
	srl $t9, $t7, 1
	add $t6, $t9, $t4  		#$t6 = endBound x (Box)
	srl $t9, $t8, 1
	add $t9, $t9, $t5  		#$t9 = endBound y (Box)
	
	
	bleu $t2, $t4, __physics__QuadTree_notInBounds
	bgeu $t2, $t6, __physics__QuadTree_notInBounds
	bleu $t3, $t5, __physics__QuadTree_notInBounds
	bgeu $t3, $t9, __physics__QuadTree_notInBounds
	PUSHI.W(1)
	j __physics__QUADThree_notInBoundsEnd
__physics__QuadTree_notInBounds:
	PUSHI.W(0)
__physics__QUADThree_notInBoundsEnd:
	jr $ra


__physics__QuadTree__nodeHas:
	POP.W($t2)   # addr of collider
	POP.W($t1)   # nodeSize
	POP.W($t0)   # addr of Node
	
	li $t3, 0
__physics__QuadTree__nodeHasFor:
	beq $t1, $t3, __physics__QuadTree__nodeHasForEnd
	addi $t4, $t3, 1
	sll $t4, $t4, 2
	add $t4, $t4, $t0
	
	lw $t5, ($t4)
	bne $t5, $t2, __physics__QuadTree__nodeHasForIFSkip
	PUSHI.W(1)
	jr $ra
__physics__QuadTree__nodeHasForIFSkip:	
	addi $t3, $t3, 1
	j __physics__QuadTree__nodeHasFor
__physics__QuadTree__nodeHasForEnd:
	PUSHI.W(0)
	jr $ra
	
	


__physics__QuadTree__collides:

	jr $ra