WATER_LEVEL_CHANGE_SPEED = dword 0.01
MOUNTAINS_LEVEL_CHANGE_SPEED = dword 0.01
proc KeyboardHandle
        
        locals
              ActualSpeed dd ?
        endl

        mov [ActualSpeed], NORMAL_SPEED
        invoke  GetKeyState, VK_SHIFT
        test eax, 0x80
        jz @F
        mov [ActualSpeed], FAST_SPEED       
@@: 

        invoke  GetKeyState, 87 ;w
        test eax, 0x80
        jz @F
        v3coefsum CamPos, CamPos, CamFront, ActualSpeed       
@@: 
        
        invoke  GetKeyState, 83 ;s
        test eax, 0x80
        jz @F
        v3coefsub CamPos, CamPos, CamFront, ActualSpeed       
@@: 

        invoke  GetKeyState, 65 ;a
        test eax, 0x80
        jz @F
        cross CamRight, CamUp, CamFront
        v3coefsum CamPos, CamPos, CamRight, ActualSpeed       
@@:
        
        invoke  GetKeyState, 68 ;d
        test eax, 0x80
        jz @F
        cross CamRight, CamUp, CamFront
        v3coefsub CamPos, CamPos, CamRight, ActualSpeed         
@@:

        invoke  GetKeyState, VK_SPACE
        test eax, 0x80
        jz @F
        v3coefsum CamPos, CamPos, CamUp, ActualSpeed         
@@:

        invoke  GetKeyState, VK_CONTROL
        test eax, 0x80
        jz @F
        v3coefsub CamPos, CamPos, CamUp, ActualSpeed         
@@:

        invoke  GetKeyState, VK_UP
        test eax, 0x80
        jz @F
        fld [waterLevel]         
        mov [waterLevel], WATER_LEVEL_CHANGE_SPEED
        fadd [waterLevel]
        fstp [waterLevel]
@@:

        invoke  GetKeyState, VK_DOWN
        test eax, 0x80
        jz @F
        fld [waterLevel]         
        mov [waterLevel], WATER_LEVEL_CHANGE_SPEED
        fsub [waterLevel]
        fstp [waterLevel]
@@:

        invoke  GetKeyState, VK_RIGHT
        test eax, 0x80
        jz @F
        fld [mountainsHeight]         
        mov [mountainsHeight], MOUNTAINS_LEVEL_CHANGE_SPEED
        fadd [mountainsHeight]
        fstp [mountainsHeight]
@@:

        invoke  GetKeyState, VK_LEFT
        test eax, 0x80
        jz @F
        fld [mountainsHeight]         
        mov [mountainsHeight], MOUNTAINS_LEVEL_CHANGE_SPEED
        fsub [mountainsHeight]
        fstp [mountainsHeight]
@@:
        ret
endp

proc MouseHandle

        locals
              temp dd ?
              Sensivity dd 0.005
              CursorPos POINT 
        endl 
        
        lea eax, [CursorPos]
        invoke GetCursorPos, eax

        cmp [bFirst], 1
        jne @F
.ResetPos:
        ;LastX = ScreeWidth / 2        
        fld1
        fchs
        fild [ScreenWidth]
        fscale
        fistp [LastX]
        fstp st0
        
        mov eax, [CursorPos.y]
        mov [LastY], eax
        
        invoke SetCursorPos, [LastX], [LastY]
        mov [bFirst], 0
        jmp .toComput
@@:
        mov eax, [ScreenWidth]
        sub eax, 100
        cmp [CursorPos.x], eax
        ja  .ResetPos
        
        cmp [CursorPos.x], 100
        jb  .ResetPos
        
.toComput:
        
        fild [CursorPos.x]
        fisub [LastX]
          
        fild [LastY]
        fisub [CursorPos.y]
        
        mov eax, [CursorPos.x]
        mov [LastX], eax
        
        mov eax, [CursorPos.y]
        mov [LastY], eax
        
        ;Pitch = (pi / 4 < newPitch ? pi / 4 : newPitch)  (newPitch = Pitch + deltaY * Sensivity)
        fmul [Sensivity]
        fadd [Pitch]
        
        mov [temp], 2.0
        fldpi
        fdiv [temp]
        
        fcom st1
        fstsw ax
        sahf
        fcmovNB st1  
        
        fstp [Pitch]
        fstp st0
        
        ;Pitch = (-pi / 4 > newPitch ? -pi / 4 : newPitch) 
        
        fld [Pitch]
        fldpi
        fdiv [temp]
        fchs
        
        fcom st1
        fstsw ax
        sahf
        fcmovB st1
        
        fstp [Pitch]
        fstp st0
        
        ;Yaw = (2*pi > newYaw ? newYaw - 2*pi : newYaw) 
        fmul [Sensivity]
        fadd [Yaw]
        
        fldz
        
        mov [temp], 2
        fldpi
        fmul [temp]
        
        fcom st2
        fstsw ax
        sahf
        fcmovB st1
        
        fsubp st2, st0
        fstp st0
        
        ;Yaw = (-2*pi < newYaw ? newYaw + 2*pi : newYaw) 
        fldz
        
        fldpi
        fmul [temp]
        fchs
        
        fcom st2
        fstsw ax
        sahf
        fcmovNB st1
        
        fsubp st2, st0
        fstp st0
        
        fstp [Yaw]
        
        
        
        ;direction.x = cos(fYaw) * cos(fPitch);
        ;direction.y = sin(fPitch);
        ;direction.z = sin(fYaw) * cos(fPitch);


        fld [Yaw]
        fsincos
        fld [Pitch]
        fsincos
        
        fxch st2
        fmul st0, st2
        
        fstp [CamFront.x]
        fstp [CamFront.y]
        fmulp
        fstp [CamFront.z]
        
        normalize CamFront
        

        ret
endp