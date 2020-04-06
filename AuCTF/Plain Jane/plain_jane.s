	.file	"plain_asm.c"
	.intel_syntax noprefix
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	mov	eax, 0
	call	func_1
	mov	DWORD PTR -4[rbp], eax 	; rbp-4 = 1346
	mov	eax, 0
	call	func_2
	mov	DWORD PTR -8[rbp], eax 	; rbp-8 = 207
	mov	edx, DWORD PTR -8[rbp]	; edx = 207
	mov	eax, DWORD PTR -4[rbp]	; eax = 1346
	mov	esi, edx				; esi = 207
	mov	edi, eax				; edi = 1346
	call	func_3
	mov	DWORD PTR -12[rbp], eax	; rbp-12 = var4 (1197903)
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.globl	func_1
	.type	func_1, @function
func_1:
.LFB7:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	BYTE PTR -1[rbp], 25	; var1 = 25
	mov	DWORD PTR -8[rbp], 0	; var2 = 0
	jmp	.L4
.L5:
	mov	eax, DWORD PTR -8[rbp]	; eax = var2
	add	eax, 10					; eax = var2 + 10
	mov	edx, eax				; edx = var2 + 10
	mov	eax, edx				; eax = var2 + 10
	sal	eax, 2					; eax = (var2 + 10) << 2
	add	eax, edx				; eax = ((var2 + 10) << 2) + (var2 + 10)
	lea	edx, 0[0+rax*4]			; edx = (((var2 + 10) << 2) + (var2 + 10)) * 4
	add	eax, edx				; eax = ((var2 + 10) << 2) + (var2 + 10) + ((((var2 + 10) << 2) + (var2 + 10)) * 4)
	add	BYTE PTR -1[rbp], al	; var1 += ((var2 + 10) << 2) + (var2 + 10) + ((((var2 + 10) << 2) + (var2 + 10)) * 4) & 0xff
	add	DWORD PTR -8[rbp], 1	; var2 += 1
.L4:
	cmp	DWORD PTR -8[rbp], 9  		; cmp var2 9
	jle	.L5							; 0 < 9 -> L5
	movzx	eax, BYTE PTR -1[rbp]	; eax = var1
	mov	DWORD PTR -12[rbp], eax		; rbp-12 = var1
	mov	eax, DWORD PTR -12[rbp]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	func_1, .-func_1
	.globl	func_2
	.type	func_2, @function
func_2:
.LFB8:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	DWORD PTR -4[rbp], 207		; rbp-4 = 207
	mov	eax, DWORD PTR -4[rbp]		; eax = 207
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	func_2, .-func_2
	.globl	func_3
	.type	func_3, @function
func_3:
.LFB9:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	DWORD PTR -36[rbp], edi		; rbp-36 = 1346
	mov	DWORD PTR -40[rbp], esi		; rbp-40 = 207
	cmp	DWORD PTR -36[rbp], 64		
	jg	.L10						; if(1346 > 64) -> .L10
	mov	eax, 24						; eax = 24
	jmp	.L11
.L10:
	cmp	DWORD PTR -40[rbp], 211
	jle	.L12
	mov	eax, 20
	jmp	.L11
.L12:
	cmp	DWORD PTR -36[rbp], 0		; cmp 1346 0
	je	.L13						; not equal
	cmp	DWORD PTR -40[rbp], 0		; cmp 207 0
	jne	.L13						; jump not equal
	mov	eax, 120
	jmp	.L11
.L13:
	cmp	DWORD PTR -36[rbp], 0		; cmp 1346 0
	jne	.L14
	cmp	DWORD PTR -40[rbp], 0
	je	.L14
	mov	eax, 220
	jmp	.L11
.L14:
	mov	eax, DWORD PTR -36[rbp]		; eax = 1346
	or	eax, DWORD PTR -40[rbp]		; eax = 1346 || 207 (1487)
	mov	DWORD PTR -12[rbp], eax		; var1 = 1487
	mov	eax, DWORD PTR -36[rbp]		; eax = 1346
	and	eax, DWORD PTR -40[rbp]		; eax = 1346 & 207
	mov	DWORD PTR -16[rbp], eax		; var2 = 66
	mov	eax, DWORD PTR -36[rbp]		; eax = 1346
	xor	eax, DWORD PTR -40[rbp]		; eax = 1346 ^ 207
	mov	DWORD PTR -20[rbp], eax		; var3 = 1421
	mov	DWORD PTR -4[rbp], 0		; var4 = 0
	mov	DWORD PTR -8[rbp], 0		; var5 = 0
	jmp	.L15
.L16:
	mov	eax, DWORD PTR -16[rbp]		; eax = var2
	sub	eax, DWORD PTR -8[rbp]		; eax = var2 - var5
	mov	edx, eax					; edx = var2 - var5
	mov	eax, DWORD PTR -12[rbp]		; eax = var1
	add	eax, edx					; eax = var1 + (var2 - var5)
	add	DWORD PTR -4[rbp], eax		; var4 += (var1 + (var2 - var5))
	add	DWORD PTR -8[rbp], 1		; rbp-8 += 1
.L15:
	mov	eax, DWORD PTR -8[rbp]		; eax = var5
	cmp	eax, DWORD PTR -20[rbp]		; cmp var5 var3
	jl	.L16
	mov	eax, DWORD PTR -4[rbp]		; eax = var4
.L11:
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	func_3, .-func_3
	.ident	"GCC: (Debian 9.2.1-22) 9.2.1 20200104"
	.section	.note.GNU-stack,"",@progbits
