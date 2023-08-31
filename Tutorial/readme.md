# Tutorial
> Follow the tutorial to get familiar with the interface and the assembly language.

The program asks for password and unlocks the door if the password is correct.

Check the password with function, `<check_password> @ 4484` and it takes the password as an argument.

```asm
4484 <check_password>
4484:  6e4f           mov.b	@r15, r14
4486:  1f53           inc	r15
4488:  1c53           inc	r12
448a:  0e93           tst	r14
448c:  fb23           jnz	$-0x8 <check_password+0x0>
448e:  3c90 0900      cmp	#0x9, r12
4492:  0224           jz	$+0x6 <check_password+0x14>
4494:  0f43           clr	r15
4496:  3041           ret
4498:  1f43           mov	#0x1, r15
449a:  3041           ret
```

From the [ABI](https://www.ti.com/lit/an/slaa534a/slaa534a.pdf), the first argument and the return value are both in `r15`.

Manually decompile the assembly code to C code.
- **pseudo c code**
    ```c
    int check_password(char *password) {
        int len = 0, idx = 0;
        do {
            len++;
        } while(password[idx++] != 0);
        if (len != 9) {
            return 0;
        }
        return 1;
    }
    ```

The function only check that the first `null` byte is at the 9th byte of the password.
That is, any input with **8 characters** and a `null` byte at the end, added automatically, will unlock the door.

<!-- solution: {'level_id': 1, 'input': '4141414141414141;'} -->
