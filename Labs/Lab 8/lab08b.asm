# Si Wang (wangsi97)

.text

main:
	addi $t0, $zero, 14	# a
	addi $t1, $zero, 14	# b
LOOP: 	beq  $t0, $t1, END	# while a != b
	bgt $t0, $t1, GT	# a > b
	ble $t0, $t1, LT	# a <= b (else)
	j LOOP	# loop

GT:
	sub $t0, $t0, $t1	# a = a - b
	j LOOP

LT:
	sub $t1, $t1, $t0	# b = b - a
	j LOOP
	
END:	add $t9, $zero, $t0	# set $t9 = a
