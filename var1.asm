.model small
.stack 100h
.data
    Buffer db 255 dup(?), '$'
    SubStrg db 255 dup(?), 'aaa$'
    FileName db "test.in", 0
    FileHandle dw ?
    SubStrLength db 0
    FoundFlag db 0          ; Флаг для позначення знаходження підстрічки
    Counts db 255 dup(0)   ; Масив для зберігання кількості підстрічок у кожній строці
    FileOpenErrorMsg db 'Error opening file.', 0Dh, 0Ah, '$'
    FileOpenSuccessMsg db 'File opened successfully.', 0Dh, 0Ah, '$'
    SubstrNotFoundMsg db 'Substring not found in file.', 0Dh, 0Ah, '$'

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
    jnc FileOpened         ; Перевірка на успішне відкриття файлу
    jmp FileOpenError      ; Якщо файл не відкрито, переходимо до обробки помилки

FileOpened:
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

    ; Вивід результату
    mov bx, 0              ; Почати зчитування результатів з початку файла
    jmp PrintResults

FileOpenError:
    ; Виведення повідомлення про помилку відкриття файлу
    mov ah, 09h
    lea dx, FileOpenErrorMsg
    int 21h
    jmp ExitProgram

FindSubStrInFile proc
    mov bx, FileHandle
    mov cl, 0             ; Зануляємо лічильник строк
ReadNextLine:

    mov ah, 3Fh
    lea dx, Buffer
    mov cl, 255
    int 21h
    or ax, ax
    jz DoneReading
    call FindSubString
    call CountSubStrInLine
    call PrintIndexAndCount
    inc bx                ; Збільшуємо індекс масиву
    jmp ReadNextLine

DoneReading:
    ret

FindSubStrInFile endp

FindSubString proc
    mov si, offset Buffer  ; Початок рядка у Buffer
    mov di, offset SubStrg ; Початок підстрічки
    mov cx, 255   ; Завантаження довжини підстрічки

SearchLoop:
    cmp cx, 0              ; Перевірка, чи досягли кінця підстрічки
    je FoundSubStr         ; Якщо так, то знайдено підстрічку
    mov al, [si]           ; Взяти символ з Buffer
    cmp al, [di]           ; Порівняти з символом у SubStr
    jne NotFound           ; Якщо символи не співпадають, перейти до мітки NotFound
    inc si                 ; Якщо співпадають, переходимо до наступного символу у Buffer
    inc di                 ; та до наступного символу у SubStr
    dec cx                 ; Зменшуємо лічильник
    loop SearchLoop        ; Повторюємо цикл до досягнення кінця підстрічки
FoundSubStr:
    mov FoundFlag, 1       ; Позначаємо, що підстрічка знайдена
    ret                    ; Повертаємося
NotFound:
    ret                    ; Повертаємося
FindSubString endp

CountSubStrInLine proc
    mov cx, 0             ; Зануляємо регістр для лічильника підстрічок у рядку
    mov si, 0             ; Ініціалізуємо індекс у Buffer
    mov di, 0             ; Ініціалізуємо індекс у SubStr

CountLoop:
    mov al, [Buffer+si]   ; Взяти символ з Buffer
    cmp al, [SubStrg+di]  ; Порівняти з символом у SubStr
    jne NotMatch          ; Якщо символи не співпадають, перейти до NotMatch
    inc si                ; Якщо співпадають, переходимо до наступного символу у Buffer
    inc di                ; та до наступного символу у SubStr
    cmp byte ptr [SubStrg+di], '$'  ; Чи досягнуто кінця підстрічки?
    je FoundSubStrCount        ; Якщо так, то знайдено підстрічку
    jmp CountLoop        ; Продовжуємо порівняння

NotMatch:
    cmp byte ptr [SubStrg], al   ; Перевірка, чи символ у Buffer співпадає з першим символом підстрічки
    jne NextCharCount           ; Якщо ні, переходимо до наступного символу в Buffer
    mov di, 0                    ; Якщо так, скидаємо індекс у SubStr і шукаємо знову

NextCharCount:
    inc si                       ; Переходимо до наступного символу в Buffer
    cmp si, 255                  ; Перевірка, чи досягли кінця рядка
    jne CountLoop               ; Якщо ні, продовжуємо пошук
    ret 
FoundSubStrCount:
    inc cx                       ; Збільшуємо лічильник підстрічок
    jmp NextCharCount            ; Переходимо до наступного символу в Buffer

CountSubStrInLine endp

PrintResults:
    mov bx, 0              ; Почати зчитування результатів з початку файла

PrintLoop:
    mov cl, Counts[bx]   ; Завантаження кількості знайдених підстрічок у регістр cx
    call PrintIndexAndCount
    inc bx
    cmp bx, 255          ; Перевірка, чи досягли кінця файлу
    jb PrintLoop

ExitProgram:
    mov ax, 4C00h        ; Код завершення програми
    int 21h

PrintIndexAndCount proc
    mov ah, 02h            ; Вивід номеру строки
    mov dl, '0'            ; Початок номера строки
    add dl, bl             ; Додавання номера строки
    int 21h

    mov ah, 02h            ; Вивід двокрапки
    mov dl, ':'            
    int 21h

    mov ah, 02h            ; Вивід кількості підстрічок у строці
    mov dl, cl             ; Завантаження кількості підстрічок
    add dl, '0'            ; Перетворення у ASCII-код
    int 21h

    mov ah, 02h            ; Вивід нового рядка
    mov dl, 0Dh
    int 21h

    mov ah, 02h            ; Вивід нового рядка
    mov dl, 0Ah
    int 21h

    ret
PrintIndexAndCount endp

ErrorMsg db "Error: Unable to open or read file", '$'

end start

