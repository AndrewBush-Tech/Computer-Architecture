TITLE Prime Numbers    (Proj4_bushand.asm)

; Author: Andrew Bush
; Last Modified: FEB 19
; OSU email address: bushand@oregonstate.edu
; Course number/section:271   CS271 Section 400
; Project Number: 04               Due Date: FEB 20 by 11:59pm
; Description: This program calculates prime numbers. First, the user is instructed to enter the number of primes to be displayed, 
;		and is prompted to enter an integer in the range [1 ... 200]. The user enters a number, n, and the program verifies that 1 ? n ? 200. 
;		If n is out of range, the user is re-prompted until they enter a value in the specified range. The program then calculates and displays 
;		the all of the prime numbers up to and including the nth prime.

INCLUDE Irvine32.inc

UPPER_BOUND =	200
LOWER_BOUND = 	1

.data

intro_1				BYTE	"Prime Numbers Programmed by Andrew Bush", 13,10,13,10
					BYTE	"Enter the number of prime numbers you would like to see.", 13,10
					BYTE	"I'll accept orders for up to 200 primes.", 13,10,0
user_info			BYTE	"Enter the number of primes to display [1 ... 200]: ", 0
invalid_info		BYTE	"No primes for you! Number out of range. Try again.", 13,10,0
farewell_message	BYTE	"Results certified by Andrew Bush. Goodbye.", 13,10,0
space_3				BYTE	"   ", 0
user_num			DWORD	?
is_prime			DWORD	?
count				DWORD	?
amount_prime		DWORD	?
divisor				DWORD	?



.code
main		PROC
	CALL		introduction
	CALL		getUserData
	CALL		showPrimes
	CALL		farewell

	Invoke ExitProcess,0							; exit to operating system
main		ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: introduction
;
;	Procedure to introduce the program.
;
;	Preconditions: intro_1 is a string that describes the program and sets a upper[200] and lower[1] bounds.
;
;	Postconditions: EDX exchange.
;
;	Recieves: none
;
;	returns: none
;---------------------------------------------------------------------------------------------------------------------------------------
introduction PROC
	MOV			EDX, OFFSET intro_1					; writes intro and displays programmers name and program title
	CALL		WriteString
	CALL		CrLf
	RET

introduction ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: getUserData
;
;	Gets the user data and saves into global variable.
;
;	Preconditions: user_info is a string and user_num exists.
;
;	Postconditions: EDX and EAX are changed.
;
;	Recieves: none
;
;	returns: user input values for global variable user_num.
;---------------------------------------------------------------------------------------------------------------------------------------
getUserData	PROC
	MOV			EDX, OFFSET user_info				; displays message to get user info and reads user number input
	CALL		WriteString
	CALL		ReadInt
	MOV			user_num, EAX						; saves into variable to use EAX register in validate procedure
	CALL		validate							

getUserData	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: validate
;
;	Validates whether user input is within the limits of the upper[200] and lower[1] bounds by comparing user_num to each and jumping if 
;		out of range to an instructions that prompts the user of an invalid number then calls the getUserData procedure for user input again.
;
;	Preconditions: user_num holds user input from getUserData procedure. 
;
;	Postconditions: EDX in changed and user_num is changed if out of range [1...200].
;
;	Recieves: none
;
;	returns: user input values for global variable user_num.
;---------------------------------------------------------------------------------------------------------------------------------------
validate	PROC
	CMP			user_num, LOWER_BOUND						
	JL			_invalidNum							; jumps if user number below 1
	CMP			user_num, UPPER_BOUND
	JG			_invalidNum							; jumps if user number above 200
	JMP			_endJmp								; jumps to _endJmp for return since validated within bounds

_invalidNum:
	MOV			EDX, OFFSET invalid_info			; writes message that user input invalid number
	CALL		WriteString
	CALL		getUserData

_endJmp:										
	RET

validate	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: showPrimes
;
;	Finds and shows the prime numbers by calling a procedure that checks for prime numbers and returns 0 for not prime and 1 for prime. The outer
;		counting loop counts the amount of prime numbers displayed and stops when it reaches the users number. This loop will continue until it reaches 
;		the upper bound of 200 then stop. The called procedure isPrime returns either a 1 or 0 and then showPrimes displays prime numbers within a 
;		row of 10 numbers (by dividing by 10 and if no remainder exists, EDX = 0, adds Carriage return and line feed), and jumps over non prime numbers 
;		to loop back to counting loop.
;
;	Preconditions: user_num to exist and to be validated.
;
;	Postconditions: EAX, EBX, EDX are changed and ECX is changed to 0.
;
;	Recieves: none
;
;	returns: A list of prime numbers from 1 to user_num is displayed.
;---------------------------------------------------------------------------------------------------------------------------------------
showPrimes	PROC
	CALL		CrLf							
	MOV			count, 2							; initializes first number to test if prime
	MOV			amount_prime, 1						; initializes the number of prime number display counter
	MOV			ECX, UPPER_BOUND					; initializing counter to user_num for outer looping

_countingLoop:
	MOV			EBX, amount_prime					
	SUB			EBX, 1								; initializes EBX register to 0 to start amount of prime numbers being displayed
	CMP			EBX, user_num
	JE			_endLoop1							; jumps to end if the user num matches the amount displayed
	PUSH		ECX									
	PUSH		count								; push preserves ECX register and count variable for passing as parameter
	CALL		isPrime
	POP			count								
	POP			ECX									; pop restores ECX register and count variable from stack
	CMP			is_prime, 0
	JE			_notPrime							; jumps if isPrime returned 0, which is not prime
	MOV			EAX, count
	CALL		WriteDec
	MOV			EDX, OFFSET space_3					; adds 3 spaces in between prime numbers
	CALL		WriteString
	MOV			EDX, 0
	MOV			EAX, amount_prime
	MOV			divisor, 10							; for the purpose of dividing by 10
	DIV			divisor									
	CMP			EDX, 0 
	JE			_space								; jumps if at the tenth prime number that has been displayed for carriage return and line feed
	INC			amount_prime
	INC			count
	LOOP		_countingLoop						; loops to keep iterating through the 200 numbers within bounds

_inBetween:											; the counting loop was too far so I added this as an in between jump
	LOOP		_countingLoop

_space:
	CALL		CrLf
	INC			amount_prime						; adds 3 spaces between prime numbers and increments next number to test
	INC			count
	JMP			_inBetween							; _countingLoop was too far

_notPrime:
	INC			count								; increments next number to test
	JMP			_inBetween							; _countingLoop was too far

_endLoop1:

	RET
showPrimes	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: isPrime
;
;	validates if number is prime by using quotient and comparing remainder in EDX register. If no remainder exists 
;		returns 0 for not prime, otherwise, returns 1 for prime.
;
;	Preconditions: move 0 into EDX and is_prime and count to exist.
;
;	Postconditions: ECX, EDX, EAX registers changed, and is_prime changed to either 0 or 1.
;
;	Recieves: none
;
;	returns: A number in is_prime either 0 or 1 indicating whether user value is prime (1) or not prime (0).
;---------------------------------------------------------------------------------------------------------------------------------------
isPrime	PROC

	MOV			ECX, count							; initializes ECX to number being tested for prime (count)
	JMP			_nestedLoop

_nestedLoop:
	MOV			EDX, 0								; required for quotient		
	CMP			ECX, count				
	JE			_notPrimeJmp						; jumps if comparing first number to itself
	MOV			EAX, count
	CMP			ECX, 1
	JE			_primeJmp							; jumps if loop was iterated through with no variables being divisible by it (EDX was not ever 0)
	DIV			ECX
	CMP			EDX, 0								
	JE			_endJmp1							; jumps because the quotient had no remainder and was divisible (EDX was 0)
	LOOP		_nestedLoop

_primeJmp:
	MOV			is_prime, 1							; sets variable is_prime to 1 because count is a prime number
	JMP			_endJmp

_notPrimeJmp:
	LOOP		_nestedLoop							; loop meant for the first jump since it is comparing to itself

_endJmp1:
	MOV			is_prime, 0							; sets variable is_prime to 0 because count is not a prime number

_endJmp:
	RET	

isPrime	ENDP

;---------------------------------------------------------------------------------------------------------------------------------------
;	Name: farewell
;
;	Procedure to end with closing message.
;
;	Preconditions: farewell_message is a string that says goodbye to the user and certifies result with programmer's name.
;
;	Postconditions: EDX exchange.
;
;	Recieves: none
;
;	returns: none
;---------------------------------------------------------------------------------------------------------------------------------------
farewell	PROC
	CALL		CrLf
	CALL		CrLf
	MOV			EDX, OFFSET farewell_message			; display goodbye message
	CALL		WriteString
	RET

farewell	ENDP

END main
