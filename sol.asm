IDEAL
MODEL small
STACK 100h
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200
DATASEG
card_col_size equ 18
card_row_size equ 29
;-------------------------------------------------------------------------------------------------------------------------
;Arrays that hold the position and value of the cards
Cards db 52 dup (?)
hand db 0, 24 dup (?)
handIndex dw 0
FoundationArrH db 0,  13 dup (0)
arrHIndex dw 0
FoundationArrD db 13, 13 dup (0)
arrDIndex dw 0
FoundationArrS db 26, 13 dup (0)
arrSIndex dw 0
FoundationArrC db 39, 13 dup (0)
arrCIndex dw 0
CurrentFouOffset dw ?
CurrentFouIndex dw ?
CurrentFouIndexOffset dw ?
CardCol1 db 13 dup (?)
CardCol2 db 14 dup (?)
CardCol3 db 15 dup (?)
CardCol4 db 16 dup (?)
CardCol5 db 17 dup (?)
CardCol6 db 18 dup (?)
CardCol7 db 19 dup (?)
Col1Index dw 1
Col2Index dw 2
Col3Index dw 3
Col4Index dw 4
Col5Index dw 5
Col6Index dw 6
Col7Index dw 7
CurrentColOffset dw ?
CurrentColIndex dw ?
CurrentColIndexOffset dw ?
ClickedColShownCards db 13 dup (?)
; these integers hold the number of hidden cards there are in all of the Card Columns
HCCol1 dw 0
HCCol2 dw 1
HCCol3 dw 2
HCCol4 dw 3
HCCol5 dw 4
HCCol6 dw 5
HCCol7 dw 6
HCCurrentCol dw ?
HCCurrentColOffset dw ?
SelectedCards db 13 dup (0)
ClickedColX dw ?
ClickedColY dw ?
SecondColClickX dw ?
SecondColClickY dw ?
ClickedColLeft dw ?
SelectedCounter dw ?
;-------------------------------------------------------------------------------------------------------------------------
; Images that are used in the program
OpeningScreen db 'OS.bmp',0
HiddenCard db 'HC.bmp',0
XCard db 'XX.bmp',0
HeartFoundation db 'HF.bmp',0
DiamondFoundation db 'DF.bmp',0
SpadeFoundation db 'SF.bmp',0
ClubFoundation db 'CF.bmp',0
ExitSign db 'exit.bmp', 0
Rules db 'rules.bmp', 0
soundOn db 'soundon.bmp', 0
soundOff db 'soundoff.bmp', 0
;-------------------------------------------------------------------------------------------------------------------------
CardValue db ?
;-------------------------------------------------------------------------------------------------------------------------
;Integers that are used for generating random numbers
xorer db 00011010b, 00101010b, 00111011b, 01101010b, 11010010b, 10101001b, 1
xorerIndex dw 0  
RandomNumber dw ?
timer dw -1
;-------------------------------------------------------------------------------------------------------------------------
sound db 1 ;determines if the sound will be on or off 0-off 1-on
;Integers used for in-program pixel printing
Color db 154
ColPos dw 0
RowPos dw 0
ColLength dw 0
RowLength dw 0
x dw ?
y dw ?
TopYCol dw ?
BotYCol dw ?
;-------------------------------------------------------------------------------------------------------------------------
;Integers used for showing BMP file process
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
;-------------------------------------------------------------------------------------------------------------------------
;Borders of buttons that are showed in the opening screen
Box1TopY dw 63
Box1BotY dw 86
Box1RX dw 210
Box1LX dw 111
Box2TopY dw 106
Box2BotY dw 129
Box2RX dw 205
Box2LX dw 111 
;-------------------------------------------------------------------------------------------------------------------------
bool db 0 ; another boolean integer used in certain procs
won db 0; holds 1 if the player won the game and 0 if not
;--------------------------------------------------------------------
ClickCounter dw 0
ClickCountString db 'clicks:000$'
WinMessage1 db 'Congratulations!, You Won!', 10, 13, '$'
WinMessage2 db 'Press Any Key To Return To The Main Menu..$'


;-------------------------------------------------------------------------------------------------------------------------
CODESEG
start:
 mov ax, @data
 mov ds,ax
 call Solitaire
exit:
mov ah, 7
int 21h
mov ax, 4c00h
int 21h
;-------------------------------------------------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------------------------------------------------	
;procs  
proc Solitaire 
 call SetGraphic
 NewGame:
 mov ax, 2
 int 33h
 call PrintOS
 mov ax, 1
 int 33h
 call SetCursor
 call OSClicks
 cmp [bool], 0
 jne RulesClicked
 call SetupGame
 call DeleteScreen
 cmp [won], 0
 je NewGame
 mov dx, offset WinMessage1
 mov ah, 9
 int 21h
 mov dl, 0
 mov dh, 20
 mov ah, 2
 int 10h
 mov dx, offset WinMessage2
 mov ah, 9
 int 21h
 mov ah, 7
 int 21h
 jmp NewGame
 RulesClicked: 
  mov [BmpTop],0
  mov [BmpLeft], 0
  mov [BmpColSize], 320
  mov [BmpRowSize], 200
  mov dx, offset Rules
  mov ax, 2
  int 33h
  call OpenShowBmp
  mov ax, 1
  int 33h
  mov ah, 7
  int 21h
  jmp NewGame
 ret
endp Solitaire
;----------------------------------------------------------------------------------------
proc SetupGame
  mov [arrHIndex], 0
  mov [arrDIndex], 0
  mov [arrSIndex], 0
  mov [arrCIndex], 0
  mov [Col1Index], 1
  mov [Col2Index], 2
  mov [Col3Index], 3
  mov [Col4Index], 4
  mov [Col5Index], 5
  mov [Col6Index], 6
  mov [Col7Index], 7
  mov [HCCol1] ,0
  mov [HCCol2], 1
  mov [HCCol3], 2
  mov [HCCol4], 3
  mov [HCCol5], 4
  mov [HCCol6], 5
  mov [HCCol7], 6
  
 call DeleteScreen
 call SetCards
 call DealHand
 call DealLayout
 call PrintBackGround
 call PrintLayout
 call SetCursor
 call InGame
ret
endp SetupGame
;----------------------------------------------------------------------------------------------------------
 proc SetCards ; the procedure gives linear values from 1-52 to all the indexes in the 'Cards' array, it will be useful for later procedures 
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
;----------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------
proc DealHand ; the procedure chooses randomaly 24 indexes from the 'Cards' array and transfers their values to the 'hand' array, the procedure also changes the said index value to 0, so every number can be transfered just once.
  push ax
   push bx
   push cx
   push dx
   mov cx, 24
   mov dx, offset hand
   loopDealHand:
   mov bx, offset cards
   call RNG
   add bx, [RandomNumber]
   dec bx
   cmp [byte bx],0
   je  loopDealHand
   mov [byte bx],0
   xchg bx, dx
   mov ax, [RandomNumber]
   mov [bx],ax
   xchg bx, dx
   inc dx
   loop loopDealHand
  pop dx
  pop bx
  pop cx
  pop dx
  ret 
endp DealHand
;------------------------------------------------------------------------------------------------------------------
proc DealLayout ; the procedure chooses random indexes in the 'Cards' array and transfers their value to one if the card columns in the layout
push ax
push bx
push cx
push dx
mov bx, offset CardCol1
mov ax, 1
mov cx, 7
loop1:
push cx
mov cx, ax
loop2:
 call RNG
 mov si, [RandomNumber]
 dec si
 cmp [byte si], 0
 jne movToLayout
 decreaseNum:
 cmp si, 0
 je loop2
 dec si
 cmp [byte si], 0
 je decreaseNum
 movToLayout:
 mov dl, [byte si]
 mov [byte si], 0
 mov [byte bx], dl
 inc bx
loop loop2
add bx, 12
inc ax
pop cx
loop loop1
 pop dx
 pop cx
 pop bx
 pop ax
 ret 
endp DealLayout
;-----------------------------------------------------------------------------------------------------------
proc RNG ; the procedure generates a random number between 1-52 and transfers it to the 'RandomNumber' integer
push ax
push bx
mov bx, offset xorer
add bx, [xorerIndex]
 GetRN: ; loop until a number in the desired range is 
 mov ax, 40h
 mov es, ax
 mov ax, [es:6ch]
 mov ah, [byte bx]
 xor al, ah
 xor ah, ah
 and al, 00111111b
 cmp al, 0
 je GetRN
 cmp al, 34h
 ja GetRN
 mov [RandomNumber], ax
 inc [xorerIndex]
 mov bx, offset xorer
 add bx ,[xorerIndex]
 cmp [byte bx], 1
 jne ExitRNG
 mov [xorerIndex], 0
 ExitRNG:
 pop bx
 pop ax
 ret
endp RNG
;---------------------------------------------------------------------------------------------------------------  
proc Delay
 push ax
 push cx
  mov cx, 1
  loopDelay:
   mov ax, 40h
   mov es, ax
   mov ax ,[es:6ch]
   cmp [timer], ax
   je loopDelay
   mov [timer], ax
 loop loopDelay
 pop cx
 pop ax
ret 
endp Delay
;-----------------------------------------------------------------------------------------------------
proc DeleteCard ;gets the coordinates of a the top-left corner of the card and replaces the card with the background color
 push bx
 push cx
 push [BmpTop]
 inc [BmpTop]
 mov bx, [BmpLeft]
 mov [ColPos], bx
 mov bx, [BmpTop]
 mov [RowPos], bx
 inc [RowPos]
 mov [RowLength], 18
 mov cx, 29
 print1Line:
 mov [color], 0
 call PHL
 mov [color], 31h
 call PHL
 inc [RowPos]
 loop print1Line
 pop [BmpTop]
 pop cx
 pop bx
 ret
endp DeleteCard
;-----------------------------------------------------------------------------------------------------------------
proc CardByValue ; gets a number between 1-52 and converts it to an actual card printed on the screen
 push ax
 push bx
 push dx
  mov bx, offset XCard
  mov al, [CardValue]
  cmp al, 26
  FindSuit:
   ja itsBlue
   itsRed:
    cmp al, 13
    ja itsDiamonds
    itsHearts:
     mov [byte bx], 'H'
     jmp FindRank
	itsDiamonds:
	mov [byte bx], 'D'
	sub al, 13
	jmp FindRank
   itsBlue:
    cmp al, 39
	ja itsClubs
	itsSpades:
	 mov [byte bx], 'S'
	 sub al, 26
	 jmp FindRank
	itsClubs:
	 mov [byte bx], 'C'
	 sub al, 39
  FindRank:
   cmp al, 9
   ja itsLetters
   itsNumbers:
    add al, 30h
    mov [byte bx+1], al
    jmp ExitCardByValue
   itsLetters:
    cmp al, 10
    jne itsRoyal
    its10:
     mov [byte bx+1], 'T'
     jmp ExitCardByValue
   itsRoyal:
    cmp al, 11
	jne itsQueenKing
	itsJack:
	 mov [byte bx+1], 'J'
	 jmp ExitCardByValue
	itsQueenKing:
	cmp al, 12
	jne itsKing
	itsQueen:
	 mov [byte bx+1], 'Q'
	 jmp ExitCardByValue
	itsKing:
	 mov [byte bx+1], 'K'
	 
 ExitCardByValue:
 mov dx, offset XCard
 call OpenShowBmp
 pop dx
 pop bx
 pop ax
 ret
endp CardByValue
;-----------------------------------------------------------------------------------------------------
proc PrintLayout ; prints the hidden and shown cards in their places on the board that were determined by the 'DealLayout' procedure
 push ax
 push bx
 push cx
 push dx
  mov [BmpLeft], 0
  mov [BmpTop], 0
  mov [BmpColSize], 36
  mov [BmpRowSize], 16
  mov dx, offset ExitSign
  call OpenShowBmp
  mov [BmpColSize], card_col_size
  mov [BmpRowSize], card_row_size
  mov [BmpLeft], 30
  mov [BmpTop], 25
  mov dx, offset HiddenCard
  call OpenShowBmp
  add [BmpTop], 40
  mov al, [byte offset CardCol1]
  mov [CardValue], al
  call CardByValue
  add [BmpLeft], 42
  mov dx, offset HiddenCard
  call OpenShowBmp
  add [BmpTop],4
  mov al, [byte offset CardCol2+1]
  mov [CardValue], al
  call CardByValue
  sub [BmpTop], 4
  add [BmpLeft], 42
  mov cx, 2
  loopCol3:
   mov dx, offset HiddenCard
   call OpenShowBmp
   add [BmpTop],4
  loop loopCol3
  mov al, [byte offset CardCol3+2]
  mov [CardValue],al
  call CardByValue
  sub [BmpTop], 8
  add [BmpLeft], 42
  mov cx, 3
  loopCol4:
   mov dx, offset HiddenCard
   call OpenShowBmp
   add [BmpTop],4
  loop loopCol4
  mov al, [byte offset CardCol4+3]
  mov [CardValue], al
  call CardByValue
  sub [bmpTop], 12
  add [BmpLeft], 42
  mov cx, 4
  loopCol5:
   mov dx, offset HiddenCard
   call OpenShowBmp
   add [BmpTop],4 
  loop loopCol5
  mov al, [byte offset CardCol5 +4]
  mov [CardValue], al
  call CardByValue
  sub [BmpTop],16
  add [BmpLeft], 42
  mov cx, 5
  loopCol6:
   mov dx, offset HiddenCard
   call OpenShowBmp
   add [BmpTop],4
  loop loopCol6
  mov al, [byte offset CardCol6 +5]
  mov [CardValue], al
  call CardByValue
  sub [BmpTop], 20
  add [BmpLeft], 42
  mov cx, 6
  loopCol7:
   mov dx, offset HiddenCard
   call OpenShowBmp
   add [BmpTop],4
  loop loopCol7
  mov al, [byte offset CardCol7+6]
  mov [CardValue], al
  call CardByValue
  mov [BmpTop], 25
  mov [BmpLeft],282
  mov dx, offset ClubFoundation
  call OpenShowBmp
  sub [BmpLeft], 42
  mov dx, offset SpadeFoundation
  call OpenShowBmp
  sub [BmpLeft], 42
  mov dx, offset DiamondFoundation
  call OpenShowBmp
  sub [BmpLeft], 42
  mov dx, offset HeartFoundation
  call OpenShowBmp
 pop dx
 pop cx
 pop bx
 pop ax
 ret
endp PrintLayout
;-----------------------------------------------------------------------------------------------------
proc InGame
 push ax
 push bx
 push cx
 push dx
 call InitializeClickCount
 CheckMouseLocation:
  ;if all the foundation piles are filled the procedure ends
  CheckIfWon:
   cmp [arrHIndex], 13
   jne CheckGame
   cmp [arrDIndex], 13
   jne CheckGame
   cmp [arrSIndex], 13
   jne CheckGame
   cmp [arrCIndex], 13
   jne CheckGame
  GameWon:
   mov [won], 1
   jmp ExitInGame
  CheckGame:
  mov [BmpLeft], 30
  mov [BmpTop], 25
  call UnhighlightCard
 mov ax, 3
 int 33h
 shr cx, 1
 add dx, 1
  CheckHand:
   cmp cx, 30
   jb CheckHandCard
   cmp cx,48
   ja CheckHandCard
   cmp dx, 25
   jb CheckHandCard
   cmp dx, 54
   ja CheckHandCard
   MouseOnHand:
    cmp bx, 00000001b
	jne CheckMouseLocation
	call IncreaseClickCount
	mov [BmpLeft], 30
	mov [BmpTop], 25
	call HighlightCard
	jmp ClickOnHand
InGame3:
 jmp CheckMouseLocation
    ClickOnHand:
	call HighlightCard
     mov ax, 3h
	 int 33h
	 shr cx, 1
	 cmp cx, 30
     jb InGame3
     cmp cx,48
     ja InGame3
     cmp dx, 25
     jb InGame3
     cmp dx, 54
     ja InGame3
	 cmp bx, 00000000b
	 jne ClickOnHand
	 call SoundStatus 
     jmp ReleaseOnHand
InGame1:
jmp InGame3	 
	 ReleaseOnHand:
	 call HandClicked 
	 jmp CheckMouseLocation
  CheckHandCard:
   cmp cx, 60
   jb CheckColumns
   cmp cx, 78
   ja CheckColumns
   cmp dx, 25
   jb CheckColumns
   cmp dx, 54
   ja CheckColumns
   MouseOnHandCard:
    cmp bx, 00000001b
	jne InGame1
	call IncreaseClickCount
	mov [BmpLeft], 60
	mov [BmpTop], 25
    cmp [handIndex], 0
	je InGame1
	call HighlightCard
	; highlights the hand card , checks if the mouse was also released on the hand card.
	ClickOnHandCard:
	 mov ax, 2
	 int 33h
	 call HighlightCard
	 mov ax, 1
	 int 33h
     mov ax, 3
	 int 33h
	 shr cx, 1
	 cmp cx, 60
     jb InGame1
     cmp cx, 78
     ja InGame1
     cmp dx, 25
     jb InGame1
     cmp dx, 54
     ja InGame1
     cmp bx, 00000000b
	 jne ClickOnHandCard
	 call SoundStatus
	 jmp ReleaseOnHandCard
InGame2:
jmp InGame1
	 ReleaseOnHandCard:
	  call HandCardClicked
    jmp InGame2 
  CheckColumns:
   call FindWhatCol
   cmp [bool], 0
   je CheckExit
  MouseOnColumns:
   cmp bx, 00000001b
   jne InGame2
   call IncreaseClickCount
  ClickOnColumns:
   call FindWhatCol
   cmp [CurrentColIndex], 0
   je InGame2
   call ColsClicked
   jmp InGame2
  CheckExit:
   cmp cx, 36
   ja InGame2
   cmp dx, 16
   ja InGame2
  MouseOnExit:
   cmp bx, 00000001b
   jne InGame2
   call SoundStatus
   call WaitForRelease
   cmp cx, 36
   ja InGame2
   cmp dx, 16
   ja InGame2
  ExitClicked:
   mov [won], 0
 ExitInGame:
 pop dx
 pop cx 
 pop bx
 pop ax
 ret
endp InGame
;-----------------------------------------------------------------------------------------------------
proc HandClicked ;shows the cards in the hand by order
 push ax
 push bx
 ; the coordinates of the hand card
   mov [BmpTop], 25
   mov [BmpLeft], 60
  xor bh, bh
  mov ax, 1
  int 33h
  ; checks if there are no more cards left to show in the hand and resets the hand if so
  cmp [handIndex], 24
  jb ShowHandCard
  resetHandIndex:
   mov [handIndex], 0
   call DeleteCard
   mov ax, 1
   int 33h
   jmp ExitHandClicked
   cardAlreadyUsed:
   inc [handIndex]
   cmp [handIndex], 24
   je ResetHandIndex
  ShowHandCard:  
   mov bx, offset hand
   add bx, [handIndex]
   cmp [byte bx], 0
   je cardAlreadyUsed
   mov al, [byte bx]
   call DeleteCard
   mov [CardValue], al
   mov ax, 2
   int 33h
   call CardByValue
   mov ax, 1
   int 33h
   inc [handIndex]
   jmp ExitHandClicked
 ExitHandClicked:
 pop bx
 pop ax
 ret
endp HandClicked
;-----------------------------------------------------------------------------------------------------
proc HandCardClicked
 push ax
 push bx
  mov bx, offset hand
  add bx, [handIndex]
  dec bx
  mov al ,[byte bx]
  mov [CardValue], al
  CheckClickAftHC:
   mov ax, 3
   int 33h
   shr cx, 1
   cmp bx, 00000001b
  jne CheckClickAftHC
  CheckFouAftHC: 
   call EligibleToFoundation
  cmp [bool], 1
  je ExitHandCardClicked
  call EligibleToColumns
  cmp [bool], 0
  je MissClickAftHC
  ExitHandCardClicked:
 call RetrieveLatestHandCard
 MissClickAftHC:
  mov [BmpLeft], 60
 mov [BmpTop], 25
 call UnhighlightCard
 
 call IncreaseClickCount
 pop bx
 pop ax
 ret
endp HandCardClicked
;----------------------------------------------------------------------------------------------------
proc EligibleToFoundation
 push ax
 push bx
 mov [bool], 0
  CheckIfEligibleToFou:
    cmp dx, 25
   jb MtchpWF0Temp2
    cmp dx, 54
   ja MtchpWF0Temp2
   mov [BmpTop], 25
   MouseOnHF:
    cmp cx, 156
   jb MouseOnDF
    cmp cx, 174
   ja MouseOnDF
    mov bx, offset FoundationArrH
	add bx, [arrHIndex]
	mov al, [CardValue]
	sub al, [byte bx]
	cmp al, 1
	jne MtchpWF0Temp2
	EligibleToHF:
     mov [BmpLeft], 156
	 mov ax, 2
	 int 33h
	 call CardByValue
	 mov ax, 1
	 int 33h
	 mov al, [CardValue]
	 inc [arrHIndex]
	 inc bx
	 mov [byte bx], al
	 jmp MatchUpWithFoundation1
MtchpWF0Temp2:
jmp MissAftHCTemp1
	MouseOnDF:
     cmp cx, 198
	jb MouseOnSF
	 cmp cx, 216
	ja MouseOnSF
	 mov bx, offset FoundationArrD
	 add bx, [arrDIndex]
	 mov al, [CardValue]
	 sub al, [byte bx]
	 cmp al, 1
     jne MissAftHCTemp1
	 jmp EligibleToDF
	 
    EligibleToDF:
	 mov [BmpLeft], 198
	 mov ax, 2
	 int 33h
	 call CardByValue
	 mov ax, 1
	 int 33h
	 mov al, [CardValue]
	 inc [arrDIndex]
	 inc bx
	 mov [byte bx], al
	 jmp MatchUpWithFoundation1
	 MouseOnSF:
     cmp cx, 240
	jb MouseOnCF
	 cmp cx, 258
	ja MouseOnCF
	 mov bx, offset FoundationArrS
	 add bx, [arrSIndex]
	 mov al, [CardValue]
	 sub al, [byte bx]
	 cmp al, 1
     jne MissAftHCTemp1
    EligibleToSF:
     mov [BmpLeft], 240
	 mov ax, 2
	 int 33h
	 call CardByValue
	 mov ax, 1
	 int 33h
	 mov al, [CardValue]
	 inc [arrSIndex]
	 inc bx
	 mov [byte bx], al	
	 jmp MatchUpWithFoundation1
MissAftHCTemp1:
jmp MatchUpWithFoundation0
	MouseOnCF:
     cmp cx, 282
	jb MatchUpWithFoundation0
	 cmp cx, 300
	ja MatchUpWithFoundation0
	 mov bx, offset FoundationArrC
	 add bx, [arrCIndex]
	 mov al, [CardValue]
	 sub al, [byte bx]
	 cmp al, 1
     jne MatchUpWithFoundation0
    EligibleToCF:
	 mov [BmpLeft], 282
	 mov ax, 2
	 int 33h
	 call CardByValue
	 mov ax, 1
	 int 33h
	 mov al, [CardValue]
	 inc [arrCIndex]
	 inc bx
	 mov [byte bx], al	
 MatchUpWithFoundation1:
 mov [bool],1 
 jmp ExitEligibleToFoundation
 MatchUpWithFoundation0:
 ExitEligibleToFoundation:
 pop bx
 pop ax
 ret
endp EligibleToFoundation
;---------------------------------------------------------------------------------------------------------------

proc EligibleToColumns
 push ax
 push bx
 push cx
 push dx
 push si
 push di
  mov [bool], 1
  call FindWhatCol
  call FindColLimits 
  mov ax, [BotYCol]
  cmp dx, ax
  ja NotEligibleToColumns
  sub ax, 29
  cmp dx, ax
  jb NotEligibleToColumns
  CheckIfMatching:
   add si, [CurrentColIndex]
   dec si
   mov bl, [byte si]
   call ifMatching
   cmp [bool], 0
   je NotEligibleToColumns
   AddToCol:
    mov ax, 2
	int 33h
   inc [CurrentColIndex]
	mov bx, [CurrentColIndexOffset]
	inc [byte bx]
	call FindColLimits
    mov ax, [BotYCol]
	sub ax, 29
	mov [BmpTop], ax
    inc si
	mov al, [CardValue]
	mov [byte si], al
	call CardByValue
	mov ax, 1
	int 33h
    jmp ExitEligibleToColumns
	 
 NotEligibleToColumns:
  mov [bool], 0
 ExitEligibleToColumns:
  mov ax, 3
  int 33h 
  cmp bx, 00000000b
  jne ExitEligibleToColumns
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 pop ax
 ret
endp EligibleToColumns
;--------------------------------------------------------------------------------------------------------
proc FindWhatCol ; checks wether the mouse on one of the columns and if so, transfer some values about that column to integers used in other procs
 push ax
 push bx
  mov [bool], 0  
  ;check if the cursor clicked in the general x field of the columns
  cmp cx, 30
  jb NoMatchWithColsTemp4
  cmp cx, 300
  ja NoMatchWithColsTemp4
  CheckMouseOnCol1:
   cmp cx, 48
  ja CheckMouseOnCol2
   mov [BmpLeft], 30
   mov si, offset CardCol1
   mov ax, [HCCol1]
   mov [HCCurrentCol], ax
   mov ax, [Col1Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col1Index
   mov [HCCurrentColOffset], offset HCCol1
   mov [CurrentColOffset], offset CardCol1

   jmp ExitFindWhatCol
  CheckMouseOnCol2:
   cmp cx, 72
  jb NoMatchWithColsTemp4
   cmp cx, 90
  ja CheckMouseOnCol3
   mov [BmpLeft], 72
   mov si, offset CardCol2
   mov ax, [HCCol2]
   mov [HCCurrentCol], ax
   mov ax, [Col2Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col2Index
   mov [HCCurrentColOffset], offset HCCol2
   mov [CurrentColOffset], offset CardCol2
   jmp ExitFindWhatCol
NoMatchWithColsTemp4:
 jmp NoMatchWithColsTemp3
  CheckMouseOnCol3:
   cmp cx, 114
  jb NoMatchWithColsTemp3
   cmp cx, 128
  ja CheckMouseOnCol4
   mov [BmpLeft], 114
   mov si, offset CardCol3
   mov ax, [HCCol3]
   mov [HCCurrentCol], ax
   mov ax, [Col3Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col3Index
   mov [HCCurrentColOffset], offset HCCol3
   mov [CurrentColOffset], offset CardCol3
   jmp ExitFindWhatCol
  CheckMouseOnCol4:
   cmp cx, 156
  jb NoMatchWithColsTemp3
   cmp cx, 164
  ja CheckMouseOnCol5
   mov [BmpLeft], 156
   mov si, offset CardCol4
   mov ax, [HCCol4]
   mov [HCCurrentCol], ax
   mov ax, [Col4Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col4Index
   mov [HCCurrentColOffset], offset HCCol4
   mov [CurrentColOffset], offset CardCol4
   jmp ExitFindWhatCol
NoMatchWithColsTemp3:
jmp NoMatchWithColsTemp2
  CheckMouseOnCol5:
   cmp cx, 198
  jb NoMatchWithColsTemp2
   cmp cx, 216
  ja CheckMouseOnCol6
   mov [BmpLeft], 198
   mov si, offset CardCol5
   mov ax, [HCCol5]
   mov [HCCurrentCol], ax
   mov ax, [Col5Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col5Index
   mov [HCCurrentColOffset], offset HCCol5
   mov [CurrentColOffset], offset CardCol5
   jmp ExitFindWhatCol
NoMatchWithColsTemp2:
jmp NoMatchWithCols
  CheckMouseOnCol6:
   cmp cx, 240
  jb NoMatchWithCols
   cmp cx, 258
  ja CheckMouseOnCol7
   mov [BmpLeft], 240
   mov si, offset CardCol6
   mov ax, [HCCol6]
   mov [HCCurrentCol], ax
   mov ax, [Col6Index]
   mov [CurrentColIndex], ax
   mov [CurrentColIndexOffset], offset Col6Index
   mov [HCCurrentColOffset], offset HCCol6
   mov [CurrentColOffset], offset CardCol6
    jmp ExitFindWhatCol
  CheckMouseOnCol7:
   cmp cx, 282
  jb NoMatchWithCols
  mov [BmpLeft], 282
   mov si, offset CardCol7
   mov ax, [HCCol7]
   mov [HCCurrentCol], ax
   mov ax, [Col7Index]
   mov [CurrentColIndex], ax
    mov [CurrentColIndexOffset], offset Col7Index
   mov [HCCurrentColOffset], offset HCCol7
   mov [CurrentColOffset], offset CardCol7
   jmp ExitFindWhatCol
  ExitFindWhatCol:
  mov [SecondColClickX], cx
  mov [SecondColClickY], dx
   call FindColLimits
   cmp dx, [TopYCol]
   jb NoMatchWithCols
   cmp dx, [BotYCol]
   ja NoMatchWithCols
   mov [bool], 1
 NoMatchWithCols: 
 pop bx
 pop ax
 ret
endp FindWhatCol
;--------------------------------------------------------------------------------------------------------
proc ColsClicked
 push ax
 push bx
 push cx
 push di
 push si
  call ResetSelectedCards
  mov ax, [BmpLeft]
  mov [ClickedColLeft], ax
  mov [ClickedColX], cx
  mov [ClickedColY], dx
  HighlightCol:
   call FindColLimits
   mov ax, [BotYCol]
   sub ax, 29
   mov [BmpTop], ax
   call HighlightCard
   mov [SelectedCounter], 1
   mov bx, [CurrentColOffset]
   add bx, [CurrentColIndex]
   dec bx
   mov al, [byte bx]
   mov [CardValue],al
   FindHowMany: 
    cmp dx, [BmpTop]
	jae AddSelectedCards
	sub [BmpTop], 7
    call PartiallyHighlight
	inc [SelectedCounter]
	dec bx
	mov al, [byte bx]
	mov [CardValue], al
   jmp FindHowMany
   AddSelectedCards: 
    mov si, offset SelectedCards
	mov cx, [SelectedCounter]
	LoopAddCards:
	 mov al, [byte  bx]
	 mov [byte si], al
	 inc si
	 inc bx
	loop LoopAddCards
   call WaitForRelease
   push si
  call SoundStatus
  pop si
  WaitFor2ndClick: 
   mov ax, 3
   int 33h
   shr cx, 1
   inc dx
   cmp bx, 00000001b
  jne WaitFor2ndClick
  cmp [SelectedCounter], 1
  ja CheckColsAftCols
  CheckFouAftCols:
   push [BmpLeft]
   push [BmpTop]
   call EligibleToFoundation
   pop [BmpTop]
   pop [BmpLeft]
   cmp [bool], 0
   je CheckColsAftCols  
   jmp AdjustByQuantity   
  CheckColsAftCols:
   push [BmpLeft]
   push [BmpTop]
   call EligibleToColumns
    call FindColLimits
   pop [BmpTop]
   pop [BmpLeft]
   cmp [bool], 0
   je ExitFindColDetails1   
    call FindColLimits
    push [BmpLeft]
    push cx
    push dx
    mov ax, 2
    int 33h
    mov cx, [ClickedColX]
    mov dx, [ClickedColY]
    mov ax, 4
    int 33h
    call FindWhatCol
    mov bl, [bool]
    mov ax, [BmpLeft]
    pop dx
    pop cx
    pop [BmpLeft]
    shl cx, 1
    dec dx
    mov ax, 4
    int 33h
    mov ax, 1
    int 33h
    cmp bl, 0
    je ExitFindColDetails1
    cmp  ax, [ClickedColLeft]
    je ExitFindColDetails1
    jmp AdjustByQuantity
ExitFindColDetails1:
jmp ExitFindColumnClickDetails
   AdjustByQuantity:
    DeleteCardsFromCol:
	call FindColLimits
	 mov bx, [CurrentColOffset]
	 add bx, [CurrentColIndex]
	 mov cx, [SelectedCounter] 
	 LoopDeleteCards: 
	  call FindColLimits
	  mov ax, [BotYCol]
	  sub ax, 29
	  mov [BmpTop], ax
	  dec [BmpTop]
	  call DeleteCard
	  dec bx 
	  mov [byte bx], 0
	  dec [CurrentColIndex]
	  mov si, [CurrentColIndexOffset]
	  dec [byte si]
	 loop LoopDeleteCards
	 call FindColLimits
   mov bx, [CurrentColIndex]
   cmp bx, 0
   je ExitFindColDetails1
   cmp bx, [HCCurrentCol]
   je RevealHiddenCard
   jmp ReprintLastCard
   ReprintLastCard:
    sub [BmpTop], 6
    add bx, [CurrentColOffset]
	dec bx
	mov al, [byte bx]
	mov [CardValue], al
	call CardByValue
    jmp CheckToAddCards
   RevealHiddenCard:
    sub [BmpTop], 3
    mov bx, [CurrentColOffset]
	add bx, [HCCurrentCol]
	dec bx
	mov al, [byte bx]
	mov [CardValue], al
	call CardByValue
	dec [HCCurrentCol]
	mov bx, [HCCurrentColOffset]
	dec [byte bx]
	CheckToAddCards:
	cmp [SelectedCounter], 1
	je ExitFindColumnClickDetails1
	jmp AddCardsToCol
ExitFindColumnClickDetails1:
 jmp ExitFindColumnClickDetails
  AddCardsToCol:
   mov ax, 3
   int 33h
   shr cx, 1
   inc dx
   call FindWhatCol
   mov bx, [CurrentColOffset]
   add bx, [CurrentColIndex]
   mov di, offset SelectedCards
   inc di
   mov cx, [SelectedCounter]
   dec cx
   mov ax, 2
   int 33h
   LoopAddToCol:
    call FindColLimits
	mov ax, [BotYCol]
	sub ax, 22
	mov [BmpTop], ax
	mov al, [byte di]
	mov [byte bx], al
	mov [CardValue], al
	push di
	call CardByValue
	pop di
	inc bx
	inc di
	inc [CurrentColIndex]
	mov si, [CurrentColIndexOffset]
	inc [byte si]
	dec cx
   cmp cx, 0
   jne LoopAddToCol
   mov ax, 1
   int 33h 
 ExitFindColumnClickDetails:
 call UnhighlightScreen
 call WaitForRelease
 call IncreaseClickCount
 pop si
 pop di
 pop cx
 pop bx
 pop ax
 ret
endp ColsClicked 
;---------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------
proc GetSelectCount
push ax
push bx
push cx
 mov cx, 13
 mov ax, 0
 LoopGetCount:
  mov bx, offset SelectedCards
  add bx, cx
  dec bx
  cmp [byte bx], 0
  je LoopGetCountAgain
  inc ax
 LoopGetCountAgain:
 loop LoopGetCount
 mov [SelectedCounter], ax
pop cx
pop bx
pop ax
ret
endp GetSelectCount
  
;--------------------------------------------------------------------------------------------------------
proc FindColLimits
 push cx
  mov [TopYCol],65 
  cmp [HCCurrentCol], 0
  je SkipHCAdjust
  mov cx, [HCCurrentCol]
  AdjustTopY:
   add [TopYCol], 4
  loop AdjustTopY
  SkipHCAdjust:
   mov cx, [TopYCol]
   mov [BotYCol], cx
   mov cx, [CurrentColIndex]
   sub cx, [HCCurrentCol]
   cmp cx, 1
   jbe ExitFindColLimits
   AdjustBotY:
    add [BotYCol],7
   loop AdjustBotY
   sub [BotYCol], 7
   ExitFindColLimits:
   add [BotYCol], 29
 pop cx
 ret
endp 
;-----------------------------------------------------------------------------------------------------
proc RetrieveLatestHandCard
 push ax
 push bx
  mov [BmpTop], 25
  mov [BmpLeft], 60
  call DeleteCard
  mov bx, offset hand
  add bx, [handIndex]
  dec bx
  mov [byte bx], 0
  loopFindLatest:
   dec bx
   dec [handIndex]
   cmp bx, offset hand
   jb ExitRetrieveLatestHandCard
   cmp [byte bx], 0
   je loopFindLatest
   mov al, [byte bx]
   mov [CardValue], al
   call CardByValue
 ExitRetrieveLatestHandCard:
  pop bx
  pop ax
  ret
endp RetrieveLatestHandCard
;-----------------------------------------------------------------------------------------------------
proc IfMatching; checks if 2 cards are in alternating in colors and have consecutive numbers
 push bx
  cmp [CurrentColIndex], 0
  jne CheckAlternate
  CheckIfKing:
   cmp [CardValue], 13
   je Matching
   cmp [CardValue], 26
   je Matching
   cmp [CardValue], 39
   je Matching
   cmp [CardValue], 52
   je Matching
  jmp NotMatching
  CheckAlternate:
   cmp [CardValue], 26
   ja CheckIfRed
   CheckIfBlue:
    cmp bl, 26
	jb NotMatching
   jmp AlternateColors
   CheckIfRed:
    cmp bl, 26
	ja NotMatching
   jmp AlternateColors
   AlternateColors:
   sub bl, [CardValue]
   cmp bl, 14
   je Matching
   cmp bl, 27
   je Matching
   cmp bl, 40
   je Matching
   cmp bl,0F4h
   je Matching
   cmp bl, 0E7h
   je Matching
   cmp bl, 0DAh
   je Matching
   jmp NotMatching
   Matching:
    mov [bool], 1
   jmp ExitIFMatching
   NotMatching:
   mov [bool], 0
 ExitIFMatching:
 pop bx
 ret
endp IfMatching
;-----------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------
proc WaitForClick
push ax
 LoopWaitForClick:
  mov ax, 3
  int 33h
  shr cx, 1
  inc dx
  cmp bx, 00000001b
  jne LoopWaitForClick
 call IncreaseClickCount
 pop ax
 ret
endp WaitForClick
;-------------------------------------------------------------------------------------
proc WaitForRelease
push ax
 LoopWaitForRelease:
  mov ax, 3
  int 33h
  shr cx, 1
  inc dx
  cmp bx, 00000000b
 jne LoopWaitForRelease
 pop ax
ret
endp WaitForRelease
	
  
;-----------------------------------------------------------------------------------------------------
proc HighlightCard
 push bx
  mov ax, 2
  int 33h
  mov [color],47h
  mov bx, [BmpLeft]
  mov [ColPos], bx
  mov bx, [BmpTop]
  mov [RowPos], bx
  inc [RowPos]
  mov [RowLength], card_col_size
  call PHL
  mov [ColLength], 28
  call PVL
  add [RowPos], 28
  call PHL
  sub [RowPos], 28
  add [ColPos], 17
  call PVL
  mov ax, 1
  int 33h
 pop bx
 ret
endp HighlightCard
;-------------------------------------------
proc UnhighlightCard
 push bx
  mov [color],0A4h
  mov bx, [BmpLeft]
  mov [ColPos], bx
  mov bx, [BmpTop]
  mov [RowPos], bx
  inc [RowPos]
  mov [RowLength], card_col_size
  call PHL
  mov [ColLength], 28
  call PVL
  add [RowPos], 28
  call PHL
  sub [RowPos], 28
  add [ColPos], 17
  call PVL
 pop bx
 ret
endp UnhighlightCard
;--------------------------------------------
proc PartiallyHighlight
 push bx
  mov ax, 2
  int 33h
  mov [color], 47h
  mov bx, [BmpLeft]
  mov [ColPos], bx
  mov bx, [BmpTop]
  mov [RowPos], bx
  inc [RowPos]
  mov [RowLength], card_col_size
  call PHL
  mov [ColLength], card_row_size
  call PVL
  add [ColPos], 17
  call PVL
  mov ax, 1
  int 33h
 pop bx
 ret
endp PartiallyHighlight
;-----------------------------------------------------------------------------------------------------
proc UnhighlightScreen
    push bx 
    push cx 
    push dx
    push ax
	mov ax, 2
	int 33h
	mov [color], 0A4h
    mov [x],320
    UnhighlightX:
     mov [y],200
     UnhighlightY:
     mov cx, [x]
	 mov dx, [y]
	 mov bx, 0
	 mov ah, 0dh
	 int 10h
	 cmp al, 47h
	 jne CheckNextPixel
	 mov ah, 0ch
	 mov al, [color]
	 int 10h
	CheckNextPixel:
	  dec [y]
      cmp [y],0
      jne UnhighlightY
      dec [x]
      cmp [x],0
     jne UnhighlightX
    mov ax, 1
	int 33h
    pop ax
    pop dx
    pop cx
    pop bx
    ret 
 endp UnhighlightScreen

;-----------------------------------------------------------------------------------------------------
proc ClickSound
 push ax
  in al, 61h
  or al, 00000011b
  out 61h, al
  mov al, 0B6h
  out 43h, al
  mov ax, 4000
  out 42h, al ; Sending lower byte
  mov al, ah
  out 42h, al ; Sending upper byte
  call Delay
  call Delay
  call Delay
  mov ax, 3500
  out 42h, al ; Sending lower byte
  mov al, ah
  out 42h, al
  call Delay
  call Delay
  call Delay
  ;close the speaker
  in al, 61h
  and al, 11111100b
  out 61h, al
 pop ax
 ret
endp ClickSound
;--------------------------------------------
proc ClickSound2
 push ax
  in al, 61h
  or al, 00000011b
  out 61h, al
  mov al, 0B6h
  out 43h, al
  mov ax, 3000
  out 42h, al ; Sending lower byte
  mov al, ah
  out 42h, al ; Sending upper byte
  call Delay
  call Delay
  call Delay
  mov ax, 2500
  out 42h, al ; Sending lower byte
  mov al, ah
  out 42h, al
  call Delay
  call Delay
  call Delay
  ;close the speaker
  in al, 61h
  and al, 11111100b
  out 61h, al
 pop ax
 ret
endp ClickSound2
proc OSClicks 
  WaitForReleaseInOS:
  call WaitForRelease
  WaitInOS:
   call WaitForClick
   mov [color], 47h
  CheckSoundButton:
   cmp cx, 20
   ja CheckBox1
   cmp dx, 20
   ja CheckBox1
    mov [BmpTop], 0
	mov [BmpLeft], 0
	mov [BmpRowSize], 20
	mov [BmpColSize] , 20
	mov ax, 2
	int 33h
	call SwitchSoundStatus
   call SoundStatus
   cmp [sound], 1
   je ShowSoundOnBmp
   ShowSoundOffBmp:
    mov dx, offset soundOff
	call OpenShowBmp
	mov ax, 1
	int 33h
	jmp WaitForReleaseInOS
	ShowSoundOnBmp:
	 mov dx, offset soundOn
	call OpenShowBmp
	mov ax, 1
	int 33h
	jmp WaitForReleaseInOS
  CheckBox1:
	cmp cx, [Box1RX]
	ja CheckBox2
	cmp cx, [Box1LX]
	jb CheckBox2
	cmp dx, [Box1TopY]
	jb CheckBox2
	cmp dx, [Box1BotY]
	ja CheckBox2
	jmp Box1Clicked
WaitInOS1:
 jmp WaitForReleaseInOS
	Box1Clicked:
	mov ax, 2
	int 33h
	mov [RowLength], 101
	mov [RowPos], 64
	mov [ColPos], 110
	call PHL
	INC [RowPos]
	call PHL
	mov [ColLength], 23
	call PVL
	inc [ColPos]
	call PVL
	add [ColPos], 99
	call PVL
	dec [ColPos]
	call PVL
	sub [ColPos], 99
	add [RowPos], 21
	call PHL
	inc [RowPos]
	call PHL
	mov [bool], 0
	jmp ExitOSClicks
  CheckBox2:
   cmp cx, [Box2RX]
	ja WaitInOS1
	cmp cx, [Box2LX]
	jb WaitInOS1
	cmp dx, [Box2TopY]
	jb WaitInOS1
	cmp dx, [Box2BotY]
	ja WaitInOS1
   mov ax, 2
   int 33h
   mov [RowPos], 107
   mov [ColPos], 111
   mov [RowLength], 93
   call PHL
   INC [RowPos]
   call PHL
   mov [ColLength], 23
   call PVL
   inc [ColPos]
   call PVL
   add [ColPos], 91
   call PVL
   inc [ColPos]
   call PVL
   sub [ColPos], 93
   add [RowPos], 22
   call PHL
   dec [RowPos]
   call PHL
   mov [bool], 1
 ExitOSClicks:
  mov ax, 1
  int 33h
  call WaitForRelease
  cmp [sound], 1
  jne DontPlaySound
  call ClickSound2    
  DontPlaySound:
 ret 
endp OSClicks
;-------------------------------------------------------------------------------------------------------
proc ResetSelectedCards
 push si
 push cx
 mov cx, 12
 LoopResetSelected:
   mov si, offset SelectedCards
   add si, cx
   mov [byte si], 0
 loop LoopResetSelected
 pop cx
 pop si
ret
endp ResetSelectedCards
;-------------------------------------------------------------------------------------------------------
proc SetCursor
 push ax
 mov ax, 0h
 int 33h
 mov ax, 1h
 int 33h
 pop ax
 ret
endp SetCursor
;------------------------------------------------------------------------------------------------------- 
proc PHL ; prints a horizontal line with custom length, color and position
 push ax
 push bx
 push cx
 push dx
 push [RowLength]
 push [ColPos]
 mov al, [color]
 mov bl, 0
 mov cx, [ColPos]
 mov dx, [RowPos]
 mov ah, 0ch
 LoopPrintPixel:
  cmp [RowLength], 0
  je ExitPHL
  int 10h
  inc cx
  dec [RowLength]
  jmp LoopPrintPixel
 ExitPHL:
 pop [ColPos]
 pop [RowLength]
 pop dx
 pop cx
 pop bx
 pop ax
 ret  
endp PHL

  proc PVL
  push ax
  push bx
  push cx
  push dx
  push [ColLength]
  mov cx, [ColPos]
  mov dx, [RowPos]
  mov ah, 0ch
  mov al , [color]
  PrintPixelPVL:
  cmp [ColLength],0
  je ExitPVL
  int 10h
  inc dx
  dec [ColLength]
  jmp PrintPixelPVL
  ExitPVL:
  pop [ColLength]
  pop ax
  pop bx
  pop cx
  pop dx
  ret 
  endp PVL

 proc DeleteScreen
    push bx 
    push cx 
    push dx
    push ax
    call SetGraphic
    mov [color],0
    mov [x],319
    xDelete:
        mov [y],199
        yDelete:
            mov bh,0h
            mov cx,[x]
            mov dx,[y]
            mov al,[color]
            mov ah,0ch
            int 10h
            dec [y] 
            cmp [y],0
            jne yDelete
        dec [x]
        cmp [x],0
        jne xDelete
    pop ax
    pop dx
    pop cx
    pop bx
    ret 
 endp DeleteScreen
;-----------------------------------------------------------------------------------------------------
proc PrintBackGround
    push bx 
    push cx 
    push dx
    push ax
    call SetGraphic
	mov [color], 31h
    mov [x],320
    xPrint:
        mov [y],200
        yPrint:
            mov bh,0h
            mov cx,[x]
            mov dx,[y]
            mov al,[color]
            mov ah,0ch
            int 10h
            dec [y] 
            cmp [y],0
            jne yDelete
        dec [x]
        cmp [x],0
        jne xPrint
		call Delay
		call Delay
		call Delay
		call Delay
    pop ax
    pop dx
    pop cx
    pop bx
    ret 
 endp PrintBackGround
;----------------------------------------------------------------------------------------------
proc PrintOS
 mov [BmpTop], 0
 mov [BmpLeft], 0
 mov [BmpColSize], 320
 mov [BmpRowSize], 200
 mov dx, offset OpeningScreen
 call OpenShowBmp
 mov [BmpColSize], 20
 mov [BmpRowSize],  20
 cmp [sound], 0
 jne PrintSoundOn
 mov dx, offset soundoff
 jmp ExitPrintOS
 PrintSoundOn:
 mov dx, offset soundOn
 ExitPrintOS:
  call OpenShowBmp
ret
endp PrintOS
;----------------------------------------------------------------------------------------------
proc InitializeClickCount
 push ax
 push bx
 push dx
 mov dh, 0
 mov dl, 30
 mov bx, 0
 mov ah, 2
 int 10h
 mov bx, offset ClickCountString
 mov [byte bx+9], '0'
 mov [byte bx+8], '0'
 mov [byte bx+7], '0'
 mov dx, offset ClickCountString
 mov ah, 9
 int 21h
 mov [ClickCounter], 0 
pop dx
pop bx
pop ax
ret
endp InitializeClickCount
;----------------------------------------------------------------------------------------------
proc IncreaseClickCount
 push ax
 push bx
 push dx
  mov dh, 0
  mov dl, 30
  mov bx, 0
  mov ah, 2
  int 10h
  inc [ClickCounter]
  mov bx, offset ClickCountString
  inc [byte bx+9]
  cmp [byte bx+9], '9'
  jbe ExitIncClickCount
  IncClickTens:
   mov [byte bx+9], '0'
   inc [byte bx+8]
   cmp [byte bx+8], '9'
   jbe ExitIncClickCount
 IncClickHuns:
  mov [byte bx+8], '0'
  inc [byte bx+7]
 ExitIncClickCount:
  mov dx, offset ClickCountString
  mov ah, 9
  int 21h
 pop dx 
 pop bx
 pop ax
ret
endp IncreaseClickCount
;----------------------------------------------------------------------------------------------
proc SoundStatus
 cmp [sound], 0
 je ExitSoundStatus
 call ClickSound
ExitSoundStatus:
 ret
endp SoundStatus
;----------------------------------------------------------------------------------------------
proc SwitchSoundStatus
 cmp [sound], 1
 je TurnOffSound
 TurnOnSound:
 mov [sound], 1
 jmp ExitSwitchSoundStatus
 TurnOffSound:
  mov [sound],0
ExitSwitchSoundStatus:
ret
endp SwitchSoundStatus
;----------------------------------------------------------------------------------------------

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