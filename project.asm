.model large
.stack 100h
.data
	numbers1 byte 100 dup(0),'$'
	numbers2 byte 43 dup(0),'$'
	numbers3 byte 100 dup(0),'$'
	;rowsize byte 10
	name1 byte ' Name: ', '$'
	score byte ' Score: ','$'
	moves byte ' Moves: ','$'
	level1 byte 'Level 1 ','$'
	crushing byte 'Crushing!','$'
	enter_n byte 0Ah,'Enter first name to start game: ','$'
	loading byte 'Loading...','$'
	en_name byte 10 dup('$'),'$'
	count byte 0
	count1 byte 0
	s_score byte 0
	s_moves byte 15
	m_remainder byte 0
	m_quotient byte 0
	s_remainder byte 0
	s_quotient byte 0
	xcoor byte 100 dup(0),'$'
	ycoor byte 100 dup(0), '$'
	enter_key byte 'Press enter key to proceed to Level 2', '$'
	
	xcoorvar1 db 0
	xcoorvar2 db 0
	countvar1 db 0
	countvar2 db 0
	countvar3 db 0
	countvar4 db 0
	ycoorvar1 db 0
	ycoorvar2 db 0
	temp1 db 0
	temp2 db 0
	
	wxcoor1 dw 0
	wxcoor2 dw 0
	wycoor1 dw 0
	wycoor2 dw 0

	addxy1 dw 0
	addxy2 dw 0
	
	presscount db 0

	tempsi1 dw 0
	tempsi2 dw 0
	tempsi3 dw 0
	tempsi4 dw 0
	
	boolvar db 0
	
	bombcount dw 0

	orientationcheck db 0 ;0 for horizontal, 1 for vertical

	;--------------filehandling variables-----------
	f_quotient byte 0
	f_remainder byte 0
	buffer byte 100 dup(0), 0
	newline byte 0Ah
	handler word ?
	amper_count byte 0
	;-----------------------------------------------
	
	xcoord dw ?
	ycoord dw ?
	xc_db byte ?
	yc_db byte ?
	div_eight db 8
	div_sixteen db 16
	div_ten db 10
	wquotient db ?
	quotient byte 0
	remainder byte 0
	countxy db 0
	
	bomb_bool byte 0

	zeroindex word ?
.code
main proc
	mov ax, @data
	mov ds, ax
	
	;-------------takes name input before the game start------;
	mov dx, offset enter_n
	mov ah, 09h
	INT 21h
	
	mov dx, offset en_name
	mov ah, 03Fh
	INT 21h
	;--------------------------------------------------------;
	
	mov ah, 00h
	mov al, 13h
	INT 10h		

	CALL get_mouse

	CALL rand1
	
	CALL draw_level1	 
	
	CALL game1

	CALL write_to_file	

	CALL display_n_s

	;----------waiting until user presses enter to proceed--------;
	l1:
		mov ah, 01h
		INT 16h
	jz l1

	mov ah, 00h
	INT 16h

	cmp ah, 28
	je entered

	jmp l1
	;-------------------------------------------------------------;
	entered:

	CALL clr_scr

	CALL rand2

	;resetting moves and scores for level2

	mov s_moves, 15
	mov s_score, 0

	CALL draw_level2

	ending:
		;mov ax, 03h
		;INT 10h			
		
		mov ah, 4ch
		INT 21h
		ret
main endp

;proc to display message that user must press enter after level1 is complete
display_n_s proc
	CALL clr_scr

	mov cx, 1
	mov dl, 12
	mov dh, 12
	mov ah, 02h
	INT 10h

	mov si, 0
	pr_name:
		cmp si, 7
		je continue
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, name1[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_name
	
	continue:
	;----------------------------------------------	
	
	mov cx, 1
	mov dl, 19
	mov dh, 12
	mov ah, 02h
	INT 10h
	
	;prints the name that has been input at the start of program
	mov si, 0
	pr_en_name:
		cmp en_name[si], 13
		je name_done
		mov cx, 1
		inc dl 
		mov ah, 02h
		INT 10h
		mov al, en_name[si]
		mov bl, 01
		mov ah, 09h
		INT 10h
		inc si	
	jmp pr_en_name
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	name_done:

	;--------------prints the word "score"------------------
	mov cx, 1
	mov dl, 12
	mov dh, 14
	mov ah, 02h
	INT 10h
	
	mov si, 0
	pr_score:
		cmp si, 8
		je continue1
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, score[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_score
	;------------------------------------------------------
	
	continue1:
	
	;printing final score
	mov cx, 1
	mov dl, 20
	mov dh, 14
	mov ah, 02h
	INT 10h
	
	mov ax, 0
	mov al, s_score
	mov bl, 10
	div bl
	mov s_remainder, ah
	mov s_quotient, al
	
	mov al, s_quotient
	mov bl, 01
	add al, 48
	mov ah, 09h
	INT 10h
	
	mov cx, 1
	inc dl
	mov ah, 02h
	INT 10h
	
	mov al, s_remainder
	mov bl, 01
	add al, 48
	mov ah, 09h
	INT 10h
	;;;;;;;;;;;;;;;;;;;;;;;

	mov cx, 1
	mov dl, 2
	mov dh, 16
	mov ah, 02h
	INT 10h
	
	mov si, 0

	l3:
		cmp enter_key[si], '$'
		je ending
		mov cx, 1
		mov ah, 02h
		INT 10h
		mov al, enter_key[si]
		mov bl, 02
		mov ah, 09h	
		INT 10h
		inc si
		inc dl
	jmp l3

	ending:
ret
display_n_s endp

;proc which writes the user score to a file which is named after the name entered at the start
write_to_file proc
	mov ax, 0
	mov al, s_score
	mov dl, 10
	div dl
	mov f_remainder, ah
	mov f_quotient, al
	
	add f_remainder, 48
	add f_quotient, 48
	
	mov si, 0
	
	l1:
		mov al, en_name[si]
		cmp al, 13
		je done
		mov buffer[si], al
		inc si
	jmp l1
	
	done:
	
	;adding txt to the end of the name
	mov buffer[si], '.'
	mov buffer[si+1], 't'
	mov buffer[si+2], 'x'
	mov buffer[si+3], 't'

	mov si, 0
	l2:
		cmp si, 10
		je continue
		cmp en_name[si], '$'
		je incre
		next:
		inc si
	jmp l2
	
	incre:
		inc amper_count
		jmp next
	
	continue:
	inc amper_count

	mov dx, offset buffer
	mov cx, 1
	mov ah, 3Ch
	INT 21h
	mov handler, ax
	
	;append
	mov bx, handler
	mov ah, 42h
	mov al, 2
	mov cx, 0
	mov dx, 0
	INT 21h
	
	;write
	mov cx, lengthof en_name
	sub cl, amper_count
	mov bx, handler
	mov dx, offset en_name
	mov ah, 40h
	INT 21h
	
	;write
	mov cx, lengthof newline
	mov bx, handler
	mov dx, offset newline
	mov ah, 40h
	INT 21h
	
	;write
	mov cx, lengthof level1
	dec cx
	mov bx, handler
	mov dx, offset level1
	mov ah, 40h
	INT 21h
	
	;write
	mov cx, lengthof f_quotient
	mov bx, handler
	mov dx, offset f_quotient
	mov ah, 40h
	INT 21h	

	;write	
	mov cx, lengthof f_remainder
	mov bx, handler
	mov dx, offset f_remainder
	mov ah, 40h
	INT 21h		
	
	mov ah, 3Eh
	mov bx, handler
	INT 21h

ret
write_to_file endp

;draws the strings in levels
draw_string proc
	;---------------printing the word "name"-----------	
	mov cx, 1
	mov dl, 1
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	mov si, 0
	pr_name:
		cmp si, 7
		je continue
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, name1[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_name
	
	continue:
	;----------------------------------------------	
	
	mov cx, 1
	mov dl, 8
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	;prints the name that has been input at the start of program
	mov si, 0
	pr_en_name:
		cmp en_name[si], 13
		je name_done
		mov cx, 1
		inc dl 
		mov ah, 02h
		INT 10h
		mov al, en_name[si]
		mov bl, 01
		mov ah, 09h
		INT 10h
		inc si	
	jmp pr_en_name
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	name_done:
	
	;--------------prints the word "score"------------------
	mov cx, 1
	mov dl, 15
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	mov si, 0
	pr_score:
		cmp si, 8
		je continue1
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, score[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_score
	;------------------------------------------------------
	
	continue1:
	
	;printing initial score
	mov cx, 1
	mov dl, 23
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	mov ax, 0
	mov al, s_score
	mov bl, 10
	div bl
	mov s_remainder, ah
	mov s_quotient, al
	
	mov al, s_quotient
	mov bl, 01
	add al, 48
	mov ah, 09h
	INT 10h
	
	mov cx, 1
	inc dl
	mov ah, 02h
	INT 10h
	
	mov al, s_remainder
	mov bl, 01
	add al, 48
	mov ah, 09h
	INT 10h
	;;;;;;;;;;;;;;;;;;;;;;;
	
	;-------------printing the word "moves"----------
	mov cx, 1
	mov dl, 25
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	mov si, 0
	pr_move:
		cmp si, 8
		je continue2
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, moves[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_move
	;-------------------------------------------
	continue2:
	
	;printing initial number of moves
	mov cx, 1
	mov dl, 32
	mov dh, 1
	mov ah, 02h
	INT 10h
	
	mov ax, 0
	mov al, s_moves
	mov bl, 10
	div bl
	mov m_remainder, ah
	mov m_quotient, al
	
	mov cx, 1
	inc dl 
	mov ah, 02h
	INT 10h
	mov al, m_quotient
	add al, 48
	mov bl, 1
	mov ah, 09h
	INT 10h
	
	mov cx, 1
	inc dl 
	mov ah, 02h
	INT 10h
	mov al, m_remainder
	add al, 48
	mov bl, 1
	mov ah, 09h
	INT 10h		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov cx, 1
	mov dl, 28
	mov dh, 8
	mov ah, 02h
	INT 10h
	
	;--------------------printing "Level 1"---------
	mov si, 0
	pr_level:
		cmp si, 8
		je continue3
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, level1[si]
		mov bl, 02
		mov ah, 09h
		INT 10h
		inc si
	jmp pr_level		
	;------------------------------------------------
	continue3:	


	ret
draw_string endp

;draws the grid for level1
draw_level1 proc

	mov ah, 00h
	mov al, 13h
	INT 10h
	
	;---------------drawing the grid-------------
	mov cx, 58
	mov dx, 20
	INT 10h

	l1:
		cmp dx, 180
		je next
		mov al, 01
		mov ah, 0Ch
		INT 10h
		inc dx
	jmp l1
	
	next:
	mov cx, 58
	mov dx, 180
	INT 10h

	l2:
		cmp cx, 218
		je next1
		mov al, 01
		mov ah, 0Ch
		INT 10h
		inc cx
	jmp l2
		
	next1:
	mov cx, 218
	mov dx, 20
	INT 10h
	
	l3:
		cmp dx, 180
		je next2
		mov al, 01
		mov ah, 0Ch
		INT 10h
		inc dx
	jmp l3
	
	next2:
	mov cx, 58
	mov dx, 20
	
	l4:
		cmp cx, 218
		je next3
		mov al, 01
		mov ah, 0Ch
		INT 10h
		inc cx
	jmp l4
	
	next3:
	
	mov cx, 58
	mov dx, 20
	INT 10h
	
	l5:
		cmp cx, 218
		je next4
		mov dx, 20
		l6:
			cmp dx, 180
			je nextitr
			mov al, 01
			mov ah, 0Ch
			INT 10h
			inc dx
			jmp l6
		nextitr:
		add cx, 16
	jmp l5
	
	next4:
	
	mov cx, 58
	mov dx, 20
	INT 10h
	
	l7:
		cmp dx, 180
		je next5
		mov cx, 58
		l8:
			cmp cx, 218
			je nextitr1
			mov al, 01
			mov ah, 0Ch
			INT 10h
			inc cx
			jmp l8
		nextitr1:
		add dx, 16	
	jmp l7	
	
	next5:
	;--------------------------------------;	
	
	;CALL get_mouse	
	
	CALL draw_string
	
	CALL populate_1
	
	ret
draw_level1 endp

;draws the grid for level2
draw_level2 proc
mov ah, 00
mov al, 13h
INT 10h

mov cx, 36
mov dx, 76
INT 10h

midleftvert:
cmp dx, 124
je next
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp midleftvert

next:

mov cx, 36
mov dx, 76
INT 10h

midtophoriz:
cmp cx, 180
je next1
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp midtophoriz

next1:

mov cx, 36
mov dx, 124
INT 10h

midbottomhoriz:
cmp cx, 180
je next2
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp midbottomhoriz

next2:

mov cx, 180
mov dx, 76
INT 10h

midrightvertic:
cmp dx, 124
je next4
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp midrightvertic

next4:

;vertical lines middle box
mov cx, 36
mov dx, 76
INT 10h

verticallines1:
cmp cx, 100
je next5
mov dx, 80
inner:
cmp dx, 124
je nextitr
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp inner
nextitr:
add cx, 16
jmp verticallines1

next5:
mov cx, 132
mov dx, 76
INT 10h

verticallines2:
cmp cx, 196
je next6
mov dx, 76
inner1:
cmp dx, 124
je nextitr1
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp inner1
nextitr1:
add cx, 16
jmp verticallines2

next6:
mov cx, 36
mov dx, 92

midtop_hline:
cmp cx, 180
je next7
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp midtop_hline

next7:

mov cx, 36
mov dx, 108

midbot_hline:
cmp cx, 180
je next8
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp midbot_hline

next8:

mov cx, 84
mov dx, 28
INT 10h

leftmidvert:
cmp dx, 172
je next9
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp leftmidvert

next9:

mov cx, 132
mov dx, 28
INT 10h

rightmidvert:
cmp dx, 172
je next10
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp rightmidvert

next10:

mov cx, 84
mov dx, 28

topmidhor:
cmp cx, 132
je next11
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp topmidhor

next11:

mov cx, 84
mov dx, 172
INT 10h

botmidhor:
cmp cx, 132
je next12
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp botmidhor

next12:

mov cx, 84
mov dx, 28
INT 10h

horizmid:
cmp dx, 76
je next13
mov cx, 88
innerm:
cmp cx, 132
je nextitr2
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp innerm
nextitr2:
add dx, 16
jmp horizmid

next13:

mov cx, 84
mov dx, 140
INT 10h

horizmid1:
cmp dx, 172
je next14
mov cx, 88
innerm1:
cmp cx, 132
je nextitr3
mov al, 01
mov ah, 0Ch
INT 10h
inc cx
jmp innerm1
nextitr3:
add dx, 16
jmp horizmid1

next14:

mov cx, 84
mov dx, 28
INT 10h

verticmid:
cmp cx, 132
je next15
mov dx, 32
innerv:
cmp dx, 92
je nextitr4
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp innerv
nextitr4:
add cx, 16
jmp verticmid

next15:

mov cx, 84
mov dx, 108
INT 10h

verticmid1:
cmp cx, 132
je next16
mov dx, 108
innerv1:
cmp dx, 172
je nextitr5
mov al, 01
mov ah, 0Ch
INT 10h
inc dx
jmp innerv1
nextitr5:
add cx, 16
jmp verticmid1

next16:
	CALL get_mouse
	CALL populate_2
	CALL draw_string
ret
draw_level2 endp	

;populating the grid made in draw_level1
populate_1 proc
	mov cx, 1
	mov dl, 8
	mov dh, 3
	mov ah, 02h
	INT 10h
	
	mov si, 0
	mov count, 10
	mov count1, 10
	l2:
		cmp count1, 0
		je ended
		mov dl, 8
		mov count, 10
		mov bl, 1
		l3:		
			cmp count, 0
			je nextitr
			mov cx, 1
			mov ah, 02h
			INT 10h
			mov al, numbers1[si]
			mov ah, 09h
			INT 10h
			mov xcoor[si], dl
			mov ycoor[si], dh			
			inc si
			dec count
			add dl, 2
			inc bl
		jmp l3
		nextitr:
		dec count1
		add dh, 2
	jmp l2
	
	ended:

	CALL get_mouse
	ret
populate_1 endp

;populating the grid in level2
populate_2 proc
	mov cx, 1
	mov dl, 5
	mov dh, 10
	mov ah, 02h
	INT 10h

	mov si, 0
	mov count, 3	
	mov count1, 3

	leftrows:
		cmp count1, 0
		je next	
		mov bl, 1
		mov count, 3
		mov dl, 5
		innerloop:
			cmp count, 0	
			je nextitr
			mov ah, 02
			INT 10h
			mov ah, 09h
			mov al, numbers2[si]
			INT 10h
			inc si
			add dl, 2
			inc bl
			dec count
		jmp innerloop
		nextitr:
		add dh, 2
		dec count1
	jmp leftrows

	next:

	mov cx, 1
	mov dl, 17
	mov dh, 10
	mov ah, 02h
	INT 10h

	mov count, 3
	mov count1, 3

	rightrows:
		cmp count1, 0
		je next1
		mov bl, 1
		mov count, 3
		mov dl, 17
		innerloop1:
			cmp count, 0	
			je nextitr1
			mov ah, 02
			INT 10h
			mov ah, 09h
			mov al, numbers2[si]
			INT 10h
			inc si
			add dl, 2
			inc bl
			dec count
		jmp innerloop1
		nextitr1:
		add dh, 2
		dec count1
	jmp rightrows

	next1:

	mov cx, 1
	mov dl, 11
	mov dh, 4
	mov ah, 02h
	INT 10h

	mov count, 3
	mov count1, 4

	toprows:
		cmp count1, 0
		je next2
		mov bl, 1
		mov count, 3
		mov dl, 11
		innerloop2:
			cmp count, 0	
			je nextitr2
			mov ah, 02
			INT 10h
			mov ah, 09h
			mov al, numbers2[si]
			INT 10h
			inc si
			add dl, 2
			inc bl
			dec count
		jmp innerloop2
		nextitr2:
		add dh, 2
		dec count1
	jmp toprows

	next2:

	mov cx, 1
	mov dl, 11
	mov dh, 14
	mov ah, 02h
	INT 10h

	mov count, 3
	mov count1, 4

	bottomrows:
		cmp count1, 0
		je next3
		mov bl, 1
		mov count, 3
		mov dl, 11
		innerloop3:
			cmp count, 0	
			je nextitr3
			mov ah, 02
			INT 10h
			mov ah, 09h
			mov al, numbers2[si]
			INT 10h
			inc si
			add dl, 2
			inc bl
			dec count
		jmp innerloop3
		nextitr3:
		add dh, 2
		dec count1
	jmp bottomrows

	next3:

	CALL get_mouse
ret
populate_2 endp

;produces 100 random numbers and contains loading screen, as well containing a call to clr_scr
rand1 proc
	mov di, 0
	mov count, 100
	
	mov cx, 1
	mov dl, 13
	mov dh, 10
	mov ah, 02h
	INT 10h
	
	mov si, 0
	
	pr_loading:
		cmp si, 10
		je continue
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, loading[si]
		mov bl, 1
		mov ah, 09h
		INT 10h
		inc si	
	jmp pr_loading
	
	continue:
	
	l1:
		cmp count, 0 
		je continue1
		
		;random number generator
		mov ah, 00h
		INT 1Ah
		
		mov ax, dx
		xor dx, dx
		mov cx, 5
		div cx
		
		add dx, 48
		add dl, 1
		mov numbers1[di], dl
		
		;delay 
		mov cx, 01h
		mov dx, 3240h
		mov ah, 86h
		INT 15h
		
		inc di
		dec count
	jmp l1

	continue1:

	mov si, 0
	mov count, 4
	l2:
		cmp count, 0
		je exiting
		
		mov ah, 00h
		INT 1Ah
		
		mov ax, dx
		xor dx, dx
		mov cx, 42
		div cx
		
		mov si, dx
		mov numbers1[si], 'B'
		
		mov cx, 0Fh
		mov dx, 4240h
		mov al, 0
		mov ah, 86h
		INT 15h
		
		dec count
	jmp l2
	
	exiting:	

	CALL clr_scr
	
	ret
rand1 endp

;produces 42 random numbers with bombs
rand2 proc
	mov di, 0
	mov count, 42
	
	mov cx, 1
	mov dl, 13
	mov dh, 10
	mov ah, 02h
	INT 10h
	
	mov si, 0
	
	pr_loading:
		cmp si, 10
		je continue
		mov cx, 1
		inc dl
		mov ah, 02h
		INT 10h
		mov al, loading[si]
		mov bl, 1
		mov ah, 09h
		INT 10h
		inc si	
	jmp pr_loading
	
	continue:
	
	l1:
		cmp count, 0 
		je continue1
		
		;random number generator
		mov ah, 00h
		INT 1Ah
		
		mov ax, dx
		xor dx, dx
		mov cx, 4
		div cx
		
		add dx, 48
		add dl, 1
		mov numbers2[di], dl
		
		;delay 
		mov cx, 01h
		mov dx, 3240h
		mov ah, 86h
		INT 15h
		
		inc di
		dec count
	jmp l1

	continue1:
	
	;use this label to generate 4 different "indexes" which we store a bomb at, thus making it random, this overwrites the values
	;initially present at those indexes
	mov si, 0
	mov count, 6
	l2:
		cmp count, 0
		je exiting
		
		mov ah, 00h
		INT 1Ah
		
		mov ax, dx
		xor dx, dx
		mov cx, 42
		div cx
		
		mov si, dx
		mov numbers2[si], 'B'
		
		mov cx, 0Fh
		mov dx, 4240h
		mov al, 0
		mov ah, 86h
		INT 15h
		
		dec count
	jmp l2
	
	exiting:	

	CALL clr_scr		
ret
rand2 endp

;clears screen
clr_scr proc
	mov ax, 0600h
	mov cx, 0
	mov dx, 184Fh
	mov bh, 0
	INT 10h

	ret
clr_scr endp

;reinitialises mouse
get_mouse proc
	;initialise mouse
	mov ax, 01
	INT 33h
	
	;mov ax, 4
	;mov cx, 2
	;mov dx, 2
	;INT 33h
	
	;;;horizontal
	mov ah, 07h
	mov cx, 0
	mov dx, 620
	INT 33h
	
	;;;vertical
	mov ah, 08h
	mov cx, 0
	mov dx, 185
	INT 33h
	
	;set mouse speed
	;mov ax, 0Fh
	;mov cx, 16000
	;mov dx, 16000
	;INT 33h	

ret
get_mouse endp

;main game loop for level1, clicks are detected here and then set on to be tested
game1 proc

	l1:
		cmp countxy, 15
		je exiting
		mov ax, 05
		INT 33h
		cmp bl, 1
		je pressed
	jmp l1

	pressed:
		mov xcoord, cx
		mov ycoord, dx
		inc presscount
		mov al, presscount
		cmp al, 1
		JE moveintovar1
		cmp al, 2
		JE moveintovar2

		mov ax, xcoord
		div div_sixteen
		mov wquotient, al
		
				
		mov ax, ycoord
		div div_eight
		mov wquotient, al
		
				
		;dec s_moves
			
		CALL clr_scr	
		CAll draw_level1	
		;inc countxy
		
	jmp l1
	
	moveintovar1:
		mov ax, xcoord
		div div_sixteen
		mov xcoorvar1, al
		
				
		mov ax, ycoord
		div div_eight
		mov ycoorvar1, al
		
		;call testswap
				
			
		CALL clr_scr	
		CAll draw_level1	
		;inc countxy
		
	jmp l1

	moveintovar2:
		mov ax, xcoord
		div div_sixteen
		mov xcoorvar2, al
		
				
		mov ax, ycoord
		div div_eight
		mov ycoorvar2, al
		
		call testswap
				
		mov ax, 1
		cmp boolvar, al
		JE decmoves
			
		CALL clr_scr	
		CAll draw_level1
		;;;Remove to inc score only on valid move	
		;inc countxy
		mov ax, 0
		mov presscount, al
	jmp l1
		
	decmoves:
		dec s_moves
		;;;Uncomment to inc score only on valid move
		inc countxy
		CALL clr_scr
		CALL draw_level1
		mov ax, 0
		mov presscount, al
		mov boolvar, al
		CALL updatenumbers
		CALL clr_scr
		CALL draw_level1
		mov ax, 0
		mov bomb_bool, al
	jmp l1	
	
	exiting:
	ret
game1 endp

;;;;MAIN SWAPPING PROC FOR LEVEL 1
testswap PROC
	;mov ax, 0
	;mov si, 0
	;add al, 48
	;mov al, numbers1[si]
	;add al, 48
	;mov bl, numbers1[si+1]
	;add bl, 48
	;mov numbers1[si], bl
	;mov numbers1[si+1], al
	
	mov ax, 0
	mov bx, 0
	
	mov al, xcoorvar1
	mov bl, xcoorvar2
	cmp al, bl
	JE setorient
	cmp al, bl
	JB var1less
	jmp var1great
	
	setorient:
		mov dx, 0
		mov orientationcheck, dl
		jmp checky
	
	var1less:
		add al, 2
		cmp al, bl
		JE checky
		jmp exitret
		
	var1great:
		add bl, 2
		cmp al, bl
		JE checky
		jmp exitret
		
	checky:
		mov ax, 0
		mov bx, 0
		mov al, ycoorvar1
		mov bl, ycoorvar2
		cmp al, bl
		JE intermed
		cmp al, bl
		JB y1less
		jmp y1great
		
	y1less:
		mov dx, 1
		mov orientationcheck, 1
		add al, 2
		cmp al, bl
		JE intermed
		jmp exitret
		
	y1great:
		mov dx, 1
		mov orientationcheck, 1
		add bl, 2
		cmp al, bl
		JE intermed
		jmp exitret
	
	intermed:
		mov ax, 0
		mov bx, 0
		mov si, 0
		mov di, 0
		mov al, xcoorvar1
		mov bl, xcoorvar2
		
	xloop1:
		mov ax, 0
		cmp si, 100
		JE exitret
		mov al, xcoor[si]
		cmp al, xcoorvar1
		JE storex
		inc si
		jmp xloop1
		
	storex:
		mov tempsi1, si
		mov si, 0
		jmp yloop1
	
	yloop1:
		mov ax, 0
		cmp si, 100
		JE exitret
		mov al, ycoor[si]
		cmp al, ycoorvar1
		JE storey
		inc si
		jmp yloop1
		
	storey:
		mov tempsi2, si
		mov ax, 0
		mov ax, tempsi2
		;mul div_ten
		mov tempsi2, ax
		mov ax, 0
		mov si, 0
		jmp xloop2
		
	xloop2:
		mov ax, 0
		cmp si, 100
		JE exitret
		mov al, xcoor[si]
		cmp al, xcoorvar2
		JE storex2
		inc si
		jmp xloop2
		
	storex2:
		mov tempsi3, si
		mov si, 0
		jmp yloop2
		
	yloop2:
		mov ax, 0
		cmp si, 100
		JE exitret
		mov al, ycoor[si]
		cmp al, ycoorvar2
		JE storey2
		inc si
		jmp yloop2
		
	storey2:
		mov tempsi4, si
		mov ax, 0
		mov ax, tempsi4
		;mul div_ten
		mov tempsi4, ax
		mov ax, 0
		mov si, 0
		jmp swaploop1
		
	swaploop1:	
		mov si, 0
		mov di, 0	
		mov ax, 0
		mov ax, tempsi1
		mov bx, tempsi2
		add ax, bx
		mov si, ax
		mov ax, 0
		mov bx, 0
		mov ax, tempsi3
		mov bx, tempsi4
		add ax, bx
		mov di, ax
		mov ax, 0
		mov bx, 0
		mov al, numbers1[si]
		mov bl, numbers1[di]
		mov numbers1[si], bl
		mov numbers1[di], al
		
		mov ax, 0
		mov bx, 0
		mov addxy1, ax
		mov addxy2, bx
		
		mov addxy1, si
		mov addxy2, di
		
		CALL checkmatch
		
		mov ax, 0
		
		mov ax, 1
		mov boolvar, al				
exitret:
ret
testswap endp

;;;PROC FOR CHECKING FOR MATCHES IN LEVEL 1
checkmatch PROC
	mov ax, 0
	mov bx, 0
	mov dx, 0
	
	mov si, addxy1
	mov di, addxy2
	
	mov al, numbers1[si]
	mov bl, numbers1[di]

	cmp al, 'B'
	JE bombl1
	cmp bl, 'B'
	JE bombl1
	jmp nobomb


	bombl1:
		mov dx, 1
		mov bomb_bool, dl
		cmp si, di
		JB siless
		jmp sigreat

		siless:
			mov ax, 0
			mov al, numbers1[si+1]
			cmp al, bl
			JE horizontalbomb
			jmp silessvercheck

		silessvercheck:
			mov ax, 0
			mov al, numbers1[si+10]
			cmp al, bl
			JE verticalbomb

		sigreat:
			mov ax, 0
			mov al, numbers1[si-1]
			cmp al, bl
			JE horizontalbomb
			jmp sigreatvercheck

		sigreatvercheck:
			mov ax, 0
			mov al, numbers1[si-10]
			cmp al, bl
			JE verticalbomb

		horizontalbomb:
			mov ax, 0
			mov al, numbers1[si]
			mov si, 0
			mov bx, 0
			mov bx, tempsi2
			mov dx, 0
			jmp hbomb

		hbomb:
			cmp si, 10
			JE exitret
			mov numbers1[si+bx], dl
			inc si
			jmp hbomb

		verticalbomb:
			mov ax, 0
			mov al, numbers1[si]
			mov si, 0
			mov bx, 0
			mov bx, tempsi1
			mov dx, 0
			jmp vbomb

		vbomb:
			cmp si, 100
			JE exitret
			mov numbers1[si+bx], dl
			add si, 10
			jmp vbomb
			

	nobomb:
		mov ax, 0
		mov bx, 0
		mov dx, 0
		mov bomb_bool, al	
		mov si, addxy1
		mov di, addxy2
	
		mov al, numbers1[si]
		mov bl, numbers1[di]

		mov dx, 0
		mov dl, numbers1[si+1]
		cmp al, dl
		JE sicheck1
		jmp sicheck2
	
		sicheck1:
			mov dx, 0
			mov dl, numbers1[si+2]
			cmp al, dl
			JE simatched1
			jmp simidcheck1
		
		simidcheck1:
			mov dx, 0
			mov dl, numbers1[si-1]
			cmp al, dl
			JE simidmatch
			jmp dicheck1
		
		simatched1:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si+1], dl
			mov numbers1[si+2], dl
			jmp sicheck2

		sicheck2:
			mov dx, 0
			mov dl, numbers1[si-1]
			cmp al, dl
			JE sicheck3
			jmp dicheck1
		
		sicheck3:
			mov dx, 0
			mov dl, numbers1[si-2]
			cmp al, dl
			JE simatched2
			jmp simidcheck2
		
		simidcheck2:
			mov dx, 0
			mov dl, numbers1[si+1]
			cmp al, dl
			JE simidmatch
			jmp dicheck1
		
		simatched2:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si-1], dl
			mov numbers1[si-2], dl
		
		simidmatch:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si-1], dl
			mov numbers1[si+1], dl
			jmp dicheck1
		
		dicheck1:
			mov dx, 0
			mov dl, numbers1[di+1]
			cmp bl, dl
			JE dicheck11
			jmp dicheck2
		
		dicheck11:
			mov dx, 0
			mov dl, numbers1[di+2]
			cmp bl, dl
			JE dimatched1
			jmp dimidcheck1
		
		dimidcheck1:
			mov dx, 0
			mov dl, numbers1[di-1]
			cmp bl, dl
			JE dimidmatch
			jmp dicheck2
		
		
		dimatched1:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di+1], dl
			mov numbers1[di+2], dl
			jmp dicheck2
		
		dicheck2:
			mov dx, 0
			mov dl, numbers1[di-1]
			cmp bl, dl
			JE dicheck22
			jmp vercheck1
		
		dicheck22:
			mov dx, 0
			mov dl, numbers1[di-2]
			cmp bl, dl
			JE dimatched2
			jmp dimidcheck2
		
		dimidcheck2:
			mov dx, 0
			mov dl, numbers1[di+1]
			cmp bl, dl
			JE dimidmatch
			jmp vercheck1
		
		dimatched2:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di-1], dl
			mov numbers1[di-2], dl
			jmp vercheck1
	
		dimidmatch:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di-1], dl
			mov numbers1[di+1], dl
			jmp vercheck1
		
		vercheck1:
			mov dx, 0
			mov dl, numbers1[si+10]
			cmp al, dl
			JE versi1
			jmp versi2
		
		versi1:
			mov dx, 0
			mov dl, numbers1[si+20]
			cmp al, dl
			JE versimatch1
			jmp versimid1
		
		versimid1:
			mov dx, 0
			mov dl, numbers1[si-10]
			cmp al, dl
			JE versimidmatch
			jmp versi2
		
		versi2:
			mov dx, 0
			mov dl, numbers1[si-10]
			cmp al, dl
			JE versi22
			jmp verdi1
		
		versi22:
			mov dx, 0
			mov dl, numbers1[si-20]
			cmp al, dl
			JE versimatch2
			jmp versimid2
		
		versimid2:
			mov dx, 0
			mov dl, numbers1[si+10]
			cmp al, dl
			JE versimidmatch
			jmp verdi1
	
		versimidmatch:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si-10], dl
			mov numbers1[si+10], dl
			jmp verdi1
		
		versimatch1:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si+10], dl
			mov numbers1[si+20], dl
			jmp verdi1
		
		versimatch2:
			mov dx, 0
			mov numbers1[si], dl
			mov numbers1[si-10], dl
			mov numbers1[si-20], dl
			jmp verdi1
		
		verdi1:
			mov dx, 0
			mov dl, numbers1[di+10]
			cmp bl, dl
			JE verdi11
			jmp verdi2
		
		verdi11:
			mov dx, 0
			mov dl, numbers1[di+20]
			cmp bl, dl
			JE verdimatch1
			jmp verdimid1
		
		verdimid1:
			mov dx, 0
			mov dl, numbers1[di-10]
			cmp bl, dl
			JE verdimidmatch
			jmp verdi2
		
		verdi2:
			mov dx, 0
			mov dl, numbers1[di-10]
			cmp bl, dl
			JE verdi22
			jmp exitret
		
		verdi22:
			mov dx, 0
			mov dl, numbers1[di-20]
			cmp bl, dl
			JE verdimatch2
			jmp verdimid2
		
		verdimid2:
			mov dx, 0
			mov dl, numbers1[di+10]
			cmp bl, dl
			JE verdimidmatch
			jmp exitret
		
		verdimatch1:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di+10], dl
			mov numbers1[di+20], dl
			jmp exitret
		
		verdimatch2:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di-10], dl
			mov numbers1[di-20], dl
			jmp exitret
		
		verdimidmatch:
			mov dx, 0
			mov numbers1[di], dl
			mov numbers1[di-10], dl
			mov numbers1[di+10], dl
			jmp exitret
exitret:
ret
checkmatch endp

;proc which is called after checkmatch and a valid click
;checks for whether it was a bomb that caused the clearing
;also displays "crushing" when random numbers are being generated

updatenumbers PROC
	mov di, 0
	mov count, 0

	orientationloop:
		cmp count, 100
		je ending
		cmp numbers1[di], 0
		je zerofound
		inc di
		inc count
	jmp orientationloop

	zerofound:
		cmp numbers1[di+10], 0
		JE updatever
		cmp numbers1[di+1], 0
		JE updatehor
		jmp ending

	updatehor:
		mov zeroindex, di
		cmp bomb_bool, 1
		je bomb

		outerloop:
			cmp ycoor[di], 3
			je firstrow
			mov count, 3
			innerloop:
				cmp count, 0
				je nextitr
				mov al, numbers1[di-10]
				mov numbers1[di], al
				inc di
				dec count
			jmp innerloop
			nextitr:
			sub di, 13
		jmp outerloop

		firstrow:

		mov zeroindex, di

		mov si, 0
		mov cx, 1
		mov dh, 12
		mov dl, 12
		mov ah, 02h	
		INT 10h

		pr_crushing:
			cmp si, 9
			je randomgen
			mov cx, 1
			mov ah, 02h
			INT 10h
			mov ah, 09h
			mov al, crushing[si]
			INT 10h
			inc dl
			inc si
		jmp pr_crushing

		randomgen:
			mov count, 3
			mov di, zeroindex
		
			l1:
			cmp count, 0 
			je continue1
		
			;random number generator
			mov ah, 00h
			INT 1Ah
		
			mov ax, dx
			xor dx, dx
			mov cx, 5
			div cx
			
			add dx, 48
			add dl, 1
			mov numbers1[di], dl
		
			;delay 
			mov cx, 0Fh
			mov dx, 4240h
			mov ah, 86h
			INT 15h
		
			inc di
			dec count
			jmp l1
		continue1:
		
		add s_score, 3		

		jmp ending

		bomb:
		add s_score, 7
		
		outerloop1:
			cmp ycoor[di], 3
			je firstrow1
			mov count, 10
			innerloop1:
				cmp count, 0
				je nextitr1
				mov al, numbers1[di-10]
				mov numbers1[di], al
				inc di
				dec count
			jmp innerloop1
			nextitr1:
			sub di, 20
		jmp outerloop1

		firstrow1:		

		mov si, 0
		mov cx, 1
		mov dh, 12
		mov dl, 12
		mov ah, 02h	
		INT 10h

		pr_crushing5:
			cmp si, 9
			je randomgen4
			mov cx, 1
			mov ah, 02h
			INT 10h
			mov ah, 09h
			mov al, crushing[si]
			INT 10h
			inc dl
			inc si
		jmp pr_crushing5

		randomgen4:

		mov count, 10
	
		l3:
			cmp count, 0 
			je continue5
		
			;random number generator
			mov ah, 00h
			INT 1Ah
		
			mov ax, dx
			xor dx, dx
			mov cx, 5
			div cx
			
			add dx, 48
			add dl, 1
			mov numbers1[di], dl
		
			;delay 
			mov cx, 0Fh
			mov dx, 3240h
			mov ah, 86h
			INT 15h
		
			inc di
			dec count
			jmp l1		
		jmp l3		
		
		continue5:
			add s_score, 10			
	jmp ending

	updatever:
		cmp bomb_bool, 1
		je bomb1

		mov zeroindex, di
		cmp ycoor[di], 3
		je randomgen1

		cmp ycoor[di-10], 3
		je secondrow
		
		cmp ycoor[di-20], 3
		je thirdrow

		cmp ycoor[di-30], 3
		je fourthrow

		cmp ycoor[di-40], 3
		je fifthrow

		cmp ycoor[di-50], 3
		je sixthrow

		cmp ycoor[di-60], 3
		je seventhrow

		cmp ycoor[di-70], 3
		je eighthrow

		secondrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al
		jmp randomgen1

		thirdrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
		jmp randomgen1
		
		fourthrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
	
			mov al, numbers1[di-30]
			mov numbers1[di], al
		jmp randomgen1

		fifthrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
	
			mov al, numbers1[di-30]
			mov numbers1[di], al

			mov al, numbers1[di-40]
			mov numbers1[di-10], al
		jmp randomgen1		

		sixthrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
	
			mov al, numbers1[di-30]
			mov numbers1[di], al

			mov al, numbers1[di-40]
			mov numbers1[di-10], al

			mov al, numbers1[di-50]
			mov numbers1[di-20], al
		jmp randomgen1

		seventhrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
	
			mov al, numbers1[di-30]
			mov numbers1[di], al

			mov al, numbers1[di-40]
			mov numbers1[di-10], al

			mov al, numbers1[di-50]
			mov numbers1[di-20], al

			mov al, numbers1[di-60]
			mov numbers1[di-30], al
		jmp randomgen1

		eighthrow:
			mov al, numbers1[di-10]
			mov numbers1[di+20], al

			mov al, numbers1[di-20]
			mov numbers1[di+10], al
	
			mov al, numbers1[di-30]
			mov numbers1[di], al

			mov al, numbers1[di-40]
			mov numbers1[di-10], al

			mov al, numbers1[di-50]
			mov numbers1[di-20], al

			mov al, numbers1[di-60]
			mov numbers1[di-30], al

			mov al, numbers1[di-70]
			mov numbers1[di-40], al
		jmp randomgen1
		
		randomgen1:
		
		getfirstrow:
			cmp ycoor[di], 3
			je firstrowfound
			sub di, 10
		jmp getfirstrow

		firstrowfound:

		mov zeroindex, di

		mov si, 0
		mov cx, 1
		mov dh, 12
		mov dl, 12
		mov ah, 02h	
		INT 10h

		pr_crushing1:
			cmp si, 9
			je continue3
			mov cx, 1
			mov ah, 02h
			INT 10h
			mov ah, 09h
			mov al, crushing[si]
			INT 10h
			inc dl
			inc si
		jmp pr_crushing1

		continue3:
			mov count, 3			
	
			l2:
			cmp count, 0 
			je continue4
		
			;random number generator
			mov ah, 00h
			INT 1Ah
		
			mov ax, dx
			xor dx, dx
			mov cx, 5
			div cx
			
			add dx, 48
			add dl, 1
			mov numbers1[di], dl
		
			;delay 
			mov cx, 0Fh
			mov dx, 3240h
			mov ah, 86h
			INT 15h
		
			add di, 10
			dec count
			jmp l2
		continue4:

		add s_score, 3

		jmp ending

		bomb1:

		mov si, 0
		mov cx, 1
		mov dh, 12
		mov dl, 12
		mov ah, 02h	
		INT 10h

		pr_crushing3:
			cmp si, 9
			je continue7
			mov cx, 1
			mov ah, 02h
			INT 10h
			mov ah, 09h
			mov al, crushing[si]
			INT 10h
			inc dl
			inc si
		jmp pr_crushing3
		
		continue7:

		mov si, 0
		mov count, 10

		l5:
			cmp count, 0 
			je continue6
		
			;random number generator
			mov ah, 00h
			INT 1Ah
		
			mov ax, dx
			xor dx, dx
			mov cx, 5
			div cx
			
			add dx, 48
			add dl, 1
			mov numbers1[di], dl
		
			;delay 
			mov cx, 0Fh
			mov dx, 3240h
			mov ah, 86h
			INT 15h
		
			add di, 10
			dec count
		jmp l5
		continue6:

		add s_score, 10
	ending:
ret
updatenumbers endp


storeinvar1 PROC
mov ax, 0
mov ax, xcoord
mov xcoorvar1, al
mov ax, 0
mov ax, ycoord
mov ycoorvar1, al


ret
storeinvar1 endp


storeinvar2 PROC
mov ax, 0
mov ax, xcoord
mov xcoorvar2, al
mov ax, 0
mov ax, ycoord
mov ycoorvar2, al

ret
storeinvar2 endp

end main