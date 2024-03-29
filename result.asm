;варіант3
;Прочитати з stdin N рядків до появи EOF (максимум 10000 рядків).
;Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
;Кожен рядок це пара "<key> <value>" (розділяються пробілом),
; де ключ - це текстовий ідентифікатор макс 16 символів 
; (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок)
; , а значення - це десяткове ціле знакове число в діапазоні [0, 9]. 
.model large
.STACK 100h

.data
    vdst        db '', 0dh, 0ah, '$'
    fname       db 'test.txt', 0
    fhandle     dw ?
    buffer1     db 100 dup('$')
    a1          db '0', '$'
    a2          db '0', '$'
    helper      db '0', '$'


.code
main proc
    mov ax, @data
    mov ds, ax

    ;відкриваємо файл
    mov ah, 3dh
    lea dx, fname
    mov al, 2
    int 21h
    mov fhandle, ax

    ;кладемо дані у буфер
    mov ah, 3fh
    mov bx, fhandle
    lea dx, buffer1
    add cx, 100
    int 21h

    mov si, dx
    jmp looping_a

looping_a:    
    mov al, [si]      
    cmp al, '0'       
    je  end_of_file   

    mov ah, 09        
    mov helper, al

    cmp helper, 'a'
    je isnext_1_2

    inc si
    jmp looping_a      

isnext_1_2:
    inc si
    mov al, [si]
    cmp al, '1'
    je case_1
    jne case_2

case_1:
    add si, 2
    mov al, [si]
    sub al, '0'
    add a1, al  
    jmp looping_a

case_2:
    add si, 2
    mov al, [si]
    sub al, '0'
    add a2, al  
    jmp looping_a
        
end_of_file:
    mov ah, 09
    lea dx, a1     
    int 21h

    lea dx, vdst
    int 21h

    mov ah, 09
    lea dx, a2      
    int 21h

    mov ah, 4ch
    int 21h

main endp
end