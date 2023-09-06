# Johannesburg
> **Vulnerability**: stack buffer overflow  
> **Mitigation**: stack canary  
> similar to [Montevideo](../Montevideo/readme.md)  

## Analysis
### What is different from [Montevideo](../Montevideo)?
`Johannesburg` introduces **stack canary** to prevent stack buffer overflow.

|              | `Montevideo` | `Johannesburg` |
| :----------: | :----------: | :------------: |
|  stack size  |  0x10 bytes  |   0x12 bytes   |
| stack canary |      ✘       |       ✓        |

### How does **stack canary** work?
```asm
452c <login>
452c:  3150 eeff      add	#0xffee, sp
4530:  f140 2000 1100 mov.b	#0x20, 0x11(sp)
...
4578:  f190 2000 1100 cmp.b	#0x20, 0x11(sp)
457e:  0624           jz	$+0xe <login+0x60>
4580:  3f40 ff44      mov	#0x44ff "Invalid Password Length: password too long.", r15
4584:  b012 f845      call	#0x45f8 <puts>
4588:  3040 3c44      br	#0x443c <__stop_progExec__>
458c:  3150 1200      add	#0x12, sp
4590:  3041           ret
```
`sp + 11` is the **stack canary** and it is compared with `0x20` at `4578`. If the value is not `0x20`, then it will return from the function `<login>`.

### Stack Layout
|             | `input` start from the top of the stack |
| :---------: | :-------------------------------------: |
|    `sp`     |                (padding)                |
| `sp + 0x2`  |                (padding)                |
| `sp + 0x4`  |                (padding)                |
| `sp + 0x6`  |                (padding)                |
| `sp + 0x8`  |                (padding)                |
| `sp + 0xa`  |                (padding)                |
| `sp + 0xc`  |                (padding)                |
| `sp + 0xe`  |                (padding)                |
| `sp + 0x10` |            (padding) + 0x20             |
| `sp + 0x12` |          **(return address)**           |
| `sp + 0x14` |                 `0x7f`                  |
| `sp + 0x14` |                (garbage)                |

The return address can be overwritten with any address that `call <INT>` and `0x7f` needs to be on the stack s.t. it can trigger the unlock with `INT 0x7f`.

## Exploit
> more details in [Montevideo](../Montevideo/readme.md)

0x11 bytes of padding + 0x20 (stack canary) + 0x2 bytes of address that `call <INT>`, `0x446c` in little endian + 0x2 bytes of `0x7f`

<!-- solution: {'level_id': 9, 'input': '4141414141414141414141414141414141206c447f00;'} -->
