# Heap

> A brief note/explanation of how microcorruption's heap work  
> related source code @ [heap.asm](./heap.asm)

## Structure

### Chunk

```c
typedef struct chunk {
  struct chunk *bk;
  struct chunk *fd;
  union {
    int16_t size;
    // specifies if the current chunk is allocated or not
    unsigned allocated : 1;
  };
  int16_t payload[0];
} chunk_t;
```

### Heap State

> heap state @ 0x2400 initialize as folllowing

```c
typedef struct heap_state {
  chunk_t *top_chunk;
  int16_t size;
  bool top_chunk_need_init;
} heap_state_t;

// 2400: 0050 0080 0100 0000 0000 0000 0000 0000
heap_state_t HEAP_STATE = {
  .top_chunk = 0x5000,
  .size = 0x8000,
  .top_chunk_need_init = true,
};
```

## Functions

### `malloc` @ [here](./heap.asm#1)

```c
void* malloc(int16_t size) {
  if (HEAP_STATE.top_chunk_need_init) {
    (HEAP_STATE.top_chunk)->bk = (HEAP_STATE.top_chunk)->fd =
        HEAP_STATE.top_chunk;
    (HEAP_STATE.top_chunk)->size = 2 * (HEAP_STATE.size - sizeof(chunk_t));
    HEAP_STATE.top_chunk_need_init = false;
  }

  chunk_t *chunk = HEAP_STATE.top_chunk;

  int16_t slot_count;
  while (true) {
    slot_count = ((chunk->size >> 1) & 0x7fff);
    if (chunk->allocated || size < slot_count) {
      if (chunk > chunk->fd || HEAP_STATE.top_chunk == chunk->fd) {
        // exit program
        puts("Heap exausted; aborting.");
        __asm__("br #__stop_progExec__;");
      }
      chunk = chunk->fd;
    } else {
      break;
    }
  }

  if ((size + sizeof(chunk_t)) <= slot_count) {
    // split block
    chunk->size = (2 * size) | 1;
    chunk_t *next = chunk + sizeof(chunk_t) + size;
    next->bk = chunk;
    next->fd = chunk->fd;
    next->size = 4 * slot_count - 3 * (size + sizeof(chunk_t));
    chunk->fd = next;
  } else {
    chunk->size |= 1;
  }

  return chunk->payload;
```

### `free` @ [here](./heap.asm#59)

```c
void free(void* payload) {
  struct chunk* ptr = (struct chunk*)((char*)payload - 6);
  ptr->size &= 0xfffe;  // set `ptr->allocated = 0`
  if (!ptr->bk->allocated) {
    // coalesce bk
    ptr->bk->size += (ptr->size + 6);
    ptr->bk->fd = ptr->fd;
    ptr->fd->bk = ptr->bk;
    ptr = ptr->bk;
  }
  if (!ptr->fd->allocated) {
    // coalesce fd
    ptr->size += (fd->size + 6);
    ptr->fd = ptr->fd->fd;
    ptr->fd->bk = ptr;
  }
}
```

### `walk` @ [here](./../18_Chernobyl/dump.asm#196)

```c
void walk(chunk_t *chunk) {
  puts("\n\n");
  do {
    if (chunk->allocated) {
      printf("@%x [alloc] [p %x] [n %x] [s %x]\n", chunk, chunk->bk, chunk->fd, chunk->size);
      printf(" {%x} [ ", &chunk->payload);
      for (int i = 0; i < (chunk->size >> 2); ++i) { // rrc chunk->size; rra chunk->size; so might not be (chunk->size >> 2)
        printf("%x ", chunk->payload[i]);
      }
      putchar(']');
      putchar('\n');
    } else {
      printf("@%x [freed] [p %x] [n %x] [s %x]\n", chunk, chunk->bk, chunk->fd, chunk->size);
    }
  } while (chunk != HEAP_STATE.top_chunk);
}
```
