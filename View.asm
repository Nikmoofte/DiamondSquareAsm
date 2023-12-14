proc CalcView
    
    locals
        f Vector3f
        s Vector3f
        u Vector3f 
        center Vector3f
    endl
    
    v3sum center, CamPos, CamFront
    
    v3sub f, center, CamPos
    normalize f
    fstp [temp]
    
    cross s, f, CamUp
    normalize s
    fstp [temp]
    
    cross u, s, f
    
    fld [s.x]
    fld [s.y]
    fld [s.z]
    
    fstp [view.z.x] 
    fstp [view.y.x] 
    fstp [view.x.x] 
    
    fld [u.x]
    fld [u.y]
    fld [u.z]
                  
    fstp [view.z.y] 
    fstp [view.y.y] 
    fstp [view.x.y]
    
    fld [f.x]
    fchs
    fld [f.y]
    fchs
    fld [f.z]
    fchs
    
    fstp [view.z.z]
    fstp [view.y.z]
    fstp [view.x.z]
    
    dot temp, s, CamPos
    fld [temp]
    fchs
    fstp [view.w.x]
    
    dot temp, u, CamPos
    fld [temp]
    fchs
    fstp [view.w.y]
    
    dot temp, f, CamPos
    fld [temp]
    fstp [view.w.z]
    
    ret
endp        