4446 <conditional_unlock_door>
4446:  0412           push	r4
4448:  0441           mov	sp, r4
444a:  2453           incd	r4
444c:  2183           decd	sp
444e:  c443 fcff      mov.b	#0x0, -0x4(r4)
4452:  3e40 fcff      mov	#0xfffc, r14
4456:  0e54           add	r4, r14
4458:  0e12           push	r14
445a:  0f12           push	r15
445c:  3012 7e00      push	#0x7e
4460:  b012 3245      call	#0x4532 <INT>
4464:  5f44 fcff      mov.b	-0x4(r4), r15
4468:  8f11           sxt	r15
446a:  3152           add	#0x8, sp
446c:  3441           pop	r4
446e:  3041           ret

44f4 <login>
44f4:  3150 f0ff      add	#0xfff0, sp
44f8:  3f40 7044      mov	#0x4470 "Enter the password to continue.", r15
44fc:  b012 9645      call	#0x4596 <puts>
4500:  3f40 9044      mov	#0x4490 "Remember: passwords are between 8 and 16 characters.", r15
4504:  b012 9645      call	#0x4596 <puts>
4508:  3e40 3000      mov	#0x30, r14
450c:  0f41           mov	sp, r15
450e:  b012 8645      call	#0x4586 <getsn>
4512:  0f41           mov	sp, r15
4514:  b012 4644      call	#0x4446 <conditional_unlock_door>
4518:  0f93           tst	r15
451a:  0324           jz	$+0x8 <login+0x2e>
451c:  3f40 c544      mov	#0x44c5 "Access granted.", r15
4520:  023c           jmp	$+0x6 <login+0x32>
4522:  3f40 d544      mov	#0x44d5 "That password is not correct.", r15
4526:  b012 9645      call	#0x4596 <puts>
452a:  3150 1000      add	#0x10, sp
452e:  3041           ret
