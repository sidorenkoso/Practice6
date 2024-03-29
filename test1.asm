.model small
.stack 100h
.data
    Buffer db 255 dup(?), '$'
    SubStrg db 255 dup(?), 'aaa$'
    FileName db "test.in", 0
    FileHandle dw ?
    SubStrLength db 0
    FoundFlag db 0          ; Флаг для позначення знаходження підстрічки
    Counts db 255 dup(0)    ; Масив для зберігання кількості підстрічок у кожній строці
    FileOpenErrorMsg db 'Error opening file.', 0Dh, 0Ah, '$'
    FileOpenSuccessMsg db 'File opened successfully.', 0Dh, 0Ah, '$'

.code
start:
    mov ax, @data
    mov ds, ax

    ; Отримання підстрічки від користувача
    lea dx, SubStrg
    mov ah, 0Ah
    int 21h
    mov SubStrLength, 4    ; Зберігаємо довжину підстрічки

    ; Відкриття файлу 
    mov ah, 3Dh 
    mov al, 0              ; Режим читання 
    lea dx, FileName 
    int 21h  
    jc FileOpenError      ; Якщо файл не відкрито, переходимо до обробки помилки
    mov FileHandle, ax    ; Зберігаємо дескриптор файлу
    ; Виведення повідомлення про успішне відкриття файлу
    mov ah, 09h
    lea dx, FileOpenSuccessMsg
    int 21h
    
    ; Пошук підстрічки у файлі
    call FindSubStrInFile

    ; Закриття файлу
    mov ah, 3Eh
    mov bx, FileHandle
    int 21h

    ; Виведення результату
    cmp FoundFlag, 1
    jne ExitProgram        ; Вихід, якщо підстрічка не знайдена

    ; Виведення кількості підстрічок у кожній строці
    mov si, 0
PrintLoop:
    mov cl, Counts[si]   ; Завантаження кількості знайдених підстрічок у регістр cx
    call PrintIndexAndCount
    inc si
    cmp si, 255          ; Перевірка на кінець масиву Counts
    jne PrintLoop

ExitProgram:
    mov ax, 4C00h        ; Код завершення програми
    int 21h

FileOpenError:
    ; Виведення повідомлення про помилку відкриття файлу
    mov ah, 09h
    lea dx, FileOpenErrorMsg
    int 21h
    jmp ExitProgram

FindSubStrInFile:
    mov si, offset Buffer     ; Початок рядка у Buffer
    mov cx, 0                 ; Занулення лічильника строк
ReadNextLine:
    mov ah, 3Fh
    lea dx, Buffer
    mov bx, FileHandle
    mov cx, 255
    int 21h
    or ax, ax
    jz DoneReading
    call FindSubString
    call CountSubStrInLine
    jmp ReadNextLine

DoneReading:
    ret


FindSubString:
    mov di, offset SubStrg    ; Початок підстрічки
    mov cx, 255               ; Завантаження довжини підстрічки
SearchLoop:
    mov al, [si]              ; Взяти символ з Buffer
    cmp al, [di]              ; Порівняти з символом у SubStr
    je CheckSubstring         ; Якщо співпадає, перевірити підстрічку
    inc si
    loop SearchLoop           ; Повторити цикл, якщо ще не кінець рядка
    jmp NotFound              ; Якщо не знайдено підстрічку

CheckSubstring:
    mov dx, si                ; Зберегти початкову позицію підстрічки
    mov cl, SubStrLength      ; Завантажити довжину підстрічки
    repe cmpsb                ; Порівняти SubStr та Buffer
    je FoundSubstring         ; Якщо підстрічка знайдена
    jmp SearchLoop            ; Інакше шукати далі

FoundSubstring:
    mov FoundFlag, 1          ; Позначити, що підстрічка знайдена
    ret

NotFound:
    ret

CountSubStrInLine:
    mov cl, 0                  ; Занулення лічильника підстрічок у рядку
    mov si, 0                  ; Ініціалізація індексу у Buffer
    mov di, 0                  ; Ініціалізація індексу у SubStr
CountLoop:
    mov al, [Buffer+si]        ; Взяти символ з Buffer
    cmp al, [SubStrg+di]       ; Порівняти з символом у SubStr
    je CompareNextCount        ; Якщо символи однакові, перевірити наступні
    jne NextCharCount          ; Якщо ні, перейти до наступного символу у Buffer

CompareNextCount:
    inc si                      ; Перейти до наступного символу у Buffer
    inc di                      ; Перейти до наступного символу у SubStr
    cmp byte ptr [SubStrg+di], '$'  ; Перевірити, чи досягнуто кінця підстрічки
    je FoundSubStrCount         ; Якщо так, збільшити лічильник підстрічок у рядку
    cmp byte ptr [Buffer+si], '$' ; Перевірити, чи досягнуто кінця рядка
    je DoneCounting              ; Якщо так, завершити підрахунок
    jmp CountLoop               ; Якщо ні, повернутися до порівняння

NextCharCount:
    inc si                      ; Перейти до наступного символу у Buffer
    xor di, di                  ; Скинути індекс у SubStr
    cmp byte ptr [Buffer+si], '$' ; Перевірити, чи досягнуто кінця рядка
    je DoneCounting              ; Якщо так, завершити підрахунок
    jmp CountLoop               ; Повернутися до початку порівнянь

FoundSubStrCount:
    inc cl                      ; Збільшити лічильник підстрічок у рядку
    mov bx, si                  ; Зберегти позицію підстрічки для використання у PrintIndexAndCount
    mov Counts[bx], cl          ; Зберегти кількість підстрічок у масив
    jmp NextCharCount           ; Перейти до наступного символу у Buffer

DoneCounting:
    ret


PrintIndexAndCount:
    mov ah, 02h                 ; Вивести номер строки
    mov dl, '0'                 ; Початок номера строки
    add bx, si                  ; Додати номер строки
    int 21h

    mov ah, 02h                 ; Вивести двокрапку
    mov dl, ':'            
    int 21h

    mov ah, 02h                 ; Вивести кількість підстрічок у строці
    mov dl, cl                  ; Завантажити кількість підстрічок
    add dl, '0'                 ; Перетворення у ASCII-код
    int 21h

    mov ah, 02h                 ; Вивести новий рядок
    mov dl, 0Dh
    int 21h

    mov ah, 02h                 ; Вивести новий рядок
    mov dl, 0Ah
    int 21h

    ret

end start
