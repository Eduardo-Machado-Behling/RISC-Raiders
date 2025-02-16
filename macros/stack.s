# Stack operation macros with proper alignment and initialization
# All operations maintain word alignment and clear unused bytes

.macro PUSH.B(%byte)
    addi $sp, $sp, -4      # Allocate full word for alignment
    sb %byte, 0($sp)       # Store byte in first position (big-endian convention)
    sb $zero, 1($sp)       # Clear remaining bytes for consistency
    sb $zero, 2($sp)
    sb $zero, 3($sp)
.end_macro 

.macro POP.B(%reg)
    lbu %reg, 0($sp)       # Load byte from first position
    addi $sp, $sp, 4       # Restore stack alignment
.end_macro 

.macro PUSH.H(%half)
    addi $sp, $sp, -4      # Allocate full word
    sh %half, 0($sp)       # Store in first half-word
    sh $zero, 2($sp)       # Clear upper half-word
.end_macro 

.macro POP.H(%reg)
    lh %reg, 0($sp)        # Load from first half-word
    addi $sp, $sp, 4       # Restore stack pointer
.end_macro 

.macro PUSH.W(%word)
    addi $sp, $sp, -4      # Allocate word
    sw %word, 0($sp)       # Store full word
.end_macro 

.macro POP.W(%reg)
    lw %reg, 0($sp)        # Load full word
    addi $sp, $sp, 4       # Restore stack pointer
.end_macro 

# Immediate versions that handle constants
.macro PUSHI.B(%byte)
    li $k0, %byte          # Use $k0 instead of $t9 to avoid conflicts
    PUSH.B($k0)
.end_macro 

.macro PUSHI.H(%half)
    li $k0, %half          # Use $k0 instead of $t9 to avoid conflicts
    PUSH.H($k0)
.end_macro 

.macro PUSHI.W(%word)
    li $k0, %word          # Use $k0 instead of $t9 to avoid conflicts
    PUSH.W($k0)
.end_macro 
