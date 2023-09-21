IDEAL
MODEL small
STACK 100h
DATASEG
color db 1
RowPos dw ?
RowLength db ?
ColPos dw ?
ColLength db ? 
CardTopLeftX dw ?
CardTopLeftY dw ?
CODESEG
proc PHL; print horizonal line
push ax
push bx
push cx
push dx
push [word RowLength]
mov cx, [RowPos]
mov dx, [ColPos]
mov ah, 0ch
mov al , [color]
mov bh,0
PrintPixelH:
cmp  [RowLength],0
je ExitPHL
int 10h
inc cx
dec [RowLength]
jmp PrintPixelH
ExitPHL:
pop [word RowLength]
pop dx
pop cx
pop bx
pop ax
ret
endp PHL

proc DrawRec 
push dx
PrintRow:
cmp [ColLength],0
je ExitDrawRec
call PHL
inc dx
dec [ColLength]
jmp PrintRow
ExitDrawRec:
pop dx
ret 
endp DrawRec
start:
    mov ax, @data
    mov ds,ax
   
exit:
mov ax,4C00h
int 21h
END start