# Montevideo
> **Vulnerability**: stack buffer overflow  
> similar to [Whitehorse](../Whitehorse/readme.md)

## Analysis
### What is different from [Whitehorse](../Whitehorse)?

From **pseudo c code**
<table>
<tr>
<td align="center"><code>Whitehorse</code></td>
<td align="center"><code>Montevideo</code></td>
</tr>
<tr>
<td>

```c
void login() {
    puts("Enter the password to continue.");
    puts("Remember: passwords are between 8 and 16 characters.");
    gets(sp, 0x30);
    if (conditional_unlock_door(sp)) {
        puts("Access granted.");
    } else {
        puts("That password is not correct.");
    }
}
```

</td>
<td>

```c
void login() {
    puts("Enter the password to continue.");
    puts("Remember: passwords are between 8 and 16 characters.");
    gets(0x2400, 0x30);
    strcpy(sp, 0x2400);
    memset(0x2400, 0, 0x64);
    if (conditional_unlock_door(sp)) {
        puts("Access granted.");
    } else {
        puts("That password is not correct.");
    }
}
```

</td>
</tr>
</table>


The main difference is that `Montevideo` uses `strcpy` and `memset` to copy the user input to the stack, while `Whitehorse` directly reads the user input to the stack.

That is, `Montevideo` will not be able to have `null` byte in the middle when copying to the stack (because `strcpy` will stop copying when it sees `null`).

For example, if the user input is `[hex] 4141 4141 0042 4242`, then the stack will end up like this:
|                 |     `Whitehorse`      |     `Montevideo`      |
| :-------------: | :-------------------: | :-------------------: |
| buffer on stack | `4141 4141 0042 4242` | `4141 4141 00?? ????` |
> `??` means the original value on the stack


However, my exploit for `Whitehorse` do not use `null` in the middle, so it is not a problem. Therefore, the exploit for `Whitehorse` can be used for `Montevideo` as well.

## Exploit
Same as [Whitehorse](../Whitehorse/readme.md)

<!-- solution: {'level_id': 8, 'input': '4141414141414141414141414141414160447f;'} -->
