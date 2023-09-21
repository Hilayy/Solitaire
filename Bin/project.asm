IDEAL
MODEL small
STACK 100h
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200
SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40
DATASEG
;;;
Cards db 52 dup (?)
hand db 24 dup (?)
xorer db 00000000b, 01010101b,10101010b,11111111b,11001100b,00110011b,10110110b, 01001001b
xorerIndex db 0
clock db -1
;;;
;;;
OpeningScreen db 'OS.bmp'
Heart2 db 'H2.bmp',0
Heart3 db 'H3.bmp',0
Heart4 db 'H4.bmp',0
Heart5 db 'H5.bmp',0
Heart6 db 'H6.bmp',0
Heart7 db 'H7.bmp',0
Heart8 db 'H8.bmp',0
Background db 'BG.bmp',0
;;;
;;;
OneBmpLine  db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
ScreenLineMax db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
;BMP File data
FileHandle dw ?
Header db 54 dup(0)
Palette db 400h dup (0)
ErrorFile db 0
BmpLeft dw ?
BmpTop dw ?
BmpColSize dw ?
BmpRowSize dw ?
;;;
; pixel borders of the buttons in the menu screen
Box1TopY dw 66
Box1BotY dw 86
Box1RX dw 209
Box1LX dw 111
Box2TopY dw 110
Box2BotY dw 131
Box2RX dw 216
Box2LX dw 102 
CardTopLeftX dw ?
CardTopLeftY dw ?
;;;
;;;

CODESEG
start:
      mov ax, @data
      mov ds,ax
	  mov ax, 13h
	  int 10h
	  mov dx, offset 
	  call SetCards
	  mov dx, offset hand
	  mov cx, 24
	  dealHand:
	  push dx
	  mov ax, 40h
	  mov es, ax
	  mov ax, [es:6ch]
	  xor ah, ah
	  cmp al, [clock]
	  je dealHand
	  mov [clock], al
	  and al, 00111111b
	  mov dx, offset xorer
	  call ChooseRandomXorer
	  add dx, [word xorerIndex]
	  mov bx, dx
	  pop dx
	  xor al, [bx]
	 and al, 00111111b
	 cmp al, 52
	 ja dealHand
	 mov bx, offset cards
	 add bx, ax
	 dec bx
	 cmp [byte bx],0
	 je dealHand
	 xchg bx, dx
	 mov [bx],ax
	 xchg bx, dx
	 mov [byte bx], 0
	 inc dx
	 loop dealHand
	 cmp [byte offset hand], 26
	 jb exit
	 mov dx, offset Heart2
	 mov [BmpLeft], 50
	 mov[BmpTop], 55
	 mov [BmpColSize], 18
	 mov [BmpRowSize], 29
	 call OpenShowBmp
exit:
mov ax, 4c00h
int 21h
	
  ;procs
  
proc CheckRightClickOnBoxes 
WaitForMouseClickInBox: 
	mov ax, 3h 
	int 33h
	shr cx,1
	cmp bx, 01h
	jne CheckBox2
	cmp cx, [Box1RX]
	ja CheckBox2
	cmp cx, [Box1LX]
	jb CheckBox2
	cmp dx, [Box1TopY]
	jb CheckBox2
	cmp dx, [Box1BotY]
	ja CheckBox2
	jmp Print2ndPic
   CheckBox2:
   cmp bl,01h
   jne WaitForMouseClickInBox
   cmp cx, [Box2RX]
   ja WaitForMouseClickInBox
   cmp cx, [Box2LX]
   jb WaitForMouseClickInBox
   cmp dx, [Box2TopY]
   jb WaitForMouseClickInBox
   cmp dx, [Box2BotY]
   ja WaitForMouseClickInBox
   Print2ndPic:

   call OpenShowBmp
   ret 
   endp CheckRightClickOnBoxes
   
  proc SetCards
  push ax
  push bx
  push cx
  mov ax, 1
  mov bx, offset Cards
  mov cx, 52
  LoopSetCards:
  mov [bx], ax
  inc ax
  inc bx
  loop LoopSetCards
  pop cx
  pop bx
  pop ax
  ret
  endp SetCards
  
  proc ChooseRandomXorer
  push ax
  mov ax, 40h
  mov es, ax
  mov ax, [es:6ch]
  xor ah,ah
  and al , 00000111b
  mov [xorerIndex], al
  pop ax
  ret 
  endp ChooseRandomXorer
 


  
  
  
	  


























































	  
;
;
;
;
;
proc OpenShowBmp near
push cx
push bx
call OpenBmpFile
cmp [ErrorFile],1
je @@ExitProc
call ReadBmpHeader
 ; from  here assume bx is global param with file handle. 
call ReadBmpPalette
call CopyBmpPalette
call ShowBMP
call CloseBmpFile
@@ExitProc:
pop bx
pop cx
ret
endp OpenShowBmp
; input dx filename to open
proc OpenBmpFile    near                         
mov ah, 3Dh
xor al, al
int 21h
jc @@ErrorAtOpen
mov [FileHandle], ax
jmp @@ExitProc
@@ErrorAtOpen:
mov [ErrorFile],1
@@ExitProc: 
ret
endp OpenBmpFile

proc CloseBmpFile near
mov ah,3Eh
mov bx, [FileHandle]
int 21h
ret
endp CloseBmpFile
; Read 54 bytes the Header
proc ReadBmpHeader  near                    
push cx
push dx
mov ah,3fh
mov bx, [FileHandle]
mov cx,54
mov dx,offset Header
int 21h
 pop dx
pop cx
ret
endp ReadBmpHeader

proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
                         ; 4 bytes for each color BGR + null)           
push cx
push dx
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
pop dx
pop cx
ret
endp ReadBmpPalette

; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette near                    
push cx
push dx
mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0  ; black first                         
out dx,al ;3C8h
inc dx    ;3C9h
CopyNextColor:
mov al,[si+2]       ; Red               
shr al,2            ; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).             
out dx,al                       
mov al,[si+1]       ; Green.                
shr al,2            
out dx,al                           
mov al,[si]         ; Blue.             
shr al,2            
out dx,al                           
add si,4            ; Point to next color.  (4 bytes for each color BGR + null)             
loop CopyNextColor
pop dx
pop cx
ret
endp CopyBmpPalette

proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
push cx
mov ax, 0A000h
mov es, ax
mov cx,[BmpRowSize]
mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
xor dx,dx
mov si,4
div si
mov bp,dx
mov dx,[BmpLeft]
@@NextLine:
push cx
push dx
mov di,cx  ; Current Row at the small bmp (each time -1) 
add di,[BmpTop] ; add the Y on entire screen
   ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
mov cx,di
shl cx,6
shl di,8
add di,cx
add di,dx
; small Read one line
mov ah,3fh
mov cx,[BmpColSize]  
add cx,bp  ; extra  bytes to each row must be divided by 4
mov dx,offset ScreenLineMax
int 21h
; Copy one line into video memory
cld ; Clear direction flag, for movsb
mov cx,[BmpColSize]  
mov si,offset ScreenLineMax
rep movsb ; Copy line to the screen
pop dx
pop cx
loop @@NextLine
pop cx
ret
endp ShowBMP

proc SetGraphic
push ax
mov ax, 13h 
int 10h
pop ax
ret
endp SetGraphic

END start




