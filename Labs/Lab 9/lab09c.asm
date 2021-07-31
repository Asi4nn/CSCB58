# Si Wang (wangsi97)

# Part III of Lab 9
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Scaled display dimensions: 64x128 units
# - Base Address for Display: 0x10008000 ($gp)


.data
	displayAddress: .word 0x10008000
	
	# dimensions
	playerWidth: .word 15
	playerHeight: .word 13
	
	objectWidth: .word 2
	objectHeight: .word 3
	
	# note: scaled by 4 for address calculation
	displayWidth: .word 256
	displayHeight: .word 512

.text
	# generate random x value for the object
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 64	   # Select upper bound of random number
	syscall            # Generate random int (returns in $a0)
	
	la $s0, ($a0)	# save random x in s0
	li $t9, 4
	mult $s0, $t9
	mflo $s0	# get address of x value
	li $s1, 40	# y value for object (not adjusted for address)
	
	# (x, y) initial values for player model
	li $t3, 100	# 4*x
	li $t4, 110	# y
	
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0xffffff # $t1 stores the white colour code
	li $t9, 0	 # $t9 stores black
	li $t8, 0x999999 # $t1 stores gray
	
	

main:	
	jal draw_object
	
	jal check_player
	
	addi $t4, $t4, 1
	jal clear_player
	subi $t4, $t4, 1
	
	jal draw_player
	
	# sleep for 40ms
	li $v0, 32
	li $a0, 40
	syscall
	
	
	subi $t4, $t4, 1	# move player y up the screen
	
	j main	# loop

# draw object function
draw_object:
	lw $t6, displayWidth
	la $t5, ($s1)		
	mult $t5, $t6
	mflo $t5
	
	add $t5, $t5, $s0
	
	# offset from displayAddress
	add $t5, $t0, $t5
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 252
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 252
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	jr $ra

# draw player function
draw_player:
	# load player (x, y) values and calculate address, using t5 as final address
	lw $t6, displayWidth
	la $t5, ($t4)		
	mult $t5, $t6
	mflo $t5
	
	add $t5, $t5, $t3
	
	# offset from displayAddress
	add $t5, $t0, $t5
	
	addi $t5, $t5, 20	
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 248
	sw $t1, ($t5)
	
	addi $t5, $t5, 228
	sw $t1, ($t5)
	addi $t5, $t5, 24
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 24
	sw $t1, ($t5)
	
	addi $t5, $t5, 200
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 200
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 200
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 200
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 224
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 248
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 248
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 248
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 240
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	
	addi $t5, $t5, 232
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t1, ($t5)

	jr $ra

clear_player:
	# load player (x, y) values and calculate address, using t5 as final address
	lw $t6, displayWidth
	la $t5, ($t4)		
	mult $t5, $t6
	mflo $t5
	
	add $t5, $t5, $t3
	
	# offset from displayAddress
	add $t5, $t0, $t5
	
	addi $t5, $t5, 20	
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 248
	sw $t9, ($t5)
	
	addi $t5, $t5, 228
	sw $t9, ($t5)
	addi $t5, $t5, 24
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 24
	sw $t9, ($t5)
	
	addi $t5, $t5, 200
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 200
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 200
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 200
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 224
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 248
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 248
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 248
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 240
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 232
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)

	jr $ra

# checks if the player is at the top of the screen
check_player:
	bltz $t4, END	# if the player is at the top, end the program
	jr $ra

END:
	li $v0, 10
	syscall