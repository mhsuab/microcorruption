<malloc>
  0b12           push	r11
  c293 0424      tst.b	&0x2404
  0f24           jz	$+0x20 <malloc+0x26>
  1e42 0024      mov	&0x2400, r14
  8e4e 0000      mov	r14, 0x0(r14)
  8e4e 0200      mov	r14, 0x2(r14)
  1d42 0224      mov	&0x2402, r13
  3d50 faff      add	#0xfffa, r13
  0d5d           add	r13, r13
  8e4d 0400      mov	r13, 0x4(r14)
  c243 0424      mov.b	#0x0, &0x2404
  1b42 0024      mov	&0x2400, r11
  0e4b           mov	r11, r14
  1d4e 0400      mov	0x4(r14), r13
  1db3           bit	#0x1, r13
  2820           jnz	$+0x52 <malloc+0x84>
  0c4d           mov	r13, r12
  12c3           clrc
  0c10           rrc	r12
  0c9f           cmp	r15, r12
  2338           jl	$+0x48 <malloc+0x84>
  0b4f           mov	r15, r11
  3b50 0600      add	#0x6, r11
  0c9b           cmp	r11, r12
  042c           jc	$+0xa <malloc+0x50>
  1dd3           bis	#0x1, r13
  8e4d 0400      mov	r13, 0x4(r14)
  163c           jmp	$+0x2e <malloc+0x7c>
  0d4f           mov	r15, r13
  0d5d           add	r13, r13
  1dd3           bis	#0x1, r13
  8e4d 0400      mov	r13, 0x4(r14)
  0d4e           mov	r14, r13
  3d50 0600      add	#0x6, r13
  0d5f           add	r15, r13
  8d4e 0000      mov	r14, 0x0(r13)
  9d4e 0200 0200 mov	0x2(r14), 0x2(r13)
  0c8f           sub	r15, r12
  3c50 faff      add	#0xfffa, r12
  0c5c           add	r12, r12
  8d4c 0400      mov	r12, 0x4(r13)
  8e4d 0200      mov	r13, 0x2(r14)
  0f4e           mov	r14, r15
  3f50 0600      add	#0x6, r15
  0e3c           jmp	$+0x1e <malloc+0xa0>
  0d4e           mov	r14, r13
  1e4e 0200      mov	0x2(r14), r14
  0e9d           cmp	r13, r14
  0228           jnc	$+0x6 <malloc+0x92>
  0e9b           cmp	r11, r14
  cd23           jnz	$-0x64 <malloc+0x2c>
  3f40 5e46      mov	"Heap exausted; aborting.\0", r15
  b012 504d      call	<puts>
  3040 3e44      br	<__stop_progExec__>
  0f43           clr	r15
  3b41           pop	r11
  3041           ret
<free>
  0b12           push	r11
  3f50 faff      add	#0xfffa, r15
  1d4f 0400      mov	0x4(r15), r13
  3df0 feff      and	#0xfffe, r13
  8f4d 0400      mov	r13, 0x4(r15)
  2e4f           mov	@r15, r14
  1c4e 0400      mov	0x4(r14), r12
  1cb3           bit	#0x1, r12
  0d20           jnz	$+0x1c <free+0x36>
  3c50 0600      add	#0x6, r12
  0c5d           add	r13, r12
  8e4c 0400      mov	r12, 0x4(r14)
  9e4f 0200 0200 mov	0x2(r15), 0x2(r14)
  1d4f 0200      mov	0x2(r15), r13
  8d4e 0000      mov	r14, 0x0(r13)
  2f4f           mov	@r15, r15
  1e4f 0200      mov	0x2(r15), r14
  1d4e 0400      mov	0x4(r14), r13
  1db3           bit	#0x1, r13
  0b20           jnz	$+0x18 <free+0x58>
  1d5f 0400      add	0x4(r15), r13
  3d50 0600      add	#0x6, r13
  8f4d 0400      mov	r13, 0x4(r15)
  9f4e 0200 0200 mov	0x2(r14), 0x2(r15)
  8e4f 0000      mov	r15, 0x0(r14)
  3b41           pop	r11
  3041           ret
