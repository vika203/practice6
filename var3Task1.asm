.model small
.stack 100h
.data
    buffer db 10000 dup(?)
    keys db 5000 dup(16 dup(?))
    averages dw 5000 dup(0)
    key_count dw ?
    n_lines dw ?
    cr equ 13
    lf equ 10

.code
    mov ax, @data
    mov ds, ax

    mov dx, offset buffer
    mov ah, 3Dh
    mov al, 0
    lea si, filename
    int 21h
    jc file_error

    mov bx, ax

    mov dx, offset buffer
read_loop:
    mov ah, 3Fh
    mov cx, 10000
    int 21h
    jc file_error

    mov di, 0
parse_loop:
    mov al, buffer[di]
    cmp al, cr
    je cr_found
    cmp al, lf
    je lf_found
    cmp al, 0
    je end_parse
    mov keys[n_lines][di], al
    inc di
    jmp parse_loop

cr_found:
    mov al, buffer[di+1]
    cmp al, lf
    je crlf_found
    mov ah, 0
    jmp separator_found

crlf_found:
    mov ah, 1
    inc di
    jmp separator_found

lf_found:
    mov al, buffer[di-1]
    cmp al, cr
    jne lf_not_preceded_by_cr
    mov ah, 1
    dec di
    jmp separator_found

lf_not_preceded_by_cr:
    mov ah, 0
    jmp separator_found

separator_found:
    mov buffer[di], 0
    call parse_key_value
    inc n_lines
    jmp read_loop

end_parse:
    call calculate_averages
    call bubble_sort
    call print_results

    mov ah, 3Eh
    int 21h

    mov ah, 4Ch
    int 21h

parse_key_value proc
    ret
parse_key_value endp

calculate_averages proc
    mov cx, n_lines
    mov bx, offset keys
    mov si, offset averages
average_loop:
    xor dx, dx
    xor ax, ax
    mov di, 0
    mov al, [bx+di]
    cmp al, 0
    je end_key
sum_digits:
    cmp al, '0'
    jl not_digit
    cmp al, '9'
    jg not_digit
    sub al, '0'
    mov ah, 0
    shl dx, 1
    add ax, dx
    adc dx, ax
    mov ax, dx
    mov dx, 0
not_digit:
    inc di
    mov al, [bx+di]
    jmp sum_digits
end_key:
    mov bx, cx
    mov dx, 0
    div bx
    mov [si], ax
    add si, 2
    add bx, 2
    loop average_loop
    ret
calculate_averages endp

bubble_sort proc
    mov cx, n_lines
    dec cx
    mov di, cx
outer_loop:
    mov si, 0
inner_loop:
    mov ax, averages[si]
    cmp ax, averages[si+2]
    jge no_swap
    xchg ax, averages[si+2]
    mov averages[si+2], ax
    lea bx, keys[si]
    mov dx, offset temp_key
    mov cx, 16
    rep movsb
    lea bx, keys[si+2]
    mov cx, 16
    rep movsb
    lea bx, offset temp_key
    mov cx, 16
    mov di, offset keys[si+2]
    rep movsb
no_swap:
    add si, 2
    loop inner_loop
    dec di
    jns outer_loop
    ret
bubble_sort endp

print_results proc
    mov cx, n_lines
print_loop:
    mov si, offset keys
    add si, cx
    dec si
    mov dx, offset averages
    add dx, cx
    dec dx
    call print_key_average
    dec cx
    jns print_loop
    ret

print_key_average proc
    mov di, 0
key_loop:
    mov al, [si+di]
    cmp al, 0
    je end_key_print
    mov ah, 0Eh
    int 10h
    inc di
    jmp key_loop
end_key_print:
    mov dl, ','
    mov ah, 2
    int 21h
    mov ax, [dx]
    call print_number
    mov dl, ' '
    mov ah, 2
    int 21h
    ret

print_number proc
    cmp ax, 0
    jge positive
    neg ax
    mov dl, '-'
    mov ah, 2
    int 21h
positive:
    xor cx, cx
    mov bx, 10
next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz next_digit
print_loop:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print_loop
    ret
print_number endp

file_error:
    mov ah, 9
    lea dx, file_error_message
    int 21h
