.model small
.stack 100h
.data
    Buffer db 255 dup(?), '$'              ; Буфер для зберігання рядка з файлу
    SubStrg db 255 dup(?), 'aaa$'          ; Підстрічка, яку шукаємо
    FileName db "test.in", 0               ; Ім'я файлу
    FileHandle dw ?                         ; Дескриптор файлу
    SubStrLength db 0                      ; Довжина підстрічки
    FoundFlag db 0                          ; Флаг для позначення знаходження підстрічки
    Counts db 255 dup(0)                   ; Масив для зберігання кількості підстрічок у кожній строці
    FileOpenErrorMsg db 'Error opening file.', 0Dh, 0Ah, '$'    ; Повідомлення про помилку відкриття файлу
    FileOpenSuccessMsg db 'File opened successfully.', 0Dh, 0Ah, '$'    ; Повідомлення про успішне відкриття файлу
    SubstrNotFoundMsg db 'Substring not found in file.', 0Dh, 0Ah, '$'  ; Повідомлення про невдалий пошук підстрічки

.code
start:
    mov ax, @data       ; Ініціалізація вказівника на сегмент даних
    mov ds, ax          ; Завантаження сегмента даних в регістр ds

    ; Отримання підстрічки від користувача
    lea dx, SubStrg     ; Завантаження адреси підстрічки у dx
    mov ah, 0Ah         ; Код функції для читання рядка
    int 21h             ; Виклик інтеруптівної послуги 21h
    mov SubStrLength, 4 ; Зберігання довжини підстрічки

    ; Відкриття файлу 
    mov ah, 3Dh         ; Код функції для відкриття файлу
    mov al, 0           ; Режим читання 
    lea dx, FileName    ; Завантаження адреси імені файлу у dx
    int 21h             ; Виклик інтеруптівної послуги 21h  
    jnc FileOpened      ; Перевірка на успішне відкриття файлу
    jmp FileOpenError   ; Якщо файл не відкрито, перехід до обробки помилки

FileOpened:
    mov FileHandle, ax  ; Зберігання дескриптора файлу
    ; Виведення повідомлення про успішне відкриття файлу
    mov ah, 09h         ; Код функції для виведення рядка
    lea dx, FileOpenSuccessMsg  ; Завантаження адреси рядка у dx
    int 21h             ; Виклик інтеруптівної послуги 21h
    jmp ContinueProgram ; Перехід до продовження виконання програми

FileOpenError:
    ; Виведення повідомлення про помилку відкриття файлу
    mov ah, 09h         ; Код функції для виведення рядка
    lea dx, FileOpenErrorMsg  ; Завантаження адреси рядка у dx
    int 21h             ; Виклик інтеруптівної послуги 21h

ContinueProgram:

    ; Пошук підстрічки у файлі
    mov FileHandle, 0   ; Очищення FileHandle
    call FindSubStrInFile   ; Виклик підпрограми для пошуку підстрічки в файлі

    ; Закриття файлу
    mov ah, 3Eh         ; Код функції для закриття файлу
    mov bx, FileHandle ; Завантаження дескриптора файлу у bx
    int 21h             ; Виклик інтеруптівної послуги 21h

    ; Виведення результату
    cmp FoundFlag, 1    ; Перевірка, чи знайдено підстрічку
    jnz PrintError      ; Якщо підстрічка не знайдена, виведення повідомлення про помилку

    mov cl, Counts[bx]  ; Завантаження кількості знайдених підстрічок у регістр cx
    call PrintIndexAndCount  ; Виклик підпрограми для виведення номера строки та кількості підстрічок

ExitProgram:
    mov ax, 4C00h       ; Код завершення програми
    int 21h             ; Виклик інтеруптівної послуги 21h

PrintError:
    ; Виведення повідомлення про помилку
    mov ah, 09h         ; Код функції для виведення рядка
    lea dx, SubstrNotFoundMsg  ; Завантаження адреси рядка у dx
    int 21h             ; Виклик інтеруптівної послуги 21h
    jmp ExitProgram     ; Перехід до завершення програми

FindSubStrInFile proc
    mov bx, FileHandle  ; Завантаження дескриптора файлу у bx
    mov cl, 0           ; Занулення лічильника строк
ReadNextLine:

    mov ah, 3Fh         ; Код функції для читання з файлу
    lea dx, Buffer      ; Завантаження адреси буфера у dx
    mov cl, 255         ; Завантаження довжини буфера
    int 21h             ; Виклик інтеруптівної послуги 21h
    or ax, ax           ; Перевірка на кінець файлу
    jz DoneReading      ; Якщо досягнуто кінець файлу, завершення читання
    call FindSubString ; Виклик підпрограми для пошуку підстрічки
    call CountSubStrInLine ; Виклик підпрограми для підрахунку підстрічок у рядку
    call PrintIndexAndCount ; Виклик підпрограми для виведення номера строки та кількості підстрічок
    mov Counts[bx], cl  ; Зберігання кількості підстрічок у масив
    inc bx              ; Збільшення індексу масиву
    cmp FoundFlag, 1    ; Перевірка, чи знайдено підстрічку
    jnz ReadNextLine    ; Якщо підстрічка не знайдена, читання наступного рядка

DoneReading:
    ret                 ; Завершення підпрограми

FindSubStrInFile endp

FindSubString proc
    mov si, offset Buffer  ; Завантаження адреси початку рядка у Buffer
    mov di, offset SubStrg ; Завантаження адреси початку підстрічки у SubStrg
    mov cx, 255            ; Завантаження довжини підстрічки

SearchLoop:
    cmp cx, 0              ; Перевірка, чи досягнуто кінця підстрічки
    je FoundSubStr         ; Якщо так, то знайдено підстрічку
    mov al, [si]           ; Завантаження символу з Buffer у al
    cmp al, [di]           ; Порівняння з символом у SubStr
    jne NotFound           ; Якщо символи не співпадають, перехід до мітки NotFound
    inc si                 ; Перехід до наступного символу у Buffer
    inc di                 ; Перехід до наступного символу у SubStr
    dec cx                 ; Зменшення лічильника
    loop SearchLoop        ; Повторення циклу до досягнення кінця підстрічки
FoundSubStr:
    mov FoundFlag, 1       ; Позначення, що підстрічка знайдена
    ret                    ; Повернення з підпрограми
NotFound:
    ret                    ; Повернення з підпрограми
FindSubString endp

CountSubStrInLine proc
    mov cx, 0              ; Занулення лічильника підстрічок у рядку
    mov si, 0              ; Ініціалізація індексу у Buffer
    mov di, 0              ; Ініціалізація індексу у SubStr

CountLoop:
    mov al, [Buffer+si]    ; Завантаження символу з Buffer у al
    cmp al, [SubStrg+di]   ; Порівняння з символом у SubStrg
    je CompareNextCount    ; Якщо символи однакові, перехід до порівняння наступних символів
    jne NextCharCount      ; Якщо ні, перехід до наступного символу у Buffer

CompareNextCount:
    inc si                 ; Перехід до наступного символу у Buffer
    inc di                 ; Перехід до наступного символу у SubStrg
    cmp byte ptr [SubStrg+di], '$' ; Перевірка, чи досягнуто кінця підстрічки
    je FoundSubStrCount    ; Якщо так, збільшення лічильника підстрічок у рядку
    jmp CountLoop          ; Якщо ні, продовження порівнянь

NextCharCount:
    inc si                 ; Перехід до наступного символу у Buffer
    xor di, di             ; Скидання індексу у SubStrg
    jmp CountLoop          ; Повернення до початку порівнянь

FoundSubStrCount:
    inc cx                 ; Збільшення лічильника підстрічок у рядку
    ret                    ; Повернення з підпрограми

CountSubStrInLine endp

PrintIndexAndCount proc
    mov ah, 02h            ; Код функції для виведення символа
    mov dl, '0'            ; Початок номера строки
    add dl, bl             ; Додавання номера строки
    int 21h                ; Виклик інтеруптівної послуги 21h

    mov ah, 02h            ; Код функції для виведення символа
    mov dl, ':'            ; Виведення двокрапки
    int 21h                ; Виклик інтеруптівної послуги 21h

    mov ah, 02h            ; Код функції для виведення символа
    mov dl, cl             ; Завантаження кількості підстрічок
    add dl, '0'            ; Перетворення у ASCII-код
    int 21h                ; Виклик інтеруптівної послуги 21h

    mov ah, 02h            ; Код функції для виведення символа
    mov dl, 0Dh            ; Виведення нового рядка
    int 21h                ; Виклик інтеруптівної послуги 21h

    mov ah, 02h            ; Код функції для виведення символа
    mov dl, 0Ah            ; Виведення нового рядка
    int 21h                ; Виклик інтеруптівної послуги 21h

    ret                    ; Повернення з підпрограми

PrintIndexAndCount endp

BubbleSort proc
    mov cx, 255            ; Завантаження довжини масиву Counts
OuterLoop:
    mov si, 0              ; Початок з першого елементу масиву
InnerLoop:
    mov al, Counts[si]     ; Завантаження поточного елементу у al
    cmp Counts[si+1], al   ; Порівняння з наступним елементом
    jg Swap                ; Якщо наступний елемент більший, обмін місцями
    inc si                 ; Перехід до наступного елементу
    loop InnerLoop         ; Повторення внутрішнього циклу для всіх елементів
    loop OuterLoop         ; Повторення зовнішнього циклу для всіх елементів
    ret                     ; Повернення з підпрограми

Swap:
    mov dl, Counts[si+1]   ; Завантаження наступного елементу у dl
    mov Counts[si+1], al   ; Зберігання поточного елементу у наступний
    mov Counts[si], dl     ; Зберігання наступного елементу у поточний
    ret                     ; Повернення з підпрограми
BubbleSort endp


ErrorMsg db "Error: Unable to open or read file", '$'

end start
