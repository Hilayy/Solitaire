   IDEAL
MODEL small



STACK 100h

MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200

SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40





DATASEG

    OneBmpLine  db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer

    ScreenLineMax   db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer

    ;BMP File data
    FileHandle  dw ?
    Header      db 54 dup(0)
    Palette     db 400h dup (0)

    SmallPicName db 'OS2.bmp',0


    BmpFileErrorMsg     db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
    ErrorFile           db 0
    BB db "BB..",'$'

    BmpLeft dw ?
    BmpTop dw ?
    BmpColSize dw ?
    BmpRowSize dw ?


CODESEG
start:
    mov ax, @data
    mov ds, ax
    call SetGraphic
    mov [BmpLeft],10
    mov [BmpTop],50
    mov [BmpColSize], 320
    mov [BmpRowSize] ,2
 mov dx,offset SmallPicName
 call OpenShowBmp 
mov ax, 0
int 33h
mov ax, 1
	 int 33h
    cmp [ErrorFile],1
    jne cont1
    jmp exitError
cont1:  

    jmp exit

exitError:   

    mov dx, offset BmpFileErrorMsg
    mov ah,9
    int 21h


exit:
    mov dx, offset BB
    mov ah,9
    ;int 21h

    mov ah,0
    int 16h

    mov ax,2
    int 10h


    mov ax, 4c00h
    int 21h

; input :
;   1.BmpLeft offset from left (where to start draw the picture) 
;   2. BmpTop offset from top
;   3. BmpColSize picture width , 
;   4. BmpRowSize bmp height 
;   5. dx offset to file name with zero at the end 
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
proc CopyBmpPalette     near                    

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

proc  SetGraphic
    mov ax,13h   ; 320 X 200 
                 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
    int 10h
    ret
endp    SetGraphic
END start