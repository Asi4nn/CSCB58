# Si Wang (wangsi97)

.data
str: 	.asciiz "Enter 3 numbers: a, b and c\n"
str2: 	.asciiz "There are "
str3: 	.asciiz " solutions for ax^2+bx+c\n"

.text
# Print "Enter 3 numbers: a, b and c"
	li $v0, 4
	la $a0, str
	syscall
# Read numbers
	li $v0, 5
	syscall          			# reads the number typed by user and overwrites $v0 with this number
	la $t0, ($v0)				# a
	li $v0, 5				# reset $v0 value to read
	syscall          			# reads the number typed by user and overwrites $v0 with this number
	la $t1, ($v0)				# b
	li $v0, 5				# reset $v0 value to read
	syscall          			# reads the number typed by user and overwrites $v0 with this number
	la $t2, ($v0)				# c
	
# lab 8 calculation
	
	# b^2
	mult $t1, $t1
	mflo $t5
	
	# ac
	mult $t0, $t2
	mflo $t4
	
	addi $t6, $zero, 4	# 4
	
	# 4ac
	mult $t4, $t6
	mflo $t4
	
	sub $t5, $t5, $t4	# b^2 - 4ac
	
	beqz $t5, ONE	# if $t5 == 0
	bgtz $t5, TWO	# if $t5 > 0
	bltz $t5, ZERO	# if $t5 < 0

		
ZERO:
	addi $t5, $zero, 0
	j END

ONE:
	addi $t5, $zero, 1
	j END

TWO:
	addi $t5, $zero, 2
	j END

END:
# Print result
 	li $v0, 4
	la $a0, str2
	syscall
	
	li $v0, 1
	addi $a0, $t5, 0 			# copy the (number+1) from $t0 to $a0. Why?
	syscall	
	
	li $v0, 4
	la $a0, str3
	syscall
	
# End program
	li $v0, 10
	syscall					