proc Glext.LoadFunctions uses esi edi

        mov     esi, extensionAddresses
        mov     edi, extensionNames

.Scan:
        movzx   eax, byte[edi]
        or      eax, 0
        je      .Return

        invoke  wglGetProcAddress, edi
        mov     [esi], eax
        add     esi, 4

        mov     al, 0
        mov     ecx, 0xFFFFFFFF
        repne   scasb
        jmp     .Scan

.Return:
        ret
endp

proc Glext.InitShaders,\
      VertexShaderPath, FragmentShaderPath
      
        locals
          program dd ?
          linked dd ?
          buffer dd ?
        endl
        
        invoke  glCreateProgram
        mov     [program], eax 
        
        stdcall Glext.LoadShader, [FragmentShaderPath], GL_FRAGMENT_SHADER, [program]
        stdcall Glext.LoadShader, [VertexShaderPath], GL_VERTEX_SHADER, [program]
        
        invoke  glLinkProgram, [program]
        
        lea     eax, [linked]
        invoke  glGetProgramiv, [program], GL_LINK_STATUS, eax
        
        
        or     [linked], 0
        je      @F
        
        jmp .Return
        @@:
        invoke  HeapAlloc, [HeapHandle], 8, 512
        mov     [buffer], eax
        

        invoke  glGetProgramInfoLog, [program], 512, NULL, dword [eax]
        invoke  glGetError
        invoke  MessageBox, NULL, dword[eax], 'ERROR', MB_OK or MB_ICONERROR 
        
        invoke  HeapFree, [HeapHandle], 0, [buffer]
.Return:
        mov eax, [program] 
        ret
endp

proc Glext.LoadShader,\
     fileName, shaderType, program

        locals
                buffer          dd      ?
                shader          dd      ?
                compiled        dd      ?
        endl

        stdcall File.LoadContent, [fileName]
        mov     [buffer], eax

        invoke  glCreateShader, [shaderType]
        mov     [shader], eax
        lea     eax, [buffer]
        invoke  glShaderSource, [shader], 1, eax, 0
        invoke  glCompileShader, [shader]

        invoke  HeapFree, [HeapHandle], 0, [buffer]

        lea     eax, [compiled]

        invoke  glGetShaderiv, [shader], GL_COMPILE_STATUS, eax
        or      [compiled], 0
        je      @F
        

        invoke  glAttachShader, [program], [shader]
        invoke  glGetError
        invoke  glDeleteShader, [shader]
        jmp     .Return

@@:
        mov     eax, 0
        invoke  HeapAlloc, [HeapHandle], 8, 512
        mov     [buffer], eax
        

        invoke  glGetShaderInfoLog, [shader], 512, NULL, dword [eax]
        invoke  glGetError
        invoke  MessageBox, NULL, dword[eax], 'ERROR', MB_OK or MB_ICONERROR         
        
        invoke  HeapFree, [HeapHandle], 0, [buffer]

.Return:
        ret
endp
