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

string_comp db 128 dup(0) ; string que é comparada com a linha de comando

erro_i db 0
erro_o db 0
erro_v db 0



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
fio_atual dw 0
n_fio db 0

conteudo_arq_in db 128 dup(0)
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
str_erro_linha db "Erro na linha",CR,LF,0





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
        jmp arquivos


arquivos:
    and t_total,0
    cmp erro_i,1
    je fim_prog
    cmp erro_o,1
    je fim_prog
    cmp erro_v,1
    je fim_prog
        
    mov tensao,ax

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

    ;; le o arquivo e coloca num buffer
    MOV AH, 3FH
    MOV BX, handle_arq_in
    MOV CX, 100
    LEA DX, conteudo_arq_in
    INT 21H

    ;; conteudo_arq_in: aramazena o cnteudo do arquivo inteiro
    ;; buffer_arq_in : armazena a linha inteira
    ;; end_atual_arqin : armazena o endereço atual da linha (serve para passar para a proxima linha)
    ;; end_atual_buffer_arqin: vai percorrendo a linha para testar os fios e pular tab/espacos

    lea bx, conteudo_arq_in
    mov cx,bx

    loop_le_linha:
     
        inc t_total

        ;; armazena no buffer_arq_in a linha // o cx aramazena o endereco da prox linha
        mov bx,cx
        lea si,buffer_arq_in
        call le_ate_LF

        ;; armazena o inicio da linha no dx // o dx vai percorrendo o buffer
        lea bx, buffer_arq_in
        mov dx,bx

        loop_elimina_tab_esp_inicio:
            mov bx,dx
            cmp [bx],0
            je fim_prog

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
            
            ;; testa se o fio possui erro ou nao
            lea bx,fio1
            call testa_erro_fio

            cmp erro_fio,1
            je erro_linha
            jmp fim_prog

            erro_linha:
                lea bx, str_erro_linha
                call printf_s
                jmp fim_prog



       ;lea si, buffer_arq_in
        ;lea di, word_fim
        ;call comp_string
       ; cmp igual,1
        ;je fim_prog

        ;jmp loop_le_linha
  
fim_prog: nop
.exit


le_ate_LF proc near
    mov dl,[bx]
    cmp dl, LF
    je fim_le_ate_LF
    cmp dl,0
    je fim_le_ate_LF
    mov [si],dl
    inc bx 
    inc si
    jmp le_ate_LF

    fim_le_ate_LF:
        mov [si],0
        inc bx
        mov cx,bx
        ret
le_ate_LF endp

le_ate_virgula_espaco_tab proc near
    mov dl,[bx]
    cmp dl, VIRGULA
    je fim_le_ate_virgula_espaco_tab
    cmp dl, SPACE
    je fim_le_ate_virgula_espaco_tab
    cmp dl, TAB
    je fim_le_ate_virgula_espaco_tab
    mov [si],dl
    inc bx 
    inc si
    jmp le_ate_virgula_espaco_tab

    fim_le_ate_virgula_espaco_tab:
        mov [si],0
        inc bx
        mov end_atual_buffer_arqin,bx
        ret
le_ate_virgula_espaco_tab endp


le_ate_virgula proc near
    mov dl,[bx]
    cmp dl, VIRGULA
    je fim_le_ate_virgula
    mov [si],dl
    inc bx 
    inc si
    jmp le_ate_virgula

    fim_le_ate_virgula:
        mov [si],0
        inc bx
        mov dx,bx
        ret
le_ate_virgula endp

    
;; testa se o fio tem erro, ou seja, se após um espaco ou tab , vem um numero -> se sim, aumento o flag de erro
testa_erro_fio proc near
    and erro_fio,0

    mov dl,[bx]
    cmp dl,0
    je fim_testa_erro_fio
    cmp dl,SPACE
    je testa_num_pos_espaco
    cmp dl,TAB
    je testa_num_pos_tab
    
    cont_test_erro_fio:
        inc bx
        jmp testa_erro_fio

    fim_testa_erro_fio:
        ret
    
    testa_num_pos_espaco:
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

		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

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
		; return
		ret

atoi	endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
