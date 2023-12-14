proc CalcProj
    
        locals 
                temp dd ?
                aspect dd ?
                tanHalfFovy dd ?
        endl
        
        radians FOV, FOV
        
        ;tanHalfFovy = tan(FOV / 2)
        fld1
        fchs
        fld [FOV]
        fscale
        fptan
        fstp [temp]
        fstp [tanHalfFovy]
        ;proj[2][3] = -1
        fstp [proj.z.w]
        
        ;aspect = width / height
        fild [ScreenWidth]
        fild [ScreenHeight]
        fdivp
        fst [aspect] 
        
        ;proj[0][0] = 1 / (aspect * tanHalfFovy)
        fmul [tanHalfFovy]
        fstp [temp]
        fld1
        fdiv [temp]
        fstp [proj.x.x]
        
        ;proj[1][1] = 1 / tanHalfFovy
        fld1
        fdiv [tanHalfFovy]
        fstp [proj.y.y]
        
        ;proj[2][2] =  - (Far + Near) / (Far - Near)
        fld   [FarPlane]
        fadd  [NearPlane]
        
        fld   [FarPlane]
        fsub  [NearPlane]
        fst   [temp]
        
        fdivp
        fchs
        fstp [proj.z.z]
        
        ;proj[3][2] = -(2 * Far * Near) / (Far - Near)
        fld1
        fld1
        fscale
        fmul [FarPlane]
        fmul [NearPlane]
        fdiv [temp]
        fchs
        
        fstp [proj.w.z]
        fstp [temp]


        ret
endp 