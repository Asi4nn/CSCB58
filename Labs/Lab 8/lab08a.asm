# Si Wang (wangsi97)

.text

main:
	addi $t0, $zero, 2	# a
	addi $t1, $zero, 3	# b
	addi $t2, $zero, 2	# c
	
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
