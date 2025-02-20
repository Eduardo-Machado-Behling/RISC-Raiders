.eqv QUAD_TREE_LOCATION 0x100C0000
.eqv QUAD_TREE_DATA_LOCATION 0x100C1554
.eqv QUAD_TREE_MAX_DEPTH 5

.eqv QUAD_TREE_THREESHOLD 16
.eqv QUAD_TREE_THREESHOLD_OFFSET 64

# () -> void
Physics__QuadTree__init:
	li $t0, QUAD_TREE_DATA_LOCATION
	li $t1, QUAD_TREE_LOCATION

	addi $t4, $t0, 4
	sw $t4, ($t1)
	sw $zero, ($t4)
	
	addi $t2, $t4, QUAD_TREE_THREESHOLD_OFFSET
	sw $t2 ($t0)

	jr $ra

# (collider: WORD*) -> void
Physics__QuadTree__insert:
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

# (parent: WORD, x: WORD, y: WORD, collider: WORD*) -> void
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
	li $s4, QUAD_TREE_LOCATION
	sll $t1, $s0, 2
	add $s5, $t1, $s4
	lw $s6, ($s5)
	
	printCharI('|')
	printHex($s6)
	printCharI('\n')
	
	PUSH.W($s2) # x
	PUSH.W($s1) # y
	PUSH.W($s0) # i
	jal __physics__QuadTree__contains
	POP.W($t0) # bool Contains
	beqz $t0, __physics__QuadTree__insertRecursiveReturn
	
	PUSH.W($s2)  # x
	PUSH.W($s1)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($s7)   # Quadrant

	beqz $s6, __physics__QuadTree__insertRecursiveIF__isLeaf
	
	PUSH.W($s3)    # object       (addr)
	PUSH.W($s6)    # dataLocation (addr)
	jal __physics__QuadTree__addObject
	POP.W($t0)
	printStringI(debug_insert_ret6)
	printCharI('\n')
	
	beqz $t0, __physics__QuadTree__insertRecursiveReturn
	
	printCharI('^')
	printStringI(debug_insert_ret5)
	printInt($s0)
	printCharI('\n')
	
	PUSH.W($s0)    # parent
	jal __physics__QuadTree__subDivide
	
	PUSH.W($s0)    # parent
	jal __physics__QuadTree__forwardChildren
	
__physics__QuadTree__insertRecursiveIF__isLeaf:
	sll $t0, $s0, 2
	add $t0, $t0, $s7
	
	PUSH.W($t0)     # parent
	PUSH.W($s1)     # y
	PUSH.W($s2)     # x
	PUSH.W($s3)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	
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


# (parent: WORD) -> void
__physics__QuadTree__subDivide:
	POP.W($t0)   #parent
	
	li $t9, QUAD_TREE_LOCATION
	sll $t3, $t0, 2
	add $t3, $t3, $t9
	
	lw $t4, ($t3)
	sw $zero, ($t3)
	lw $t6, ($t4)
	sw $zero ($t4)
	
	addi $t3, $t3, 4
	sw $t4, ($t3)

	li $t7, QUAD_TREE_DATA_LOCATION
	lw $t8, ($t7)

	#unrolled for, is it really better?
	addi $t3, $t3, 4
	sw $t8, ($t3)
	addi $t8, $t8, QUAD_TREE_THREESHOLD_OFFSET

	addi $t3, $t3, 4
	sw $t8, ($t3)
	addi $t8, $t8, QUAD_TREE_THREESHOLD_OFFSET

	addi $t3, $t3, 4
	sw $t8, ($t3)
	addi $t8, $t8, QUAD_TREE_THREESHOLD_OFFSET

	sw $t8, ($t7)

	jr $ra


# (dataLocation: *WORD, Object: WORD*) -> WORD [1 = Fail, 0 = Success]
__physics__QuadTree__addObject:
	POP.W($t0)  # dataLocation (addr)
	POP.W($t1)  # Object  (addr)
	
	lw $t3 ($t0)
	addi $t3, $t3, 1
	
	beq $t3, QUAD_TREE_THREESHOLD, __physics__QuadTree__addObject__Fail
	sw $t3 ($t0)
	sll $t5, $t3, 2
	add $t5, $t5, $t0
	sw $t1, ($t5)
	
	PUSHI.W(0)
	jr $ra

__physics__QuadTree__addObject__Fail:
	PUSHI.W(1)
	jr $ra



# (parent: WORD) -> void
__physics__QuadTree__forwardChildren:
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
	sll $t1, $s0, 2
	add $s7, $t1, $t0
	lw $s5, 4($s7)
	
	li $s1, QUAD_TREE_THREESHOLD
	li $s2, 1
__physics__QuadTree__forwardChildren__For:
	addi $s5, $s5, 4
	beq $s2, $s1, __physics__QuadTree__forwardChildren__ForEnd

	lw $s3, ($s5)
	lh $s4, ($s3)
	lh $s6, 2($s3)
	
	PUSH.W($s4)  # x
	PUSH.W($s6)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($t7)   # Quadrant
	
	sll $t9, $t7, 2
	add $t9, $t9, $s7
	lw $t9, ($t9)
	
	PUSH.W($s3)     # collider  (addr)
	PUSH.W($t9)     # data (addr)
	jal __physics__QuadTree__addObject
	POP.W($t0)

	addi $s2, $s2, 1
	j __physics__QuadTree__forwardChildren__For
__physics__QuadTree__forwardChildren__ForEnd:
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



# (x: WORD, y: WORD, Parent: WORD) -> WORD [NW = 1, NE = 2, SW = 3, SE = 4]
__physics__QuadTree__getQuadrant:
	POP.W($t2)    # i
    POP.W($t1)    # y
    POP.W($t0)    # x

	li $t7, SCREEN_WIDTH
	li $t8, SCREEN_HEIGHT  
	bgez $t2, __physics__QuadTree__getQuadrant__Skip

	sub $t4, $t2, 1
	sra $t2, $t4, 2
__physics__QuadTree__getQuadrant__Skip:
	addi $t3, $t2, 1
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
	addi $t5, $t5, 1
	
	PUSH.W($t5)
	jr $ra


# (x: word, y: word, i: word) -> Word [True = 1, False = 0]
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
	
	printStringI(debug_insert_ret7)
	printInt($t4)
	printCharI('x')
	printInt($t5)
	printCharI(' ')
	printInt($t6)
	printCharI('x')
	printInt($t9)
	printCharI('\n')
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
