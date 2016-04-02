segment .code

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
	push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x2F
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
	push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x1C
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