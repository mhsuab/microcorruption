# Lagos
> source code [here](./dump.asm)  
> **Vulnerability**: 

## Analysis
pseudo code for `main`, assembly code [here](./dump.asm)
```c
void login() {
    void *input_buffer = 0x2400;
    ...
    gets(input_buffer, 0x200);     // gets password
    int index = 0;
    // start from instrcution, 45a0
    while (1) {
        uint8_t c = input_buffer[index];
        ++index;
        if ((c - 0x30) > 9 || (c - 0x41) > 25 || (c - 0x61) > 25) {
            break;
        }
        sp[index] = c;              // sp = 0x43ec
    }
    memset(input_buffer, 0, 0x200);
    if (conditional_unlock_door(sp)) {
        puts ("Access granted.");
    } else {
        puts ("That password is not correct.");
    }
}
```

Suppose the all the instruction remain unchanged, the program has the ability to modify the memory from `0x43ed` to `0x45ed`. However, the function `<logic>` starts from `0x455e` and the modification loop starts from `0x45a0`. Therefore, the program may behave differently if the modification loop is modified.

---
return address @ sp + 0x12

sp @ 0x43ec

start overwrite @ sp + 1

only 0-9a-zA-Z will be copied


read 0x200 characters from input