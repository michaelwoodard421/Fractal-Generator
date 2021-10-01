.data 0x10000000 ##!
  display: 	.space 65536
  		.align 2
  redPrompt:	.asciiz "Enter a RED color value for the background (integer in range 0-255):\n"
  greenPrompt:	.asciiz "Enter a GREEN color value for the background (integer in range 0-255):\n"
  bluePrompt:	.asciiz "Enter a BLUE color value for the background (integer in range 0-255):\n"
  redSquarePrompt:	.asciiz "Enter a RED color value for the squares (integer in range 0-255):\n"
  greenSquarePrompt:	.asciiz "Enter a GREEN color value for the squares (integer in range 0-255):\n"
  blueSquarePrompt:	.asciiz "Enter a BLUE color value for the squares (integer in range 0-255):\n"
  sizePrompt:	.asciiz "Enter the width in pixels of the first square (Integer power of 2 in the set {1, 2, 4, 8, 16, 32, 64):\n"
  


.text 0x00400000 ##!
main:

	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, redPrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the R value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s0, $0, $v0			# copy N into $s0
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, greenPrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the G value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s1, $0, $v0			# copy N into $s1
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, bluePrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the B value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s2, $0, $v0			# copy N into $s2
 	
 	
 	
 	
 	#############################################
	## Calculate square color and put in       ##
	## appropriate register                    ##
	#############################################

	
	sll $s0, $s0, 16
         sll $s1, $s1, 8

         or $s1, $s2, $s1
         or $s1, $s1, $s0

         li $s0, 0
         li $s3, 16384

	j drawDisplay
	
# Exit from the program
exit:
  ori $v0, $0, 10       		# system call code 10 for exit
  syscall               		# exit the program
	
drawDisplay:
	mul $t3, $s0, 4
	sw $s1, display($t3)
	addi $s0, $s0, 1
	bne $s0, $s3, drawDisplay
	
	
readSquareColors:
	addi	$v0, $0, 4  	
	la 	$a0, redSquarePrompt 
	syscall           	
	# read in the R value
	addi	$v0, $0, 5	
	syscall 		
 	add	$s0, $0, $v0	
 	
 	
 	
 	addi	$v0, $0, 4  			
	la 	$a0, greenSquarePrompt 		
	syscall           			
	# read in the G value
	addi	$v0, $0, 5			
	syscall 				
 	add	$s1, $0, $v0			
 	
 	
 	
 	addi	$v0, $0, 4  		
	la 	$a0, blueSquarePrompt 	
	syscall           		
	# read in the B value
	addi	$v0, $0, 5		
	syscall 			
 	add	$s2, $0, $v0	
 	
 	#############################################
	## Calculate square color and put in       ##
	## appropriate register                    ##
	#############################################
	
	sll $s0, $s0, 16
        sll $s1, $s1, 8

        or $t7, $s2, $s1
        or $t7, $t7, $s0
        
        li $t0, 0
        li $t4, 16384
	
readSize:

	addi	$v0, $0, 4  	
	la 	$a0, sizePrompt 
	syscall           	
	addi	$v0, $0, 5	
	syscall 		
 	add	$s0, $0, $v0
 
 

 	li $t1, 1
 	beq $s0, $t1, sizeOneEdgeCase
 	li $t9, 128
 	li $s7, 2
 	sub $t8, $t9, $s0
 	div $t8, $s7
 	mflo $a3
 	add $a1, $0, $a3 #x
 	add $a2, $0, $a3 #y
 	add $a3, $s0, $0  #size
 
 
  	jal drawSquare # Do not change this line
  	
  	j exit
 
 drawSquare:	# Do not change  this label
 
  #initial fp and sp	
 	addi $sp, $sp, -8
 	sw $ra, 4($sp)
 	sw $fp, 0($sp)
 	addi $fp, $sp, 4

 	
 	#alloc for s temps
 	addi $sp, $sp, -20
 	sw $s3, -8($fp)
 	sw $s4, -12($fp)
 	sw $s5, -16($fp)
	sw $s6, -20($fp)
	sw $s7, -24($fp) 

		
	
 
 
	#create size temps
 	add $s5, $a3, $0 #size
 	srl, $s6, $a3, 1 #size/2
 	srl, $s7, $a3, 2 #size/4
 	
 	#base
 	ble $s5, $t1, return
 	
 	sll $t0, $a2, 7
 	
 	add $t4, $a2, $a3
 	sll $t4, $t4, 7

 	
 	topcolorloop:
 	div $t0, $t9 #divide counter by 128
 	mfhi $t5 #mod val
 	mflo $t2 #div val
 	
 	
 	add $s3, $a1, $a3
 	add $s4, $a2, $a3
 	
 	#mod, x's
 	bge $t5, $s3, skip
 	blt $t5, $a1, skip
 	
 	#div y's
 	bge $t2, $s4, skip
 	blt $t2, $a2, skip

	
	
	sll $t6, $t0, 2
	sw $t7, display($t6)
	
	skip:
		
		addi $t0, $t0, 1
		bne $t0, $t4, topcolorloop




 	 
 	 #####Top Left######
 	#alloc and initialize arguments
 	addi $sp, $sp, -12
	
	sw $a1, 8($sp)
	sw $a2, 4($sp) 
	sw $a3, 0($sp)
	
	#modify args
 	sub $a1, $a1, $s7
 	sub $a2, $a2, $s7
 	sub $a3, $s6, $0
 	
	
 	jal drawSquare
	
	lw $a1, 8($sp)
	lw $a2, 4($sp) 
	lw $a3, 0($sp)
	
	#####Top Right######
 	#initialize arguments
	
	sw $a1, 8($sp)
	sw $a2, 4($sp) 
	sw $a3, 0($sp)
	
	#modify args
 	add $a1, $a1, $s5
 	sub $a1, $a1, $s7
 	sub $a2, $a2, $s7
 	sub $a3, $s6, $0
 	
 	jal drawSquare
 	
	lw $a1, 8($sp)
	lw $a2, 4($sp) 
	lw $a3, 0($sp)
	
	#####Bottom Right######
 	#initialize arguments
	
	sw $a1, 8($sp)
	sw $a2, 4($sp) 
	sw $a3, 0($sp)
	
	#modify args
 	add $a1, $a1, $s5
 	sub $a1, $a1, $s7
 	add $a2, $a2, $s5
 	sub $a2, $a2, $s7
 	sub $a3, $s6, $0
 	
 	jal drawSquare
 	
	lw $a1, 8($sp)
	lw $a2, 4($sp) 
	lw $a3, 0($sp)
 	

	#####Bottom Left######
 	#initialize arguments
	
	sw $a1, 8($sp)
	sw $a2, 4($sp) 
	sw $a3, 0($sp)
	
	#modify args
 	sub $a1, $a1, $s7
 	add $a2, $a2, $s5
 	sub $a2, $a2, $s7
 	sub $a3, $s6, $0
 	
 	jal drawSquare
 	
	lw $a1, 8($sp)
	lw $a2, 4($sp) 
	lw $a3, 0($sp)
 	




		
	return:
	
	
	lw $s3, -8($fp)
 	lw $s4, -12($fp)
 	lw $s5, -16($fp)
	lw $s6, -20($fp)
	lw $s7, -24($fp) 

	
	
       	
       	addi $sp, $fp, 4
       	lw $ra, 0($fp)
       	lw $fp, -4($fp)
	jr $ra
 	
       
       
        	
sizeOneEdgeCase:
	li $t9, 32508
	sw $t7, display($t9)
	j exit
     
     
     
     
     
     
     
     
     
     
     
     
     