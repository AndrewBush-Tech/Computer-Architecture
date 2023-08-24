TITLE Generating, Sorting, and Counting Random integers    (Proj5_bushand.asm)

; Author: Andrew Bush
; Last Modified: FEB 27
; OSU email address: bushand@oregonstate.edu
; Course number/section:271   CS271 Section 400
; Project Number: 05               Due Date: FEB 27 by 11:59pm
; Description:program generates 200 random numbers in the range [15 ... 50], displays the
;		original list, sorts the list, displays the median value of the list, displays the 
;		list sorted in ascending order, then displays the number of instances of each 
;		generated value, starting with the number of 15s.

INCLUDE Irvine32.inc

ARRAYSIZE	= 200
LO			= 15
HI			= 50

.data

intro1				BYTE	"Generating, Sorting, and Counting Random integers! Programmed by Andrew Bush", 13,10,13,10,0
intro2				BYTE	"This program generates 200 random numbers in the range [15 ... 50], displays the", 13,10
					BYTE	"original list, sorts the list, displays the median value of the list, displays the", 13,10
					BYTE	"list sorted in ascending order, then displays the number of instances of each", 13,10
					BYTE	"generated value, starting with the number of 15s.", 13, 10, 0
unsortedListTitle	BYTE	"Your unsorted random numbers:", 13,10,0
sortedListTitle		BYTE	"Your sorted random numbers:", 13,10,0
medianTitle			BYTE	"The median value of the array: ",0
countTitle			BYTE	"Your list of instances of each generated number, starting with the number of 15s:", 13,10,0
farewell_message	BYTE	"Goodbye, and thanks for using this program!", 0
numSpace			BYTE	" ", 0
randArray			DWORD	ARRAYSIZE DUP(?)
countArray			DWORD	ARRAYSIZE DUP(?)


.code
main		PROC
				
	PUSH		OFFSET intro1
	PUSH		OFFSET intro2
	CALL		introduction

	CALL		Randomize
	PUSH		OFFSET randArray
	CALL		fillArray

	PUSH		OFFSET numSpace
	PUSH		OFFSET unsortedListTitle
	PUSH		OFFSET randArray
	CALL		displayList

	PUSH		OFFSET randArray
	CALL		sortList

	PUSH		OFFSET medianTitle
	PUSH		OFFSET randArray
	CALL		displayMedian

	PUSH		OFFSET numSpace
	PUSH		OFFSET sortedListTitle
	PUSH		OFFSET randArray
	CALL		displayList

	PUSH		OFFSET countArray
	PUSH		OFFSET randArray
	CALL		countList

	PUSH		OFFSET numSpace
	PUSH		OFFSET countTitle
	PUSH		OFFSET countArray
	CALL		displayList

	PUSH		OFFSET farewell_message
	CALL		farewell

	Invoke ExitProcess,0							; exit to operating system
main		ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: introduction
;
;	Procedure to introduce the program.
;
;	Preconditions: intro1 is a string that displays title and name of programmer, and intro2 is a string that describes what the program does.
;
;	Postconditions: none
;
;	Recieves:	
;		[EBP+8]			= intro with instructions
;		[EBP+12]		= intro with title and programmer				
;
;	returns: String of programmer and instructions for user.
;---------------------------------------------------------------------------------------------------------------------------------------
introduction PROC
	
	PUSH		EBP
	MOV			EBP, ESP
	PUSH		EDX
	MOV			EDX, [EBP+12] 					
	CALL		WriteString							; writes intro and displays programmers name and program title
	MOV			EDX, [EBP+8]
	CALL		WriteString							; writes instructions of program
	CALL		CrLf

	POP			EDX
	POP			EBP
	RET			8

introduction ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: fillArray
;
;	Procedure generates a random array list.
;
;	Preconditions: Randomize is called before the procedure and empty array the size of 200.
;
;	Postconditions: Array filled with randomized numbers.
;
;	Recieves:	
;		[EBP+8]			= empty random array the size of 200
;		ARRAYSIZE, HI, and LO are global constants
;
;	returns: randArray	= filled array of 200 random numbers
;---------------------------------------------------------------------------------------------------------------------------------------
fillArray	PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		ESI									
	PUSH		ECX
	PUSH		EAX

	MOV			ESI, [EBP+8]						
	MOV			ECX, ARRAYSIZE						; loop the size of 200

_fillArrLoop:
	MOV			EAX, HI					
	SUB			EAX, LO
	ADD			EAX, 1								
	CALL		RandomRange							; creates a number below 35
	ADD			EAX, LO								; adds 15 to bring number into range
	MOV			[ESI], EAX							; moves number into empty array spot
	ADD			ESI, 4								; moves spot in array
	LOOP		_fillArrLoop
	CALL		CrLf

	POP			EAX									; restores registerd
	POP			ECX							
	POP			ESI
	POP			EBP
	RET			4
	
fillArray	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: displayList
;
;	Procedure that displays a list of Arrays for user in rows of 20 numbers or less.
;		
;	Preconditions: An array and title explaining the array, and a string that holds space between numbers.
;
;	Postconditions: Displayed array with rows of 20 or less.
;
;	Recieves:	
;		[EBP+8]			= array with random numbers
;		[EBP+12]		= string with title explaining array
;		[EBP+16]		= string with spaces for number placement
;		ARRAYSIZE is a global constants
;
;	returns: randArray	= an array with rows of 20.
;---------------------------------------------------------------------------------------------------------------------------------------
displayList	PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		EAX
	PUSH		EDX
	PUSH		ECX
	PUSH		ESI
	PUSH		EBX

	MOV			ESI, [EBP+8]						
	MOV			EDX, [EBP+12]						; displays title of array to user
	CALL		WriteString
	MOV			ECX, ARRAYSIZE						
	DEC			ECX									; set loop count 1 less than array size to ensure number isn't 0 when it's subtracted	

_PrintArr:
	MOV			EBX, 0								
	CMP			[ESI], EBX
	JE			_ignoreNum							; jumps over zeros so they dont display in count array
	MOV			EAX, [ESI]							
	CALL		WriteDec							; displays number in array
	MOV			EDX, [EBP+16]						
	CALL		WriteString							; creates space between number

_ignoreNum:
	PUSH		EBX									; once again preserved the registers for use
	PUSH		ECX
	PUSH		EAX
	MOV			EAX, ARRAYSIZE						
	SUB			EAX, ECX							
	MOV			EDX, 0
	MOV			EBX, 20	
	DIV			EBX									
	CMP			EDX, 0								; determines if on 20th number and skips carriage return line feed if so	
	JNE			_noSpace		
	MOV			EBX, 0								; jumps over zeros so they dont display in count array
	CMP			[ESI], EBX
	JE			_noSpace
	CALL		CrLf								; carriage return line feed since divisible by 20, remainder EDX = 0 and array number wasn't 0

_noSpace:
	POP			EAX									; retsores registers from above loop
	POP			ECX
	POP			EBX
	ADD			ESI, 4								; moves to next number in random array
	LOOP		_PrintArr
	MOV			EBX, 0								
	CMP			[ESI], EBX
	JE			_skipNum							; jumps over zeros so they dont display in count array

	MOV			EAX, [ESI]          
	CALL		WriteDec							; displays last number since the count was 1 less than the array size
	
_skipNum:
								
	CALL		CrLf								; for space between array and next procedure
	CALL		CrLf

	POP			EBX									; restores registers
	POP			ESI
	POP			ECX
	POP			EDX
	POP			EAX
	POP			EBP

	RET			8

displayList	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: sortList
;
;	Procedure that sorts array in ascending order using bubble sort.
;		
;	Preconditions: Random array within the array size.
;
;	Postconditions: Sorted array of numbers from smallest to biggest.
;
;	Recieves:	
;		[EBP+8]			= array with random numbers
;		ARRAYSIZE is a global constants
;
;	returns: randArray	= array in ascending order
;---------------------------------------------------------------------------------------------------------------------------------------
sortList	PROC

	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		ECX
	PUSH		ESI
	PUSH		EAX

	MOV			ECX, ARRAYSIZE						; outer loop with 1 less than array size
	DEC			ECX
	
_outerLoop:
	PUSH		ECX									
	MOV			ESI, [EBP+8]						; moves array into ESI

_nestedLoop:
	MOV			EAX, [ESI]							
	CMP			[ESI+4], EAX						; compares number with next number in the array and jumps if greater or equal
	JGE			_resetLoops
	CALL		exchangeElements					; calls nested procedure for exchange

_resetLoops:
	ADD			ESI, 4								; moves to next number in array
	LOOP		_nestedLoop
	POP			ECX									; restores outer loop count 
	LOOP		_outerLoop

	POP			EAX									; restores registers
	POP			ESI
	POP			ECX
	POP			EBP

	RET			4

sortList	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: exchangeElements
;
;	Nested procedure with the sole purpose is to exchanges elements in Bubble sort loop.
;
;	Preconditions: Next element to be less than current element in array.
;
;	Postconditions: Elements are switched and the smaller number is put first.
;
;	Recieves: none
;
;	returns: none
;---------------------------------------------------------------------------------------------------------------------------------------
exchangeElements	PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		EBX
	PUSH		EAX

	MOV			EBX, [ESI+4]						; moves next element into registers
	MOV			[ESI+4], EAX
	MOV			EAX, EBX							
	MOV			[ESI], EAX							; replaces current element with next element in array list

	POP			EAX									; restores registers
	POP			EBX
	POP			EBP
	RET			

exchangeElements	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: displayMedian
;
;	Finds and displays median of array list.
;
;	Preconditions: Sorted random array list.
;
;	Postconditions: none
;
;	Recieves:	
;		[EBP+8]			= sorted random array list
;		[EBP+12]		= title telling user the median number	
;		ARRAYSIZE is a global constants
;	returns: displayed string with title and median number.
;---------------------------------------------------------------------------------------------------------------------------------------
displayMedian		PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		EDX
	PUSH		EBX
	PUSH		EAX
	PUSH		ESI

	MOV			ESI,[EBP+8]							; moves array to ESI

	MOV			EDX, [EBP+12] 					
	CALL		WriteString							; displays titlle stating the median number

	MOV			EDX, 0
	MOV			EAX, ARRAYSIZE						
	MOV			EBX, 2
	DIV			EBX									; finds middle of array
	CMP			EDX, 0
	JE			_evenArray							; jumps if even for further calculations
	MOV			EAX, [ESI+EAX*4]					
	CALL		WriteDec							; displays number if odd array size
	CALL		CrLf
	CALL		Crlf
	JMP			_endJmp
_evenArray:
	MOV			EBX, [ESI+EAX*4]					
	SUB			EAX, 1
	MOV			EAX, [ESI+EAX*4]
	MOV			EDX, 0
	ADD			EAX, EBX							; adds middle number with element before and divides by 2 for median
	MOV			EBX, 2
	DIV			EBX
	CALL		WriteDec							; displays median number
	CALL		CrLf
	CALL		Crlf

	
_endJmp:											; jump for odd array size

	POP			ESI
	POP			EAX									; restored registers
	POP			EBX
	POP			EDX
	POP			EBP
	RET			8

displayMedian		ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: countList
;
;	Procedure that counts and adds the number of times each element of a sorted array is repeated and overwrites to a count array.
;
;	Preconditions: Sorted array list within the size of array, in this case 200.
;
;	Postconditions: countArray with a number corresponding to the repetitions starting with the lower bound, in this case 15.
;
;	Recieves:	
;		[EBP+8]			= sorted random array 
;		[EBP+12]		= empty count array
;	ARRAYSIZE, HI, and LO are global constants
;
;	returns: countArray	= list array of all numbers of repetitions in sorted random array.
;---------------------------------------------------------------------------------------------------------------------------------------
countList	PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		EDI
	PUSH		EBX
	PUSH		ECX
	PUSH		EAX
	PUSH		EDX

	MOV			EAX, HI			
	MOV			EBX, LO
	SUB			EAX, EBX
	ADD			EAX, 1

	MOV			EDI, [EBP+12]
	MOV			ESI, [EBP+8]

	MOV			ECX, EAX							; count for outer loop for the numbers within the range of lower bound and upper bound, in this case, 35.
	MOV			EAX, LO								; starting number to test for repetitions
	SUB			EAX, 1								
	
_outerLoop:
	PUSH		ECX									; preserves count for outer loop
	PUSH		ESI
	INC			EAX									;loop to test every number within bounds from LO to HI
	MOV			EBX, 0
	MOV			ECX, ARRAYSIZE						; count for inner loop to iterate through all of sorted array, in this case 200

_countArr:		

	CMP			[ESI], EAX							
	JNE			_endLoop							; jump to end if not a repetition
	INC			EBX
	MOV			[EDI], EBX							; add to count of repetition

_endLoop:
	ADD			ESI, 4								; move inner loop sorted array to next number for comparing
	LOOP		_countArr
	ADD			EDI, 4								; move outer loop count array to next number for comparing
	POP			ESI
	POP			ECX									; restore registers for outer loop 
	LOOP		_outerLoop

	POP			EDX									; restore registers
	POP			EAX
	POP			ECX
	POP			EBX
	POP			EDI
	POP			EBP

	RET			8

countList	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: farewell
;
;	Procedure to end with closing message.
;
;	Preconditions: farewell message is a string that says goodbye.
;
;	Postconditions: none
;
;	Recieves:	
;		[EBP+8]			= string with farewell message			
;
;	returns: String with goodbye message.
;---------------------------------------------------------------------------------------------------------------------------------------
farewell	PROC
	PUSH		EBP									; preserves registers
	MOV			EBP, ESP
	PUSH		EDX


	MOV			EDX, [EBP+8]
	CALL		WriteString							; displays goodbye message
	CALL		CrLf

	POP			EDX
	POP			EBP									; restores registers
	RET			4

farewell	ENDP

END main
