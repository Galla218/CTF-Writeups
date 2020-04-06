# Plain Jane
- Reversing

I'm learning assembly. Think you can figure out what this program returns?

## Solution
I decided to figure this one out the hard way and opened up `plain_jane.s` in Visual Studio and followed the assembly line by line.

Looking at main, I see it calls three different functions.
```
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
	mov	DWORD PTR -4[rbp], eax
	mov	eax, 0
	call	func_2
	mov	DWORD PTR -8[rbp], eax
	mov	edx, DWORD PTR -8[rbp]
	mov	eax, DWORD PTR -4[rbp]
	mov	esi, edx				
	mov	edi, eax				
	call	func_3
	mov	DWORD PTR -12[rbp], eax	
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
  ```
  `func_1` was relatively straight forward. It would initiate two variables with the values `25` and `0`
  ```
  mov	BYTE PTR -1[rbp], 25  ; var1
  mov	DWORD PTR -8[rbp], 0  ; var2
  ```
  Compare `var2` to `9` and if less than or equal to, jump
  ```
  cmp	DWORD PTR -8[rbp], 9  		; cmp var2 9
  jle	.L5
  ```
  At the jump, `var1` would go through several mathematical operations and `var2` would be incremented by one. So, we have a simple while loop.
  ```
  mov	eax, DWORD PTR -8[rbp]	; eax = var2
  add	eax, 10                 ; eax = var2 + 10
  mov	edx, eax                ; edx = var2 + 10
  mov	eax, edx                ; eax = var2 + 10
  sal	eax, 2                  ; eax = (var2 + 10) << 2
  add	eax, edx                ; eax = ((var2 + 10) << 2) + (var2 + 10)
  lea	edx, 0[0+rax*4]         ; edx = (((var2 + 10) << 2) + (var2 + 10)) * 4
  add	eax, edx                ; eax = ((var2 + 10) << 2) + (var2 + 10) + ((((var2 + 10) << 2) + (var2 + 10)) * 4)
  add	BYTE PTR -1[rbp], al    ; var1 += ((var2 + 10) << 2) + (var2 + 10) + ((((var2 + 10) << 2) + (var2 + 10)) * 4) & 0xff
  add	DWORD PTR -8[rbp], 1    ; var2 += 1
  ```
  I wrote out the function in Python and computed the result
  ```Ruby
  def func1():
    var1 = 25
    var2 = 0
    
    while(var2 <= 9):
        var1 += (((var2 + 10) << 2) + (var2 + 10)) + ((((var2 + 10) << 2) + (var2 + 10)) * 4) 
        var1 = var1 & 0xff
        var2 += 1
    return var1 # var1 = 66
 ```
 `66` is returned to main and moving onto `func_2` I see all it does is return `207`
 ```
  mov	DWORD PTR -4[rbp], 207		; rbp-4 = 207
  mov	eax, DWORD PTR -4[rbp]		; eax = 207
  pop	rbp
  ret
 ```
 The last function is a little lengthier than the other two. Working my way through the first few sections, I see it is 
 just a bunch of conditional if-else statements comparing the two variables we obtained from `func_1` and `func_2`. After going
 through the loops we get to another while loop.
 ```
 .L14:
    mov	eax, DWORD PTR -36[rbp]		; eax = var1
    or	eax, DWORD PTR -40[rbp]		; eax = var1 || var2
    mov	DWORD PTR -12[rbp], eax		; var3 = eax
    mov	eax, DWORD PTR -36[rbp]		; eax = var1
    and	eax, DWORD PTR -40[rbp]		; eax = var1 & var2
    mov	DWORD PTR -16[rbp], eax		; var4 = eax
    mov	eax, DWORD PTR -36[rbp]		; eax = var1
    xor	eax, DWORD PTR -40[rbp]		; eax = var1 ^ var2
    mov	DWORD PTR -20[rbp], eax		; var5 = eax
    mov	DWORD PTR -4[rbp], 0		; var6 = 0
    mov	DWORD PTR -8[rbp], 0		; var7 = 0
    jmp	.L15
.L16:
    mov	eax, DWORD PTR -16[rbp]		; eax = var4
    sub	eax, DWORD PTR -8[rbp]		; eax = var4 - var7
    mov	edx, eax                        ; edx = eax
    mov	eax, DWORD PTR -12[rbp]		; eax = var3
    add	eax, edx                        ; eax = var3 + (var4 - var7)
    add	DWORD PTR -4[rbp], eax		; var6 += (var3 + (var4 - var7))
    add	DWORD PTR -8[rbp], 1            ; var7 += 1
.L15:
	mov	eax, DWORD PTR -8[rbp]		; eax = var7
	cmp	eax, DWORD PTR -20[rbp]		; cmp var7 var5
	jl	.L16
	mov	eax, DWORD PTR -4[rbp]		; eax = var6
.L11:
	pop	rbp
	ret
  ```
  It begins by creating five more variables and then jumps to `L15`. There we compare `var7` with `var5` and move into another loop.
  In `L16` we do some math operations to `var6` and increment `var7`. In Python this function would like this:
  ```Ruby
  def func3(x, y):
    var1 = x | y
    var2 = x & y
    var3 = x ^ y
    
    var4 = 0
    var5 = 0
    while(var5 < var3):
        var4 += var1 + (var2 - var5)
        var5 += 1
    return var4
 ```
 The final answer is the result returned from `func_3`. After computing, `28623` is the number returned and is the flag.
 ### Flag
 `28623`
 
