;Варіант 3: 
;підпрограма, що конвертує десяткове значення у вигляді рядка в бінарне представлення (слово) у доповнювальному коді 
.MODEL SMALL
.STACK 100H

.DATA
    decimal_input DB "12345$"     ; input стрічка
    binary_output DB 16 DUP(?)    ; output 16-бітна стрічка

.CODE
MAIN PROC
                    MOV  AX, @DATA
                    MOV  DS, AX

    ;конвертуємо десяткове число в двійкове
                    LEA  SI, decimal_input
                    LEA  DI, binary_output
                    CALL DecimalToBinary

    ; друкуємо двійкове представлення
                    MOV  AH, 9
                    LEA  DX, binary_output
                    INT  21H

                    MOV  AH, 4CH
                    INT  21H

MAIN ENDP
 
    ;сама наша програма яка перетворює десяткове число в двійкове

DecimalToBinary PROC
                    XOR  CX, CX                ; викликаємо регістр CX
                    MOV  CL, 0FH               ;встановлюємо лічильник на 15
                    MOV  AX, 0                 ; очищаємо регістр AX

    ConvertLoop:    
                    MOV  AL, [SI]              ; завантажуємо наступний символ з інпут стрічки
                    INC  SI                    ;переміщаємось до наступного символу

    ;перевірка чи рядок закінчився
                    CMP  AL, "$"
                    JE   ConvertDone

    ;конвертуємо ASCII в двійковий код
                    SUB  AL, '0'               ; конвертуємо ASCII згідно з його нумеровим значенням
                    MOV  BH, 10                ; переміщаємо 10 в регістр DH для використання в розрахунках в 10кової система числення
                    MUL  BH                    ; AX = AX * 10
                    ADD  AX, BX                ; AX = AX + BX

                    LOOP ConvertLoop           ;повторюємо цикл, допоки не будуть зчитані всі символи

    ConvertDone:  
    
   ;тепер в регістрі АХ лежить 10кове значення  
    ;перетворення AX на двійковий у двійковому виведенні
                    MOV  BX, DI                ; збергіаємо DI в BX регістрі для подальошго використання

                    MOV  CX, 16                ; цикл в 16 разів

    ConvertLoop2:   
                    ROL  AX, 1                 ; повертаємо ліворуч AX, вставивши молодший біт у CF
                    JC   SetBit1               ;якщо CF = 1, установіть відповідний біт у binary_output
                    MOV  BYTE PTR [DI], '0'    ; в іншому випадку встановлємо '0'
                    JMP  NextBit
    SetBit1:        
                    MOV  BYTE PTR [DI], '1'    ; встановлюємо '1'
    NextBit:        
                    INC  DI                    ; рухаємось до наступного біту в binary_output
                    LOOP ConvertLoop2          ; повторюємо це для всіх 16 бітів

                    MOV  BYTE PTR [DI], "$"    ; завершення двійкового рядка нулем
                    RET
DecimalToBinary ENDP

END MAIN
