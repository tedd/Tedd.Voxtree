## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.Production()
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,48
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqa   xmmword ptr [rsp+30],xmm4
       mov       [rsp+40],rax
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000075E
       lea       rbx,[rax+10]
       mov       esi,[rax+8]
M00_L00:
       mov       rax,[rcx+10]
       test      rax,rax
       je        near ptr 0000000000000767
       lea       rdi,[rax+10]
       mov       ebp,[rax+8]
M00_L01:
       mov       r14d,[rcx+18]
       mov       ecx,[rcx+1C]
       mov       r15d,ecx
       test      ecx,ecx
       sete      r13b
       movzx     r13d,r13b
       mov       ecx,r14d
       call      qword ptr [0CDF8]; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       test      r15d,r15d
       je        short 00000000000006BA
       cmp       r15d,1
       jne       near ptr 0000000000000770
M00_L02:
       test      r13d,r13d
       je        short 00000000000006C9
       cmp       r13d,1
       jne       near ptr 00000000000007AC
M00_L03:
       lea       ecx,[r14+r14*2]
       mov       eax,1
       shlx      r12d,eax,ecx
       cmp       esi,r12d
       jne       near ptr 00000000000007E8
       cmp       ebp,r12d
       jl        near ptr 00000000000007E8
       cmp       r12d,ebp
       ja        near ptr 0000000000000824
       cmp       r15d,r13d
       je        near ptr 000000000000082B
       test      r12d,r12d
       je        short 0000000000000722
       mov       rcx,rdi
       sub       rcx,rbx
       movsxd    rax,r12d
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000000843
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000000843
M00_L04:
       mov       [rsp+38],rbx
       mov       [rsp+40],r12d
       mov       [rsp+28],rdi
       mov       [rsp+30],r12d
       lea       rcx,[rsp+38]
       lea       rdx,[rsp+28]
       mov       r8d,r14d
       mov       r9d,r15d
       call      qword ptr [0CDE0]; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
M00_L05:
       nop
       add       rsp,48
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L06:
       xor       ebx,ebx
       xor       esi,esi
       jmp       near ptr 000000000000067A
M00_L07:
       xor       edi,edi
       xor       ebp,ebp
       jmp       near ptr 000000000000068E
M00_L08:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2AB8A8
       call      qword ptr [6C58]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CE70]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L09:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2AB8A8
       call      qword ptr [6C58]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CE70]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L10:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,435
       mov       rdx,7FFB2D2AB8A8
       call      qword ptr [6C58]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0D488]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L11:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L12:
       mov       r8d,r12d
       shl       r8,2
       mov       rcx,rdi
       mov       rdx,rbx
       call      qword ptr [5818]; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       jmp       near ptr 000000000000074C
M00_L13:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,46B
       mov       rdx,7FFB2D2AB8A8
       call      qword ptr [6C58]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0D488]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 575
```
```assembly
; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,50
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+30],ymm4
       mov       ebx,ecx
       cmp       ebx,9
       ja        short 0000000000000DCA
       vzeroupper
       add       rsp,50
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L00:
       mov       rcx,offset MT_System.Int32
       call      0000000000005240
       mov       rsi,rax
       mov       [rsi+8],ebx
       lea       rcx,[rsp+28]
       mov       edx,31
       mov       r8d,1
       call      qword ptr [67C0]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       ja        short 0000000000000E77
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       cmp       eax,30
       jb        short 0000000000000E48
       vmovups   ymm0,[0F20]
       vmovups   [rdx],ymm0
       vmovups   ymm0,[0F40]
       vmovups   [rdx+20],ymm0
       vmovups   ymm0,[0F60]
       vmovups   [rdx+40],ymm0
       mov       ecx,[rsp+38]
       add       ecx,30
       mov       [rsp+38],ecx
       jmp       short 0000000000000E5D
M01_L01:
       lea       rcx,[rsp+28]
       mov       rdx,23200562818
       call      qword ptr [67D8]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L02:
       lea       rcx,[rsp+28]
       mov       edx,9
       call      qword ptr [6AF0]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       jbe       short 0000000000000E7E
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       je        short 0000000000000EA2
       mov       word ptr [rdx],2E
       mov       ecx,[rsp+38]
       inc       ecx
       mov       [rsp+38],ecx
       jmp       short 0000000000000EB7
M01_L05:
       lea       rcx,[rsp+28]
       mov       rdx,23200550658
       call      qword ptr [67D8]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L06:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,12BF
       mov       rdx,7FFB2D2AB8A8
       call      qword ptr [6C58]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdi,rax
       lea       rcx,[rsp+28]
       call      qword ptr [67F0]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       mov       r9,rax
       mov       rdx,rdi
       mov       r8,rsi
       mov       rcx,rbx
       call      qword ptr [0C0F0]; Precode of System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 359
```
```assembly
; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,48
       lea       rbp,[rsp+20]
       mov       rax,74B321E1913E
       mov       [rbp+8],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       edx,4
       mul       rdx
       jb        near ptr 000000000000A965
       test      rax,rax
       je        short 000000000000A7EE
       add       rax,0F
       shr       rax,4
       add       rsp,20
M02_L00:
       push      0
       push      0
       dec       rax
       jne       short 000000000000A7DC
       sub       rsp,20
       lea       rax,[rsp+20]
M02_L01:
       test      r8d,r8d
       jl        near ptr 000000000000A958
       xor       edx,edx
       test      r8d,r8d
       jle       short 000000000000A836
       xor       esi,esi
       mov       edi,24924924
       pdep      esi,esi,edi
       xor       edi,edi
       mov       r14d,12492492
       pdep      edi,edi,r14d
       or        esi,edi
       nop       dword ptr [rax]
M02_L02:
       mov       edi,9249249
       pdep      edi,edx,edi
       or        edi,esi
       mov       [rax+rdx*4],edi
       inc       edx
       cmp       edx,r8d
       jl        short 000000000000A820
M02_L03:
       xor       edx,edx
       test      r9d,r9d
       jne       near ptr 000000000000A8E0
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 000000000000A8B9
M02_L04:
       mov       [rbp+24],r9d
       mov       esi,r9d
       mov       [rbp+18],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L05:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L06:
       mov       r9d,[rax+r13]
       shl       r9d,2
       or        r9d,r15d
       lea       esi,[rdx+1]
       cmp       r9d,r11d
       jae       near ptr 000000000000A95F
       cmp       edx,ecx
       jae       near ptr 000000000000A95F
       mov       edx,edx
       mov       edx,[rbx+rdx*4]
       mov       [r10+r9*4],edx
       add       r13,4
       dec       r12d
       mov       edx,esi
       jne       short 000000000000A86D
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+18]
       jne       short 000000000000A859
       mov       r9d,[rbp+24]
       inc       r9d
       cmp       r9d,r8d
       jl        short 000000000000A849
M02_L07:
       mov       r8,74B321E1913E
       cmp       [rbp+8],r8
       je        short 000000000000A8CE
       call      000000000000BD80
M02_L08:
       nop
       lea       rsp,[rbp+28]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M02_L09:
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 000000000000A8B9
M02_L10:
       mov       [rbp+20],r9d
       mov       esi,r9d
       mov       [rbp+10],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L11:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L12:
       lea       r9d,[rdx+1]
       cmp       edx,r11d
       jae       short 000000000000A95F
       mov       edx,edx
       lea       rdx,[r10+rdx*4]
       mov       esi,[rax+r13]
       shl       esi,2
       or        esi,r15d
       cmp       esi,ecx
       jae       short 000000000000A95F
       mov       esi,[rbx+rsi*4]
       mov       [rdx],esi
       add       r13,4
       dec       r12d
       mov       edx,r9d
       jne       short 000000000000A90C
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+10]
       jne       short 000000000000A8F8
       mov       r9d,[rbp+20]
       inc       r9d
       cmp       r9d,r8d
       jl        short 000000000000A8E8
       jmp       near ptr 000000000000A8B9
M02_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M02_L14:
       call      0000000000001788
       int       3
M02_L15:
       call      0000000000001770
       int       3
; Total bytes of code 491
```
```assembly
; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       mov       rax,rcx
       sub       rax,rdx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       mov       rax,rdx
       sub       rax,rcx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       lea       rax,[rdx+r8]
       lea       r10,[rcx+r8]
       cmp       r8,10
       jbe       short 000000000000C0AB
       cmp       r8,40
       ja        near ptr 000000000000C0F3
M03_L00:
       vmovups   xmm0,[rdx]
       vmovups   [rcx],xmm0
       cmp       r8,20
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+10]
       vmovups   [rcx+10],xmm0
       cmp       r8,30
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+20]
       vmovups   [rcx+20],xmm0
       jmp       near ptr 000000000000C13D
M03_L01:
       test      r8b,18
       je        short 000000000000C0C4
       mov       r8,[rdx]
       mov       [rcx],r8
       mov       rdx,[rax+0FFF8]
       mov       [r10+0FFF8],rdx
       jmp       near ptr 000000000000C148
M03_L02:
       test      r8b,4
       jne       short 000000000000C0E6
       test      r8,r8
       je        short 000000000000C148
       movzx     edx,byte ptr [rdx]
       mov       [rcx],dl
       test      r8b,2
       je        short 000000000000C148
       movsx     rcx,word ptr [rax+0FFFE]
       mov       [r10+0FFFE],cx
       jmp       short 000000000000C148
M03_L03:
       mov       edx,[rdx]
       mov       [rcx],edx
       mov       ecx,[rax+0FFFC]
       mov       [r10+0FFFC],ecx
       jmp       short 000000000000C148
M03_L04:
       cmp       r8,800
       ja        near ptr 000000000000C180
       cmp       r8,100
       jae       short 000000000000C14C
M03_L05:
       mov       r9,r8
       shr       r9,6
M03_L06:
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rcx,40
       add       rdx,40
       dec       r9
       jne       short 000000000000C110
       and       r8,3F
       cmp       r8,10
       ja        near ptr 000000000000C076
M03_L07:
       vmovups   xmm0,[rax+0FFF0]
       vmovups   [r10+0FFF0],xmm0
M03_L08:
       vzeroupper
       ret
M03_L09:
       mov       r9,rcx
       and       r9,3F
       neg       r9
       add       r9,40
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rdx,r9
       add       rcx,r9
       sub       r8,r9
       jmp       short 000000000000C109
M03_L10:
       cmp       rcx,rdx
       jne       short 000000000000C180
       cmp       [rdx],dl
       jmp       short 000000000000C148
M03_L11:
       cmp       [rcx],cl
       cmp       [rdx],dl
       vzeroupper
       jmp       qword ptr [66E8]; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
; Total bytes of code 333
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       mov       esi,edx
       mov       edi,r8d
       xor       eax,eax
       mov       [rbx],rax
       call      qword ptr [0A098]
       mov       rcx,[rax]
       imul      edx,edi,0B
       add       edx,esi
       mov       eax,100
       cmp       edx,100
       cmovle    edx,eax
       cmp       [rcx],ecx
       call      qword ptr [98B8]; Precode of System.Text.UTF8Encoding.GetMaxByteCount(Int32)
       mov       [rbx+8],rax
       test      rax,rax
       je        short 000000000000C4E0
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M04_L00:
       mov       [rbx+18],rcx
       mov       [rbx+20],eax
       xor       eax,eax
       mov       [rbx+10],eax
       mov       byte ptr [rbx+14],0
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M04_L01:
       xor       ecx,ecx
       xor       eax,eax
       jmp       short 000000000000C4C8
; Total bytes of code 102
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,58
       xorps     xmm4,xmm4
       movaps    [rsp+30],xmm4
       movaps    [rsp+40],xmm4
       mov       rbx,rcx
       mov       esi,edx
       cmp       byte ptr [rbx+14],0
       jne       short 000000000000F15B
M05_L00:
       lea       rdx,[rbx+18]
       mov       r8d,[rbx+10]
       mov       edi,[rdx+8]
       cmp       r8d,edi
       ja        near ptr 000000000000F1D8
       mov       rdx,[rdx]
       mov       ecx,r8d
       lea       rbp,[rdx+rcx*2]
       sub       edi,r8d
       mov       rcx,[rbx]
       test      esi,esi
       jl        short 000000000000F173
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       rdx,[rsp+40]
       lea       r8,[rsp+50]
       mov       ecx,esi
       call      qword ptr [0CF8]; Precode of System.Number.TryUInt32ToDecStr[[System.Char, System.Private.CoreLib]](UInt32, System.Span`1<Char>, Int32 ByRef)
M05_L01:
       test      eax,eax
       jne       short 000000000000F152
       mov       rcx,rbx
       call      qword ptr [4FF8]
       jmp       short 000000000000F100
M05_L02:
       mov       eax,[rsp+50]
       add       [rbx+10],eax
       jmp       short 000000000000F169
M05_L03:
       mov       rcx,rbx
       mov       edx,esi
       xor       r8d,r8d
       call      qword ptr [1B50]
M05_L04:
       nop
       add       rsp,58
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M05_L05:
       test      rcx,rcx
       je        short 000000000000F180
       call      qword ptr [1260]; Precode of System.Globalization.NumberFormatInfo.<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider)
       jmp       short 000000000000F186
M05_L06:
       call      qword ptr [1248]; Precode of System.Globalization.NumberFormatInfo.get_CurrentInfo()
M05_L07:
       mov       r8,[rax+28]
       test      r8,r8
       jne       short 000000000000F197
       xor       r9d,r9d
       xor       r8d,r8d
       jmp       short 000000000000F19F
M05_L08:
       lea       r9,[r8+0C]
       mov       r8d,[r8+8]
M05_L09:
       mov       [rsp+30],r9
       mov       [rsp+38],r8d
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       r8,[rsp+50]
       mov       [rsp+20],r8
       lea       r8,[rsp+30]
       lea       r9,[rsp+40]
       mov       ecx,esi
       mov       edx,0FFFFFFFF
       call      qword ptr [0CE0]
       jmp       near ptr 000000000000F143
M05_L10:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 255
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,38
       xor       eax,eax
       mov       [rsp+28],rax
       mov       rbx,rcx
       lea       rsi,[rbx+18]
       mov       rcx,rsi
       mov       eax,[rbx+10]
       cmp       eax,[rcx+8]
       ja        short 000000000000C6F7
       mov       rcx,[rcx]
       mov       [rsp+28],rcx
       mov       [rsp+30],eax
       lea       rcx,[rsp+28]
       call      qword ptr [0BB28]; Precode of System.String.Ctor(System.ReadOnlySpan`1<Char>)
       mov       rdi,rax
       mov       rbp,[rbx+8]
       xor       eax,eax
       mov       [rbx+8],rax
       mov       [rsi],rax
       mov       [rsi+8],rax
       mov       [rbx+10],eax
       test      rbp,rbp
       je        short 000000000000C6EB
       call      qword ptr [0A098]
       mov       rcx,[rax]
       mov       rdx,rbp
       xor       r8d,r8d
       cmp       [rcx],ecx
       call      qword ptr [98C0]; Precode of System.IO.StreamWriter.Flush(Boolean, Boolean)
M06_L00:
       mov       rax,rdi
       add       rsp,38
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M06_L01:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 126
```
```assembly
; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,0A8
       lea       rbp,[rsp+0E0]
       mov       [rbp+0FFC0],rcx
       mov       [rbp+0FFB8],rdx
       mov       [rbp+0FF58],rcx
       mov       [rbp+0FF50],rdx
       mov       [rbp+0FF48],r8
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9030]; CORINFO_HELP_JIT_PINVOKE_BEGIN
       mov       rax,[5A58]
       mov       rcx,[rbp+0FF58]
       mov       rdx,[rbp+0FF50]
       mov       r8,[rbp+0FF48]
       call      qword ptr [rax]
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9038]; CORINFO_HELP_JIT_PINVOKE_END
       xor       eax,eax
       mov       [rbp+0FFB8],rax
       mov       [rbp+0FFC0],rax
       add       rsp,0A8
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
; Total bytes of code 142
```
**Method was not JITted yet.**
System.String.StrCns(UInt32, IntPtr)
System.ArgumentOutOfRangeException..ctor(System.String)
System.ArgumentException..ctor(System.String)
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.PrevalidatedRows()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 0000000000001B0D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000001B16
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 0000000000001B1F
       cmp       r9d,1
       ja        near ptr 0000000000001B1F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000001B43
       cmp       edx,edi
       jl        near ptr 0000000000001B43
       cmp       edi,edx
       ja        near ptr 0000000000001B67
       test      edi,edi
       je        short 0000000000001AE2
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000001B6E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000001B6E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CF60]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000001A65
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000001A79
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6A0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF30]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF30]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,58
       lea       rbp,[rsp+20]
       mov       rax,0AF801F6A0525
       mov       [rbp],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       [rbp+34],r8d
       mov       esi,r8d
       mov       [rbp+28],rsi
       mov       eax,4
       mul       rsi
       jb        near ptr 0000000000009758
       test      rax,rax
       je        short 0000000000009596
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000009584
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 000000000000974B
       mov       edx,r8d
       mov       [rbp+30],edx
       xor       edi,edi
       test      r8d,r8d
       jle       short 00000000000095E9
       xor       r14d,r14d
       mov       r15d,24924924
       pdep      r14d,r14d,r15d
       xor       r15d,r15d
       mov       r13d,12492492
       pdep      r15d,r15d,r13d
       or        r14d,r15d
       nop       dword ptr [rax+rax]
M01_L02:
       mov       r15d,9249249
       pdep      r15d,edi,r15d
       or        r15d,r14d
       mov       [rax+rdi*4],r15d
       inc       edi
       cmp       edi,r8d
       jl        short 00000000000095D0
M01_L03:
       xor       edi,edi
       test      r9d,r9d
       jne       near ptr 00000000000096B5
       test      edx,edx
       jle       near ptr 000000000000968E
       xor       r9d,r9d
       mov       [rbp+0C],edx
M01_L04:
       xor       r15d,r15d
       mov       r13d,edx
M01_L05:
       mov       [rbp+10],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       r9d,ecx
       cmp       r12,r9
       ja        near ptr 000000000000974B
       mov       r9d,edi
       lea       r9,[rbx+r9*4]
       xor       r12d,r12d
       mov       esi,r8d
M01_L06:
       mov       edx,[rax+r12]
       shl       edx,2
       or        edx,r14d
       cmp       edx,r11d
       jae       near ptr 0000000000009752
       mov       r8d,[r9+r12]
       mov       [r10+rdx*4],r8d
       add       r12,4
       dec       esi
       jne       short 0000000000009639
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+10]
       jne       short 0000000000009608
       add       r9,4
       mov       r14d,[rbp+0C]
       dec       r14d
       mov       [rbp+0C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 0000000000009602
M01_L07:
       mov       r8,0AF801F6A0525
       cmp       [rbp],r8
       je        short 00000000000096A3
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+38]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       test      edx,edx
       jle       short 000000000000968E
       xor       r9d,r9d
       mov       [rbp+1C],edx
M01_L10:
       xor       r15d,r15d
       mov       r13d,edx
M01_L11:
       mov       [rbp+20],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       esi,r11d
       cmp       r12,rsi
       ja        short 000000000000974B
       mov       esi,edi
       lea       rsi,[r10+rsi*4]
       xor       r12d,r12d
       mov       edx,r8d
M01_L12:
       lea       r8,[rsi+r12]
       mov       r9d,[rax+r12]
       shl       r9d,2
       or        r9d,r14d
       cmp       r9d,ecx
       jae       short 0000000000009752
       mov       r9d,[rbx+r9*4]
       mov       [r8],r9d
       add       r12,4
       dec       edx
       jne       short 00000000000096F1
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+20]
       jne       short 00000000000096C5
       add       r9,4
       mov       r14d,[rbp+1C]
       dec       r14d
       mov       [rbp+1C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 00000000000096BF
       jmp       near ptr 000000000000968E
M01_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001788
       int       3
M01_L15:
       call      0000000000001770
       int       3
; Total bytes of code 574
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000202D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000002036
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 000000000000203F
       cmp       r9d,1
       ja        near ptr 000000000000203F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000002063
       cmp       edx,edi
       jl        near ptr 0000000000002063
       cmp       edi,edx
       ja        near ptr 0000000000002087
       test      edi,edi
       je        short 0000000000002002
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 000000000000208E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 000000000000208E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CE70]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000001F85
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000001F99
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E4C0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CE58]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C48]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CE58]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,28
       lea       rbp,[rsp+20]
       mov       rax,0C96190BBB2CB
       mov       [rbp],rax
       mov       r10,rdx
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       r11d,4
       mul       r11
       jb        near ptr 00000000000090B3
       test      rax,rax
       je        short 0000000000008F65
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000008F53
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 00000000000090AC
       mov       edx,r8d
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000008FB8
       xor       ebx,ebx
       mov       esi,24924924
       pdep      ebx,ebx,esi
       xor       esi,esi
       mov       edi,12492492
       pdep      esi,esi,edi
       or        ebx,esi
       nop       dword ptr [rax+rax]
       nop       dword ptr [rax+rax]
M01_L02:
       mov       esi,9249249
       pdep      esi,r11d,esi
       or        esi,ebx
       mov       [rax+r11*4],esi
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000008FA0
M01_L03:
       mov       rcx,[rcx]
       mov       r8,[r10]
       xor       r10d,r10d
       test      r9d,r9d
       jne       near ptr 000000000000904C
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009025
M01_L04:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L05:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L06:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       movsxd    r10,r10d
       mov       r10d,[rcx+r10*4]
       mov       [r8+r12*4],r10d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 0000000000008FEC
       add       rbx,4
       dec       esi
       jne       short 0000000000008FD8
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000008FD1
M01_L07:
       mov       r8,0C96190BBB2CB
       cmp       [rbp],r8
       je        short 000000000000903A
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+8]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009025
M01_L10:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L11:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L12:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       mov       r12d,[rcx+r12*4]
       movsxd    r10,r10d
       mov       [r8+r10*4],r12d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 000000000000906E
       add       rbx,4
       dec       esi
       jne       short 000000000000905A
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000009053
       jmp       near ptr 0000000000009025
M01_L13:
       call      qword ptr [7C48]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001770
       int       3
; Total bytes of code 441
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.Production()
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,48
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqa   xmmword ptr [rsp+30],xmm4
       mov       [rsp+40],rax
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000328E
       lea       rbx,[rax+10]
       mov       esi,[rax+8]
M00_L00:
       mov       rax,[rcx+10]
       test      rax,rax
       je        near ptr 0000000000003297
       lea       rdi,[rax+10]
       mov       ebp,[rax+8]
M00_L01:
       mov       r14d,[rcx+18]
       mov       ecx,[rcx+1C]
       mov       r15d,ecx
       test      ecx,ecx
       sete      r13b
       movzx     r13d,r13b
       mov       ecx,r14d
       call      qword ptr [0C828]; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       test      r15d,r15d
       je        short 00000000000031EA
       cmp       r15d,1
       jne       near ptr 00000000000032A0
M00_L02:
       test      r13d,r13d
       je        short 00000000000031F9
       cmp       r13d,1
       jne       near ptr 00000000000032DC
M00_L03:
       lea       ecx,[r14+r14*2]
       mov       eax,1
       shlx      r12d,eax,ecx
       cmp       esi,r12d
       jne       near ptr 0000000000003318
       cmp       ebp,r12d
       jl        near ptr 0000000000003318
       cmp       r12d,ebp
       ja        near ptr 0000000000003354
       cmp       r15d,r13d
       je        near ptr 000000000000335B
       test      r12d,r12d
       je        short 0000000000003252
       mov       rcx,rdi
       sub       rcx,rbx
       movsxd    rax,r12d
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000003373
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000003373
M00_L04:
       mov       [rsp+38],rbx
       mov       [rsp+40],r12d
       mov       [rsp+28],rdi
       mov       [rsp+30],r12d
       lea       rcx,[rsp+38]
       lea       rdx,[rsp+28]
       mov       r8d,r14d
       mov       r9d,r15d
       call      qword ptr [0C810]; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
M00_L05:
       nop
       add       rsp,48
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L06:
       xor       ebx,ebx
       xor       esi,esi
       jmp       near ptr 00000000000031AA
M00_L07:
       xor       edi,edi
       xor       ebp,ebp
       jmp       near ptr 00000000000031BE
M00_L08:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2B2F18
       call      qword ptr [6BC8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0C8A0]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L09:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2B2F18
       call      qword ptr [6BC8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0C8A0]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L10:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,435
       mov       rdx,7FFB2D2B2F18
       call      qword ptr [6BC8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0F210]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L11:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L12:
       mov       r8d,r12d
       shl       r8,2
       mov       rcx,rdi
       mov       rdx,rbx
       call      qword ptr [5818]; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       jmp       near ptr 000000000000327C
M00_L13:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,46B
       mov       rdx,7FFB2D2B2F18
       call      qword ptr [6BC8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0F210]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 575
```
```assembly
; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,50
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+30],ymm4
       mov       ebx,ecx
       cmp       ebx,9
       ja        short 00000000000036BA
       vzeroupper
       add       rsp,50
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L00:
       mov       rcx,offset MT_System.Int32
       call      0000000000005240
       mov       rsi,rax
       mov       [rsi+8],ebx
       lea       rcx,[rsp+28]
       mov       edx,31
       mov       r8d,1
       call      qword ptr [66E8]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       ja        short 0000000000003767
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       cmp       eax,30
       jb        short 0000000000003738
       vmovups   ymm0,[3800]
       vmovups   [rdx],ymm0
       vmovups   ymm0,[3820]
       vmovups   [rdx+20],ymm0
       vmovups   ymm0,[3840]
       vmovups   [rdx+40],ymm0
       mov       ecx,[rsp+38]
       add       ecx,30
       mov       [rsp+38],ecx
       jmp       short 000000000000374D
M01_L01:
       lea       rcx,[rsp+28]
       mov       rdx,1F200562818
       call      qword ptr [6700]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L02:
       lea       rcx,[rsp+28]
       mov       edx,9
       call      qword ptr [6AF0]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       jbe       short 000000000000376E
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       je        short 0000000000003792
       mov       word ptr [rdx],2E
       mov       ecx,[rsp+38]
       inc       ecx
       mov       [rsp+38],ecx
       jmp       short 00000000000037A7
M01_L05:
       lea       rcx,[rsp+28]
       mov       rdx,1F200550658
       call      qword ptr [6700]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L06:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,12BF
       mov       rdx,7FFB2D2B2F18
       call      qword ptr [6BC8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdi,rax
       lea       rcx,[rsp+28]
       call      qword ptr [6718]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       mov       r9,rax
       mov       rdx,rdi
       mov       r8,rsi
       mov       rcx,rbx
       call      qword ptr [7AB0]; Precode of System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 359
```
```assembly
; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,48
       lea       rbp,[rsp+20]
       mov       rax,8F4D5DE90AB4
       mov       [rbp+8],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       edx,4
       mul       rdx
       jb        near ptr 00000000000072A5
       test      rax,rax
       je        short 000000000000712E
       add       rax,0F
       shr       rax,4
       add       rsp,20
M02_L00:
       push      0
       push      0
       dec       rax
       jne       short 000000000000711C
       sub       rsp,20
       lea       rax,[rsp+20]
M02_L01:
       test      r8d,r8d
       jl        near ptr 0000000000007298
       xor       edx,edx
       test      r8d,r8d
       jle       short 0000000000007176
       xor       esi,esi
       mov       edi,24924924
       pdep      esi,esi,edi
       xor       edi,edi
       mov       r14d,12492492
       pdep      edi,edi,r14d
       or        esi,edi
       nop       dword ptr [rax]
M02_L02:
       mov       edi,9249249
       pdep      edi,edx,edi
       or        edi,esi
       mov       [rax+rdx*4],edi
       inc       edx
       cmp       edx,r8d
       jl        short 0000000000007160
M02_L03:
       xor       edx,edx
       test      r9d,r9d
       jne       near ptr 0000000000007220
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 00000000000071F9
M02_L04:
       mov       [rbp+24],r9d
       mov       esi,r9d
       mov       [rbp+18],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L05:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L06:
       mov       r9d,[rax+r13]
       shl       r9d,2
       or        r9d,r15d
       lea       esi,[rdx+1]
       cmp       r9d,r11d
       jae       near ptr 000000000000729F
       cmp       edx,ecx
       jae       near ptr 000000000000729F
       mov       edx,edx
       mov       edx,[rbx+rdx*4]
       mov       [r10+r9*4],edx
       add       r13,4
       dec       r12d
       mov       edx,esi
       jne       short 00000000000071AD
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+18]
       jne       short 0000000000007199
       mov       r9d,[rbp+24]
       inc       r9d
       cmp       r9d,r8d
       jl        short 0000000000007189
M02_L07:
       mov       r8,8F4D5DE90AB4
       cmp       [rbp+8],r8
       je        short 000000000000720E
       call      000000000000BD80
M02_L08:
       nop
       lea       rsp,[rbp+28]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M02_L09:
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 00000000000071F9
M02_L10:
       mov       [rbp+20],r9d
       mov       esi,r9d
       mov       [rbp+10],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L11:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L12:
       lea       r9d,[rdx+1]
       cmp       edx,r11d
       jae       short 000000000000729F
       mov       edx,edx
       lea       rdx,[r10+rdx*4]
       mov       esi,[rax+r13]
       shl       esi,2
       or        esi,r15d
       cmp       esi,ecx
       jae       short 000000000000729F
       mov       esi,[rbx+rsi*4]
       mov       [rdx],esi
       add       r13,4
       dec       r12d
       mov       edx,r9d
       jne       short 000000000000724C
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+10]
       jne       short 0000000000007238
       mov       r9d,[rbp+20]
       inc       r9d
       cmp       r9d,r8d
       jl        short 0000000000007228
       jmp       near ptr 00000000000071F9
M02_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M02_L14:
       call      0000000000001788
       int       3
M02_L15:
       call      0000000000001770
       int       3
; Total bytes of code 491
```
```assembly
; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       mov       rax,rcx
       sub       rax,rdx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       mov       rax,rdx
       sub       rax,rcx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       lea       rax,[rdx+r8]
       lea       r10,[rcx+r8]
       cmp       r8,10
       jbe       short 000000000000C0AB
       cmp       r8,40
       ja        near ptr 000000000000C0F3
M03_L00:
       vmovups   xmm0,[rdx]
       vmovups   [rcx],xmm0
       cmp       r8,20
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+10]
       vmovups   [rcx+10],xmm0
       cmp       r8,30
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+20]
       vmovups   [rcx+20],xmm0
       jmp       near ptr 000000000000C13D
M03_L01:
       test      r8b,18
       je        short 000000000000C0C4
       mov       r8,[rdx]
       mov       [rcx],r8
       mov       rdx,[rax+0FFF8]
       mov       [r10+0FFF8],rdx
       jmp       near ptr 000000000000C148
M03_L02:
       test      r8b,4
       jne       short 000000000000C0E6
       test      r8,r8
       je        short 000000000000C148
       movzx     edx,byte ptr [rdx]
       mov       [rcx],dl
       test      r8b,2
       je        short 000000000000C148
       movsx     rcx,word ptr [rax+0FFFE]
       mov       [r10+0FFFE],cx
       jmp       short 000000000000C148
M03_L03:
       mov       edx,[rdx]
       mov       [rcx],edx
       mov       ecx,[rax+0FFFC]
       mov       [r10+0FFFC],ecx
       jmp       short 000000000000C148
M03_L04:
       cmp       r8,800
       ja        near ptr 000000000000C180
       cmp       r8,100
       jae       short 000000000000C14C
M03_L05:
       mov       r9,r8
       shr       r9,6
M03_L06:
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rcx,40
       add       rdx,40
       dec       r9
       jne       short 000000000000C110
       and       r8,3F
       cmp       r8,10
       ja        near ptr 000000000000C076
M03_L07:
       vmovups   xmm0,[rax+0FFF0]
       vmovups   [r10+0FFF0],xmm0
M03_L08:
       vzeroupper
       ret
M03_L09:
       mov       r9,rcx
       and       r9,3F
       neg       r9
       add       r9,40
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rdx,r9
       add       rcx,r9
       sub       r8,r9
       jmp       short 000000000000C109
M03_L10:
       cmp       rcx,rdx
       jne       short 000000000000C180
       cmp       [rdx],dl
       jmp       short 000000000000C148
M03_L11:
       cmp       [rcx],cl
       cmp       [rdx],dl
       vzeroupper
       jmp       qword ptr [66E8]; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
; Total bytes of code 333
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       mov       esi,edx
       mov       edi,r8d
       xor       eax,eax
       mov       [rbx],rax
       call      qword ptr [0A098]
       mov       rcx,[rax]
       imul      edx,edi,0B
       add       edx,esi
       mov       eax,100
       cmp       edx,100
       cmovle    edx,eax
       cmp       [rcx],ecx
       call      qword ptr [98B8]; Precode of System.Collections.Generic.SegmentedArrayBuilder`1[[System.Double, System.Private.CoreLib]].Dispose()
       mov       [rbx+8],rax
       test      rax,rax
       je        short 000000000000C4E0
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M04_L00:
       mov       [rbx+18],rcx
       mov       [rbx+20],eax
       xor       eax,eax
       mov       [rbx+10],eax
       mov       byte ptr [rbx+14],0
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M04_L01:
       xor       ecx,ecx
       xor       eax,eax
       jmp       short 000000000000C4C8
; Total bytes of code 102
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,58
       xorps     xmm4,xmm4
       movaps    [rsp+30],xmm4
       movaps    [rsp+40],xmm4
       mov       rbx,rcx
       mov       esi,edx
       cmp       byte ptr [rbx+14],0
       jne       short 000000000000F15B
M05_L00:
       lea       rdx,[rbx+18]
       mov       r8d,[rbx+10]
       mov       edi,[rdx+8]
       cmp       r8d,edi
       ja        near ptr 000000000000F1D8
       mov       rdx,[rdx]
       mov       ecx,r8d
       lea       rbp,[rdx+rcx*2]
       sub       edi,r8d
       mov       rcx,[rbx]
       test      esi,esi
       jl        short 000000000000F173
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       rdx,[rsp+40]
       lea       r8,[rsp+50]
       mov       ecx,esi
       call      qword ptr [0CF8]; Precode of System.Number.TryUInt32ToDecStr[[System.Char, System.Private.CoreLib]](UInt32, System.Span`1<Char>, Int32 ByRef)
M05_L01:
       test      eax,eax
       jne       short 000000000000F152
       mov       rcx,rbx
       call      qword ptr [4FF8]
       jmp       short 000000000000F100
M05_L02:
       mov       eax,[rsp+50]
       add       [rbx+10],eax
       jmp       short 000000000000F169
M05_L03:
       mov       rcx,rbx
       mov       edx,esi
       xor       r8d,r8d
       call      qword ptr [1B50]
M05_L04:
       nop
       add       rsp,58
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M05_L05:
       test      rcx,rcx
       je        short 000000000000F180
       call      qword ptr [1260]; Precode of System.Globalization.NumberFormatInfo.<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider)
       jmp       short 000000000000F186
M05_L06:
       call      qword ptr [1248]; Precode of System.Globalization.NumberFormatInfo.get_CurrentInfo()
M05_L07:
       mov       r8,[rax+28]
       test      r8,r8
       jne       short 000000000000F197
       xor       r9d,r9d
       xor       r8d,r8d
       jmp       short 000000000000F19F
M05_L08:
       lea       r9,[r8+0C]
       mov       r8d,[r8+8]
M05_L09:
       mov       [rsp+30],r9
       mov       [rsp+38],r8d
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       r8,[rsp+50]
       mov       [rsp+20],r8
       lea       r8,[rsp+30]
       lea       r9,[rsp+40]
       mov       ecx,esi
       mov       edx,0FFFFFFFF
       call      qword ptr [0CE0]
       jmp       near ptr 000000000000F143
M05_L10:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 255
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,38
       xor       eax,eax
       mov       [rsp+28],rax
       mov       rbx,rcx
       lea       rsi,[rbx+18]
       mov       rcx,rsi
       mov       eax,[rbx+10]
       cmp       eax,[rcx+8]
       ja        short 000000000000C6F7
       mov       rcx,[rcx]
       mov       [rsp+28],rcx
       mov       [rsp+30],eax
       lea       rcx,[rsp+28]
       call      qword ptr [0BB28]; Precode of System.String.Ctor(System.ReadOnlySpan`1<Char>)
       mov       rdi,rax
       mov       rbp,[rbx+8]
       xor       eax,eax
       mov       [rbx+8],rax
       mov       [rsi],rax
       mov       [rsi+8],rax
       mov       [rbx+10],eax
       test      rbp,rbp
       je        short 000000000000C6EB
       call      qword ptr [0A098]
       mov       rcx,[rax]
       mov       rdx,rbp
       xor       r8d,r8d
       cmp       [rcx],ecx
       call      qword ptr [98C0]; Precode of System.Linq.Enumerable+ArrayWhereIterator`1[[System.Double, System.Private.CoreLib]]..ctor(Double[], System.Func`2<Double,Boolean>)
M06_L00:
       mov       rax,rdi
       add       rsp,38
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M06_L01:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 126
```
```assembly
; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,0A8
       lea       rbp,[rsp+0E0]
       mov       [rbp+0FFC0],rcx
       mov       [rbp+0FFB8],rdx
       mov       [rbp+0FF58],rcx
       mov       [rbp+0FF50],rdx
       mov       [rbp+0FF48],r8
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9030]; CORINFO_HELP_JIT_PINVOKE_BEGIN
       mov       rax,[5A58]
       mov       rcx,[rbp+0FF58]
       mov       rdx,[rbp+0FF50]
       mov       r8,[rbp+0FF48]
       call      qword ptr [rax]
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9038]; CORINFO_HELP_JIT_PINVOKE_END
       xor       eax,eax
       mov       [rbp+0FFB8],rax
       mov       [rbp+0FFC0],rax
       add       rsp,0A8
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
; Total bytes of code 142
```
**Method was not JITted yet.**
System.String.StrCns(UInt32, IntPtr)
System.ArgumentOutOfRangeException..ctor(System.String)
System.ArgumentException..ctor(System.String)
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.PrevalidatedRows()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000248D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000002496
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 000000000000249F
       cmp       r9d,1
       ja        near ptr 000000000000249F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 00000000000024C3
       cmp       edx,edi
       jl        near ptr 00000000000024C3
       cmp       edi,edx
       ja        near ptr 00000000000024E7
       test      edi,edi
       je        short 0000000000002462
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 00000000000024EE
       neg       rax
       cmp       rax,rcx
       jb        near ptr 00000000000024EE
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CEA0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 00000000000023E5
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 00000000000023F9
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6A0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CE70]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CE70]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,58
       lea       rbp,[rsp+20]
       mov       rax,0ED6AE10A02F7
       mov       [rbp],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       [rbp+34],r8d
       mov       esi,r8d
       mov       [rbp+28],rsi
       mov       eax,4
       mul       rsi
       jb        near ptr 00000000000091F8
       test      rax,rax
       je        short 0000000000009036
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000009024
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 00000000000091EB
       mov       edx,r8d
       mov       [rbp+30],edx
       xor       edi,edi
       test      r8d,r8d
       jle       short 0000000000009089
       xor       r14d,r14d
       mov       r15d,24924924
       pdep      r14d,r14d,r15d
       xor       r15d,r15d
       mov       r13d,12492492
       pdep      r15d,r15d,r13d
       or        r14d,r15d
       nop       dword ptr [rax+rax]
M01_L02:
       mov       r15d,9249249
       pdep      r15d,edi,r15d
       or        r15d,r14d
       mov       [rax+rdi*4],r15d
       inc       edi
       cmp       edi,r8d
       jl        short 0000000000009070
M01_L03:
       xor       edi,edi
       test      r9d,r9d
       jne       near ptr 0000000000009155
       test      edx,edx
       jle       near ptr 000000000000912E
       xor       r9d,r9d
       mov       [rbp+0C],edx
M01_L04:
       xor       r15d,r15d
       mov       r13d,edx
M01_L05:
       mov       [rbp+10],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       r9d,ecx
       cmp       r12,r9
       ja        near ptr 00000000000091EB
       mov       r9d,edi
       lea       r9,[rbx+r9*4]
       xor       r12d,r12d
       mov       esi,r8d
M01_L06:
       mov       edx,[rax+r12]
       shl       edx,2
       or        edx,r14d
       cmp       edx,r11d
       jae       near ptr 00000000000091F2
       mov       r8d,[r9+r12]
       mov       [r10+rdx*4],r8d
       add       r12,4
       dec       esi
       jne       short 00000000000090D9
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+10]
       jne       short 00000000000090A8
       add       r9,4
       mov       r14d,[rbp+0C]
       dec       r14d
       mov       [rbp+0C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 00000000000090A2
M01_L07:
       mov       r8,0ED6AE10A02F7
       cmp       [rbp],r8
       je        short 0000000000009143
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+38]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       test      edx,edx
       jle       short 000000000000912E
       xor       r9d,r9d
       mov       [rbp+1C],edx
M01_L10:
       xor       r15d,r15d
       mov       r13d,edx
M01_L11:
       mov       [rbp+20],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       esi,r11d
       cmp       r12,rsi
       ja        short 00000000000091EB
       mov       esi,edi
       lea       rsi,[r10+rsi*4]
       xor       r12d,r12d
       mov       edx,r8d
M01_L12:
       lea       r8,[rsi+r12]
       mov       r9d,[rax+r12]
       shl       r9d,2
       or        r9d,r14d
       cmp       r9d,ecx
       jae       short 00000000000091F2
       mov       r9d,[rbx+r9*4]
       mov       [r8],r9d
       add       r12,4
       dec       edx
       jne       short 0000000000009191
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+20]
       jne       short 0000000000009165
       add       r9,4
       mov       r14d,[rbp+1C]
       dec       r14d
       mov       [rbp+1C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 000000000000915F
       jmp       near ptr 000000000000912E
M01_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001788
       int       3
M01_L15:
       call      0000000000001770
       int       3
; Total bytes of code 574
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000172D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000001736
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 000000000000173F
       cmp       r9d,1
       ja        near ptr 000000000000173F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000001763
       cmp       edx,edi
       jl        near ptr 0000000000001763
       cmp       edi,edx
       ja        near ptr 0000000000001787
       test      edi,edi
       je        short 0000000000001702
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 000000000000178E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 000000000000178E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CF48]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000001685
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000001699
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E2C8]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF30]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF30]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,28
       lea       rbp,[rsp+20]
       mov       rax,0D4AA76ECC574
       mov       [rbp],rax
       mov       r10,rdx
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       r11d,4
       mul       r11
       jb        near ptr 000000000000A013
       test      rax,rax
       je        short 0000000000009EC5
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000009EB3
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 000000000000A00C
       mov       edx,r8d
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000009F18
       xor       ebx,ebx
       mov       esi,24924924
       pdep      ebx,ebx,esi
       xor       esi,esi
       mov       edi,12492492
       pdep      esi,esi,edi
       or        ebx,esi
       nop       dword ptr [rax+rax]
       nop       dword ptr [rax+rax]
M01_L02:
       mov       esi,9249249
       pdep      esi,r11d,esi
       or        esi,ebx
       mov       [rax+r11*4],esi
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000009F00
M01_L03:
       mov       rcx,[rcx]
       mov       r8,[r10]
       xor       r10d,r10d
       test      r9d,r9d
       jne       near ptr 0000000000009FAC
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009F85
M01_L04:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L05:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L06:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       movsxd    r10,r10d
       mov       r10d,[rcx+r10*4]
       mov       [r8+r12*4],r10d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 0000000000009F4C
       add       rbx,4
       dec       esi
       jne       short 0000000000009F38
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000009F31
M01_L07:
       mov       r8,0D4AA76ECC574
       cmp       [rbp],r8
       je        short 0000000000009F9A
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+8]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009F85
M01_L10:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L11:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L12:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       mov       r12d,[rcx+r12*4]
       movsxd    r10,r10d
       mov       [r8+r10*4],r12d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 0000000000009FCE
       add       rbx,4
       dec       esi
       jne       short 0000000000009FBA
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000009FB3
       jmp       near ptr 0000000000009F85
M01_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001770
       int       3
; Total bytes of code 441
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.Production()
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,48
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqa   xmmword ptr [rsp+30],xmm4
       mov       [rsp+40],rax
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 0000000000001EEE
       lea       rbx,[rax+10]
       mov       esi,[rax+8]
M00_L00:
       mov       rax,[rcx+10]
       test      rax,rax
       je        near ptr 0000000000001EF7
       lea       rdi,[rax+10]
       mov       ebp,[rax+8]
M00_L01:
       mov       r14d,[rcx+18]
       mov       ecx,[rcx+1C]
       mov       r15d,ecx
       test      ecx,ecx
       sete      r13b
       movzx     r13d,r13b
       mov       ecx,r14d
       call      qword ptr [0CCA8]; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       test      r15d,r15d
       je        short 0000000000001E4A
       cmp       r15d,1
       jne       near ptr 0000000000001F00
M00_L02:
       test      r13d,r13d
       je        short 0000000000001E59
       cmp       r13d,1
       jne       near ptr 0000000000001F3C
M00_L03:
       lea       ecx,[r14+r14*2]
       mov       eax,1
       shlx      r12d,eax,ecx
       cmp       esi,r12d
       jne       near ptr 0000000000001F78
       cmp       ebp,r12d
       jl        near ptr 0000000000001F78
       cmp       r12d,ebp
       ja        near ptr 0000000000001FB4
       cmp       r15d,r13d
       je        near ptr 0000000000001FBB
       test      r12d,r12d
       je        short 0000000000001EB2
       mov       rcx,rdi
       sub       rcx,rbx
       movsxd    rax,r12d
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000001FD3
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000001FD3
M00_L04:
       mov       [rsp+38],rbx
       mov       [rsp+40],r12d
       mov       [rsp+28],rdi
       mov       [rsp+30],r12d
       lea       rcx,[rsp+38]
       lea       rdx,[rsp+28]
       mov       r8d,r14d
       mov       r9d,r15d
       call      qword ptr [0CC90]; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
M00_L05:
       nop
       add       rsp,48
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L06:
       xor       ebx,ebx
       xor       esi,esi
       jmp       near ptr 0000000000001E0A
M00_L07:
       xor       edi,edi
       xor       ebp,ebp
       jmp       near ptr 0000000000001E1E
M00_L08:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2A4850
       call      qword ptr [6FE8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CD20]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L09:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D2A4850
       call      qword ptr [6FE8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CD20]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L10:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,435
       mov       rdx,7FFB2D2A4850
       call      qword ptr [6FE8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0DC80]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L11:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L12:
       mov       r8d,r12d
       shl       r8,2
       mov       rcx,rdi
       mov       rdx,rbx
       call      qword ptr [5818]; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       jmp       near ptr 0000000000001EDC
M00_L13:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,46B
       mov       rdx,7FFB2D2A4850
       call      qword ptr [6FE8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0DC80]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 575
```
```assembly
; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,50
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+30],ymm4
       mov       ebx,ecx
       cmp       ebx,9
       ja        short 000000000000231A
       vzeroupper
       add       rsp,50
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L00:
       mov       rcx,offset MT_System.Int32
       call      0000000000005240
       mov       rsi,rax
       mov       [rsi+8],ebx
       lea       rcx,[rsp+28]
       mov       edx,31
       mov       r8d,1
       call      qword ptr [6838]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       ja        short 00000000000023C7
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       cmp       eax,30
       jb        short 0000000000002398
       vmovups   ymm0,[2460]
       vmovups   [rdx],ymm0
       vmovups   ymm0,[2480]
       vmovups   [rdx+20],ymm0
       vmovups   ymm0,[24A0]
       vmovups   [rdx+40],ymm0
       mov       ecx,[rsp+38]
       add       ecx,30
       mov       [rsp+38],ecx
       jmp       short 00000000000023AD
M01_L01:
       lea       rcx,[rsp+28]
       mov       rdx,1C580212818
       call      qword ptr [6850]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L02:
       lea       rcx,[rsp+28]
       mov       edx,9
       call      qword ptr [6AD8]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       jbe       short 00000000000023CE
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       je        short 00000000000023F2
       mov       word ptr [rdx],2E
       mov       ecx,[rsp+38]
       inc       ecx
       mov       [rsp+38],ecx
       jmp       short 0000000000002407
M01_L05:
       lea       rcx,[rsp+28]
       mov       rdx,1C580200658
       call      qword ptr [6850]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L06:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,12BF
       mov       rdx,7FFB2D2A4850
       call      qword ptr [6FE8]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdi,rax
       lea       rcx,[rsp+28]
       call      qword ptr [6868]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       mov       r9,rax
       mov       rdx,rdi
       mov       r8,rsi
       mov       rcx,rbx
       call      qword ptr [7ED0]; Precode of System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 359
```
```assembly
; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,48
       lea       rbp,[rsp+20]
       mov       rax,0D06A77E716B3
       mov       [rbp+8],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       edx,4
       mul       rdx
       jb        near ptr 0000000000008AC5
       test      rax,rax
       je        short 000000000000894E
       add       rax,0F
       shr       rax,4
       add       rsp,20
M02_L00:
       push      0
       push      0
       dec       rax
       jne       short 000000000000893C
       sub       rsp,20
       lea       rax,[rsp+20]
M02_L01:
       test      r8d,r8d
       jl        near ptr 0000000000008AB8
       xor       edx,edx
       test      r8d,r8d
       jle       short 0000000000008996
       xor       esi,esi
       mov       edi,24924924
       pdep      esi,esi,edi
       xor       edi,edi
       mov       r14d,12492492
       pdep      edi,edi,r14d
       or        esi,edi
       nop       dword ptr [rax]
M02_L02:
       mov       edi,9249249
       pdep      edi,edx,edi
       or        edi,esi
       mov       [rax+rdx*4],edi
       inc       edx
       cmp       edx,r8d
       jl        short 0000000000008980
M02_L03:
       xor       edx,edx
       test      r9d,r9d
       jne       near ptr 0000000000008A40
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 0000000000008A19
M02_L04:
       mov       [rbp+24],r9d
       mov       esi,r9d
       mov       [rbp+18],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L05:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L06:
       mov       r9d,[rax+r13]
       shl       r9d,2
       or        r9d,r15d
       lea       esi,[rdx+1]
       cmp       r9d,r11d
       jae       near ptr 0000000000008ABF
       cmp       edx,ecx
       jae       near ptr 0000000000008ABF
       mov       edx,edx
       mov       edx,[rbx+rdx*4]
       mov       [r10+r9*4],edx
       add       r13,4
       dec       r12d
       mov       edx,esi
       jne       short 00000000000089CD
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+18]
       jne       short 00000000000089B9
       mov       r9d,[rbp+24]
       inc       r9d
       cmp       r9d,r8d
       jl        short 00000000000089A9
M02_L07:
       mov       r8,0D06A77E716B3
       cmp       [rbp+8],r8
       je        short 0000000000008A2E
       call      000000000000BD80
M02_L08:
       nop
       lea       rsp,[rbp+28]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M02_L09:
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 0000000000008A19
M02_L10:
       mov       [rbp+20],r9d
       mov       esi,r9d
       mov       [rbp+10],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L11:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L12:
       lea       r9d,[rdx+1]
       cmp       edx,r11d
       jae       short 0000000000008ABF
       mov       edx,edx
       lea       rdx,[r10+rdx*4]
       mov       esi,[rax+r13]
       shl       esi,2
       or        esi,r15d
       cmp       esi,ecx
       jae       short 0000000000008ABF
       mov       esi,[rbx+rsi*4]
       mov       [rdx],esi
       add       r13,4
       dec       r12d
       mov       edx,r9d
       jne       short 0000000000008A6C
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+10]
       jne       short 0000000000008A58
       mov       r9d,[rbp+20]
       inc       r9d
       cmp       r9d,r8d
       jl        short 0000000000008A48
       jmp       near ptr 0000000000008A19
M02_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M02_L14:
       call      0000000000001788
       int       3
M02_L15:
       call      0000000000001770
       int       3
; Total bytes of code 491
```
```assembly
; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       mov       rax,rcx
       sub       rax,rdx
       cmp       rax,r8
       jb        near ptr 000000000000C197
       mov       rax,rdx
       sub       rax,rcx
       cmp       rax,r8
       jb        near ptr 000000000000C197
       lea       rax,[rdx+r8]
       lea       r10,[rcx+r8]
       cmp       r8,10
       jbe       short 000000000000C0CB
       cmp       r8,40
       ja        near ptr 000000000000C113
M03_L00:
       vmovups   xmm0,[rdx]
       vmovups   [rcx],xmm0
       cmp       r8,20
       jbe       near ptr 000000000000C15D
       vmovups   xmm0,[rdx+10]
       vmovups   [rcx+10],xmm0
       cmp       r8,30
       jbe       near ptr 000000000000C15D
       vmovups   xmm0,[rdx+20]
       vmovups   [rcx+20],xmm0
       jmp       near ptr 000000000000C15D
M03_L01:
       test      r8b,18
       je        short 000000000000C0E4
       mov       r8,[rdx]
       mov       [rcx],r8
       mov       rdx,[rax+0FFF8]
       mov       [r10+0FFF8],rdx
       jmp       near ptr 000000000000C168
M03_L02:
       test      r8b,4
       jne       short 000000000000C106
       test      r8,r8
       je        short 000000000000C168
       movzx     edx,byte ptr [rdx]
       mov       [rcx],dl
       test      r8b,2
       je        short 000000000000C168
       movsx     rcx,word ptr [rax+0FFFE]
       mov       [r10+0FFFE],cx
       jmp       short 000000000000C168
M03_L03:
       mov       edx,[rdx]
       mov       [rcx],edx
       mov       ecx,[rax+0FFFC]
       mov       [r10+0FFFC],ecx
       jmp       short 000000000000C168
M03_L04:
       cmp       r8,800
       ja        near ptr 000000000000C1A0
       cmp       r8,100
       jae       short 000000000000C16C
M03_L05:
       mov       r9,r8
       shr       r9,6
M03_L06:
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rcx,40
       add       rdx,40
       dec       r9
       jne       short 000000000000C130
       and       r8,3F
       cmp       r8,10
       ja        near ptr 000000000000C096
M03_L07:
       vmovups   xmm0,[rax+0FFF0]
       vmovups   [r10+0FFF0],xmm0
M03_L08:
       vzeroupper
       ret
M03_L09:
       mov       r9,rcx
       and       r9,3F
       neg       r9
       add       r9,40
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rdx,r9
       add       rcx,r9
       sub       r8,r9
       jmp       short 000000000000C129
M03_L10:
       cmp       rcx,rdx
       jne       short 000000000000C1A0
       cmp       [rdx],dl
       jmp       short 000000000000C168
M03_L11:
       cmp       [rcx],cl
       cmp       [rdx],dl
       vzeroupper
       jmp       qword ptr [66E8]; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
; Total bytes of code 333
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       mov       esi,edx
       mov       edi,r8d
       xor       eax,eax
       mov       [rbx],rax
       call      qword ptr [0A098]
       mov       rcx,[rax]
       imul      edx,edi,0B
       add       edx,esi
       mov       eax,100
       cmp       edx,100
       cmovle    edx,eax
       cmp       [rcx],ecx
       call      qword ptr [98B8]; Precode of System.Buffers.SharedArrayPool`1[[System.Char, System.Private.CoreLib]].Rent(Int32)
       mov       [rbx+8],rax
       test      rax,rax
       je        short 000000000000C4E0
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M04_L00:
       mov       [rbx+18],rcx
       mov       [rbx+20],eax
       xor       eax,eax
       mov       [rbx+10],eax
       mov       byte ptr [rbx+14],0
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M04_L01:
       xor       ecx,ecx
       xor       eax,eax
       jmp       short 000000000000C4C8
; Total bytes of code 102
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,58
       xorps     xmm4,xmm4
       movaps    [rsp+30],xmm4
       movaps    [rsp+40],xmm4
       mov       rbx,rcx
       mov       esi,edx
       cmp       byte ptr [rbx+14],0
       jne       short 000000000000F15B
M05_L00:
       lea       rdx,[rbx+18]
       mov       r8d,[rbx+10]
       mov       edi,[rdx+8]
       cmp       r8d,edi
       ja        near ptr 000000000000F1D8
       mov       rdx,[rdx]
       mov       ecx,r8d
       lea       rbp,[rdx+rcx*2]
       sub       edi,r8d
       mov       rcx,[rbx]
       test      esi,esi
       jl        short 000000000000F173
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       rdx,[rsp+40]
       lea       r8,[rsp+50]
       mov       ecx,esi
       call      qword ptr [0CF8]; Precode of System.Number.TryUInt32ToDecStr[[System.Char, System.Private.CoreLib]](UInt32, System.Span`1<Char>, Int32 ByRef)
M05_L01:
       test      eax,eax
       jne       short 000000000000F152
       mov       rcx,rbx
       call      qword ptr [4FF8]
       jmp       short 000000000000F100
M05_L02:
       mov       eax,[rsp+50]
       add       [rbx+10],eax
       jmp       short 000000000000F169
M05_L03:
       mov       rcx,rbx
       mov       edx,esi
       xor       r8d,r8d
       call      qword ptr [1B50]
M05_L04:
       nop
       add       rsp,58
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M05_L05:
       test      rcx,rcx
       je        short 000000000000F180
       call      qword ptr [1260]; Precode of System.Globalization.NumberFormatInfo.<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider)
       jmp       short 000000000000F186
M05_L06:
       call      qword ptr [1248]; Precode of System.Globalization.NumberFormatInfo.get_CurrentInfo()
M05_L07:
       mov       r8,[rax+28]
       test      r8,r8
       jne       short 000000000000F197
       xor       r9d,r9d
       xor       r8d,r8d
       jmp       short 000000000000F19F
M05_L08:
       lea       r9,[r8+0C]
       mov       r8d,[r8+8]
M05_L09:
       mov       [rsp+30],r9
       mov       [rsp+38],r8d
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       r8,[rsp+50]
       mov       [rsp+20],r8
       lea       r8,[rsp+30]
       lea       r9,[rsp+40]
       mov       ecx,esi
       mov       edx,0FFFFFFFF
       call      qword ptr [0CE0]
       jmp       near ptr 000000000000F143
M05_L10:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 255
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,38
       xor       eax,eax
       mov       [rsp+28],rax
       mov       rbx,rcx
       lea       rsi,[rbx+18]
       mov       rcx,rsi
       mov       eax,[rbx+10]
       cmp       eax,[rcx+8]
       ja        short 000000000000C6F7
       mov       rcx,[rcx]
       mov       [rsp+28],rcx
       mov       [rsp+30],eax
       lea       rcx,[rsp+28]
       call      qword ptr [0BB28]; Precode of System.String.Ctor(System.ReadOnlySpan`1<Char>)
       mov       rdi,rax
       mov       rbp,[rbx+8]
       xor       eax,eax
       mov       [rbx+8],rax
       mov       [rsi],rax
       mov       [rsi+8],rax
       mov       [rbx+10],eax
       test      rbp,rbp
       je        short 000000000000C6EB
       call      qword ptr [0A098]
       mov       rcx,[rax]
       mov       rdx,rbp
       xor       r8d,r8d
       cmp       [rcx],ecx
       call      qword ptr [98C0]; Precode of System.Buffers.SharedArrayPool`1[[System.Char, System.Private.CoreLib]].Return(Char[], Boolean)
M06_L00:
       mov       rax,rdi
       add       rsp,38
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M06_L01:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 126
```
```assembly
; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,0A8
       lea       rbp,[rsp+0E0]
       mov       [rbp+0FFC0],rcx
       mov       [rbp+0FFB8],rdx
       mov       [rbp+0FF58],rcx
       mov       [rbp+0FF50],rdx
       mov       [rbp+0FF48],r8
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9030]; CORINFO_HELP_JIT_PINVOKE_BEGIN
       mov       rax,[5A58]
       mov       rcx,[rbp+0FF58]
       mov       rdx,[rbp+0FF50]
       mov       r8,[rbp+0FF48]
       call      qword ptr [rax]
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9038]; CORINFO_HELP_JIT_PINVOKE_END
       xor       eax,eax
       mov       [rbp+0FFB8],rax
       mov       [rbp+0FFC0],rax
       add       rsp,0A8
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
; Total bytes of code 142
```
**Method was not JITted yet.**
System.String.StrCns(UInt32, IntPtr)
System.ArgumentOutOfRangeException..ctor(System.String)
System.ArgumentException..ctor(System.String)
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.PrevalidatedRows()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000212D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000002136
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 000000000000213F
       cmp       r9d,1
       ja        near ptr 000000000000213F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000002163
       cmp       edx,edi
       jl        near ptr 0000000000002163
       cmp       edi,edx
       ja        near ptr 0000000000002187
       test      edi,edi
       je        short 0000000000002102
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 000000000000218E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 000000000000218E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CED0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000002085
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000002099
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6A0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CEA0]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CEA0]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,58
       lea       rbp,[rsp+20]
       mov       rax,108098FC6A32
       mov       [rbp],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       [rbp+34],r8d
       mov       esi,r8d
       mov       [rbp+28],rsi
       mov       eax,4
       mul       rsi
       jb        near ptr 0000000000009038
       test      rax,rax
       je        short 0000000000008E76
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000008E64
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 000000000000902B
       mov       edx,r8d
       mov       [rbp+30],edx
       xor       edi,edi
       test      r8d,r8d
       jle       short 0000000000008EC9
       xor       r14d,r14d
       mov       r15d,24924924
       pdep      r14d,r14d,r15d
       xor       r15d,r15d
       mov       r13d,12492492
       pdep      r15d,r15d,r13d
       or        r14d,r15d
       nop       dword ptr [rax+rax]
M01_L02:
       mov       r15d,9249249
       pdep      r15d,edi,r15d
       or        r15d,r14d
       mov       [rax+rdi*4],r15d
       inc       edi
       cmp       edi,r8d
       jl        short 0000000000008EB0
M01_L03:
       xor       edi,edi
       test      r9d,r9d
       jne       near ptr 0000000000008F95
       test      edx,edx
       jle       near ptr 0000000000008F6E
       xor       r9d,r9d
       mov       [rbp+0C],edx
M01_L04:
       xor       r15d,r15d
       mov       r13d,edx
M01_L05:
       mov       [rbp+10],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       r9d,ecx
       cmp       r12,r9
       ja        near ptr 000000000000902B
       mov       r9d,edi
       lea       r9,[rbx+r9*4]
       xor       r12d,r12d
       mov       esi,r8d
M01_L06:
       mov       edx,[rax+r12]
       shl       edx,2
       or        edx,r14d
       cmp       edx,r11d
       jae       near ptr 0000000000009032
       mov       r8d,[r9+r12]
       mov       [r10+rdx*4],r8d
       add       r12,4
       dec       esi
       jne       short 0000000000008F19
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+10]
       jne       short 0000000000008EE8
       add       r9,4
       mov       r14d,[rbp+0C]
       dec       r14d
       mov       [rbp+0C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 0000000000008EE2
M01_L07:
       mov       r8,108098FC6A32
       cmp       [rbp],r8
       je        short 0000000000008F83
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+38]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       test      edx,edx
       jle       short 0000000000008F6E
       xor       r9d,r9d
       mov       [rbp+1C],edx
M01_L10:
       xor       r15d,r15d
       mov       r13d,edx
M01_L11:
       mov       [rbp+20],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       esi,r11d
       cmp       r12,rsi
       ja        short 000000000000902B
       mov       esi,edi
       lea       rsi,[r10+rsi*4]
       xor       r12d,r12d
       mov       edx,r8d
M01_L12:
       lea       r8,[rsi+r12]
       mov       r9d,[rax+r12]
       shl       r9d,2
       or        r9d,r14d
       cmp       r9d,ecx
       jae       short 0000000000009032
       mov       r9d,[rbx+r9*4]
       mov       [r8],r9d
       add       r12,4
       dec       edx
       jne       short 0000000000008FD1
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+20]
       jne       short 0000000000008FA5
       add       r9,4
       mov       r14d,[rbp+1C]
       dec       r14d
       mov       [rbp+1C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 0000000000008F9F
       jmp       near ptr 0000000000008F6E
M01_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001788
       int       3
M01_L15:
       call      0000000000001770
       int       3
; Total bytes of code 574
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 0000000000000EED
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000000EF6
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 0000000000000EFF
       cmp       r9d,1
       ja        near ptr 0000000000000EFF
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000000F23
       cmp       edx,edi
       jl        near ptr 0000000000000F23
       cmp       edi,edx
       ja        near ptr 0000000000000F47
       test      edi,edi
       je        short 0000000000000EC2
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000000F4E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000000F4E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CFF0]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000000E45
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000000E59
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E6E8]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CFD8]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CFD8]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,28
       lea       rbp,[rsp+20]
       mov       rax,4E82633DAC4
       mov       [rbp],rax
       mov       r10,rdx
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       r11d,4
       mul       r11
       jb        near ptr 000000000000B433
       test      rax,rax
       je        short 000000000000B2E5
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 000000000000B2D3
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 000000000000B42C
       mov       edx,r8d
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 000000000000B338
       xor       ebx,ebx
       mov       esi,24924924
       pdep      ebx,ebx,esi
       xor       esi,esi
       mov       edi,12492492
       pdep      esi,esi,edi
       or        ebx,esi
       nop       dword ptr [rax+rax]
       nop       dword ptr [rax+rax]
M01_L02:
       mov       esi,9249249
       pdep      esi,r11d,esi
       or        esi,ebx
       mov       [rax+r11*4],esi
       inc       r11d
       cmp       r11d,r8d
       jl        short 000000000000B320
M01_L03:
       mov       rcx,[rcx]
       mov       r8,[r10]
       xor       r10d,r10d
       test      r9d,r9d
       jne       near ptr 000000000000B3CC
       xor       r9d,r9d
       test      edx,edx
       jle       short 000000000000B3A5
M01_L04:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L05:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L06:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       movsxd    r10,r10d
       mov       r10d,[rcx+r10*4]
       mov       [r8+r12*4],r10d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 000000000000B36C
       add       rbx,4
       dec       esi
       jne       short 000000000000B358
       inc       r9d
       cmp       r9d,edx
       jl        short 000000000000B351
M01_L07:
       mov       r8,4E82633DAC4
       cmp       [rbp],r8
       je        short 000000000000B3BA
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+8]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       xor       r9d,r9d
       test      edx,edx
       jle       short 000000000000B3A5
M01_L10:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L11:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L12:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       mov       r12d,[rcx+r12*4]
       movsxd    r10,r10d
       mov       [r8+r10*4],r12d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 000000000000B3EE
       add       rbx,4
       dec       esi
       jne       short 000000000000B3DA
       inc       r9d
       cmp       r9d,edx
       jl        short 000000000000B3D3
       jmp       near ptr 000000000000B3A5
M01_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001770
       int       3
; Total bytes of code 441
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.Production()
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,48
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqa   xmmword ptr [rsp+30],xmm4
       mov       [rsp+40],rax
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 000000000000220E
       lea       rbx,[rax+10]
       mov       esi,[rax+8]
M00_L00:
       mov       rax,[rcx+10]
       test      rax,rax
       je        near ptr 0000000000002217
       lea       rdi,[rax+10]
       mov       ebp,[rax+8]
M00_L01:
       mov       r14d,[rcx+18]
       mov       ecx,[rcx+1C]
       mov       r15d,ecx
       test      ecx,ecx
       sete      r13b
       movzx     r13d,r13b
       mov       ecx,r14d
       call      qword ptr [0CC90]; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       test      r15d,r15d
       je        short 000000000000216A
       cmp       r15d,1
       jne       near ptr 0000000000002220
M00_L02:
       test      r13d,r13d
       je        short 0000000000002179
       cmp       r13d,1
       jne       near ptr 000000000000225C
M00_L03:
       lea       ecx,[r14+r14*2]
       mov       eax,1
       shlx      r12d,eax,ecx
       cmp       esi,r12d
       jne       near ptr 0000000000002298
       cmp       ebp,r12d
       jl        near ptr 0000000000002298
       cmp       r12d,ebp
       ja        near ptr 00000000000022D4
       cmp       r15d,r13d
       je        near ptr 00000000000022DB
       test      r12d,r12d
       je        short 00000000000021D2
       mov       rcx,rdi
       sub       rcx,rbx
       movsxd    rax,r12d
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 00000000000022F3
       neg       rax
       cmp       rax,rcx
       jb        near ptr 00000000000022F3
M00_L04:
       mov       [rsp+38],rbx
       mov       [rsp+40],r12d
       mov       [rsp+28],rdi
       mov       [rsp+30],r12d
       lea       rcx,[rsp+38]
       lea       rdx,[rsp+28]
       mov       r8d,r14d
       mov       r9d,r15d
       call      qword ptr [0CC78]; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
M00_L05:
       nop
       add       rsp,48
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       ret
M00_L06:
       xor       ebx,ebx
       xor       esi,esi
       jmp       near ptr 000000000000212A
M00_L07:
       xor       edi,edi
       xor       ebp,ebp
       jmp       near ptr 000000000000213E
M00_L08:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D293880
       call      qword ptr [7258]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CD08]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L09:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,423
       mov       rdx,7FFB2D293880
       call      qword ptr [7258]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0CD08]; Precode of System.ArgumentOutOfRangeException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L10:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,435
       mov       rdx,7FFB2D293880
       call      qword ptr [7258]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0E910]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L11:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L12:
       mov       r8d,r12d
       shl       r8,2
       mov       rcx,rdi
       mov       rdx,rbx
       call      qword ptr [5818]; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       jmp       near ptr 00000000000021FC
M00_L13:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,46B
       mov       rdx,7FFB2D293880
       call      qword ptr [7258]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdx,rax
       mov       rcx,rbx
       call      qword ptr [0E910]; Precode of System.ArgumentException..ctor(System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 575
```
```assembly
; Tedd.Voxtree.OctreeCodec.ValidateLevels(Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,50
       xor       eax,eax
       mov       [rsp+28],rax
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+30],ymm4
       mov       ebx,ecx
       cmp       ebx,9
       ja        short 000000000000263A
       vzeroupper
       add       rsp,50
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M01_L00:
       mov       rcx,offset MT_System.Int32
       call      0000000000005240
       mov       rsi,rax
       mov       [rsi+8],ebx
       lea       rcx,[rsp+28]
       mov       edx,31
       mov       r8d,1
       call      qword ptr [67F0]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       ja        short 00000000000026E7
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       cmp       eax,30
       jb        short 00000000000026B8
       vmovups   ymm0,[2780]
       vmovups   [rdx],ymm0
       vmovups   ymm0,[27A0]
       vmovups   [rdx+20],ymm0
       vmovups   ymm0,[27C0]
       vmovups   [rdx+40],ymm0
       mov       ecx,[rsp+38]
       add       ecx,30
       mov       [rsp+38],ecx
       jmp       short 00000000000026CD
M01_L01:
       lea       rcx,[rsp+28]
       mov       rdx,29E00212818
       call      qword ptr [6808]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L02:
       lea       rcx,[rsp+28]
       mov       edx,9
       call      qword ptr [6AD8]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       mov       ecx,[rsp+38]
       cmp       ecx,[rsp+48]
       jbe       short 00000000000026EE
M01_L03:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L04:
       mov       rdx,[rsp+40]
       mov       eax,ecx
       lea       rdx,[rdx+rax*2]
       mov       eax,[rsp+48]
       sub       eax,ecx
       je        short 0000000000002712
       mov       word ptr [rdx],2E
       mov       ecx,[rsp+38]
       inc       ecx
       mov       [rsp+38],ecx
       jmp       short 0000000000002727
M01_L05:
       lea       rcx,[rsp+28]
       mov       rdx,29E00200658
       call      qword ptr [6808]; Precode of System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
M01_L06:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       ecx,12BF
       mov       rdx,7FFB2D293880
       call      qword ptr [7258]; Precode of System.String.StrCns(UInt32, IntPtr)
       mov       rdi,rax
       lea       rcx,[rsp+28]
       call      qword ptr [6820]; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       mov       r9,rax
       mov       rdx,rdi
       mov       r8,rsi
       mov       rcx,rbx
       call      qword ptr [7D38]; Precode of System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 359
```
```assembly
; Tedd.Voxtree.DenseVoxel.ConvertLayout[[System.UInt32, System.Private.CoreLib]](System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,48
       lea       rbp,[rsp+20]
       mov       rax,0CCF4BF791BB3
       mov       [rbp+8],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       edx,4
       mul       rdx
       jb        near ptr 00000000000088A5
       test      rax,rax
       je        short 000000000000872E
       add       rax,0F
       shr       rax,4
       add       rsp,20
M02_L00:
       push      0
       push      0
       dec       rax
       jne       short 000000000000871C
       sub       rsp,20
       lea       rax,[rsp+20]
M02_L01:
       test      r8d,r8d
       jl        near ptr 0000000000008898
       xor       edx,edx
       test      r8d,r8d
       jle       short 0000000000008776
       xor       esi,esi
       mov       edi,24924924
       pdep      esi,esi,edi
       xor       edi,edi
       mov       r14d,12492492
       pdep      edi,edi,r14d
       or        esi,edi
       nop       dword ptr [rax]
M02_L02:
       mov       edi,9249249
       pdep      edi,edx,edi
       or        edi,esi
       mov       [rax+rdx*4],edi
       inc       edx
       cmp       edx,r8d
       jl        short 0000000000008760
M02_L03:
       xor       edx,edx
       test      r9d,r9d
       jne       near ptr 0000000000008820
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 00000000000087F9
M02_L04:
       mov       [rbp+24],r9d
       mov       esi,r9d
       mov       [rbp+18],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L05:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L06:
       mov       r9d,[rax+r13]
       shl       r9d,2
       or        r9d,r15d
       lea       esi,[rdx+1]
       cmp       r9d,r11d
       jae       near ptr 000000000000889F
       cmp       edx,ecx
       jae       near ptr 000000000000889F
       mov       edx,edx
       mov       edx,[rbx+rdx*4]
       mov       [r10+r9*4],edx
       add       r13,4
       dec       r12d
       mov       edx,esi
       jne       short 00000000000087AD
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+18]
       jne       short 0000000000008799
       mov       r9d,[rbp+24]
       inc       r9d
       cmp       r9d,r8d
       jl        short 0000000000008789
M02_L07:
       mov       r8,0CCF4BF791BB3
       cmp       [rbp+8],r8
       je        short 000000000000880E
       call      000000000000BD80
M02_L08:
       nop
       lea       rsp,[rbp+28]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M02_L09:
       xor       r9d,r9d
       test      r8d,r8d
       jle       short 00000000000087F9
M02_L10:
       mov       [rbp+20],r9d
       mov       esi,r9d
       mov       [rbp+10],rsi
       xor       edi,edi
       mov       r14d,r8d
M02_L11:
       mov       r15d,[rax+rsi*4]
       mov       r13d,[rax+rdi]
       add       r13d,r13d
       or        r15d,r13d
       xor       r13d,r13d
       mov       r12d,r8d
M02_L12:
       lea       r9d,[rdx+1]
       cmp       edx,r11d
       jae       short 000000000000889F
       mov       edx,edx
       lea       rdx,[r10+rdx*4]
       mov       esi,[rax+r13]
       shl       esi,2
       or        esi,r15d
       cmp       esi,ecx
       jae       short 000000000000889F
       mov       esi,[rbx+rsi*4]
       mov       [rdx],esi
       add       r13,4
       dec       r12d
       mov       edx,r9d
       jne       short 000000000000884C
       add       rdi,4
       dec       r14d
       mov       rsi,[rbp+10]
       jne       short 0000000000008838
       mov       r9d,[rbp+20]
       inc       r9d
       cmp       r9d,r8d
       jl        short 0000000000008828
       jmp       near ptr 00000000000087F9
M02_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M02_L14:
       call      0000000000001788
       int       3
M02_L15:
       call      0000000000001770
       int       3
; Total bytes of code 491
```
```assembly
; System.SpanHelpers.Memmove(Byte ByRef, Byte ByRef, UIntPtr)
       mov       rax,rcx
       sub       rax,rdx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       mov       rax,rdx
       sub       rax,rcx
       cmp       rax,r8
       jb        near ptr 000000000000C177
       lea       rax,[rdx+r8]
       lea       r10,[rcx+r8]
       cmp       r8,10
       jbe       short 000000000000C0AB
       cmp       r8,40
       ja        near ptr 000000000000C0F3
M03_L00:
       vmovups   xmm0,[rdx]
       vmovups   [rcx],xmm0
       cmp       r8,20
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+10]
       vmovups   [rcx+10],xmm0
       cmp       r8,30
       jbe       near ptr 000000000000C13D
       vmovups   xmm0,[rdx+20]
       vmovups   [rcx+20],xmm0
       jmp       near ptr 000000000000C13D
M03_L01:
       test      r8b,18
       je        short 000000000000C0C4
       mov       r8,[rdx]
       mov       [rcx],r8
       mov       rdx,[rax+0FFF8]
       mov       [r10+0FFF8],rdx
       jmp       near ptr 000000000000C148
M03_L02:
       test      r8b,4
       jne       short 000000000000C0E6
       test      r8,r8
       je        short 000000000000C148
       movzx     edx,byte ptr [rdx]
       mov       [rcx],dl
       test      r8b,2
       je        short 000000000000C148
       movsx     rcx,word ptr [rax+0FFFE]
       mov       [r10+0FFFE],cx
       jmp       short 000000000000C148
M03_L03:
       mov       edx,[rdx]
       mov       [rcx],edx
       mov       ecx,[rax+0FFFC]
       mov       [r10+0FFFC],ecx
       jmp       short 000000000000C148
M03_L04:
       cmp       r8,800
       ja        near ptr 000000000000C180
       cmp       r8,100
       jae       short 000000000000C14C
M03_L05:
       mov       r9,r8
       shr       r9,6
M03_L06:
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rcx,40
       add       rdx,40
       dec       r9
       jne       short 000000000000C110
       and       r8,3F
       cmp       r8,10
       ja        near ptr 000000000000C076
M03_L07:
       vmovups   xmm0,[rax+0FFF0]
       vmovups   [r10+0FFF0],xmm0
M03_L08:
       vzeroupper
       ret
M03_L09:
       mov       r9,rcx
       and       r9,3F
       neg       r9
       add       r9,40
       vmovdqu   ymm0,ymmword ptr [rdx]
       vmovdqu   ymmword ptr [rcx],ymm0
       vmovdqu   ymm0,ymmword ptr [rdx+20]
       vmovdqu   ymmword ptr [rcx+20],ymm0
       add       rdx,r9
       add       rcx,r9
       sub       r8,r9
       jmp       short 000000000000C109
M03_L10:
       cmp       rcx,rdx
       jne       short 000000000000C180
       cmp       [rdx],dl
       jmp       short 000000000000C148
M03_L11:
       cmp       [rcx],cl
       cmp       [rdx],dl
       vzeroupper
       jmp       qword ptr [66E8]; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
; Total bytes of code 333
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler..ctor(Int32, Int32)
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,20
       mov       rbx,rcx
       mov       esi,edx
       mov       edi,r8d
       xor       eax,eax
       mov       [rbx],rax
       call      qword ptr [0A098]
       mov       rcx,[rax]
       imul      edx,edi,0B
       add       edx,esi
       mov       eax,100
       cmp       edx,100
       cmovle    edx,eax
       cmp       [rcx],ecx
       call      qword ptr [98B8]
       mov       [rbx+8],rax
       test      rax,rax
       je        short 000000000000C4E0
       lea       rcx,[rax+10]
       mov       eax,[rax+8]
M04_L00:
       mov       [rbx+18],rcx
       mov       [rbx+20],eax
       xor       eax,eax
       mov       [rbx+10],eax
       mov       byte ptr [rbx+14],0
       add       rsp,20
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M04_L01:
       xor       ecx,ecx
       xor       eax,eax
       jmp       short 000000000000C4C8
; Total bytes of code 102
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.AppendFormatted[[System.Int32, System.Private.CoreLib]](Int32)
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,58
       xorps     xmm4,xmm4
       movaps    [rsp+30],xmm4
       movaps    [rsp+40],xmm4
       mov       rbx,rcx
       mov       esi,edx
       cmp       byte ptr [rbx+14],0
       jne       short 000000000000F15B
M05_L00:
       lea       rdx,[rbx+18]
       mov       r8d,[rbx+10]
       mov       edi,[rdx+8]
       cmp       r8d,edi
       ja        near ptr 000000000000F1D8
       mov       rdx,[rdx]
       mov       ecx,r8d
       lea       rbp,[rdx+rcx*2]
       sub       edi,r8d
       mov       rcx,[rbx]
       test      esi,esi
       jl        short 000000000000F173
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       rdx,[rsp+40]
       lea       r8,[rsp+50]
       mov       ecx,esi
       call      qword ptr [0CF8]; Precode of System.Number.TryUInt32ToDecStr[[System.Char, System.Private.CoreLib]](UInt32, System.Span`1<Char>, Int32 ByRef)
M05_L01:
       test      eax,eax
       jne       short 000000000000F152
       mov       rcx,rbx
       call      qword ptr [4FF8]
       jmp       short 000000000000F100
M05_L02:
       mov       eax,[rsp+50]
       add       [rbx+10],eax
       jmp       short 000000000000F169
M05_L03:
       mov       rcx,rbx
       mov       edx,esi
       xor       r8d,r8d
       call      qword ptr [1B50]
M05_L04:
       nop
       add       rsp,58
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M05_L05:
       test      rcx,rcx
       je        short 000000000000F180
       call      qword ptr [1260]; Precode of System.Globalization.NumberFormatInfo.<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider)
       jmp       short 000000000000F186
M05_L06:
       call      qword ptr [1248]; Precode of System.Globalization.NumberFormatInfo.get_CurrentInfo()
M05_L07:
       mov       r8,[rax+28]
       test      r8,r8
       jne       short 000000000000F197
       xor       r9d,r9d
       xor       r8d,r8d
       jmp       short 000000000000F19F
M05_L08:
       lea       r9,[r8+0C]
       mov       r8d,[r8+8]
M05_L09:
       mov       [rsp+30],r9
       mov       [rsp+38],r8d
       mov       [rsp+40],rbp
       mov       [rsp+48],edi
       lea       r8,[rsp+50]
       mov       [rsp+20],r8
       lea       r8,[rsp+30]
       lea       r9,[rsp+40]
       mov       ecx,esi
       mov       edx,0FFFFFFFF
       call      qword ptr [0CE0]
       jmp       near ptr 000000000000F143
M05_L10:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 255
```
```assembly
; System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.ToStringAndClear()
       push      rdi
       push      rsi
       push      rbp
       push      rbx
       sub       rsp,38
       xor       eax,eax
       mov       [rsp+28],rax
       mov       rbx,rcx
       lea       rsi,[rbx+18]
       mov       rcx,rsi
       mov       eax,[rbx+10]
       cmp       eax,[rcx+8]
       ja        short 000000000000C6F7
       mov       rcx,[rcx]
       mov       [rsp+28],rcx
       mov       [rsp+30],eax
       lea       rcx,[rsp+28]
       call      qword ptr [0BB28]; Precode of System.String.Ctor(System.ReadOnlySpan`1<Char>)
       mov       rdi,rax
       mov       rbp,[rbx+8]
       xor       eax,eax
       mov       [rbx+8],rax
       mov       [rsi],rax
       mov       [rsi+8],rax
       mov       [rbx+10],eax
       test      rbp,rbp
       je        short 000000000000C6EB
       call      qword ptr [0A098]
       mov       rcx,[rax]
       mov       rdx,rbp
       xor       r8d,r8d
       cmp       [rcx],ecx
       call      qword ptr [98C0]; Precode of System.Buffers.SharedArrayPool`1[[System.Char, System.Private.CoreLib]].Return(Char[], Boolean)
M06_L00:
       mov       rax,rdi
       add       rsp,38
       pop       rbx
       pop       rbp
       pop       rsi
       pop       rdi
       ret
M06_L01:
       call      qword ptr [0F2B8]
       int       3
; Total bytes of code 126
```
```assembly
; System.Buffer.MemmoveInternal(Byte ByRef, Byte ByRef, UIntPtr)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,0A8
       lea       rbp,[rsp+0E0]
       mov       [rbp+0FFC0],rcx
       mov       [rbp+0FFB8],rdx
       mov       [rbp+0FF58],rcx
       mov       [rbp+0FF50],rdx
       mov       [rbp+0FF48],r8
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9030]; CORINFO_HELP_JIT_PINVOKE_BEGIN
       mov       rax,[5A58]
       mov       rcx,[rbp+0FF58]
       mov       rdx,[rbp+0FF50]
       mov       r8,[rbp+0FF48]
       call      qword ptr [rax]
       lea       rcx,[rbp+0FF60]
       call      qword ptr [9038]; CORINFO_HELP_JIT_PINVOKE_END
       xor       eax,eax
       mov       [rbp+0FFB8],rax
       mov       [rbp+0FFC0],rax
       add       rsp,0A8
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
; Total bytes of code 142
```
**Method was not JITted yet.**
System.String.StrCns(UInt32, IntPtr)
System.ArgumentOutOfRangeException..ctor(System.String)
System.ArgumentException..ctor(System.String)
System.ThrowHelper.ThrowArgumentOutOfRangeException()
System.Runtime.CompilerServices.DefaultInterpolatedStringHandler.GrowThenCopyString(System.String)
System.ArgumentOutOfRangeException..ctor(System.String, System.Object, System.String)

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.PrevalidatedRows()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 00000000000015FD
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000001606
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 000000000000160F
       cmp       r9d,1
       ja        near ptr 000000000000160F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000001633
       cmp       edx,edi
       jl        near ptr 0000000000001633
       cmp       edi,edx
       ja        near ptr 0000000000001657
       test      edi,edi
       je        short 00000000000015D2
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 000000000000165E
       neg       rax
       cmp       rax,rcx
       jb        near ptr 000000000000165E
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CEE8]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000001555
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000001569
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E718]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CEB8]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CEB8]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRows(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,58
       lea       rbp,[rsp+20]
       mov       rax,0D3EB50BF9A86
       mov       [rbp],rax
       mov       r10,[rdx]
       mov       r11d,[rdx+8]
       mov       rbx,[rcx]
       mov       ecx,[rcx+8]
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       [rbp+34],r8d
       mov       esi,r8d
       mov       [rbp+28],rsi
       mov       eax,4
       mul       rsi
       jb        near ptr 0000000000009D98
       test      rax,rax
       je        short 0000000000009BD6
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000009BC4
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 0000000000009D8B
       mov       edx,r8d
       mov       [rbp+30],edx
       xor       edi,edi
       test      r8d,r8d
       jle       short 0000000000009C29
       xor       r14d,r14d
       mov       r15d,24924924
       pdep      r14d,r14d,r15d
       xor       r15d,r15d
       mov       r13d,12492492
       pdep      r15d,r15d,r13d
       or        r14d,r15d
       nop       dword ptr [rax+rax]
M01_L02:
       mov       r15d,9249249
       pdep      r15d,edi,r15d
       or        r15d,r14d
       mov       [rax+rdi*4],r15d
       inc       edi
       cmp       edi,r8d
       jl        short 0000000000009C10
M01_L03:
       xor       edi,edi
       test      r9d,r9d
       jne       near ptr 0000000000009CF5
       test      edx,edx
       jle       near ptr 0000000000009CCE
       xor       r9d,r9d
       mov       [rbp+0C],edx
M01_L04:
       xor       r15d,r15d
       mov       r13d,edx
M01_L05:
       mov       [rbp+10],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       r9d,ecx
       cmp       r12,r9
       ja        near ptr 0000000000009D8B
       mov       r9d,edi
       lea       r9,[rbx+r9*4]
       xor       r12d,r12d
       mov       esi,r8d
M01_L06:
       mov       edx,[rax+r12]
       shl       edx,2
       or        edx,r14d
       cmp       edx,r11d
       jae       near ptr 0000000000009D92
       mov       r8d,[r9+r12]
       mov       [r10+rdx*4],r8d
       add       r12,4
       dec       esi
       jne       short 0000000000009C79
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+10]
       jne       short 0000000000009C48
       add       r9,4
       mov       r14d,[rbp+0C]
       dec       r14d
       mov       [rbp+0C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 0000000000009C42
M01_L07:
       mov       r8,0D3EB50BF9A86
       cmp       [rbp],r8
       je        short 0000000000009CE3
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+38]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       test      edx,edx
       jle       short 0000000000009CCE
       xor       r9d,r9d
       mov       [rbp+1C],edx
M01_L10:
       xor       r15d,r15d
       mov       r13d,edx
M01_L11:
       mov       [rbp+20],r9
       mov       r12d,[rax+r9]
       mov       r14d,[rax+r15]
       add       r14d,r14d
       or        r14d,r12d
       mov       r12d,edi
       add       r12,rsi
       mov       esi,r11d
       cmp       r12,rsi
       ja        short 0000000000009D8B
       mov       esi,edi
       lea       rsi,[r10+rsi*4]
       xor       r12d,r12d
       mov       edx,r8d
M01_L12:
       lea       r8,[rsi+r12]
       mov       r9d,[rax+r12]
       shl       r9d,2
       or        r9d,r14d
       cmp       r9d,ecx
       jae       short 0000000000009D92
       mov       r9d,[rbx+r9*4]
       mov       [r8],r9d
       add       r12,4
       dec       edx
       jne       short 0000000000009D31
       mov       edx,[rbp+30]
       add       edi,edx
       add       r15,4
       dec       r13d
       mov       rsi,[rbp+28]
       mov       r8d,[rbp+34]
       mov       r9,[rbp+20]
       jne       short 0000000000009D05
       add       r9,4
       mov       r14d,[rbp+1C]
       dec       r14d
       mov       [rbp+1C],r14d
       mov       edx,[rbp+30]
       jne       near ptr 0000000000009CFF
       jmp       near ptr 0000000000009CCE
M01_L13:
       call      qword ptr [7C18]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001788
       int       3
M01_L15:
       call      0000000000001770
       int       3
; Total bytes of code 574
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()

## .NET 10.0.12 (10.0.12, 10.0.1226.42308), X64 RyuJIT x86-64-v3 (Job: Job-BZNPUE(IterationCount=5, IterationTime=200ms, LaunchCount=1, WarmupCount=3))

```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ManagedReference()
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,40
       vxorps    xmm4,xmm4,xmm4
       vmovdqu   ymmword ptr [rsp+20],ymm4
       mov       rax,[rcx+8]
       test      rax,rax
       je        near ptr 0000000000001F4D
       lea       rbx,[rax+10]
       mov       eax,[rax+8]
M00_L00:
       mov       rdx,[rcx+10]
       test      rdx,rdx
       je        near ptr 0000000000001F56
       lea       rsi,[rdx+10]
       mov       edx,[rdx+8]
M00_L01:
       mov       r8d,[rcx+18]
       mov       r9d,[rcx+1C]
       cmp       r8d,9
       ja        near ptr 0000000000001F5F
       cmp       r9d,1
       ja        near ptr 0000000000001F5F
       lea       ecx,[r8+r8*2]
       mov       r10d,1
       shlx      edi,r10d,ecx
       cmp       eax,edi
       jne       near ptr 0000000000001F83
       cmp       edx,edi
       jl        near ptr 0000000000001F83
       cmp       edi,edx
       ja        near ptr 0000000000001FA7
       test      edi,edi
       je        short 0000000000001F22
       mov       rcx,rsi
       sub       rcx,rbx
       movsxd    rax,edi
       shl       rax,2
       cmp       rcx,rax
       jb        near ptr 0000000000001FAE
       neg       rax
       cmp       rax,rcx
       jb        near ptr 0000000000001FAE
M00_L02:
       mov       [rsp+30],rbx
       mov       [rsp+38],edi
       mov       [rsp+20],rsi
       mov       [rsp+28],edi
       lea       rcx,[rsp+30]
       lea       rdx,[rsp+20]
       call      qword ptr [0CF60]; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       nop
       add       rsp,40
       pop       rbx
       pop       rsi
       pop       rdi
       ret
M00_L03:
       xor       ebx,ebx
       xor       eax,eax
       jmp       near ptr 0000000000001EA5
M00_L04:
       xor       esi,esi
       xor       edx,edx
       jmp       near ptr 0000000000001EB9
M00_L05:
       mov       rcx,offset MT_System.ArgumentOutOfRangeException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0E4C0]; Precode of System.ArgumentOutOfRangeException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L06:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF48]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
M00_L07:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M00_L08:
       mov       rcx,offset MT_System.ArgumentException
       call      0000000000005240
       mov       rbx,rax
       mov       rcx,rbx
       call      qword ptr [0CF48]; Precode of System.ArgumentException..ctor()
       mov       rcx,rbx
       call      000000000000B8A0
       int       3
; Total bytes of code 338
```
```assembly
; Tedd.Voxtree.Benchmark.Tests.AccessBoundsConversion.ConvertRefs(System.ReadOnlySpan`1<UInt32>, System.Span`1<UInt32>, Int32, Tedd.Voxtree.DenseVoxelLayout)
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,28
       lea       rbp,[rsp+20]
       mov       rax,4674E28B55CA
       mov       [rbp],rax
       mov       r10,rdx
       mov       eax,1
       shlx      r8d,eax,r8d
       mov       eax,r8d
       mov       r11d,4
       mul       r11
       jb        near ptr 0000000000009E73
       test      rax,rax
       je        short 0000000000009D25
       add       rax,0F
       shr       rax,4
       add       rsp,20
M01_L00:
       push      0
       push      0
       dec       rax
       jne       short 0000000000009D13
       sub       rsp,20
       lea       rax,[rsp+20]
M01_L01:
       test      r8d,r8d
       jl        near ptr 0000000000009E6C
       mov       edx,r8d
       xor       r11d,r11d
       test      r8d,r8d
       jle       short 0000000000009D78
       xor       ebx,ebx
       mov       esi,24924924
       pdep      ebx,ebx,esi
       xor       esi,esi
       mov       edi,12492492
       pdep      esi,esi,edi
       or        ebx,esi
       nop       dword ptr [rax+rax]
       nop       dword ptr [rax+rax]
M01_L02:
       mov       esi,9249249
       pdep      esi,r11d,esi
       or        esi,ebx
       mov       [rax+r11*4],esi
       inc       r11d
       cmp       r11d,r8d
       jl        short 0000000000009D60
M01_L03:
       mov       rcx,[rcx]
       mov       r8,[r10]
       xor       r10d,r10d
       test      r9d,r9d
       jne       near ptr 0000000000009E0C
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009DE5
M01_L04:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L05:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L06:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       movsxd    r10,r10d
       mov       r10d,[rcx+r10*4]
       mov       [r8+r12*4],r10d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 0000000000009DAC
       add       rbx,4
       dec       esi
       jne       short 0000000000009D98
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000009D91
M01_L07:
       mov       r8,4674E28B55CA
       cmp       [rbp],r8
       je        short 0000000000009DFA
       call      000000000000BD80
M01_L08:
       nop
       lea       rsp,[rbp+8]
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L09:
       xor       r9d,r9d
       test      edx,edx
       jle       short 0000000000009DE5
M01_L10:
       mov       r11d,r9d
       xor       ebx,ebx
       mov       esi,edx
M01_L11:
       mov       edi,[rax+r11*4]
       mov       r14d,[rax+rbx]
       add       r14d,r14d
       or        edi,r14d
       xor       r14d,r14d
       mov       r15d,edx
M01_L12:
       lea       r13d,[r10+1]
       mov       r12d,[rax+r14]
       shl       r12d,2
       or        r12d,edi
       movsxd    r12,r12d
       mov       r12d,[rcx+r12*4]
       movsxd    r10,r10d
       mov       [r8+r10*4],r12d
       add       r14,4
       dec       r15d
       mov       r10d,r13d
       jne       short 0000000000009E2E
       add       rbx,4
       dec       esi
       jne       short 0000000000009E1A
       inc       r9d
       cmp       r9d,edx
       jl        short 0000000000009E13
       jmp       near ptr 0000000000009DE5
M01_L13:
       call      qword ptr [7C30]; Precode of System.ThrowHelper.ThrowArgumentOutOfRangeException()
       int       3
M01_L14:
       call      0000000000001770
       int       3
; Total bytes of code 441
```
**Method was not JITted yet.**
System.ArgumentOutOfRangeException..ctor()
System.ArgumentException..ctor()
System.ThrowHelper.ThrowArgumentOutOfRangeException()
