
proc Random.Init
    locals
        SysTime SYSTEMTIME
    endl

    lea eax, [SysTime]
    invoke GetSystemTime,  eax
  
    xor eax, eax
    mov ax, [SysTime.wSecond]
    mov [Random.StartNumber], eax
    shl [Random.StartNumber], 16
    mov ax, [SysTime.wMilliseconds]
    add [Random.StartNumber], eax
    
    ret
endp

proc Random.Get, Min, Max
    
    mov eax, [Random.StartNumber]
    rol eax, 13   
    adc eax, 34865
    ror eax, 5
    adc eax, 23453
    ror eax, 6
    adc eax, 214342 
    mov [Random.StartNumber], eax
    
    mov ecx, [Max]
    sub ecx, [Min]
    inc ecx
    
    xor edx, edx
    
    div ecx
    
    add edx, [Min]
    
    mov eax, edx
    ret
endp