#Cam Makin
#CMPEN 351 Final Project - Connect 4
#Due Date: 12/13/17 11:00AM

#################################################################################################################################
## Welcome to my CMPEN 351 - Microprocessors Final Project!
## I decided to recreate the Connect 4 Game
## Motivation to create this game was that we were instructed to create a game that would take approx. 3 weeks worth of lab time.
## Also, the best way to demonstrate literacy in a programming language is by creating a game!
## To properly set this game up: Set the MARS Bitmap settings to 8x8 pixels with a 512x512 display and connect to heap base memory
## User Input is taken from the physical keyboard (No keyboard polling bologna)
## Enjoy!
#################################################################################################################################
.data
ColorTable:	#Used to find the HEX value of the colors in Connect 4
 .word 0x0000FF #[0] Blue   0x0000FF	Gridlines
 .word 0xFF0000 #[1] Red    0xFF0000	Player 1 Chip
 .word 0xE5C420 #[2] Gold   0xE5C420	Player 2 Chip
 .word 0xFFFFFF #[3] White  0xFFFFFF	Background


#8px Diameter circle table comprised of TWO values of importance
#First value is an X-Offset that will take the value of X given for the circle and add the offset to see..
#..where the Horizontal Line generator should begin.
#Second Value is the length of the Horizontal line to create. Basically, a circle is...
#..a bunch of horizontal lines of increasing then decreasing length 
CircleTable: 
	.word 2, 4, 1, 6, 0, 8, 0, 8, 0, 8, 0, 8, 1, 6, 2, 4

boardArray: .byte 0:42	#This will be the array that represents the gameboard: 0=Empty 1=Player1 2=Player2
prompt0: .asciiz "Welcome to Connect 4!\nThis is a MIPS version of the classic 2 player board game Connect 4.\nThe game will begin with Player 1's turn.\nEnter 1-7 to choose which column to place the game piece in.\nOnce Player 1 goes, Player 2 may then take their turn.\nThe game will automatically alternate user turns so be patient and once you see the game peice placed on the Bitmap it is time for the other player to take their turn!\n\nHave fun!\n\n"
prompt1: .asciiz "\nPlayer 1's turn: "
prompt2: .asciiz "\nPlayer 2's turn: "
prompt3: .asciiz "Player 1 Wins!\n"
prompt4: .asciiz "Player 2 Wins!\n"
prompt5: .asciiz "Please enter a number between 1 and 7 (inclusive)\n"
prompt6: .asciiz "The column you have chosen is full. Select a different column\n"
prompt7: .asciiz "It's a Tie!\n"

.text

#Draw Gamboard
jal DrawGameBoard

#Load Welcome Prompt
la $a0, prompt0	
li $v0, 4
syscall

################################  Begin Main ################################ 
main:

#Get Player 1 Input
playerOne:
la $a0, prompt1
li $v0, 4
syscall
li $v0, 5
syscall

#Place User Input into Array and Error Check
li $a0, 1
jal StoreInput

#Draw Player 1 "Chip" (Box)
li $a0, 1
jal DrawPlayerChip

#Check for Player 1 "Connect 4"
#If found, go to Player 1 win
#If not found, continue game
jal WinCheck

#Get Player 2 Input
playerTwo:
la $a0, prompt2
li $v0, 4
syscall
li $v0, 5
syscall

#Place User Input into Array
li $a0, 2
jal StoreInput

#Draw Player 1 "Chip" (Box)
li $a0, 2
jal DrawPlayerChip

#Check for Player 2 "Connect 4"
#If found, go to Player 2 win
#If not found, go back to Player 1 turn
jal WinCheck

j main	#Play next set of turns
################################  End Main ################################ 



################################  Begin All Drawing Procedures ################################ 
#Procedure: DrawPlayerChip
#Input: $a0 - Player Number
#Input: $v0 - Slot Number (0-41)
#Will format player data then DrawCircle
DrawPlayerChip:
	
	addiu $sp, $sp, -12
	sw $ra, ($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	
	#Move chip color from Player Number
	move $a2, $a0
	
	#Calculate Address
	li $t0, 7
	div $v0, $t0
	mflo $t0	#Division (Y)
	mfhi $t1	#Remainder(X)

	#Y-Address = 63-[(Y+1)*9+4] = 50-9Y
	li $t2, 50
	mul $t0, $t0, 9
	mflo $t0
	sub $t0, $t2, $t0 #Final Y address is in $t0
	
	#X-Address = [X*9]+1
	mul $t1, $t1, 9
	addi $t1, $t1, 1
	
	#Copy address to $a registers for procedure call
	move $a0, $t1
	move $a1, $t0
	
	jal DrawCircle
	
	lw $v0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

#Procedure: DrawGameBoard
#Will draw the blank gameboard
DrawGameBoard:
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#White Background
	li $a0, 0
	li $a1, 0
	li $a2, 3	#White
	li $a3, 64
	jal DrawBox
	
	#Top bar
	li $a0, 0	#Start at X = 0
	li $a1, 0	#Start ar Y = 0
	li $a2, 0	#Blue
	li $a3, 64	#64 pixels wide
	jal DrawHorz
	li $a1, 1
	jal DrawHorz
	li $a1, 2	
	jal DrawHorz
	li $a1, 3	
	jal DrawHorz
	li $a1, 4	
	jal DrawHorz
	
	#Bottom Bar
	li $a0, 0	#Start at X = 0
	li $a1, 58	#Start ar Y = 57
	li $a2, 0	#Blue
	li $a3, 64	#64 pixels wide
	jal DrawHorz
	li $a1, 59
	jal DrawHorz
	li $a1, 60	
	jal DrawHorz
	li $a1, 61	
	jal DrawHorz
	li $a1, 62	
	jal DrawHorz
	li $a1, 63	
	jal DrawHorz


	#Vertical Lines 
	li $a0, 0	#Start at X = 0
	li $a1, 0	#Start ar Y = 0
	li $a2, 0	#Blue
	li $a3, 64	#64 pixels wide
	jal DrawVert	
	li $a0, 9	#(X = 9)
	jal DrawVert
	li $a0, 18	#(X = 18)
	jal DrawVert
	li $a0, 27	#(X = 27)
	jal DrawVert
	li $a0, 36	#(X = 36)
	jal DrawVert
	li $a0, 45	#(X = 45)
	jal DrawVert
	li $a0, 54	#(X = 54)
	jal DrawVert
	li $a0, 63	#(X = 63)
	jal DrawVert

	#Horizontal Lines
	li $a0, 0	#Start at X = 0
	li $a1, 13	#Start ar Y = 13
	li $a2, 0	#Blue
	li $a3, 64	#64 pixels wide
	jal DrawHorz
	li $a1, 22
	jal DrawHorz
	li $a1, 31	
	jal DrawHorz
	li $a1, 40	
	jal DrawHorz
	li $a1, 49	
	jal DrawHorz

	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra


#Procedure: DrawCircle
#Input - $a0 = X 
#Input - $a1 = Y
#Input - $a2 = Color (0-5)
#Will draw a circle with given parameters
DrawCircle:
	#Save room in stack pointer
	addiu $sp, $sp, -28 	#Make room for 7 words
	#Save $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	li $s2, 0	#Counter
	
CircleLoop:
	la $t1, CircleTable
	addi $t2, $s2, 0	#Copy counter for table serach
	mul $t2, $t2, 8		#Using counter value, shift to adjust for table's 2 arguments per 1 instance
	add $t2, $t1, $t2	#Get X-Offest array index [base + counter*4]
	lw $t3, ($t2)		#Load offset into $t3
	add $a0, $a0, $t3	#Add X-Offset to Current X
	
	addi $t2, $t2, 4	#Move to HorzLine length in array
	lw $a3, ($t2)		#Load line length 
	sw $a1, 4($sp)		#Save $a1
	sw $a3, 0($sp)		#Save $a3
	sw $s2, 24($sp)		#Save counter
	jal DrawHorz
	
	#Restore $a0-3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	lw $s2, 24($sp)
	addi $a1, $a1, 1	#Increment Y value
	addi $s2, $s2, 1	#Increment counter
	bne $s2, 8, CircleLoop	#Keep looping until counter = 50 (50 horizontal lines in 1 circle)
	
	
	#Restore $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 28	#Reset $sp
	jr $ra
	
#Procedure: DrawBox
#Input - $a0 = X 
#Input - $a1 = Y
#Input - $a2 = Color (0-5)
#Input - $a3 = Box Width
#Will draw a box with the given parameters
DrawBox:
	addiu $sp, $sp, -24 	#Make room for 6 words
	#Save $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	move $s0, $a3		#Copy $a3 -> $s0
	
BoxLoop:
	sw $a1, 4($sp)	#Save $a1
	sw $a3, 0($sp)	#Save $a3
	jal DrawHorz
	
	#Restore $a0-3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	addi $a1, $a1, 1	#Increment Y value
	addi $s0, $s0, -1	#Decrement the width/length (since box)
	bne $zero, $s0, BoxLoop	#Keep looping until counter=0
	
	#Restore $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 24	#Reset $sp
	jr $ra
	
#Procedure: DrawHorz
#Input - $a0 = X 
#Input - $a1 = Y
#Input - $a2 = Color (0-5)
#Input - $a3 = Box Width
#Uses the DrawDot procedure to draw dots in a horizontal fashion
DrawHorz:
	addiu $sp, $sp, -28
	#Save $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
HorzLoop:
	#Save $a0, $a3 (changes with next procedure call)
	sw $a0, 4($sp)
	sw $a3, 0($sp)
	jal DrawDot
	#Restore all but $ra
	lw $a0, 4($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		#Decrement the width
	addi $a0, $a0, 1		#Increase X value
	bnez $a3, HorzLoop		#If width > 0, keep looping	
	lw $ra, 16($sp)			#Restore $ra
	lw $a0, 20($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		#Restore $sp
	jr $ra
	
#Procedure: DrawVert
#Input - $a0 = X 
#Input - $a1 = Y
#Input - $a2 = Color (0-5)
#Input - $a3 = Box Width
#Uses the DrawDot procedure to draw dots in a vertical fashion
DrawVert:
	addiu $sp, $sp, -28
	#Save $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
VertLoop:
	#Save $a0, $a3 (changes with next procedure call)
	sw $a1, 4($sp)
	sw $a3, 0($sp)
	jal DrawDot
	#Restore all but $ra
	lw $a1, 4($sp)
	lw $a0, 20($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		#Decrement the width
	addi $a1, $a1, 1		#Increase Y value
	bnez $a3, VertLoop		#If width > 0, keep looping	
	lw $ra, 16($sp)			#Restore $ra
	lw $a1, 12($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		#Restore $sp
	jr $ra
	
#Procedure: DrawDot
#Input - $a0 = X
#Input - $a1 = Y
#Input - $a2 = Color (0-5)
#Draws a dot on the Bitmap by saving a color's hex value to the memrory address associated with the bitmap
DrawDot:
	addiu $sp, $sp, -8
	#Save $ra, $a2
	sw $ra, 4($sp)
	sw $a2, 0($sp)
	jal CalcAddress		#Calculate memory address to write to
	lw $a2, 0($sp)		#Load $a2
	sw $v0, 0($sp)		#Save $v0
	jal GetColor		#Retreive Hex vale of color
	lw $v0, 0($sp)		#Restore $v0
	sw $v1, ($v0)		#Write the color value to the proper memory address
	lw $ra, 4($sp)		#Restore $ra
	addiu $sp, $sp, 8	#Reset $sp
	jr $ra


#Procedure: CalcAddress
#Input - $a0 = X
#Input - $a1 = Y
#Output - $v0 = actual memory address to draw dot
CalcAddress:
	sll $t0, $a0, 2			#Multiply X by 4
	sll $t1, $a1, 8			#Multiply Y by 64*4 (512/8= 64 * 4 words)
	add $t2, $t0, $t1		#Add 
	addi $v0, $t2, 0x10040000	#Add base (heap value)
	jr $ra

#Procedure: GetColor
#Input - $a2 = Color Value (0-5)
#Output - $v1 = Hex color value
#Returns the hex value of requested color
GetColor:
	la $t0, ColorTable	#Load color table
	sll $a2, $a2, 2		#Shift left by 2 (x4)
	add $a2, $a2, $t0	#Add base
	lw $v1, ($a2)		#Load color value to $v1
	jr $ra

################################  End All Drawing Procedures ################################ 


#Procedure: StoreInput
#Input: User entered value - $v0
#Input: Player Number (1 or 2) - $a0
#Output: Box Number ($v0)
#Will determine which exact array location to place user input and store it into array
StoreInput:
	addiu $v0, $v0, -8	#Convert user input into Array notation(-1) and subtract for nextCheck Loop(-7)
	bltu $v0, -7, OOBError
	bgtu $v0, -1, OOBError
	
	#Find out (in the column) where the next available row is
	nextCheck:
	addiu $v0, $v0, 7	#Increment row
	bgtu $v0, 41, ColumnFull#If column is full go to error
	lb $t1, boardArray($v0)	#Load byte from boardArray that user has chosen
	bnez $t1, nextCheck	#If loaded byte is NOT EMPTY(1 or 2) then try next row up (add 7 to array index)
	
	#Only reach here if boardArray(base + offset) = 0
	sb $a0, boardArray($v0)	#Place player number into boardArray at location player's chip will end
	
	jr $ra	#Finished Procedure Successfully
	
	#Out of Bounds Error Catching
	OOBError:
	move $t0, $a0
	la $a0, prompt5
	li $v0, 4
	syscall
	move $a0, $t0
	j returnToPlayer
	
	#Column Full Error Catching
	ColumnFull:
	move $t0, $a0
	la $a0, prompt6
	li $v0, 4
	syscall
	move $a0, $t0
	
	returnToPlayer:
	beq $a0, 1, playerOne
	beq $a0, 2, playerTwo
	
################################  Begin WinCheck ################################ 
#Procedure: WinCheck
#Input: $a0 - Player Number
#Input: $v0 - Last location offset chip was placed
#Will deterine is the current player's move have triggered a win using DFS
WinCheck:    	
     	#Must check FOUR different directions a win can happen:
     	#1. Horizontal Line
     	#2. Vertical Line
     	#3. Forward Slash
     	#4. Backward Slash
    	
     	#5. Check for Full Board (Tie)
     	addiu $sp, $sp, -4
     	sw $ra, ($sp)
     	
        li $t8, 7		#Constant 7 used for modulo divison for left-most and right-most checking
          	 	
    	#-----------------Check horizontal-----------------#
     	#From start, go LEFT as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching LEFT
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching RIGHT
        checkLeft:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the leftmost slot, skip to check right
     	div $t2, $t8
     	mfhi $t3		#The modulo result of offset value % 7 
     	beqz $t3, checkRight	#If result = 0 then go to check right
     	
     	#Else look at slot to our left
     	lb $t1, -1($t0)			#Left of current location
     	bne $t1, $a0, checkRight	#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next left
     	addiu $t2, $t2, -1
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkLeft
     	
     	#From start, go RIGHT as far possible
	checkRight:
	la $t0, boardArray($t4)
	
	#If we are at rightmost slot, end horizontal checking
	div $t4, $t8
	mfhi $t3
	beq $t3, 6, endHorz	#If modulo result = 6 then we know we are in rightmost slot
	
	#Else look at slot to our right
	lb $t1, 1($t0)		#Right of current location
	bne $t1, $a0, endHorz	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, 1	#Move to next value to the right
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkRight
	
	endHorz:
	#-----------------End Horizontal Check-----------------#
	
     	
     	#-----------------Check vertical-----------------#
     	#From start, go UP as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UP
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DOWN
        checkUp:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row, skip to checkDown
     	bgtu $t2, 34, checkDown	#If our offset is greater than 34 that means we are on the top row
     	
     	#Else look at slot above us
     	lb $t1, 7($t0)			#Left of current location
     	bne $t1, $a0, checkDown		#If value is not equal to player number, then proceed to check down
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next row up
     	addiu $t2, $t2, 7
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUp
     	
     	#From start, go DOWN as far possible
	checkDown:
	la $t0, boardArray($t4)
	
	#If we are at bottom row, end vertical checking
	bltu $t4, 7, endVert
	
	#Else look at slot below us
	lb $t1, -7($t0)		#Below current location
	bne $t1, $a0, endVert	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -7	#Move to next value below current location
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDown
	
	endVert:  
     	#-----------------End Vertical Check-----------------#
     	
     	
     	
     	
     	#-----------------Check forward-slash diagonal-----------------#
	#From start, go UP-RIGHT (UR) as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UR
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DL
        checkUR:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row OR we are at the rightmost coloumn, then skip to down-left
     	bgtu $t2, 34, checkDL	#If our offset is greater than 34 that means we are on the top row
	div $t2, $t8
	mfhi $t3
	beq $t3, 6, checkDL	#If modulo result = 6 then we know we are in rightmost slot
     	
     	#Else look at slot above us and over to the right 
     	lb $t1, 8($t0)			#UR of current location
     	bne $t1, $a0, checkDL		#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next value in pattern
     	addiu $t2, $t2, 8
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUR
     	
     	#From start, go DOWN-LEFT (DL) as far possible
	checkDL:
	la $t0, boardArray($t4)
	
	#If we are at bottom row OR leftmost column, then end FSDiag checking
	bltu $t4, 7, endFSDiag	#Bottom row test
	div $t4, $t8
	mfhi $t3
	beq $t3, 0, endFSDiag	#Leftmost column test
	
	#Else look at slot below us and over to the left one
	lb $t1, -8($t0)		#DL of current location
	bne $t1, $a0, endFSDiag	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -8	#Move to next value
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDL
	
	endFSDiag:  
     	#-----------------End Forward-Slash Diagonal Check-----------------#
     	
     	
     	
     	
     	#-----------------Check backward-slash diagonal-----------------#
	#From start, go UP-LEFT (UL) as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UL
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DR
        checkUL:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row OR we are at the leftmost coloumn, then skip to down-right
     	bgtu $t2, 34, checkDR	#Top row test
	div $t2, $t8
	mfhi $t3
	beq $t3, 0, checkDR	#Left-most column test
     	
     	#Else look at slot above us and over to the left 
     	lb $t1, 6($t0)			#Up and Left of current position
     	bne $t1, $a0, checkDR		#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next value in pattern
     	addiu $t2, $t2, 6
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUL
     	
     	#From start, go DOWN-RIGHT (DR) as far possible
	checkDR:
	la $t0, boardArray($t4)
	
	#If we are at bottom row OR rightmost column, then end BSDiag checking
	bltu $t4, 7, endBSDiag	#Bottom row test
	div $t4, $t8
	mfhi $t3
	beq $t3, 6, endBSDiag	#Right-most column test
	
	#Else look at slot below us and over to the right one
	lb $t1, -6($t0)		#BR of current location
	bne $t1, $a0, endBSDiag	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -6	#Move to next value
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDR
	
	endBSDiag:     	
     	#-----------------End Backward-Slash Diagonal Check-----------------#
     	
     	#-----------------Start Full Board Check-----------------#
     	li $t9, 35		#Load the offset for the top row of the gameboard
     	la $t0, boardArray($t9)
     	
     	li $t2, 0		#Counter for # of player chips in top row
    	checkTop:
    	lb $t1, ($t0)
    	beqz $t1, endTie	#If a blank slot is found then stop checking
    	addi $t0, $t0, 1
    	add $t2, $t2, 1	
    	beq $t2, 7, GameTie	#If there are 7 chips in top row, it's a tie
    	j checkTop	
    
    	endTie:
     	#-----------------End Full Board Check-----------------#
	
	lw $ra, ($sp)
	addiu $sp, $sp, 4	
	jr $ra	#Return to game after all checks are made
	

################################  End WinCheck ################################ 

#Sub-Procedure: GameTie
#Triggered when the top row of game board is filled and no one is a winner
GameTie:
	la $a0, prompt7
	li $v0, 4
	syscall
	li $v0, 10
	syscall


#Procedure: PlayerWon
#Input: $a0 - Player Number
#Triggered when a player wins a game
#Will show winner message then exit program
PlayerWon:
	beq $a0, 1 player1Win	#If player 1 won, jump to second instruction set
	
	#Player 2 Won
	la $a0, prompt4
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
	#Player 1 Won
	player1Win:
	la $a0, prompt3
	li $v0, 4
	syscall
	li $v0, 10
	syscall










