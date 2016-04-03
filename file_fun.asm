segment .code

_ChkDOSStatus:
		push ax
		push bx
		mov ah, 34h
		int 21h
		mov al, [es:bx]     ;Get InDOS flag.
		dec bx
		or al, [es:bx]   ;OR with CritErr flag.
		pop bx
		pop ax
		jz .Okay2Call

	.NotOkay2Call:
		stc
		ret

	.Okay2Call:     
		clc
		ret

_print_to_file:

		pusha

		call _ChkDOSStatus

		jc .kraj

	;http://stanislavs.org/helppc/int_21-3d.html
		mov ah, 03Ch        ; the open/create-a-file function
		mov cx, 000h        ; file attribute - normal file
		mov dx, [.filename_addr]    ; address of a ZERO TERMINATED! filename string
		int 021h           ; call on Good Old Dos

		jc .error_handler

		mov [filehndl],ax  ; returns a file handle

		mov ah, 040h        ; the Write-to-a-file function for int 21h
		mov bx, [filehndl]  ; the file handle goes in bx
		mov cx, [.msg_len]   ; number of bytes to write
		mov dx, [.msg_addr]     	; address to write from (the text we input)
		int 021h            ; call on Good Old Dos
		mov ah,03Eh        ; the close-the-file function
		mov bx,[filehndl]  ; the file handle
		int 021h           ; call on Good Old Dos
		jmp .kraj

	.error_handler:
		push ax
		mov al, 'e'
		call _print_char
		mov al, 'r'
		call _print_char
		mov al, 'r'
		call _print_char
		mov al, ':'
		call _print_char
		pop ax
		call _ax2hex
	.kraj:
		popa
	ret

.filename_addr dw 0
.msg_len dw 0
.msg_addr dw 0


segment .data

filehndl dw 0

