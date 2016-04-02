segment .code

; Sacuvati originalni vektor prekida 0x09, tako da kasnije mozemo da ga vratimo
_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_int09_off], bx 
	mov bx, [es:09h*4+2]
	mov [old_int09_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, _myint_09
	mov [es:09h*4], dx
	mov ax, cs
	mov [es:09h*4+2], ax
	sti         
	ret


; Vratiti stari vektor prekida 0x09
_stari_09:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int09_seg]
	mov [es:09h*4+2], ax
	mov dx, [old_int09_off]
	mov [es:09h*4], dx
	sti
	ret


; Sacuvati originalni vektor prekida 0x2F, tako da kasnije mozemo da ga vratimo
_novi_2F:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:2Fh*4]
	mov [old_int2F_off], bx 
	mov bx, [es:2Fh*4+2]
	mov [old_int2F_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, _myint_2F
	mov [es:2Fh*4], dx
	mov ax, cs
	mov [es:2Fh*4+2], ax
	sti         
	ret


; Vratiti stari vektor prekida 0x2F
_stari_2F:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int2F_seg]
	mov [es:2Fh*4+2], ax
	mov dx, [old_int2F_off]
	mov [es:2Fh*4], dx
	sti
	ret


; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_int1C_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_int1C_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, _myint_1C
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	sti         
	ret


; Vratiti stari vektor prekida 0x1C
_stari_1C:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int1C_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [old_int1C_off]
	mov [es:1Ch*4], dx
	sti
	ret

segment .data

old_int2F_seg: dw 0
old_int2F_off: dw 0
old_int1C_seg: dw 0
old_int1C_off: dw 0
old_int09_seg: dw 0
old_int09_off: dw 0