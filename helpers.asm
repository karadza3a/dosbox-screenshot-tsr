; Ispisivanje poruke na ekranu upotrebom BIOS-a
; -----------------------------------------------
_print:
.string dw 0
	push ax
	push si
	mov si, [.string]
	cld				; Clear direction (flag). Brine se da se SI krece u dobrom pravcu
.prn:
	lodsb				; Ucitavati znakove sve do nailaska prve nule
				  ; Ucitava se se lokacije DS:SI, i SI se pomera
						; "unapred" u memoriji ako direction flag nije postavljen (cld)
						; Ucitan znak se smesta u AL
	or   al,al		; Ako je rezultat OR operacije, kao i drugih logickih i aritmetickih 0,
						; bice postavljen zero flag.
	jz  .end			; Kraj stringa
	mov  ah,0eh		; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
	int  10h			; BIOS prekid za rad sa ekranom
	jmp .prn     
.end:
	pop  si
	pop  ax
	ret         

; Ispisivanje karaktera u al
; -----------------------------------------------
_print_char:
	push ax
	mov  ah,0eh		; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
	int  10h			; BIOS prekid za rad sa ekranom
	pop  ax
	ret          



; Poredi dva stringa
;-------------------------------------
; params:
;	di -> str1
;	si -> str2
; returns:
; 	equal ->  al = 0
; 	not_equal ->  al = 1
_strcmp:
	push si
	push di
	mov si, [.str1]
	mov di, [.str2]
.while:	
	mov ah, 0
	
	cmp byte [di], 0
	jne .skip1
		or ah, 1  ; prvi string gotov
	.skip1:

	cmp byte [si], 0
	jne .skip2
		or ah, 2  ; drugi string gotov
	.skip2:

	cmp ah, 0
	jne .string_end ; neki string gotov



	mov ah, [ds:di]
	cmp ah, [ds:si]
	jne .not_equal

	inc si
	inc di

	jmp .while

.string_end:
	cmp ah, 3  ; oba stringa gotova?
	je .equal
	jmp .not_equal

.equal:
	mov ah, 0
	mov al, 0
	jmp .end

.not_equal:
	mov ah, 0
	mov al, 1
	jmp .end

.end:
	pop di
	pop si
	ret

.str1 dw 0
.str2 dw 0