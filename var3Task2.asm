;Варіант 3: 
;підпрограма, що порівнює 2 рядки (для порівняння <key> значень)

.MODEL SMALL
.STACK 100H

.DATA
    src DB "слово тестер$"
    lenSrc EQU ($ - src)
    dst DB "слово тестер$"
    lenDst EQU ($ - dst)

.CODE
_main PROC

    ; порівнюємо довжину стрічок
    mov ax, lenSrc
    cmp ax, lenDst
    jne notequal

    ;якщо довжини спіпадають, то виконуємо CMPS
    lea si, src
    lea di, dst
    mov cx, lenSrc
    cld
    repe cmpsb

    ; пілся CMPS, дивимось чи результат успішний
    jnz notequal

    ; equality things
    jmp done

notequal:
    ; non-equality things

done:
    mov ax, 4C00H ; завершуємо програму
    int 21H

_main ENDP

END
