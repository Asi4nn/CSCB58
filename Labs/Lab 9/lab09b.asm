# Si Wang (wangsi97)

.data
A: 	.word 5, 8, -3, 4, -7, 2, 33, 0 	# set 0 at the end to know the end of the array
B: 	.word 220:7                    # Initialized to 220 (which is 0xdc) so that we can see it better in the data segment

.text	
	# Load A value
	la $t5, A
	
	# Load B value
	la $t6, B
	
	# Offset
	li $t7, 0
	
	# multiplication consts
	li $t8, 5
	li $t9, 10
	
LOOP:	
	lw $t1, ($t5)
	bltz $t1, NEGATIVE	# t5 < 0
	bgtz $t1, POSITIVE	# t5 > 0
	beqz $t1, END		# t5 == 0 (end of array)
RETURN:	mflo $t2
	sw $t2, ($t6)
	addi $t5, $t5, 4
	addi $t6, $t6, 4
	j LOOP
	
NEGATIVE:
	mult  $t8, $t1
	j RETURN

POSITIVE:
	mult  $t9, $t1
	j RETURN

END: 
	li $v0, 10
	syscall	