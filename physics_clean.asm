.eqv QUAD_TREE_LOCATION 0x100C0000
.eqv QUAD_TREE_MAX_DEPTH 8

.eqv QUAD_TREE_THREESHOLD 7
.eqv QUAD_TREE_THREESHOLD_OVERALL 8
.eqv QUAD_TREE_SHIFT 5

__physics__QuadTree__remove:
	POP.W($t0)    # addr of collider
	
	PUSH.W($ra)
	
	lh $t1, ($t0)
	lh $t2, 2($t0)
	
	PUSH.W($zero) # parent
	PUSH.W($t1)   # x
	PUSH.W($t2)   # y
	PUSH.W($t0)   # addr Collider
	
	jal __physics__QuadTree__removeRecursive
	
	POP.W($ra)
	jr $ra

__physics__QuadTree__removeRecursive:
	POP.W($t3)   # addr of collider
	POP.W($t2)   # x
	POP.W($t1)   # y
	POP.W($t0)   # parent (int)
	
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
	
	PUSH.W($s2) # x
	PUSH.W($s1) # y
	PUSH.W($s0) # i
	jal __physics__QuadTree__contains
	POP.W($t0) # bool Contains
	beqz $t0, __physics__QuadTree__removeRecursiveReturn
	
	li $s4, QUAD_TREE_LOCATION
	sll $t1, $s0, QUAD_TREE_SHIFT
	add $s5, $t1, $s4
	lw $s6, ($s5)
	
	beq $s6, 0xffff, __physics__QuadTree__removeRecursive__isLeaf
	PUSH.W($s7)     # parent
	PUSH.W($s1)     # y
	PUSH.W($s2)     # x
	PUSH.W($s3)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	j __physics__QuadTree__removeRecursiveReturn
	
__physics__QuadTree__removeRecursive__isLeaf:
	PUSH.W($s7)    # parent
	PUSH.W($s3)    # collidar (addr)
	jal __physics__QuadTree__removeObject
__physics__QuadTree__removeRecursiveReturn:
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

__physics__QuadTree__insert:
	POP.W($t0)    # addr of collider
	
	PUSH.W($ra)
	
	lh $t1, ($t0)
	lh $t2, 2($t0)
	
	PUSH.W($zero) # parent
	PUSH.W($t1)   # x
	PUSH.W($t2)   # y
	PUSH.W($t0)   # addr Collider
	
	jal __physics__QuadTree__insertRecursive
	
	POP.W($ra)
	jr $ra
	

__physics__QuadTree__insertRecursive:
	POP.W($t3)   # addr of collider
	POP.W($t2)   # x
	POP.W($t1)   # y
	POP.W($t0)   # parent (int)
	
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
	
	PUSH.W($s2) # x
	PUSH.W($s1) # y
	PUSH.W($s0) # i
	jal __physics__QuadTree__contains
	POP.W($t0) # bool Contains
	
	beqz $t0, __physics__QuadTree__insertRecursiveReturn
	
	li $s4, QUAD_TREE_LOCATION
	sll $t1, $s0, QUAD_TREE_SHIFT
	add $s5, $t1, $s4
	lw $s6, ($s5)
	
	PUSH.W($s2)  # x
	PUSH.W($s1)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($s7)   # Quadrant
	
	printCharI('|')
	printInt($s6)
	printCharI('\n')
	
	bltu $s6, QUAD_TREE_THREESHOLD, __physics__QuadTree__insertRecursiveIF__isLeaf
	
	printCharI('^')
	printStringI(debug_insert_ret5)
	printInt($s0)
	printCharI('\n')
	PUSH.W($s0)    # parent
	jal __physics__QuadTree__fowardChildren
	
	sll $t0, $s0, 2
	addi $t0, $t0, 1
	add $t0, $t0, $s7
	
	PUSH.W($s7)     # parent
	PUSH.W($s1)     # y
	PUSH.W($s2)     # x
	PUSH.W($s3)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	j __physics__QuadTree__insertRecursiveReturn
	
__physics__QuadTree__insertRecursiveIF__isLeaf:
	PUSH.W($s3)    # parent
	PUSH.W($s7)    # parent
	jal __physics__QuadTree__addObject
	POP.W($t0)
	
	beqz $t0, __physics__QuadTree__insertRecursiveReturn

	
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



__physics__QuadTree__removeObject:
	POP.W($t0)  # parent (int)
	POP.W($t1)  # collidar (addr)
	
	li $t4, QUAD_TREE_LOCATION
	sll $t1, $t0, QUAD_TREE_SHIFT
	add $t4, $t1, $t4
	
	lw $t3 ($t4)
	addi $t3, $t3, -1
	sw $t3 ($t4)
	sll $t5, $t3, 2
	add $t5, $t5, $t4
	lw $t6, ($t5)
	li $t7, 0
	
__physics__QuadTree__removeObject__For:
	addi $t4, $t4, 4
	beq $t7, $t3, __physics__QuadTree__removeObject__ForEnd
	
	lw $t9, ($t4)
	bne $t9, $t1, __physics__QuadTree__removeObject__NotEqual
	sw $t6 ($t4)
	j __physics__QuadTree__removeObject__Return

__physics__QuadTree__removeObject__NotEqual:
	addi $t7, $t7, 1
	j __physics__QuadTree__removeObject__For
__physics__QuadTree__removeObject__ForEnd:
	
__physics__QuadTree__removeObject__Return:
	jr $ra



# returns: 1 WORD -> [Error = 1, Success = 0]
__physics__QuadTree__addObject:
	POP.W($t0)  # parent (int)
	POP.W($t1)  # Object  (addr)
	
	li $t4, QUAD_TREE_LOCATION
	sll $t8, $t0, QUAD_TREE_SHIFT
	add $t4, $t8, $t4
	
	lw $t3 ($t4)
	addi $t3, $t3, 1
	sw $t3 ($t4)
	
	beq $t3, QUAD_TREE_THREESHOLD, __physics__QuadTree__addObject__Fail
	sll $t5, $t3, 2
	add $t5, $t5, $t4
	sw $t1, ($t5)
	
	PUSHI.W(0)
	jr $ra

__physics__QuadTree__addObject__Fail:
	PUSHI.W(1)
	jr $ra



__physics__QuadTree__fowardChildren:
	POP.W($t0)    # parent
	
	printStringI(debug_insert_ret5)
	printInt($t0)
	printCharI('\n')
	
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
	
	li $t0, QUAD_TREE_LOCATION
	sll $t1, $s0, QUAD_TREE_SHIFT
	add $s5, $t1, $t0

	lw $s1, ($s5)
	li $s2, 0
	
__physics__QuadTree__fowardChildren__For:
	addi $s5, $s5, 4
	beq $s2, $s1, __physics__QuadTree__fowardChildren__ForEnd

	lw $s3 ($s5)
	lh $s4 ($s3)
	lh $s6 2($s3)
	
	PUSH.W($s4)  # x
	PUSH.W($s6)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($s7)   # Quadrant
	
	sll $t0, $s0, 2
	add $t0, $t0, $s7
	addi $t0, $t0, 1
	
	PUSH.W($t0)     # parent
	PUSH.W($s6)     # y
	PUSH.W($s4)     # x
	PUSH.W($s3)     # addr of collider
	jal __physics__QuadTree__insertRecursive

	addi $s2, $s2, 1
	j __physics__QuadTree__fowardChildren__For
__physics__QuadTree__fowardChildren__ForEnd:
	POP.W($s7)
	POP.W($s6)
	POP.W($s5)
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra



# returns: 1 WORD -> [NW = 0, NE = 1, SW = 2, SE = 3]
__physics__QuadTree__getQuadrant:
	POP.W($t2)    # i
    POP.W($t1)    # y
    POP.W($t0)    # x
	
	subi $t2, $t2, 1        #$t0 = i - 1
	sra $t3, $t2, 2         #$t1 = P

	li $t7, SCREEN_WIDTH
	li $t8, SCREEN_HEIGHT  
	
	addi $t3, $t3, 2
	srlv $t7, $t7, $t3      #$t7 = W(p)
	srlv $t8, $t8, $t3		#$t8 = H(p)
	
	bleu $t0, $t7, __physics__QuadTree__getQuadrant__WEST
	li $t4, 1
	j __physics__QuadTree__getQuadrant__Vert
__physics__QuadTree__getQuadrant__WEST:
	li $t4, 0
__physics__QuadTree__getQuadrant__Vert:

	bleu $t1, $t8, __physics__QuadTree__getQuadrant__NORTH
	li $t5, 1
	j __physics__QuadTree__getQuadrant__Return
__physics__QuadTree__getQuadrant__NORTH:
	li $t5, 0
__physics__QuadTree__getQuadrant__Return:
	sll $t5, $t5, 1
	add $t5, $t4, $t5
	
	PUSH.W($t5)
	jr $ra


# returns: 1 WORD -> [True = 1, False = 0]
__physics__QuadTree__contains:
	POP.W($t0)   # i
	POP.W($t3)   # y
	POP.W($t2)   # x
	
	li $t7, SCREEN_WIDTH
	li $t8, SCREEN_HEIGHT   
	
	li $t4, 0
	li $t5, 0
beqz $t0, __physics__QuadTree__contains__Skip
	subi $t0, $t0, 1        #$t0 = i - 1
	sra $t1, $t0, 2         #$t1 = P
	addi $t1, $t1, 1        #$t0 = i + 1
	
	srlv $t7, $t7, $t1      #$t7 = W(p)
	srlv $t8, $t8, $t1		#$t8 = H(p)

	li $t1, 2
	div $t0, $t1           #$t4 = startBound x (Box)
	mfhi $t4
	mul $t4, $t4, $t7
	
	
	srl $t9, $t0, 1
	div $t9, $t1            #$t5 = startBound y (Box)
	mfhi $t5
	mul $t5, $t8, $t5

__physics__QuadTree__contains__Skip:
	add $t6, $t7, $t4  		#$t6 = endBound x (Box)
	add $t9, $t8, $t5  		#$t9 = endBound y (Box)
	
	
	bltu $t2, $t4, __physics__QuadTree_notInBounds
	bgtu $t2, $t6, __physics__QuadTree_notInBounds
	bltu $t3, $t5, __physics__QuadTree_notInBounds
	bgtu $t3, $t9, __physics__QuadTree_notInBounds
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
