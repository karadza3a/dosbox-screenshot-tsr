segment .code

_install_tsr:
		mov     byte [FuncID], 0       ;Initialize FuncID to zero.
		mov     cx, 0FFh
	.SearchLoop:
		cmp cl, 080h		; try all IDs 80h..FFh
		je .NotInstalled

		push cx
		push ds

		mov ah, cl
		mov al, 0
		int 2Fh
		
		pop ds
		pop cx
		
		cmp al, 0
		je .TryNext

		mov word [_strcmp.str1], di		; ID matches?
		mov word [_strcmp.str2], uid
		call _strcmp
		cmp al, 0
		
		je      .AlreadyThere
		loop    .SearchLoop
		jmp     .NotInstalled

	.TryNext:
		mov     [FuncID], cl	; Save possible function ID if this
		loop    .SearchLoop		;  identifier is not in use.
		jmp     .NotInstalled

	.AlreadyThere:
		mov word [_print.string], text_tsr_exists
		call _print
	ret

	.NotInstalled:
		cmp     byte [FuncID], 0       ;If there are no available IDs, this
		jne     .GoodID          ; will still contain zero.
		mov word [_print.string], text_tsr_haos
		call _print
	ret
	    
	.GoodID:
		mov word [_print.string], text_meddling
		call _print
		;install tsr
		call _novi_2F
		mov dx, 0FFFh	;Cuvamo FFF paragrafa
		mov ah, 31h		;TSR funkcija ima kod 31h
		int 21h			;DOS sistemski poziv
    
	ret

;If this code gets to label "GoodID" then a previous copy of the TSR is not
; present in memory and the FuncID variable contains an unused function identifier.
; Of course, when you install your TSR in this manner, you must not forget to patch 
; your interrupt 2Fh handler into the int 2Fh chain. Also, you have to write an interrupt 
; 2Fh handler to process int 2Fh calls. The following is a very simple multiplex interrupt
; handler for the code we've been developing:

_myint_2F:

	push ax
	mov ax, cs
	mov ds, ax	
	pop ax

	cmp     ah, [FuncID]   ;Is this call for us?
	je      .ItsUs

	; jump to old int
	push word [old_int2F_seg]
	push word [old_int2F_off]
	retf

	; Now decode the function value in AL:

	.ItsUs:
		cmp     al, 0           ;Verify presence call?
		je     .verify
		cmp     al, 1          ;remove call?
		je     .remove
	iret

	.verify:
		mov     al, 0FFh        ;Return "present" value in AL.
		mov 	di, uid
	iret                    ;Return to caller.

	.remove:
		
		;remove

	iret                    ;Return to caller.

_myint_1C:
		pusha

		push gs     ; obnovi vrednost ds koju smo sacuvali pri instaliranju hendlera
		pop  ds
	; ; Obrada tajmerskog prekida 
	; 	dec word [brojac]
	; 	jnz izlaz
	; ; Jeste nula, tj. sad ispisujemo...
	; 	inc  byte [var]
	; 	mov ax, [vrednost]
	; 	mov [brojac], ax
	;     mov si, var
	; 	call _print

	izlaz:
		popa  	
	iret

segment .data

FuncID db 0
uid db "screenshot.karadza3a.com", cr, lf, 0

%include "prekidi.asm"

