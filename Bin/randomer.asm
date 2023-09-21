IDEAL
MODEL small
STACK 100h
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200
SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40
DATASEG
allCards db 52 dup (?)
stock db 24 dup (?)
xorer db 1
RandomNumber db ?
CODESEG
start:
      mov ax, @data
      mov ds,ax
	  call SetCardsValues
	  call RegisterStock
	  
	  
	
exit:
    ;int 21h
    mov ah,0
    int 16h
    mov ax,2
    int 10h
    mov ax, 4c00h
    int 21h
	
;
proc SetCardsValues
push ax
push bx
push dx
mov ax, 1
mov bx, offset allCards
mov dx, 52
add dx, bx
; dx now holds the offset of the end of the cards array
LoopGiveValues:
cmp bx, dx
je ExitAllCards
mov [bx],ax
inc ax
inc bx
jmp LoopGiveValues
ExitAllCards:
pop dx 
pop bx
pop ax
ret 
endp SetCardsValues

proc RegisterStock
push ax
push bx
push cx
push dx
mov ax, 40h
      mov es, ax
	  mov bx, offset stock
	  mov cx, 24
	  loop1:
	  jmp startLoop1
	  Again:
	  pop bx
	  startLoop1:
	  mov ax, [es:6Ch]
	  and al, 00111111b
	  xor al, 00101101b
	  cmp al,52
	  ja startLoop1
	  sub al,1
	  push bx
	  mov bx, offset allCards
	  xor ah,ah
	  add bx, ax
	  cmp [byte bx],0
	  je Again
	  mov dl, [byte bx]
	  mov [byte bx],0
	  pop bx
	  mov [bx], dx
	  inc bx
      LOOP Loop1 
	  pop dx
	  pop cx
	  pop bx
	  pop ax
	  ret 
	  endp RegisterStock
	  
	 proc GenRandNum
	 push ax
	 mov ax, 40h
      mov es, ax
	  mov ax, [es:6ch]
	  and al, 00011111b
	  mov [RandomNumber], al
	  pop ax
	  ret
	  endp GenRandNum
	  
END start




