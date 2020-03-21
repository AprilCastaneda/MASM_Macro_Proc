TITLE MacroProc     (MacroProc.asm)

; Author: April Castaneda
; Last Modified: 03.13.2020
; Description:	MASM program that implements readVal and writeVal procedures for signed integers
;				and getString and displayString macros. It gets 10 valid integers from the user,
;				then displays the integers, their sum, and their average.
;				1.	Introduces the program.
;				2.	Implements macro getString that displays a prompt, then gets user's keyboard
;					input into a memory location.
;				3.	Implements macro displayString that prints the string which is stored in a specified
;					memory location.
;				4.	Implements procedure readVal that invokes getString macro to get the user's
;					string of digits. It then converts the digit string to numeric, while validating
;					the user's input.
;				5.	Implements procedure writeVal that converts a numeric value to a string of digits
;					and invokes the displayString macro to produce the output
;				6.	Program gets 10 valid integers from user, displays integers, their sum, and their average.

INCLUDE Irvine32.inc

; Global constants
ARRAYSIZE = 10
BUFFERSIZE = 13
UPPER = +2147483647
LOWER = -2147483648

; ************************************************************************
; getString
; Macro that displays a prompt, then gets the user's keyboard input into a
; memory location 
; Receives: OFFSETs of prompt to display, buffer to store string, byteCount to store length
; Returns: none
; Pre-conditions: none
; Registers changed: edx, ecx, edi
; ************************************************************************
getString	MACRO	promptString, numBuffer, stringSize
		
	push	edx
	push	ecx
	push	edi

	mov		edx, promptString										; Set up WriteString
	call	WriteString
	mov		edx, numBuffer											; Set up ReadString
	mov		ecx, BUFFERSIZE
	call	ReadString
	mov		edi, stringSize											; Store length of string
	mov		[edi], eax

	pop		edi
	pop		ecx
	pop		edx		
	
ENDM

; ************************************************************************
; displayString
; Macro that displays a string which is stored in a specified memory location
; Receives: OFFSET of string to display
; Returns: none
; Pre-conditions: none
; Registers changed: edx
; ************************************************************************
displayString	MACRO	someString

	push	edx
	
	mov		edx, someString											; Set up WriteString
	call	WriteString

	pop		edx

ENDM

.data
pTitle		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
pTitle2		BYTE	"Written by: ", 0
pName		BYTE	"April Castaneda ", 0
instruct1a	BYTE	"Please provide ", 0
instruct1b	BYTE	" signed decimal integers.", 0
instruct2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct3	BYTE	"After you have finished inputting the raw numbers, I will display a list", 0
instruct4	BYTE	"of the integers, their sum, and their average value.", 0
prompt		BYTE	"Please enter a signed number: ", 0
promptError	BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
prompt2		BYTE	"Please try again: ", 0
array		SDWORD	ARRAYSIZE DUP (?)
buffer		BYTE	ARRAYSIZE+1 DUP (0)
bufferOut	BYTE	ARRAYSIZE+1 DUP (?)
byteCount	SDWORD	?
loopCount	SDWORD	?
sum			SDWORD	0
average		SDWORD	0
dispArray	BYTE	"You entered the following numbers:", 0
dispComma	BYTE	", ", 0
dispSum		BYTE	"The sum of these numbers is: ", 0
dispAve		BYTE	"The rounded average is: ", 0
dispThanks	BYTE	"Thanks for playing!", 0

.code
main PROC

; Set up introduction call
	push	OFFSET pTitle											; 52
	push	OFFSET pTitle2											; 48
	push	OFFSET pName											; 44
	push	OFFSET instruct1a										; 40
	push	OFFSET instruct1b										; 36
	push	OFFSET instruct2										; 32
	push	OFFSET instruct3										; 28
	push	OFFSET instruct4										; 24
	push	ARRAYSIZE												; 20
	push	OFFSET bufferOut										; 16
	call	introduction

; Set up readVal call
	push	OFFSET prompt											; 64
	push	OFFSET promptError										; 60
	push	OFFSET prompt2											; 56
	push	OFFSET array											; 52
	push	OFFSET buffer											; 48
	push	OFFSET byteCount										; 44
	push	ARRAYSIZE												; 40
	push	UPPER													; 36
	push	LOWER													; 32
	push	OFFSET loopCount										; 28
	call	readVal

; Set up calcVal call
	push	OFFSET array											; 40
	push	ARRAYSIZE												; 36
	push	OFFSET sum												; 32
	push	OFFSET average											; 28
	call	calcVal

; Set up displayResults call
	push	OFFSET dispArray										; 52
	push	OFFSET dispComma										; 48
	push	OFFSET dispSum											; 44
	push	OFFSET dispAve											; 40
	push	OFFSET array											; 36
	push	sum														; 32
	push	average													; 28
	push	ARRAYSIZE												; 24
	push	OFFSET bufferOut										; 20
	call	displayResults

; Set up farewell call
	push	OFFSET dispThanks										; 12
	call	farewell

	exit															;exit to operating system
main ENDP

; ************************************************************************
; introduction
; Procedure displays title, programmer's name, and brief instructions.
; Receives: OFFSETs of pTitle, pTitle2, pName, instruct1a, b, 2, 3, 4, bufferOut; ARRAYSIZE
; Returns: none
; Pre-conditions:  none
; Registers changed: ebp, esp, edx, eax
; ************************************************************************
introduction PROC

	push	ebp
	push	edx
	push	eax

	mov		ebp, esp
	displayString	[ebp+52]										; First line
	call	CrLf
	displayString	[ebp+48]										; Second line
	displayString	[ebp+44]
	call	CrLf
	call	CrLf
	displayString	[ebp+40]										; Third line
	push	[ebp+20]												; Set up writeVal
	push	[ebp+16]
	call	writeVal
	displayString	[ebp+36]
	call	CrLf
	displayString	[ebp+32]										; Fourth line
	call	CrLf
	displayString	[ebp+28]										; Fifth line
	call	CrLf
	displayString	[ebp+24]										; Sixth line
	call	CrLf
	call	CrLf

	pop		eax
	pop		edx
	pop		ebp

	ret		36

introduction	ENDP

; ************************************************************************
; readVal
; Procedure to invoke getString macro to get user's string of digits. It then
; converts the digit string to numeric, while validating the user's input.
; Receives: OFFSET of prompt, promptError, prompt2, array, buffer, byteCount, 
;			loopCount; ARRAYSIZE, UPPER, LOWER
; Returns: None
; Pre-conditions: Introduction has been called
; Registers changed: ebp, esp, ecx, esi, eax, edx, ebx
; ************************************************************************
readVal	PROC

	push	ebp
	push	ecx
	push	esi
	push	eax
	push	edx
	push	ebx

	mov		ebp, esp

; Set outerLoop counter
	mov		ecx, [ebp+40]											; ARRAYSIZE

; Set up destination array
	mov		edi, [ebp+52]

; Outer loop to get numbers by invoking getString macro
outerLoopReg:
	getString	[ebp+64], [ebp+48], [ebp+44]						; Params: prompt, buffer, byteCount
	mov		ebx, [ebp+28]											; Save outerLoop counter to loopCount
	mov		[ebx], ecx
	jmp		checkString

; Get numbers with different prompt script (if previous input had error)
outerLoopErr:
	getString	[ebp+56], [ebp+48], [ebp+44]
	mov		ebx, [ebp+28]											; Save outerLoop counter to loopCount
	mov		[ebx], ecx
	jmp		checkString

; Helper to get back to outerLoop range
outerLoopRange:
	loop	outerLoopReg

; Go through string and validate if it is a signed number.
checkString:
	mov		esi, [ebp+44]											; Get length of string and put into ecx
	mov		ecx, [esi]												
	cmp		ecx, 11													; Invalid string if length is more than 11 chars
	jg		invalidNum
	mov		esi, [ebp+48]											; Set source to buffer index
	mov		edx, 0													; Edx will store converted number string
	mov		eax, 0													; Eax will store each digit
	mov		ebx, 1													; Ebx = 1 if pos num, Ebx = -1 if neg num
	cld

; See if first character is a sign or a number
	mov		al, [esi]												; Don't use lodsb to not inc esi
	cmp		al, '-'
	je		negNum
	cmp		al, '+'
	je		posNum
	jmp		noSign

; If negative number, reduce length counter and store -1 to ebx to convert whole number later.
negNum:
	dec		ecx
	cmp		ecx, 0													; Number is only a sign so invalid
	je		invalidNum
	mov		ebx, -1
	inc		esi														; Move to next char
	jmp		innerLoop

; If positive number, reduce length counter and store 1 to ebx to convert whole number later.
posNum:
	dec		ecx
	cmp		ecx, 0
	je		invalidNum
	mov		ebx, 1
	inc		esi														; Move to next char
	jmp		innerLoop

; If number has no sign, it is a positive, store 1 to ebx but don't touch length counter
noSign:
	mov		ebx, 1
	jmp		innerLoop

; Check rest of numbers in number string if invalid. If valid, convert ASCII to num and add digits.
innerLoop:
	imul	edx, 10													; Multiply by 10 to be able to add more digits
	jo		invalidNum
	lodsb
	cmp		al, 48													; Check if less than 0
	jb		invalidNum
	cmp		al, 57													; Check if greater than 9
	ja		invalidNum
	sub		al, 48													; Convert ASCII to number
	add		edx, eax												; Add digit to previous number
	loop	innerLoop												; Valid digit so go to next digit		
	jmp		convertSigned											; Valid number so convert per sign

; Number is not a signed number or number is too big
invalidNum:
	displayString	[ebp+60]
	call	CrLf
	mov		ebx, [ebp+28]											; Get back outer loopCount
	mov		ecx, [ebx]
	jmp		outerLoopErr											; Not loop. Don't want to touch ecx.

; Convert whole number to positive or negative number
convertSigned:
	imul	edx, ebx
	cmp		ebx, -1
	je		checkNegRange
	jmp		checkPosRange

; Check if positive num is within range
checkPosRange:
	mov		eax, edx
	cmp		[ebp+36], edx											; Check if higher than upper range
	jo		invalidNum
	jmp		storeNum

; Check if negative num is within range
checkNegRange:
	mov		eax, edx
	cmp		[ebp+32], edx											; Check if lower than lower range
	jo		invalidNum
	jmp		storeNum

; Valid number so store number into array
storeNum:
	mov		eax, edx
	stosd
	jmp		returnOuter

; innerLoop finished so go back to outerLoop for next number in array
returnOuter:
	mov		ebx, [ebp+28]											; Get back outer loopCount
	mov		ecx, [ebx]
	cmp		ecx, 1													; If at last number, finish proc.
	je		procDone
	jmp		outerLoopRange

; Pop used registers
procDone:
	call	CrLf
	pop		ebx
	pop		edx
	pop		eax
	pop		esi
	pop		ecx
	pop		ebp

	ret		40

readVal	ENDP

; ************************************************************************
; calcVal
; Procedure to calculate sum of numbers in array and average.
; Receives: OFFSET of array, sum, average; ARRAYSIZE
; Returns: None
; Pre-conditions: Array has 10 valid numbers.
; Registers changed: ebp, esp, eax, ebx, edx, esi, edi
; ************************************************************************
calcVal	PROC

	push	ebp
	push	eax
	push	ebx
	push	edx
	push	esi
	push	edi

	mov		ebp, esp

; Set up source, loop counter, destination, and initialize sum.
	mov		esi, [ebp+40]											; OFFSET array
	mov		ecx, [ebp+36]											; ARRAYSIZE
	mov		edi, [ebp+32]											; sum
	mov		edx, 0													; edx will store sum inside of proc
	cld

; Calculate sum of numbers in array
calcLoop:
	lodsd
	add		edx, eax
	loop	calcLoop

; Store sum in sum variable
	mov		[edi], edx

; Calculate average = sum / ARRAYSIZE
calcAve:
	mov		eax, [edi]
	cdq
	mov		ebx, [ebp+36]
	idiv	ebx

; Store average in average variable
	mov		edi, [ebp+28]
	mov		[edi], eax

	pop		edi
	pop		esi
	pop		edx
	pop		ebx
	pop		eax
	pop		ebp

	ret		16

calcVal	ENDP

; ************************************************************************
; writeVal
; Procedure to convert a numeric value to a string of digits and invoke the
; displayString macro to produce the output.
; Receives: OFFSET of bufferOut; (unknown variable name) number to be displayed
; Returns: None
; Pre-conditions: OFFSET of bufferOut and number to be displayed pushed into stack.
; Registers changed: ebp, esp, esi, edi, ecx, eax, ebx, edx
; ************************************************************************
writeVal	PROC

	push	ebp
	push	esi
	push	edi
	push	ecx
	push	eax
	push	ebx
	push	edx

	mov		ebp, esp

; Set up source, destination, and initialize digits counter to 0.
	mov		esi, [ebp+36]											; Number in stack
	mov		edi, [ebp+32]											; bufferOut
	mov		ecx, 0													; digits counter
	cld

; Count how many digits in number
	mov		eax, esi
	mov		ebx, 10
countDig:
	cdq
	idiv	ebx
	inc		ecx
	cmp		eax, 0													; If no more digits, go to checkSign
	je		checkSign
	jmp		countDig

; Check if value is positive or negative
checkSign:
	test	esi, esi
	js		negNum
	jmp		posNum

; If negative number, add '-' character and turn number into positive.
negNum:
	mov		al, '-'
	mov		[edi], al												
	mov		ebx, -1
	imul	esi, ebx
	jmp		preDigLoop

; If positive, don't add a character and decrease edi pointer.
posNum:
	dec		edi
	jmp		preDigLoop

; Go through digits and store as characters in bufferOut
preDigLoop:
	mov		eax, esi												; Set up iDiv
	mov		ebx, 10
	add		edi, ecx												; Move forward in bufferOut depending on how many digits in number
;  Add 0 to end of string
	inc		edi														; Go forward a byte to add 0
	mov		edx, 0
	mov		[edi], edx
	dec		edi														; Go back to where digits should go
	std																; Reverse flag

; Loop through digits in reverse with idiv and store ascii equivalent of remainder to bufferOut.
digLoop:
	cdq
	idiv	ebx
	mov		ebx, eax												; Store quotient at ebx
	add		dl, 48													; Get ascii for digit at remainder
	mov		al, dl													; Put rem into eax for stosd
	stosb
	mov		eax, ebx												; Store back quotient to eax
	mov		ebx, 10
	mov		edx, 0
	loop	digLoop	

; Invoke displayString to produce output
	displayString	[ebp+32]

	pop		edx
	pop		ebx
	pop		eax
	pop		ecx
	pop		edi
	pop		esi
	pop		ebp

	ret		8

writeVal	ENDP

; ************************************************************************
; displayResults
; Procedure to display array, sum of array numbers, and rounded average.
; Receives: OFFSET of dispArray, dispComma, dispSum, dispAve, array, bufferOut;
;			sum, average, ARRAYSIZE.
; Returns: None
; Pre-conditions: Array has 10 numbers and sum and average have been calculated.
; Registers changed: ebp, esp, edx, eax, esi
; ************************************************************************
displayResults	PROC

	push	ebp
	push	edx
	push	eax
	push	esi

	mov		ebp, esp

	displayString	[ebp+52]										; Line 1
	call	CrLf

; Set up to display array
	mov		ecx, [ebp+24] 											; ARRAYSIZE									
	mov		esi, [ebp+36]											; array
	cld

; Go through each number in array and call writeVal to display number.
dispLoop:															; Line 2
	lodsd
	push	eax														; Set up WriteVal
	push	[ebp+20]
	call	writeVal
	cmp		ecx, 1													; Don't print comma if last number
	je		displaySum
	displayString	[ebp+48]
	loop	dispLoop

; Display sum by calling writeVal.
displaySum:
	call	CrLf	
	displayString	[ebp+44]										; Line 3
	push	[ebp+32]												; Set up WriteVal
	push	[ebp+20]
	call	writeVal	
	call	CrLf

; Display average by calling writeVal.
displayAve:
	displayString	[ebp+40]										; Line 4
	push	[ebp+28]												; Set up WriteVal
	push	[ebp+20]
	call	writeVal	
	call	CrLf
	call	CrLf

	pop		esi
	pop		eax
	pop		edx
	pop		ebp

	ret		32

displayResults	ENDP

; ************************************************************************
; displayGoodbye
; Procedure to display farewell message
; Receives: OFFSET of dispThanks
; Returns: None
; Pre-conditions: Program finished calculating and displaying results.
; Registers changed: ebp, esp, edx
; ************************************************************************
farewell	PROC

	push	ebp
	push	edx

	mov		ebp, esp

; Display farewell message
	displayString	[ebp+12]										; dispThanks
	call	CrLf

	pop		edx
	pop		ebp

	ret		4

farewell	ENDP

END main