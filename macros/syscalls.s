.macro printInt(%int)
	li $v0, 1
	move $a0, %int
	syscall
.end_macro

.macro printFloat(%float)
	li $v0, 2
	move $f12, %float
	syscall
.end_macro

.macro printDouble(%double)
	li $v0, 3
	move $f12, %double
	syscall
.end_macro

.macro printString(%str)
	li $v0, 4
	move $a0, %str
	syscall
.end_macro

.macro printStringI(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

.macro readInt(%reg)
	li $v0, 5
	syscall
	move %reg, $v0
.end_macro

.macro readFloat(%reg)
	li $v0, 6
	syscall
	move %reg, $f0
.end_macro

.macro readDouble(%reg)
	li $v0, 7
	syscall
	move %reg, $f0
.end_macro

.macro readString(%str, %strLen)
	li $v0, 8
	syscall
	move %str, $a0
	move %strLen, $a1	
.end_macro

.macro sbrk(%address, %bytes)
	li $v0, 9
	li $v0, %bytes
	syscall
	move %address, $v0
.end_macro

.macro exit
	li $v0, 10
	syscall
.end_macro

.macro printChar(%char)
	li $v0, 11
	move $a0, %char
	syscall
.end_macro

.macro printCharI(%char)
	li $v0, 11
	li $a0, %char
	syscall
.end_macro

.macro readChar(%char)
	li $v0, 12
	syscall
	move %char, $v0
.end_macro

.macro fopen(%filename_reg, %flags, %mode)
	li $v0, 13
	move $a0, %filename_reg
	move $a1, %flags
	move $a2, %mode
	syscall
	move %char, $v0
.end_macro

.macro fread(%fd, %buffer, %max_amount)
	li $v0, 14
	move $a0, %fd
	move $a1, %buffer
	li $a2, %max_amount
	syscall
.end_macro

.macro fwrite(%fd, %buffer, %max_amount)
	li $v0, 15
	move $a0, %fd
	move $a1, %buffer
	li $a2, %max_amount
	syscall
.end_macro

.macro fclose(%fd)
	li $v0, 16
	move $a0, %fd
	move $a1, %buffer
	li $a2, %max_amount
	syscall
.end_macro

.macro abort(%exit_code)
	li $v0, 17
	move $a0, %exit_code
	syscall
.end_macro

.macro time(%HI, %LO)
	li $v0, 30
	syscall
	move %HI, $a0
	move %LO, $a1
.end_macro

.macro MIDI_outI(%pitch, %duration, %instrument, %volume)
	li $v0, 31
	li $a0, %pitch
	li $a1, %duration
	li $a2, %instrument
	li $a3, %volume
	move $a0, %exit_code
	syscall
.end_macro

.macro MIDI_out(%pitch, %duration, %instrument, %volume)
	li $v0, 31
	move $a0, %pitch
	move $a1, %duration
	move $a2, %instrument
	move $a3, %volume
	move $a0, %exit_code
	syscall
.end_macro

.macro sleep(%milliseconds)
	li $v0, 32
	move $a0, %milliseconds
	syscall
.end_macro

.macro sleepI(%milliseconds)
	li $v0, 32
	li $a0, %milliseconds
	syscall
.end_macro

.macro MIDI_outSI(%pitch, %duration, %instrument, %volume)
	li $v0, 33
	li $a0, %pitch
	li $a1, %duration
	li $a2, %instrument
	li $a3, %volume
	move $a0, %exit_code
	syscall
.end_macro

.macro MIDI_outS(%pitch, %duration, %instrument, %volume)
	li $v0, 33
	move $a0, %pitch
	move $a1, %duration
	move $a2, %instrument
	move $a3, %volume
	move $a0, %exit_code
	syscall
.end_macro

.macro printHex(%int)
	li $v0, 34
	move $a0, %int
	syscall
.end_macro

.macro printBinary(%int)
	li $v0, 35
	move $a0, %int
	syscall
.end_macro

.macro printUInt(%int)
	li $v0, 36
	move $a0, %int
	syscall
.end_macro

.macro srand(%id, %int)
	li $v0, 40
	li $a0, %id
	move $a1, %int
	syscall
.end_macro

.macro rand(%reg, %id)
	li $v0, 41
	li $a0, %id
	syscall
	move %reg, $a0
.end_macro

.macro randRange(%reg, %id, %max)
	li $v0, 42
	li $a0, %id
	li $a1, %max
	syscall
	move %reg, $a0
.end_macro

.macro randFloat(%reg, %id)
	li $v0, 42
	li $a0, %id
	syscall
	move %reg, $f0
.end_macro

.macro randDouble(%reg, %id)
	li $v0, 42
	li $a0, %id
	syscall
	move %reg, $f0
.end_macro
