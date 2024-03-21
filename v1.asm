.model small
.stack 100h

.data
   dispMsg db 'Substring: $'
   lenDispMsg equ $-dispMsg
   buffer db 100 dup(?)  ; Buffer to store the input string

.code
start:
   mov ax, @data
   mov ds, ax

   mov si, offset buffer  ; Pointer to the start of the buffer
   mov cx, 100            ; Maximum number of characters to read

read_loop:
   mov ah, 01h            ; Function to read a character
   int 21h 
   cmp al, 0Dh            ; Check if Enter key is pressed
   je end_input           ; If Enter is pressed, exit loop
   mov [si], al           ; Store the character in buffer
   inc si                 ; Move to the next position in the buffer
   loop read_loop         ; Continue reading characters

end_input:
   mov byte ptr [si], '$' ; Null-terminate the string
   lea dx, dispMsg
   mov ah, 09h
   int 21h

   lea dx, buffer         ; Display the entered string
   int 21h

   ; Exit code
exit_program:
    mov ah, 4Ch
    int 21h

end start
