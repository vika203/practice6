;варіант3
;Провести групування: заповнити два масиви (або масив структур з 2х значень) 
;для зберігання пари <key> та <average> ,
;які будуть включати лише унікальні значення <key> а <average> - це средне значення, обраховане для всіх <value>, 
;що відповідають конкретному значенню <key>.
.model large
.STACK 100h

.data
    vdst         db '', 0dh, 0ah, '$'    ; Буфер для виводу результатів
    fname        db 'test.txt', 0        ; Ім'я файлу для читання
    fhandle      dw ?
    buffer1      db 100 dup('$')         ; Буфер для зберігання даних з файлу
    unique_data  dw 100 dup(0)           ; Масив унікальних ключів та середніх значень
    unique_index dw ?                    ; Індекс унікальних даних
    sum          dw ?                    ; Змінна для обчислення суми значень
    counter      dw ?                    ; Лічильник для підрахунку кількості значень

.code
main proc
                     mov  ax, @data                 ; Завантаження адреси сегмента даних у регістр AX
                     mov  ds, ax                    ; Завантаження адреси сегмента даних у регістр DS

    ; Відкриваємо файл
                     mov  ah, 3dh                   ; DOS-преривання для відкриття файлу
                     lea  dx, fname                 ; Передача адреси імені файлу в регістр DX
                     mov  al, 2                     ; Режим відкриття файлу (читання)
                     int  21h                       ; Виклик DOS-преривання
                     mov  fhandle, ax               ; Зберігання дескриптора файлу

    ; Кладемо дані у буфер
                     mov  ah, 3fh                   ; DOS-преривання для зчитування даних з файлу
                     mov  bx, fhandle               ; Передача дескриптора файлу в регістр BX
                     lea  dx, buffer1               ; Передача адреси буфера для зберігання даних
                     add  cx, 100                   ; Кількість байт, яку потрібно зчитати
                     int  21h                       ; Виклик DOS-преривання

                     mov  si, dx                    ; Завантаження адреси буфера в регістр SI
                     mov  unique_index, 0           ; Ініціалізація індексу унікальних даних

    looping_a:       
                     mov  al, [si]                  ; Завантаження символу з буфера в регістр AL
                     cmp  al, '0'                   ; Перевірка, чи символ є нулем
                     je   end_of_file               ; Якщо так, переходимо до кінця файлу

                     mov  ah, 09                    ; DOS-преривання для виводу символу
                     mov  helper, al                ; Зберігання значення в допоміжну змінну

                     cmp  helper, 'a'               ; Перевірка, чи зустрівся "a"
                     je   isnext_1_2                ; Якщо так, переходимо до обробки

                     inc  si                        ; Перехід до наступного символу
                     jmp  looping_a                 ; Повторюємо процес

    isnext_1_2:      
                     inc  si                        ; Перехід до наступного символу
                     mov  al, [si]                  ; Завантаження наступного символу
                     cmp  al, '1'                   ; Перевірка, чи тип даних "1"
                     je   case_1                    ; Якщо так, переходимо до обробки першого кейсу
                     jne  case_2                    ; Якщо ні, переходимо до обробки другого кейсу

    case_1:          
                     add  si, 2                     ; Перехід до наступного значення після ключа
                     mov  al, [si]                  ; Завантаження значення типу "1"
                     sub  al, '0'                   ; Конвертація ASCII в число
                     add  a1, al                    ; Додавання значення до суми "a1"
                     add  counter, 1                ; Інкремент лічильника
                     jmp  looping_a                 ; Повторення циклу

    case_2:          
                     add  si, 2                     ; Перехід до наступного значення після ключа
                     mov  al, [si]                  ; Завантаження значення типу "2"
                     sub  al, '0'                   ; Конвертація ASCII в число
                     add  a2, al                    ; Додавання значення до суми "a2"
                     add  counter, 1                ; Інкремент лічильника
                     jmp  looping_a                 ; Повторення циклу
        
    end_of_file:     
    ; Обчислення середнього значення для кожного типу даних
                     mov  sum, a1
                     div  counter                   ; Ділення суми на кількість елементів
                     mov  a1, sum                   ; Зберігання середнього значення

                     mov  sum, a2
                     div  counter                   ; Ділення суми на кількість елементів
                     mov  a2, sum                   ; Зберігання середнього значення

    ; Заповнення масиву унікальних даних
                     mov  si, offset unique_data    ; Завантаження адреси масиву унікальних даних
                     mov  cx, unique_index          ; Кількість унікальних даних
                     mov  dx, 0                     ; Створення змінної для індекса масиву унікальних даних

    fill_unique_data:
    ; Перевірка, чи вже є ключ в масиві унікальних даних
                     mov  bx, 0
                     cmp  cx, 0                     ; Перевірка, чи масив порожній
                     je   add_unique_data           ; Якщо так, додаємо новий елемент
                     mov  di, si
                     add  di, bx                    ; Зберігаємо адресу наступного ключа у діапазоні масиву
                     mov  ax, [di]                  ; Завантаження ключа
                     cmp  ax, a1                    ; Порівняння ключа
                     je   fill_average              ; Якщо ключ вже існує, переходимо до оновлення середнього значення
                     add  bx, 4                     ; Перехід до наступної пари ключ-середнє значення
                     loop fill_unique_data          ; Повторюємо пошук для іншого ключа
                     jmp  add_unique_data

    fill_average:    
    ; Обновлення середнього значення
                     add  di, 2                     ; Зберігання адреси середнього значення
                     add  [di], a1                  ; Додавання до суми
                     inc  [di+2]                    ; Інкремент лічильника
                     jmp  end_of_file

    add_unique_data: 
                     mov  ax, a1                    ; Завантаження ключа
                     mov  [si+bx], ax               ; Додавання ключа в масив унікальних даних
                     add  bx, 2                     ; Перехід до середнього значення
                     mov  [si+bx], a1               ; Додавання середнього значення в масив унікальних даних
                     add  unique_index, 1           ; Інкремент індексу масиву унікальних даних

    end_of_file:     
    ; Виведення результатів
                     mov  ah, 09
                     lea  dx, vdst
                     int  21h

                     mov  ah, 4ch                   ; DOS-преривання для завершення програми
                     int  21h                       ; Виклик DOS-преривання

main endp
end main                                 ; Завершення програми
