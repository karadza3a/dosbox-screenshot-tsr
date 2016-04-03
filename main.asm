org 100h

cr equ 0Ah
lf equ 0Dh

KBD equ 60h
F1_SCAN equ 3Bh
; F1_SCAN equ 01h

segment .code

main:
	cld
	mov	cx, 0080h	; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
	mov	di, 81h		; Pocetak komandne linije u PSP.

	mov	al, ' '		; String uvek pocinje praznim mestom (razmak izmedju komande i parametra) 
	repe	scasb		; Trazimo prvo mesto koje nije prazno (tada DI pokazuje na lokaciju iza njega)
				;   REPNE - nalazi prvi bajt koji je jednak sa bajtom u AL
				;   REPE  - nalazi prvi bajt koji NIJE jednak sa bajtom u AL

	mov	si, di		; Pocetak stringa u SI
	mov	bx, cx		; save counter
	mov	al, ' '		; Trazimo kraj stringa (prazno mjesto)
	repne	scasb		; (tada DI pokazuje na lokaciju iza njega) 
	
	; prvi token mora biti kraci od 8 karaktera
	; Ovo rjesava i problem kad je samo jedan token
	; i 'di' se inkrementuje do kraja PSP
	mov ax, di
	sub ax, si
	cmp ax, 8

	jl .found_end

	;else reset counter, reset string pointer
	mov cx, bx
	mov di, si
	mov	al, lf		; Trazimo kraj stringa (enter)
	repne	scasb		; (tada DI pokazuje na lokaciju iza njega) 
	

.found_end:
	dec si
	mov	byte [di-1], 0                  ; string zavrsavamo nulom   

	; compare with stop
	mov word [_strcmp.str1], si
	mov word [_strcmp.str2], text_stop
	call _strcmp

	cmp al, 0
	je .stop_tsr

	; compare with start
	mov word [_strcmp.str1], si
	mov word [_strcmp.str2], text_start
	call _strcmp

	cmp al, 0
	je .start_tsr

.wrong_params:
	mov word [_print.string], text_usage
	call	_print
	ret	

.stop_tsr:
	mov word [_print.string], text_stopping
	call	_print
	ret

.start_tsr:

	mov	si, di 			; pocetak je sada poslije '-start'
	mov	al, ' '			; skipujemo razmak
	repe	scasb			; (tada DI pokazuje na lokaciju iza njega) 

	mov	si, di 			; pocetak je sada poslije '-start    '
	dec	si

	mov	al, lf			; Trazimo kraj stringa (enter)
	repne	scasb			; (tada DI pokazuje na lokaciju iza njega) 
	dec	di
	mov	byte [di], 0		; string zavrsavamo nulom   

	
	; drugi token mora biti duzi od 0 karaktera, kraci od 64
	mov ax, di
	sub ax, si

	; add al, '0'
	; call _print_char
	; sub al, '0'

	cmp ax, 1
	jl .wrong_params
	cmp ax, 64	
	jg .wrong_params

	; call	_print

	mov [filename_addr], si

	mov word [_print.string], text_starting
	call	_print

	call _install_tsr

ret

segment .data

text_usage db "Usage:", cr, lf, "  SS.COM -start filename", cr, lf, "  SS.COM -stop", cr, lf, 0
text_stop db "-stop", 0
text_start db "-start", 0
text_stopping db "Removing screenshot TSR...", cr, lf, 0
text_starting db "Installing screenshot TSR...", cr, lf, 0
text_meddling db "Meddling with interupt table...", cr, lf, 0
text_new_line db cr, lf, 0
text_tsr_exists db "A copy of this TSR already exists in memory",cr,lf, " Aborting installation process.",cr,lf,0
text_tsr_haos db "There are too many TSRs already installed.",cr,lf, "Sorry, aborting installation process.",cr,lf,0

filename_addr dw 0

%include "helpers.asm"
%include "my_int.asm"
%include "file_fun.asm"