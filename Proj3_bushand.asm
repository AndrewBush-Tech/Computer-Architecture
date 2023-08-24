TITLE The Integer Accumulator    (Proj3_bushand.asm)

; Author: Andrew Bush
; Last Modified:02/04/2022
; OSU email address: bushand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:Project03                Due Date:Feb 06 by 11:59pm
; Description: This file displays the program title and programmer’s name.
; Get the user's name, and greet the user.
; Display instructions for the user.
; Repeatedly prompt the user to enter a number.
; Calculate the (rounded integer) average of the valid numbers and store in a variable.

INCLUDE Irvine32.inc
	
	ONE				=	1
	FIFTY			=	50
	ONE_HUNDRED		=	100
	TWO_HUNDRED		=	200

.data

	title_1			BYTE	"Welcome to the Integer Accumulator by Andrew Bush", 0
	intro_1			BYTE	"What is your name? ", 0
	instruction_1	BYTE	"Please enter numbers in [-200, -100] or [-50, -1].", 0
	instruction_2	BYTE	"Enter a non-negative number when you are finished to see results.", 0
	instruction_3	BYTE	"Enter number: ", 0
	entered_number	DWORD	?
	sumNum			DWORD	?
	maxNum			DWORD	?
	minNum			DWORD	?
	avgNum			DWORD	?
	countNum		DWORD	?
	greeting_1		BYTE	"Hello there, ", 0	
	userName		BYTE	33 DUP(0)
	result_1		BYTE	"You entered ", 0
	result_2		BYTE	" valid numbers.", 0
	invalidResult	BYTE	"Number Invalid!", 0
	zeroValidNum	BYTE	"There were no valid numbers entered.", 0
	sum_result		BYTE	"The sum of your valid numbers is ",0
	rounded_avg		BYTE	"The rounded average is ", 0
	max_num			BYTE	"The maximum valid number is ", 0
	min_num			BYTE	"The minimum valid number is ", 0
	goodBye			BYTE	"We have to stop meeting like this. Farewell, ", 0

.code
main PROC

; Display the program title and programmer’s name.

	MOV		EDX, OFFSET title_1					
	CALL	WriteString
	CALL	CrLf

; Get the user's name, and greets the user.

	MOV		EDX, OFFSET intro_1				
	CALL	WriteString
	MOV		EDX, OFFSET userName
	MOV		ECX, 32
	CALL	ReadString
	MOV		EDX, OFFSET greeting_1					
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Displays instructions for the user.

	CALL	CrLf									
	MOV		EDX, OFFSET instruction_1			
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET instruction_2		
	CALL	WriteString
	CALL	CrLf
	SUB		ECX, 33								; Makes sure counter register starts at 0 by making ECX -1

; Repeatedly prompt the user to enter a number.

_negativeNum:									; Loops of negative numbers from user
	INC		ECX		
	MOV		countNum, ECX
	MOV		EDX, OFFSET instruction_3			
	CALL	WriteString
	CALL	ReadInt
	MOV		entered_number, EAX
	JNS		_nonNegative						; Jumps to end if sign flag is clear
	JS		_negativeCheck						; Jumps to recurring loop if sign flag is set

_negativeCheck:									; Checks if the user number is within range of [-50, -1]
	NEG		EAX									; Two's compliment to switch the sign for easier comparing while debugging
	CMP		EAX, FIFTY
	JG		_greaterThanFifty
	CMP		EAX, ONE
	JL		_nonNegative
	NEG		EAX
	MOV		EBX, sumNum
	ADD		EBX, EAX
	MOV		sumNum, EBX
	JMP		_minNumCheck

_greaterThanFifty:								; Checks if the user number is not valid by checking within range [-99, -51]
	CMP		EAX, ONE_HUNDRED
	JGE		_greaterThanEqHundred
	JMP		_invalidNum

_greaterThanEqHundred:							; Checks if the user number is within range of [-200, -100]
	CMP		EAX, TWO_HUNDRED
	JG		_invalidNum
	MOV		EAX, entered_number
	MOV		EBX, sumNum
	ADD		EBX, EAX
	MOV		sumNum, EBX
	JLE		_maxNumCheck

_maxNumCheck:									; Checks if the users number is a maximum number
	MOV		EAX, entered_number
	CMP		ECX, 0
	JE		_newNum
	CMP		EAX, maxNum
	JGE		_newMaxNum
	CMP		EAX, minNum
	JLE		_newMinNum
	JMP		_negativeNum

_minNumCheck:									; Checks if the users number is minimum number
	CMP		ECX, 0
	JE		_newNum
	CMP		EAX, minNum
	JLE		_newMinNum
	CMP		EAX, maxNum
	JGE		_newMaxNum
	JMP		_negativeNum

_newNum:										; Creates a variable for starting number for maximum and minimum
	MOV		minNum, EAX
	MOV		maxNum, EAX
	JMP		_negativeNum

_newMinNum:										; Saves new minimum number in variable
	MOV		minNum, EAX
	JMP		_negativeNum

_newMaxNum:										; Saves new maximum number in variable
	MOV		maxNum, EAX
	JMP		_negativeNum

_invalidNum:									; Displays message of invalid number entered by user
	MOV		EDX, OFFSET invalidResult		
	CALL	WriteString
	CALL	CrLf
	DEC		ECX
	JMP		_negativeNum

; Calculate the (rounded integer) average of the valid numbers and store in a variable.

_avgRoundedNum:									; Gets the average and rounds numbers greater than or equal to .51 up and less than or equal to .50 down
	MOV		EBX, 100
	MOV		EDX, 0
	NEG		sumNum
	MOV		EAX, sumNum
	MUL		EBX									; Moves decimal place over twice by multiplying by 100
	DIV		ECX
	ADD		EAX, 49								; Adds 49 to ensure rounding up one number if over .51
	MOV		EDX, 0
	DIV		EBX
	NEG		EAX
	MOV		avgNum, EAX
	NEG		sumNum
	JMP		_goodBye

; Display Output

_noValidNumbers:
	MOV		EDX, OFFSET zeroValidNum			; Jump if no valid numbers were entered
	CALL	WriteString
	CALL	CrLf
	JMP		_goodBye

_nonNegative:									; Jump if user entered non-negative number
	MOV		EAX, countNum
	CMP		EAX, 0
	JE		_noValidNumbers
	MOV		EDX, OFFSET result_1			
	CALL	WriteString
	CALL	WriteDec
	MOV		EDX, OFFSET result_2
	CALL	WriteString
	CALL	CrLf
	JMP		_avgRoundedNum

_goodBye:										; Says goodbye to user and displays results
	MOV		EAX, maxNum
	MOV		EDX, OFFSET max_num
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

	MOV		EAX, minNum
	MOV		EDX, OFFSET min_num
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

	MOV		EAX, sumNum
	MOV		EDX, OFFSET sum_result
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

	MOV		EAX, avgNum
	MOV		EDX, OFFSET rounded_avg
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf
	CALL	CrLf


	MOV		EDX, OFFSET goodBye				
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	CALL	CrLf

	Invoke ExitProcess,0						; exit to operating system
main ENDP
END main
