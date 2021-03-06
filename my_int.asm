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

		; install int handlers
		call _novi_2F
		call _novi_09
		call _novi_1C

		; terminate and stay resident
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

		cmp     ah, [cs:FuncID]   ;Is this call for us?
		je      .ItsUs

		; jump to old int
		push word [cs:old_int2F_seg]
		push word [cs:old_int2F_off]
	retf

	; Now decode the function value in AL:

	.ItsUs:
		cmp     al, 0           ;Verify presence call?
		je     .verify

	.verify:
		mov     al, 0FFh        ;Return "present" value in AL.
		mov 	di, uid
	iret                    ;Return to caller.

_myint_1C:
		pusha
		mov bx, cs
		mov ds, bx

		cmp byte [should_print], 1
		jne .izlaz

	.write:
		mov bx, [filename_addr]
		mov word [_print_to_file.filename_addr], bx
		mov word [_print_to_file.msg_len], 2050
		mov word [_print_to_file.msg_addr], screen_cap
		call _print_to_file
		jc .izlaz

		; succesful
		mov byte [should_print], 0

		cmp byte [status_mode], 1
		jne .izlaz

		call _green_dot

		jmp .izlaz

	.izlaz:
		popa  
		push word [old_int1C_seg]
		push word [old_int1C_off]
	retf
		;retf (return far) ce da skoci na stari handler za 09h
		;nema potrebe da mi radimo iret, posto ce to stari hendler da ucini za nas
	;iret

_myint_09:
		pusha
		mov bx, cs
		mov ds, bx

	; Obrada tastaturnog prekida 
		in al, KBD				;citamo scan code
		cmp al, F1_SCAN				;ako je pritisnuto F1
		je .f1
		cmp al, F2_SCAN				;ako je pritisnuto F2
		je .f2
		jmp .izlaz					;u suprotnom, idi na kraj
	.f2:
		xor byte [status_mode], 1
		jmp .izlaz
	.f1:
		mov byte [should_print], 1
		mov bx, 0B800h
		mov es, bx

		mov cx, 2000
		mov dx, 80 ;new line counter
		mov bx, 0
		mov di, screen_cap
	.copy:
		mov al, [es:bx]
		mov [di], al
		inc di
		add bx, 2

		dec dx
		or dx, dx
		jnz .copy_bottom

		mov dx, 80
		mov byte [di], cr
		inc di
		mov byte [di], lf
		inc di

	.copy_bottom:
		loop .copy

		jmp .izlaz

	.izlaz:
		popa
		
		push word [old_int09_seg]
		push word [old_int09_off]
	retf
		;retf (return far) ce da skoci na stari handler za 09h
		;nema potrebe da mi radimo iret, posto ce to stari hendler da ucini za nas
	;iret

segment .data

FuncID db 0
uid db "screenshot.karadza3a.com", cr, lf, 0
should_print db 0
status_mode db 0
screen_cap times 2060 db 0

%include "prekidi.asm"

