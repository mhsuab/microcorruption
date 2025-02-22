#include <stdint.h>
#include <stdio.h>

void mark_page_executable(int page) {
    printf("x:\t%d\t\t0x%x\n", page, page * 256);
}

void mark_page_writable(int page) {
    printf("w:\t%d\t\t0x%x\n", page, page * 256);
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
    printf("rwx\tpage\taddress\n");
    set_up_protection();
    return 0;
}
