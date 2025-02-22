# Santa Cruz
> partial source code is [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow

Program will ask for a username and password. If the password is correct, it will unlock the door.

## Analysis
For both username and password, it reads input as of the following pseudo code:
```c
gets(0x2404, 0x63);
strcpy(buffer, 0x2404);
// buffer differ for username and password
```

username will be copied to `sp + 2` and password will be copied to `sp + 21`.
Therefore, from `username`'s point of view, `password` is at `username[19]`.

### Vulnerability
Both username and password are copied to the buffer on the stack and can both read in maximum 0x63 bytes. However, the stack size is only 0x28 bytes (`4558:  3150 d8ff      add	#0xffd8, sp`). Therefore, there is a **stack buffer overflow**.

Therefore, it should be possible to overwrite the return address of the function `<login>`.

### Conditions
> Detailed of the conditions can be found in the [source code](./dump.asm), the comments should be sufficient.
1. `password length` vs `username[18]`  
    `username[18]` holds the lowerbound of the password length.
2. `password length` vs `username[17]`  
    `username[17]` holds the upperbound of the password length.
3. `password[17]` vs `null`  
    `password[17]` needs to be `null`.

All of the above conditions need to be satisfied or else the program will stop immediately.

### By-passing the conditions
Since both inputs use `strcpy` to copy to the stack, it is not possible to have `null` byte in the middle of the input. Therefore, the password be less or equal to 17 bytes. That is, cannot use the password to overwrite the return address of the function `<login>`.

Therefore, use the username to overwrite the return address of the function `<login>`. At the same time, this will also overwrite the buffer to which the password is copied. That is, the password needs to be **exactly 17 bytes** so that the `null` byte will be copied to `password[17]`. Otherwise, if the password is shorter, the `null` byte will not be copied to `password[17]` by `strcpy` and will leave it with the value that copied to it by `username`.

*Restriction for condition 3: `password` needs to be exactly 17 bytes.* 

For condition 1 and 2, set the `username[18]` to 0x11 and `username[17]` to `0x7f` and `0x1` respectively. Then, the password can be any length between 0x1 and 0x7f.

### Stack Layout
**return address** of `<login>` is at `sp + 44` which is at `username + 42`.
Therefore, the 43 and 44 bytes of the username should be `0x444a` in little endian so that `<unlock_door>` will be called when `<login>` returns.

## Exploit
| username                                                                                                                                                                                            | password              |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------- |
| (0x11 bytes of padding) + 1 byte **lowerbound** for password + 1 byte **upperbound** for password + 0x17 bytes of padding + 2 bytes of address to function `unlock_door`, `0x444a` in little endian | 0x11 bytes of padding |

<!-- solution: {'level_id': 10,  'input': '4141414141414141414141414141414141017f41414141414141414141414141414141414141414141414a44;6161616161616161616161616161616161;'} -->
