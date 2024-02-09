.model small
.stack 100h

CR		equ		13
LF		equ		10
SPACE    equ		32

.data

string_i db "-i",0 
string_o db "-o",0
string_v db "-v",0

string_comp db 128 dup(0) ; string que é comparada com a linha de comando

buffer db 128 dup(0) ; Buffer to store the string

CMDLINE db 128 dup(0) ; Buffer para armazenar a linha de comando

igual db 0 ; flag para strings iguais
msg_igual db "Strings iguais",0
msg_diferente db "Strings diferentes",0
msg_igual_i db "Igual i",0
msg_igual_o db "Igual o",0
msg_igual_v db "Igual v",0

msg_erro_1 db "Entrada invalida: Nao comecou com -i,-o ou -v",0
msg_erro_i db "Entrada invalida: Opcao [-i] sem parametro",0
msg_erro_o db "Entrada invalida: Opcao [-o] sem parametro",0
msg_erro_v db "Entrada invalida: Opcao [-v] sem parametro",0
msg_erro_esp_v db "Entrada invalida: Espaco a mais após -v",0
msg_erro_esp_i db "Entrada invalida: Espaco a mais após -i",0
msg_erro_esp_o db "Entrada invalida: Espaco a mais após -o",0

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

    

    lea bx, CMDLINE
    lea si, buffer
    add bx,1

loop_teste_cmd:

    call procura_espaco

    lea di,buffer
    lea si,string_i
    call comp_string
    cmp igual,1
    je i_flag

    lea di,buffer
    lea si,string_o
    call comp_string
    cmp igual,1
    je o_flag

    lea di,buffer
    lea si,string_v
    call comp_string
    cmp igual,1
    je v_flag

    jmp print_erro_1

    i_flag:
        lea di,buffer
        loop_limpa_buffer1:
            cmp [di],0
            je fim_loop_limpa_buffer1
            mov [di],0
            inc di
            jmp loop_limpa_buffer1
        fim_loop_limpa_buffer1:

        mov bx,cx
        lea si, buffer
        call procura_espaco
        
        lea di,buffer
        lea si,string_o
        call comp_string
        cmp igual,1
        je print_erro_i

        lea di,buffer
        lea si,string_v
        call comp_string
        cmp igual,1
        je print_erro_i

        lea si,buffer
        cmp [si],0
        je print_erro_i
        cmp [si],SPACE
        je print_erro_esp_i
        cmp [si],CR
        je print_erro_i
        cmp[si],LF
        je print_erro_i


        lea		si,buffer
		call	atoi
        cmp ax,127
        je print_erro_i
        cmp ax,220
        je print_erro_i
        jmp fim_prog

   o_flag: 
        lea di,buffer
        loop_limpa_buffer2:
            cmp [di],0
            je fim_loop_limpa_buffer2
            mov [di],0
            inc di
            jmp loop_limpa_buffer2
        fim_loop_limpa_buffer2:

        mov bx,cx
        lea si, buffer
        call procura_espaco

        lea di,buffer
        lea si,string_i
        call comp_string
        cmp igual,1
        je print_erro_o

        lea di,buffer
        lea si,string_v
        call comp_string
        cmp igual,1
        je print_erro_o

        lea si,buffer
        cmp [si],0
        je print_erro_o
        cmp [si],SPACE
        je print_erro_esp_o
        cmp [si],CR
        je print_erro_o
        cmp[si],LF
        je print_erro_o

        lea		si,buffer
		call	atoi
        cmp ax,127
        je print_erro_o
        cmp ax,220
        je print_erro_o
        jmp fim_prog


   v_flag: 
        lea di,buffer
        loop_limpa_buffer3:
            cmp [di],0
            je fim_loop_limpa_buffer3
            mov [di],0
            inc di
            jmp loop_limpa_buffer3
        fim_loop_limpa_buffer3:

        mov bx,cx
        lea si, buffer
        call procura_espaco

        lea di,buffer
        lea si,string_i
        call comp_string
        cmp igual,1
        je print_erro_v

        lea di,buffer
        lea si,string_o
        call comp_string
        cmp igual,1
        je print_erro_v
        

        lea si,buffer
        cmp [si],0
        je print_erro_v
        cmp [si],SPACE
        je print_erro_esp_v
        cmp [si],CR
        je print_erro_v
        cmp[si],LF
        je print_erro_v
        jmp fim_prog

    print_erro_1:
        lea bx,msg_erro_1
        call printf_s
        jmp fim_prog
    
    print_erro_i:
        lea bx,msg_erro_i
        call printf_s
        jmp fim_prog
    
    print_erro_v:
        lea bx,msg_erro_v
        call printf_s
        jmp fim_prog
    
    print_erro_o:
        lea bx,msg_erro_o
        call printf_s
        jmp fim_prog
    
    print_erro_esp_i:
        lea bx,msg_erro_esp_i
        call printf_s
        jmp fim_prog    
    
    print_erro_esp_o:
        lea bx,msg_erro_esp_o
        call printf_s
        jmp fim_prog

    print_erro_esp_v:
        lea bx,msg_erro_esp_v
        call printf_s
        jmp fim_prog



fim_prog: nop
.exit


;;procura_espaco: rotina para pegar a string até o espaço
procura_espaco proc near
    mov		dl,[bx]
	cmp		dl,SPACE
	je		fim_espaco

    mov		[si],dl
    inc		bx
    inc		si
    jmp		procura_espaco

fim_espaco:
    mov [si],0   
    inc bx
    mov cx,bx
    ret
procura_espaco endp


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
		cmp		byte ptr[si], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[si]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		si
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		ret

atoi	endp


end
