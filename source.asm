INCLUDE Irvine32.inc
INCLUDE Macros.inc

; -=-==-=-=-=-=-=-=-=-=- WINAPI AND CONSTS -=-==-=-=-=-=-=-=-=-=-
INCLUDELIB winmm.lib                 ; need this library for sound
mciSendStringA PROTO,                ; func to play audio
    lpstrCommand:PTR BYTE,
    lpstrReturnString:PTR BYTE,
    uReturnLength:DWORD,
    hwndCallback:DWORD

GetAsyncKeyState PROTO, vKey:DWORD

; constants for file stuff
GENERIC_WRITE    EQU 40000000h
OPEN_ALWAYS      EQU 4
FILE_END         EQU 2
FILE_ATTRIBUTE_NORMAL EQU 80h

; keys for moving
VK_LEFT       EQU 25h
VK_UP         EQU 26h
VK_RIGHT      EQU 27h
VK_DOWN       EQU 28h
VK_SPACE      EQU 20h
VK_ESCAPE     EQU 1Bh
VK_P          EQU 50h ; pause game
VK_A          EQU 41h   
VK_D          EQU 44h 
VK_S          EQU 53h ; key for secret room
VK_Z          EQU 5Ah ; moon jump

; settings for map
ROW_SIZE      = 120
COL_SIZE      = 30
BLOCK_CHAR    = "#"
COIN_CHAR     = "O"
SPIKE_CHAR    = "x"
LAVA_CHAR     = "v"    ; lava block
FLAG_CHAR     = "F"
CONTINUE_CHAR = "U"   
SPACE_BAR     = 32
ESCAPE        = 27
CLOUD_CHAR    = "C"
BUSH_CHAR     = "B"
MYSTERY_CHAR  = "0" 
GOOMBA_BLOCK_CHAR = "9" 
PIPE_CHAR     = "P"          
POLE_CHAR     = "|"
FLAG_TOP_CHAR = ">"

; secret room chars
SECRET_ENTRY_CHAR = "5" 
SECRET_FLOOR_CHAR = "g" 
SECRET_EXIT_CHAR  = "L" 
SECRET_SKY_CHAR   = "W" 

; speed racer item
TURBO_STAR_CHAR   = "*" 

; bad guys
GOOMBA_CHAR   = "G"
KOOPA_CHAR    = "K"
SHELL_CHAR    = "S"
MUSHROOM_CHAR = "M" 
BOSS_CHAR     = "N"   ; boss char

PLAYER_SPEED EQU 4 

.data
    ; menu strings
    strRollNo    BYTE "Roll No: 24i0753",0
    
    ; logo art part one
    logo1  db " @@@   @  @  @@@@  @@@@  @@@@ ", 0
    logo2  db "@      @  @  @  @  @     @  @ ", 0
    logo3  db " @@@   @  @  @@@@  @@@   @@@@ ", 0
    logo4  db "    @  @  @  @     @     @ @  ", 0
    logo5  db "@@@@    @@   @     @@@@  @  @ ", 0

    ; logo art part two
    logo6  db "@   @   @@@   @@@@  @@@   @@@      @@@@  @@@@   @@@   @@@@ ", 0
    logo7  db "@@ @@  @   @  @  @   @   @   @     @  @  @  @  @   @  @    ", 0
    logo8  db "@ @ @  @@@@@  @@@@   @   @   @     @@@@  @@@@  @   @   @@@ ", 0
    logo9  db "@   @  @   @  @ @    @   @   @     @  @  @ @   @   @      @ ", 0
    logo10 db "@   @  @   @  @  @  @@@   @@@      @@@@  @  @   @@@   @@@@ ", 0

    ; vars for game state
    score         DWORD 0
    coins         DWORD 0
    world         BYTE "1-1",0
    time          DWORD 400
    lives         BYTE 3
    frameCounter DWORD 0 
    
    ; status flags 0 play 1 dead etc
    gameStatus    BYTE 0  
    
    ; size of mario
    marioState    BYTE 0 

    ; turbo stuff
    isTurboMode   BYTE 0        ; 0 slow 1 fast
    turboTimer    DWORD 0       ; how long turbo lasts

    ; moon jump vars
    isMoonJumpActive BYTE 0       ; gravity check
    moonJumpUsed     BYTE 0       ; did we use it
    moonJumpTimer    DWORD 0      ; timer for jump
    
    ; bg color var
    bgLevelColor  BYTE 9        ; defult blue

    ; secret room stuff
    inSecretRoom      BYTE 0
    secretRoomVisited BYTE 0
    savedMarioX       BYTE 0
    savedMarioY       BYTE 0
    savedFilename     BYTE 40 DUP(0)
    strSecretRoom     BYTE "secretroom.txt",0
    
    ; save map data
    savedMapArray     BYTE 3600 DUP(?)
    savedEnemyCount   DWORD 0
    savedEX           BYTE 10 DUP(0) 
    savedEY           BYTE 10 DUP(0)
    savedEType        BYTE 10 DUP(0)
    savedEDir         BYTE 10 DUP(0)
    savedEActive      BYTE 10 DUP(0)

    ; jump physics
    isJumping      BYTE 0        
    jumpCounter    DWORD 0        
    JUMP_HEIGHT    DWORD 6        

    ; levels
    currentLevel BYTE 1
    strLevel1    BYTE "level1.txt",0
    strLevel1Part2 BYTE "level1part2.txt",0 
    strLevel2    BYTE "level2.txt",0

    ; file handling
    filename      BYTE 40 DUP(0)
    fileHandle    HANDLE ?
    fileBuffer    BYTE 5000 DUP(?)
    
    ; map buffer
    mapArray      BYTE 3600 DUP(" ")
    
    ; player pos
    marioX        BYTE 5
    marioY        BYTE 20
    oldX          BYTE 5
    oldY          BYTE 20
    
    inputChar     BYTE ?

;    -=-==-=-=-=-=-=-=-=-=- ENEMY DATA -=-==-=-=-=-=-=-=-=-=-
    MAX_ENEMIES     = 10
    enemyCount      DWORD 0
    enemyTimer      DWORD 0          
    
    ; arrays for bad guys
    eX              BYTE MAX_ENEMIES DUP(0)
    eY              BYTE MAX_ENEMIES DUP(0)
    eType           BYTE MAX_ENEMIES DUP(0) 
    eDir            BYTE MAX_ENEMIES DUP(0) 
    eActive         BYTE MAX_ENEMIES DUP(0) 
    eHealth         BYTE MAX_ENEMIES DUP(0) ; hp for boss

;    -=-==-=-=-=-=-=-=-=-=- HIGH SCORE DATA -=-==-=-=-=-=-=-=-=-=-
    strGameRecordFilename BYTE "game_record.txt",0
    playerName            BYTE 21 DUP(0)       ; name goes here
    scoreStr              BYTE 16 DUP(0)       ; score text
    levelStr              BYTE 8 DUP(0)        ; level text
    finalRecordLine       BYTE 100 DUP(0)      ; line to write
    bytesWritten          DWORD ?
    strEnterName          BYTE "Enter your name: ",0
    strSaving             BYTE "Saving score to game_record.txt...",0
    strSeparator          BYTE " - Score: ",0
    strLevelSep           BYTE " - Level: ",0  
    strNewLine            BYTE 0Dh, 0Ah, 0     ; next line

;    -=-==-=-=-=-=-=-=-=-=- AUDIO COMMANDS -=-==-=-=-=-=-=-=-=-=-
    ; strings for mci commands
    cmdOpenTheme   BYTE "open theme.mp3 type mpegvideo alias myTheme",0
    cmdPlayTheme   BYTE "play myTheme repeat",0
    cmdStopTheme   BYTE "stop myTheme",0
    cmdCloseTheme  BYTE "close myTheme",0
    
    ; sound effects
    cmdPlayJump    BYTE "play jump.wav from 0",0
    cmdPlayCoin    BYTE "play coin.mp3 from 0",0
    cmdPlayFall    BYTE "play falling.mp3 from 0",0
    cmdPlayGameOver BYTE "play gameover.mp3 from 0",0
    cmdPlayFlagpole BYTE "play flagpole.mp3 from 0",0

.code
main PROC
 ;   -=-==-=-=-=-=-=-=-=-=- MAIN MENU LOOP -=-==-=-=-=-=-=-=-=-=-
    MenuLoop:
        mov eax, yellow + (black * 16)
        call SetTextColor
        call Clrscr
        
        call ShowMainMenu
        call ReadChar
        
        cmp al, "1"
        je ResetAndStartGame
        cmp al, "2"
        je DoInstructions
        cmp al, "3"
        je DoHighScore
        cmp al, "4"
        je ExitProgram
        jmp MenuLoop

    DoInstructions:
        call ShowInstructions
        jmp MenuLoop

    DoHighScore:
        call ShowHighScore
        jmp MenuLoop

  ;  -=-==-=-=-=-=-=-=-=-=- GAME INIT -=-==-=-=-=-=-=-=-=-=-
    ResetAndStartGame:
        ; clear vars
        mov score, 0
        mov coins, 0
        mov lives, 3
        mov currentLevel, 1
        mov marioState, 0
        mov secretRoomVisited, 0 
        mov inSecretRoom, 0
        
        INVOKE Str_copy, ADDR strLevel1, ADDR filename
        
        ; audio setup
        INVOKE mciSendStringA, ADDR cmdCloseTheme, 0, 0, 0
        INVOKE mciSendStringA, ADDR cmdOpenTheme, 0, 0, 0
        
        ; wait for load
        mov eax, 50
        call Delay
        
    InitGame:
        ; level reset
        mov time, 400
        mov frameCounter, 0
        mov gameStatus, 0 
        mov isJumping, 0         
        mov jumpCounter, 0
        mov isTurboMode, 0    
        mov turboTimer, 0
        
        ; reset moon jump
        mov isMoonJumpActive, 0
        mov moonJumpTimer, 0
        
        ; chek if loading part two
        INVOKE Str_compare, ADDR filename, ADDR strLevel1Part2
        je SkipMoonReset
        
        mov moonJumpUsed, 0    ; new game reset
        
    SkipMoonReset:
        
        cmp currentLevel, 1
        je SetW1
        mov world[0], "1"
        mov world[2], "2"
        ; level 2 is black
        mov bgLevelColor, 0 
        jmp FinishWSet
    SetW1:
        mov world[0], "1"
        mov world[2], "1"
        ; level 1 is blue
        mov bgLevelColor, 9 
    FinishWSet:

        mov enemyCount, 0
        call LoadMapFromFile
        
    LevelStart:
        mov eax, white + (lightblue * 16)
        call SetTextColor
        call Clrscr
        
        call DrawMap
        
        ; start music
        INVOKE mciSendStringA, ADDR cmdPlayTheme, 0, 0, 0
        
        mov bl, marioX
        mov oldX, bl
        mov bl, marioY
        mov oldY, bl
        
;        -=-==-=-=-=-=-=-=-=-=- GAME LOOP -=-==-=-=-=-=-=-=-=-=-
        GameLoop:
            call EraseMario

            cmp gameStatus, 1
            je DeathSequence
            cmp gameStatus, 2
            je WinGame
            cmp gameStatus, 3
            je MenuLoop
            cmp gameStatus, 4
            je NextLevelSequence
            cmp gameStatus, 5   
            je LevelPart2Sequence

            ; timer stuff
            inc frameCounter
            cmp frameCounter, 20
            jl SkipTimerDec
            dec time
            mov frameCounter, 0
            cmp time, 0
            jle TimeUpSequence    
            SkipTimerDec:

            ; moon jump timer
            cmp isMoonJumpActive, 1
            jne SkipMoonLogic
            
            dec moonJumpTimer
            cmp moonJumpTimer, 0
            jg SkipMoonLogic
            mov isMoonJumpActive, 0 ; timer done
            SkipMoonLogic:

            ; logic calls
            call HandleInput       
            call UpdatePhysics     

            ; check level load trigger
            cmp gameStatus, 5
            je LevelPart2Sequence
            
            ; death boundary check
            cmp marioY, 30
            jge SetDeathStatus

            ; enemies logic
            call UpdateEnemies
            cmp gameStatus, 1
            je DeathSequence
            cmp gameStatus, 2   ; win check
            je WinGame

            RenderFrame:
                call UpdateHUD
                call DrawMario
                
                ; speed logic
                cmp isTurboMode, 1
                je TurboSpeed
                
                ; normal speed
                mov eax, 40 
                jmp DoDelay
                
            TurboSpeed:
                ; go fast
                mov eax, 20 
                dec turboTimer
                cmp turboTimer, 0
                jg DoDelay
                mov isTurboMode, 0 ; done
                
            DoDelay:
                call Delay
                
                mov bl, marioX
                mov oldX, bl
                mov bl, marioY
                mov oldY, bl
                
            jmp GameLoop

            SetDeathStatus:
                mov gameStatus, 1
                jmp GameLoop

;    -=-==-=-=-=-=-=-=-=-=- END SEQUENCES -=-==-=-=-=-=-=-=-=-=-
    
    TimeUpSequence:
        mov eax, white + (red * 16)
        call SetTextColor
        call Clrscr
        mov dh, 12
        mov dl, 52
        call Gotoxy
        mWrite "T I M E   U P !"
        
        ; stop music
        INVOKE mciSendStringA, ADDR cmdStopTheme, 0, 0, 0
        INVOKE mciSendStringA, ADDR cmdPlayFall, 0, 0, 0
        
        mov eax, 2000
        call Delay
        dec lives
        cmp lives, 0
        je GameOver
        mov marioState, 0     
        mov gameStatus, 0
        mov time, 400
        mov marioX, 5
        mov marioY, 20
        mov isJumping, 0
        mov inSecretRoom, 0 
        mov isMoonJumpActive, 0
        jmp LevelStart

    LevelPart2Sequence:
        INVOKE Str_copy, ADDR strLevel1Part2, ADDR filename
        mov eax, white + (black * 16)
        call SetTextColor
        call Clrscr
        mov dh, 12
        mov dl, 35
        call Gotoxy
        mWrite "LOADING NEXT AREA..."
        mov eax, 1000
        call Delay
        jmp InitGame 

    NextLevelSequence:
        ; calc bonus
        mov eax, white + (black * 16)
        call SetTextColor
        call Clrscr
        mov dh, 10
        mov dl, 35
        call Gotoxy
        mWrite "LEVEL COMPLETED!"
        
        call CalculateTimeBonus 
        
        inc currentLevel
        INVOKE Str_copy, ADDR strLevel2, ADDR filename
        jmp InitGame 

DeathSequence:
    ; stop theme play fall
    INVOKE mciSendStringA, ADDR cmdStopTheme, 0, 0, 0
    INVOKE mciSendStringA, ADDR cmdPlayFall, 0, 0, 0
    
    FallAnimLoop:
        cmp marioY, 30      
        jge DoneFallAnim
        call EraseMario     
        inc marioY            
        mov dl, marioX
        mov dh, marioY
        call Gotoxy
        mov eax, white + (red * 16) 
        call SetTextColor
        mov al, "M"
        call WriteChar
        mov eax, 60            
        call Delay
        jmp FallAnimLoop    
        
    DoneFallAnim:
        mov gameStatus, 0   
        mov marioState, 0         
        dec lives
        cmp lives, 0
        je GameOver
        
        mov eax, white + (red * 16)
        call SetTextColor
        call Clrscr
        mov dh, 12
        mov dl, 40
        call Gotoxy
        mWrite "LIFE LOST!"
        mov eax, 1000
        call Delay
        
        mov marioX, 5
        mov marioY, 20
        mov time, 400
        mov isJumping, 0
        mov inSecretRoom, 0 
        mov isMoonJumpActive, 0
        jmp LevelStart

 ;   -=-==-=-=-=-=-=-=-=-=- GAME OVER -=-==-=-=-=-=-=-=-=-=-
    GameOver:
        ; music logic
        INVOKE mciSendStringA, ADDR cmdStopTheme, 0, 0, 0
        INVOKE mciSendStringA, ADDR cmdPlayGameOver, 0, 0, 0
        
        mov eax, white + (red * 16)
        call SetTextColor
        call Clrscr
        
        mov dh, 8
        mov dl, 30
        call Gotoxy
        mWrite " G A M E   O V E R "
        
        mov dh, 10
        mov dl, 30
        call Gotoxy
        mWrite " Final Score: "
        mov eax, score
        call WriteDec
        
        ; save scores
        call InputAndSaveScore

        mov eax, white + (red * 16) ; reset color
        call SetTextColor
        mov dh, 15
        mov dl, 30
        call Gotoxy
        mWrite " (R)etry or (M)enu "
        
        GDLoop:
            call ReadChar
            cmp al, "r"
            je ResetAndStartGame
            cmp al, "m"
            je MenuLoop
            jmp GDLoop

    WinGame:
        mov eax, white + (green * 16)
        call SetTextColor
        call Clrscr
        
        mov dh, 10
        mov dl, 30
        call Gotoxy
        mWrite " Y O U   W I N ! ! "
        
        call CalculateTimeBonus 
        
        mov dh, 14
        mov dl, 30
        call Gotoxy
        mWrite " Final Score: "
        mov eax, score
        call WriteDec
        
        ; save the score
        call InputAndSaveScore
        
        mov eax, white + (green * 16)
        call SetTextColor
        mov dh, 18
        mov dl, 30
        mWrite " (R)etry or (M)enu "
        WGLoop:
            call ReadChar
            cmp al, "r"
            je ResetAndStartGame
            cmp al, "m"
            je MenuLoop
            jmp WGLoop

    ExitProgram:
    exit
main ENDP

;-=-==-=-=-=-=-=-=-=-=- -= INPUT AND SAVE SCORE -=-==-=-=-=-=-=-=-=-=-
InputAndSaveScore PROC
    ; set input color
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET strEnterName
    call WriteString

    ; empty buffer loop
    FlushBufferLoop:
        mov eax, 10      ; small wait
        call Delay
        call ReadKey     ; get any key pressed
        jz BufferEmpty   ; if zero flag then empty
        jmp FlushBufferLoop ; repeat
    BufferEmpty:

    ; get name max 20
    mov edx, OFFSET playerName
    mov ecx, 20
    call ReadString

    ; tell user saving
    mov dh, 13
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET strSaving
    call WriteString
    mov eax, 1000
    call Delay

    ; do file stuff
    call AppendToFile
    ret
InputAndSaveScore ENDP

; -=-==-=-=-=-=-=-=-=-=- -= APPEND TO FILE -=-==-=-=-=-=-=-=-=-=-
AppendToFile PROC
    ; convert score
    mov eax, score
    
    ; int to str conversion
    mov ecx, 10     ; divide by 10
    mov edi, OFFSET scoreStr
    add edi, 15     ; end of buffer
    mov byte ptr [edi], 0 ; null term
    dec edi
    
    cmp eax, 0
    jne ConvertLoop
    mov byte ptr [edi], '0'
    dec edi
    jmp DoneConvert
    
    ConvertLoop:
        xor edx, edx
        div ecx
        add dl, '0'
        mov [edi], dl
        dec edi
        test eax, eax
        jnz ConvertLoop
    DoneConvert:
        inc edi     ; fix ptr
        push edi    ; save score ptr
    
    ; convert level
    movzx eax, currentLevel
    mov ecx, 10
    mov edi, OFFSET levelStr
    add edi, 7      
    mov byte ptr [edi], 0
    dec edi
    
    cmp eax, 0
    jne ConvertLevelLoop
    mov byte ptr [edi], '0'
    dec edi
    jmp DoneLevelConvert
    
    ConvertLevelLoop:
        xor edx, edx
        div ecx
        add dl, '0'
        mov [edi], dl
        dec edi
        test eax, eax
        jnz ConvertLevelLoop
    DoneLevelConvert:
        inc edi     ; fix ptr
        mov ebx, edi ; save level ptr
        
    ; build line
    INVOKE Str_copy, ADDR playerName, ADDR finalRecordLine
    INVOKE Str_length, ADDR finalRecordLine
    mov edi, OFFSET finalRecordLine
    add edi, eax    ; go to end
    
    ; append seperator
    mov esi, OFFSET strSeparator
    call AppendStringHelper

    ; append score
    pop esi          ; get score ptr back
    call AppendStringHelper

    ; append lvl sep
    mov esi, OFFSET strLevelSep
    call AppendStringHelper

    ; append level
    mov esi, ebx    ; get level ptr back
    call AppendStringHelper

    ; new line
    mov al, 0Dh
    mov [edi], al
    inc edi
    mov al, 0Ah
    mov [edi], al
    inc edi
    mov byte ptr [edi], 0 ; null term

    ; create file
    INVOKE CreateFile,
        ADDR strGameRecordFilename,
        GENERIC_WRITE,
        0,
        NULL,
        OPEN_ALWAYS,
        FILE_ATTRIBUTE_NORMAL,
        0
        
    cmp eax, -1
    je FileError
    mov fileHandle, eax

    ; go to end of file
    INVOKE SetFilePointer, fileHandle, 0, 0, FILE_END
        
    ; write it
    INVOKE Str_length, ADDR finalRecordLine
    mov ecx, eax
    INVOKE WriteFile, fileHandle, ADDR finalRecordLine, ecx, ADDR bytesWritten, 0
        
    ; close it
    INVOKE CloseHandle, fileHandle
    ret

    FileError:
        ret

    ; helper func
    AppendStringHelper:
        push eax
        CopyL:
            mov al, [esi]
            cmp al, 0
            je EndCopyL
            mov [edi], al
            inc edi
            inc esi
            jmp CopyL
        EndCopyL:
        pop eax
        ret
AppendToFile ENDP

;-=-==-=-=-=-=-=-=-=-=- -= HANDLE INPUT -=-==-=-=-=-=-=-=-=-=-
HandleInput PROC
    ; chek esc
    INVOKE GetAsyncKeyState, VK_ESCAPE
    test ax, 8000h
    jnz GoToMenu

    ; chek p pause
    INVOKE GetAsyncKeyState, VK_P
    test ax, 8000h
    jnz DoPause

    ; chek s for secret
    INVOKE GetAsyncKeyState, VK_S
    test ax, 8000h
    jnz CheckSecretEntry

    ; chek z moon jump
    INVOKE GetAsyncKeyState, VK_Z
    test ax, 8000h
    jnz TryActivateMoon
    
    ; left key
    INVOKE GetAsyncKeyState, VK_A
    test ax, 8000h
    jz CheckRight
    dec marioX
    call CheckCollision
    CheckRight:
    ; right key
    INVOKE GetAsyncKeyState, VK_D
    test ax, 8000h
    jz CheckJump
    inc marioX
    call CheckCollision

    CheckJump:
    ; space bar
    INVOKE GetAsyncKeyState, VK_SPACE
    test ax, 8000h
    jz EndInput

    cmp isJumping, 1
    je EndInput
    
    call IsOnGround
    cmp al, 1
    jne EndInput
    
    mov isJumping, 1
    mov jumpCounter, 0
    
    ; sound
    INVOKE mciSendStringA, ADDR cmdPlayJump, 0, 0, 0
    
    jmp EndInput

    TryActivateMoon:
        cmp moonJumpUsed, 1         ; already used
        je EndInput                 
        
        mov isMoonJumpActive, 1     ; turn on
        mov moonJumpUsed, 1         ; set flag
        mov moonJumpTimer, 100      ; set time
        jmp EndInput

    CheckSecretEntry:
        ; logic to enter room
        cmp inSecretRoom, 0
        jne EndInput
        cmp secretRoomVisited, 1
        je EndInput
        
        ; check if on 5
        call IsStandingOnSecretEntry
        cmp al, 1
        je EnterSecretRoomProc
        jmp EndInput

    EndInput:
    ret

    GoToMenu:
        mov gameStatus, 3
        ret
    DoPause:
        call ShowPauseMenu
        call Clrscr
        call DrawMap
        ret
        
    EnterSecretRoomProc:
        mov inSecretRoom, 1
        mov secretRoomVisited, 1
        
        ; save pos
        mov al, marioX
        mov savedMarioX, al
        mov al, marioY
        mov savedMarioY, al
        
        ; save map
        mov ecx, 3600
        mov esi, 0
        SaveMapL:
            mov al, mapArray[esi]
            mov savedMapArray[esi], al
            inc esi
            dec ecx
            jnz SaveMapL

        ; save bad guys
        mov eax, enemyCount
        mov savedEnemyCount, eax
        
        mov ecx, MAX_ENEMIES
        mov esi, 0
        SaveEnemiesL:
            mov al, eX[esi]
            mov savedEX[esi], al
            mov al, eY[esi]
            mov savedEY[esi], al
            mov al, eType[esi]
            mov savedEType[esi], al
            mov al, eDir[esi]
            mov savedEDir[esi], al
            mov al, eActive[esi]
            mov savedEActive[esi], al
            inc esi
            dec ecx
            jnz SaveEnemiesL

        ; load room file
        INVOKE Str_copy, ADDR filename, ADDR savedFilename
        INVOKE Str_copy, ADDR strSecretRoom, ADDR filename
        mov enemyCount, 0
        call LoadMapFromFile
        
        ; set mario
        mov marioX, 5
        mov marioY, 20
        
        ; refresh scrn
        call Clrscr
        call DrawMap
        ret

HandleInput ENDP

LeaveSecretRoomProc PROC
    mov inSecretRoom, 0
    
    ; restore fname
    INVOKE Str_copy, ADDR savedFilename, ADDR filename
    
    ; restore map
    mov ecx, 3600
    mov esi, 0
    RestMapL:
        mov al, savedMapArray[esi]
        mov mapArray[esi], al
        inc esi
        dec ecx
        jnz RestMapL
        
    ; restore bad guys
    mov eax, savedEnemyCount
    mov enemyCount, eax
    
    mov ecx, MAX_ENEMIES
    mov esi, 0
    RestEnemiesL:
        mov al, savedEX[esi]
        mov eX[esi], al
        mov al, savedEY[esi]
        mov eY[esi], al
        mov al, savedEType[esi]
        mov eType[esi], al
        mov al, savedEDir[esi]
        mov eDir[esi], al
        mov al, savedEActive[esi]
        mov eActive[esi], al
        inc esi
        dec ecx
        jnz RestEnemiesL
    
    ; restore player
    mov al, savedMarioX
    mov marioX, al
    mov al, savedMarioY
    mov marioY, al
    mov oldX, al 
    mov oldY, al
    
    ; draw
    call Clrscr
    call DrawMap
    ret
LeaveSecretRoomProc ENDP

IsStandingOnSecretEntry PROC
    movzx eax, marioY
    inc eax             ; check under
    mov ebx, 120
    mul ebx
    movzx ebx, marioX
    add eax, ebx
    mov bl, mapArray[eax]
    
    cmp bl, SECRET_ENTRY_CHAR
    je YesSecret
    mov al, 0
    ret
    YesSecret:
    mov al, 1
    ret
IsStandingOnSecretEntry ENDP

;-=-==-=-=-=-=-=-=-=-=- -= UPDATE PHYSICS -=-==-=-=-=-=-=-=-=-=-
UpdatePhysics PROC
    cmp isJumping, 1
    je PerformJumpMotion

    ; gravity check
    call IsOnGround
    cmp al, 1
    je OnGroundPhysics
    
    ; fall
    inc marioY
    call CheckCollisionY
    ret

    OnGroundPhysics:
    ; check triggers
    movzx eax, marioY
    inc eax
    mov ebx, 120
    mul ebx
    movzx ebx, marioX
    add eax, ebx
    mov bl, mapArray[eax]
    
    cmp bl, "U"
    je TriggerLoad
    cmp bl, "u"
    je TriggerLoad
    ret

    TriggerLoad:
    mov gameStatus, 5
    ret

    ; jump logic
    PerformJumpMotion:
        dec marioY
        inc jumpCounter
        
        call CheckCollisionY
        cmp bl, 1
        je StopJumping
        
        ; moon jump chk
        mov eax, jumpCounter
        
        cmp isMoonJumpActive, 1     ; is active
        je CheckMoonHeight
        
        ; normal
        cmp eax, JUMP_HEIGHT        ; limit 6
        jge StopJumping
        ret
        
        CheckMoonHeight:
        cmp eax, 12                 ; limit 12
        jge StopJumping
        ret
        
    StopJumping:
        mov isJumping, 0
        ret
UpdatePhysics ENDP

;-=-==-=-=-=-=-=-=-=-=- -= IS ON GROUND -=-==-=-=-=-=-=-=-=-=-
IsOnGround PROC
    movzx eax, marioY
    inc eax             ; y plus 1
    mov ebx, 120
    mul ebx
    movzx ebx, marioX
    add eax, ebx
    mov bl, mapArray[eax]

    cmp bl, BLOCK_CHAR
    je YesGround
    cmp bl, MYSTERY_CHAR
    je YesGround
    cmp bl, GOOMBA_BLOCK_CHAR
    je YesGround
    cmp bl, PIPE_CHAR
    je YesGround
    cmp bl, "U"
    je YesGround
    cmp bl, "u"
    je YesGround
    
    ; secret blocks
    cmp bl, SECRET_ENTRY_CHAR
    je YesGround
    cmp bl, SECRET_FLOOR_CHAR
    je YesGround
    cmp bl, SECRET_EXIT_CHAR
    je YesGround
    cmp bl, SECRET_SKY_CHAR 
    je YesGround

    mov al, 0 
    ret
    YesGround:
    mov al, 1

    cmp bl, POLE_CHAR
    je YesGround
    cmp bl, FLAG_TOP_CHAR
    je YesGround

    ret
IsOnGround ENDP

;-=-==-=-=-=-=-=-=-=-=- -= CHECK COLLISION -=-==-=-=-=-=-=-=-=-=-
CheckCollision PROC
    cmp marioX, 0
    jl Revert
    cmp marioX, 118
    jg Revert

    movzx eax, marioY
    mov ebx, 120
    mul ebx
    movzx ebx, marioX
    add eax, ebx
    mov bl, mapArray[eax]
    
    cmp bl, BLOCK_CHAR
    je Revert
    cmp bl, MYSTERY_CHAR
    je Revert
    cmp bl, GOOMBA_BLOCK_CHAR 
    je Revert
    cmp bl, PIPE_CHAR 
    je Revert
    
    ; secret check
    cmp bl, SECRET_FLOOR_CHAR
    je Revert
    cmp bl, SECRET_ENTRY_CHAR
    je Revert
    cmp bl, SECRET_EXIT_CHAR
    je TriggerLeaveSecret
    cmp bl, SECRET_SKY_CHAR
    je Revert

    ; star check
    cmp bl, TURBO_STAR_CHAR
    je GetTurbo

    cmp bl, POLE_CHAR
    je Revert                
    cmp bl, FLAG_TOP_CHAR
    je Revert                

    cmp bl, "U"
    je TriggerPart2
    cmp bl, "u"
    je TriggerPart2

    cmp bl, COIN_CHAR
    je GetCoin
    cmp bl, SPIKE_CHAR
    je HitSpike
    cmp bl, LAVA_CHAR     
    je HitSpike
    cmp bl, FLAG_CHAR
    je HitFlag
    ret

    Revert:
        mov bl, oldX
        mov marioX, bl
        ret
    
    GetTurbo:
        mov isTurboMode, 1
        mov turboTimer, 400 
        mov mapArray[eax], " "
        ret

    TriggerPart2:
        mov gameStatus, 5
        ret
        
    TriggerLeaveSecret:
        call LeaveSecretRoomProc
        ret

    GetCoin:
        inc coins
        add score, 200
        mov mapArray[eax], " "
        
        INVOKE mciSendStringA, ADDR cmdPlayCoin, 0, 0, 0
        
        ret
    HitSpike:
        mov gameStatus, 1 
        ret
    HitFlag:
        INVOKE mciSendStringA, ADDR cmdStopTheme, 0, 0, 0
        INVOKE mciSendStringA, ADDR cmdPlayFlagpole, 0, 0, 0
        
        cmp currentLevel, 1
        je TriggerNextLevel
        mov gameStatus, 2 
        ret
    TriggerNextLevel:
        mov gameStatus, 4 
        ret
CheckCollision ENDP

;-=-==-=-=-=-=-=-=-=-=- -= CHECK COLLISION Y -=-==-=-=-=-=-=-=-=-=-
CheckCollisionY PROC
    movzx eax, marioY
    mov ebx, 120
    mul ebx
    movzx ebx, marioX
    add eax, ebx
    mov bl, mapArray[eax]

    ; solid
    cmp bl, BLOCK_CHAR
    je HitSolid
    cmp bl, PIPE_CHAR 
    je HitSolid
    
    ; secret solid
    cmp bl, SECRET_FLOOR_CHAR
    je HitSolid
    cmp bl, SECRET_ENTRY_CHAR
    je HitSolid
    cmp bl, SECRET_EXIT_CHAR
    je HitSolid
    cmp bl, SECRET_SKY_CHAR
    je HitSolid
    
    cmp bl, POLE_CHAR
    je HitSolid
    cmp bl, FLAG_TOP_CHAR
    je HitSolid

    ; items
    cmp bl, MYSTERY_CHAR
    je HitMystery
    cmp bl, GOOMBA_BLOCK_CHAR
    je HitMushroomBlockY
    
    cmp bl, COIN_CHAR
    je GetCoinY
    cmp bl, SPIKE_CHAR
    je HitSpikeY
    cmp bl, LAVA_CHAR      
    je HitSpikeY
    cmp bl, TURBO_STAR_CHAR
    je GetTurboY
    
    mov bl, 0 
    ret

    HitSolid:
        mov bl, oldY
        mov marioY, bl
        mov bl, 1 
        ret

    HitMystery:
        inc coins
        add score, 100
        mov mapArray[eax], BLOCK_CHAR
        ; redraw block
        push eax
        push edx
        mov dl, marioX
        mov dh, marioY
        call Gotoxy
        mov eax, blue + (6 * 16)
        call SetTextColor
        mov al, " "
        call WriteChar
        pop edx
        pop eax
        jmp HitSolid

    HitMushroomBlockY:
        mov mapArray[eax], BLOCK_CHAR
        push eax
        push edx
        mov dl, marioX
        mov dh, marioY
        call Gotoxy
        mov eax, blue + (6 * 16)
        call SetTextColor
        mov al, " "
        call WriteChar
        ; spawn shroom
        push esi
        mov esi, 0
        SpawnSearch:
            cmp esi, MAX_ENEMIES
            jge FinishSpawn
            cmp eActive[esi], 0 
            je SpawnNow
            inc esi
            jmp SpawnSearch
        SpawnNow:
            mov dl, marioX
            mov eX[esi], dl
            mov dl, marioY
            dec dl              
            dec dl              
            mov eY[esi], dl
            mov eType[esi], 5  
            mov eDir[esi], 1    
            mov eActive[esi], 1
            inc enemyCount
        FinishSpawn:
        pop esi
        pop edx
        pop eax
        jmp HitSolid

    GetCoinY:
        inc coins
        add score, 100
        mov mapArray[eax], " "
        
        INVOKE mciSendStringA, ADDR cmdPlayCoin, 0, 0, 0
        
        ret
        
    GetTurboY:
        mov isTurboMode, 1
        mov turboTimer, 400
        mov mapArray[eax], " "
        ret

    HitSpikeY:
        mov gameStatus, 1
        mov bl, 1
        ret
CheckCollisionY ENDP

;-=-==-=-=-=-=-=-=-=-=- -= SHOW MAIN MENU -=-==-=-=-=-=-=-=-=-=-
ShowMainMenu PROC
    call DrawMenuBorder

    mov eax, 12 + (black * 16) 
    call SetTextColor
    
    mov dh, 2
    mov dl, 47  
    call Gotoxy
    mov edx, OFFSET logo1
    call PrintMappedString
    
    mov dh, 3
    mov dl, 47
    call Gotoxy
    mov edx, OFFSET logo2
    call PrintMappedString

    mov dh, 4
    mov dl, 47
    call Gotoxy
    mov edx, OFFSET logo3
    call PrintMappedString
    
    mov dh, 5
    mov dl, 47
    call Gotoxy
    mov edx, OFFSET logo4
    call PrintMappedString
    
    mov dh, 6
    mov dl, 47
    call Gotoxy
    mov edx, OFFSET logo5
    call PrintMappedString

    mov dh, 8
    mov dl, 35  
    call Gotoxy
    mov edx, OFFSET logo6
    call PrintMappedString
    
    mov dh, 9
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET logo7
    call PrintMappedString

    mov dh, 10
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET logo8
    call PrintMappedString
    
    mov dh, 11
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET logo9
    call PrintMappedString
    
    mov dh, 12
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET logo10

    call PrintMappedString
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 40
    call Gotoxy
    mov al, "O"
    call WriteChar
    mov dl, 78
    call Gotoxy
    call WriteChar

    mov eax, lightGreen + (black * 16)
    call SetTextColor
    
    mov dh, 14
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET strRollNo
    call WriteString
    
    mov eax, white + (black*16)
    call SetTextColor

    mov dh, 17
    mov dl, 50
    call Gotoxy
    mWrite "1. Start Game"

    mov dh, 19
    mov dl, 50
    call Gotoxy
    mWrite "2. Instructions"

    mov dh, 21
    mov dl, 50
    call Gotoxy
    mWrite "3. High Score"

    mov dh, 23
    mov dl, 50
    call Gotoxy
    mWrite "4. Exit"

    mov dh, 26
    mov dl, 48
    call Gotoxy
    mWrite "Enter Choice: "
    
    ret
ShowMainMenu ENDP

;-=-==-=-=-=-=-=-=-=-=- -= DRAW MENU BORDER -=-==-=-=-=-=-=-=-=-=-
DrawMenuBorder PROC
    push eax
    push edx
    push ecx

    mov eax, cyan + (black * 16)
    call SetTextColor

    mov dh, 16
    mov dl, 45
    call Gotoxy
    mov ecx, 30
    L1: 
        mov al, 205 
        call WriteChar
        loop L1

    mov dh, 25
    mov dl, 45
    call Gotoxy
    mov ecx, 30
    L2: 
        mov al, 205
        call WriteChar
        loop L2

    mov ecx, 8
    mov dh, 17
    L3:
        mov dl, 44
        call Gotoxy
        mov al, 186 
        call WriteChar
        
        mov dl, 75
        call Gotoxy
        mov al, 186
        call WriteChar
        
        inc dh
        loop L3

    mov dh, 16
    mov dl, 44
    call Gotoxy
    mov al, 201 
    call WriteChar

    mov dh, 16
    mov dl, 75
    call Gotoxy
    mov al, 187 
    call WriteChar

    mov dh, 25
    mov dl, 44
    call Gotoxy
    mov al, 200 
    call WriteChar

    mov dh, 25
    mov dl, 75
    call Gotoxy
    mov al, 188 
    call WriteChar

    mov eax, brown + (black * 16)
    call SetTextColor
    mov dh, 29
    mov dl, 0
    call Gotoxy
    mov ecx, 119
    GroundLoop:
        mov al, "#"
        call WriteChar
        loop GroundLoop

    pop ecx
    pop edx
    pop eax
    ret
DrawMenuBorder ENDP

PrintMappedString PROC uses eax edx esi ebx
    mov esi, edx        
NextChar:
    mov al, [esi]        
    cmp al, 0                      
    je Done
    cmp al, '@'                 
    jne PrintNormal
    mov eax, 12 + (12 * 16)       
    call SetTextColor
    mov al, 219                    
    call WriteChar
    mov eax, 9 + (12 * 16)       
    call SetTextColor
    jmp MoveNext
PrintNormal:
    mov eax, 12 + (black * 16)         
    call SetTextColor
    mov al, [esi]
    call WriteChar        
MoveNext:
    inc esi                      
    jmp NextChar
Done:
    ret
PrintMappedString ENDP

ShowInstructions PROC
    call Clrscr
    mWrite "---- CONTROLS ----"
    call Crlf
    mWrite "A / D : Move Left / Right"
    call Crlf
    mWrite "SPACE : Jump"
    call Crlf
    mWrite "P     : Pause Game"
    call Crlf
    mWrite "S     : Enter Secret Room (On '5' block)"
    call Crlf
    mWrite "Z     : MOON JUMP (Once per level, 4 seconds)"
    call Crlf
    call Crlf
    mWrite "Goal: Collect coins (o), hit '0' blocks."
    call Crlf
    mWrite "      Hit '9' to get MUSHROOMS!"
    call Crlf
    mWrite "      Hit '*' to get TURBO SPEED!"
    call Crlf
    call WaitMsg
    ret 
ShowInstructions ENDP

ShowHighScore PROC
    call Clrscr
    mWrite "--- HIGH SCORES ---"
    call Crlf
    mWrite "Data is saved in game_record.txt"
    call Crlf
    mWrite "Open the text file to view all records."
    call Crlf
    call WaitMsg
    ret 
ShowHighScore ENDP

ShowPauseMenu PROC
    mov eax, white + (blue * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 30
    call Gotoxy
    mWrite "===================="
    mov dh, 11
    mov dl, 30
    call Gotoxy
    mWrite "|   GAME PAUSED    |"
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mWrite "|  (R)esume          |"
    mov dh, 13
    mov dl, 30
    call Gotoxy
    mWrite "|  (E)xit to Menu    |"
    mov dh, 14
    mov dl, 30
    call Gotoxy
    mWrite "===================="
    PauseLoop:
        call ReadChar
        cmp al, "r"
        je Resume
        cmp al, "e"
        je SetQuitFlag
        jmp PauseLoop
    SetQuitFlag:
        mov gameStatus, 3 
        ret
    Resume:
        ret
ShowPauseMenu ENDP

UpdateHUD PROC
    push eax
    push edx
    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov eax, white + (blue * 16)
    call SetTextColor
    mWrite "MARIO    "
    mWrite "COINS    "
    mWrite "WORLD    "
    
    ; color for turbo
    cmp isTurboMode, 1
    je BlueTime
    mov eax, white + (blue * 16)
    jmp PrintTimeLabel
    BlueTime:
    mov eax, blue + (white * 16)
    
    PrintTimeLabel:
    call SetTextColor
    mWrite "TIME     "
    
    mov eax, white + (blue * 16)
    call SetTextColor
    mWrite "LIVES    "
    mWrite "STATE"
    mov dh, 2
    mov dl, 2
    call Gotoxy
    mov eax, score
    call WriteDec
    mWrite "        "
    mov eax, coins
    call WriteDec
    mWrite "         "
    mov edx, OFFSET world
    call WriteString
    mWrite "        "
    
    ; print time
    cmp isTurboMode, 1
    je BlueTimeVal
    mov eax, white + (blue * 16)
    jmp DoPrintTime
    BlueTimeVal:
    mov eax, blue + (white * 16)
    
    DoPrintTime:
    call SetTextColor
    mov eax, time
    call WriteDec
    
    mov eax, white + (blue * 16)
    call SetTextColor
    mWrite "       "
    movzx eax, lives
    call WriteDec
    mWrite "         "
    cmp marioState, 1
    je ShowBig
    mWrite "SMALL"
    jmp DrawMoonHUD

    ShowBig:
    mWrite "BIG  "

    DrawMoonHUD:
    mov dh, 1
    mov dl, 65              
    call Gotoxy
    
    cmp isMoonJumpActive, 1
    je DrawMoonActive
    
    cmp moonJumpUsed, 0
    je DrawMoonReady
    
    ; empty if used
    mov eax, white + (black * 16)
    call SetTextColor
    mWrite "            "
    jmp DoneHUD

    DrawMoonReady:
    mov eax, white + (black * 16)
    call SetTextColor
    mWrite "[MOON: RDY]"
    jmp DoneHUD

    DrawMoonActive:
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mWrite "[MOON: "
    mov eax, moonJumpTimer
    call WriteDec
    mWrite " ]"

    DoneHUD:
    pop edx
    pop eax
    ret
UpdateHUD ENDP

;-=-==-=-=-=-=-=-=-=-=- -= DRAWMAP -=-==-=-=-=-=-=-=-=-=-
DrawMap PROC
    mov dh, 0 
    mov esi, 0 
    Outer:
        cmp dh, COL_SIZE
        jge DoneDraw
        mov dl, 0
        call Gotoxy
        Inner:
            cmp dl, ROW_SIZE
            jge NextRow
            mov al, mapArray[esi]
            
            cmp al, BLOCK_CHAR
            je PrintWall
            
            cmp al, "U"
            je PrintContinueBlock
            cmp al, "u"
            je PrintContinueBlock
            
            ; secrets
            cmp al, SECRET_ENTRY_CHAR
            je PrintSecretEntry
            cmp al, SECRET_FLOOR_CHAR
            je PrintSecretFloor
            cmp al, SECRET_EXIT_CHAR
            je PrintSecretExit
            cmp al, SECRET_SKY_CHAR
            je PrintWhiteSky
            
            cmp al, "-"
            je PrintBlackAirBlock
            
            cmp al, TURBO_STAR_CHAR
            je PrintTurboStar

            cmp al, COIN_CHAR
            je PrintCoin
            cmp al, SPIKE_CHAR
            je PrintSpike
            cmp al, LAVA_CHAR     
            je PrintLava
            
            cmp al, FLAG_CHAR
            je PrintFlag      
            cmp al, POLE_CHAR
            je PrintPole         
            cmp al, FLAG_TOP_CHAR
            je PrintFlagTop      
            
            cmp al, MYSTERY_CHAR
            je PrintMystery
            cmp al, GOOMBA_BLOCK_CHAR
            je PrintMystery
            
            cmp al, PIPE_CHAR 
            je PrintPipe
            
            cmp al, CLOUD_CHAR
            je PrintCloud
            cmp al, BUSH_CHAR
            je PrintBush
            
            ; sky logic
            cmp inSecretRoom, 1
            je PrintBlackAir
            
            movzx eax, bgLevelColor
            shl eax, 4
            add eax, white 
            call SetTextColor
            mov al, " " 
            jmp PrintChar
            
            PrintBlackAir:
            mov eax, white + (black * 16)
            call SetTextColor
            mov al, " "
            jmp PrintChar
            
            PrintWhiteSky:
            mov eax, white + (white * 16) 
            call SetTextColor
            mov al, " "
            jmp PrintChar
            
            PrintBlackAirBlock:
            mov eax, black + (black * 16)
            call SetTextColor
            mov al, " "
            jmp PrintChar

            PrintWall:
            mov eax, blue + (6 * 16) 
            call SetTextColor
            mov al, " "      
            jmp PrintChar

            PrintContinueBlock:
            mov eax, 6 + (6 * 16)   
            call SetTextColor
            mov al, "U"                 
            jmp PrintChar
            
            PrintSecretEntry:
            mov eax, black + (green * 16) 
            call SetTextColor
            mov al, "|"   
            jmp PrintChar
            
            PrintSecretFloor:
            mov eax, gray + (black * 16) 
            call SetTextColor
            mov al, 219 
            jmp PrintChar
            
            PrintSecretExit:
            mov eax, black + (black * 16) 
            call SetTextColor
            mov al, "L"
            jmp PrintChar
            
            PrintTurboStar:
            cmp inSecretRoom, 1
            je SecretStar
            
            movzx eax, bgLevelColor
            shl eax, 4
            add eax, blue
            jmp DrawStarChar
            
            SecretStar:
            mov eax, blue + (black * 16)
            DrawStarChar:
            call SetTextColor
            mov al, "*" 
            jmp PrintChar

            PrintPipe: 
            mov eax, black + (green * 16) 
            call SetTextColor
            mov al, "|"      
            jmp PrintChar

            PrintMystery:
            mov eax, yellow + (6 * 16)
            call SetTextColor
            mov al, "?"
            jmp PrintChar
            
            PrintCoin:
            cmp inSecretRoom, 1
            je PrintCoinWhite
            
            movzx eax, bgLevelColor
            shl eax, 4
            add eax, yellow
            jmp DoCoin
            
            PrintCoinWhite:
            mov eax, yellow + (black * 16)
            DoCoin:
            call SetTextColor
            mov al, "O"          
            jmp PrintChar
            
            PrintSpike:
            movzx eax, bgLevelColor
            shl eax, 4
            add eax, red
            call SetTextColor                      
            mov al, "X"          
            jmp PrintChar
            
            PrintLava:
            mov eax, red + (red * 16)
            call SetTextColor
            mov al, "v"
            jmp PrintChar
            
            PrintFlag:
            mov eax, gray + (gray * 16) 
            call SetTextColor
            mov al, "F" 
            jmp PrintChar

            PrintPole:
            mov eax, gray + (gray * 16)
            call SetTextColor
            mov al, "|"
            jmp PrintChar

            PrintFlagTop:
            mov eax, red + (red * 16)
            call SetTextColor
            mov al, ">"
            jmp PrintChar

            PrintCloud:
            cmp bgLevelColor, 0     
            je PrintBlueCloud
            
            mov eax, white + (white * 16)   
            call SetTextColor
            mov al, " "                   
            jmp PrintChar
            
            PrintBlueCloud:
            mov eax, lightBlue + (lightBlue * 16)
            call SetTextColor
            mov al, " "
            jmp PrintChar

            PrintBush: 
            mov eax, lightGreen + (lightGreen * 16)    
            call SetTextColor
            mov al, " "                   
            jmp PrintChar

            PrintChar:
            call WriteChar
            inc esi
            inc dl
            jmp Inner
        NextRow:
            inc dh
            jmp Outer
    DoneDraw:
    ret
DrawMap ENDP

DrawMario PROC
    mov dl, marioX
    mov dh, marioY
    call Gotoxy
    cmp marioState, 1
    je DrawBig
    
    mov eax, yellow + (green * 16)
    call SetTextColor
    mov al, "M"
    call WriteChar
    ret
    
    DrawBig:
    mov eax, white + (red * 16) 
    call SetTextColor
    mov al, "M"
    call WriteChar
    ret
DrawMario ENDP

EraseMario PROC
    movzx eax, oldY
    mov ebx, 120            
    mul ebx
    movzx ebx, oldX
    add eax, ebx            
    mov bl, mapArray[eax]
    
    cmp bl, BUSH_CHAR
    je RestoreBush
    cmp bl, CLOUD_CHAR
    je RestoreCloud
    cmp bl, PIPE_CHAR
    je RestorePipeM
    cmp bl, CONTINUE_CHAR
    je RestoreContinueM
    cmp bl, SECRET_ENTRY_CHAR
    je RestoreSecretM
    cmp bl, SECRET_EXIT_CHAR
    je RestoreSecretExitM
    cmp bl, SECRET_SKY_CHAR
    je RestoreWhiteSky
    cmp bl, "-"
    je RestoreBlackAirBlock
    cmp bl, LAVA_CHAR
    je RestoreLava

    ; air
    cmp inSecretRoom, 1
    je RestoreBlackAir
    
    movzx eax, bgLevelColor
    shl eax, 4
    add eax, white
    jmp DrawRestore
    
    RestoreBlackAir:
    mov eax, white + (black * 16)
    jmp DrawRestore
    
    RestoreWhiteSky:
    mov eax, white + (white * 16)
    jmp DrawRestore
    
    RestoreBlackAirBlock:
    mov eax, black + (black * 16)
    jmp DrawRestore
    
    RestoreLava:
    mov eax, red + (red * 16)
    jmp DrawRestore

    RestoreBush:
    mov eax, lightGreen + (lightGreen * 16)
    jmp DrawRestore
    
    RestoreCloud:
    cmp bgLevelColor, 0
    je RestoreBlueCloud
    
    mov eax, white + (white * 16)
    jmp DrawRestore
    
    RestoreBlueCloud:
    mov eax, lightBlue + (lightBlue * 16)
    jmp DrawRestore

    RestorePipeM:
    mov eax, black + (green * 16)
    call SetTextColor
    mov al, "|"
    call WriteChar
    ret

    RestoreContinueM:
    mov eax, brown + (yellow * 16)
    call SetTextColor
    mov al, "U"
    call WriteChar
    ret
    
    RestoreSecretM:
    mov eax, black + (green * 16)
    call SetTextColor
    mov al, "|"
    call WriteChar
    ret
    
    RestoreSecretExitM:
    mov eax, black + (black * 16) 
    call SetTextColor
    mov al, "L"
    call WriteChar
    ret

    DrawRestore:
    call SetTextColor
    mov dl, oldX
    mov dh, oldY
    call Gotoxy
    mov al, " "
    call WriteChar
    ret
EraseMario ENDP

; -=-==-=-=-=-=-=-=-=-=- -= UPDATE ENEMIES -=-==-=-=-=-=-=-=-=-=-
UpdateEnemies PROC
    mov edi, 0              
    inc enemyTimer
    cmp enemyTimer, 3        
    jl StartEnemyLoop        
    mov enemyTimer, 0        
    mov edi, 1              

    StartEnemyLoop:
    mov esi, 0              

    EnemyLoop:
        cmp esi, enemyCount
        jge DoneEnemies
        
        cmp eActive[esi], 0
        je NextEnemy
        
        call EraseEnemy 
        
        cmp eType[esi], 4    
        je DoPhysics         
        cmp edi, 1            
        jne SkipMovement      
        
        DoPhysics:                  
        
        cmp eType[esi], 10
        je DoBossPhysics

        ; gravity
        movzx eax, eY[esi]
        inc eax              
        mov ebx, 120
        mul ebx
        movzx ebx, eX[esi]
        add eax, ebx
        mov bl, mapArray[eax]
        
        cmp bl, BLOCK_CHAR
        je EnemyWalk
        cmp bl, MYSTERY_CHAR
        je EnemyWalk
        cmp bl, GOOMBA_BLOCK_CHAR 
        je EnemyWalk
        cmp bl, PIPE_CHAR 
        je EnemyWalk
        cmp bl, CONTINUE_CHAR
        je EnemyWalk
        cmp bl, SECRET_FLOOR_CHAR
        je EnemyWalk
        cmp bl, SECRET_SKY_CHAR 
        je EnemyWalk

        inc eY[esi]
        jmp CheckBounds

        DoBossPhysics:
        ; boss gravity logic
        movzx eax, eY[esi]
        add eax, 2           
        mov ebx, 120
        mul ebx
        movzx ebx, eX[esi]
        add eax, ebx
        mov bl, mapArray[eax]
        
        cmp bl, BLOCK_CHAR
        je EnemyWalk
        cmp bl, SECRET_FLOOR_CHAR
        je EnemyWalk
        cmp bl, SECRET_SKY_CHAR
        je EnemyWalk
        
        inc eax
        mov bl, mapArray[eax]
        cmp bl, BLOCK_CHAR
        je EnemyWalk
        cmp bl, SECRET_FLOOR_CHAR
        je EnemyWalk
        cmp bl, SECRET_SKY_CHAR
        je EnemyWalk
        
        inc eY[esi]

        CheckBounds:
        cmp eY[esi], 30
        jge KillEnemySilent
        jmp SkipWalk        

        EnemyWalk:
            cmp eType[esi], 3    
            je SkipWalk           

            cmp eDir[esi], 0
            je TryLeft
            jmp TryRight
            
            TryLeft:
                cmp eX[esi], 0
                jle TurnRight
                
                movzx eax, eY[esi]
                mov ebx, 120
                mul ebx
                movzx ebx, eX[esi]
                add eax, ebx
                dec eax              
                mov bl, mapArray[eax]
                
                cmp bl, BLOCK_CHAR
                je TurnRight
                cmp bl, MYSTERY_CHAR
                je TurnRight
                cmp bl, GOOMBA_BLOCK_CHAR 
                je TurnRight
                cmp bl, SPIKE_CHAR
                je TurnRight
                cmp bl, LAVA_CHAR     
                je TurnRight
                cmp bl, PIPE_CHAR 
                je TurnRight
                cmp bl, CONTINUE_CHAR
                je TurnRight
                cmp bl, SECRET_FLOOR_CHAR
                je TurnRight
                cmp bl, SECRET_SKY_CHAR 
                je TurnRight
                
                cmp eType[esi], 10
                jne DoMoveLeft
                
                add eax, 120
                mov bl, mapArray[eax]
                cmp bl, BLOCK_CHAR
                je TurnRight
                cmp bl, SECRET_FLOOR_CHAR
                je TurnRight
                cmp bl, SECRET_SKY_CHAR
                je TurnRight
                
                DoMoveLeft:
                dec eX[esi]       
                jmp SkipWalk
                
                TurnRight:
                mov eDir[esi], 1 
                jmp SkipWalk

            TryRight:
                cmp eX[esi], 118
                jge TurnLeft
                
                movzx eax, eY[esi]
                mov ebx, 120
                mul ebx
                movzx ebx, eX[esi]
                add eax, ebx
                inc eax              
                mov bl, mapArray[eax]
                
                cmp bl, BLOCK_CHAR
                je TurnLeft
                cmp bl, MYSTERY_CHAR
                je TurnLeft
                cmp bl, GOOMBA_BLOCK_CHAR 
                je TurnLeft
                cmp bl, SPIKE_CHAR
                je TurnLeft
                cmp bl, LAVA_CHAR     
                je TurnLeft
                cmp bl, PIPE_CHAR 
                je TurnLeft
                cmp bl, CONTINUE_CHAR
                je TurnLeft
                cmp bl, SECRET_FLOOR_CHAR
                je TurnLeft
                cmp bl, SECRET_SKY_CHAR 
                je TurnLeft
                
                cmp eType[esi], 10
                jne DoMoveRight
                
                inc eax 
                mov bl, mapArray[eax]
                cmp bl, BLOCK_CHAR
                je TurnLeft
                cmp bl, SECRET_SKY_CHAR
                je TurnLeft
                
                add eax, 120
                mov bl, mapArray[eax]
                cmp bl, BLOCK_CHAR
                je TurnLeft
                cmp bl, SECRET_SKY_CHAR
                je TurnLeft
                
                DoMoveRight:
                inc eX[esi]       
                jmp SkipWalk
                
                TurnLeft:
                mov eDir[esi], 0 

        SkipWalk:
        SkipMovement:

        ; shell vs enemy
        cmp eType[esi], 4        
        jne CheckMarioCollision 

        push ecx                  
        push ebx
        mov ecx, 0                
        
        ShellKillLoop:
            cmp ecx, enemyCount
            jge EndShellKill
            cmp ecx, esi        
            je NextVictim
            cmp eActive[ecx], 0 
            je NextVictim

            mov al, eX[esi]
            cmp al, eX[ecx]
            jne NextVictim
            mov al, eY[esi]
            cmp al, eY[ecx]
            jne NextVictim

            mov eActive[ecx], 0 
            add score, 200      

        NextVictim:
            inc ecx
            jmp ShellKillLoop
        
        EndShellKill:
        pop ebx
        pop ecx

        CheckMarioCollision:
            mov al, eX[esi]
            cmp al, marioX
            je XMatch
            
            cmp eType[esi], 10
            jne DrawThisEnemy 
            
            mov al, eX[esi]
            inc al
            cmp al, marioX
            jne DrawThisEnemy
            
            XMatch:
            mov al, eY[esi]
            cmp al, marioY
            je CollisionYMatch
            
            cmp eType[esi], 10
            jne DrawThisEnemy
            
            mov al, eY[esi]
            inc al
            cmp al, marioY
            je CollisionYMatch
            
            jmp DrawThisEnemy
            
            CollisionYMatch:
            
            cmp eType[esi], 5
            je CollectMushroom
            
            mov al, oldY
            cmp al, eY[esi]
            jl MarioStomped         
            
            cmp eType[esi], 3    
            je KickTheShell

            cmp marioState, 1
            je ShrinkMario
            
            mov gameStatus, 1       
            ret

            CollectMushroom:
                mov eActive[esi], 0 
                add score, 1000
                mov marioState, 1   
                jmp NextEnemy

            ShrinkMario:
                mov marioState, 0   
                sub marioY, 2
                cmp marioX, 5
                jl SafeBounce
                dec marioX              
                SafeBounce:
                jmp DrawThisEnemy

            KickTheShell:
                mov eType[esi], 4 
                mov al, marioX
                cmp al, eX[esi]
                jl MarioIsLeft      
                MarioIsRight:
                    mov eDir[esi], 0    
                    dec eX[esi]             
                    dec eX[esi]             
                    jmp DrawThisEnemy
                MarioIsLeft:
                    mov eDir[esi], 1    
                    inc eX[esi]             
                    inc eX[esi]             
                    jmp DrawThisEnemy

            MarioStomped:
                sub marioY, 2         
                cmp eType[esi], 1 
                je KillGoomba
                cmp eType[esi], 2 
                je ShellKoopa
                cmp eType[esi], 3 
                je StartShell         
                cmp eType[esi], 4 
                je DestroyShell     
                cmp eType[esi], 5 
                je CollectMushroom
                cmp eType[esi], 10
                je HitBoss
                jmp DrawThisEnemy

                KillGoomba:
                    mov eActive[esi], 0
                    add score, 100
                    jmp NextEnemy 
                ShellKoopa:
                    mov eType[esi], 3  
                    add score, 100
                    inc eX[esi] 
                    jmp DrawThisEnemy 
                StartShell:
                    mov eType[esi], 4
                    mov eDir[esi], 1 
                    jmp DrawThisEnemy
                StopShell:
                    mov eType[esi], 3
                    add score, 50
                    jmp DrawThisEnemy
                DestroyShell:
                    mov eActive[esi], 0 
                    add score, 500          
                    jmp NextEnemy
                
                HitBoss:
                    dec eHealth[esi]
                    
                    dec marioY
                    dec marioY
                    mov isJumping, 1
                    mov jumpCounter, 4 
                    
                    cmp eHealth[esi], 0
                    je BossDead
                    
                    jmp DrawThisEnemy
                    
                    BossDead:
                    mov eActive[esi], 0
                    add score, 5000
                    mov gameStatus, 2 
                    ret

        KillEnemySilent:
            mov eActive[esi], 0
            jmp NextEnemy

        DrawThisEnemy:
            call DrawEnemy
            
        NextEnemy:
            inc esi
            jmp EnemyLoop
            
    DoneEnemies:
    ret
UpdateEnemies ENDP

DrawEnemy PROC
    mov dl, eX[esi]
    mov dh, eY[esi]
    call Gotoxy
    cmp eType[esi], 1
    je DrawGoomba
    cmp eType[esi], 2
    je DrawKoopa
    cmp eType[esi], 3
    je DrawShell
    cmp eType[esi], 4
    je DrawShell
    cmp eType[esi], 5
    je DrawMushroom
    cmp eType[esi], 10
    je DrawBoss
    ret
    DrawGoomba:
        mov eax, black + (brown * 16)
        call SetTextColor
        mov al, "G"
        call WriteChar
        ret
    DrawKoopa:
        mov eax, white + (green * 16)
        call SetTextColor
        mov al, "K"
        call WriteChar
        ret
    DrawShell:
        mov eax, white + (green * 16)
        call SetTextColor
        mov al, "S"
        call WriteChar
        ret
    DrawMushroom:
        mov eax, white + (red * 16) 
        call SetTextColor
        mov al, "M"
        call WriteChar
        ret
    DrawBoss:
        mov eax, black + (red * 16)
        call SetTextColor
        mov al, "B"
        call WriteChar
        mov al, "B"
        call WriteChar
        
        mov dl, eX[esi]
        mov dh, eY[esi]
        inc dh
        call Gotoxy
        mov al, "B"
        call WriteChar
        mov al, "B"
        call WriteChar
        ret
DrawEnemy ENDP

EraseEnemy PROC
    cmp eType[esi], 10
    je EraseBossHandler

    movzx eax, eY[esi]
    mov ebx, 120
    mul ebx
    movzx ebx, eX[esi]
    add eax, ebx
    mov bl, mapArray[eax]
    
    cmp bl, BUSH_CHAR
    je RestoreBushE
    cmp bl, CLOUD_CHAR
    je RestoreCloudE
    cmp bl, COIN_CHAR
    je RestoreCoinE      
    cmp bl, FLAG_CHAR
    je RestoreFlagE      
    cmp bl, SPIKE_CHAR
    je RestoreSpikeE
    cmp bl, LAVA_CHAR
    je RestoreLavaE
    cmp bl, BLOCK_CHAR
    je RestoreWallE
    cmp bl, MYSTERY_CHAR
    je RestoreMysteryE
    cmp bl, GOOMBA_BLOCK_CHAR
    je RestoreMysteryE
    cmp bl, PIPE_CHAR 
    je RestorePipeE
    cmp bl, CONTINUE_CHAR
    je RestoreContinueE
    cmp bl, SECRET_FLOOR_CHAR
    je RestoreSecretFloorE
    cmp bl, SECRET_SKY_CHAR
    je RestoreWhiteSkyE
    cmp bl, "-"
    je RestoreBlackAirBlockE

    cmp inSecretRoom, 1
    je RestoreBlackAirE
    
    movzx eax, bgLevelColor
    shl eax, 4
    add eax, white
    call SetTextColor
    
    mov al, " "
    jmp GoXYE
    
    EraseBossHandler:
    ; clear 2 by 2
    movzx eax, bgLevelColor
    shl eax, 4
    add eax, white
    call SetTextColor
    
    mov dl, eX[esi]
    mov dh, eY[esi]
    call Gotoxy
    mov al, " "
    call WriteChar
    
    inc dl
    call Gotoxy
    call WriteChar
    
    mov dl, eX[esi]
    inc dh
    call Gotoxy
    call WriteChar
    
    inc dl
    call Gotoxy
    call WriteChar
    ret
    
    RestoreBlackAirE:
    mov eax, white + (black * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE
    
    RestoreWhiteSkyE:
    mov eax, white + (white * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE
    
    RestoreBlackAirBlockE:
    mov eax, black + (black * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE

    RestoreBushE:
    mov eax, lightGreen + (lightGreen * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE
    
    RestoreCloudE:
    cmp bgLevelColor, 0
    je RestoreBlueCloudE
    
    mov eax, white + (white * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE
    
    RestoreBlueCloudE:
    mov eax, lightBlue + (lightBlue * 16)
    call SetTextColor
    mov al, " "
    jmp GoXYE
    
    RestoreCoinE:
    cmp inSecretRoom, 1
    je RestoreCoinWhiteE
    
    movzx eax, bgLevelColor
    shl eax, 4
    add eax, yellow
    jmp DoCoinRestore
    
    RestoreCoinWhiteE:
    mov eax, yellow + (black * 16)
    DoCoinRestore:
    call SetTextColor
    mov al, "O"
    jmp GoXYE
    
    RestoreFlagE:
    mov eax, gray + (gray * 16)
    call SetTextColor
    mov al, "F"
    jmp GoXYE
    
    RestoreSpikeE:
    movzx eax, bgLevelColor
    shl eax, 4
    add eax, red
    call SetTextColor
    mov al, "X"
    jmp GoXYE
    
    RestoreLavaE:
    mov eax, red + (red * 16)
    call SetTextColor
    mov al, "v"
    jmp GoXYE
    
    RestoreWallE:
    mov eax, blue + (6 * 16) 
    call SetTextColor
    mov al, " "
    jmp GoXYE
    RestoreMysteryE:
    mov eax, black + (yellow * 16)
    call SetTextColor
    mov al, "?"
    jmp GoXYE
    RestorePipeE: 
    mov eax, black + (green * 16) 
    call SetTextColor
    mov al, "|"
    call WriteChar
    ret
    
    RestoreSecretFloorE:
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, 219
    jmp GoXYE

    RestoreContinueE:
    mov eax, 6 + (6 * 16)   
    call SetTextColor
    mov al, "U"
    jmp GoXYE

    GoXYE:
    mov dl, eX[esi]
    mov dh, eY[esi]
    call Gotoxy
    call WriteChar
    ret
EraseEnemy ENDP

;-=-==-=-=-=-=-=-=-=-=- -= LOAD MAP -=-==-=-=-=-=-=-=-=-=-
LoadMapFromFile PROC
    mov edx, OFFSET filename
    call OpenInputFile
    mov fileHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je FileError

    mov eax, fileHandle
    mov edx, OFFSET fileBuffer
    mov ecx, SIZEOF fileBuffer
    call ReadFromFile
    push eax  
    mov eax, fileHandle
    call CloseFile
    pop ecx 

    mov esi, 0      
    mov edi, 0      

    cmp ecx, 0
    je FinishLoad

    FilterLoop:
        cmp edi, 3600
        jge FinishLoad
        
        mov al, fileBuffer[esi]
        
        cmp al, 13          
        je SkipCharInc
        
        cmp al, 10          
        je HandleNewLine

        cmp al, "M"
        je FoundPlayer
        cmp al, "G"
        je AddGoomba
        cmp al, "K"
        je AddKoopa
        cmp al, "N"
        je AddBoss
        
        mov mapArray[edi], al
        inc edi
        jmp SkipCharInc

    HandleNewLine:
        push eax
        push edx
        push ebx

        mov eax, edi
        mov bl, 120
        div bl          
        cmp ah, 0
        je NoPaddingNeeded 

        mov bl, 120
        sub bl, ah      
        movzx ecx, bl   
        
        PadLoop:
            cmp edi, 3600        
            jge DonePadding
            mov mapArray[edi], " "
            inc edi
            loop PadLoop
        
        DonePadding:
        NoPaddingNeeded:
        pop ebx
        pop edx
        pop eax
        jmp SkipCharInc

    FoundPlayer:
        mov eax, edi
        mov bl, 120
        div bl
        mov marioY, al
        mov marioX, ah
        mov mapArray[edi], " " 
        inc edi
        jmp SkipCharInc

    AddGoomba:
        call CreateEnemyGoomba
        mov mapArray[edi], " "
        inc edi
        jmp SkipCharInc

    AddKoopa:
        call CreateEnemyKoopa
        mov mapArray[edi], " "
        inc edi
        jmp SkipCharInc

    AddBoss:
        call CreateEnemyBoss
        mov mapArray[edi], " "
        inc edi
        jmp SkipCharInc

    SkipCharInc:
        inc esi
        dec ecx
        jnz FilterLoop

    FinishLoad:
    ret

    FileError:
    mWrite "Error: File missing."
    exit
LoadMapFromFile ENDP

CreateEnemyGoomba PROC
    push esi
    mov esi, enemyCount
    cmp esi, MAX_ENEMIES
    jge FullEnemies
    mov eax, edi
    mov bl, 120
    div bl
    mov eY[esi], al
    mov eX[esi], ah
    mov eType[esi], 1 
    mov eDir[esi], 0    
    mov eActive[esi], 1
    mov eHealth[esi], 1
    inc enemyCount
    FullEnemies:
    pop esi
    ret
CreateEnemyGoomba ENDP

CreateEnemyKoopa PROC
    push esi
    mov esi, enemyCount
    cmp esi, MAX_ENEMIES
    jge FullEnemiesK
    mov eax, edi
    mov bl, 120
    div bl
    mov eY[esi], al
    mov eX[esi], ah
    mov eType[esi], 2 
    mov eDir[esi], 1    
    mov eActive[esi], 1
    mov eHealth[esi], 1
    inc enemyCount
    FullEnemiesK:
    pop esi
    ret
CreateEnemyKoopa ENDP

CreateEnemyBoss PROC
    push esi
    mov esi, enemyCount
    cmp esi, MAX_ENEMIES
    jge FullEnemiesB
    mov eax, edi
    mov bl, 120
    div bl
    mov eY[esi], al
    mov eX[esi], ah
    mov eType[esi], 10    
    mov eDir[esi], 1      
    mov eActive[esi], 1
    mov eHealth[esi], 4   
    inc enemyCount
    FullEnemiesB:
    pop esi
    ret
CreateEnemyBoss ENDP

CalculateTimeBonus PROC
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 12
    mov dl, 35
    call Gotoxy
    mWrite "Converting Time to Score..."

    CalcLoop:
        cmp time, 0
        jle CalcDone
        
        dec time
        add score, 50
        
        call UpdateHUD
        
        mov eax, 20 
        call Delay
        
        jmp CalcLoop
        
    CalcDone:
    mov eax, 1000
    call Delay
    ret
CalculateTimeBonus ENDP

END main