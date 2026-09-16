## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.FieldLength()
       sub       rsp,28
       xor       eax,eax
       xor       edx,edx
       mov       rcx,[rcx+8]
       cmp       dword ptr [rcx+8],0
       jle       short 000000000000F495
       nop       dword ptr [rax]
       nop       dword ptr [rax]
M00_L00:
       mov       r8,rcx
       cmp       edx,[r8+8]
       jae       short 000000000000F49A
       add       eax,[r8+rdx*4+10]
       inc       edx
       cmp       [rcx+8],edx
       jg        short 000000000000F480
M00_L01:
       add       rsp,28
       ret
M00_L02:
       call      0000000000001788
       int       3
; Total bytes of code 64
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.LocalLength()
       mov       rax,[rcx+8]
       xor       ecx,ecx
       mov       edx,[rax+8]
       test      edx,edx
       jle       short 000000000000241B
       add       rax,10
M00_L00:
       add       ecx,[rax]
       add       rax,4
       dec       edx
       jne       short 0000000000002411
M00_L01:
       mov       eax,ecx
       ret
; Total bytes of code 30
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.CheckedPrefix()
       push      rbx
       sub       rsp,20
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       mov       edx,[rax+8]
       cmp       edx,ecx
       jb        short 0000000000002B10
       xor       r8d,r8d
       xor       r10d,r10d
       test      ecx,ecx
       jle       short 0000000000002AF0
       cmp       edx,ecx
       jl        short 0000000000002AF9
       add       rax,10
M00_L00:
       add       r8d,[rax]
       add       rax,4
       dec       ecx
       jne       short 0000000000002AE5
M00_L01:
       mov       eax,r8d
       add       rsp,20
       pop       rbx
       ret
M00_L02:
       cmp       r10d,edx
       jae       short 0000000000002B34
       mov       r9d,r10d
       add       r8d,[rax+r9*4+10]
       inc       r10d
       cmp       r10d,ecx
       jl        short 0000000000002AF9
       jmp       short 0000000000002AF0
M00_L03:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E610]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L04:
       call      0000000000001788
       int       3
; Total bytes of code 122
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.SlicedPrefix()
       sub       rsp,28
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       test      rax,rax
       je        short 00000000000028F5
       cmp       [rax+8],ecx
       jb        short 00000000000028FF
       add       rax,10
M00_L00:
       xor       edx,edx
       test      ecx,ecx
       jle       short 00000000000028EE
       xor       r8d,r8d
M00_L01:
       add       edx,[rax+r8]
       add       r8,4
       dec       ecx
       jne       short 00000000000028E2
M00_L02:
       mov       eax,edx
       add       rsp,28
       ret
M00_L03:
       test      ecx,ecx
       jne       short 00000000000028FF
       xor       eax,eax
       xor       ecx,ecx
       jmp       short 00000000000028D9
M00_L04:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 70
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.RefPrefix()
       sub       rsp,28
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       test      rax,rax
       je        short 0000000000002B38
       cmp       [rax+8],ecx
       jb        short 0000000000002B42
       add       rax,10
M00_L00:
       xor       edx,edx
       xor       r8d,r8d
       test      ecx,ecx
       jle       short 0000000000002B31
M00_L01:
       movsxd    r10,r8d
       add       edx,[rax+r10*4]
       inc       r8d
       cmp       r8d,ecx
       jl        short 0000000000002B22
M00_L02:
       mov       eax,edx
       add       rsp,28
       ret
M00_L03:
       test      ecx,ecx
       jne       short 0000000000002B42
       xor       eax,eax
       xor       ecx,ecx
       jmp       short 0000000000002B19
M00_L04:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 73
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.FieldLength()
       sub       rsp,28
       xor       eax,eax
       xor       edx,edx
       mov       rcx,[rcx+8]
       cmp       dword ptr [rcx+8],0
       jle       short 0000000000001675
       nop       dword ptr [rax]
       nop       dword ptr [rax]
M00_L00:
       mov       r8,rcx
       cmp       edx,[r8+8]
       jae       short 000000000000167A
       add       eax,[r8+rdx*4+10]
       inc       edx
       cmp       [rcx+8],edx
       jg        short 0000000000001660
M00_L01:
       add       rsp,28
       ret
M00_L02:
       call      0000000000001788
       int       3
; Total bytes of code 64
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.LocalLength()
       mov       rax,[rcx+8]
       xor       ecx,ecx
       mov       edx,[rax+8]
       test      edx,edx
       jle       short 0000000000001D5B
       add       rax,10
M00_L00:
       add       ecx,[rax]
       add       rax,4
       dec       edx
       jne       short 0000000000001D51
M00_L01:
       mov       eax,ecx
       ret
; Total bytes of code 30
```

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.CheckedPrefix()
       push      rbx
       sub       rsp,20
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       mov       edx,[rax+8]
       cmp       edx,ecx
       jb        short 00000000000028D0
       xor       r8d,r8d
       xor       r10d,r10d
       test      ecx,ecx
       jle       short 00000000000028B0
       cmp       edx,ecx
       jl        short 00000000000028B9
       add       rax,10
M00_L00:
       add       r8d,[rax]
       add       rax,4
       dec       ecx
       jne       short 00000000000028A5
M00_L01:
       mov       eax,r8d
       add       rsp,20
       pop       rbx
       ret
M00_L02:
       cmp       r10d,edx
       jae       short 00000000000028F4
       mov       r9d,r10d
       add       r8d,[rax+r9*4+10]
       inc       r10d
       cmp       r10d,ecx
       jl        short 00000000000028B9
       jmp       short 00000000000028B0
M00_L03:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E580]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L04:
       call      0000000000001788
       int       3
; Total bytes of code 122
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.SlicedPrefix()
       sub       rsp,28
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       test      rax,rax
       je        short 0000000000001815
       cmp       [rax+8],ecx
       jb        short 000000000000181F
       add       rax,10
M00_L00:
       xor       edx,edx
       test      ecx,ecx
       jle       short 000000000000180E
       xor       r8d,r8d
M00_L01:
       add       edx,[rax+r8]
       add       r8,4
       dec       ecx
       jne       short 0000000000001802
M00_L02:
       mov       eax,edx
       add       rsp,28
       ret
M00_L03:
       test      ecx,ecx
       jne       short 000000000000181F
       xor       eax,eax
       xor       ecx,ecx
       jmp       short 00000000000017F9
M00_L04:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 70
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsLoops.RefPrefix()
       sub       rsp,28
       mov       rax,[rcx+8]
       mov       ecx,[rcx+10]
       test      rax,rax
       je        short 00000000000014B8
       cmp       [rax+8],ecx
       jb        short 00000000000014C2
       add       rax,10
M00_L00:
       xor       edx,edx
       xor       r8d,r8d
       test      ecx,ecx
       jle       short 00000000000014B1
M00_L01:
       movsxd    r10,r8d
       add       edx,[rax+r10*4]
       inc       r8d
       cmp       r8d,ecx
       jl        short 00000000000014A2
M00_L02:
       mov       eax,edx
       add       rsp,28
       ret
M00_L03:
       test      ecx,ecx
       jne       short 00000000000014C2
       xor       eax,eax
       xor       ecx,ecx
       jmp       short 0000000000001499
M00_L04:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
; Total bytes of code 73
```
**Method was not JITted yet.**
System.ThrowHelper.ThrowArgumentOutOfRangeException()
