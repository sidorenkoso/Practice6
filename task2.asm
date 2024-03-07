.model small
.stack 100h

.data
    array dw 10*20 dup(?) 

.code
main:
    mov ax, @data       
    mov ds, ax          

    xor cx, cx      
    lea di, array  

outer_loop:
    xor bx, bx   
    mov dx, cx   

inner_loop:
    mov ax, dx       
    add ax, 5   
    mul bx         
    mov [di], ax   
    add di, 1    
    inc bx     
    cmp bx, 20    
    jl inner_loop   

    inc cx      
    cmp cx, 10      
    jl outer_loop   


    mov ah, 4ch     
    int 21h

end main