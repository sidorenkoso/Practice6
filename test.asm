.model small
.stack 100h

.data
   dispMsg db 'Input:$'
   lenDispMsg equ $-dispMsg
   buffer db 255 dup(?)  ; Buffer to store the input string
   oneChar db 0 
   filename db "test.in", 0
   mesBad db "File error $"
   handle dw 0
   firstLine db 255 dup(?) ; Buffer to store the first line of the file
.code
start: 
   mov ax, @data
   mov ds, ax

   mov dx, offset filename ; Address filename with ds:dx 
   mov ah, 3Dh ; DOS Open-File function number 
   mov al, 0 ; 0 = Read-only access 
   int 21h ; Call DOS to open file 

   jc error ; Call routine to handle errors
   jmp cont
error:
   mov ah, 09h
   mov dx, offset mesBad
   int 21h
   jmp ending
cont:
   mov [handle], ax ; Save file handle for later

   ; Read the first line separately and ignore it
   mov ah, 3Fh ; DOS Read from File function number
   mov bx, [handle] ; File handle
   mov cx, 255 ; Number of bytes to read
   mov dx, offset firstLine ; Buffer to store the first line
   int 21h ; Call DOS to read from file

   ; Read and output the rest of the file
read_next:
   mov ah, 3Fh
   mov bx, [handle] ; File handle
   mov cx, 1 ; 1 byte to read
   mov dx, offset oneChar ; Read to ds:dx 
   int 21h ; AX = number of bytes read

   ; Check for end of file
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
; Close the file
   mov ah, 3Eh ; DOS Close File function number
   mov bx, [handle] ; File handle
   int 21h ; Call DOS to close file

   ; Exit program
   mov ah, 4Ch ; DOS Terminate Program function number
   int 21h

end start
