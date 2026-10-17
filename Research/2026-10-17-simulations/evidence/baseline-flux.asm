; Assembly listing for method Tedd.Voxtree.Simulations.SimulationWorkload:Flux(int,int,int,int,int,int,uint):long:this (FullOpts)
; Emitting BLENDED_CODE for generic X64 + VEX on Windows
; FullOpts code
; optimized code
; rsp based frame
; partially interruptible
; No PGO data
; 4 inlinees with PGO data; 16 single block inlinees; 10 inlinees without PGO data

G_M000_IG01:                ;; offset=0x0000
       push     r15
       push     r14
       push     r13
       push     r12
       push     rdi
       push     rsi
       push     rbp
       push     rbx
       sub      rsp, 120
       xor      eax, eax
       mov      qword ptr [rsp+0x58], rax
       mov      qword ptr [rsp+0x60], rax
       mov      rbx, rcx
       mov      esi, edx
       mov      edi, r8d
       mov      ebp, r9d
       mov      r14d, dword ptr [rsp+0xE0]
       mov      r15d, dword ptr [rsp+0xE8]
       mov      r13d, dword ptr [rsp+0xF0]
       mov      r12d, dword ptr [rsp+0xF8]

G_M000_IG02:                ;; offset=0x0047
       mov      rax, gword ptr [rbx+0x18]
       mov      gword ptr [rsp+0x48], rax
       cmp      byte  ptr [rax], al
       mov      rcx, rax
       call     [Tedd.Voxtree.HotOctreeChunk:GetValues():uint[]:this]
       mov      rcx, gword ptr [rsp+0x48]
       cmp      dword ptr [rcx+0x24], 0
       je       G_M000_IG13
       mov      edx, dword ptr [rcx+0x20]
       lea      ecx, [rdx+2*rdx]
       mov      r8d, 1
       shlx     r8d, r8d, ecx
       test     rax, rax
       je       G_M000_IG14

G_M000_IG03:                ;; offset=0x0084
       cmp      dword ptr [rax+0x08], r8d
       jb       G_M000_IG18
       add      rax, 16
       mov      r10d, r8d
       mov      bword ptr [rsp+0x38], rax
       mov      dword ptr [rsp+0x54], r10d

G_M000_IG04:                ;; offset=0x009F
       mov      dword ptr [rsp+0x70], edx
       mov      ecx, edx
       call     [Tedd.Voxtree.OctreeCodec:ValidateLevels(int)]
       mov      ecx, 1
       mov      edx, dword ptr [rsp+0x70]
       shlx     ecx, ecx, edx
       cmp      r14d, ecx
       jae      G_M000_IG15
       cmp      r15d, ecx
       jae      G_M000_IG15
       cmp      r13d, ecx
       jae      G_M000_IG15
       mov      ecx, 0x24924924
       pdep     ecx, r13d, ecx
       mov      eax, 0x12492492
       pdep     eax, r15d, eax
       or       ecx, eax
       mov      eax, 0x9249249
       pdep     eax, r14d, eax
       or       ecx, eax
       cmp      ecx, dword ptr [rsp+0x54]
       jae      G_M000_IG20
       mov      rax, bword ptr [rsp+0x38]
       mov      eax, dword ptr [rax+4*rcx]
       mov      dword ptr [rsp+0x74], eax
       cmp      dword ptr [rbx+0x3C], 0
       jne      G_M000_IG11

G_M000_IG05:                ;; offset=0x0116
       mov      rdx, gword ptr [rbx+0x18]
       mov      gword ptr [rsp+0x40], rdx
       cmp      byte  ptr [rdx], dl
       mov      rcx, rdx
       call     [Tedd.Voxtree.HotOctreeChunk:GetValues():uint[]:this]
       mov      rcx, gword ptr [rsp+0x40]
       cmp      dword ptr [rcx+0x24], 1
       jbe      G_M000_IG16
       mov      edx, dword ptr [rcx+0x20]
       lea      ecx, [rdx+2*rdx]
       mov      r8d, 1
       shlx     r8d, r8d, ecx
       test     rax, rax
       je       G_M000_IG17
       mov      ecx, r8d
       lea      r10, [rcx+rcx]
       mov      r9d, dword ptr [rax+0x08]
       cmp      r10, r9
       ja       G_M000_IG18
       lea      rax, bword ptr [rax+4*rcx+0x10]
       mov      r10d, r8d
       mov      bword ptr [rsp+0x30], rax
       mov      dword ptr [rsp+0x50], r10d

G_M000_IG06:                ;; offset=0x0179
       mov      dword ptr [rsp+0x6C], edx
       mov      ecx, edx
       call     [Tedd.Voxtree.OctreeCodec:ValidateLevels(int)]
       mov      edx, 1
       mov      ecx, dword ptr [rsp+0x6C]
       shlx     edx, edx, ecx
       cmp      esi, edx
       jae      G_M000_IG19
       cmp      edi, edx
       jae      G_M000_IG19
       cmp      ebp, edx
       jae      G_M000_IG19
       mov      edx, 0x24924924
       pdep     edx, ebp, edx
       mov      ecx, 0x12492492
       pdep     ecx, edi, ecx
       or       edx, ecx
       mov      ecx, 0x9249249
       pdep     ecx, esi, ecx
       or       edx, ecx
       cmp      edx, dword ptr [rsp+0x50]
       jae      G_M000_IG20
       mov      rsi, bword ptr [rsp+0x30]
       mov      esi, dword ptr [rsi+4*rdx]
       mov      edi, r12d
       add      rsi, rdi
       mov      rbx, gword ptr [rbx+0x18]
       cmp      byte  ptr [rbx], bl
       lea      rdx, [rsp+0x58]
       mov      rcx, rbx
       mov      r8d, 1
       call     [Tedd.Voxtree.HotOctreeChunk:GetChannelSpan(int):System.Span`1[uint]:this]
       mov      dword ptr [rsp+0x20], 1
       mov      r9d, dword ptr [rbx+0x20]
       mov      ecx, r14d
       mov      edx, r15d
       mov      r8d, r13d
       call     [Tedd.Voxtree.DenseVoxel:GetIndex(int,int,int,int,int):int]
       cmp      eax, dword ptr [rsp+0x60]
       jae      G_M000_IG20
       mov      rcx, bword ptr [rsp+0x58]
       mov      eax, eax
       mov      eax, dword ptr [rcx+4*rax]
       mov      ebx, dword ptr [rsp+0x74]
       mov      ecx, ebx
       add      rax, rcx
       sub      rax, rsi
       mov      rcx, rax
       sar      rcx, 63
       and      rcx, 7
       add      rax, rcx
       sar      rax, 3
       js       SHORT G_M000_IG09
       shr      ebx, 2
       mov      ecx, ebx

G_M000_IG07:                ;; offset=0x0253
       cmp      rax, rcx
       cmovg    rax, rcx

G_M000_IG08:                ;; offset=0x025A
       add      rsp, 120
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG09:                ;; offset=0x026B
       neg      rax
       shr      r12d, 2
       mov      ecx, r12d
       cmp      rax, rcx
       cmovg    rax, rcx
       neg      rax

G_M000_IG10:                ;; offset=0x027F
       add      rsp, 120
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG11:                ;; offset=0x0290
       mov      eax, dword ptr [rsp+0x74]
       mov      edx, r12d
       sub      rax, rdx
       mov      edx, 8
       mov      ecx, 16
       cmp      dword ptr [rbx+0x3C], 1
       cmovne   edx, ecx
       mov      ecx, edx
       cqo
       idiv     rdx:rax, rcx

G_M000_IG12:                ;; offset=0x02B2
       add      rsp, 120
       pop      rbx
       pop      rbp
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       ret

G_M000_IG13:                ;; offset=0x02C3
       mov      rcx, 0x7FFC6569F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3ED
       mov      rdx, 0x7FFC6584F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG14:                ;; offset=0x02FF
       test     r8d, r8d
       jne      G_M000_IG18
       xor      rax, rax
       mov      bword ptr [rsp+0x38], rax
       xor      r10d, r10d
       mov      dword ptr [rsp+0x54], r10d
       jmp      G_M000_IG04

G_M000_IG15:                ;; offset=0x031C
       mov      rcx, 0x7FFC6569F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3FD
       mov      rdx, 0x7FFC6584F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG16:                ;; offset=0x0358
       mov      rcx, 0x7FFC6569F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3ED
       mov      rdx, 0x7FFC6584F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG17:                ;; offset=0x0394
       test     r8d, r8d
       jne      SHORT G_M000_IG18
       xor      rax, rax
       mov      bword ptr [rsp+0x30], rax
       xor      r10d, r10d
       mov      dword ptr [rsp+0x50], r10d
       jmp      G_M000_IG06

G_M000_IG18:                ;; offset=0x03AD
       call     [System.ThrowHelper:ThrowArgumentOutOfRangeException()]
       int3

G_M000_IG19:                ;; offset=0x03B4
       mov      rcx, 0x7FFC6569F218
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      ecx, 0x3FD
       mov      rdx, 0x7FFC6584F070
       call     [CORINFO_HELP_STRCNS]
       mov      rdx, rax
       mov      rcx, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rcx, rbx
       call     CORINFO_HELP_THROW
       int3

G_M000_IG20:                ;; offset=0x03F0
       call     CORINFO_HELP_RNGCHKFAIL
       int3

; Total bytes of code 1014
