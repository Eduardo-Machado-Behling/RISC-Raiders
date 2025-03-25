.eqv QUAD_TREE_LOCATION 0x100C0000
.eqv QUAD_TREE_DATA_LOCATION 0x100C1554
.eqv QUAD_TREE_DATA_LOC 0x100C1558
.eqv QUAD_TREE_MAX_DEPTH 5

.eqv QUAD_TREE_THREESHOLD 32
.eqv QUAD_TREE_THREESHOLD_OFFSET 128
.eqv QUAD_TREE_THREESHOLD_OFFSET_SHIFT 7

.macro arrayGet(%reg, %arr, %shift, %i)
	sll $k0, %i, %shift
	addi %reg, $k0, %arr
.end_macro

.macro treeGetChildrenIndex(%reg, %i)
	sll $k0, %i, 2
	addi %reg, $k0, 1
.end_macro

.macro treeGetChildrenIndexNth(%reg, %i, %j)
	sll $k0, %i, 2
	add %reg, $k0, %j
.end_macro

# () -> void
Physics__QuadTree__init:
	li $t0, QUAD_TREE_DATA_LOCATION
	li $t1, QUAD_TREE_LOCATION

	addi $t4, $t0, 4
	sw $t4, ($t1)
	sw $zero, ($t4)
	
	addi $t2, $t4, QUAD_TREE_THREESHOLD_OFFSET
	sw $t2, ($t0)

	jr $ra

# (collider: WORD*) -> void
Physics__QuadTree__delete:
	POP.W($t0)    # addr of collider
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	move $s0, $t0
	
	lh $s1, 0($s0)
	lh $s2, 2($s0)
	lh $s3, 4($s0)
	lh $s4, 6($s0)
	
	PUSH.W($zero)
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	PUSH.W($s0)   # addr Collider	
	jal __physics__QuadTree__deleteRecursive
	POP.W($zero)
	
	add $t0, $s1, $s3
	PUSH.W($zero)
	PUSH.W($t0)   # x + w
	PUSH.W($s2)   # y
	PUSH.W($s0)   # addr Collider	
	jal __physics__QuadTree__deleteRecursive
	POP.W($zero)
	
	add $t1, $s2, $s4
	PUSH.W($zero)
	PUSH.W($s1)   # x
	PUSH.W($t1)   # y + h
	PUSH.W($s0)   # addr Collider	
	jal __physics__QuadTree__deleteRecursive
	POP.W($zero)
	
	add $t0, $s1, $s3
	add $t1, $s2, $s4
	PUSH.W($zero)
	PUSH.W($t0)   # x + w
	PUSH.W($t1)   # y + h
	PUSH.W($s0)   # addr Collider	
	jal __physics__QuadTree__deleteRecursive
	POP.W($zero)

	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	POP.W($ra)
	jr $ra	

#(parent: WORD, x: WORD, y: WORD, collider: WORD*) -> WORD [0 = noDelete, 1 = leaf_noDelete, 2 = leaf_delete]
__physics__QuadTree__deleteRecursive:
	POP.W($t3)    # addr of collider
	POP.W($t2)    # y
	POP.W($t1)    # x
	POP.W($t0)    # parent
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	PUSH.W($s5)
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	move $s3, $t3

	li $v1, 0
	PUSH.W($s0)
	jal __physics__QuadTree__getData
	POP.W($s4)
	
	bnez $s4, __physics__QuadTree__deleteRecursive__isLeaf
	
	PUSH.W($s1)  # x
	PUSH.W($s2)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($t0)
	
	treeGetChildrenIndexNth($s5, $s0, $t0)
	
	PUSH.W($s5)
	PUSH.W($s1)  # x
	PUSH.W($s2)  # y
	PUSH.W($s3)
	jal __physics__QuadTree__deleteRecursive
	POP.W($t2)
	beqz $t2, __physics__QuadTree__deleteRecursive__return
	
	# PUSH.W($s0)
	# jal __physics__QuadTree__countChildrenObjects
	# POP.W($s5)
	# bge $s5, QUAD_TREE_THREESHOLD, __physics__QuadTree__deleteRecursive__return
	
	# PUSH.W($s0)
	# PUSH.W($s5)
	# jal __physics__QuadTree__merge
	li $v1, 0
	
	j __physics__QuadTree__deleteRecursive__return
__physics__QuadTree__deleteRecursive__isLeaf:
	arrayGet($t0, QUAD_TREE_LOCATION, 2, $s0)
	PUSH.W($t0)
	PUSH.W($s3)
	jal __physics__QuadTree__deleteFromLeaf
	POP.W($t0)
	addi $v1, $t0, 1
__physics__QuadTree__deleteRecursive__return:
	POP.W($s5)
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	PUSH.W($v1)
	jr $ra


#(parent: WORD) -> WORD
__physics__QuadTree__countChildrenObjects:
	POP.W($t0)
	
	sll $t2, $t0, 2
	arrayGet($t6, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $t2)
	
	addi $t6, $t6,  QUAD_TREE_THREESHOLD_OFFSET
	lw $t2, ($t6)
	
	addi $t6, $t6,  QUAD_TREE_THREESHOLD_OFFSET
	lw $t3, ($t6)
	add $t2, $t2, $t3
	
	addi $t6, $t6,  QUAD_TREE_THREESHOLD_OFFSET
	lw $t3, ($t6)
	add $t2, $t2, $t3
	
	addi $t6, $t6,  QUAD_TREE_THREESHOLD_OFFSET
	lw $t3, ($t6)
	add $t2, $t2, $t3
	
	PUSH.W($t2)
	jr $ra

#(parent: WORD, amount: WORD) -> void
__physics__QuadTree__merge:
	POP.W($t1)
	POP.W($t0)
	
	arrayGet($t6, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $t0)
	arrayGet($t7, QUAD_TREE_LOCATION, 2, $t0)
	sw $t1, ($t6)
	sw $t6, ($t7)
	
	sll $t6, $t0, 2
	arrayGet($t6, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $t6)
	
	
	
	addi $t9, $t6,  QUAD_TREE_THREESHOLD_OFFSET
	move $t2, $t9
	lw $t5, ($t2)
	li $t4, 0
	sw $zero, 4($t7)
__physics__QuadTree__for0:
	beq $t4, $t5, __physics__QuadTree__forEnd0
	
	addi $t2, $t2, 4
	lw $t1, ($t2)
	addi $t6, $t6, 4
	sw $t1, ($t6)
	
	addi $t4, $t4, 1
	j 	__physics__QuadTree__for0
__physics__QuadTree__forEnd0:

	addi $t9, $t9,  QUAD_TREE_THREESHOLD_OFFSET
	move $t2, $t9
	lw $t5, ($t2)
	li $t4, 0
	sw $zero, 8($t7)
__physics__QuadTree__for1:
	beq $t4, $t5, __physics__QuadTree__forEnd1
	
	addi $t2, $t2, 4
	lw $t1, ($t2)
	addi $t6, $t6, 4
	sw $t1, ($t6)
	
	addi $t4, $t4, 1
	j 	__physics__QuadTree__for1
__physics__QuadTree__forEnd1:

	addi $t9, $t9,  QUAD_TREE_THREESHOLD_OFFSET
	move $t2, $t9
	lw $t5, ($t2)
	li $t4, 0
	sw $zero, 12($t7)
__physics__QuadTree__for2:
	beq $t4, $t5, __physics__QuadTree__forEnd2
	
	addi $t2, $t2, 4
	lw $t1, ($t2)
	addi $t6, $t6, 4
	sw $t1, ($t6)
	
	addi $t4, $t4, 1
	j 	__physics__QuadTree__for2
__physics__QuadTree__forEnd2:

	addi $t2, $t9,  QUAD_TREE_THREESHOLD_OFFSET
	lw $t5, ($t2)
	li $t4, 0
	sw $zero, 16($t7)
__physics__QuadTree__for3:
	beq $t4, $t5, __physics__QuadTree__return
	
	addi $t2, $t2, 4
	lw $t1, ($t2)
	addi $t6, $t6, 4
	sw $t1, ($t6)
	
	addi $t4, $t4, 1
	j 	__physics__QuadTree__for3
__physics__QuadTree__return:
	jr $ra



__physics__QuadTree__deleteFromParent:
	POP.W($t1)    # addr of collider
	POP.W($t0)    # parent
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	
	move $s0, $t0
	move $s1, $t1
	
	arrayGet($s2, QUAD_TREE_LOCATION, 2, $t0)  #quadtree[$t0] -> $t3
	
	#unrolled for, is it really better?
	addi $s2, $s2, 4
	PUSH.W($s2)
	PUSH.W($s1)
	jal __physics__QuadTree__deleteFromLeaf
	POP.W($t0)
	bnez $t0, __physics__QuadTree__deleteFromParent__return
	
	addi $s2, $s2, 4
	PUSH.W($s2)
	PUSH.W($s1)
	jal __physics__QuadTree__deleteFromLeaf
	POP.W($t0)
	bnez $t0, __physics__QuadTree__deleteFromParent__return
	
	addi $s2, $s2, 4
	PUSH.W($s2)
	PUSH.W($s1)
	jal __physics__QuadTree__deleteFromLeaf
	POP.W($t0)
	bnez $t0, __physics__QuadTree__deleteFromParent__return
	
	addi $s2, $s2, 4
	PUSH.W($s2)
	PUSH.W($s1)
	jal __physics__QuadTree__deleteFromLeaf
	POP.W($t0)

__physics__QuadTree__deleteFromParent__return:
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	PUSH.W($t0)
	jr $ra

#(parent: WORD*, collider: WORD*) -> WORD: [1 = Deleted, 0 = notDeleted]
__physics__QuadTree__deleteFromLeaf:
	POP.W($t1)
	POP.W($t0)
	
	li $t2, 0
	li $t9, 0
	lw $t4, ($t0)
	lw $t5, ($t4)
	move $t3, $t4

__physics__QuadTree__deleteFromLeaf__for:
	beq $t2, $t5, __physics__QuadTree__deleteFromLeaf__forEnd
	
	addi $t4, $t4, 4
	lw $t6, ($t4)
	bne $t6, $t1, __physics__QuadTree__deleteFromLeaf__notFound  #if Found swap last with found to delete it
	subi $t7, $t5, 1
	sw $t7, ($t3)
	sll $t7, $t7, 2
	add $t7, $t4, $t7

	lw $t7, ($t7)
	sw $t7, ($t4)
	addi $t9, $t9, 1
	j __physics__QuadTree__deleteFromLeaf__forEnd
__physics__QuadTree__deleteFromLeaf__notFound:
	addi $t2, $t2, 1
	j __physics__QuadTree__deleteFromLeaf__for
__physics__QuadTree__deleteFromLeaf__forEnd:	
	PUSH.W($t9)
	jr $ra

# (collider: WORD*, resultArray: WORD*) -> void
Physics__QuadTree__search:
	POP.W($t1)    # addr of result
	POP.W($t0)    # addr of collider
	
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
	move $s5, $t1
	
	lh $s1, ($s0)
	lh $s2, 2($s0)
	lh $s3, 4($s0)
	lh $s4, 6($s0)
	
	PUSH.W($zero) # parent
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	jal __physics__QuadTree__searchRecursive
	POP.W($s6)
	
	PUSH.W($s6)
	PUSH.W($s5)
	jal __physics__QuadTree__appendArray
	
	add $t0, $s1, $s3
	PUSH.W($zero) # parent
	PUSH.W($t0)   # x + w
	PUSH.W($s2)   # y
	jal __physics__QuadTree__searchRecursive
	POP.W($s7)
	beq $s7, $s6, Physics__QuadTree__search__skip0
	PUSH.W($s7)
	PUSH.W($s5)
	jal __physics__QuadTree__appendArray

Physics__QuadTree__search__skip0:
	add $t1, $s2, $s4
	PUSH.W($zero) # parent
	PUSH.W($s1)   # x
	PUSH.W($t1)   # y + h
	jal __physics__QuadTree__searchRecursive
	POP.W($s0)
	beq $s0, $s6, Physics__QuadTree__search__skip1
	beq $s0, $s7, Physics__QuadTree__search__skip1
	PUSH.W($s0)
	PUSH.W($s5)
	jal __physics__QuadTree__appendArray
	
Physics__QuadTree__search__skip1:
	add $t0, $s1, $s3
	add $t1, $s2, $s4	
	PUSH.W($zero) # parent
	PUSH.W($t0)   # x + w
	PUSH.W($t1)   # y + h
	jal __physics__QuadTree__searchRecursive
	POP.W($t0)
	beq $t0, $s6, Physics__QuadTree__search__skip2
	beq $t0, $s7, Physics__QuadTree__search__skip2
	beq $t0, $s0, Physics__QuadTree__search__skip2
	PUSH.W($t0)
	PUSH.W($s5)
	jal __physics__QuadTree__appendArray
	
Physics__QuadTree__search__skip2:
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


# (orig: WORD*, dest: WORD*) -> void
__physics__QuadTree__appendArray:
	POP.W($t1) # orig
	POP.W($t0) # dest
	
	lw $t7, ($t1)
	sll $t3, $t7, 2
	add $t4, $t1, $t3
	
	lw $t5, ($t0)
	li $t6, 0
__physics__QuadTree__appendArray__for:
	beq $t6, $t5, __physics__QuadTree__appendArray__forEnd

	addi $t0, $t0, 4	
	lw $t9, ($t0)
	addi $t4, $t4, 4
	sw $t9, ($t4)
	
	addi $t6, $t6, 1
	j __physics__QuadTree__appendArray__for
	
__physics__QuadTree__appendArray__forEnd:
	add $t7, $t7, $t5
	sw $t7, ($t1)
	jr $ra
	
# (parent: WORD, x: WORD, y: WORD) -> Colliders: WORD*
__physics__QuadTree__searchRecursive:
	POP.W($t2)   # y
	POP.W($t1)   # x
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
	
	PUSH.W($s0) # i
	jal __physics__QuadTree__getData
	POP.W($s3)  #data
	beqz $s3, __physics__QuadTree__searchRecursive__isNotLeaf
__physics__QuadTree__searchRecursive__isLeaf:
	arrayGet($v0, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $s0)
	j __physics__QuadTree__searchRecursive__return
__physics__QuadTree__searchRecursive__isNotLeaf:
	PUSH.W($s1)  # x
	PUSH.W($s2)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($s7)   # Quadrant

	sll $t0, $s0, 2
	add $t0, $t0, $s7
	
	PUSH.W($t0) # parent
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	jal __physics__QuadTree__searchRecursive
	POP.W($v0)
__physics__QuadTree__searchRecursive__return:	
	POP.W($s7)
	POP.W($s6)
	POP.W($s5)
	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	PUSH.W($v0)
	jr $ra
	
# (i: WORD) -> WORD*
__physics__QuadTree__getData:
	POP.W($t0)
	li $t4, QUAD_TREE_LOCATION
	sll $t1, $t0, 2
	add $t5, $t1, $t4
	lw $t6, ($t5)
	
	PUSH.W($t6)
	jr $ra

# (collider: WORD*) -> void
Physics__QuadTree__insert:
	POP.W($t0)    # addr of collider
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	PUSH.W($s3)
	PUSH.W($s4)
	
	move $s0, $t0
	
	lh $s1, 0($s0)
	lh $s2, 2($s0)
	lh $s3, 4($s0)
	lh $s4, 6($s0)
	
	PUSH.W($s0)   # addr Collider	
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	jal __physics__QuadTree__insertOrSkip
	
	add $t0, $s1, $s3
	PUSH.W($s0)   # addr Collider	
	PUSH.W($t0)   # x + w
	PUSH.W($s2)   # y
	jal __physics__QuadTree__insertOrSkip
	
	add $t1, $s2, $s4
	PUSH.W($s0)   # addr Collider	
	PUSH.W($s1)   # x
	PUSH.W($t1)   # y + h
	jal __physics__QuadTree__insertOrSkip
	
	add $t0, $s1, $s3
	add $t1, $s2, $s4
	PUSH.W($s0)   # addr Collider	
	PUSH.W($t0)   # x + w
	PUSH.W($t1)   # y + h
	jal __physics__QuadTree__insertOrSkip

	POP.W($s4)
	POP.W($s3)
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	POP.W($ra)
	jr $ra	
	
#(collider: WORD*, x: WORD, y: WORD) -> void
__physics__QuadTree__insertOrSkip:
	POP.W($t2)
	POP.W($t1)
	POP.W($t0)
	
	PUSH.W($ra)
	PUSH.W($s0)
	PUSH.W($s1)
	PUSH.W($s2)
	
	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	PUSH.W($zero) # i
	jal __physics__QuadTree__contains
	POP.W($t0) # bool Contains
	
	beqz $t0, __physics__QuadTree__insertOrSkip__skip
	PUSH.W($zero) # parent
	PUSH.W($s1)   # x
	PUSH.W($s2)   # y
	PUSH.W($s0)   # addr Collider	
	jal __physics__QuadTree__insertRecursive
__physics__QuadTree__insertOrSkip__skip:
	POP.W($s2)
	POP.W($s1)
	POP.W($s0)
	
	POP.W($ra)
	jr $ra
	
	

# (parent: WORD, x: WORD, y: WORD, collider: WORD*) -> void
__physics__QuadTree__insertRecursive:
	POP.W($t3)   # addr of collider
	POP.W($t2)   # y
	POP.W($t1)   # x
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
	printInt($s1)
	printCharI('|')
	printInt($s2)
	printCharI('|')
	printInt($s0)
	printCharI('|')
	printHex($s3)
	
	bnez $s0, __physics__QuadTree__skipCounterInit
	li $a3, 0
__physics__QuadTree__skipCounterInit:
	add $a3, $a3, 1
	bge $a3, QUAD_TREE_MAX_DEPTH, __physics__QuadTree__skipped
	
	PUSH.W($s0)
	jal __physics__QuadTree__getData
	POP.W($s6)
	
	printCharI('|')
	printHex($s6)
	printCharI('\n')
	
	PUSH.W($s1)  # x
	PUSH.W($s2)  # y
	PUSH.W($s0)  # i
	jal __physics__QuadTree__getQuadrant
	POP.W($s7)   # Quadrant

	beqz $s6, __physics__QuadTree__insertRecursiveIF__isLeaf
	
	PUSH.W($s3)    # object       (addr)
	PUSH.W($s6)    # dataLocation (addr)
	PUSHI.W(QUAD_TREE_THREESHOLD)  # size (WORD)
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
	
	printCharI('F')
	printCharI('\n')
	
	PUSH.W($s0)    # parent
	jal __physics__QuadTree__forwardChildren
	
__physics__QuadTree__insertRecursiveIF__isLeaf:
	sll $t0, $s0, 2
	add $t0, $t0, $s7
	
	PUSH.W($t0)     # parent
	PUSH.W($s1)     # x
	PUSH.W($s2)     # y
	PUSH.W($s3)     # addr of collider
	jal __physics__QuadTree__insertRecursive
	j __physics__QuadTree__insertRecursiveReturn
	
__physics__QuadTree__skipped:
	printStringI(debug_insert_ret8)
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
	
	arrayGet($t3, QUAD_TREE_LOCATION, 2, $t0)  #quadtree[$t0] -> $t3
	move $t2, $t3
	
	lw $t4, ($t2)
	sw $zero, ($t2)
	lw $t6, ($t4)
	sw $zero ($t4)
	
	sll $t0, $t0, 2
	arrayGet($t3, QUAD_TREE_LOCATION, 2, $t0)  #quadtree[$t0] -> $t3
	arrayGet($t8, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $t0) #quadData[$t2] -> $t8
	

	#unrolled for, is it really better?
	addi $t3, $t3, 4
	addi $t8, $t8,  QUAD_TREE_THREESHOLD_OFFSET
	sw $t8, ($t3)
	sw $zero ($t8)
	
	addi $t3, $t3, 4
	addi $t8, $t8,  QUAD_TREE_THREESHOLD_OFFSET
	sw $t8, ($t3)
	sw $zero ($t8)

	addi $t3, $t3, 4
	addi $t8, $t8,  QUAD_TREE_THREESHOLD_OFFSET
	sw $t8, ($t3)
	sw $zero ($t8)
	
	addi $t3, $t3, 4
	addi $t8, $t8,  QUAD_TREE_THREESHOLD_OFFSET
	sw $t8, ($t3)
	sw $zero ($t8)

	jr $ra


# (dataLocation: *WORD, Object: WORD*, size: WORD) -> WORD [1 = Fail, 0 = Success]
__physics__QuadTree__addObject:
	POP.W($t9)  # size  (WORD)
	POP.W($t0)  # dataLocation (addr)
	POP.W($t1)  # Object  (addr)

	lw $t3 ($t0)
	printCharI('A')
	printCharI(':')
	printCharI(' ')
	printInt($t3)
	printCharI('\n')
		
	addi $t7, $t3, 1
	beq $t7, $t9, __physics__QuadTree__addObject__Fail


	li $t4, 0
	addi $t6, $t0, 4  # Start at first object slot
__physics__QuadTree__addObject__for:
	beq $t4, $t3, __physics__QuadTree__addObject__forEnd
	
	lw $t8, ($t6)
	beq $t8, $t1, __physics__QuadTree__addObject__return
	
	addi $t6, $t6, 4
	addi $t4, $t4, 1
	j __physics__QuadTree__addObject__for
__physics__QuadTree__addObject__forEnd:	
    sw $t1, ($t6)
	sw $t7, ($t0)
	
__physics__QuadTree__addObject__return:
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
	arrayGet($s7, QUAD_TREE_DATA_LOC, QUAD_TREE_THREESHOLD_OFFSET_SHIFT, $t0)
	move $s5, $s7
	
	li $s1, QUAD_TREE_THREESHOLD
	li $s2, 1
	sw $zero, ($s5)
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
	
	sll $t9, $t7, QUAD_TREE_THREESHOLD_OFFSET_SHIFT
	add $t9, $t9, $s7
	
	PUSH.W($s3)     # collider  (addr)
	PUSH.W($t9)     # data (addr)
	PUSHI.W(QUAD_TREE_THREESHOLD)  # size (WORD)
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

__physics__QuadTree__getDepth:
    bnez $a0, __physics__QuadTree__check_loop
    li $v0, 0
    jr $ra

__physics__QuadTree__check_loop:
    li $t0, 0       # depth = 0
    li $t1, 1       # count = 1

__physics__QuadTree__loop:
    blt $a0, $t1, __physics__QuadTree__return_depth
    addi $t0, $t0, 1    # depth += 1
    sll $t1, $t1, 2     # count *= 4
    j __physics__QuadTree__loop

__physics__QuadTree__return_depth:
    move $v0, $t0   # Return depth
    jr $ra

# (x: WORD, y: WORD, Parent: WORD) -> WORD [NW = 1, NE = 2, SW = 3, SE = 4]
__physics__QuadTree__getQuadrant:
	POP.W($t2)    # i
    POP.W($t1)    # y
    POP.W($t0)    # x

	PUSH.W($ra)

	li $t7, SCREEN_WIDTH
	li $t8, SCREEN_HEIGHT  

	move $a0, $t2
	jal __physics__QuadTree__getDepth
	srlv $t7, $t7, $v0      #$t7 = W(p)
	srlv $t8, $t8, $v0		#$t8 = H(p)


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
	
	POP.W($ra)
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
	printInt($t2)
	printCharI(',')
	printInt($t3)
	printCharI('|')
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
