bits 16
org 0x7C00

	cli
	mov edi, 0xB8000
	mov ax, 0;
	mov ss, ax;
	mov sp, 0xFFFF;
	
;	mov bh, 0;
;	mov bl, 1;
;	call MovCur;
;	hlt;
	jmp check_key

MovCur: 
	pusha
	mov bl,[x]
	mov bh ,[y];
	xor	eax, eax
	mov	ecx, 80
	mov	al, bh			; get y pos
	mul	ecx			; multiply y*COLS
	add	al, bl			; Now add x
	mov	ebx, eax
	mov	al, 0x0f		; Cursor location low byte index
	mov	dx, 0x03D4		; Write it to the CRT index register
	out	dx, al
    mov	al, bl			; The current location is in EBX. BL contains the low byte, BH high byte
	mov	dx, 0x03D5		; Write it to the data register
	out	dx, al			; low byte
	xor	eax, eax
	mov	al, 0x0e		; Cursor location high byte index
	mov	dx, 0x03D4		; Write to the CRT index register
	out	dx, al
	mov	al, bh			; the current location is in EBX. BL contains low byte, BH high byte
	mov	dx, 0x03D5		; Write it to the data register
	out	dx, al			; high byte

	popa
	ret
	
check_key:
	in al, 0x64;
	and al, 1;
	jz check_key
	
	;If pressed get key
	in al, 0x60;
leftshift:
	cmp al, 0XAA ;shift break code 
	jne rightshift
	xor cl,cl
	mov [shift],cl
	jmp endd
	
rightshift:
	cmp al, 0XB6 ;shift break code 
	jne translation
	xor cl,cl
	mov [shift],cl
	jmp endd
translation:	
	;translate key
	cmp al, 0x80; make key
	ja check_key
	
backspace:
	cmp al ,0x0E; make key
	jne space
	dec edi
	dec edi
	mov al,0x20 ;ascii code 0x08
	mov [edi],al
bcursor:	
	mov bl,[x]
	cmp bl,80
	jb decreasment 
	
	sub bl,80
	mov bh,[y]
	dec bh
	mov [y],bh
decreasment:
    dec bl
    mov [x],bl	
	call MovCur
	jmp endd
 	
space:	
	cmp al ,0x39; make key
	jne shiftleft
	mov al ,0x20
	mov [edi],al
	inc edi
	inc edi
	jmp cursor
		
shiftleft:
	cmp al,0X2A; shift make code 
	jne rightshiftm
	xor ecx,ecx
	mov cl,1
	mov [shift],cl
    jmp endd
rightshiftm:
    cmp al,0x36; shift make code 
	jne rightarrow
	xor ecx,ecx
	mov cl,1
	mov [shift],cl
    jmp endd
	
rightarrow: 
	cmp al, 0x4D ;right arrow
	jne leftarrow 
	mov cl , [shift]
;	add cl, 0x30;
;	mov [edi], cl;
;	inc edi
;	inc edi;
;	sub cl, 0x30;
	
	cmp cl, 1
	jne moveright
	inc edi
	inc edi
	xor edx,edx
    mov edx,[edi]
	mov dh,0X70
	mov [edi],dx
	jmp cursor
	
moveright:
	inc edi
	inc edi    
	jmp cursor
	
	
leftarrow:
	cmp al, 0x4B ;leftarrow
	jne start
	mov cl , [shift]
	cmp cl,1
	jne moveleft
	dec edi
	dec edi
	xor edx,edx
    mov edx,[edi]
	mov dh,0X70
	mov [edi],dx
	jmp bcursor
	
moveleft:
	dec edi
	dec edi    
	jmp bcursor
	


start:
	cmp al ,0x0B
	ja line1
	mov ebx, ScanCodeTable1	
	sub al,0X02
	xlat
	mov [edi], al;
	inc edi;
	inc edi;
	
	jmp cursor
	
line1: 
	cmp al , 0X19
	ja line2
	cmp al,0X10 
	jb endd
	sub al,0X10
	mov ebx, ScanCodeTable2	
	jmp write
	
line2:
	cmp al , 0X26
	ja line3
	cmp al,0X1E
	jb endd
	sub al,0X1E
	mov ebx, ScanCodeTable3	
	jmp write
	
line3:
	cmp al , 0X32
	ja endd
	cmp al,0X2C
	jb endd
	sub al,0X2C
	mov ebx, ScanCodeTable4	
write:
	xlat
	mov cl , [shift]
	cmp cl,1
	jne noshift
	sub al,0X20
	
noshift:
	mov [edi], al;
	inc edi;
	inc edi;
cursor:
	mov bl,[x]
	cmp bl,80
	jb increasment 
	
	sub bl,80
	mov bh,[y]
	inc bh
	mov [y],bh
increasment:
    inc bl
    mov [x],bl	
	call MovCur
	
	endd:
	jmp check_key
	
	 ScanCodeTable1: db "1234567890"
	 ScanCodeTable2: db "qwertyuiop"
	 ScanCodeTable3: db "asdfghjkl"
	 ScanCodeTable4: db "zxcvbnm"
	 shift: dd 0
	 x: dd 0
	 y: dd 0
         control: dd 0
         arrow: dd 0
        
times (510 - ($ - $$)) db 0
db 0x55, 0xAA
times (0x400000 - 512) db 0

db 	0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db	0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db	0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db	0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db	0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db	0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
