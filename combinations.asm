TITLE Project Five   (Project Six B.asm)

; Author: Daniel Mesa
; Last Modified: 12/9/19
; OSU email address: mesad@oregonstate.edu
; Course number/section: CS 271
; Project Number: 6B               Due Date: 12/8/19
; Description:  This program asks the user to calculate the
; number of combinations of r items taken from a set of n. It
; generates a random n [3-12] and a random r [1-n]. The student
; enters the answer and the program reports correct answer and
; validates student answer to right or wrong. The program keeps
; tack of question numbers, right answers nums, and wrong answer nums.
; The program will repeat until student quits.

INCLUDE Irvine32.inc

;----------------------------------------------------------
;MACRO - Receives and prints string
; Receives: addresses of intro strings on system stack
; Returns: none
; Preconditions: none
; Registers Changed: edx
;----------------------------------------------------------
printString		MACRO	buffer
	mov		edx, buffer					; place buffer to call
	call	WriteString					;Print string
ENDM

; (insert constant definitions here)
MAXSIZE = 20		; upper limit of input string
MAX_TERM = 12		; upper limit
MIN_TERM = 3		; lower limit

.data
intro_1		BYTE	"Welcome to the Combinations Calculator",0
intro_2		BYTE	"Programmed by Daniel Mesa.",0
intro_3		BYTE	"I'll give you a combination problem.",0
intro_4		BYTE	"You enter your answer and I'll let you know if you're right.",0
ec_1		BYTE	"**EC: Numbers each problem and keeps score.",0
instruct_1	BYTE	"Problem #",0
instruct_2	BYTE	"Number of elements in the set: ",0
instruct_3	BYTE	"Number of elements to choose from the set: ",0	
instruct_4	BYTE	"How many ways can you choose? ",0
inString	BYTE	MAXSIZE DUP(?)
sLength		DWORD	0
array		DWORD	2 DUP(?)
result		DWORD	1
userNum		DWORD	?
unsorted_1	BYTE	"The unsorted random numbers are: ",0
sorted_1	BYTE	"The sorted list: ",0
median_1	BYTE	"The median is ",0
play_again	BYTE	"Another Problem? (y/n): ",0
playAnswer	BYTE	10 DUP(0)
numOfProbs	DWORD	1
rightWrong	DWORD	2 DUP(0)
result1		BYTE	"There are ",0
result2		BYTE	" combinations of ",0
result3		BYTE	" items from a set of ",0
right1		BYTE	"You are correct!",0
wrong1		BYTE	"Not ",0
wrong2		BYTE	"You need more practice.",0
outro_1		BYTE	"Thank you for using my program!",0
error_1		BYTE	"Invalid input",0
numWrong1	BYTE	"Number of incorrect answers: ",0
numRight1	BYTE	"Number of correct answers: ",0
restart		DWORD	?

.code
main PROC

	; introduction
	push	OFFSET ec_1
	push	OFFSET intro_4
	push	OFFSET intro_3
	push	OFFSET intro_2
	push	OFFSET intro_1
	call intro

	PlayAgain:
	; fill array with random ints
	push	numofProbs
	push	OFFSET instruct_3
	push	OFFSET instruct_2
	push	OFFSET instruct_1	
	push	OFFSET array				
	call	showProblem


	; prompt user for number
	push	OFFSET sLength
	push	OFFSET userNum
	push	OFFSET instruct_4
	push	OFFSET inString				
	push	OFFSET error_1				
	call	getUserData


	;do the calculation
	push	[array]
	push	[array+4]
	push	OFFSET result
	call	combination

	;show the results
	push	OFFSET rightWrong
	push	[array]
	push	[array+4]
	push	result
	push	userNum
	push	OFFSET right1
	push	OFFSET wrong2
	push	OFFSET wrong1
	push	OFFSET result3
	push	OFFSET result2
	push	OFFSET result1
	call	showResult

	; goodbye message
	push	OFFSET restart
	push	OFFSET numRight1
	push	OFFSET numWrong1
	push	OFFSET error_1
	push	[rightWrong]				
	push	[rightWrong+4]				
	push	OFFSET play_again
	push	sLength
	push	OFFSET inString
	push	OFFSET numOfProbs
	push	OFFSET outro_1				
	call	anotherGame

	;check restart
	mov		eax, restart
	cmp		eax, 1
	je		PlayAgain	

	exit								; exit to operating system
main ENDP

;--------------------------------------------------------------------------------------------
; Introduces program title, programmer name, and short description of program.
; Receives: addresses of intro strings on system stack
; Returns: none
; Preconditions: none
; Registers Changed: edx
;--------------------------------------------------------------------------------------------
intro	PROC
	push	ebp							; set up stack frame, save registers
	mov		ebp,esp
	push	edx

	printString	[ebp+8]
	call	CrLf
	printString	[ebp+12]
	call	CrLf
	printString	[ebp+16]
	call	CrLf
	printString	[ebp+20]
	call	CrLf
	printString	[ebp+24]
	call	CrLf


	pop		edx
	pop		ebp
	ret		20
intro ENDP

;--------------------------------------------------------------------------------------------
; Procedure shows the combination problem with two random ints
; Receives: address of string to display, OFFSET of array
; Returns: array filled with random integers
; Preconditions: userNum is within range
; Registers Changed: ebp, edi, ecx, eax
;--------------------------------------------------------------------------------------------
showProblem PROC	

	call	Randomize

	push	ebp						; set up stack frame, save registers
	mov		ebp, esp
	pushad
	mov		edi, [ebp+8]		; edi now holds the start address of array
	mov		ecx, 2				; only two 


	mov		eax, MAX_TERM		; set eax to range using HI-LO+1 before calling RandomRange
	fillRandom:
	sub		eax, MIN_TERM
	inc		eax
	call	RandomRange
	add		eax, MIN_TERM		; add the lower limit to random number so it is in range
	mov		[edi], eax			; save random number in array, eax now holds max term for r, [1-n]
	add		edi, 4				; increase to next address by 4 bytes
	loop	fillRandom

	mov		edi, [ebp+8]		;start at beginning address for array


	printString	[ebp+12]	
	mov		eax, [ebp+24]				; num of problems
	call	WriteDec
	call	CrLf

	printString	[ebp+16]
	mov		eax, [edi]
	call	WriteDec
	call	CrLf

	printString	[ebp+20]
	mov		eax, [edi+4]
	call	WriteDec
	call	CrLf

	popad
	pop		ebp					; restore stack frame and registers
	ret		20
showProblem ENDP

;--------------------------------------------------------------------------------------------
; Procedure to get answer from the user
; Receives: addresses of userNum on system stack
; Returns: user input saved in userNum
; Preconditions: none
; Registers Changed: eax, ecx, edx, ebp, esp
;--------------------------------------------------------------------------------------------
getUserData PROC

;Display instructions for user and prompt user for input
	push	ebp
	mov 	ebp, esp
	pushad

	Reprompt:

	printString	[ebp+16]
	mov 	edx, [ebp+12]				; move address of inString to edx
	mov		ecx, MAXSIZE
	call	ReadString


	mov		ebx, 0
	mov		ecx, eax
	mov		esi, [ebp+12]
	cld

	Counter:
	lodsb							
	cmp		al, 48						;iterate through string to validate
	jl		NotValid
	cmp		al, 57
	jg		NotValid					;otherwise jump to notvalid
	sub		al, 48
	movzx	edi, al
	mov		eax, ebx						
	mov		edx, 10						; multiply each int by 10 
	mul		edx
	add		eax, edi
	mov		ebx, eax
	loop	Counter
	mov		eax, [ebp+20]
	mov		[eax], ebx					; move answer to userNum
	jmp		Valid


	NotValid:
	printString	[ebp+8]					; print invalid
	call	CrLf
	jmp		Reprompt

	Valid:
	popad
	pop		ebp
	ret		20

getUserData ENDP

;--------------------------------------------------------------------------------------------
; Calculates the combination problem
; Receives: values of the two numbers on the array, OFFSET of results
; Returns: result
; Preconditions: the array is filled with two random ints
; Registers Changed: edx
;--------------------------------------------------------------------------------------------

combination		PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		eax, [ebp+16]				; value of n		
	mov		ebx, [ebp+12]				; value of r
	mov		esi, [ebp+8]				; address of result

	;calculate (n-r)!
	sub		eax, ebx
	mov		[esi], eax
	push	[esi]
	push	esi
	call factorial
	mov		ecx, [esi]						; value of (n-r)! in ecx

	;calculate n!
	mov		eax, [ebp+16]					; value of n
	mov		[esi], eax
	push	[esi]
	push	esi
	call	factorial
	mov		eax, [esi]					;value of n! in [ebp+16]
	mov		[ebp+16], eax

	;calculate r!
	mov		ebx, [ebp+12]					; value of r
	mov		[esi], ebx
	push	[esi]
	push	esi	
	call	factorial
	mov		ebx, [esi]						;value of r! in ebx


	;multiply r!(n-r)!
	mov		eax, ecx
	mul		ebx					
	mov		ecx, eax						;value of r!(n-r)! in ecx

	mov		eax, [ebp+16]					;div n!/[r!(n-r)!]
	mov		edx, 0
	div		ecx

	mov		ecx, [ebp+8]					; address of result
	mov		[ecx], eax


	popad
	pop		ebp
	ret		12
combination		ENDP
	
;--------------------------------------------------------------------------------------------
; Procedures that performs the factorial calculation
; Receives: eax, ebx
; Returns: eax
; Preconditions: registers have values
; Registers Changed: eax, ebx, ebp, esp,
;--------------------------------------------------------------------------------------------
factorial	PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		ecx, [ebp+8]				;address of result
	mov		eax, [ebp+12]				; value of num
	

	cmp		eax, 1
	je		BaseCase1
	jl		BaseCase0



	mov		ebx, eax		;
	mov		eax,[ecx]		;Current factorial
	dec		ebx
	mul		ebx				;Current factorial x number n
	mov		[ecx],	eax		;Update factorial


	push	ebx				; n - 1
	push	ecx				; address of result
	call	factorial
	
	jmp		TheEnd

	BaseCase0:
	mov		eax, 1
	mov		[ecx], eax



	BaseCase1:
	TheEnd:
	popad
	pop		ebp
	ret		8
factorial	ENDP


;--------------------------------------------------------------------------------------------
; Procedure to display the results
; Receives: addresses of intro strings for results, OFFSET result
; Returns: none
; Preconditions: none
; Registers Changed: edx
;--------------------------------------------------------------------------------------------
showResult	PROC
	push	ebp
	mov		ebp, esp
	pushad

	;display results
	printString	[ebp+8]
	mov		eax, [ebp+36]					; result
	call	WriteDec

	printString	[ebp+12]
	mov		eax, [ebp+40]					; r
	call	WriteDec

	printString	[ebp+16]
	mov		eax, [ebp+44]					; n
	call	WriteDec
	call	CrLf


	;compare userNum to result

	mov		eax, [ebp+32]					; userNum
	cmp		eax, [ebp+36]					; result
	je		Correct							; jump to correct
	printString	[ebp+20]					; else, incorrect
	call	WriteDec
	call	CrLf
	printString	[ebp+24]
	call	CrLf
	mov		esi, [ebp+48]					; address of rightWrong array (aka right element)
	add		esi, 4							; address of wrong element 
	mov		eax, [esi]						
	inc		eax								; inc wrong element to keep count of wrong answers
	mov		[esi], eax
	jmp		TheEnd

	Correct:
	printString	[ebp+28]
	call	CrLf
	mov		esi, [ebp+48]					; address of rightWrong array (aka right element)
	mov		eax, [esi]							
	inc		eax
	mov		[esi], eax						; inc right element to keep count of right answers

	TheEnd:
	popad
	pop		ebp
	ret		44
showResult	ENDP

;--------------------------------------------------------------------------------------------
; Procedure that asks user if they want to play again, and prompts user for answer
; Receives: OFFSET restart, OFFSET numRight1 OFFSET numWrong1 OFFSET error1, 
; OFFSET play_again, sLength, OFFSET inString, OFFSET numOfProbs ,OFFSET outro_1		
; Returns:  restart, numRight,  numWrong, inString, numOfProbs
; Preconditions: none
; Registers Changed: eax, ebx, ecx, edx, ebp, esp, esi
;--------------------------------------------------------------------------------------------
anotherGame PROC
	push	ebp
	mov		ebp, esp
	pushad
	

	; ask user if they want to play again
	Reprompt:
	printString	[ebp+24]		; play again message


	mov		edx, [ebp+16]		; address of user input string 
	mov		ecx, MAXSIZE		; size limit
	call	ReadString			
	mov		[ebp+20], eax		;move user input size to sLength


	cmp		eax, 1				;if bigger than one
	jne		NotValid			; jump to not valid if larger
	mov		ecx, eax
	mov		esi, [ebp+16]
	cld		

	lodsb						; cmp input to y and n, jump to newProblem if y, quit if n
	cmp		al, 121
	je		NewProblem
	cmp		al, 110
	je		Quit
	jmp		NotValid
	
	
	Quit:
										;show number of correct answers
	printString	[ebp+44]
	mov		eax, [ebp+32]
	call	WriteDec
	call	CrLf

										;show number of incorrect answers		
	printString	[ebp+40]
	mov		eax, [ebp+28]
	call	WriteDec
	call	CrLf

										;display goodbye message
	printString	[ebp+8]
	call	CrLf

										;change restart to 2(no)
	mov		eax, [ebp+48]
	mov		ebx, 2
	mov		[eax], ebx
	jmp		TheEnd



	NewProblem:
										; inc number of problems
	mov		eax, [ebp+12]
	mov		ebx, [eax]	
	inc		ebx
	mov		[eax], ebx
	
										; change restart to 1(yes)
	mov		eax, [ebp+48]
	mov		ebx, 1
	mov		[eax], ebx
	jmp		TheEnd



	NotValid:
	printString	[ebp+36]
	call	CrLf
	jmp		Reprompt

	TheEnd:
	popad
	pop		ebp
	ret		44
anotherGame ENDP

END main