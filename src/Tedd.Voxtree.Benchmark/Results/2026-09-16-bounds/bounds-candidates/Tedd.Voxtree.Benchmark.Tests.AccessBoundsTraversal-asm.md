## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000044E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000044E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000044E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CD38]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000448E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003915
       xor       eax,eax
       dec       r10d
       js        near ptr 0000000000003939
       mov       rcx,[rcx+8]
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       mov       rbx,rcx
       lea       esi,[rax+r11+1]
       mov       edi,[rbx+8]
       cmp       esi,edi
       jae       short 000000000000395D
       mov       ebx,[rbx+rsi*4+10]
       mov       rsi,rcx
       cmp       eax,edi
       jae       short 000000000000395D
       mov       eax,eax
       mov       eax,[rsi+rax*4+10]
       bt        eax,r11d
       jb        short 000000000000390B
       mov       eax,ebx
       dec       r10d
       jns       short 00000000000038B2
       jmp       short 0000000000003939
M01_L01:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E5E0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C300]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 227
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004421
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004421
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004421
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0C7B0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 00000000000043CE
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003E0D
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000003E31
       mov       r11d,[rax+8]
M01_L00:
       mov       ebx,r10d
       and       ebx,1F
       sarx      esi,edx,ebx
       and       esi,1
       shl       esi,2
       sarx      edi,r8d,ebx
       and       edi,1
       add       edi,edi
       or        esi,edi
       sarx      ebx,r9d,ebx
       and       ebx,1
       or        ebx,esi
       lea       esi,[rcx+rbx+1]
       cmp       esi,r11d
       jae       short 0000000000003E55
       mov       esi,[rax+rsi*4+10]
       cmp       ecx,r11d
       jae       short 0000000000003E55
       mov       ecx,ecx
       mov       ecx,[rax+rcx*4+10]
       bt        ecx,ebx
       jb        short 0000000000003E03
       mov       ecx,esi
       dec       r10d
       jns       short 0000000000003DB6
       jmp       short 0000000000003E31
M01_L01:
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E220]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C258]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 219
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004661
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004661
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004661
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CC30]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000460E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003999
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 00000000000039C4
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       test      rax,rax
       je        short 00000000000039BD
       mov       ebx,[rax+8]
       mov       ecx,ecx
       lea       rsi,[rcx+9]
       cmp       rbx,rsi
       jb        short 00000000000039BD
       lea       rcx,[rax+rcx*4+10]
       lea       ebx,[r11+1]
       cmp       ebx,9
       jae       short 00000000000039E8
       mov       ebx,[rcx+rbx*4]
       mov       ecx,[rcx]
       bt        ecx,r11d
       jb        short 0000000000003990
       mov       ecx,ebx
       dec       r10d
       jns       short 0000000000003931
       jmp       short 00000000000039C4
M01_L01:
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E4C0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2E8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       call      0000000000001788
       int       3
; Total bytes of code 238
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004561
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004561
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004561
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CC18]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000450E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 000000000000394F
       mov       rax,[rcx+8]
       test      rax,rax
       je        short 0000000000003942
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M01_L00:
       xor       eax,eax
       dec       r10d
       js        short 0000000000003973
M01_L01:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       lea       ebx,[rax+r11+1]
       movsxd    rbx,ebx
       mov       ebx,[rcx+rbx*4]
       cdqe
       mov       eax,[rcx+rax*4]
       bt        eax,r11d
       jb        short 0000000000003946
       mov       eax,ebx
       dec       r10d
       jns       short 00000000000038F9
       jmp       short 0000000000003973
M01_L02:
       xor       ecx,ecx
       jmp       short 00000000000038F2
M01_L03:
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L04:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E580]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C300]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 215
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

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
       jmp       short 00000000000054F3
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000055DD
M00_L01:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000056E8
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000056E8
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000056E8
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000055EE
       cmp       eax,r15d
       jae       near ptr 0000000000005605
       cmp       ecx,r15d
       jae       near ptr 000000000000561E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005637
       xor       r10d,r10d
       dec       r14d
       js        near ptr 00000000000056D4
       mov       r9d,[r8+8]
M00_L02:
       mov       r11d,r14d
       and       r11d,1F
       sarx      ebp,edx,r11d
       and       ebp,1
       shl       ebp,2
       sarx      r15d,eax,r11d
       and       r15d,1
       add       r15d,r15d
       or        ebp,r15d
       sarx      r11d,ecx,r11d
       and       r11d,1
       or        r11d,ebp
       lea       ebp,[r10+r11+1]
       cmp       ebp,r9d
       jae       near ptr 00000000000056E8
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 00000000000056E8
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 00000000000054E3
       mov       r10d,ebp
       dec       r14d
       jns       short 0000000000005575
       jmp       near ptr 00000000000056D4
M00_L03:
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
M00_L04:
       mov       rcx,11980482B18
       call      qword ptr [0F798]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000054E3
M00_L05:
       mov       edx,eax
       mov       rcx,11980492698
       call      qword ptr [0F798]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000054E3
M00_L06:
       mov       edx,ecx
       mov       rcx,119804926B0
       call      qword ptr [0F798]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000054E3
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005645
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000054E3
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
       je        short 00000000000056B4
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000567C
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005695
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
       ja        short 00000000000056E1
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000056E1
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000054E3
M00_L12:
       call      qword ptr [0F810]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000054E3
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004221
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004221
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004221
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0C7E0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 00000000000041CE
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003C15
       xor       eax,eax
       dec       r10d
       js        near ptr 0000000000003C39
       mov       rcx,[rcx+8]
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       mov       rbx,rcx
       lea       esi,[rax+r11+1]
       mov       edi,[rbx+8]
       cmp       esi,edi
       jae       short 0000000000003C5D
       mov       ebx,[rbx+rsi*4+10]
       mov       rsi,rcx
       cmp       eax,edi
       jae       short 0000000000003C5D
       mov       eax,eax
       mov       eax,[rsi+rax*4+10]
       bt        eax,r11d
       jb        short 0000000000003C0B
       mov       eax,ebx
       dec       r10d
       jns       short 0000000000003BB2
       jmp       short 0000000000003C39
M01_L01:
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E490]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 227
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004681
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004681
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004681
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0C798]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000462E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 000000000000406D
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000004091
       mov       r11d,[rax+8]
M01_L00:
       mov       ebx,r10d
       and       ebx,1F
       sarx      esi,edx,ebx
       and       esi,1
       shl       esi,2
       sarx      edi,r8d,ebx
       and       edi,1
       add       edi,edi
       or        esi,edi
       sarx      ebx,r9d,ebx
       and       ebx,1
       or        ebx,esi
       lea       esi,[rcx+rbx+1]
       cmp       esi,r11d
       jae       short 00000000000040B5
       mov       esi,[rax+rsi*4+10]
       cmp       ecx,r11d
       jae       short 00000000000040B5
       mov       ecx,ecx
       mov       ecx,[rax+rcx*4+10]
       bt        ecx,ebx
       jb        short 0000000000004063
       mov       ecx,esi
       dec       r10d
       jns       short 0000000000004016
       jmp       short 0000000000004091
M01_L01:
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E550]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 219
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000040E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000040E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000040E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0C8D0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000408E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003AD9
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000003B04
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       test      rax,rax
       je        short 0000000000003AFD
       mov       ebx,[rax+8]
       mov       ecx,ecx
       lea       rsi,[rcx+9]
       cmp       rbx,rsi
       jb        short 0000000000003AFD
       lea       rcx,[rax+rcx*4+10]
       lea       ebx,[r11+1]
       cmp       ebx,9
       jae       short 0000000000003B28
       mov       ebx,[rcx+rbx*4]
       mov       ecx,[rcx]
       bt        ecx,r11d
       jb        short 0000000000003AD0
       mov       ecx,ebx
       dec       r10d
       jns       short 0000000000003A71
       jmp       short 0000000000003B04
M01_L01:
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E478]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       call      0000000000001788
       int       3
; Total bytes of code 238
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000041E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000041E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000041E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CC18]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000418E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000003D2F
       mov       rax,[rcx+8]
       test      rax,rax
       je        short 0000000000003D22
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M01_L00:
       xor       eax,eax
       dec       r10d
       js        short 0000000000003D53
M01_L01:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       lea       ebx,[rax+r11+1]
       movsxd    rbx,ebx
       mov       ebx,[rcx+rbx*4]
       cdqe
       mov       eax,[rcx+rax*4]
       bt        eax,r11d
       jb        short 0000000000003D26
       mov       eax,ebx
       dec       r10d
       jns       short 0000000000003CD9
       jmp       short 0000000000003D53
M01_L02:
       xor       ecx,ecx
       jmp       short 0000000000003CD2
M01_L03:
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L04:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E4C0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2E8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 215
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

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
       jmp       short 0000000000005673
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 000000000000575D
M00_L01:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+18]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005868
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005868
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005868
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000576E
       cmp       eax,r15d
       jae       near ptr 0000000000005785
       cmp       ecx,r15d
       jae       near ptr 000000000000579E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000057B7
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000005854
       mov       r9d,[r8+8]
M00_L02:
       mov       r11d,r14d
       and       r11d,1F
       sarx      ebp,edx,r11d
       and       ebp,1
       shl       ebp,2
       sarx      r15d,eax,r11d
       and       r15d,1
       add       r15d,r15d
       or        ebp,r15d
       sarx      r11d,ecx,r11d
       and       r11d,1
       or        r11d,ebp
       lea       ebp,[r10+r11+1]
       cmp       ebp,r9d
       jae       near ptr 0000000000005868
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000005868
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 0000000000005663
       mov       r10d,ebp
       dec       r14d
       jns       short 00000000000056F5
       jmp       near ptr 0000000000005854
M00_L03:
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
M00_L04:
       mov       rcx,1A180452B18
       call      qword ptr [0F360]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005663
M00_L05:
       mov       edx,eax
       mov       rcx,1A180462698
       call      qword ptr [0F360]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005663
M00_L06:
       mov       edx,ecx
       mov       rcx,1A1804626B0
       call      qword ptr [0F360]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005663
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000057C5
       mov       ebp,[rbp+10]
       jmp       near ptr 0000000000005663
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
       je        short 0000000000005834
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000057FC
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005815
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
       ja        short 0000000000005861
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005861
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005663
M00_L12:
       call      qword ptr [0F4C8]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005663
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004801
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004801
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004801
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CBE8]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 00000000000047AE
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000004215
       xor       eax,eax
       dec       r10d
       js        near ptr 0000000000004239
       mov       rcx,[rcx+8]
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       mov       rbx,rcx
       lea       esi,[rax+r11+1]
       mov       edi,[rbx+8]
       cmp       esi,edi
       jae       short 000000000000425D
       mov       ebx,[rbx+rsi*4+10]
       mov       rsi,rcx
       cmp       eax,edi
       jae       short 000000000000425D
       mov       eax,eax
       mov       eax,[rsi+rax*4+10]
       bt        eax,r11d
       jae       short 000000000000420C
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L01:
       mov       eax,ebx
       dec       r10d
       jns       short 00000000000041B2
       jmp       short 0000000000004239
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E5F8]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C300]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 227
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004881
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004881
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004881
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CBD0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000482E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 000000000000428D
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 00000000000042B1
       mov       r11d,[rax+8]
M01_L00:
       mov       ebx,r10d
       and       ebx,1F
       sarx      esi,edx,ebx
       and       esi,1
       shl       esi,2
       sarx      edi,r8d,ebx
       and       edi,1
       add       edi,edi
       or        esi,edi
       sarx      ebx,r9d,ebx
       and       ebx,1
       or        ebx,esi
       lea       esi,[rcx+rbx+1]
       cmp       esi,r11d
       jae       short 00000000000042D5
       mov       esi,[rax+rsi*4+10]
       cmp       ecx,r11d
       jae       short 00000000000042D5
       mov       ecx,ecx
       mov       ecx,[rax+rcx*4+10]
       bt        ecx,ebx
       jae       short 0000000000004284
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L01:
       mov       ecx,esi
       dec       r10d
       jns       short 0000000000004236
       jmp       short 00000000000042B1
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E388]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 219
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000048E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000048E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000048E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0C7B0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000488E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000004339
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000004364
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       test      rax,rax
       je        short 000000000000435D
       mov       ebx,[rax+8]
       mov       ecx,ecx
       lea       rsi,[rcx+9]
       cmp       rbx,rsi
       jb        short 000000000000435D
       lea       rcx,[rax+rcx*4+10]
       lea       ebx,[r11+1]
       cmp       ebx,9
       jae       short 0000000000004388
       mov       ebx,[rcx+rbx*4]
       mov       ecx,[rcx]
       bt        ecx,r11d
       jae       short 0000000000004330
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L01:
       mov       ecx,ebx
       dec       r10d
       jns       short 00000000000042D1
       jmp       short 0000000000004364
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E550]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       call      0000000000001788
       int       3
; Total bytes of code 238
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000048E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000048E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000048E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CD80]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000488E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 000000000000438F
       mov       rax,[rcx+8]
       test      rax,rax
       je        short 0000000000004382
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M01_L00:
       xor       eax,eax
       dec       r10d
       js        short 00000000000043B3
M01_L01:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       lea       ebx,[rax+r11+1]
       movsxd    rbx,ebx
       mov       ebx,[rcx+rbx*4]
       cdqe
       mov       eax,[rcx+rax*4]
       bt        eax,r11d
       jae       short 0000000000004386
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L02:
       xor       ecx,ecx
       jmp       short 0000000000004332
M01_L03:
       mov       eax,ebx
       dec       r10d
       jns       short 0000000000004339
       jmp       short 00000000000043B3
M01_L04:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E640]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C300]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 215
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

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
       jae       near ptr 0000000000005879
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005879
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005879
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000577F
       cmp       eax,r15d
       jae       near ptr 0000000000005793
       cmp       ecx,r15d
       jae       near ptr 00000000000057A9
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000057BF
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000005865
       mov       r9d,[r8+8]
M00_L01:
       mov       r11d,r14d
       and       r11d,1F
       sarx      ebp,edx,r11d
       and       ebp,1
       shl       ebp,2
       sarx      r15d,eax,r11d
       and       r15d,1
       add       r15d,r15d
       or        ebp,r15d
       sarx      r11d,ecx,r11d
       and       r11d,1
       or        r11d,ebp
       lea       ebp,[r10+r11+1]
       cmp       ebp,r9d
       jae       near ptr 0000000000005879
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000005879
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       near ptr 0000000000005859
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000005681
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
       mov       rcx,184002D2B18
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000575E
M00_L04:
       mov       edx,eax
       mov       rcx,184002E2608
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000575E
M00_L05:
       mov       edx,ecx
       mov       rcx,184002E2620
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000575E
M00_L06:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000057CA
       mov       ebp,[rbp+10]
       jmp       short 000000000000575E
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
       je        short 0000000000005839
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000005801
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000581A
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
       ja        short 0000000000005872
       add       r15,rdx
       mov       r13d,ecx
M00_L10:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005872
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000575E
M00_L11:
       mov       r10d,ebp
       dec       r14d
       jns       near ptr 0000000000005703
M00_L12:
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000575E
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 543
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000049A1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000049A1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000049A1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CD38]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000494E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.FieldGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 00000000000043B5
       xor       eax,eax
       dec       r10d
       js        near ptr 00000000000043D9
       mov       rcx,[rcx+8]
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       mov       rbx,rcx
       lea       esi,[rax+r11+1]
       mov       edi,[rbx+8]
       cmp       esi,edi
       jae       short 00000000000043FD
       mov       ebx,[rbx+rsi*4+10]
       mov       rsi,rcx
       cmp       eax,edi
       jae       short 00000000000043FD
       mov       eax,eax
       mov       eax,[rsi+rax*4+10]
       bt        eax,r11d
       jae       short 00000000000043AC
       mov       eax,ebx
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L01:
       mov       eax,ebx
       dec       r10d
       jns       short 0000000000004352
       jmp       short 00000000000043D9
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6D0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C318]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 227
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 00000000000049E1
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 00000000000049E1
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 00000000000049E1
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CC00]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 000000000000498E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.LocalGet(Int32, Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 00000000000043ED
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000004411
       mov       r11d,[rax+8]
M01_L00:
       mov       ebx,r10d
       and       ebx,1F
       sarx      esi,edx,ebx
       and       esi,1
       shl       esi,2
       sarx      edi,r8d,ebx
       and       edi,1
       add       edi,edi
       or        esi,edi
       sarx      ebx,r9d,ebx
       and       ebx,1
       or        ebx,esi
       lea       esi,[rcx+rbx+1]
       cmp       esi,r11d
       jae       short 0000000000004435
       mov       esi,[rax+rsi*4+10]
       cmp       ecx,r11d
       jae       short 0000000000004435
       mov       ecx,ecx
       mov       ecx,[rax+rcx*4+10]
       bt        ecx,ebx
       jae       short 00000000000043E4
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L01:
       mov       ecx,esi
       dec       r10d
       jns       short 0000000000004396
       jmp       short 0000000000004411
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E580]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2E8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L04:
       call      0000000000001788
       int       3
; Total bytes of code 219
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceChecked()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004B61
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004B61
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004B61
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CD80]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 0000000000004B0E
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.SliceGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 0000000000004559
       mov       rax,[rcx+8]
       xor       ecx,ecx
       dec       r10d
       js        near ptr 0000000000004584
M01_L00:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       test      rax,rax
       je        short 000000000000457D
       mov       ebx,[rax+8]
       mov       ecx,ecx
       lea       rsi,[rcx+9]
       cmp       rbx,rsi
       jb        short 000000000000457D
       lea       rcx,[rax+rcx*4+10]
       lea       ebx,[r11+1]
       cmp       ebx,9
       jae       short 00000000000045A8
       mov       ebx,[rcx+rbx*4]
       mov       ecx,[rcx]
       bt        ecx,r11d
       jae       short 0000000000004550
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L01:
       mov       ecx,ebx
       dec       r10d
       jns       short 00000000000044F1
       jmp       short 0000000000004584
M01_L02:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6D0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C3C0]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       call      0000000000001788
       int       3
; Total bytes of code 238
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       xor       esi,esi
       xor       edi,edi
M00_L00:
       mov       rdx,[rbx+18]
       cmp       edi,[rdx+8]
       jae       short 0000000000004A01
       mov       r8d,edi
       mov       edx,[rdx+r8*4+10]
       mov       r9,[rbx+20]
       cmp       edi,[r9+8]
       jae       short 0000000000004A01
       mov       r9d,[r9+r8*4+10]
       mov       rcx,[rbx+28]
       cmp       edi,[rcx+8]
       jae       short 0000000000004A01
       mov       ecx,[rcx+r8*4+10]
       mov       r8d,r9d
       mov       r9d,ecx
       mov       rcx,rbx
       call      qword ptr [0CB88]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       add       esi,eax
       inc       edi
       cmp       edi,400
       jl        short 00000000000049AE
       mov       eax,esi
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L01:
       call      0000000000001788
       int       3
; Total bytes of code 103
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.RefGet(Int32, Int32, Int32)
       push      rsi
       push      rbx
       sub       rsp,28
       mov       eax,edx
       or        eax,r8d
       or        eax,r9d
       mov       r10d,[rcx+30]
       mov       r11d,1
       shlx      r11d,r11d,r10d
       cmp       eax,r11d
       jae       short 00000000000043CF
       mov       rax,[rcx+8]
       test      rax,rax
       je        short 00000000000043C2
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M01_L00:
       xor       eax,eax
       dec       r10d
       js        short 00000000000043F3
M01_L01:
       mov       r11d,r10d
       and       r11d,1F
       sarx      ebx,edx,r11d
       and       ebx,1
       shl       ebx,2
       sarx      esi,r8d,r11d
       and       esi,1
       add       esi,esi
       or        ebx,esi
       sarx      r11d,r9d,r11d
       and       r11d,1
       or        r11d,ebx
       lea       ebx,[rax+r11+1]
       movsxd    rbx,ebx
       mov       ebx,[rcx+rbx*4]
       cdqe
       mov       eax,[rcx+rax*4]
       bt        eax,r11d
       jae       short 00000000000043C6
       mov       eax,ebx
       add       rsp,28
       pop       rbx
       pop       rsi
       ret
M01_L02:
       xor       ecx,ecx
       jmp       short 0000000000004372
M01_L03:
       mov       eax,ebx
       dec       r10d
       jns       short 0000000000004379
       jmp       short 00000000000043F3
M01_L04:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E490]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M01_L05:
       mov       rcx,offset MT_System.InvalidOperationException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0C2B8]; Precode of System.InvalidOperationException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 215
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.InvalidOperationException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

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
       jae       near ptr 0000000000005B96
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005B96
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+28]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005B96
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000005AA8
       cmp       eax,r15d
       jae       near ptr 0000000000005ABC
       cmp       ecx,r15d
       jae       near ptr 0000000000005AD2
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005AE8
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000005B82
       mov       r9d,[r8+8]
M00_L01:
       mov       r11d,r14d
       and       r11d,1F
       sarx      ebp,edx,r11d
       and       ebp,1
       shl       ebp,2
       sarx      r15d,eax,r11d
       and       r15d,1
       add       r15d,r15d
       or        ebp,r15d
       sarx      r11d,ecx,r11d
       and       r11d,1
       or        r11d,ebp
       lea       ebp,[r10+r11+1]
       cmp       ebp,r9d
       jae       near ptr 0000000000005B96
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000005B96
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       short 0000000000005A9B
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 00000000000059A1
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
       mov       r10d,ebp
       dec       r14d
       jns       short 0000000000005A23
       jmp       near ptr 0000000000005B82
M00_L04:
       mov       rcx,1B7803D2B18
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005A7A
M00_L05:
       mov       edx,eax
       mov       rcx,1B7803E24C0
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005A7A
M00_L06:
       mov       edx,ecx
       mov       rcx,1B7803E24D8
       call      qword ptr [0F2D0]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005A7A
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005AF3
       mov       ebp,[rbp+10]
       jmp       short 0000000000005A7A
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
       je        short 0000000000005B62
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000005B2A
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005B43
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
       ja        short 0000000000005B8F
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005B8F
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005A7A
M00_L12:
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005A7A
M00_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 540
```
**Method was not JITted yet.**
Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
