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
# - Milestone 2
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
	objects: .word 0:9	# store (active, x,y) values for 3 objects, active = 1 when the object is on screen
	
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
	la $s5, objects
	
setup:	jal clear_screen	# clear the screen for resets
	jal reset_objects
	
	# (x, y) initial values for player model
	li $t3, 20	# x
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
#	t9 : RGB black
#
#	s0 :
#	s1 : 
#	s2 : inputAddress
#	s3 : input boolean
#	s4 : input value
#	s5 : object array
#	s6 :
#	s7 :
	li $s7, 0
main:	
	jal update_objects
	
	jal draw_player
	
	lw $s3, 0($s2)	# keypress bool
	lw $s4, 4($s2)	# keypress value
	beq $s3, 1, handle_keypress

	# sleep for refreshRate time
	li $v0, 32
	li $a0, refreshRate
	syscall
	
	beq $s3, 1, handle_keypress
keypress_return:
	j main	# loop


handle_keypress:
	beq $s4, 0x70, handle_p
	
	# moving
	beq $s4, 0x77, handle_w
	beq $s4, 0x61, handle_a
	beq $s4, 0x73, handle_s
	beq $s4, 0x64, handle_d
	j keypress_return
	
# game restart
handle_p:
	jal clear_screen
	j setup

# handle player movements	
handle_w:
	bge $t4, 1, move_up
	j keypress_return
move_up:	
	jal clear_player
	subi $t4, $t4, 1	# move player y up the screen
	j keypress_return
	
handle_s:
	ble $t4, 114, move_down
	j keypress_return
move_down:
	jal clear_player
	addi $t4, $t4, 1	# move player y down the screen
	j keypress_return
	
handle_a:
	bge $t3, 1, move_left
	j keypress_return
move_left:
	jal clear_player
	subi $t3, $t3, 1	# move player x left
	j keypress_return
	
handle_d:
	ble $t3, 48, move_right
	j keypress_return
move_right:
	jal clear_player
	addi $t3, $t3, 1	# move player x right
	j keypress_return


update_objects:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a0, 0($s5)
	lw $a1, 4($s5)
	lw $a2, 8($s5)
	jal update_object
	sw $a0, 0($s5)
	sw $a1, 4($s5)
	sw $a2, 8($s5)
	
	lw $a0, 12($s5)
	lw $a1, 16($s5)
	lw $a2, 20($s5)
	jal update_object
	sw $a0, 12($s5)
	sw $a1, 16($s5)
	sw $a2, 20($s5)
	
	lw $a0, 24($s5)
	lw $a1, 28($s5)
	lw $a2, 32($s5)
	jal update_object
	sw $a0, 24($s5)
	sw $a1, 28($s5)
	sw $a2, 32($s5)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# update single object, takes params (a0, a1, a2) = (active, x, y)
update_object:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	beq $a0, 1, activated
	jal spawn_object
	j object_return
activated:
	jal clear_object
	add $a1, $a1, 0
	add $a2, $a2, 1
	jal check_object
	jal draw_object
object_return:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

check_object:
	bge $a2, 125, set_inactive
	jr $ra
set_inactive:
	li $a0, 0
	li $a1, 0
	li $a2, 0
	j object_return

# spawn object function, takes params (a0, a1, a2) = (active, x, y)
spawn_object:
	# generate random x value for the object
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 63	   # Select upper bound of random number
	syscall            # Generate random int (returns in $a0)
	
	la $a1, ($a0)	# save random x in a1
	li $a2, 0	# y value for object (not adjusted for address)
	li $a0, 1
	jr $ra

# sets all object values to default
reset_objects:
	sw $zero, 0($s5)
	sw $zero, 4($s5)
	sw $zero, 8($s5)
	
	sw $zero, 12($s5)
	sw $zero, 16($s5)
	sw $zero, 20($s5)
	
	sw $zero, 24($s5)
	sw $zero, 28($s5)
	sw $zero, 32($s5)

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

# draw object function, takes a1 = x val, a2 = y val
draw_object:
	# calculate addr for y val
	lw $t6, displayWidth
	la $t5, ($a2)		
	mult $t5, $t6
	mflo $t5
	
	# calculate addr for x val
	li $t7, 4
	mult $a1, $t7
	mflo $t6
	
	add $t5, $t5, $t6
	
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

# clear object function, takes a1 = x val, a2 = y val
clear_object:
	# calculate addr for y val
	lw $t6, displayWidth
	la $t5, ($a2)		
	mult $t5, $t6
	mflo $t5
	
	# calculate addr for x val
	li $t7, 4
	mult $a1, $t7
	mflo $t6
	
	add $t5, $t5, $t6
	
	# offset from displayAddress
	add $t5, $t0, $t5
	
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 252
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	addi $t5, $t5, 252
	sw $t9, ($t5)
	addi $t5, $t5, 4
	sw $t9, ($t5)
	
	jr $ra

	
# draw player function
draw_player:
	# load player (x, y) values and calculate address, using t5 as final address
	lw $t6, displayWidth
	la $t5, ($t4)		
	mult $t5, $t6
	mflo $t5
	
	# calculate addr for x val
	li $t7, 4
	mult $t3, $t7
	mflo $t6
	
	add $t5, $t5, $t6
	
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
	
	# calculate addr for x val
	li $t7, 4
	mult $t3, $t7
	mflo $t6
	
	add $t5, $t5, $t6
	
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
