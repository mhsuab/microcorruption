#include <stdint.h>
#include <stdio.h>

void mark_page_executable(int page) {
    printf("x: 0x%x\n", page * 256);
}

void mark_page_writable(int page) {
    printf("w: 0x%x\n", page * 256);
}

void set_up_protection() {
    mark_page_executable(0);
    int i = 1;
    for (; i < 0x44; i++) {
        mark_page_writable(i);
    }
    for (; i < 0x100; i++) {
        mark_page_executable(i);
    }
}

int main() {
    set_up_protection();
    return 0;
}
