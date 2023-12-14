struct Vector3f
        x       dd         0
        y       dd         0
        z       dd         0
ends

struct Vector4f
        x       dd         0
        y       dd         0
        z       dd         0
        w       dd         0
ends

macro vec3 vec3f, x, y, z
{
  mov dword [vec3f + 0], x
  mov dword [vec3f + SIZEOFFLOAT], y
  mov dword [vec3f + SIZEOFFLOAT + SIZEOFFLOAT], z
}

macro v3coefsum dest, first, second, coef
{
    fld dword [first + 0]
    fld dword [first + SIZEOFFLOAT]
    fld dword [first + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fld dword [second + SIZEOFFLOAT + SIZEOFFLOAT]
    fmul dword [coef]
    faddp
    fstp dword [dest + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fld dword [second + SIZEOFFLOAT]
    fmul dword [coef]
    faddp
    fstp dword [dest + SIZEOFFLOAT]
    
    fld dword [second + 0]
    fmul dword [coef]
    faddp
    fstp dword [dest + 0]
}   

macro v3coefsub dest, first, second, coef
{
    fld dword [first + 0]
    fld dword [first + SIZEOFFLOAT]
    fld dword [first + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fld dword [second + SIZEOFFLOAT + SIZEOFFLOAT]
    fmul dword [coef]
    fsubp
    fstp dword [dest + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fld dword [second + SIZEOFFLOAT]
    fmul dword [coef]
    fsubp
    fstp dword [dest + SIZEOFFLOAT]
    
    fld dword [second + 0]
    fmul dword [coef]
    fsubp
    fstp dword [dest + 0]
} 

macro v3sum dest, first, second
{
    fld dword [first + 0]
    fld dword [first + SIZEOFFLOAT]
    fld dword [first + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fadd dword [second + SIZEOFFLOAT + SIZEOFFLOAT]
    fstp dword [dest + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fadd dword [second + SIZEOFFLOAT]
    fstp dword [dest + SIZEOFFLOAT]
    
    fadd dword [second + 0]
    fstp dword [dest + 0]
}

macro v3sub dest, first, second
{
    fld dword [first + 0]
    fld dword [first + SIZEOFFLOAT]
    fld dword [first + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fsub dword [second + SIZEOFFLOAT + SIZEOFFLOAT]
    fstp dword [dest + SIZEOFFLOAT + SIZEOFFLOAT]
    
    fsub dword [second + SIZEOFFLOAT]
    fstp dword [dest + SIZEOFFLOAT]
    
    fsub dword [second + 0]
    fstp dword [dest + 0] 
}

macro normalize vec3f
{
    fld dword [vec3f + 0]
    fld st0
    fmulp
    
    fld dword [vec3f + SIZEOFFLOAT]
    fld st0
    fmulp
    
    fld dword [vec3f + SIZEOFFLOAT + SIZEOFFLOAT]
    fld st0
    fmulp
    
    faddp
    faddp
    
    fsqrt
    
    fld dword [vec3f + 0]
    fdiv st0, st1
    fstp dword [vec3f + 0]
    
    fld dword [vec3f + SIZEOFFLOAT]
    fdiv st0, st1
    fstp dword [vec3f + SIZEOFFLOAT]
    
    fld dword [vec3f + SIZEOFFLOAT + SIZEOFFLOAT]
    fdiv st0, st1
    fstp dword [vec3f + SIZEOFFLOAT + SIZEOFFLOAT]
    fstp st0   
}  


macro cross dest, left, right
{
      ;dest.x = left.y*right.z - left.z*right.y
      fld dword [left + SIZEOFFLOAT]
      fmul dword [right + SIZEOFFLOAT + SIZEOFFLOAT]
      
      fld dword [right + SIZEOFFLOAT]
      fmul dword [left + SIZEOFFLOAT + SIZEOFFLOAT]
      
      fsubp
      fstp dword [dest + 0]
      
      ;dest.y = left.z*right.x - left.x*right.z
      fld dword [left + SIZEOFFLOAT + SIZEOFFLOAT]
      fmul dword [right + 0]
      
      fld dword [right + SIZEOFFLOAT + SIZEOFFLOAT]
      fmul dword [left + 0]
      
      fsubp
      fstp dword [dest + SIZEOFFLOAT]  
      
      ;dest.z = left.x*right.y - left.y*right.x
      fld dword [left + 0]
      fmul dword [right + SIZEOFFLOAT]
      
      fld dword [right + 0]
      fmul dword [left + SIZEOFFLOAT]
      
      fsubp
      fstp dword [dest + SIZEOFFLOAT + SIZEOFFLOAT]  
}

macro dot dest, left, right
{ 
      fld dword [left + 0]
      fld dword [right + 0]
      fmulp
      
      fld dword [left + SIZEOFFLOAT]
      fld dword [right + SIZEOFFLOAT]
      fmulp
      
      fld dword [left + SIZEOFFLOAT + SIZEOFFLOAT]
      fld dword [right + SIZEOFFLOAT + SIZEOFFLOAT]
      fmulp
      
      faddp
      faddp
      
      fstp dword [dest]
}

macro radians dest, src
{
      fld [src]
      mov [dest], 180.0
      fld [dest]
      
      fdivp
      fldPi
      fmulp
      
      fstp [dest]
}