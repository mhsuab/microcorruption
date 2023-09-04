4464 <malloc>
4464:  0b12           push	r11
4466:  c293 0424      tst.b	&0x2404
446a:  0f24           jz	$+0x20 <malloc+0x26>        ; if (heap_initialized == 0) goto 448a
446c:  1e42 0024      mov	&0x2400, r14
4470:  8e4e 0000      mov	r14, 0x0(r14)
4474:  8e4e 0200      mov	r14, 0x2(r14)
4478:  1d42 0224      mov	&0x2402, r13        ; r13 = 0x2402
447c:  3d50 faff      add	#0xfffa, r13        ; r13 = 0x2402 + 6
4480:  0d5d           add	r13, r13            ; r13 = (0x2402 + 6) * 2
4482:  8e4d 0400      mov	r13, 0x4(r14)       ; r14->flag = r13
4486:  c243 0424      mov.b	#0x0, &0x2404       ; heap_initialized = arena->flag =  0
448a:  1b42 0024      mov	&0x2400, r11        ; r11 = arena
448e:  0e4b           mov	r11, r14            ; r14 = arena
4490:  1d4e 0400      mov	0x4(r14), r13
4494:  1db3           bit	#0x1, r13
4496:  2820           jnz	$+0x52 <malloc+0x84>    ; if (r13 & 0x1) goto 44e8
4498:  0c4d           mov	r13, r12
449a:  12c3           clrc
449c:  0c10           rrc	r12
449e:  0c9f           cmp	r15, r12
44a0:  2338           jl	$+0x48 <malloc+0x84>
44a2:  0b4f           mov	r15, r11
44a4:  3b50 0600      add	#0x6, r11
44a8:  0c9b           cmp	r11, r12
44aa:  042c           jc	$+0xa <malloc+0x50>
44ac:  1dd3           bis	#0x1, r13
44ae:  8e4d 0400      mov	r13, 0x4(r14)
44b2:  163c           jmp	$+0x2e <malloc+0x7c>
44b4:  0d4f           mov	r15, r13
44b6:  0d5d           add	r13, r13
44b8:  1dd3           bis	#0x1, r13
44ba:  8e4d 0400      mov	r13, 0x4(r14)
44be:  0d4e           mov	r14, r13
44c0:  3d50 0600      add	#0x6, r13
44c4:  0d5f           add	r15, r13
44c6:  8d4e 0000      mov	r14, 0x0(r13)
44ca:  9d4e 0200 0200 mov	0x2(r14), 0x2(r13)
44d0:  0c8f           sub	r15, r12
44d2:  3c50 faff      add	#0xfffa, r12
44d6:  0c5c           add	r12, r12
44d8:  8d4c 0400      mov	r12, 0x4(r13)
44dc:  8e4d 0200      mov	r13, 0x2(r14)
44e0:  0f4e           mov	r14, r15
44e2:  3f50 0600      add	#0x6, r15
44e6:  0e3c           jmp	$+0x1e <malloc+0xa0>
44e8:  0d4e           mov	r14, r13
44ea:  1e4e 0200      mov	0x2(r14), r14
44ee:  0e9d           cmp	r13, r14
44f0:  0228           jnc	$+0x6 <malloc+0x92>
44f2:  0e9b           cmp	r11, r14
44f4:  cd23           jnz	$-0x64 <malloc+0x2c>
44f6:  3f40 4a44      mov	#0x444a "Heap exausted; aborting.", r15
44fa:  b012 1a47      call	#0x471a <puts>
44fe:  3040 4044      br	#0x4440 <__stop_progExec__>
4502:  0f43           clr	r15
4504:  3b41           pop	r11
4506:  3041           ret
4508 <free> ; free(r15 = payload)
4508:  0b12           push	r11
450a:  3f50 faff      add	#0xfffa, r15            ; r15 = payload - 6 = ptr
450e:  1d4f 0400      mov	0x4(r15), r13           ; r13 = ptr->size
4512:  3df0 feff      and	#0xfffe, r13            ; r13 = size = ptr->size & 0xfffe
4516:  8f4d 0400      mov	r13, 0x4(r15)           ; ptr->size = size = r13
451a:  2e4f           mov	@r15, r14               ; r14 = ptr->bk = bk
451c:  1c4e 0400      mov	0x4(r14), r12           ; r12 = bk->size
4520:  1cb3           bit	#0x1, r12               ; if (bk->size & 0x1)
4522:  0d20           jnz	$+0x1c <free+0x36>      ; if not zero goto 453e
    4524:  3c50 0600      add	#0x6, r12               ; r12 = bk->size + 6
    4528:  0c5d           add	r13, r12                ; r12 = bk->size + 6 + size
    452a:  8e4c 0400      mov	r12, 0x4(r14)           ; bk->size = r12
    452e:  9e4f 0200 0200 mov	0x2(r15), 0x2(r14)      ; bk->fd = ptr->fd
    4534:  1d4f 0200      mov	0x2(r15), r13           ; r13 = fd = ptr->fd
    4538:  8d4e 0000      mov	r14, 0x0(r13)           ; fd->bk = bk
    453c:  2f4f           mov	@r15, r15               ; r15 = ptr = ptr->bk
453e:  1e4f 0200      mov	0x2(r15), r14           ; r14 = fd = ptr->fd
4542:  1d4e 0400      mov	0x4(r14), r13           ; r13 = fd->size
4546:  1db3           bit	#0x1, r13               ; if (fd->size & 0x1)
4548:  0b20           jnz	$+0x18 <free+0x58>      ; if not zero goto 4560
    454a:  1d5f 0400      add	0x4(r15), r13           ; r13 += ptr->size ~> r13 = fd->size + ptr->size
    454e:  3d50 0600      add	#0x6, r13               ; r13 += 6 ~> r13 = fd->size + ptr->size + 6
    4552:  8f4d 0400      mov	r13, 0x4(r15)           ; ptr->size = r13
    4556:  9f4e 0200 0200 mov	0x2(r14), 0x2(r15)      ; ptr->fd = fd->fd
    455c:  8e4f 0000      mov	r15, 0x0(r14)           ; fd->bk = ptr
4560:  3b41           pop	r11
4562:  3041           ret
463a <login>
463a:  0b12           push	r11
463c:  0a12           push	r10
463e:  3f40 1000      mov	#0x10, r15
4642:  b012 6444      call	#0x4464 <malloc>
4646:  0a4f           mov	r15, r10            ; r10 = malloc(0x10)
4648:  3f40 1000      mov	#0x10, r15
464c:  b012 6444      call	#0x4464 <malloc>
4650:  0b4f           mov	r15, r11            ; r11 = malloc(0x10)
4652:  3f40 9a45      mov	#0x459a "Enter your username and password to continue", r15
4656:  b012 1a47      call	#0x471a <puts>
465a:  3f40 c845      mov	#0x45c8 "Username >>", r15
465e:  b012 1a47      call	#0x471a <puts>
4662:  3e40 3000      mov	#0x30, r14
4666:  0f4a           mov	r10, r15
4668:  b012 0a47      call	#0x470a <getsn>     ; gets(r10, 0x30)
466c:  3f40 c845      mov	#0x45c8 "Username >>", r15
4670:  b012 1a47      call	#0x471a <puts>
4674:  3f40 d445      mov	#0x45d4 "(Remember: passwords are between 8 and 16 characters.)", r15
4678:  b012 1a47      call	#0x471a <puts>
467c:  3e40 3000      mov	#0x30, r14
4680:  0f4b           mov	r11, r15
4682:  b012 0a47      call	#0x470a <getsn>     ; gets(r11, 0x30)
4686:  0f4b           mov	r11, r15
4688:  b012 7045      call	#0x4570 <test_password_valid> ; test_password_valid(r11 = password)
468c:  0f93           tst	r15
468e:  0524           jz	$+0xc <login+0x60>  ; if (test_password_valid(password) == 0) goto 469a
4690:  b012 6445      call	#0x4564 <unlock_door>
4694:  3f40 0b46      mov	#0x460b "Access granted.", r15
4698:  023c           jmp	$+0x6 <login+0x64>  ; goto 469e
469a:  3f40 1b46      mov	#0x461b "That password is not correct.", r15
469e:  b012 1a47      call	#0x471a <puts>
46a2:  0f4b           mov	r11, r15
46a4:  b012 0845      call	#0x4508 <free>      ; free(r11 = password)
46a8:  0f4a           mov	r10, r15
46aa:  b012 0845      call	#0x4508 <free>      ; free(r10 = username)
46ae:  3a41           pop	r10
46b0:  3b41           pop	r11
46b2:  3041           ret
4564 <unlock_door>
4564:  3012 7f00      push	#0x7f
4568:  b012 b646      call	#0x46b6 <INT>
456c:  2153           incd	sp
456e:  3041           ret
