"""
made by Stephen Guo
Works for images in RGBA format, probably works in RGB format too
you can check by adding:
    print(image.mode)
after opening the image.
"""

from PIL import Image

image = Image.open("title.png")
if image.width != 64:
    print("Width isn't 64px")
    exit()
if image.height != 64:
    print("Height isn't 64px")
    exit()
if (image.mode != "RGB") and (image.mode != "RGBA"):
    print("Image mode:", image.mode, "is incorrect.")
    exit()

arrayName = "Ayaya"  # name for array

print(arrayName + ":\t.word\t", end="")
for x in range(0, 64):
    for y in range(0, 64):
        currentPixel = image.getpixel((y, x))
        hexColor = "0x%02x%02x%02x" % (  # gets current pixel color in hex
            currentPixel[0],
            currentPixel[1],
            currentPixel[2],
        )
        print(hexColor, end=" ")

print("\n")
print("# Starts drawing the title graphic")
print("li $v0, 32		    # syscall for sleeping for 30 ms")
print("li $a0, 30")
print("addi $t0, $zero, BASE_ADDRESS    # register to write pixels to\n")

print("li $t6, 0			# counter for syscall")
print("li $t7, 64 			# canvas width")
print("li $t8, 0 			# number of times to loop")
print("li $t9, 4096 			# width * height\n")
print("la $t1, " + arrayName + "			# loads address for color array")
print(arrayName + "_Loop:")
print("	beq $t8, $t9, " + arrayName + "_Finish 	# exit loops after 4096 iterations")
print("	lw $t2, 0($t1) 		# reads color")
print("	sw $t2, 0($t0) 		# stores color")

print("	addi $t1, $t1, 4 	# increment color array, canvas array")
print("	addi $t0, $t0, 4")
print("	addi $t8, $t8, 1 	# increment both counters")
print("	addi $t6, $t6, 1")

print("	beq $t6, $t7, " + arrayName + "_Pause 	# sleep if written 64 pixels")
print("	j " + arrayName + "_Loop")
print(" " + arrayName + "_Pause:")
print("		li $t6, 0 	# resets counter")
print("		syscall")
print("		j " + arrayName + "_Loop")

print(arrayName + "_Finish:")