## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-GDKDLG(IterationCount=10, IterationTime=300ms, LaunchCount=2, WarmupCount=5))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.Production()
       push      r15
       push      r14
       push      r13
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,30
       xor       eax,eax
       mov       [rsp+20],rax
       mov       [rsp+28],rax
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
       jmp       short 000000000000537A
       nop       dword ptr [rax]
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 0000000000005457
M00_L02:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005562
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005562
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005562
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000005468
       cmp       eax,r15d
       jae       near ptr 000000000000547F
       cmp       ecx,r15d
       jae       near ptr 0000000000005498
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000054B1
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 000000000000554E
M00_L03:
       mov       r9d,r14d
       and       r9d,1F
       sarx      r11d,edx,r9d
       and       r11d,1
       shl       r11d,2
       sarx      ebp,eax,r9d
       and       ebp,1
       add       ebp,ebp
       or        r11d,ebp
       sarx      r9d,ecx,r9d
       and       r9d,1
       or        r9d,r11d
       lea       r11d,[r8+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r10+r11*4]
       movsxd    r8,r8d
       mov       r8d,[r10+r8*4]
       bt        r8d,r9d
       jb        near ptr 0000000000005367
       mov       r8d,r11d
       dec       r14d
       jns       short 0000000000005400
       jmp       near ptr 000000000000554E
M00_L04:
       mov       eax,esi
       add       rsp,30
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L05:
       mov       rcx,1D100302B18
       call      qword ptr [0F708]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000536A
M00_L06:
       mov       edx,eax
       mov       rcx,1D100312698
       call      qword ptr [0F708]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000536A
M00_L07:
       mov       edx,ecx
       mov       rcx,1D1003126B0
       call      qword ptr [0F708]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000536A
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000054BF
       mov       ebp,[rbp+10]
       jmp       near ptr 000000000000536A
M00_L09:
       shlx      r14d,edx,r14d
       add       r14d,eax
       imul      r14d,r15d
       add       r14d,ecx
       add       rbp,18
       xor       r15d,r15d
       xor       r13d,r13d
       mov       rcx,[rbp]
       test      rcx,rcx
       je        short 000000000000552E
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000054F6
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000550F
M00_L10:
       lea       rdx,[rsp+20]
       mov       rax,[rcx]
       mov       rax,[rax+40]
       call      qword ptr [rax+28]
       mov       r15,[rsp+20]
       mov       r13d,[rsp+28]
M00_L11:
       mov       edx,[rbp+8]
       and       edx,7FFFFFFF
       mov       ecx,[rbp+0C]
       mov       eax,ecx
       add       rax,rdx
       mov       r8d,r13d
       cmp       rax,r8
       ja        short 000000000000555B
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000555B
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000536A
M00_L13:
       call      qword ptr [0F780]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000536A
M00_L14:
       call      qword ptr [7C48]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001788
       int       3
; Total bytes of code 552
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-GDKDLG(IterationCount=10, IterationTime=300ms, LaunchCount=2, WarmupCount=5))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.Production()
       push      r15
       push      r14
       push      r13
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,30
       xor       eax,eax
       mov       [rsp+20],rax
       mov       [rsp+28],rax
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
       jmp       short 00000000000051FA
       nop       dword ptr [rax]
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000052D7
M00_L02:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000053E2
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000053E2
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000053E2
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000052E8
       cmp       eax,r15d
       jae       near ptr 00000000000052FF
       cmp       ecx,r15d
       jae       near ptr 0000000000005318
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005331
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 00000000000053CE
M00_L03:
       mov       r9d,r14d
       and       r9d,1F
       sarx      r11d,edx,r9d
       and       r11d,1
       shl       r11d,2
       sarx      ebp,eax,r9d
       and       ebp,1
       add       ebp,ebp
       or        r11d,ebp
       sarx      r9d,ecx,r9d
       and       r9d,1
       or        r9d,r11d
       lea       r11d,[r8+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r10+r11*4]
       movsxd    r8,r8d
       mov       r8d,[r10+r8*4]
       bt        r8d,r9d
       jb        near ptr 00000000000051E7
       mov       r8d,r11d
       dec       r14d
       jns       short 0000000000005280
       jmp       near ptr 00000000000053CE
M00_L04:
       mov       eax,esi
       add       rsp,30
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L05:
       mov       rcx,2CA00202B18
       call      qword ptr [0F198]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000051EA
M00_L06:
       mov       edx,eax
       mov       rcx,2CA002124C0
       call      qword ptr [0F198]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000051EA
M00_L07:
       mov       edx,ecx
       mov       rcx,2CA002124D8
       call      qword ptr [0F198]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000051EA
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 000000000000533F
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000051EA
M00_L09:
       shlx      r14d,edx,r14d
       add       r14d,eax
       imul      r14d,r15d
       add       r14d,ecx
       add       rbp,18
       xor       r15d,r15d
       xor       r13d,r13d
       mov       rcx,[rbp]
       test      rcx,rcx
       je        short 00000000000053AE
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000005376
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000538F
M00_L10:
       lea       rdx,[rsp+20]
       mov       rax,[rcx]
       mov       rax,[rax+40]
       call      qword ptr [rax+28]
       mov       r15,[rsp+20]
       mov       r13d,[rsp+28]
M00_L11:
       mov       edx,[rbp+8]
       and       edx,7FFFFFFF
       mov       ecx,[rbp+0C]
       mov       eax,ecx
       add       rax,rdx
       mov       r8d,r13d
       cmp       rax,r8
       ja        short 00000000000053DB
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000053DB
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000051EA
M00_L13:
       call      qword ptr [0F210]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000051EA
M00_L14:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001788
       int       3
; Total bytes of code 552
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-GDKDLG(IterationCount=10, IterationTime=300ms, LaunchCount=2, WarmupCount=5))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.Production()
       push      r15
       push      r14
       push      r13
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,30
       xor       eax,eax
       mov       [rsp+20],rax
       mov       [rsp+28],rax
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000578F
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000578F
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 000000000000578F
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000005695
       cmp       eax,r15d
       jae       near ptr 00000000000056A9
       cmp       ecx,r15d
       jae       near ptr 00000000000056BF
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000056D5
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 000000000000577B
M00_L01:
       mov       r9d,r14d
       and       r9d,1F
       sarx      r11d,edx,r9d
       and       r11d,1
       shl       r11d,2
       sarx      ebp,eax,r9d
       and       ebp,1
       add       ebp,ebp
       or        r11d,ebp
       sarx      r9d,ecx,r9d
       and       r9d,1
       or        r9d,r11d
       lea       r11d,[r8+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r10+r11*4]
       movsxd    r8,r8d
       mov       r8d,[r10+r8*4]
       bt        r8d,r9d
       jae       near ptr 000000000000576F
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 00000000000055A1
       mov       eax,esi
       add       rsp,30
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L03:
       mov       rcx,20F802D2B18
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005674
M00_L04:
       mov       edx,eax
       mov       rcx,20F802E24C0
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005674
M00_L05:
       mov       edx,ecx
       mov       rcx,20F802E24D8
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005674
M00_L06:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000056E0
       mov       ebp,[rbp+10]
       jmp       short 0000000000005674
M00_L07:
       shlx      r14d,edx,r14d
       add       r14d,eax
       imul      r14d,r15d
       add       r14d,ecx
       add       rbp,18
       xor       r15d,r15d
       xor       r13d,r13d
       mov       rcx,[rbp]
       test      rcx,rcx
       je        short 000000000000574F
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000005717
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005730
M00_L08:
       lea       rdx,[rsp+20]
       mov       rax,[rcx]
       mov       rax,[rax+40]
       call      qword ptr [rax+28]
       mov       r15,[rsp+20]
       mov       r13d,[rsp+28]
M00_L09:
       mov       edx,[rbp+8]
       and       edx,7FFFFFFF
       mov       ecx,[rbp+0C]
       mov       eax,ecx
       add       rax,rdx
       mov       r8d,r13d
       cmp       rax,r8
       ja        short 0000000000005788
       add       r15,rdx
       mov       r13d,ecx
M00_L10:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005788
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005674
M00_L11:
       mov       r8d,r11d
       dec       r14d
       jns       near ptr 0000000000005627
M00_L12:
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005674
M00_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 533
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-GDKDLG(IterationCount=10, IterationTime=300ms, LaunchCount=2, WarmupCount=5))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.Production()
       push      r15
       push      r14
       push      r13
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,30
       xor       eax,eax
       mov       [rsp+20],rax
       mov       [rsp+28],rax
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005A0C
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005A0C
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005A0C
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000591E
       cmp       eax,r15d
       jae       near ptr 0000000000005932
       cmp       ecx,r15d
       jae       near ptr 0000000000005948
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 000000000000595E
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 00000000000059F8
M00_L01:
       mov       r9d,r14d
       and       r9d,1F
       sarx      r11d,edx,r9d
       and       r11d,1
       shl       r11d,2
       sarx      ebp,eax,r9d
       and       ebp,1
       add       ebp,ebp
       or        r11d,ebp
       sarx      r9d,ecx,r9d
       and       r9d,1
       or        r9d,r11d
       lea       r11d,[r8+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r10+r11*4]
       movsxd    r8,r8d
       mov       r8d,[r10+r8*4]
       bt        r8d,r9d
       jae       short 0000000000005911
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000005821
       mov       eax,esi
       add       rsp,30
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L03:
       mov       r8d,r11d
       dec       r14d
       jns       short 00000000000058A7
       jmp       near ptr 00000000000059F8
M00_L04:
       mov       rcx,1D200552B18
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000058F0
M00_L05:
       mov       edx,eax
       mov       rcx,1D2005624C0
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000058F0
M00_L06:
       mov       edx,ecx
       mov       rcx,1D2005624D8
       call      qword ptr [0F258]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000058F0
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005969
       mov       ebp,[rbp+10]
       jmp       short 00000000000058F0
M00_L08:
       shlx      r14d,edx,r14d
       add       r14d,eax
       imul      r14d,r15d
       add       r14d,ecx
       add       rbp,18
       xor       r15d,r15d
       xor       r13d,r13d
       mov       rcx,[rbp]
       test      rcx,rcx
       je        short 00000000000059D8
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000059A0
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 00000000000059B9
M00_L09:
       lea       rdx,[rsp+20]
       mov       rax,[rcx]
       mov       rax,[rax+40]
       call      qword ptr [rax+28]
       mov       r15,[rsp+20]
       mov       r13d,[rsp+28]
M00_L10:
       mov       edx,[rbp+8]
       and       edx,7FFFFFFF
       mov       ecx,[rbp+0C]
       mov       eax,ecx
       add       rax,rdx
       mov       r8d,r13d
       cmp       rax,r8
       ja        short 0000000000005A05
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005A05
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000058F0
M00_L12:
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000058F0
M00_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 530
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
