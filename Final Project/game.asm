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
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Difficulty increasing
# 2. Enemy ships
# 3. Pick-ups (health, kill all enemies)
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
	
	objects: .word 0:9	# store (active, x, y) values for 3 objects, active = 1 when the object is on screen
	
	powerup: .word 0:4	# store (active, x, y, type) values for 1 powerup object; type 1 = life up, type 2 = bonus score
	
	# note: scaled by 4 for address calculation
	displayWidth: .word 256
	displayHeight: .word 512
	
	red: .word 0xff0000
	white: .word 0xffffff
	background: .word 0x16285b
	gray: .word 0x999999
	
	health: .word 4
	collisions: .word 0	# keep track of collisions with objects
	
	objectSpeed: .word 1

.eqv refreshRate 40
.eqv playerWidth 15
.eqv playerHeight 13
.eqv playerSpeed 2
.eqv healthLocation 31240
.eqv playerWidth 15
.eqv playerHeight 13
.eqv objectWidth 2
.eqv objectHeight 3

.eqv powerupScoreColour		0x0AAFF5
.eqv powerupHealthColour 	0x1AE535

.text
	# setting up registers
	
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0xffffff # $t1 stores the white colour code
	li $t9, 0x16285b # $t9 stores bg colour
	li $t8, 0x999999 # $t1 stores gray

	lw $s2, inputAddress
	la $s5, objects
	la $s6, powerup
	
setup:	jal clear_screen	# clear the screen for resets
	jal reset_objects
	li $t7, 3
	sw $t7, health		# reset health
	li $t7, 1
	sw $t7, objectSpeed 	# reset object speed

	sw $zero, collisions	# reset collisions
	li $s0, 0		# reset game tick
	
	# (x, y) initial values for player model
	li $t3, 26	# x
	li $t4, 111	# y
	
# 	RESERVED REGISTERS
#	t0 : displayAddress
#	t1 : RGB red
#	t2 : RGB white
#	t3 : player x val
#	t4 : player y val
#	t5 : free, typical use for movement calculation
#	t6 : free, typical use for movement caluclation
#	t7 : free
#	t8 : RGB object colour
#	t9 : RGB background colour
#
#	s0 : game tick
#	s1 : 
#	s2 : inputAddress
#	s3 : input boolean
#	s4 : input value
#	s5 : object array
#	s6 : powerup array
#	s7 :

	# sleep before starting
	li $v0, 32
	li $a0, 1000
	syscall
main:	
	jal update_objects
	
	jal draw_player
	
	jal draw_health
	
	lw $s3, 0($s2)	# keypress bool
	lw $s4, 4($s2)	# keypress value
	beq $s3, 1, handle_keypress

	# sleep for refreshRate time
	li $v0, 32
	li $a0, refreshRate
	syscall
	
	addi $s0, $s0, 1	# increment game tick ( used for score and timing )
	beq $s3, 1, handle_keypress
keypress_return:
	j main	# loop

handle_end_keypress:
	beq $s4, 0x70, handle_p
	j ENDLOOP

handle_keypress:
	beq $s4, 0x70, handle_p
	
	# moving
	beq $s4, 0x77, handle_w
	beq $s4, 0x61, handle_a
	beq $s4, 0x73, handle_s
	beq $s4, 0x64, handle_d
	
	beq $s4, 0x71, lower_health	# testing purposes (press q to lower health)
	j keypress_return
	
# game restart
handle_p:
	j setup

# handle player movements	
handle_w:
	bge $t4, 1, move_up
	j keypress_return
move_up:	
	jal clear_player
	subi $t4, $t4, playerSpeed	# move player y up the screen
	j keypress_return
	
handle_s:
	ble $t4, 114, move_down
	j keypress_return
move_down:
	jal clear_player
	addi $t4, $t4, playerSpeed	# move player y down the screen
	j keypress_return
	
handle_a:
	bge $t3, 1, move_left
	j keypress_return
move_left:
	jal clear_player
	subi $t3, $t3, playerSpeed	# move player x left
	j keypress_return
	
handle_d:
	ble $t3, 47, move_right
	j keypress_return
move_right:
	jal clear_player
	addi $t3, $t3, playerSpeed	# move player x right
	j keypress_return

increase_health:
	lw $t5, health
	addi $t5, $t5, 1
	sw $t5, health
	j set_inactive_powerup

lower_health:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t5, health
	subi $t5, $t5, 1	# lower health  by 1
	
	li $t6, 7	# hearts offset
	li $t7, 4	# address size
	mult $t6, $t7
	mflo $t6	# calculates proper pixel offset for 1 heart
	mult $t6, $t5	# multiply by number of hearts
	mflo $t6
	add $a0, $t6, healthLocation
	add $a0, $a0, $t0
	jal clear_heart
	
	beq $t5, 0, END		# goto END if health = 0
	
	sw $t5, health
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

update_objects:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# powerup
	lw $a0, 0($s6)
	lw $a1, 4($s6)
	lw $a2, 8($s6)
	lw $a3, 12($s6)
	jal update_powerup
	sw $a0, 0($s6)
	sw $a1, 4($s6)
	sw $a2, 8($s6)
	sw $a3, 12($s6)
	
	# objects
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
	
	beq $a0, 1, activated_object
	jal spawn_object
	j object_return
activated_object:
	jal clear_object
	jal check_object
	lw $t5, objectSpeed
	add $a2, $a2, $t5		# move object down
	jal draw_object
object_return:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

check_object:
	# collision test against player cords (t3, t4)
	addi $t5, $t3, playerWidth
	bgt $a1, $t5, no_collision_object	# objectX > playerX + playerWidth
	addi $t5, $a1, objectWidth
	blt $t5, $t3, no_collision_object	# objectX + objectWidth < playerX
	addi $t5, $a2, objectHeight
	blt $t5, $t4, no_collision_object	# objectY + objectHeight < playerY
	addi $t5, $t4, playerHeight
	bgt $a2, $t5, no_collision_object	# objectY > playerY + playerHeight
	# there is collision
	lw $t6 collisions
	addi $t6, $t6, 1	# increment number of collisions by 1
	sw $t6, collisions
	jal lower_health
	j set_inactive
no_collision_object:
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

# sets all object values to default (including powerup)
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
	
	sw $zero, 0($s6)
	sw $zero, 4($s6)
	sw $zero, 8($s6)
	sw $zero, 12($s6)

	jr $ra
	
# -------------------------------------------------------------------------------------
	
# update single powerup, takes params (a0, a1, a2, a3) = (active, x, y, type)
update_powerup:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	beq $a0, 1, activated_powerup
	jal spawn_powerup
	j powerup_return
activated_powerup:
	jal clear_powerup
	add $a2, $a2, 1		# move powerup down
	jal check_powerup
	jal draw_powerup
powerup_return:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

check_powerup:
	# collision test against player cords (t3, t4)
	addi $t5, $t3, playerWidth
	bgt $a1, $t5, no_collision_powerup	# objectX > playerX + playerWidth
	addi $t5, $a1, 2
	blt $t5, $t3, no_collision_powerup	# objectX + objectWidth < playerX
	addi $t5, $a2, 2
	blt $t5, $t4, no_collision_powerup	# objectY + objectHeight < playerY
	addi $t5, $t4, playerHeight
	bgt $a2, $t5, no_collision_powerup	# objectY > playerY + playerHeight
	# there is collision
	beq $a3, 1, increase_health
	beq $a3, 2, kill_enemies
	j set_inactive_powerup
no_collision_powerup:
	bge $a2, 125, set_inactive_powerup
	jr $ra
set_inactive_powerup:
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	j powerup_return

# spawn powerup function, takes params (a0, a1, a2, a3) = (active, x, y, type)
spawn_powerup:
	# generate random x value for the object
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 63	   # Select upper bound of random number
	syscall            # Generate random int (returns in $a0)
	
	la $t7, ($a0)	# save random x in t7
	
	li $v0, 42         
	li $a0, 1          
	li $a1, 3	   
	syscall            # Generate random int (returns in $a0)
	
	la $a3, ($a0)	# save random object type in a3
	la $a1, ($t7)	# save random x in a1
	
	li $a2, 0	# y value for object (not adjusted for address)
	li $a0, 1
	jr $ra

kill_enemies:
	# erase all objects
	lw $a0, 0($s5)
	lw $a1, 4($s5)
	lw $a2, 8($s5)
	jal clear_object
	
	lw $a0, 12($s5)
	lw $a1, 16($s5)
	lw $a2, 20($s5)
	jal clear_object
	
	lw $a0, 24($s5)
	lw $a1, 28($s5)
	lw $a2, 32($s5)
	jal clear_object
	
	# reset all object values
	sw $zero, 0($s5)
	sw $zero, 4($s5)
	sw $zero, 8($s5)
	
	sw $zero, 12($s5)
	sw $zero, 16($s5)
	sw $zero, 20($s5)
	
	sw $zero, 24($s5)
	sw $zero, 28($s5)
	sw $zero, 32($s5)
	j set_inactive_powerup
	
clear_screen:
	addi $t5, $t0, 0	# load display addr
	li $t6, 0		# counter for number of pixels passed
	addi $sp, $sp, -4
	sw $ra, 0($sp)
clear_loop:
	sw $t9, ($t5)		# set pixel bg colour
	addi $t5, $t5, 4	# goto next pixel
	addi $t6, $t6, 1	# increment counter
	bgt $t6, 8191, clear_loop_end
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
	beq $s3, 1, handle_end_keypress
	
	# sleep for 100ms
	li $v0, 32
	li $a0, 100
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

# draw powerup function, takes a1 = x val, a2 = y val, a3 = type
draw_powerup:
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
	
	beq $a3, 1, health_colour
	beq $a3, 2, score_colour
health_colour:
	li $t7, powerupHealthColour
	j draw_powerup_jump
score_colour:
	li $t7, powerupScoreColour
	j draw_powerup_jump
draw_powerup_jump:	
	sw $t7, ($t5)
	addi $t5, $t5, 4
	sw $t7, ($t5)
	
	addi $t5, $t5, 252
	sw $t7, ($t5)
	addi $t5, $t5, 4
	sw $t7, ($t5)
	
	jr $ra

# clear object function, takes a1 = x val, a2 = y val
clear_powerup:
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
	
draw_health:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $t5, $t0, healthLocation	# starting cordinate of health location (6th last row)
	lw $t7, health
draw_health_loop:
	ble $t7, 0, draw_health_end
	addi $a0, $t5, 0
	jal draw_heart
	
	subi $t7, $t7, 1
	addi $t5, $t5, 28
	j draw_health_loop
	
draw_health_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# takes (x, y) cords as top left of the heart in a0 = y*256 + 4*x + displayLocation
draw_heart:
	addi $a0, $a0, 4
	
	sw $t1, ($a0)
	addi $a0, $a0, 8
	sw $t1, ($a0)
	
	addi $a0, $a0, 244
	
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	
	addi $a0, $a0, 244
	
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	addi $a0, $a0, 4
	sw $t1, ($a0)
	
	addi $a0, $a0, 252
	
	sw $t1, ($a0)
	
	jr $ra
	
# takes (x, y) cords as top left of the heart in a0 = y*256 + 4*x + displayLocation
clear_heart:
	addi $a0, $a0, 4
	
	sw $t9, ($a0)
	addi $a0, $a0, 8
	sw $t9, ($a0)
	
	addi $a0, $a0, 244
	
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	
	addi $a0, $a0, 244
	
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	addi $a0, $a0, 4
	sw $t9, ($a0)
	
	addi $a0, $a0, 252
	
	sw $t9, ($a0)
	
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
