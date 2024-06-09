# Lagos
> source code [here](./dump.asm)  
> **Vulnerability**: stack buffer overflow

## Analysis
pseudo code for `main`, assembly code [here](./dump.asm)
```c
void login() {
  // push r11
  // add #0xfff0, sp ; sp -= 0x10
  void *input_buffer = 0x2400;
  ...
  gets(input_buffer, 0x200);     // gets input
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

Stack size is 0x10 and the program takes in **0x200 bytes**, which will be copied to stack under certain condition. That is, ***exist stack buffer overflow*** vulnerability.
However, the program will only copy **alphanumerical** (0-9a-zA-Z) to the stack so the exploit need to be carefully crafted.

<details>
<summary>Observation not used...</summary>

Suppose the all the instruction remain unchanged, the program has the ability to modify the memory from `0x43ed` to `0x45ed`. However, the function `<logic>` starts from `0x455e` and the modification loop starts from `0x45a0`. Therefore, the program may behave differently if the modification loop is modified.

</details>

## Exploit
Detail [here](./solve.py).
