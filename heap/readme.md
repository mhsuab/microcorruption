# Heap

> A brief note/explanation of how microcorruption's heap work  
> related source code @ [heap.asm](./heap.asm)

## Functions

### `malloc` @ [here](./heap.asm#1)

```c
void* malloc(int16_t size) {
  if (HEAP_STATE.is_top_chunk_not_set) {
    (HEAP_STATE.top_chunk)->bk = (HEAP_STATE.top_chunk)->fd =
        HEAP_STATE.top_chunk;
    (HEAP_STATE.top_chunk)->size = 2 * (HEAP_STATE.size - sizeof(chunk_t));
    HEAP_STATE.is_top_chunk_not_set = false;
  }

  chunk_t *chunk = HEAP_STATE.top_chunk;

  int16_t asdf;
  while (true) {
    asdf = ((chunk->size >> 1) & 0x7fff);
    if (chunk->allocated || size < asdf) {
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

  if ((size + sizeof(chunk_t)) <= asdf) {
    // split block
    chunk->size = (2 * size) | 1;
    chunk_t *next = chunk + sizeof(chunk_t) + size;
    next->bk = chunk;
    next->fd = chunk->fd;
    asdf -= (size + 6);
    asdf = 2 * asdf;
    next->size = 2 * (asdf - size - sizeof(chunk_t));
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
  char payload[0];
} chunk_t;
```

### Heap State

> heap state @ 0x2400 initialize as folllowing

```c
typedef struct heap_state {
  chunk_t *top_chunk;
  int16_t size;
  bool is_top_chunk_not_set;
} heap_state_t;

heap_state_t HEAP_STATE = {
  .top_chunk = 0x5000,
  .size = 0x8000,
  .is_top_chunk_not_set = true,
};
```
