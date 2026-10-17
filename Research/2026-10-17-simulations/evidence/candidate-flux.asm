; Assembly listing for method Tedd.Voxtree.Simulations.SimulationWorkload:Flux(int,int,int,int,int,int,uint):long:this (FullOpts)
; Emitting BLENDED_CODE for generic X64 + VEX on Windows
; FullOpts code
; optimized code
; rsp based frame
; partially interruptible
; No PGO data
; 4 inlinees with PGO data; 19 single block inlinees; 11 inlinees without PGO data

G_M000_IG01:                ;; offset=0x0000
       push     r15
       push     r14
       push     r13
       push     r12
       push     rdi
       push     rsi
       push     rbp
       push     rbx
       sub      rsp, 88
       xor      eax, eax
       mov      qword ptr [rsp+0x40], rax
       mov      qword ptr [rsp+0x48], rax
       mov      rbx, rcx
       mov      esi, edx
       mov      edi, r8d
       mov      ebp, r9d
       mov      r14d, dword ptr [rsp+0xC0]
       mov      r15d, dword ptr [rsp+0xC8]
       mov      r13d, dword ptr [rsp+0xD0]
       mov      r12d, dword ptr [rsp+0xD8]

G_M000_IG02:                ;; offset=0x0047
       mov      rax, gword ptr [rbx+0x18]
       mov      gword ptr [rsp+0x30], rax
       cmp      byte  ptr [rax], al
       mov      rcx, rax
       call     [Tedd.Voxtree.HotOctreeChunk:GetValues():uint[]:this]
       mov      rcx, gword ptr [rsp+0x30]
       cmp      dword ptr [rcx+0x24], 0
       je       G_M000_IG12
       mov      ecx, dword ptr [rcx+0x20]
       lea      edx, [rcx+2*rcx]
       mov      r8d, 1
       shlx     edx, r8d, edx
       test     rax, rax
       je       G_M000_IG13

G_M000_IG03:                ;; offset=0x0084
       cmp      dword ptr [rax+0x08], edx
       jb       G_M000_IG17
       add      rax, 16

G_M000_IG04:                ;; offset=0x0091
       mov      r8d, r14d
       or       r8d, r15d
       or       r8d, r13d
       mov      r10d, 1
       shlx     ecx, r10d, ecx
       cmp      r8d, ecx
       jae      G_M000_IG14
       mov      ecx, 0x24924924
       pdep     r8d, r13d, ecx
       mov      ecx, 0x12492492
       pdep     r10d, r15d, ecx
       or       r8d, r10d
       mov      ecx, 0x9249249
       pdep     r10d, r14d, ecx
       or       r8d, r10d
       mov      dword ptr [rsp+0x3C], r8d
       mov      ecx, r8d
       cmp      ecx, edx
       jae      G_M000_IG20
       mov      eax, dword ptr [rax+4*rcx]
       mov      dword ptr [rsp+0x54], eax
       cmp      dword ptr [rbx+0x3C], 0
       jne      G_M000_IG10

G_M000_IG05:                ;; offset=0x00F3
       mov      rdx, gword ptr [rbx+0x18]
       mov      gword ptr [rsp+0x28], rdx
       cmp      byte  ptr [rdx], dl
       mov      rcx, rdx
       call     [Tedd.Voxtree.HotOctreeChunk:GetValues():uint[]:this]
       mov      rdx, gword ptr [rsp+0x28]
       cmp      dword ptr [rdx+0x24], 1
       jbe      G_M000_IG15
       mov      edx, dword ptr [rdx+0x20]
       lea      ecx, [rdx+2*rdx]
       mov      r8d, 1
       shlx     ecx, r8d, ecx
       test     rax, rax
       je       G_M000_IG16
       mov      r8d, ecx
       lea      r10, [r8+r8]
       mov      r9d, dword ptr [rax+0x08]
       cmp      r10, r9
       ja       G_M000_IG17
       lea      r8, bword ptr [rax+4*r8+0x10]

G_M000_IG06:                ;; offset=0x0149
       mov      eax, esi
       or       eax, edi
       or       eax, ebp
       mov      r10d, 1
       shlx     edx, r10d, edx
       cmp      eax, edx
       jae      G_M000_IG18
       mov      edx, 0x24924924
       pdep     edx, ebp, edx
       mov      eax, 0x12492492
       pdep     eax, edi, eax
       or       edx, eax
       mov      eax, 0x9249249
       pdep     eax, esi, eax
       or       edx, eax
       cmp      edx, ecx
       jae      G_M000_IG20
       mov      esi, dword ptr [r8+4*rdx]
       mov      edi, r12d
       add      rsi, rdi
       mov      rbx, gword ptr [rbx+0x18]
       cmp      byte  ptr [rbx], bl
       lea      rdx, [rsp+0x40]
       mov      rcx, rbx
       mov      r8d, 1
       call     [Tedd.Voxtree.HotOctreeChunk:GetChannelSpan(int):System.Span`1[uint]:this]
       or       r14d, r15d
       or       r14d, r13d
       mov      eax, dword ptr [rbx+0x20]
       mov      ecx, 1
       shlx     eax, ecx, eax
       cmp      r14d, eax
       jae      G_M000_IG19
       mov      ebx, dword ptr [rsp+0x3C]
       cmp      ebx, dword ptr [rsp+0x48]
       jae      G_M000_IG20
       mov      rax, bword ptr [rsp+0x40]
       mov      ecx, ebx
       mov      eax, dword ptr [rax+4*rcx]
       mov      ebx, dword ptr [rsp+0x54]
       mov      ecx, ebx
       add      rax, rcx
       sub      rax, rsi
       mov      rcx, rax
       sar      rcx, 63
       and      rcx, 7
       add      rax, rcx
       sar      rax, 3
       js       SHORT G_M000_IG08
       shr      ebx, 2
       mov      ecx, ebx
       cmp      rax, rcx
       cmovg    rax, rcx

G_M000_IG07:                ;; offset=0x0210
       add      rsp, 88
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG08:                ;; offset=0x0221
       neg      rax
       shr      r12d, 2
       mov      ecx, r12d
       cmp      rax, rcx
       cmovg    rax, rcx
       neg      rax

G_M000_IG09:                ;; offset=0x0235
       add      rsp, 88
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG10:                ;; offset=0x0246
       mov      eax, dword ptr [rsp+0x54]
       mov      edx, r12d
       sub      rax, rdx
       mov      edx, 8
       mov      ecx, 16
       cmp      dword ptr [rbx+0x3C], 1
       cmovne   edx, ecx
       mov      ecx, edx
       cqo
       idiv     rdx:rax, rcx

G_M000_IG11:                ;; offset=0x0268
       add      rsp, 88
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG12:                ;; offset=0x0279
       mov      rcx, 0x7FFC6567F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3ED
       mov      rdx, 0x7FFC6582F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG13:                ;; offset=0x02B5
       test     edx, edx
       jne      G_M000_IG17
       xor      rax, rax
       xor      edx, edx
       jmp      G_M000_IG04

G_M000_IG14:                ;; offset=0x02C6
       mov      rcx, 0x7FFC6567F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3FD
       mov      rdx, 0x7FFC6582F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG15:                ;; offset=0x0302
       mov      rcx, 0x7FFC6567F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3ED
       mov      rdx, 0x7FFC6582F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG16:                ;; offset=0x033E
       test     ecx, ecx
       jne      SHORT G_M000_IG17
       xor      r8, r8
       xor      ecx, ecx
       jmp      G_M000_IG06

G_M000_IG17:                ;; offset=0x034C
       call     [System.ThrowHelper:ThrowArgumentOutOfRangeException()]
       int3

G_M000_IG18:                ;; offset=0x0353
       mov      rcx, 0x7FFC6567F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3FD
       mov      rdx, 0x7FFC6582F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG19:                ;; offset=0x038F
       mov      rcx, 0x7FFC6567F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3FD
       mov      rdx, 0x7FFC6582F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG20:                ;; offset=0x03CB
       call     CORINFO_HELP_RNGCHKFAIL
       int3

; Total bytes of code 977
