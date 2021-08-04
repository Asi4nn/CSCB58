#####################################################################
#
# CSCB58 Summer 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Si Wang, 1006090365, wangsi97
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes 
# GitHub Repo: https://github.com/Asi4nn/CSCB58
#
# Any additional information that the TA needs to know:
# - Vertical scrolling instead of horizontal
#
#####################################################################

.data
	displayAddress: .word 0x10008000
	inputAddress: .word 0xffff0000
	
	# dimensions
	playerWidth: .word 15
	playerHeight: .word 13
	
	objectWidth: .word 2
	objectHeight: .word 3
	objects: .word 0:3
	numOfObjects: .word 0
	
	# note: scaled by 4 for address calculation
	displayWidth: .word 256
	displayHeight: .word 512
	
	red: .word 0xff0000
	white: .word 0xffffff
	black: .word 0
	gray: .word 0x999999

.eqv refreshRate 40

.text
	# setting up registers
	
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0xffffff # $t1 stores the white colour code
	li $t9, 0	 # $t9 stores black
	li $t8, 0x999999 # $t1 stores gray

	lw $s2, inputAddress
	
setup:	jal clear_screen	# clear the screen for resets

	# generate random x value for the object
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 64	   # Select upper bound of random number
	syscall            # Generate random int (returns in $a0)
	
	la $s0, ($a0)	# save random x in s0
	li $t7, 4
	mult $s0, $t7
	mflo $s0	# get address of x value
	li $s1, 80	# y value for object (not adjusted for address)
	
	# (x, y) initial values for player model
	li $t3, 100	# 4*x
	li $t4, 110	# y
	
# 	RESERVED REGISTERS
#	t0 : displayAddress
#	t1 : RGB red
#	t2 : RGB white
#	t3 : player x val
#	t4 : player y val
#	t5 : free, typical use for movement calculation
#	t6 : free, typical use for movement caluclation
#	t7 : free
#	t8 : RGB gray
#	t9 : RGB 
#
#	s0 : object x val
#	s1 : object y val
#	s2 : inputAddress
#	s3 : input boolean
#	s4 : input value
#	s5 : 
#	s6 :
#	s7 :
			
main:	
	jal draw_object
	
	jal check_player
	
	addi $t4, $t4, 2
	jal clear_player
	subi $t4, $t4, 2
	
	jal draw_player
	
	lw $s3, 0($s2)	# keypress bool
	lw $s4, 4($s2)	# keypress value
	beq $s3, 1, handle_keypress

keypress_return:
	# sleep for 40ms
	li $v0, 32
	li $a0, refreshRate
	syscall
	
	subi $t4, $t4, 2	# move player y up the screen
	
	j main	# loop


handle_keypress:
	beq $s4, 0x70, handle_p
	j keypress_return
	
	
handle_p:
	jal clear_screen
	j setup

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
	
draw_gameover:
	addi $t5, $t0, 0
	addi $t5, $t5, 5156
	
	# Start of word GAME
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 108
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	# Start of word OVER
	addi $t5, $t5, 588
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 16
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 16
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)

	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 8
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 76
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 24
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 100
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 24
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 100
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 16
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 92
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 16
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 44
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 92
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 16
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
	addi $t5, $t5, 84
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	addi $t5, $t5, 16
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 28
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 12
	
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	addi $t5, $t5, 20
	sw $t8, ($t5)
	addi $t5, $t5, 4
	sw $t8, ($t5)
	
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
	
	
clear_screen:
	addi $t5, $t0, 0	# load display addr
	li $t6, 0		# counter for number of pixels passed
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
clear_loop:
	sw $t9, ($t5)		# set pixel bg colour
	addi $t5, $t5, 4	# goto next pixel
	
	addi $t6, $t6, 1	# increment counter
	bgt $t6, 8192, clear_loop_end
	j clear_loop
clear_loop_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
END:
	jal draw_gameover
ENDLOOP:	
	lw $s3, 0($s2)	# keypress bool
	lw $s4, 4($s2)	# keypress value
	beq $s3, 1, handle_keypress
	
	# sleep for 40ms
	li $v0, 32
	li $a0, refreshRate
	syscall
	
	j ENDLOOP
	
