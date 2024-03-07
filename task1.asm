.model small
.stack 100h

.data
    array dw 20 dup (?) 

.code
main:
    mov ax, @data 
    mov ds, ax

    mov cx, 20 
    lea si, array

    mov bx, 20          

fill_array:
    mov [si], bx        
    sub bx, 1             
    inc si          
    loop fill_array    

    mov ah, 4ch
    int 21h
end main