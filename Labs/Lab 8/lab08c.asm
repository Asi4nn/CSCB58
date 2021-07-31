# Si Wang (wangsi97)

# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000

.text
j main

# starter code
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x00ff00 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code
sw $t1, 0($t0) # paint the first (top-left) unit red.
sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?
Exit:
li $v0, 10 # terminate the program gracefully
syscall

main:
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0xffffff # $t1 stores the red colour code
	
	# sort by row
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	
	sw $t1, 320($t0)
	
	sw $t1, 420($t0)
	sw $t1, 444($t0)
	sw $t1, 448($t0)
	sw $t1, 452($t0)
	sw $t1, 476($t0)
	
	sw $t1, 548($t0)
	sw $t1, 552($t0)
	sw $t1, 556($t0)
	sw $t1, 560($t0)
	sw $t1, 564($t0)
	sw $t1, 568($t0)
	sw $t1, 572($t0)
	sw $t1, 576($t0)
	sw $t1, 580($t0)
	sw $t1, 584($t0)
	sw $t1, 588($t0)
	sw $t1, 592($t0)
	sw $t1, 596($t0)
	sw $t1, 600($t0)
	sw $t1, 604($t0)
	
	sw $t1, 676($t0)
	sw $t1, 680($t0)
	sw $t2, 684($t0)
	sw $t2, 688($t0)
	sw $t1, 692($t0)
	sw $t1, 696($t0)
	sw $t1, 700($t0)
	sw $t1, 704($t0)
	sw $t1, 708($t0)
	sw $t1, 712($t0)
	sw $t1, 716($t0)
	sw $t2, 720($t0)
	sw $t2, 724($t0)
	sw $t1, 728($t0)
	sw $t1, 732($t0)
	
	sw $t1, 804($t0)
	sw $t1, 808($t0)
	sw $t2, 812($t0)
	sw $t2, 816($t0)
	sw $t1, 820($t0)
	sw $t1, 824($t0)
	sw $t1, 828($t0)
	sw $t1, 832($t0)
	sw $t1, 836($t0)
	sw $t1, 840($t0)
	sw $t1, 844($t0)
	sw $t2, 848($t0)
	sw $t2, 852($t0)
	sw $t1, 856($t0)
	sw $t1, 860($t0)
	
	sw $t1, 932($t0)
	sw $t1, 936($t0)
	sw $t1, 940($t0)
	sw $t1, 944($t0)
	sw $t1, 948($t0)
	sw $t1, 952($t0)
	sw $t1, 956($t0)
	sw $t1, 960($t0)
	sw $t1, 964($t0)
	sw $t1, 968($t0)
	sw $t1, 972($t0)
	sw $t1, 976($t0)
	sw $t1, 980($t0)
	sw $t1, 984($t0)
	sw $t1, 988($t0)
	
	sw $t1, 1084($t0)
	sw $t1, 1088($t0)
	sw $t1, 1092($t0)
	
	sw $t1, 1212($t0)
	sw $t1, 1216($t0)
	sw $t1, 1220($t0)
	
	sw $t1, 1340($t0)
	sw $t1, 1344($t0)
	sw $t1, 1348($t0)
	
	sw $t1, 1468($t0)
	sw $t1, 1472($t0)
	sw $t1, 1476($t0)
	
	sw $t1, 1588($t0)
	sw $t1, 1592($t0)
	sw $t1, 1596($t0)
	sw $t1, 1600($t0)
	sw $t1, 1604($t0)
	sw $t1, 1608($t0)
	sw $t1, 1612($t0)
	
	sw $t1, 1716($t0)
	sw $t1, 1720($t0)
	sw $t1, 1724($t0)
	sw $t1, 1728($t0)
	sw $t1, 1732($t0)
	sw $t1, 1736($t0)
	sw $t1, 1740($t0)