.data
str: 	.asciiz "Hello!\n"
A: 	.word 5, 8, -3, 4, -7, 2, 33
B: 	.word 220:7                    # Initialized to 220 (which is 0xdc) so that we can see it better in the data segment

.text
# Part I
# Print "Hello!" (address of string to print should be in $a0)
	li $v0, 4
	la $a0, str
	syscall
# Read a number (result will be in $v0)
	li $v0, 5
	syscall          			# reads the number typed by user and overwrites $v0 with this number
	addi $t0, $v0, 1 # $t0 = $v0 + 1       # $t0 = this number + 1 (to display it back to user)
# Print result
	li $v0, 1
	addi $a0, $t0, 0 			# copy the (number+1) from $t0 to $a0. Why?
	syscall					# number to print should be in $a0
# End program
	li $v0, 10
#	syscall					# This line is commented out to run Part II and Part III


# Part II		
	# Load and Store to Array
	la $t5, A
	lw $s0, 0($t5)
	lw $s1, 4($t5)
	lw $s2, 8($t5)
	lw $s3, 12($t5)
	
	addi $s0, $zero, 2
	addi $s1, $zero, 5
	addi $s2, $zero, 8
	
	sw $s0, 0($t5)
	sw $s1, 4($t5)
	sw $s2, 8($t5)
	
	lw $s5, 0($t5)
	lw $s6, 4($t5)
	lw $s7, 8($t5)
	

# Part III

	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 27	   # Select upper bound of random number
	syscall            # Generate random int (returns in $a0)





