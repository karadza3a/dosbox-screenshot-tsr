
_print_to_file:

.filename_addr dw 0
.msg_len dw 0
.msg_addr dw 0

	pusha

;http://stanislavs.org/helppc/int_21-3d.html
	mov ah, 03ch        ; the open/create-a-file function
	mov cx,020h        ; file attribute - normal file
	mov dx, [.filename_addr]    ; address of a ZERO TERMINATED! filename string
	int 021h           ; call on Good Old Dos

	; jc error_handler!!!

	mov [filehndl],ax  ; returns a file handle

	mov ah, 040h        ; the Write-to-a-file function for int 21h
	mov bx, [filehndl]  ; the file handle goes in bx
	mov cx, [.msg_len]   ; number of bytes to write
	mov dx, [.msg_addr]     	; address to write from (the text we input)
	int 021h            ; call on Good Old Dos
	mov ah,03Eh        ; the close-the-file function
	mov bx,[filehndl]  ; the file handle
	int 021h           ; call on Good Old Dos

	popa

filehndl dw 0