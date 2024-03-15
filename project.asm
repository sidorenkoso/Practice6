section .data
    ; Рядок для зберігання підрядка для пошуку
    substring db 0

    ; Рядок для зберігання кожного рядка, який читається з stdin
    input_line db 255, 0

    ; Рядок для зберігання кількості входжень та індексу рядка
    result_format db "%d %d", 100, 0

    ; Рядок для зберігання проміжних результатів
    temp_result dd 0

    ; Лічильники та змінні
    occurrence_count dd 0
    current_index dd 0
    total_lines dd 0

section .bss
    ; Масив для зберігання рядків
    lines_array resb 100*255

section .text
    global _start

_start:
