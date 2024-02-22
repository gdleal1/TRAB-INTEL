.model small
.stack 100h

CR		equ		13
LF		equ		10
SPACE    equ	32
TAB     equ     9
VIRGULA equ     44


.data

string_i db "-i",0 
string_o db "-o",0
string_v db "-v",0

flag_tensao_padrao db 0 

str_opcao_i db "Opcao [-i]: ",0
str_opcao_o db "Opcao [-o]: ",0
str_opcao_v db "Opcao [-v]: ",0
str_dp db ":",0
str_dp_b db ":"
str_checando db "Checando arquivo de entrada...",CR,LF,0

str_relatorio_saida db "Relatorio de saida:",CR,LF,0

string_comp db 128 dup(0) ; string que é comparada com a linha de comando

erro_i db 0
erro_o db 0
erro_v db 0

salva_regc dw 0
salva_regd dw 0

str_lf db LF,0

cont_limpa_buffer dw 128

sw_n	dw	0
sw_f	db	0
sw_m	dw	0

t_horas dw 0
t_min dw 0
t_sec dw 0




buffer_i db 128 dup(0) ; Buffer to store the string
flag_i db 0
buffer_o db 128 dup(0) ; Buffer to store the string
flag_o db 0
buffer_v db 128 dup(0) ; Buffer to store the string
flag_v db 0

conta_carac dw 0


CMDLINE db 128 dup(0) ; Buffer para armazenar a linha de comando
tam_str_cmd dw ? ; Tamanho da string da linha de comando
arq_in db 128 dup(0) 
arq_in_padrao db "a.in",0
arq_out db 128 dup(0)
arq_out_padrao db "a.out",0


;; ARQUIVOS
handle_arq_in dw 0
handle_arq_out dw 0
fio1 db 128 dup(0)
fio2 db 128 dup(0)
fio3 db 128 dup(0)
fio1_num dw 0
fio2_num dw 0
fio3_num dw 0
fio1_str db 128 dup (0)
fio2_str db 128 dup (0)
fio3_str db 128 dup (0)

t_q_tensao dw 0
t_q_tensao_h db 128 dup(0)
t_q_tensao_m db 128 dup(0) 
t_q_tensao_s db 128 dup(0) 
str_tq_tensao db "Tempo de qualidade da tensao: ",0

t_sem_tensao dw 0
t_sem_tensao_h db 128 dup(0)
t_sem_tensao_m db 128 dup(0) 
t_sem_tensao_s db 128 dup(0) 
str_sem_tensao db "Tempo sem tensao: ",0


t_total_str db 128 dup(0)
n_linha dw 0
n_linha_str db 128 dup(0)

str_tensao db 128 dup(0)

str_t_total_h db 128 dup(0)
str_t_total_m db 128 dup(0)
str_t_total_s db 128 dup(0)

str_t_total db "Tempo total: ",0
str_0 db "0",0
str_0_b db "0"
str_relatorio db "Relatorio: ",0

conteudo_arq_in db 50000 dup(0)
tensao dw 0
t_total dw 0
ok_arq_in db "Arquivo aberto com sucesso",0
ok_arq_out db "Arquivo criado com sucesso",0
erro_arq_in db "Erro: arquivo de entrada nao existe",0
buffer_arq_in db 128 dup(0)
end_atual_arqin dw 0
end_atual_buffer_arqin dw 0
word_fim db "fim",0
erro_fio dw 0
str_erro_linha db 128 dup(0)

str_linha db "Linha ",0
str_invalido db " invalido: ",0


cont_test dw 0


igual db 0 ; flag para strings iguais
msg_igual db "Strings iguais",0
msg_diferente db "Strings diferentes",0
msg_teste db "TESTE",CR,LF,0

msg_erro_1 db "Entrada invalida: Nao comecou com -i,-o ou -v",0
msg_erro_i db "Entrada invalida: Opcao [-i] sem parametro",CR,LF,0
msg_erro_o db "Entrada invalida: Opcao [-o] sem parametro",CR,LF,0
msg_erro_v db "Entrada invalida: Opcao [-v] sem parametro",CR,LF,0
msg_erro_v_t db "O parametro da opcao [-v] deve ser 127 ou 220",CR,LF,0


.code
.startup

    ;; LE A LINHA DE COMANDO
    push ds
    push es
    mov ax,ds ; Troca DS com ES para poder usa o REP MOVSB
    mov bx,es

    mov ds,bx
    mov es,ax
    mov si,80h ; Obtém o tamanho do string da linha de comando e coloca em CX
    mov ch,0
    mov cl,[si]
    mov ax,cx ; Salva o tamanho do string em AX, para uso futuro
    mov si,81h ; Inicializa o ponteiro de origem
    lea di,CMDLINE ; Inicializa o ponteiro de destino
    rep movsb
    pop es ; retorna as informações dos registradores de segmentos
    pop ds

    and flag_i,0
    and flag_o,0
    and flag_v,0
    and erro_i,0
    and erro_o,0
    and erro_v,0
    and flag_tensao_padrao,0

    mov tam_str_cmd,ax


    mov ax, tam_str_cmd
    sub ax,1
    lea cx, CMDLINE
    add cx,ax
    mov bx, cx
    cmp [bx],'i'
    je print_erro_i 


    cont_prog_i:
    lea cx, CMDLINE
    lea si, buffer_i
    add cx,1

loop_teste_cmd_i:
    mov bx,cx
    cmp [bx],0
    je nome_a_in

    mov bx,cx
    lea si, buffer_i
    call procura_espaco

    cmp flag_i,1
    je verifica_i

    lea di,buffer_i
    lea si,string_i
    call comp_string
    cmp igual,1
    je i_flag

    jmp loop_teste_cmd_i

    i_flag:
        mov flag_i,1
        jmp loop_teste_cmd_i
    
    verifica_i:

        lea di,buffer_i
        lea si,string_o
        call comp_string
        cmp igual,1
        je print_erro_i

        lea di,buffer_i
        lea si,string_v
        call comp_string
        cmp igual,1
        je print_erro_i

        lea bx, buffer_i
        lea si, arq_in
        call puts_nome_arq

        jmp inic_o

        print_erro_i:
            lea bx, msg_erro_i
            call printf_s
            inc erro_i
            jmp inic_o


nome_a_in:
    lea bx, arq_in_padrao
    lea si, arq_in
    call puts_nome_arq
    jmp inic_o


inic_o:
    mov ax, tam_str_cmd
    sub ax,1
    lea cx, CMDLINE
    add cx,ax
    mov bx, cx
    cmp [bx],'o'
    je print_erro_o
    

    cont_prog_o:
    lea cx, CMDLINE
    lea si, buffer_o
    add cx,1

    loop_teste_cmd_o:
        mov bx,cx
        cmp [bx],0
        je nome_a_out

        mov bx,cx
        lea si, buffer_o
        call procura_espaco

        cmp flag_o,1
        je verifica_o

        lea di,buffer_o
        lea si,string_o
        call comp_string
        cmp igual,1
        je o_flag

        jmp loop_teste_cmd_o

    o_flag:
        mov flag_o,1
        jmp loop_teste_cmd_o
    
    verifica_o:

        lea di,buffer_o
        lea si,string_i
        call comp_string
        cmp igual,1
        je print_erro_o

        lea di,buffer_o
        lea si,string_v
        call comp_string
        cmp igual,1
        je print_erro_o

        lea bx, buffer_o
        lea si, arq_out
        call puts_nome_arq

        jmp inic_v

        print_erro_o:
            lea bx, msg_erro_o
            call printf_s
            inc erro_o
            jmp inic_v

nome_a_out:
    lea bx, arq_out_padrao
    lea si, arq_out
    call puts_nome_arq
    jmp inic_v



inic_v:
    mov ax, tam_str_cmd
    sub ax,1
    lea cx, CMDLINE
    add cx,ax
    mov bx, cx
    cmp [bx],'v'
    je print_erro_v
    

    cont_prog_v:
    lea cx, CMDLINE
    lea si, buffer_v
    add cx,1

    loop_teste_cmd_v:
        mov bx,cx
        cmp [bx],0
        je tensao_padrao

        mov bx,cx
        lea si, buffer_v
        call procura_espaco

        cmp flag_v,1
        je verifica_v

        lea di,buffer_v
        lea si,string_v
        call comp_string
        cmp igual,1
        je v_flag

        jmp loop_teste_cmd_v

    v_flag:
        mov flag_v,1
        jmp loop_teste_cmd_v
    
    verifica_v:

        lea di,buffer_v
        lea si,string_i
        call comp_string
        cmp igual,1
        je print_erro_v

        lea di,buffer_v
        lea si,string_o
        call comp_string
        cmp igual,1
        je print_erro_v

        lea	bx,buffer_v
		call atoi

        cmp ax, 127
        je arquivos
        cmp ax, 220
        je arquivos
        jmp print_erro_v_t

        jmp arquivos

        print_erro_v:
            lea bx, msg_erro_v
            call printf_s
            inc erro_v
            jmp fim_prog
        
        print_erro_v_t:
            lea bx, msg_erro_v_t
            call printf_s
            inc erro_v
            jmp fim_prog
    
    tensao_padrao:
        mov tensao,127
        inc flag_tensao_padrao
        jmp arquivos


arquivos:
    and t_total,0
    cmp erro_i,1
    je fim_prog
    cmp erro_o,1
    je fim_prog
    cmp erro_v,1
    je fim_prog

    cmp flag_tensao_padrao,1
    je abre_arq_entrada   
    mov tensao,ax

    abre_arq_entrada:
    ;; abre arquivo de entrada
    MOV AH, 3DH
    MOV AL, 0 
    LEA DX, arq_in
    INT 21H
    mov handle_arq_in,ax
    jnc cria_arq_out
    lea bx, erro_arq_in
    call printf_s
    jmp fim_prog

    ;; cria arquivo de saida
    cria_arq_out:
        MOV AH, 3CH
        MOV CX, 0 ; atributos do arquivo
        LEA DX, arq_out
        INT 21H
        mov handle_arq_out,ax
    
    lea bx, str_checando
    call printf_s

    ;; le o arquivo de entrada e coloca num buffer
    MOV AH, 3FH
    MOV BX, handle_arq_in
    MOV CX, 50000
    LEA DX, conteudo_arq_in
    INT 21H


    ;; conteudo_arq_in: aramazena o cnteudo do arquivo inteiro
    ;; buffer_arq_in : armazena a linha inteira
    
    lea bx, conteudo_arq_in
    mov cx,bx

    and t_total,0
    and t_q_tensao,0
    and t_sem_tensao,0
    and cont_test,0


    loop_le_linha:
     
        inc t_total
        
        ;; limpas os buffers
        mov bx,128
        lea si,fio1
        call limpa_buffer
        
        mov bx,128
        lea si, fio2
        call limpa_buffer

        mov bx,128
        lea si, fio3
        call limpa_buffer  

        ;; armazena no buffer_arq_in a linha // o cx armazena o endereco da prox linha

        mov bx,cx
        lea si,buffer_arq_in
        call le_ate_LF

       
        ;; armazena o inicio da linha no dx // o dx vai percorrendo o buffer
        lea bx, buffer_arq_in
        mov dx,bx

        loop_elimina_tab_esp_inicio:
            mov si,dx
            mov al,[si]
            cmp al, ' '
            je elimina_esp_tab
            cmp al, TAB
            je elimina_esp_tab
            jmp cont1
        
        elimina_esp_tab:
            inc dx
            jmp loop_elimina_tab_esp_inicio
    
    
        cont1:

            ;; le o dx ate encontrar uma virgula --> armazena no fio 1
            mov bx, dx
            lea si, fio1
            call le_ate_virgula

            ;; coloca na variavel a versao em numero do fio
            lea bx, fio1
            lea si,fio1_str
            call pega_string_fio
            lea bx,fio1_str
            call atoi
            mov fio1_num,ax


            ;; testa se o fio possui erro ou nao
            lea bx,fio1
            call testa_erro_fio

            cmp erro_fio,1
            je erro_linha

            cmp fio1_num,0
            jb erro_linha

            cmp fio1_num,499
            ja erro_linha

            jmp loop_elimina_tab_esp_inicio2

            erro_linha:
                inc cont_test
                mov ax,t_total
                mov n_linha,ax
                lea bx, n_linha_str
                
                call sprintf_w
               
                lea bx, str_linha
                call printf_s

                lea bx, n_linha_str
                call printf_s

                lea bx, str_invalido
                call printf_s

                lea bx, buffer_arq_in
                call printf_s

                jmp test_fim_loop_le_linha

               
    loop_elimina_tab_esp_inicio2:
            mov si,dx
            mov al,[si]
            cmp al, ' '
            je elimina_esp_tab2
            cmp al, TAB
            je elimina_esp_tab2
            jmp cont2
        
        elimina_esp_tab2:
            inc dx
            jmp loop_elimina_tab_esp_inicio2
    
    
        cont2:
            ;; le o dx ate encontrar uma virgula --> armazena no fio 1
            mov bx,dx
            lea si, fio2
            call le_ate_virgula

            ;; coloca na variavel a versao em numero do fio
            lea bx, fio2
            lea si,fio2_str
            call pega_string_fio
            lea bx,fio2_str
            call atoi
            mov fio2_num,ax


            ;; testa se o fio possui erro ou nao
            lea bx,fio2
            call testa_erro_fio

            cmp erro_fio,1
            je erro_linha

            cmp fio2_num,0
            jb erro_linha

            cmp fio2_num,499
            ja erro_linha

        

            jmp loop_elimina_tab_esp_inicio3
    
    loop_elimina_tab_esp_inicio3:
            mov si,dx
            mov al,[si]
            cmp al, ' '
            je elimina_esp_tab3
            cmp al, TAB
            je elimina_esp_tab3
            jmp cont3
        
        elimina_esp_tab3:
            inc dx
            jmp loop_elimina_tab_esp_inicio3
    
    
        cont3:

            ;; le o dx ate encontrar uma virgula --> armazena no fio 1
            mov bx, dx
            lea si, fio3
            call le_buffer_ate_lf

            ;; coloca na variavel a versao em numero do fio
            lea bx, fio3
            lea si,fio3_str
            call pega_string_fio
            lea bx,fio3_str
            call atoi
            mov fio3_num,ax
   
            ;; testa se o fio possui erro ou nao
            lea bx,fio3
            call testa_erro_fio

            cmp erro_fio,1
            je erro_linha

            cmp fio3_num,0
            jb erro_linha

            cmp fio3_num,499
            ja erro_linha


            cmp tensao,127
            je testa_q_tensao_127

            testa_q_tensao_220:
                cmp fio1_num,210
                jl testa_sem_tensao

                cmp fio1_num,230
                jg testa_sem_tensao

                cmp fio2_num,210
                jl testa_sem_tensao

                cmp fio2_num,230
                jg testa_sem_tensao

                cmp fio3_num,210
                jl testa_sem_tensao

                cmp fio3_num,230
                jg testa_sem_tensao

                inc t_q_tensao
                jmp test_fim_loop_le_linha
            

            testa_q_tensao_127:
                cmp fio1_num,117
                jl testa_sem_tensao

                cmp fio1_num,137
                jg testa_sem_tensao

                cmp fio2_num,117
                jl testa_sem_tensao

                cmp fio2_num,137
                jg testa_sem_tensao

                cmp fio3_num,117
                jl testa_sem_tensao

                cmp fio3_num,137
                jg testa_sem_tensao

                inc t_q_tensao
                jmp test_fim_loop_le_linha
            
            testa_sem_tensao:
                cmp fio1_num,10
                jge test_fim_loop_le_linha

                cmp fio2_num,10
                jge test_fim_loop_le_linha

                cmp fio3_num,10
                jge test_fim_loop_le_linha

                inc t_sem_tensao
                jmp test_fim_loop_le_linha
     
            
   test_fim_loop_le_linha:      
        mov bx,cx
        mov al,[bx]
        cmp al,'f'
        je relatorio_tela
        cmp cx , 26
        je relatorio_tela
        jmp loop_le_linha

relatorio_tela:
    cmp cont_test,0
    jne fim_prog

    lea bx, str_lf
    call printf_s
    lea bx,str_relatorio
    call printf_s
    lea bx, str_lf
    call printf_s

    ;; printa as opcoes escolhida na tela
    lea bx, str_opcao_i
    call printf_s
    lea bx, arq_in
    call printf_s
    lea bx, str_lf
    call printf_s
    lea bx, str_opcao_o
    call printf_s
    lea bx, arq_out
    call printf_s
    lea bx, str_lf
    call printf_s
    lea bx, str_opcao_v
    call printf_s
    mov ax, tensao
    lea bx, str_tensao
    call sprintf_w
    lea bx, str_tensao
    call printf_s
    lea bx, str_lf
    call printf_s

    ;; printa tempo total 
    and t_horas,0
    and t_min,0
    and t_sec,0

    mov ax,t_total
    call trata_tempo

    lea bx, str_t_total
    call printf_s

    cmp t_horas,0
    je talvez_printa_total_min

    cmp t_horas,9
    ja cont_print_hrs
    lea bx, str_0
    call printf_s

    cont_print_hrs:
    mov ax, t_horas
    lea bx, str_t_total_h
    call sprintf_w
    lea bx, str_t_total_h
    call printf_s
    lea bx, str_dp
    call printf_s
    jmp printa_total_min

    talvez_printa_total_min:
        cmp t_min,0
        je printa_total_sec
    
    printa_total_min:
        cmp t_min,9
        ja cont_print_min
        lea bx, str_0
        call printf_s
        
        cont_print_min:
            mov ax, t_min
            lea bx, str_t_total_m
            call sprintf_w
            lea bx, str_t_total_m
            call printf_s
            lea bx, str_dp
            call printf_s
            jmp printa_total_sec
    
    printa_total_sec:
        cmp t_sec,9
        ja cont_print_sec
        lea bx, str_0
        call printf_s
        
        cont_print_sec:
            mov ax, t_sec
            lea bx, str_t_total_s
            call sprintf_w
            lea bx, str_t_total_s
            call printf_s
    
    ;;fecha arquivo de entrada
    mov ah, 3Eh ; Function 3Eh - close file
    mov bx, handle_arq_in
    int 21h

jmp relatorio_arqout


relatorio_arqout:

    ;; abre arquivo de saida:

    mov ah, 3Dh ; Function 3Dh - open file
    mov al, 2   ; Open for writing (0 = read, 1 = write, 2 = read/write)
    lea dx, arq_out
    int 21h

    ;; escreve no arquivo de saida

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_relatorio_saida
    mov cx,22  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_opcao_i
    mov cx,13  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, arq_in
    mov cx,10  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_lf
    mov cx,2  ; Length of the string
    int 21h
; ---------------------------------------
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_opcao_o
    mov cx,13  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, arq_out
    mov cx,10  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_lf
    mov cx,2  ; Length of the string
    int 21h
; ---------------------------------------
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_opcao_v
    mov cx,13  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_tensao
    mov cx,4  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_lf
    mov cx,2  ; Length of the string
    int 21h
; ------------ printa tempo total ------------------------

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_t_total
    mov cx,14  ; Length of the string
    int 21h

    cmp t_horas,0
    je pula_hrs
    cmp t_horas,9
    ja cont_print_hrs2

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_0
    mov cx,1  ; Length of the string
    int 21h

    cont_print_hrs2:
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_t_total_h
    mov cx,3  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_dp_b
    mov cx,1  ; Length of the string
    int 21h


    pula_hrs:
    cmp t_min,0
    je pula_min
    cmp t_min,9
    ja cont_print_min2

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_0_b
    mov cx,1  ; Length of the string
    int 21h

    cont_print_min2:
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_t_total_m
    mov cx,3  ; Length of the string
    int 21h

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_dp_b
    mov cx,1  ; Length of the string
    int 21h

    pula_min:
    cmp t_sec,9
    ja cont_print_sec2
    
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_0_b
    mov cx,1  ; Length of the string
    int 21h

    cont_print_sec2:
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_t_total_s
    mov cx,3  ; Length of the string
    int 21h
    
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_lf
    mov cx,2  ; Length of the string
    int 21h
;------------- Escreve o tempo de qualidade e sem tensao no arquivo de saida -------------------    

    and t_horas,0
    and t_min,0
    and t_sec,0

    ;; escreve msg tensao de qualidade
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_tq_tensao
    mov cx,31  ; Length of the string
    int 21h

    mov ax,t_q_tensao
    call trata_tempo

    cmp t_horas,0
    je talvez_printa_total_min2

    cmp t_horas,9
    ja cont_print_hrs3

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_0_b
    mov cx,1  ; Length of the string
    int 21h

    cont_print_hrs3:
    mov ax, t_horas
    lea bx, t_q_tensao_h
    call sprintf_w

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, t_q_tensao_h
    mov cx,3  ; Length of the string
    int 21h
    jmp printa_total_min2

    talvez_printa_total_min2:
        cmp t_min,0
        je printa_total_sec2
    
    printa_total_min2:
        cmp t_min,9
        ja cont_print_min3

        mov ah, 40h ; Function 40h - write to file
        mov bx, handle_arq_out
        lea dx, str_0_b
        mov cx,1  ; Length of the string
        int 21h

        cont_print_min3:
            mov ax, t_min
            lea bx, t_q_tensao_m
            call sprintf_w

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, t_q_tensao_m
            mov cx,3  ; Length of the string
            int 21h

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, str_dp_b
            mov cx,1  ; Length of the string
            int 21h

            jmp printa_total_sec2
        
    printa_total_sec2:
        cmp t_sec,9
        ja cont_print_sec3

        mov ah, 40h ; Function 40h - write to file
        mov bx, handle_arq_out
        lea dx, str_0_b
        mov cx,1  ; Length of the string
        int 21h

        cont_print_sec3:
            mov ax, t_sec
            lea bx, t_q_tensao_s
            call sprintf_w

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, t_q_tensao_s
            mov cx,3  ; Length of the string
            int 21h

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, str_lf
            mov cx,2  ; Length of the string
            int 21h

;-----------------------------------------------------------
    and t_horas,0
    and t_min,0
    and t_sec,0

    ;; escreve msg tensao de qualidade
    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_sem_tensao
    mov cx,19  ; Length of the string
    int 21h

    mov ax,t_sem_tensao
    call trata_tempo

    cmp t_horas,0
    je talvez_printa_total_min3

    cmp t_horas,9
    ja cont_print_hrs4

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, str_0_b
    mov cx,1  ; Length of the string
    int 21h

    cont_print_hrs4:
    mov ax, t_horas
    lea bx, t_sem_tensao_h
    call sprintf_w

    mov ah, 40h ; Function 40h - write to file
    mov bx, handle_arq_out
    lea dx, t_sem_tensao_h
    mov cx,3  ; Length of the string
    int 21h
    jmp printa_total_min3

    talvez_printa_total_min3:
        cmp t_min,0
        je printa_total_sec3
    
    printa_total_min3:
        cmp t_min,9
        ja cont_print_min4

        mov ah, 40h ; Function 40h - write to file
        mov bx, handle_arq_out
        lea dx, str_0_b
        mov cx,1  ; Length of the string
        int 21h

        cont_print_min4:
            mov ax, t_min
            lea bx, t_sem_tensao_m
            call sprintf_w

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, t_sem_tensao_m
            mov cx,3  ; Length of the string
            int 21h

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, str_dp_b
            mov cx,1  ; Length of the string
            int 21h

            jmp printa_total_sec3
        
    printa_total_sec3:
        cmp t_sec,9
        ja cont_print_sec4

        mov ah, 40h ; Function 40h - write to file
        mov bx, handle_arq_out
        lea dx, str_0_b
        mov cx,1  ; Length of the string
        int 21h

        cont_print_sec4:
            mov ax, t_sec
            lea bx, t_sem_tensao_s
            call sprintf_w

            mov ah, 40h ; Function 40h - write to file
            mov bx, handle_arq_out
            lea dx, t_sem_tensao_s
            mov cx,3  ; Length of the string
            int 21h

    ;;fecha arquivo de saida
    mov ah, 3Eh ; Function 3Eh - close file
    mov bx, handle_arq_out
    int 21h

    jmp fim_prog

fim_prog: nop
.exit



trata_tempo proc near
    cmp ax, 3600
    jge trata_horas
    cmp ax, 60
    jge trata_minutos
    jmp trata_segundos

    trata_horas:
        cmp ax,3600
        jl fim_trata_horas
        sub ax,3600
        inc t_horas
        jmp trata_horas

        fim_trata_horas:
            cmp ax,60
            jge trata_minutos
            jmp trata_segundos
    
    trata_minutos:
        cmp ax,60
        jl fim_trata_minutos
        sub ax,60
        inc t_min
        jmp trata_minutos

        fim_trata_minutos:
            cmp ax,0
            je fim_trata_tempo
            jmp trata_segundos
    
    trata_segundos:
        cmp ax,0
        je fim_trata_tempo
        sub ax,1
        inc t_sec
        jmp trata_segundos
    
fim_trata_tempo:
    ret

trata_tempo endp


pega_string_fio proc near
    and ax,0

    mov al,[bx]
    cmp al,TAB 
    je fim_pega_string_fio
    cmp al,SPACE
    je fim_pega_string_fio
    cmp al,0
    je fim_pega_string_fio

    mov [si],al
    inc si
    inc bx
    jmp pega_string_fio

    fim_pega_string_fio:
        mov [si],0
        ret
pega_string_fio endp


le_ate_LF proc near
    and ax,0

    mov al,[bx]
    cmp al, LF
    je fim_le_ate_LF
    mov [si],al
    inc bx 
    inc si
    jmp le_ate_LF

    fim_le_ate_LF:
        mov [si],LF
        inc bx
        mov cx,bx
        ret
le_ate_LF endp



le_ate_virgula proc near
    and ax,0

    mov al,[bx]
    cmp al, VIRGULA
    je fim_le_ate_virgula
    mov [si],al
    inc bx 
    inc si
    jmp le_ate_virgula

    fim_le_ate_virgula:
        mov [si],0
        inc bx
        mov dx,bx
        ret
le_ate_virgula endp

le_buffer_ate_lf proc near
    and ax,0

    mov al,[bx]
    cmp al, LF
    je fim_le_buffer_ate_lf
    mov [si],al
    inc bx 
    inc si
    jmp le_buffer_ate_lf

    fim_le_buffer_ate_lf:
        mov [si],0
        inc bx
        mov dx,bx
        ret
le_buffer_ate_lf endp

limpa_buffer_ate_lf proc near
    and ax,0

    mov al,[si]
    cmp al, LF
    je fim_limpa_buffer_ate_lf
    mov [si],0
    inc si
    jmp limpa_buffer_ate_lf

    fim_limpa_buffer_ate_lf:
        mov [si],0
        ret
limpa_buffer_ate_lf endp



comp_fim_arquivo proc near
    and bx,0
    and ax,0
    
    and igual,0
    mov al,[di]
    mov bl , [si]
    cmp al,0
    je fim_comp_fim_arquivo_igu
    inc di
    inc si
    cmp al,bl
    jne fim_comp_fim_arquivo_dif
    jmp comp_fim_arquivo
    
    fim_comp_fim_arquivo_igu:
        inc igual
        ret
    fim_comp_fim_arquivo_dif:
        ret

comp_fim_arquivo endp
    
    
;; testa se o fio tem erro, ou seja, se após um espaco ou tab , vem um numero -> se sim, aumento o flag de erro
testa_erro_fio proc near
    and erro_fio,0
    and ax,0

    mov al,[bx]
    cmp al,0
    je fim_testa_erro_fio
    cmp al,SPACE
    je testa_num_pos_espaco
    cmp al,TAB
    je testa_num_pos_tab
    
    cont_test_erro_fio:
        inc bx
        jmp testa_erro_fio

    fim_testa_erro_fio:
        ret
    
    testa_num_pos_espaco:
        and ax,0

        mov si,bx
        inc si
        mov al,[si]
        cmp al,0
        je cont_test_erro_fio
        cmp al,SPACE
        je cont_test_erro_fio
        cmp al,TAB
        je cont_test_erro_fio
        jmp fim_testa_erro_fio_erro
    
    testa_num_pos_tab:
        mov si,bx
        inc si
        mov al,[si]
        cmp al,0
        je cont_test_erro_fio
        cmp al,SPACE
        je cont_test_erro_fio
        cmp al,TAB
        je cont_test_erro_fio
        jmp fim_testa_erro_fio_erro
    
    fim_testa_erro_fio_erro:
        mov erro_fio,1
        ret
        
testa_erro_fio endp


limpa_buffer proc near
    mov [si],0
    dec bx
    cmp bx,0
    je fim_limpa_buffer
    inc si
    jmp limpa_buffer

    fim_limpa_buffer:
        ret
limpa_buffer endp




;;procura_espaco: rotina para pegar a string até o espaço
procura_espaco proc near
    mov		dl,[bx]
	cmp		dl,SPACE
	je		fim_espaco
    cmp    dl,0
    je fim_espaco_zero

    inc conta_carac
    mov		[si],dl
    inc		bx
    inc		si
    jmp		procura_espaco

fim_espaco:
    inc conta_carac
    mov [si],0   
    inc bx
    mov cx,bx
    ret
fim_espaco_zero:
    inc conta_carac
    mov [si],0
    mov cx,bx
    ret
procura_espaco endp



puts_nome_arq proc near

mov dl,[bx]
cmp dl,0
je fim_puts_nome_arq
mov [si],dl
inc si 
inc bx
jmp puts_nome_arq

fim_puts_nome_arq:
    mov [si],0
    ret
puts_nome_arq endp

;;printf_s: rotina para imprimir strings
printf_s	proc	near


;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

;		putchar(*s)
	push	bx
	mov		ah,2
	int		21H
	pop		bx

;		++s;
	inc		bx
		
;	}
	jmp		printf_s
		
ps_1:
    
	ret
	
printf_s	endp


printf_s_lf	proc	near


;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,LF
	je		ps_1_lf

;		putchar(*s)
	push	bx
	mov		ah,2
	int		21H
	pop		bx

;		++s;
	inc		bx
		
;	}
	jmp		printf_s_lf
		
ps_1_lf:
    
	ret
	
printf_s_lf	endp



;;comp_string: rotina para comparar strings
comp_string proc near

    and igual,0 ; limpa a flag de igualdade

    compare_loop:
        mov al, [si] ; load a character from string_comp into al
        mov bl, [di] ; load a character from CMDLINE into bl
        inc si ; increment string_comp pointer
        inc di ; increment CMDLINE pointer

        cmp al, bl ; compare the characters
        jne strings_differ ; if they're not equal, the strings differ

        cmp al, 0 ; check if we've reached the end of the strings
        je strings_equal ; if we have, the strings are equal

        jmp compare_loop ; otherwise, continue comparing

    strings_differ:
        jmp fim

    strings_equal:
        mov igual, 1 ; set the flag to indicate that the strings are equal
        jmp fim

fim: 
    ret
    comp_string endp 



atoi	proc near
        push dx
        push cx
		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

        cmp byte ptr[bx], '0'
        jb atoi_1

        cmp byte ptr[bx], '9'
        ja atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		pop cx
        pop dx
		ret

atoi	endp


;;- Escrever uma rotina para converter um n�mero com 16 bits em um string
;	- O valor de 16 bits entra no registrador AX
;	- O ponteiro para o string entra em DS:BX
;	- Um string � uma seq��ncia de caracteres ASCII que termina com 00H (�\0�)
sprintf_w	proc	near
push dx
push cx

;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instru��o DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
    pop cx
    pop dx
	ret
		
sprintf_w	endp
;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
