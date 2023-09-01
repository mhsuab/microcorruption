# Addis Ababa
> partial source code is [here](./dump.asm)  
> **Vulnerability**: Format String Vulnerability

## Analysis
### How it takes input for `password`?
(psudo c code for getting input for `password`)
```c
gets(0x2400, 0x13);
strcpy(sp + 2, 0x2400);
```

Therefore, the `password` without the `null` byte will be copied to `sp + 2`.  
That is, the payload entered by the user shall not contain `null` byte in the middle.

### How it checks whether to unlock the door?
The program use the return value from the function `test_password_valid(password)` and save it to `sp + 0`. Then, it will check if the return value is `0` or not. If it is `0`, then it will **not** unlock the door.

### Vulnerability
The program uses `printf` to print the user input at `447c:  b012 c845      call	#0x45c8 <printf>`. Therefore, it is possible to use **Format String Vulnerability** to overwrite the return address of the function `<login>`.

Check details for how exactly the `printf` works on Lockitail [here](https://microcorruption.com/public/manual.pdf).
For `%n`, it will save the number of characters printed thus far.

Combine with the methodlogy for [check to unlock](#how-it-checks-whether-to-unlock-the-door) and `printf(password)` called after `test_password_valid(password)`, it is possible to overwrite the value of `sp + 0` to any value not equal to `0` to unlock the door.

Since the `printf` gets arguments from the stack and the user input for `password` is copied to `sp + 2`, analyze the stack. Also, before the `printf` is called, the pointer for `password` is pushed to the stack (`447a:  0b12           push	r11`) and the stack pointer will be subtracted by 2.  
Therefore, the stack layout is as follows:

| address | stack | `printf` arguments |                                       data                                       |
| :-----: | :---: | :----------------: | :------------------------------------------------------------------------------: |
|   ...   |  ...  |         -          |                                       ...                                        |
|  3604   |  sp   |    1st argument    |                              pointer to `password`                               |
|  3606   | sp+2  |    2nd argument    | (value set by the return value from `test_password_valid` and used for checking) |
|  3608   | sp+4  |    3rd argument    |                                   password[0]                                    |
|  360a   | sp+6  |    4th argument    |                                   password[2]                                    |
|  360c   | sp+8  |    5th argument    |                                   password[4]                                    |
|   ...   |  ...  |        ...         |                                       ...                                        |

Therefore, the input for `password` should be as follows:
| `password`  | content  | reasoning                                                                   |
| :---------: | :------: | :-------------------------------------------------------------------------- |
| password[0] | `0x3606` | address of the value used for checking, on the 3rd argument                 |
| password[2] |   '%x'   | used it to print out the 2nd argument, since we do not have control over it |
| password[4] |   '%n'   | use it to write value to the address of **3rd argument**, which is `0x3606` |
|     ...     |   ...    |                                                                             |

> **Why needed an additional '%x'?**  
> because we have no control over the 2nd argument and cannot make it to be `0x3606`. Therefore, we need one conversion specifier to print out the 2nd argument and follow with '%n' to write to the address of the 3rd argument.

## Exploit
2 bytes of address, `0x3606` in little endian + `%x` + `%n`

<!-- solution: {'level_id': 12, 'input': '06362578256e;'} -->