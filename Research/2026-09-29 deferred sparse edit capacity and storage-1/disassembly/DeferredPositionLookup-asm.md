## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.Scalar()
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        short 0000000000001BAC
       cmp       [rdx+8],r8d
       jb        short 0000000000001BB8
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       test      r10d,r10d
       jle       short 0000000000001BA6
       add       rcx,10
       jmp       short 0000000000001B80
M00_L01:
       mov       r9d,r11d
M00_L02:
       add       eax,r9d
       add       rcx,2
       dec       r10d
       je        short 0000000000001BA6
M00_L03:
       movzx     r9d,word ptr [rcx]
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000001B9E
M00_L04:
       movzx     ebx,word ptr [rdx+r11*2]
       cmp       ebx,r9d
       je        short 0000000000001B71
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000001B8C
M00_L05:
       mov       r9d,0FFFFFFFF
       jmp       short 0000000000001B74
M00_L06:
       add       rsp,20
       pop       rbx
       ret
M00_L07:
       test      r8d,r8d
       jne       short 0000000000001BB8
       xor       edx,edx
       xor       r8d,r8d
       jmp       short 0000000000001B5E
M00_L08:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 127
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.SpanIndexOf()
       push      r14
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,20
       xor       ebx,ebx
       mov       rsi,[rcx+8]
       mov       edi,[rcx+18]
       test      rsi,rsi
       je        short 000000000000067D
       cmp       [rsi+8],edi
       jb        short 0000000000000687
       add       rsi,10
M00_L00:
       mov       rbp,[rcx+10]
       mov       r14d,[rbp+8]
       test      r14d,r14d
       jle       short 0000000000000662
       add       rbp,10
M00_L01:
       movzx     edx,word ptr [rbp]
       movsx     rdx,dx
       movzx     ecx,dx
       dec       ecx
       cmp       ecx,0FE
       jae       short 000000000000066F
       movsx     rdx,dx
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [0C2E8]; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
M00_L02:
       add       ebx,eax
       add       rbp,2
       dec       r14d
       jne       short 0000000000000632
M00_L03:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M00_L04:
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [60E8]; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       jmp       short 0000000000000657
M00_L05:
       test      edi,edi
       jne       short 0000000000000687
       xor       esi,esi
       xor       edi,edi
       jmp       short 0000000000000621
M00_L06:
       call      qword ptr [7B70]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 142
```
```assembly
; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       push      r14
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,50
       vmovaps   [rsp+40],xmm6
       vmovaps   [rsp+30],xmm7
       vmovaps   [rsp+20],xmm8
       mov       rsi,rcx
       mov       edi,edx
       mov       ebx,r8d
       cmp       ebx,8
       jl        near ptr 000000000000D4FC
       mov       rbp,rsi
       cmp       ebx,10
       jle       near ptr 000000000000D479
       vmovd     xmm6,edi
       vpbroadcastb ymm6,xmm6
       cmp       ebx,20
       jle       near ptr 000000000000D3B4
       lea       ecx,[rbx+0FFE0]
       movsxd    rcx,ecx
       lea       rdi,[rbp+rcx*2]
       vmovups   ymm0,[rsi]
       vpackuswb ymm0,ymm0,[rsi+20]
       vpcmpeqb  ymm7,ymm0,ymm6
       vptest    ymm7,ymm7
       jne       short 000000000000D363
M01_L00:
       add       rbp,40
       cmp       rbp,rdi
       jae       short 000000000000D399
       mov       rcx,7FF83A4D2578
       vextractf128 xmm8,ymm6,1
       call      0000000000008420
       vmovups   ymm0,[rbp]
       vpackuswb ymm0,ymm0,[rbp+20]
       vinsertf128 ymm6,ymm6,xmm8,1
       vpcmpeqb  ymm7,ymm0,ymm6
       vptest    ymm7,ymm7
       je        short 000000000000D32A
M01_L01:
       mov       rcx,7FF83A4D256C
       vextractf128 xmm8,ymm7,1
       call      0000000000008420
       mov       rax,rbp
       sub       rax,rsi
       shr       rax,1
       vinsertf128 ymm7,ymm7,xmm8,1
       vpermq    ymm0,ymm7,0D8
       vpmovmskb ecx,ymm0
       tzcnt     ecx,ecx
       add       eax,ecx
       jmp       short 000000000000D3FC
M01_L02:
       mov       rcx,7FF83A4D2574
       vextractf128 xmm8,ymm6,1
       call      0000000000008420
       vinsertf128 ymm6,ymm6,xmm8,1
M01_L03:
       add       ebx,0FFFFFFF0
       movsxd    rcx,ebx
       lea       rbx,[rsi+rcx*2]
       cmp       rbp,rbx
       ja        short 000000000000D41C
       mov       rdi,rbp
M01_L04:
       vmovups   ymm0,[rdi]
       vpackuswb ymm0,ymm0,[rbx]
       vpcmpeqb  ymm6,ymm0,ymm6
       vptest    ymm6,ymm6
       jne       short 000000000000D43C
       mov       rcx,7FF83A4D2584
       call      0000000000008420
M01_L05:
       mov       rcx,7FF83A4D2594
       call      0000000000008420
       mov       eax,0FFFFFFFF
M01_L06:
       vzeroupper
       vmovaps   xmm6,[rsp+40]
       vmovaps   xmm7,[rsp+30]
       vmovaps   xmm8,[rsp+20]
       add       rsp,50
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M01_L07:
       mov       rcx,7FF83A4D257C
       vextractf128 xmm8,ymm6,1
       call      0000000000008420
       mov       rdi,rbx
       vinsertf128 ymm6,ymm6,xmm8,1
       jmp       short 000000000000D3C6
M01_L08:
       mov       rcx,7FF83A4D2580
       vextractf128 xmm7,ymm6,1
       call      0000000000008420
       vinsertf128 ymm6,ymm6,xmm7,1
       vpermq    ymm0,ymm6,0D8
       vpmovmskb ecx,ymm0
       tzcnt     ecx,ecx
       cmp       ecx,10
       jge       near ptr 000000000000D650
M01_L09:
       sub       rdi,rsi
       shr       rdi,1
       lea       eax,[rdi+rcx]
       jmp       short 000000000000D3FC
M01_L10:
       mov       rcx,7FF83A4D2570
       call      0000000000008420
       vmovd     xmm6,edi
       vpbroadcastb xmm6,xmm6
       lea       ecx,[rbx+0FFF8]
       movsxd    rcx,ecx
       lea       rbx,[rsi+rcx*2]
       cmp       rsi,rbx
       ja        near ptr 000000000000D65B
       mov       rdi,rsi
M01_L11:
       vmovups   xmm0,[rdi]
       vpackuswb xmm0,xmm0,[rbx]
       vpcmpeqb  xmm6,xmm0,xmm6
       vptest    xmm6,xmm6
       jne       short 000000000000D4CE
       mov       rcx,7FF83A4D2590
       call      0000000000008420
       jmp       near ptr 000000000000D3E8
M01_L12:
       mov       rcx,7FF83A4D258C
       call      0000000000008420
       vpmovmskb ecx,xmm6
       tzcnt     ecx,ecx
       cmp       ecx,8
       jge       near ptr 000000000000D672
M01_L13:
       sub       rdi,rsi
       shr       rdi,1
       lea       eax,[rdi+rcx]
       jmp       near ptr 000000000000D3FC
M01_L14:
       xor       ebp,ebp
       cmp       ebx,4
       jl        short 000000000000D555
       add       ebx,0FFFFFFFC
       movsx     rcx,word ptr [rsi]
       movsx     r14,di
       cmp       ecx,r14d
       je        near ptr 000000000000D59E
       movsx     rcx,word ptr [rsi+2]
       cmp       ecx,r14d
       je        near ptr 000000000000D5CF
       movsx     rcx,word ptr [rsi+4]
       cmp       ecx,r14d
       je        near ptr 000000000000D603
       movsx     rcx,word ptr [rsi+6]
       cmp       ecx,r14d
       je        near ptr 000000000000D637
       mov       rcx,7FF83A4D2560
       call      0000000000008420
       mov       ebp,4
M01_L15:
       test      ebx,ebx
       jle       near ptr 000000000000D3E8
       movsx     r14,di
M01_L16:
       dec       ebx
       movsx     rcx,word ptr [rsi+rbp*2]
       cmp       ecx,r14d
       je        short 000000000000D588
       mov       rcx,7FF83A4D2568
       call      0000000000008420
       inc       rbp
       test      ebx,ebx
       jg        short 000000000000D561
       jmp       near ptr 000000000000D3E8
M01_L17:
       mov       rcx,7FF83A4D2564
       call      0000000000008420
       mov       eax,ebp
       jmp       near ptr 000000000000D3FC
M01_L18:
       mov       rcx,7FF83A4D2550
       call      0000000000008420
       xor       eax,eax
       vzeroupper
       vmovaps   xmm6,[rsp+40]
       vmovaps   xmm7,[rsp+30]
       vmovaps   xmm8,[rsp+20]
       add       rsp,50
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M01_L19:
       mov       rcx,7FF83A4D2554
       call      0000000000008420
       mov       eax,1
       vzeroupper
       vmovaps   xmm6,[rsp+40]
       vmovaps   xmm7,[rsp+30]
       vmovaps   xmm8,[rsp+20]
       add       rsp,50
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M01_L20:
       mov       rcx,7FF83A4D2558
       call      0000000000008420
       mov       eax,2
       vzeroupper
       vmovaps   xmm6,[rsp+40]
       vmovaps   xmm7,[rsp+30]
       vmovaps   xmm8,[rsp+20]
       add       rsp,50
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M01_L21:
       mov       rcx,7FF83A4D255C
       call      0000000000008420
       mov       eax,3
       jmp       near ptr 000000000000D3FC
M01_L22:
       mov       rdi,rbx
       add       ecx,0FFFFFFF0
       jmp       near ptr 000000000000D46E
M01_L23:
       mov       rcx,7FF83A4D2588
       call      0000000000008420
       mov       rdi,rbx
       jmp       near ptr 000000000000D4A7
M01_L24:
       mov       rdi,rbx
       add       ecx,0FFFFFFF8
       jmp       near ptr 000000000000D4EE
; Total bytes of code 957
```
```assembly
; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jge       near ptr 00000000000002BC
       xor       eax,eax
       cmp       r8d,8
       jge       short 00000000000001C7
M02_L00:
       cmp       r8d,4
       jge       near ptr 0000000000000245
M02_L01:
       test      r8d,r8d
       jle       short 00000000000001BE
       movsx     r9,dx
M02_L02:
       dec       r8d
       movsx     rdx,word ptr [rcx+rax*2]
       cmp       edx,r9d
       jne       short 00000000000001B6
M02_L03:
       vzeroupper
       ret
M02_L04:
       inc       rax
       test      r8d,r8d
       jg        short 00000000000001A5
M02_L05:
       mov       eax,0FFFFFFFF
       vzeroupper
       ret
M02_L06:
       add       r8d,0FFFFFFF8
       movsx     r10,word ptr [rcx+rax*2]
       movsx     r9,dx
       cmp       r10d,r9d
       je        short 00000000000001B2
       movsx     r10,word ptr [rcx+rax*2+2]
       cmp       r10d,r9d
       je        near ptr 00000000000002B5
       movsx     r10,word ptr [rcx+rax*2+4]
       cmp       r10d,r9d
       je        near ptr 00000000000002AD
       movsx     r10,word ptr [rcx+rax*2+6]
       cmp       r10d,r9d
       je        near ptr 00000000000002A5
       movsx     r10,word ptr [rcx+rax*2+8]
       cmp       r10d,r9d
       je        near ptr 000000000000029D
       movsx     r10,word ptr [rcx+rax*2+0A]
       cmp       r10d,r9d
       je        short 0000000000000295
       movsx     r10,word ptr [rcx+rax*2+0C]
       cmp       r10d,r9d
       je        short 000000000000028D
       movsx     r10,word ptr [rcx+rax*2+0E]
       cmp       r10d,r9d
       je        short 0000000000000285
       add       rax,8
       cmp       r8d,8
       jge       short 00000000000001C7
       jmp       near ptr 0000000000000192
M02_L07:
       add       r8d,0FFFFFFFC
       movsx     r10,word ptr [rcx+rax*2]
       movsx     r9,dx
       cmp       r10d,r9d
       je        near ptr 00000000000001B2
       movsx     r10,word ptr [rcx+rax*2+2]
       cmp       r10d,r9d
       je        short 00000000000002B5
       movsx     r10,word ptr [rcx+rax*2+4]
       cmp       r10d,r9d
       je        short 00000000000002AD
       movsx     r10,word ptr [rcx+rax*2+6]
       cmp       r10d,r9d
       je        short 00000000000002A5
       add       rax,4
       jmp       near ptr 000000000000019C
M02_L08:
       add       eax,7
       jmp       near ptr 00000000000001B2
M02_L09:
       add       eax,6
       jmp       near ptr 00000000000001B2
M02_L10:
       add       eax,5
       jmp       near ptr 00000000000001B2
M02_L11:
       add       eax,4
       jmp       near ptr 00000000000001B2
M02_L12:
       add       eax,3
       jmp       near ptr 00000000000001B2
M02_L13:
       add       eax,2
       jmp       near ptr 00000000000001B2
M02_L14:
       inc       eax
       jmp       near ptr 00000000000001B2
M02_L15:
       cmp       r8d,10
       jl        near ptr 000000000000035A
       movsx     r9,dx
       vmovd     xmm0,r9d
       vpbroadcastw ymm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF0]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
M02_L16:
       vpcmpeqw  ymm1,ymm0,[rax]
       vptest    ymm1,ymm1
       jne       short 00000000000002F8
       add       rax,20
       cmp       rax,rdx
       jbe       short 00000000000002E2
       jmp       short 000000000000031C
M02_L17:
       sub       rax,rcx
       shr       rax,1
       vpshufb   ymm0,ymm1,[400]
       vpermq    ymm0,ymm0,0D8
       vpmovmskb ecx,xmm0
       tzcnt     ecx,ecx
       add       eax,ecx
       jmp       near ptr 00000000000001B2
M02_L18:
       mov       eax,r8d
       test      al,0F
       je        near ptr 00000000000001BE
       vpcmpeqw  ymm1,ymm0,[rdx]
       vptest    ymm1,ymm1
       je        near ptr 00000000000001BE
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   ymm1,ymm1,[400]
       vpermq    ymm0,ymm1,0D8
       vpmovmskb eax,xmm0
       tzcnt     eax,eax
       add       eax,edx
       jmp       near ptr 00000000000001B2
M02_L19:
       movsx     r9,dx
       vmovd     xmm0,r9d
       vpbroadcastw xmm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF8]
       movsxd    r9,edx
       lea       rdx,[rax+r9*2]
       vpcmpeqw  xmm1,xmm0,[rcx]
       vptest    xmm1,xmm1
       jne       short 0000000000000395
M02_L20:
       add       rax,10
       cmp       rax,rdx
       ja        short 00000000000003B8
       vpcmpeqw  xmm1,xmm0,[rax]
       vptest    xmm1,xmm1
       je        short 0000000000000381
M02_L21:
       sub       rax,rcx
       shr       rax,1
       vpshufb   xmm0,xmm1,[400]
       vpmovmskb ecx,xmm0
       xor       r8d,r8d
       tzcnt     r8d,ecx
       add       eax,r8d
       jmp       near ptr 00000000000001B2
M02_L22:
       mov       eax,r8d
       test      al,7
       je        near ptr 00000000000001BE
       vpcmpeqw  xmm1,xmm0,[rdx]
       vptest    xmm1,xmm1
       je        near ptr 00000000000001BE
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   xmm1,xmm1,[400]
       vpmovmskb ecx,xmm1
       xor       eax,eax
       tzcnt     eax,ecx
       add       eax,edx
       jmp       near ptr 00000000000001B2
; Total bytes of code 626
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.ExplicitVector256()
       push      rsi
       push      rbx
       sub       rsp,28
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        near ptr 00000000000039B4
       cmp       [rdx+8],r8d
       jb        near ptr 00000000000039C3
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       mov       r9d,10
       inc       r10d
       jmp       short 0000000000003964
       nop       dword ptr [rax]
       nop
M00_L01:
       vmovd     xmm0,r11d
       vpbroadcastw ymm0,xmm0
       lea       ebx,[r8+0FFF0]
       test      ebx,ebx
       jl        short 0000000000003978
M00_L02:
       movsxd    rbx,esi
       vpcmpeqw  ymm1,ymm0,[rdx+rbx*2]
       vpshufb   ymm1,ymm1,[39E0]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb ebx,xmm1
       test      ebx,ebx
       je        short 0000000000003943
       xor       r11d,r11d
       tzcnt     r11d,ebx
       add       r11d,esi
       jmp       short 000000000000395D
       nop       dword ptr [rax]
M00_L03:
       add       esi,10
       lea       ebx,[r8+0FFF0]
       cmp       esi,ebx
       jle       short 0000000000003910
       jmp       short 0000000000003978
M00_L04:
       inc       esi
       cmp       esi,r8d
       jl        short 0000000000003981
M00_L05:
       mov       r11d,0FFFFFFFF
M00_L06:
       add       eax,r11d
       add       r9,2
M00_L07:
       dec       r10d
       je        short 00000000000039AA
       movzx     r11d,word ptr [rcx+r9]
       mov       ebx,r8d
       xor       esi,esi
       cmp       ebx,10
       jge       short 00000000000038FE
M00_L08:
       cmp       esi,r8d
       jge       short 0000000000003957
       test      esi,esi
       jl        short 0000000000003991
M00_L09:
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       jne       short 0000000000003950
M00_L10:
       mov       r11d,esi
       jmp       short 000000000000395D
M00_L11:
       cmp       esi,r8d
       jae       short 00000000000039CA
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        short 000000000000398C
       inc       esi
       cmp       esi,r8d
       jl        short 0000000000003991
       jmp       short 0000000000003957
M00_L12:
       vzeroupper
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M00_L13:
       test      r8d,r8d
       jne       short 00000000000039C3
       xor       edx,edx
       xor       r8d,r8d
       jmp       near ptr 00000000000038E7
M00_L14:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001788
       int       3
; Total bytes of code 272
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.PaddedVector256()
       push      rsi
       push      rbx
       sub       rsp,28
       xor       eax,eax
       mov       rdx,[rcx+10]
       xor       r8d,r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jg        short 0000000000002F1E
M00_L00:
       vzeroupper
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M00_L01:
       xor       r11d,r11d
       xor       ebx,ebx
M00_L02:
       xor       r9d,r9d
       cmp       ebx,10
       jl        short 0000000000002F43
       nop       dword ptr [rax]
       vmovd     xmm0,r10d
       vpbroadcastw ymm0,xmm0
       lea       esi,[rbx+0FFF0]
       test      esi,esi
       jl        short 0000000000002F43
M00_L03:
       movsxd    rsi,r9d
       vpcmpeqw  ymm1,ymm0,[r11+rsi*2]
       vpshufb   ymm1,ymm1,[2FA0]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb esi,xmm1
       test      esi,esi
       je        short 0000000000002F37
       xor       r10d,r10d
       tzcnt     r10d,esi
       add       r10d,r9d
M00_L04:
       add       eax,r10d
       inc       r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jle       short 0000000000002EB8
M00_L05:
       movzx     r10d,word ptr [rdx+r8*2+10]
       mov       r9,[rcx+8]
       test      r9,r9
       je        short 0000000000002EC2
       lea       r11,[r9+10]
       mov       ebx,[r9+8]
       jmp       short 0000000000002EC7
M00_L06:
       add       r9d,10
       lea       esi,[rbx+0FFF0]
       cmp       r9d,esi
       jle       short 0000000000002EE4
M00_L07:
       cmp       r9d,ebx
       jl        short 0000000000002F5B
M00_L08:
       mov       r10d,0FFFFFFFF
       jmp       short 0000000000002F0F
       nop       word ptr [rax+rax]
M00_L09:
       test      r9d,r9d
       jl        short 0000000000002F7C
M00_L10:
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       jne       short 0000000000002F72
M00_L11:
       mov       r10d,r9d
       jmp       short 0000000000002F0F
M00_L12:
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000002F60
       jmp       short 0000000000002F48
M00_L13:
       cmp       r9d,ebx
       jae       short 0000000000002F98
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 0000000000002F6D
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000002F7C
       jmp       short 0000000000002F48
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 254
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.Scalar()
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        short 000000000000442C
       cmp       [rdx+8],r8d
       jb        short 0000000000004438
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       test      r10d,r10d
       jle       short 0000000000004426
       add       rcx,10
       jmp       short 0000000000004400
M00_L01:
       mov       r9d,r11d
M00_L02:
       add       eax,r9d
       add       rcx,2
       dec       r10d
       je        short 0000000000004426
M00_L03:
       movzx     r9d,word ptr [rcx]
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 000000000000441E
M00_L04:
       movzx     ebx,word ptr [rdx+r11*2]
       cmp       ebx,r9d
       je        short 00000000000043F1
       inc       r11d
       cmp       r11d,r8d
       jl        short 000000000000440C
M00_L05:
       mov       r9d,0FFFFFFFF
       jmp       short 00000000000043F4
M00_L06:
       add       rsp,20
       pop       rbx
       ret
M00_L07:
       test      r8d,r8d
       jne       short 0000000000004438
       xor       edx,edx
       xor       r8d,r8d
       jmp       short 00000000000043DE
M00_L08:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 127
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.SpanIndexOf()
       push      r14
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,20
       xor       ebx,ebx
       mov       rsi,[rcx+8]
       mov       edi,[rcx+18]
       test      rsi,rsi
       je        short 000000000000431D
       cmp       [rsi+8],edi
       jb        short 0000000000004327
       add       rsi,10
M00_L00:
       mov       rbp,[rcx+10]
       mov       r14d,[rbp+8]
       test      r14d,r14d
       jle       short 0000000000004302
       add       rbp,10
M00_L01:
       movzx     edx,word ptr [rbp]
       movsx     rdx,dx
       movzx     ecx,dx
       dec       ecx
       cmp       ecx,0FE
       jae       short 000000000000430F
       movsx     rdx,dx
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [0C3F0]; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
M00_L02:
       add       ebx,eax
       add       rbp,2
       dec       r14d
       jne       short 00000000000042D2
M00_L03:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M00_L04:
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [6220]; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       jmp       short 00000000000042F7
M00_L05:
       test      edi,edi
       jne       short 0000000000004327
       xor       esi,esi
       xor       edi,edi
       jmp       short 00000000000042C1
M00_L06:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 142
```
```assembly
; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jge       short 000000000000323F
       xor       r10d,r10d
       cmp       r8d,4
       jl        short 0000000000003214
       add       r8d,0FFFFFFFC
       movsx     r10,word ptr [rcx]
       movsx     r9,dx
       cmp       r10d,r9d
       je        near ptr 00000000000032DC
       movsx     rax,word ptr [rcx+2]
       cmp       eax,r9d
       je        near ptr 00000000000032E2
       movsx     rax,word ptr [rcx+4]
       cmp       eax,r9d
       je        near ptr 00000000000032EB
       movsx     rax,word ptr [rcx+6]
       cmp       eax,r9d
       je        near ptr 00000000000032F4
       mov       r10d,4
M01_L00:
       test      r8d,r8d
       jle       short 0000000000003236
       movsx     r9,dx
M01_L01:
       dec       r8d
       movsx     rdx,word ptr [rcx+r10*2]
       cmp       edx,r9d
       je        near ptr 00000000000032FE
       inc       r10
       test      r8d,r8d
       jg        short 000000000000321D
M01_L02:
       mov       eax,0FFFFFFFF
M01_L03:
       vzeroupper
       ret
M01_L04:
       mov       rax,rcx
       cmp       r8d,10
       jle       near ptr 0000000000003330
       vmovd     xmm0,edx
       vpbroadcastb ymm0,xmm0
       cmp       r8d,20
       jle       short 0000000000003283
       lea       edx,[r8+0FFE0]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
       vmovups   ymm1,[rcx]
       vpackuswb ymm1,ymm1,[rcx+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       jne       short 00000000000032BE
M01_L05:
       add       rax,40
       cmp       rax,rdx
       jb        short 00000000000032AA
M01_L06:
       add       r8d,0FFFFFFF0
       movsxd    rdx,r8d
       lea       rdx,[rcx+rdx*2]
       cmp       rax,rdx
       cmova     rax,rdx
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rdx]
       vpcmpeqb  ymm0,ymm1,ymm0
       vptest    ymm0,ymm0
       je        short 0000000000003236
       jmp       short 0000000000003306
M01_L07:
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rax+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       je        short 000000000000327A
M01_L08:
       sub       rax,rcx
       shr       rax,1
       vpermq    ymm0,ymm1,0D8
       vpmovmskb r8d,ymm0
       xor       ecx,ecx
       tzcnt     ecx,r8d
       add       eax,ecx
       jmp       near ptr 000000000000323B
M01_L09:
       xor       eax,eax
       vzeroupper
       ret
M01_L10:
       mov       eax,1
       vzeroupper
       ret
M01_L11:
       mov       eax,2
       vzeroupper
       ret
M01_L12:
       mov       eax,3
       jmp       near ptr 000000000000323B
M01_L13:
       mov       eax,r10d
       jmp       near ptr 000000000000323B
M01_L14:
       vpermq    ymm0,ymm0,0D8
       vpmovmskb r8d,ymm0
       tzcnt     r8d,r8d
       cmp       r8d,10
       jl        short 0000000000003322
       mov       rax,rdx
       add       r8d,0FFFFFFF0
M01_L15:
       sub       rax,rcx
       shr       rax,1
       add       eax,r8d
       jmp       near ptr 000000000000323B
M01_L16:
       vmovd     xmm0,edx
       vpbroadcastb xmm0,xmm0
       lea       eax,[r8+0FFF8]
       cdqe
       lea       rax,[rcx+rax*2]
       cmp       rcx,rax
       mov       rdx,rcx
       cmova     rdx,rax
       vmovups   xmm1,[rdx]
       vpackuswb xmm1,xmm1,[rax]
       vpcmpeqb  xmm0,xmm1,xmm0
       vptest    xmm0,xmm0
       je        near ptr 0000000000003236
       vpmovmskb r8d,xmm0
       tzcnt     r8d,r8d
       cmp       r8d,8
       jl        short 000000000000337A
       mov       rdx,rax
       add       r8d,0FFFFFFF8
M01_L17:
       sub       rdx,rcx
       shr       rdx,1
       lea       eax,[rdx+r8]
       jmp       near ptr 000000000000323B
; Total bytes of code 457
```
```assembly
; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jge       near ptr 0000000000004116
       xor       eax,eax
       cmp       r8d,8
       jge       short 0000000000004088
M02_L00:
       cmp       r8d,4
       jl        short 000000000000404F
       add       r8d,0FFFFFFFC
       movsx     r10,word ptr [rcx+rax*2]
       movsx     r9,dx
       cmp       r10d,r9d
       je        short 0000000000004065
       movsx     r10,word ptr [rcx+rax*2+2]
       cmp       r10d,r9d
       je        short 0000000000004084
       movsx     r10,word ptr [rcx+rax*2+4]
       cmp       r10d,r9d
       je        short 000000000000407F
       movsx     r10,word ptr [rcx+rax*2+6]
       cmp       r10d,r9d
       je        short 000000000000407A
       add       rax,4
M02_L01:
       test      r8d,r8d
       jle       short 0000000000004071
       movsx     r9,dx
M02_L02:
       dec       r8d
       movsx     rdx,word ptr [rcx+rax*2]
       cmp       edx,r9d
       jne       short 0000000000004069
M02_L03:
       vzeroupper
       ret
M02_L04:
       inc       rax
       test      r8d,r8d
       jg        short 0000000000004058
M02_L05:
       mov       eax,0FFFFFFFF
       vzeroupper
       ret
M02_L06:
       add       eax,3
       jmp       short 0000000000004065
M02_L07:
       add       eax,2
       jmp       short 0000000000004065
M02_L08:
       inc       eax
       jmp       short 0000000000004065
M02_L09:
       add       r8d,0FFFFFFF8
       movsx     r10,word ptr [rcx+rax*2]
       movsx     r9,dx
       cmp       r10d,r9d
       je        short 0000000000004065
       movsx     r10,word ptr [rcx+rax*2+2]
       cmp       r10d,r9d
       je        short 0000000000004084
       movsx     r10,word ptr [rcx+rax*2+4]
       cmp       r10d,r9d
       je        short 000000000000407F
       movsx     r10,word ptr [rcx+rax*2+6]
       cmp       r10d,r9d
       je        short 000000000000407A
       movsx     r10,word ptr [rcx+rax*2+8]
       cmp       r10d,r9d
       je        short 000000000000410E
       movsx     r10,word ptr [rcx+rax*2+0A]
       cmp       r10d,r9d
       je        short 0000000000004106
       movsx     r10,word ptr [rcx+rax*2+0C]
       cmp       r10d,r9d
       je        short 00000000000040FE
       movsx     r10,word ptr [rcx+rax*2+0E]
       cmp       r10d,r9d
       je        short 00000000000040F6
       add       rax,8
       cmp       r8d,8
       jge       short 0000000000004088
       jmp       near ptr 0000000000004012
M02_L10:
       add       eax,7
       jmp       near ptr 0000000000004065
M02_L11:
       add       eax,6
       jmp       near ptr 0000000000004065
M02_L12:
       add       eax,5
       jmp       near ptr 0000000000004065
M02_L13:
       add       eax,4
       jmp       near ptr 0000000000004065
M02_L14:
       cmp       r8d,10
       jl        near ptr 00000000000041B4
       movsx     r9,dx
       vmovd     xmm0,r9d
       vpbroadcastw ymm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF0]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
M02_L15:
       vpcmpeqw  ymm1,ymm0,[rax]
       vptest    ymm1,ymm1
       jne       short 0000000000004152
       add       rax,20
       cmp       rax,rdx
       jbe       short 000000000000413C
       jmp       short 0000000000004176
M02_L16:
       sub       rax,rcx
       shr       rax,1
       vpshufb   ymm0,ymm1,[4260]
       vpermq    ymm0,ymm0,0D8
       vpmovmskb ecx,xmm0
       tzcnt     ecx,ecx
       add       eax,ecx
       jmp       near ptr 0000000000004065
M02_L17:
       mov       eax,r8d
       test      al,0F
       je        near ptr 0000000000004071
       vpcmpeqw  ymm1,ymm0,[rdx]
       vptest    ymm1,ymm1
       je        near ptr 0000000000004071
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   ymm1,ymm1,[4260]
       vpermq    ymm0,ymm1,0D8
       vpmovmskb eax,xmm0
       tzcnt     eax,eax
       add       eax,edx
       jmp       near ptr 0000000000004065
M02_L18:
       movsx     r9,dx
       vmovd     xmm0,r9d
       vpbroadcastw xmm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF8]
       movsxd    r9,edx
       lea       rdx,[rax+r9*2]
       vpcmpeqw  xmm1,xmm0,[rcx]
       vptest    xmm1,xmm1
       jne       short 00000000000041EF
M02_L19:
       add       rax,10
       cmp       rax,rdx
       ja        short 0000000000004212
       vpcmpeqw  xmm1,xmm0,[rax]
       vptest    xmm1,xmm1
       je        short 00000000000041DB
M02_L20:
       sub       rax,rcx
       shr       rax,1
       vpshufb   xmm0,xmm1,[4260]
       vpmovmskb ecx,xmm0
       xor       r8d,r8d
       tzcnt     r8d,ecx
       add       eax,r8d
       jmp       near ptr 0000000000004065
M02_L21:
       mov       eax,r8d
       test      al,7
       je        near ptr 0000000000004071
       vpcmpeqw  xmm1,xmm0,[rdx]
       vptest    xmm1,xmm1
       je        near ptr 0000000000004071
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   xmm1,xmm1,[4260]
       vpmovmskb ecx,xmm1
       xor       eax,eax
       tzcnt     eax,ecx
       add       eax,edx
       jmp       near ptr 0000000000004065
; Total bytes of code 588
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.ExplicitVector256()
       push      rsi
       push      rbx
       sub       rsp,28
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        near ptr 00000000000037C7
       cmp       [rdx+8],r8d
       jb        near ptr 00000000000037D6
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       mov       r9d,10
       inc       r10d
       jmp       short 0000000000003786
M00_L01:
       vmovd     xmm0,r11d
       vpbroadcastw ymm0,xmm0
       lea       ebx,[r8+0FFF0]
       test      ebx,ebx
       jl        short 000000000000379A
M00_L02:
       movsxd    rbx,esi
       vpcmpeqw  ymm1,ymm0,[rdx+rbx*2]
       vpshufb   ymm1,ymm1,[3800]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb ebx,xmm1
       test      ebx,ebx
       je        short 0000000000003758
       xor       r11d,r11d
       tzcnt     r11d,ebx
       add       r11d,esi
       jmp       short 000000000000377F
M00_L03:
       add       esi,10
       lea       ebx,[r8+0FFF0]
       cmp       esi,ebx
       jle       short 000000000000372C
       jmp       short 000000000000379A
M00_L04:
       inc       esi
       cmp       esi,r8d
       jge       short 00000000000037B5
M00_L05:
       cmp       esi,r8d
       jae       short 00000000000037DD
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       jne       short 0000000000003765
M00_L06:
       mov       r11d,esi
M00_L07:
       add       eax,r11d
       add       r9,2
M00_L08:
       dec       r10d
       je        short 00000000000037BD
       movzx     r11d,word ptr [rcx+r9]
       mov       ebx,r8d
       xor       esi,esi
       cmp       ebx,10
       jge       short 000000000000371A
M00_L09:
       cmp       esi,r8d
       jge       short 00000000000037B5
       test      esi,esi
       jl        short 000000000000376C
M00_L10:
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        short 000000000000377C
       inc       esi
       cmp       esi,r8d
       jl        short 00000000000037A3
M00_L11:
       mov       r11d,0FFFFFFFF
       jmp       short 000000000000377F
M00_L12:
       vzeroupper
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M00_L13:
       test      r8d,r8d
       jne       short 00000000000037D6
       xor       edx,edx
       xor       r8d,r8d
       jmp       near ptr 0000000000003707
M00_L14:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001788
       int       3
; Total bytes of code 259
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.PaddedVector256()
       push      rsi
       push      rbx
       sub       rsp,28
       xor       eax,eax
       mov       rdx,[rcx+10]
       xor       r8d,r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jg        short 00000000000041DE
M00_L00:
       vzeroupper
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M00_L01:
       xor       r11d,r11d
       xor       ebx,ebx
M00_L02:
       xor       r9d,r9d
       cmp       ebx,10
       jl        short 0000000000004203
       nop       dword ptr [rax]
       vmovd     xmm0,r10d
       vpbroadcastw ymm0,xmm0
       lea       esi,[rbx+0FFF0]
       test      esi,esi
       jl        short 0000000000004203
M00_L03:
       movsxd    rsi,r9d
       vpcmpeqw  ymm1,ymm0,[r11+rsi*2]
       vpshufb   ymm1,ymm1,[4280]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb esi,xmm1
       test      esi,esi
       je        short 00000000000041F7
       xor       r10d,r10d
       tzcnt     r10d,esi
       add       r10d,r9d
M00_L04:
       add       eax,r10d
       inc       r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jle       short 0000000000004178
M00_L05:
       movzx     r10d,word ptr [rdx+r8*2+10]
       mov       r9,[rcx+8]
       test      r9,r9
       je        short 0000000000004182
       lea       r11,[r9+10]
       mov       ebx,[r9+8]
       jmp       short 0000000000004187
M00_L06:
       add       r9d,10
       lea       esi,[rbx+0FFF0]
       cmp       r9d,esi
       jle       short 00000000000041A4
M00_L07:
       cmp       r9d,ebx
       jl        short 000000000000421B
M00_L08:
       mov       r10d,0FFFFFFFF
       jmp       short 00000000000041CF
       nop       word ptr [rax+rax]
M00_L09:
       test      r9d,r9d
       jl        short 0000000000004237
M00_L10:
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 0000000000004253
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000004220
       jmp       short 0000000000004208
M00_L11:
       cmp       r9d,ebx
       jae       short 000000000000425B
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 0000000000004253
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000004237
       jmp       short 0000000000004208
M00_L12:
       mov       r10d,r9d
       jmp       near ptr 00000000000041CF
M00_L13:
       call      0000000000001788
       int       3
; Total bytes of code 257
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.Scalar()
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        short 0000000000003E0C
       cmp       [rdx+8],r8d
       jb        short 0000000000003E18
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       test      r10d,r10d
       jle       short 0000000000003E06
       add       rcx,10
       jmp       short 0000000000003DE0
M00_L01:
       mov       r9d,r11d
M00_L02:
       add       eax,r9d
       add       rcx,2
       dec       r10d
       je        short 0000000000003E06
M00_L03:
       movzx     r9d,word ptr [rcx]
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000003DFE
M00_L04:
       movzx     ebx,word ptr [rdx+r11*2]
       cmp       ebx,r9d
       je        short 0000000000003DD1
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000003DEC
M00_L05:
       mov       r9d,0FFFFFFFF
       jmp       short 0000000000003DD4
M00_L06:
       add       rsp,20
       pop       rbx
       ret
M00_L07:
       test      r8d,r8d
       jne       short 0000000000003E18
       xor       edx,edx
       xor       r8d,r8d
       jmp       short 0000000000003DBE
M00_L08:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 127
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.SpanIndexOf()
       push      r14
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,20
       xor       ebx,ebx
       mov       rsi,[rcx+8]
       mov       edi,[rcx+18]
       test      rsi,rsi
       je        short 0000000000003BBD
       cmp       [rsi+8],edi
       jb        short 0000000000003BC7
       add       rsi,10
M00_L00:
       mov       rbp,[rcx+10]
       mov       r14d,[rbp+8]
       test      r14d,r14d
       jle       short 0000000000003BA2
       add       rbp,10
M00_L01:
       movzx     edx,word ptr [rbp]
       movsx     rdx,dx
       movzx     ecx,dx
       dec       ecx
       cmp       ecx,0FE
       jae       short 0000000000003BAF
       movsx     rdx,dx
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [0C378]; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
M00_L02:
       add       ebx,eax
       add       rbp,2
       dec       r14d
       jne       short 0000000000003B72
M00_L03:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M00_L04:
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [6220]; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       jmp       short 0000000000003B97
M00_L05:
       test      edi,edi
       jne       short 0000000000003BC7
       xor       esi,esi
       xor       edi,edi
       jmp       short 0000000000003B61
M00_L06:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 142
```
```assembly
; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jl        near ptr 0000000000002A8C
       mov       rax,rcx
       cmp       r8d,10
       jle       near ptr 0000000000002B55
       vmovd     xmm0,edx
       vpbroadcastb ymm0,xmm0
       cmp       r8d,20
       jg        short 0000000000002A38
M01_L00:
       add       r8d,0FFFFFFF0
       movsxd    rdx,r8d
       lea       rdx,[rcx+rdx*2]
       cmp       rax,rdx
       cmova     rax,rdx
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rdx]
       vpcmpeqb  ymm0,ymm1,ymm0
       vptest    ymm0,ymm0
       jne       near ptr 0000000000002B2B
M01_L01:
       mov       eax,0FFFFFFFF
M01_L02:
       vzeroupper
       ret
M01_L03:
       lea       edx,[r8+0FFE0]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
       vmovups   ymm1,[rcx]
       vpackuswb ymm1,ymm1,[rcx+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       jne       short 0000000000002A74
M01_L04:
       add       rax,40
       cmp       rax,rdx
       jae       short 0000000000002A06
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rax+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       je        short 0000000000002A57
M01_L05:
       sub       rax,rcx
       shr       rax,1
       vpermq    ymm0,ymm1,0D8
       vpmovmskb ecx,ymm0
       tzcnt     ecx,ecx
       add       eax,ecx
       jmp       short 0000000000002A34
M01_L06:
       xor       r10d,r10d
       cmp       r8d,4
       jl        near ptr 0000000000002B19
       add       r8d,0FFFFFFFC
       movsx     r10,word ptr [rcx]
       movsx     rax,dx
       cmp       r10d,eax
       jne       short 0000000000002AB0
       xor       eax,eax
       vzeroupper
       ret
M01_L07:
       movsx     rax,word ptr [rcx+2]
       movsx     r10,dx
       cmp       eax,r10d
       jne       short 0000000000002AC7
       mov       eax,1
       vzeroupper
       ret
M01_L08:
       movsx     rax,word ptr [rcx+4]
       movsx     r10,dx
       cmp       eax,r10d
       jne       short 0000000000002ADE
       mov       eax,2
       vzeroupper
       ret
M01_L09:
       movsx     rax,word ptr [rcx+6]
       movsx     r10,dx
       cmp       eax,r10d
       jne       short 0000000000002AF6
       mov       eax,3
       jmp       near ptr 0000000000002A34
M01_L10:
       mov       r10d,4
       test      r8d,r8d
       jle       near ptr 0000000000002A2F
M01_L11:
       dec       r8d
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 0000000000002B23
       inc       r10
M01_L12:
       test      r8d,r8d
       jg        short 0000000000002B05
       jmp       near ptr 0000000000002A2F
M01_L13:
       mov       eax,r10d
       jmp       near ptr 0000000000002A34
M01_L14:
       vpermq    ymm0,ymm0,0D8
       vpmovmskb r8d,ymm0
       tzcnt     r8d,r8d
       cmp       r8d,10
       jl        short 0000000000002B47
       mov       rax,rdx
       add       r8d,0FFFFFFF0
M01_L15:
       sub       rax,rcx
       shr       rax,1
       add       eax,r8d
       jmp       near ptr 0000000000002A34
M01_L16:
       vmovd     xmm0,edx
       vpbroadcastb xmm0,xmm0
       lea       eax,[r8+0FFF8]
       movsxd    r8,eax
       lea       rax,[rcx+r8*2]
       cmp       rcx,rax
       mov       rdx,rcx
       cmova     rdx,rax
       vmovups   xmm1,[rdx]
       vpackuswb xmm1,xmm1,[rax]
       vpcmpeqb  xmm0,xmm1,xmm0
       vptest    xmm0,xmm0
       je        near ptr 0000000000002A2F
       vpmovmskb r8d,xmm0
       tzcnt     r8d,r8d
       cmp       r8d,8
       jl        short 0000000000002BA0
       mov       rdx,rax
       add       r8d,0FFFFFFF8
M01_L17:
       sub       rdx,rcx
       shr       rdx,1
       lea       eax,[rdx+r8]
       jmp       near ptr 0000000000002A34
; Total bytes of code 463
```
```assembly
; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jl        near ptr 000000000000346B
       cmp       r8d,10
       jl        near ptr 00000000000035F4
       vmovd     xmm0,edx
       vpbroadcastw ymm0,xmm0
       mov       rdx,rcx
       lea       eax,[r8+0FFF0]
       cdqe
       add       rax,rax
       lea       r10,[rdx+rax]
       vpcmpeqw  ymm1,ymm0,[rcx]
       vptest    ymm1,ymm1
       jne       short 000000000000343C
M02_L00:
       add       rdx,20
       cmp       rdx,r10
       jbe       near ptr 00000000000035E0
       mov       ecx,r8d
       test      cl,0F
       je        short 0000000000003462
       vpcmpeqw  ymm1,ymm0,[r10]
       vptest    ymm1,ymm1
       je        short 0000000000003462
       shr       rax,1
       vpshufb   ymm1,ymm1,[36A0]
       vpermq    ymm0,ymm1,0D8
       vpmovmskb edx,xmm0
       xor       r8d,r8d
       tzcnt     r8d,edx
       add       eax,r8d
       jmp       short 000000000000345E
M02_L01:
       mov       rax,rdx
       sub       rax,rcx
       shr       rax,1
       vpshufb   ymm0,ymm1,[36A0]
       vpermq    ymm0,ymm0,0D8
       vpmovmskb ecx,xmm0
       tzcnt     ecx,ecx
       add       eax,ecx
M02_L02:
       vzeroupper
       ret
M02_L03:
       mov       eax,0FFFFFFFF
       vzeroupper
       ret
M02_L04:
       xor       r10d,r10d
       cmp       r8d,8
       jl        near ptr 0000000000003521
M02_L05:
       add       r8d,0FFFFFFF8
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035D8
       movsx     rax,word ptr [rcx+r10*2+2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035CF
       movsx     rax,word ptr [rcx+r10*2+4]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035C6
       movsx     rax,word ptr [rcx+r10*2+6]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035BD
       movsx     rax,word ptr [rcx+r10*2+8]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035B4
       movsx     rax,word ptr [rcx+r10*2+0A]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035AB
       movsx     rax,word ptr [rcx+r10*2+0C]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035A2
       movsx     rax,word ptr [rcx+r10*2+0E]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000003599
       add       r10,8
       cmp       r8d,8
       jge       near ptr 0000000000003478
M02_L06:
       cmp       r8d,4
       jl        short 000000000000358F
       add       r8d,0FFFFFFFC
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035D8
       movsx     rax,word ptr [rcx+r10*2+2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 00000000000035CF
       movsx     rax,word ptr [rcx+r10*2+4]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 00000000000035C6
       movsx     rax,word ptr [rcx+r10*2+6]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 00000000000035BD
       add       r10,4
       test      r8d,r8d
       jle       near ptr 0000000000003462
M02_L07:
       dec       r8d
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 00000000000035D8
       inc       r10
M02_L08:
       test      r8d,r8d
       jg        short 000000000000357B
       jmp       near ptr 0000000000003462
M02_L09:
       lea       eax,[r10+7]
       jmp       near ptr 000000000000345E
M02_L10:
       lea       eax,[r10+6]
       jmp       near ptr 000000000000345E
M02_L11:
       lea       eax,[r10+5]
       jmp       near ptr 000000000000345E
M02_L12:
       lea       eax,[r10+4]
       jmp       near ptr 000000000000345E
M02_L13:
       lea       eax,[r10+3]
       jmp       near ptr 000000000000345E
M02_L14:
       lea       eax,[r10+2]
       jmp       near ptr 000000000000345E
M02_L15:
       lea       eax,[r10+1]
       jmp       near ptr 000000000000345E
M02_L16:
       mov       eax,r10d
       jmp       near ptr 000000000000345E
M02_L17:
       vpcmpeqw  ymm1,ymm0,[rdx]
       vptest    ymm1,ymm1
       jne       near ptr 000000000000343C
       jmp       near ptr 00000000000033F8
M02_L18:
       vmovd     xmm0,edx
       vpbroadcastw xmm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF8]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
       vpcmpeqw  xmm1,xmm0,[rcx]
       vptest    xmm1,xmm1
       jne       short 000000000000362A
M02_L19:
       add       rax,10
       cmp       rax,rdx
       ja        short 000000000000364B
       vpcmpeqw  xmm1,xmm0,[rax]
       vptest    xmm1,xmm1
       je        short 0000000000003616
M02_L20:
       sub       rax,rcx
       shr       rax,1
       vpshufb   xmm0,xmm1,[36A0]
       vpmovmskb r8d,xmm0
       xor       ecx,ecx
       tzcnt     ecx,r8d
       add       eax,ecx
       jmp       near ptr 000000000000345E
M02_L21:
       mov       eax,r8d
       test      al,7
       je        near ptr 0000000000003462
       vpcmpeqw  xmm1,xmm0,[rdx]
       vptest    xmm1,xmm1
       je        near ptr 0000000000003462
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   xmm1,xmm1,[36A0]
       vpmovmskb ecx,xmm1
       xor       eax,eax
       tzcnt     eax,ecx
       add       eax,edx
       jmp       near ptr 000000000000345E
; Total bytes of code 709
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.ExplicitVector256()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        near ptr 00000000000038B2
       cmp       [rdx+8],r8d
       jb        near ptr 00000000000038C1
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       mov       r9d,10
       inc       r10d
       jmp       short 0000000000003816
       nop       dword ptr [rax]
M00_L01:
       mov       r11d,esi
       jmp       short 000000000000380F
M00_L02:
       xor       r11d,r11d
       tzcnt     r11d,edi
       add       r11d,esi
M00_L03:
       add       eax,r11d
       add       r9,2
M00_L04:
       dec       r10d
       je        near ptr 00000000000038A7
       movzx     r11d,word ptr [rcx+r9]
       mov       ebx,r8d
       xor       esi,esi
       cmp       ebx,10
       jl        short 0000000000003866
       vmovd     xmm0,r11d
       vpbroadcastw ymm0,xmm0
       lea       ebx,[r8+0FFF0]
       test      ebx,ebx
       jl        short 0000000000003866
M00_L05:
       movsxd    rdi,esi
       vpcmpeqw  ymm1,ymm0,[rdx+rdi*2]
       vpshufb   ymm1,ymm1,[38E0]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb edi,xmm1
       test      edi,edi
       jne       short 0000000000003804
       add       esi,10
       cmp       esi,ebx
       jle       short 0000000000003840
M00_L06:
       cmp       esi,r8d
       jge       short 0000000000003882
       test      esi,esi
       jl        short 000000000000388A
       nop
M00_L07:
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        short 00000000000037FF
       inc       esi
       cmp       esi,r8d
       jl        short 0000000000003870
M00_L08:
       mov       r11d,0FFFFFFFF
       jmp       short 000000000000380F
M00_L09:
       cmp       esi,r8d
       jae       short 00000000000038C8
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        near ptr 00000000000037FF
       inc       esi
       cmp       esi,r8d
       jl        short 000000000000388A
       jmp       short 0000000000003882
M00_L10:
       vzeroupper
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L11:
       test      r8d,r8d
       jne       short 00000000000038C1
       xor       edx,edx
       xor       r8d,r8d
       jmp       near ptr 00000000000037E8
M00_L12:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L13:
       call      0000000000001788
       int       3
; Total bytes of code 270
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.PaddedVector256()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+10]
       xor       r8d,r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jg        short 0000000000003813
M00_L00:
       vzeroupper
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       lea       r11,[r9+10]
       mov       ebx,[r9+8]
       jmp       short 0000000000003827
M00_L02:
       cmp       r9d,ebx
       jae       near ptr 00000000000038A4
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 00000000000037F1
       inc       r9d
       cmp       r9d,ebx
       jl        short 00000000000037CE
       jmp       near ptr 0000000000003899
M00_L03:
       mov       r10d,r9d
       jmp       short 0000000000003804
       nop       dword ptr [rax]
M00_L04:
       xor       r10d,r10d
       tzcnt     r10d,edi
       add       r10d,r9d
M00_L05:
       add       eax,r10d
       inc       r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jle       short 00000000000037B9
M00_L06:
       movzx     r10d,word ptr [rdx+r8*2+10]
       mov       r9,[rcx+8]
       test      r9,r9
       jne       short 00000000000037C4
       xor       r11d,r11d
       xor       ebx,ebx
M00_L07:
       xor       r9d,r9d
       cmp       ebx,10
       jl        short 0000000000003869
       vmovd     xmm0,r10d
       vpbroadcastw ymm0,xmm0
       lea       esi,[rbx+0FFF0]
       test      esi,esi
       jl        short 0000000000003869
M00_L08:
       movsxd    rdi,r9d
       vpcmpeqw  ymm1,ymm0,[r11+rdi*2]
       vpshufb   ymm1,ymm1,[38C0]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb edi,xmm1
       test      edi,edi
       jne       short 00000000000037F9
       add       r9d,10
       cmp       r9d,esi
       jle       short 0000000000003840
M00_L09:
       cmp       r9d,ebx
       jge       short 0000000000003899
       test      r9d,r9d
       jl        near ptr 00000000000037CE
       nop       word ptr [rax+rax]
M00_L10:
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        near ptr 00000000000037F1
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000003880
M00_L11:
       mov       r10d,0FFFFFFFF
       jmp       near ptr 0000000000003804
M00_L12:
       call      0000000000001788
       int       3
; Total bytes of code 266
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.Scalar()
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        short 00000000000012AF
       cmp       [rdx+8],r8d
       jb        short 00000000000012BB
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       test      r10d,r10d
       jle       short 00000000000012A4
       add       rcx,10
       jmp       short 0000000000001284
       nop
M00_L01:
       mov       r9d,0FFFFFFFF
M00_L02:
       add       eax,r9d
       add       rcx,2
       dec       r10d
       je        short 00000000000012A4
M00_L03:
       movzx     r9d,word ptr [rcx]
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000001272
M00_L04:
       movzx     ebx,word ptr [rdx+r11*2]
       cmp       ebx,r9d
       je        short 00000000000012AA
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000001290
       jmp       short 0000000000001272
M00_L05:
       add       rsp,20
       pop       rbx
       ret
M00_L06:
       mov       r9d,r11d
       jmp       short 0000000000001278
M00_L07:
       test      r8d,r8d
       jne       short 00000000000012BB
       xor       edx,edx
       xor       r8d,r8d
       jmp       short 000000000000125E
M00_L08:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 130
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.SpanIndexOf()
       push      r14
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,20
       xor       ebx,ebx
       mov       rsi,[rcx+8]
       mov       edi,[rcx+18]
       test      rsi,rsi
       je        short 0000000000001B1D
       cmp       [rsi+8],edi
       jb        short 0000000000001B27
       add       rsi,10
M00_L00:
       mov       rbp,[rcx+10]
       mov       r14d,[rbp+8]
       test      r14d,r14d
       jle       short 0000000000001B02
       add       rbp,10
M00_L01:
       movzx     edx,word ptr [rbp]
       movsx     rdx,dx
       movzx     ecx,dx
       dec       ecx
       cmp       ecx,0FE
       jae       short 0000000000001B0F
       movsx     rdx,dx
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [0C378]; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
M00_L02:
       add       ebx,eax
       add       rbp,2
       dec       r14d
       jne       short 0000000000001AD2
M00_L03:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r14
       ret
M00_L04:
       mov       rcx,rsi
       mov       r8d,edi
       call      qword ptr [61D8]; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       jmp       short 0000000000001AF7
M00_L05:
       test      edi,edi
       jne       short 0000000000001B27
       xor       esi,esi
       xor       edi,edi
       jmp       short 0000000000001AC1
M00_L06:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 142
```
```assembly
; System.PackedSpanHelpers.IndexOf[[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib],[System.PackedSpanHelpers+NopTransform, System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jl        near ptr 00000000000005AA
       mov       rax,rcx
       cmp       r8d,10
       jle       near ptr 0000000000000574
       vmovd     xmm0,edx
       vpbroadcastb ymm0,xmm0
       cmp       r8d,20
       jle       short 000000000000051D
       lea       edx,[r8+0FFE0]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
       vmovups   ymm1,[rcx]
       vpackuswb ymm1,ymm1,[rcx+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       jne       short 0000000000000502
M01_L00:
       add       rax,40
       cmp       rax,rdx
       jae       short 000000000000051D
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rax+20]
       vpcmpeqb  ymm1,ymm1,ymm0
       vptest    ymm1,ymm1
       je        short 00000000000004E5
M01_L01:
       sub       rax,rcx
       shr       rax,1
       vpermq    ymm0,ymm1,0D8
       vpmovmskb r8d,ymm0
       xor       ecx,ecx
       tzcnt     ecx,r8d
       add       eax,ecx
       jmp       short 0000000000000547
M01_L02:
       add       r8d,0FFFFFFF0
       movsxd    rdx,r8d
       lea       rdx,[rcx+rdx*2]
       cmp       rax,rdx
       cmova     rax,rdx
       vmovups   ymm1,[rax]
       vpackuswb ymm1,ymm1,[rdx]
       vpcmpeqb  ymm0,ymm1,ymm0
       vptest    ymm0,ymm0
       jne       short 000000000000054B
M01_L03:
       mov       eax,0FFFFFFFF
M01_L04:
       vzeroupper
       ret
M01_L05:
       vpermq    ymm0,ymm0,0D8
       vpmovmskb r8d,ymm0
       tzcnt     r8d,r8d
       cmp       r8d,10
       jge       short 000000000000056B
M01_L06:
       sub       rax,rcx
       shr       rax,1
       add       eax,r8d
       jmp       short 0000000000000547
M01_L07:
       mov       rax,rdx
       add       r8d,0FFFFFFF0
       jmp       short 0000000000000560
M01_L08:
       vmovd     xmm0,edx
       vpbroadcastb xmm0,xmm0
       lea       eax,[r8+0FFF8]
       movsxd    r8,eax
       lea       rax,[rcx+r8*2]
       cmp       rcx,rax
       mov       rdx,rcx
       cmova     rdx,rax
       vmovups   xmm1,[rdx]
       vpackuswb xmm1,xmm1,[rax]
       vpcmpeqb  xmm0,xmm1,xmm0
       vptest    xmm0,xmm0
       je        short 0000000000000542
       jmp       near ptr 0000000000000634
M01_L09:
       xor       eax,eax
       cmp       r8d,4
       jl        short 00000000000005E6
       add       r8d,0FFFFFFFC
       movsx     rax,word ptr [rcx]
       movsx     r10,dx
       cmp       eax,r10d
       je        short 000000000000060D
       movsx     rax,word ptr [rcx+2]
       cmp       eax,r10d
       je        short 0000000000000613
       movsx     rax,word ptr [rcx+4]
       cmp       eax,r10d
       je        short 000000000000061C
       movsx     rax,word ptr [rcx+6]
       cmp       eax,r10d
       je        short 0000000000000625
       mov       eax,4
M01_L10:
       test      r8d,r8d
       jle       near ptr 0000000000000542
M01_L11:
       dec       r8d
       movsx     r9,word ptr [rcx+rax*2]
       movsx     r10,dx
       cmp       r9d,r10d
       je        short 000000000000062F
       inc       rax
       test      r8d,r8d
       jg        short 00000000000005EF
       jmp       near ptr 0000000000000542
M01_L12:
       xor       eax,eax
       vzeroupper
       ret
M01_L13:
       mov       eax,1
       vzeroupper
       ret
M01_L14:
       mov       eax,2
       vzeroupper
       ret
M01_L15:
       mov       eax,3
       jmp       near ptr 0000000000000547
M01_L16:
       jmp       near ptr 0000000000000547
M01_L17:
       vpmovmskb r8d,xmm0
       tzcnt     r8d,r8d
       cmp       r8d,8
       jl        short 000000000000064A
       mov       rdx,rax
       add       r8d,0FFFFFFF8
M01_L18:
       sub       rdx,rcx
       shr       rdx,1
       lea       eax,[rdx+r8]
       jmp       near ptr 0000000000000547
; Total bytes of code 441
```
```assembly
; System.SpanHelpers.NonPackedIndexOfValueType[[System.Int16, System.Private.CoreLib],[System.SpanHelpers+DontNegate`1[[System.Int16, System.Private.CoreLib]], System.Private.CoreLib]](Int16 ByRef, Int16, Int32)
       cmp       r8d,8
       jl        near ptr 00000000000017EF
       cmp       r8d,10
       jl        near ptr 000000000000199C
       vmovd     xmm0,edx
       vpbroadcastw ymm0,xmm0
       mov       rdx,rcx
       lea       eax,[r8+0FFF0]
       cdqe
       lea       rax,[rdx+rax*2]
       vpcmpeqw  ymm1,ymm0,[rcx]
       vptest    ymm1,ymm1
       jne       short 00000000000017B4
       nop       word ptr [rax+rax]
M02_L00:
       add       rdx,20
       cmp       rdx,rax
       ja        short 00000000000017DA
       vpcmpeqw  ymm1,ymm0,[rdx]
       vptest    ymm1,ymm1
       je        short 00000000000017A0
M02_L01:
       mov       rax,rdx
       sub       rax,rcx
       shr       rax,1
       vpshufb   ymm0,ymm1,[1A40]
       vpermq    ymm0,ymm0,0D8
       vpmovmskb ecx,xmm0
       tzcnt     ecx,ecx
       add       eax,ecx
M02_L02:
       vzeroupper
       ret
M02_L03:
       mov       edx,r8d
       test      dl,0F
       jne       near ptr 0000000000001964
M02_L04:
       mov       eax,0FFFFFFFF
       vzeroupper
       ret
M02_L05:
       xor       r10d,r10d
       cmp       r8d,8
       jl        near ptr 00000000000018A5
M02_L06:
       add       r8d,0FFFFFFF8
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 000000000000195C
       movsx     rax,word ptr [rcx+r10*2+2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000001953
       movsx     rax,word ptr [rcx+r10*2+4]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 000000000000194A
       movsx     rax,word ptr [rcx+r10*2+6]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000001941
       movsx     rax,word ptr [rcx+r10*2+8]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000001938
       movsx     rax,word ptr [rcx+r10*2+0A]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 000000000000192F
       movsx     rax,word ptr [rcx+r10*2+0C]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000001926
       movsx     rax,word ptr [rcx+r10*2+0E]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 000000000000191D
       add       r10,8
       cmp       r8d,8
       jge       near ptr 00000000000017FC
M02_L07:
       cmp       r8d,4
       jl        short 0000000000001913
       add       r8d,0FFFFFFFC
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 000000000000195C
       movsx     rax,word ptr [rcx+r10*2+2]
       movsx     r9,dx
       cmp       eax,r9d
       je        near ptr 0000000000001953
       movsx     rax,word ptr [rcx+r10*2+4]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 000000000000194A
       movsx     rax,word ptr [rcx+r10*2+6]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 0000000000001941
       add       r10,4
       test      r8d,r8d
       jle       near ptr 00000000000017E6
M02_L08:
       dec       r8d
       movsx     rax,word ptr [rcx+r10*2]
       movsx     r9,dx
       cmp       eax,r9d
       je        short 000000000000195C
       inc       r10
M02_L09:
       test      r8d,r8d
       jg        short 00000000000018FF
       jmp       near ptr 00000000000017E6
M02_L10:
       lea       eax,[r10+7]
       jmp       near ptr 00000000000017D6
M02_L11:
       lea       eax,[r10+6]
       jmp       near ptr 00000000000017D6
M02_L12:
       lea       eax,[r10+5]
       jmp       near ptr 00000000000017D6
M02_L13:
       lea       eax,[r10+4]
       jmp       near ptr 00000000000017D6
M02_L14:
       lea       eax,[r10+3]
       jmp       near ptr 00000000000017D6
M02_L15:
       lea       eax,[r10+2]
       jmp       near ptr 00000000000017D6
M02_L16:
       lea       eax,[r10+1]
       jmp       near ptr 00000000000017D6
M02_L17:
       mov       eax,r10d
       jmp       near ptr 00000000000017D6
M02_L18:
       vpcmpeqw  ymm1,ymm0,[rax]
       vptest    ymm1,ymm1
       je        near ptr 00000000000017E6
       sub       rax,rcx
       shr       rax,1
       vpshufb   ymm1,ymm1,[1A40]
       vpermq    ymm0,ymm1,0D8
       vpmovmskb ecx,xmm0
       xor       r8d,r8d
       tzcnt     r8d,ecx
       add       eax,r8d
       jmp       near ptr 00000000000017D6
M02_L19:
       vmovd     xmm0,edx
       vpbroadcastw xmm0,xmm0
       mov       rax,rcx
       lea       edx,[r8+0FFF8]
       movsxd    rdx,edx
       lea       rdx,[rax+rdx*2]
       vpcmpeqw  xmm1,xmm0,[rcx]
       vptest    xmm1,xmm1
       jne       short 00000000000019D2
M02_L20:
       add       rax,10
       cmp       rax,rdx
       ja        short 00000000000019F3
       vpcmpeqw  xmm1,xmm0,[rax]
       vptest    xmm1,xmm1
       je        short 00000000000019BE
M02_L21:
       sub       rax,rcx
       shr       rax,1
       vpshufb   xmm0,xmm1,[1A40]
       vpmovmskb r8d,xmm0
       xor       ecx,ecx
       tzcnt     ecx,r8d
       add       eax,ecx
       jmp       near ptr 00000000000017D6
M02_L22:
       mov       eax,r8d
       test      al,7
       je        near ptr 00000000000017E6
       vpcmpeqw  xmm1,xmm0,[rdx]
       vptest    xmm1,xmm1
       je        near ptr 00000000000017E6
       sub       rdx,rcx
       shr       rdx,1
       vpshufb   xmm1,xmm1,[1A40]
       vpmovmskb ecx,xmm1
       xor       eax,eax
       tzcnt     eax,ecx
       add       eax,edx
       jmp       near ptr 00000000000017D6
; Total bytes of code 717
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.ExplicitVector256()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+8]
       mov       r8d,[rcx+18]
       test      rdx,rdx
       je        near ptr 000000000000186C
       cmp       [rdx+8],r8d
       jb        near ptr 000000000000187B
       add       rdx,10
M00_L00:
       mov       rcx,[rcx+10]
       mov       r10d,[rcx+8]
       mov       r9d,10
       inc       r10d
       jmp       short 00000000000017CD
M00_L01:
       xor       r11d,r11d
       tzcnt     r11d,edi
       add       r11d,esi
M00_L02:
       add       eax,r11d
       add       r9,2
M00_L03:
       dec       r10d
       je        near ptr 0000000000001861
       movzx     r11d,word ptr [rcx+r9]
       mov       ebx,r8d
       xor       esi,esi
       cmp       ebx,10
       jl        short 000000000000181D
       vmovd     xmm0,r11d
       vpbroadcastw ymm0,xmm0
       lea       ebx,[r8+0FFF0]
       test      ebx,ebx
       jl        short 000000000000181D
M00_L04:
       movsxd    rdi,esi
       vpcmpeqw  ymm1,ymm0,[rdx+rdi*2]
       vpshufb   ymm1,ymm1,[18A0]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb edi,xmm1
       test      edi,edi
       jne       short 00000000000017BB
       add       esi,10
       cmp       esi,ebx
       jle       short 00000000000017F7
M00_L05:
       cmp       esi,r8d
       jge       short 0000000000001838
       test      esi,esi
       jl        short 0000000000001840
M00_L06:
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        short 0000000000001859
       inc       esi
       cmp       esi,r8d
       jl        short 0000000000001826
M00_L07:
       mov       r11d,0FFFFFFFF
       jmp       short 00000000000017C6
M00_L08:
       cmp       esi,r8d
       jae       short 0000000000001882
       mov       ebx,esi
       movzx     ebx,word ptr [rdx+rbx*2]
       cmp       ebx,r11d
       je        short 0000000000001859
       inc       esi
       cmp       esi,r8d
       jl        short 0000000000001840
       jmp       short 0000000000001838
M00_L09:
       mov       r11d,esi
       jmp       near ptr 00000000000017C6
M00_L10:
       vzeroupper
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L11:
       test      r8d,r8d
       jne       short 000000000000187B
       xor       edx,edx
       xor       r8d,r8d
       jmp       near ptr 00000000000017A8
M00_L12:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L13:
       call      0000000000001788
       int       3
; Total bytes of code 264
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-ZNVNAZ(IterationCount=5, IterationTime=100ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.DeferredPositionLookup.PaddedVector256()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       xor       eax,eax
       mov       rdx,[rcx+10]
       xor       r8d,r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jg        near ptr 000000000000138E
M00_L00:
       vzeroupper
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       lea       r11,[r9+10]
       mov       ebx,[r9+8]
       jmp       near ptr 00000000000013A6
M00_L02:
       xor       r10d,r10d
       tzcnt     r10d,edi
       add       r10d,r9d
       jmp       short 000000000000137B
M00_L03:
       cmp       r9d,ebx
       jae       near ptr 00000000000013F2
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 0000000000001342
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000001322
       jmp       short 0000000000001375
M00_L04:
       mov       r10d,r9d
       jmp       short 000000000000137B
       nop       dword ptr [rax]
       nop       dword ptr [rax+rax]
M00_L05:
       cmp       r9d,ebx
       jge       short 0000000000001375
       test      r9d,r9d
       jl        short 0000000000001322
M00_L06:
       mov       esi,r9d
       movzx     esi,word ptr [r11+rsi*2]
       cmp       esi,r10d
       je        short 0000000000001342
       inc       r9d
       cmp       r9d,ebx
       jl        short 0000000000001360
M00_L07:
       mov       r10d,0FFFFFFFF
M00_L08:
       add       eax,r10d
       inc       r8d
       mov       r10d,[rdx+8]
       cmp       r10d,r8d
       jle       near ptr 00000000000012FD
M00_L09:
       movzx     r10d,word ptr [rdx+r8*2+10]
       mov       r9,[rcx+8]
       test      r9,r9
       jne       near ptr 0000000000001308
       xor       r11d,r11d
       xor       ebx,ebx
M00_L10:
       xor       r9d,r9d
       cmp       ebx,10
       jl        short 0000000000001356
       vmovd     xmm0,r10d
       vpbroadcastw ymm0,xmm0
       lea       esi,[rbx+0FFF0]
       test      esi,esi
       jl        short 0000000000001356
       nop
M00_L11:
       movsxd    rdi,r9d
       vpcmpeqw  ymm1,ymm0,[r11+rdi*2]
       vpshufb   ymm1,ymm1,[1400]
       vpermq    ymm1,ymm1,0D8
       vpmovmskb edi,xmm1
       test      edi,edi
       jne       near ptr 0000000000001315
       add       r9d,10
       cmp       r9d,esi
       jle       short 00000000000013C0
       jmp       near ptr 0000000000001356
M00_L12:
       call      0000000000001788
       int       3
; Total bytes of code 280
```
