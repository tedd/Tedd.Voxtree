## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.CheckedProduction()
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
       jmp       short 00000000000084F3
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000085DD
M00_L01:
       mov       rbp,[rbx+18]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000086E8
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000086E8
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000086E8
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000085EE
       cmp       eax,r15d
       jae       near ptr 0000000000008605
       cmp       ecx,r15d
       jae       near ptr 000000000000861E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000008637
       xor       r10d,r10d
       dec       r14d
       js        near ptr 00000000000086D4
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
       jae       near ptr 00000000000086E8
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 00000000000086E8
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 00000000000084E3
       mov       r10d,ebp
       dec       r14d
       jns       short 0000000000008575
       jmp       near ptr 00000000000086D4
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
       mov       rcx,1E900102A48
       call      qword ptr [0F060]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000084E3
M00_L05:
       mov       edx,eax
       mov       rcx,1E900113778
       call      qword ptr [0F060]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000084E3
M00_L06:
       mov       edx,ecx
       mov       rcx,1E900113790
       call      qword ptr [0F060]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000084E3
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000008645
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000084E3
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
       je        short 00000000000086B4
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000867C
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000008695
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
       ja        short 00000000000086E1
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000086E1
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000084E3
M00_L12:
       call      qword ptr [0F0A8]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000084E3
M00_L13:
       call      qword ptr [4750]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.UncheckedProduction()
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
       jmp       short 00000000000064D6
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000065AF
M00_L02:
       mov       rbp,[rbx+20]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000066BA
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000066BA
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000066BA
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000065C0
       cmp       eax,r15d
       jae       near ptr 00000000000065D7
       cmp       ecx,r15d
       jae       near ptr 00000000000065F0
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000006609
       add       r8,10
       xor       r10d,r10d
       dec       r14d
       js        near ptr 00000000000066A6
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
       lea       r11d,[r10+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r8+r11*4]
       movsxd    r10,r10d
       mov       r10d,[r8+r10*4]
       bt        r10d,r9d
       jb        near ptr 00000000000064C3
       mov       r10d,r11d
       dec       r14d
       jns       short 0000000000006558
       jmp       near ptr 00000000000066A6
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
       mov       rcx,27A00102A48
       call      qword ptr [0EEB0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000064C6
M00_L06:
       mov       edx,eax
       mov       rcx,27A00113778
       call      qword ptr [0EEB0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000064C6
M00_L07:
       mov       edx,ecx
       mov       rcx,27A00113790
       call      qword ptr [0EEB0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000064C6
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000006617
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000064C6
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
       je        short 0000000000006686
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000664E
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000006667
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
       ja        short 00000000000066B3
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000066B3
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000064C6
M00_L13:
       call      qword ptr [0EF70]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000064C6
M00_L14:
       call      qword ptr [4018]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001620
       int       3
; Total bytes of code 544
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.CheckedProduction()
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
       jmp       short 0000000000006573
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 000000000000665D
M00_L01:
       mov       rbp,[rbx+18]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006768
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006768
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006768
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000666E
       cmp       eax,r15d
       jae       near ptr 0000000000006685
       cmp       ecx,r15d
       jae       near ptr 000000000000669E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000066B7
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006754
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
       jae       near ptr 0000000000006768
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000006768
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 0000000000006563
       mov       r10d,ebp
       dec       r14d
       jns       short 00000000000065F5
       jmp       near ptr 0000000000006754
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
       mov       rcx,1F680002A48
       call      qword ptr [0F030]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000006563
M00_L05:
       mov       edx,eax
       mov       rcx,1F680013778
       call      qword ptr [0F030]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000006563
M00_L06:
       mov       edx,ecx
       mov       rcx,1F680013790
       call      qword ptr [0F030]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000006563
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000066C5
       mov       ebp,[rbp+10]
       jmp       near ptr 0000000000006563
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
       je        short 0000000000006734
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000066FC
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000006715
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
       ja        short 0000000000006761
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000006761
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000006563
M00_L12:
       call      qword ptr [0F078]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000006563
M00_L13:
       call      qword ptr [4540]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.UncheckedProduction()
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
       jmp       short 0000000000005F96
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 000000000000606F
M00_L02:
       mov       rbp,[rbx+20]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000617A
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000617A
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 000000000000617A
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000006080
       cmp       eax,r15d
       jae       near ptr 0000000000006097
       cmp       ecx,r15d
       jae       near ptr 00000000000060B0
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000060C9
       add       r8,10
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006166
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
       lea       r11d,[r10+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r8+r11*4]
       movsxd    r10,r10d
       mov       r10d,[r8+r10*4]
       bt        r10d,r9d
       jb        near ptr 0000000000005F83
       mov       r10d,r11d
       dec       r14d
       jns       short 0000000000006018
       jmp       near ptr 0000000000006166
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
       mov       rcx,1BB00102A48
       call      qword ptr [0EEF8]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005F86
M00_L06:
       mov       edx,eax
       mov       rcx,1BB00113778
       call      qword ptr [0EEF8]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005F86
M00_L07:
       mov       edx,ecx
       mov       rcx,1BB00113790
       call      qword ptr [0EEF8]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005F86
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000060D7
       mov       ebp,[rbp+10]
       jmp       near ptr 0000000000005F86
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
       je        short 0000000000006146
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000610E
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000006127
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
       ja        short 0000000000006173
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000006173
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005F86
M00_L13:
       call      qword ptr [0EFB8]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005F86
M00_L14:
       call      qword ptr [4750]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L15:
       call      0000000000001620
       int       3
; Total bytes of code 544
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.CheckedProduction()
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
       mov       rbp,[rbx+18]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006256
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006256
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006256
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000006168
       cmp       eax,r15d
       jae       near ptr 000000000000617C
       cmp       ecx,r15d
       jae       near ptr 0000000000006192
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000061A8
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006242
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
       jae       near ptr 0000000000006256
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000006256
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       short 000000000000615B
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000006061
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
       jns       short 00000000000060E3
       jmp       near ptr 0000000000006242
M00_L04:
       mov       rcx,1D180002A48
       call      qword ptr [0F048]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000613A
M00_L05:
       mov       edx,eax
       mov       rcx,1D180013778
       call      qword ptr [0F048]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000613A
M00_L06:
       mov       edx,ecx
       mov       rcx,1D180013790
       call      qword ptr [0F048]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000613A
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000061B3
       mov       ebp,[rbp+10]
       jmp       short 000000000000613A
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
       je        short 0000000000006222
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000061EA
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000006203
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
       ja        short 000000000000624F
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000624F
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000613A
M00_L12:
       call      qword ptr [0F090]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000613A
M00_L13:
       call      qword ptr [4780]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 540
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.UncheckedProduction()
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
       mov       rbp,[rbx+20]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006248
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006248
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006248
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000615A
       cmp       eax,r15d
       jae       near ptr 000000000000616E
       cmp       ecx,r15d
       jae       near ptr 0000000000006184
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 000000000000619A
       add       r8,10
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006234
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
       lea       r11d,[r10+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r8+r11*4]
       movsxd    r10,r10d
       mov       r10d,[r8+r10*4]
       bt        r10d,r9d
       jae       short 000000000000614D
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000006061
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
       mov       r10d,r11d
       dec       r14d
       jns       short 00000000000060E3
       jmp       near ptr 0000000000006234
M00_L04:
       mov       rcx,2B280002A48
       call      qword ptr [0EF70]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L05:
       mov       edx,eax
       mov       rcx,2B280013778
       call      qword ptr [0EF70]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L06:
       mov       edx,ecx
       mov       rcx,2B280013790
       call      qword ptr [0EF70]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000061A5
       mov       ebp,[rbp+10]
       jmp       short 000000000000612C
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
       je        short 0000000000006214
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000061DC
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 00000000000061F5
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
       ja        short 0000000000006241
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000006241
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000612C
M00_L12:
       call      qword ptr [0F030]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000612C
M00_L13:
       call      qword ptr [43C0]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 526
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.CheckedProduction()
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
       mov       rbp,[rbx+18]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006236
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006236
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006236
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000006148
       cmp       eax,r15d
       jae       near ptr 000000000000615C
       cmp       ecx,r15d
       jae       near ptr 0000000000006172
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000006188
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006222
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
       jae       near ptr 0000000000006236
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000006236
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       short 000000000000613B
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000006041
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
       jns       short 00000000000060C3
       jmp       near ptr 0000000000006222
M00_L04:
       mov       rcx,19380102A48
       call      qword ptr [0F0C0]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000611A
M00_L05:
       mov       edx,eax
       mov       rcx,19380113778
       call      qword ptr [0F0C0]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000611A
M00_L06:
       mov       edx,ecx
       mov       rcx,19380113790
       call      qword ptr [0F0C0]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000611A
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000006193
       mov       ebp,[rbp+10]
       jmp       short 000000000000611A
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
       je        short 0000000000006202
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000061CA
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 00000000000061E3
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
       ja        short 000000000000622F
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000622F
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000611A
M00_L12:
       call      qword ptr [0F108]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000611A
M00_L13:
       call      qword ptr [4018]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 540
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()

## .NET 11.0.0 (11.0.0-preview.7.26381.103, 11.0.26.38203), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsTraversal.UncheckedProduction()
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
       mov       rbp,[rbx+20]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006248
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+30]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006248
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+38]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006248
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000615A
       cmp       eax,r15d
       jae       near ptr 000000000000616E
       cmp       ecx,r15d
       jae       near ptr 0000000000006184
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 000000000000619A
       add       r8,10
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000006234
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
       lea       r11d,[r10+r9+1]
       movsxd    r11,r11d
       mov       r11d,[r8+r11*4]
       movsxd    r10,r10d
       mov       r10d,[r8+r10*4]
       bt        r10d,r9d
       jae       short 000000000000614D
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000006061
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
       mov       r10d,r11d
       dec       r14d
       jns       short 00000000000060E3
       jmp       near ptr 0000000000006234
M00_L04:
       mov       rcx,21780102A48
       call      qword ptr [0EEE0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L05:
       mov       edx,eax
       mov       rcx,21780113778
       call      qword ptr [0EEE0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L06:
       mov       edx,ecx
       mov       rcx,21780113790
       call      qword ptr [0EEE0]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 000000000000612C
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000061A5
       mov       ebp,[rbp+10]
       jmp       short 000000000000612C
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
       je        short 0000000000006214
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000061DC
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 00000000000061F5
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
       ja        short 0000000000006241
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000006241
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000612C
M00_L12:
       call      qword ptr [0EFB8]; Precode of Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000612C
M00_L13:
       call      qword ptr [0FFA8]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001620
       int       3
; Total bytes of code 526
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.UncheckedLookupCandidate.ThrowMalformed()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()
