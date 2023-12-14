;GENERATEMAP

proc GetRandHeight, length
    locals
        accuracy dd 1000000
        rougness dd 0.2
        temp dd ?
    endl
    fild [accuracy]
    fchs
    fistp [temp]
    stdcall Random.Get, [temp], [accuracy]
    mov [temp], eax
    
    fild [temp]
    fild [accuracy]
    fdivp
    
    fild [length] 
    fld [rougness]
    fmulp
    fmulp
    fstp [temp]
    
    mov eax, [temp]
    
    ret  
endp

;MyCall Y then X to fpu stack register
proc SetDiamondVertexies uses edi, pMap, RealMapSize, SideLength
    
    locals
          temp dd 0
          fEdge db 0
    endl
    
    stdcall GetVertIndx, [pMap], [RealMapSize]
    mov edi, eax
    add edi, SIZEOFFLOAT
    
    fiadd [SideLength]
    stdcall GetVertIndx, [pMap], [RealMapSize]
    .if eax = 0
        mov [fEdge], 1
    .else
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
    .endif  
    
    fisub [SideLength]
    fisub [SideLength]
    stdcall GetVertIndx, [pMap], [RealMapSize]
    .if eax = 0
        mov [fEdge], 1
    .else
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
    .endif 
    
    fiadd [SideLength]
    fxch st1
    fiadd [SideLength]
    fxch st1
    stdcall GetVertIndx, [pMap], [RealMapSize]
    .if eax = 0
        mov [fEdge], 1
    .else
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
    .endif 
    
    fxch st1
    fisub [SideLength]
    fisub [SideLength]
    fxch st1
    stdcall GetVertIndx, [pMap], [RealMapSize]
    .if eax = 0
        mov [fEdge], 1
    .else
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
    .endif 
    
    
    fxch st1
    fiadd [SideLength]
    fxch st1
    
    fld [temp]
    
    .if [fEdge] = 0
        mov [temp], 4
    .else
        mov [temp], 3
    .endif
     
    fidiv [temp]         
    stdcall GetRandHeight, [SideLength]
    mov [temp], eax
    fadd [temp]
        
    fstp dword [edi] 
    
    ret
endp


  



proc GenerateMap,\
      RealMapSize
    locals
        temp dd ?
        SideLength dd ?
        SquareCount dd ?
        X dd ?
        Y dd ?
        pMap dd ?
        cw dw ?
    endl 
        
    fild [RealMapSize]
    fimul [RealMapSize]
    mov [temp], COORCOUNT
    fimul [temp]
    
    fist [NumOfIndicies]
    mov [temp], SIZEOFFLOAT 
    fimul [temp]
    fistp [temp]      
    
    invoke HeapAlloc, [HeapHandle], 8, [temp]
    mov [pMap], eax
      
    stdcall MapInit, eax, [RealMapSize] 

    ;Map[0][0] = Rand
    stdcall GetRandHeight, [RealMapSize]
    mov ebx, eax

    mov [temp], 0.0  
    
    fld [temp]
    fld st0
    stdcall GetVertIndx, [pMap], [RealMapSize] 
    mov dword [eax + SIZEOFFLOAT], ebx
    
    ;Map[edgeLength - 1][0] = Rand
    stdcall GetRandHeight, [RealMapSize]
    mov ebx, eax
    
    fstp st0
    mov edx, [RealMapSize]
    mov [SideLength], edx
    dec edx
    mov [temp], edx
    fild [temp]
    
    stdcall GetVertIndx, [pMap], [RealMapSize] 
    mov dword [eax + SIZEOFFLOAT], ebx
    
    ;Map[0][edgeLength - 1] = Rand
    stdcall GetRandHeight, [RealMapSize]
    mov ebx, eax
    
    fxch st1
    
    stdcall GetVertIndx, [pMap], [RealMapSize] 
    mov dword [eax + SIZEOFFLOAT], ebx
    
    ;Map[edgeLength - 1][edgeLength - 1] = Rand
    stdcall GetRandHeight, [RealMapSize]
    mov ebx, eax
    
    fstp st0
    fld st0
    
    stdcall GetVertIndx, [pMap], [RealMapSize] 
    mov dword [eax + SIZEOFFLOAT], ebx
    
    fstp st0
    fstp st0
;===============================================================================
;GENERATION 
    fstcw [cw]
    or [cw], 0000'1000'0000'0000b
    fldcw [cw]
    

    mov [SquareCount], 1
    
    .while [SideLength] > 1
      fld1
      fchs
      fild [SideLength] 
      fadd st0, st1
      fscale

      fistp [SideLength]
      fstp st0
      
      and [X], 0
      and [Y], 0

      xor ebx, ebx
      .while ebx < [SquareCount]
        and [temp], 0
        
        fild [Y]
        fiadd [SideLength]
      
        fild [X]
        fiadd [SideLength]
        
                   
;===============================================================================
;SQUARE-STEP
        ;Центр 
        stdcall GetVertIndx, [pMap], [RealMapSize]
        mov edi, eax
        add edi, SIZEOFFLOAT
        fstp st0
        fstp st0
        
        ;Левый верхний
        
        fild [Y]
        fild [X] 
        stdcall GetVertIndx, [pMap], [RealMapSize]
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
        
        ;Левый нижний
        fxch st1
        fiadd [SideLength]
        fiadd [SideLength]
        fxch st1
        stdcall GetVertIndx, [pMap], [RealMapSize]
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
        
        ;Правый нижний
        fiadd [SideLength]
        fiadd [SideLength]
        stdcall GetVertIndx, [pMap], [RealMapSize]
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]
        fstp [temp]
        
        ;Правый верхний
        fxch st1
        fisub [SideLength]
        fisub [SideLength]
        fxch st1
        stdcall GetVertIndx, [pMap], [RealMapSize]
        fld dword [eax + SIZEOFFLOAT]
        fadd [temp]


        mov [temp], 4
        fidiv [temp]         
        stdcall GetRandHeight, [SideLength]
        mov [temp], eax
        fadd [temp]
        
        fstp dword [edi] 
        
        
;===============================================================================
;Diamond-Step
        
        fisub [SideLength]
        stdcall SetDiamondVertexies, [pMap], [RealMapSize], [SideLength]
        
        fisub [SideLength]
        fxch st1
        fiadd [SideLength]
        fxch st1
        stdcall SetDiamondVertexies, [pMap], [RealMapSize], [SideLength]
        
        fiadd [SideLength]
        fxch st1
        fiadd [SideLength]
        fxch st1
        stdcall SetDiamondVertexies, [pMap], [RealMapSize], [SideLength]

        fiadd [SideLength]
        fxch st1
        fisub [SideLength]
        fxch st1
        stdcall SetDiamondVertexies, [pMap], [RealMapSize], [SideLength]
         
        fxch st1
        fisub [SideLength]
        fxch st1
              
        fistp [X]                
        fistp [Y]
        mov eax, [X]
        inc eax
        .if eax = [RealMapSize]
            and [X], 0
            fild [Y]
            fiadd [SideLength] 
            fiadd [SideLength] 
            fistp [Y]
        .endif
        
        inc ebx
      .endw
    
    
      fild [SquareCount]
      mov [SquareCount], 4
      fimul [SquareCount]
      fistp [SquareCount]
      
      
    .endw
    
      

    stdcall PostProcessing, [pMap], [RealMapSize] 

    
        
    mov [temp], SIZEOFFLOAT
    fild [NumOfIndicies]
    fimul [temp]
    fistp [temp]
    
    invoke  glBufferData, GL_ARRAY_BUFFER, [temp], [pMap], GL_STATIC_DRAW
    invoke  glEnableVertexAttribArray, 0 
    invoke  glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE, SIZEOFFLOAT * 3, 0
    
    invoke  HeapFree, [HeapHandle], 0, [pMap]
    
    ret   
endp


proc PostProcessing uses ebx, pMap, RealMapSize

    locals
        X dd ?
        Y dd ?
        SmoothHeight dd ?
        counter dd 0
    endl
    
    xor ecx, ecx
    .while ecx < [RealMapSize]
         xor edx, edx
         .while edx < [RealMapSize]
               and [SmoothHeight], 0
               and [counter], 0
               mov [X], edx
               dec [X]
               mov [Y], ecx
               dec [Y]
               
               mov ebx, ecx
               inc ebx
               inc ebx
cycle: 
               cmp [Y], ebx
               jge @F
                    fild [Y]
                    fild [X]
                    stdcall GetVertIndx, [pMap], [RealMapSize]
                    .if eax <> 0    
                          fld [SmoothHeight]
                          fadd dword [eax + SIZEOFFLOAT]
                          fstp [SmoothHeight]
                          inc  [counter]        
                    .endif
                    inc [X]
                    inc edx
                    .if [X] > edx
                          inc [Y]
                          mov [X], edx
                          sub [X], 2
                    .endif
                    dec edx
                    
                    .if [X] = edx
                          .if [Y] = ecx
                                inc [X]
                          .endif
                    .endif
               
               fstp st0
               fstp st0
               jmp cycle               
@@:
               
               fld [SmoothHeight]
               fidiv [counter]
               fstp [SmoothHeight]
               

               mov [X], edx
               mov [Y], ecx
               fild [Y]
               fild [X]
               stdcall GetVertIndx, [pMap], [RealMapSize]
               fld [SmoothHeight]
               fstp dword [eax + SIZEOFFLOAT]
               
               fstp st0
               fstp st0
               
               inc edx
         .endw  
         inc ecx
    .endw

    ret
endp 


;Absolutly not std call), push Y then X in fpu rexisters 
proc GetVertIndx,\
       pMap, RealMapSize
      
      locals
          CoorCount dd ?
          sizeOfFloat dd ?
          temp dd ?
      endl
      fist [temp]
      fxch st1
      fist [CoorCount]
      fxch st1
      mov eax, [RealMapSize]  
      .if [temp] < eax
        .if [CoorCount] < eax
          .if [temp] >= 0
            .if [CoorCount] >= 0
              mov [CoorCount], COORCOUNT
              mov [sizeOfFloat], SIZEOFFLOAT
              ;lineSize = RealMapSize * COORDCOUNT 
              fild [RealMapSize]
              fimul [CoorCount]
              fimul [sizeOfFloat]
              ;Indx = pMap + COORCOUNT * X + Y * lineSize
              fld st2
              fistp [temp]
              fimul [temp]
      
              fld st1
              fimul [CoorCount]
              fimul [sizeOfFloat]
      
              fistp [temp]
              fiadd [temp]
      
              fiadd [pMap]
      
              fistp [temp]
            
              mov eax, [temp]
          
              ret
            .endif
          .endif
        .endif
      .endif
      mov eax, 0
      ret  
endp


;FILL INDX ARR  
proc FillIndexArr uses ebx, esi, edi
  locals
      pBuffer dd ?
      squareIndCount dd SQUAREINDICIESCOUNT
      numOfSquaresINDX dd ?
       
      sizeOfInt dd SIZEOFINT
      temp dd ?
      TempHeapHandle dd ?
  endl
  
  dec [RealMapSize]
  
  ; numOfSquaresINDX = (RealMapSize - 1) * (RealMapSize - 1) * 6
  fild [RealMapSize]
  fimul [RealMapSize]
  fimul [squareIndCount]
  
  fist [numOfSquaresINDX]
  ;Bytes = numOfSquares * SIZEOFINT
  fimul [sizeOfInt]
  mov [temp], 1
  fiadd [temp]   
  fistp [temp]
  
  invoke HeapCreate, NULL, [temp], [temp]
  mov [TempHeapHandle], eax
  
  fild [numOfSquaresINDX]
  fimul [sizeOfInt]
  fistp [temp]
  
  invoke HeapAlloc, [TempHeapHandle], 8, [temp]
  mov [pBuffer], eax
  


  xor ecx, ecx
  .while ecx < [RealMapSize]
        xor edx, edx
        .while edx < [RealMapSize]
            xor ebx, ebx
            .while ebx < SQUAREINDICIESCOUNT
                ;indx = (b + d * squareIndCount + c * (RealMapSize - 1) * squareIndCount) * SizeOfInt 
                mov [temp], edx
                fild [temp]
                fimul [squareIndCount]
                
                mov [temp], ecx
                fild [temp]
                fimul [RealMapSize]
                fimul [squareIndCount]
                
                faddp 
                
                mov [temp], ebx
                fiadd [temp]
                
                fimul [sizeOfInt]
                
                ;PBuffer + indx = squareIndicies[b * sizeOfInt] + d + c * RealMapSize
                fiadd [pBuffer]
                
                fistp [temp]
                mov eax, [temp]
                
                mov [temp], ecx
                fild [temp]
                
                inc [RealMapSize]
                fimul [RealMapSize]
                dec [RealMapSize]
                
                mov [temp], edx
                fiadd [temp]
                
                ;squareIndicies[b * sizeOfInt] 
                mov [temp], ebx
                fild [temp]
                fimul [sizeOfInt]
                
                push ebx
                push edx
                
                  fistp [temp]
                  mov ebx, [temp]
                  mov edx, [squareIndicies + ebx]
                  mov [temp], edx
                  fiadd [temp]
                  
                pop edx
                  
                  fistp [temp]
                
                  mov ebx, [temp]
                
                  mov [eax], ebx
                 
                pop ebx
            
                inc ebx
            .endw
            
            inc edx
        .endw
        
        inc ecx
    .endw
    
    fild [numOfSquaresINDX]
    fist [IndiciesCount]

    fimul [sizeOfInt]
    fistp [temp]
    
    invoke glBufferData, GL_ELEMENT_ARRAY_BUFFER, [temp], [pBuffer], GL_STATIC_DRAW
  
    invoke  HeapFree, [TempHeapHandle], 0, [pBuffer]   
    
    invoke  HeapDestroy, [TempHeapHandle]
    
    inc [RealMapSize]
    ret
endp

proc MapInit uses ebx,\
       pMap, RealMapSize
      
      locals
          one dd 1.0
          X dd ?
          Y dd ?
      endl   
      
      fldz
      xor ecx, ecx
      .while ecx < [RealMapSize] 
          fst [Y]
          fldz
          xor edx, edx
          .while edx < [RealMapSize]
              fst [X]
              stdcall GetVertIndx, [pMap], [RealMapSize] 
              
              mov ebx, [X]
              mov dword [eax], ebx
              
              mov dword [eax + SIZEOFFLOAT], 0.0
              
              mov ebx, [Y]
              mov dword [eax + SIZEOFFLOAT + SIZEOFFLOAT], ebx
               
              fadd [one]
              inc edx
          .endw
          
          fstp [Y]
          fadd [one]
          inc ecx
      .endw    
      fstp [X]
      
      ret
endp
