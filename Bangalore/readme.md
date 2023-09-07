# Bangalore
> source code [here](./dump.asm)

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



## Exploit
