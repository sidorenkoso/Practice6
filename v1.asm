.model small
.stack 100h

.data
   dispMsg db 'Input:$'
   lenDispMsg equ $-dispMsg
   buffer db 255 dup(?)  ; Buffer to store the input string
    oneChar db 0 
    filename  db "test.in", 0
    mesBad db "File error $"
    handle dw 0
.code
start: 
mov ax, @data
    mov ds, ax

    mov dx, offset fileName; Address filename with ds:dx 
    mov ah, 03Dh ;DOS Open-File function number 
    mov  al, 0;  0 = Read-only access 
    int 21h; Call DOS to open file 

    jc error ;Call routine to handle errors
        jmp cont
    error:
        mov ah, 09h
    mov dx, offset mesBad
    int 21h
    jmp ending
    cont:

    mov [handle] , ax ; Save file handle for later

;read file and put characters into buffer
read_next:
    mov ah, 3Fh
    mov bx, [handle]  ; file handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    ; do something with [oneChar]

    ;save ax
    push ax
    push bx
    push cx
    push dx
    mov ah, 02h
    mov dl, oneChar
    int 21h
   
pop dx
pop cx
pop bx
pop ax
    or ax,ax
    jnz read_next

ending:

end start
