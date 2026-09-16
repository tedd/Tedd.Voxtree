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
       jmp       short 0000000000005FBA
       nop       dword ptr [rax]
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 0000000000006097
M00_L02:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000061A2
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000061A2
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000061A2
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000060A8
       cmp       eax,r15d
       jae       near ptr 00000000000060BF
       cmp       ecx,r15d
       jae       near ptr 00000000000060D8
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000060F1
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 000000000000618E
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
       jb        near ptr 0000000000005FA7
       mov       r8d,r11d
       dec       r14d
       jns       short 0000000000006040
       jmp       near ptr 000000000000618E
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
       mov       rcx,1AB802D2B18
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005FAA
M00_L06:
       mov       edx,eax
       mov       rcx,1AB802E2398
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005FAA
M00_L07:
       mov       edx,ecx
       mov       rcx,1AB802E23B0
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 0000000000005FAA
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000060FF
       mov       ebp,[rbp+10]
       jmp       near ptr 0000000000005FAA
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
       je        short 000000000000616E
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000006136
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000614F
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
       ja        short 000000000000619B
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000619B
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005FAA
M00_L13:
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005FAA
M00_L14:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
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
       jmp       short 00000000000057D3
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000058BD
M00_L01:
       mov       rbp,[rbx+18]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000059C8
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000059C8
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000059C8
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000058CE
       cmp       eax,r15d
       jae       near ptr 00000000000058E5
       cmp       ecx,r15d
       jae       near ptr 00000000000058FE
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005917
       xor       r10d,r10d
       dec       r14d
       js        near ptr 00000000000059B4
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
       jae       near ptr 00000000000059C8
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 00000000000059C8
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 00000000000057C3
       mov       r10d,ebp
       dec       r14d
       jns       short 0000000000005855
       jmp       near ptr 00000000000059B4
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
       mov       rcx,28280552B18
       call      qword ptr [0D668]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000057C3
M00_L05:
       mov       edx,eax
       mov       rcx,28280562398
       call      qword ptr [0D668]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000057C3
M00_L06:
       mov       edx,ecx
       mov       rcx,282805623B0
       call      qword ptr [0D668]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000057C3
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005925
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000057C3
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
       je        short 0000000000005994
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000595C
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005975
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
       ja        short 00000000000059C1
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000059C1
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000057C3
M00_L12:
       call      qword ptr [0D6E0]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000057C3
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
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
       jmp       short 000000000000607A
       nop       dword ptr [rax]
M00_L00:
       mov       ebp,r11d
M00_L01:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 0000000000006157
M00_L02:
       mov       rbp,[rbx+10]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006262
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000006262
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000006262
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000006168
       cmp       eax,r15d
       jae       near ptr 000000000000617F
       cmp       ecx,r15d
       jae       near ptr 0000000000006198
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 00000000000061B1
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 000000000000624E
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
       jb        near ptr 0000000000006067
       mov       r8d,r11d
       dec       r14d
       jns       short 0000000000006100
       jmp       near ptr 000000000000624E
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
       mov       rcx,1E101612B18
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000606A
M00_L06:
       mov       edx,eax
       mov       rcx,1E101622398
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000606A
M00_L07:
       mov       edx,ecx
       mov       rcx,1E1016223B0
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 000000000000606A
M00_L08:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000061BF
       mov       ebp,[rbp+10]
       jmp       near ptr 000000000000606A
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
       je        short 000000000000622E
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000061F6
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000620F
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
       ja        short 000000000000625B
       add       r15,rdx
       mov       r13d,ecx
M00_L12:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000625B
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000606A
M00_L13:
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 000000000000606A
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
       jmp       short 00000000000055F3
M00_L00:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jge       near ptr 00000000000056DD
M00_L01:
       mov       rbp,[rbx+18]
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000057E8
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000057E8
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000057E8
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000056EE
       cmp       eax,r15d
       jae       near ptr 0000000000005705
       cmp       ecx,r15d
       jae       near ptr 000000000000571E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005737
       xor       r10d,r10d
       dec       r14d
       js        near ptr 00000000000057D4
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
       jae       near ptr 00000000000057E8
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 00000000000057E8
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jb        near ptr 00000000000055E3
       mov       r10d,ebp
       dec       r14d
       jns       short 0000000000005675
       jmp       near ptr 00000000000057D4
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
       mov       rcx,2A3002D2B18
       call      qword ptr [0D530]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000055E3
M00_L05:
       mov       edx,eax
       mov       rcx,2A3002E2398
       call      qword ptr [0D530]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000055E3
M00_L06:
       mov       edx,ecx
       mov       rcx,2A3002E23B0
       call      qword ptr [0D530]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       near ptr 00000000000055E3
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005745
       mov       ebp,[rbp+10]
       jmp       near ptr 00000000000055E3
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
       je        short 00000000000057B4
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000577C
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005795
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
       ja        short 00000000000057E1
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000057E1
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000055E3
M00_L12:
       call      qword ptr [0D5A8]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000055E3
M00_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 558
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
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
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000684F
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000684F
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 000000000000684F
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000006755
       cmp       eax,r15d
       jae       near ptr 0000000000006769
       cmp       ecx,r15d
       jae       near ptr 000000000000677F
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000006795
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 000000000000683B
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
       jae       near ptr 000000000000682F
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000006661
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
       mov       rcx,214802D2B18
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000006734
M00_L04:
       mov       edx,eax
       mov       rcx,214802E2398
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000006734
M00_L05:
       mov       edx,ecx
       mov       rcx,214802E23B0
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000006734
M00_L06:
       cmp       dword ptr [rbp+24],0
       jne       short 00000000000067A0
       mov       ebp,[rbp+10]
       jmp       short 0000000000006734
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
       je        short 000000000000680F
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 00000000000067D7
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 00000000000067F0
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
       ja        short 0000000000006848
       add       r15,rdx
       mov       r13d,ecx
M00_L10:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000006848
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000006734
M00_L11:
       mov       r8d,r11d
       dec       r14d
       jns       near ptr 00000000000066E7
M00_L12:
       call      qword ptr [0F3A8]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000006734
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
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005FF6
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 0000000000005FF6
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 0000000000005FF6
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 0000000000005F08
       cmp       eax,r15d
       jae       near ptr 0000000000005F1C
       cmp       ecx,r15d
       jae       near ptr 0000000000005F32
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 0000000000005F48
       xor       r10d,r10d
       dec       r14d
       js        near ptr 0000000000005FE2
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
       jae       near ptr 0000000000005FF6
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 0000000000005FF6
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       short 0000000000005EFB
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 0000000000005E01
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
       jns       short 0000000000005E83
       jmp       near ptr 0000000000005FE2
M00_L04:
       mov       rcx,218802D2B18
       call      qword ptr [0D698]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005EDA
M00_L05:
       mov       edx,eax
       mov       rcx,218802E2398
       call      qword ptr [0D698]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005EDA
M00_L06:
       mov       edx,ecx
       mov       rcx,218802E23B0
       call      qword ptr [0D698]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 0000000000005EDA
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000005F53
       mov       ebp,[rbp+10]
       jmp       short 0000000000005EDA
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
       je        short 0000000000005FC2
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000005F8A
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000005FA3
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
       ja        short 0000000000005FEF
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 0000000000005FEF
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 0000000000005EDA
M00_L12:
       call      qword ptr [0D7A0]; Precode of Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 0000000000005EDA
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L14:
       call      0000000000001788
       int       3
; Total bytes of code 540
```
**Method was not JITted yet.**
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowCoordinate(System.String, Int32)
Tedd.Voxtree.Benchmark.Tests.CheckedLookupBaseline.ThrowMalformed()
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
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000068CC
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 00000000000068CC
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 00000000000068CC
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 00000000000067DE
       cmp       eax,r15d
       jae       near ptr 00000000000067F2
       cmp       ecx,r15d
       jae       near ptr 0000000000006808
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 000000000000681E
       lea       r10,[r8+10]
       mov       r8d,[r8+8]
       xor       r8d,r8d
       dec       r14d
       js        near ptr 00000000000068B8
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
       jae       short 00000000000067D1
       mov       ebp,r11d
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 00000000000066E1
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
       jns       short 0000000000006767
       jmp       near ptr 00000000000068B8
M00_L04:
       mov       rcx,293003D2B18
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000067B0
M00_L05:
       mov       edx,eax
       mov       rcx,293003E2398
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000067B0
M00_L06:
       mov       edx,ecx
       mov       rcx,293003E23B0
       call      qword ptr [0F348]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowCoordinate(System.String, Int32)
       mov       ebp,eax
       jmp       short 00000000000067B0
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 0000000000006829
       mov       ebp,[rbp+10]
       jmp       short 00000000000067B0
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
       je        short 0000000000006898
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 0000000000006860
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 0000000000006879
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
       ja        short 00000000000068C5
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 00000000000068C5
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 00000000000067B0
M00_L12:
       call      qword ptr [0F378]; Precode of Tedd.Voxtree.OctreeThrowHelper.ThrowMalformed()
       mov       ebp,eax
       jmp       near ptr 00000000000067B0
M00_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
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

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-GDKDLG(IterationCount=10, IterationTime=300ms, LaunchCount=2, WarmupCount=5))

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
       mov       rax,[rbx+20]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000D477
       mov       ecx,edi
       mov       edx,[rax+rcx*4+10]
       mov       rax,[rbx+28]
       cmp       edi,[rax+8]
       jae       near ptr 000000000000D477
       mov       eax,[rax+rcx*4+10]
       mov       r8,[rbx+30]
       cmp       edi,[r8+8]
       jae       near ptr 000000000000D477
       mov       ecx,[r8+rcx*4+10]
       mov       r14d,[rbp+14]
       mov       r8d,1
       shlx      r15d,r8d,r14d
       cmp       edx,r15d
       jae       near ptr 000000000000D368
       cmp       eax,r15d
       jae       near ptr 000000000000D382
       cmp       ecx,r15d
       jae       near ptr 000000000000D39E
       mov       r8,[rbp+8]
       test      r8,r8
       je        near ptr 000000000000D3BA
       xor       r10d,r10d
       dec       r14d
       js        near ptr 000000000000D457
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
       jae       near ptr 000000000000D477
       mov       ebp,[r8+rbp*4+10]
       cmp       r10d,r9d
       jae       near ptr 000000000000D477
       mov       r10d,r10d
       mov       r10d,[r8+r10*4+10]
       bt        r10d,r11d
       jae       short 000000000000D35B
M00_L02:
       add       esi,ebp
       inc       edi
       cmp       edi,400
       jl        near ptr 000000000000D261
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
       jns       short 000000000000D2E3
       jmp       near ptr 000000000000D457
M00_L04:
       mov       rcx,252002D2B18
       mov       rax,25202EBD7D0
       call      qword ptr [rax]
       mov       ebp,eax
       jmp       short 000000000000D33A
M00_L05:
       mov       edx,eax
       mov       rcx,252002E2398
       mov       rax,25202EBD7D0
       call      qword ptr [rax]
       mov       ebp,eax
       jmp       short 000000000000D33A
M00_L06:
       mov       edx,ecx
       mov       rcx,252002E23B0
       mov       rax,25202EBD7D0
       call      qword ptr [rax]
       mov       ebp,eax
       jmp       short 000000000000D33A
M00_L07:
       cmp       dword ptr [rbp+24],0
       jne       short 000000000000D3C8
       mov       ebp,[rbp+10]
       jmp       near ptr 000000000000D33A
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
       je        short 000000000000D437
       mov       rdx,[rcx]
       test      dword ptr [rdx],80000000
       je        short 000000000000D3FF
       lea       r15,[rcx+10]
       mov       r13d,[rcx+8]
       jmp       short 000000000000D418
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
       ja        short 000000000000D46A
       add       r15,rdx
       mov       r13d,ecx
M00_L11:
       lea       edx,[r14*4+2]
       mov       ecx,edx
       add       rcx,4
       mov       eax,r13d
       cmp       rcx,rax
       ja        short 000000000000D46A
       add       rdx,r15
       mov       ebp,[rdx]
       jmp       near ptr 000000000000D33A
M00_L12:
       mov       rax,25202EBD848
       call      qword ptr [rax]
       mov       ebp,eax
       jmp       near ptr 000000000000D33A
M00_L13:
       mov       rax,7FFB2D047C30
       call      qword ptr [rax]
       int       3
M00_L14:
       call      0000000000000240
       int       3
; Total bytes of code 573
```
**Method was not JITted yet.**
Internal.Runtime.CompilerHelpers.ThrowHelpers.ThrowIndexOutOfRangeException()
