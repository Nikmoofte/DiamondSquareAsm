format PE GUI 4.0
entry Start

include 'win32ax.inc'
include 'GLext.INC'
include 'Vec.inc'
 
struct mat4
        x       Vector4f 
        y       Vector4f       
        z       Vector4f        
        w       Vector4f        
ends

struct mat3
        x       Vector3f
        y       Vector3f
        z       Vector3f
ends


COLOR_DEPTH     =       24
PFD_FLAGS       =       PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW
VERTEXCOUNT     =       4
COORCOUNT       =       3 
MAPSIZE         =       6
SIZEOFINT       =       4
SIZEOFFLOAT     =       4

NORMAL_SPEED    =       dword 0.01
FAST_SPEED      =       dword 0.1


section '.text' code readable executable  

include 'GLext.asm'
include 'File.asm'
include 'Rand.asm'
      

Start:
  stdcall Random.Init
  

  call [LoadIcon], 0 , IDI_APPLICATION
  mov [wc.hIcon], eax
  
  invoke LoadCursor, 0, IDC_ARROW
  mov    [wc.hCursor], eax
  
  invoke GetModuleHandle, 0   
  mov    [wc.hInstance], eax
    
  invoke RegisterClass, wc                            
  test eax, eax
  jz error
  
  invoke GetSystemMetrics, SM_CXSCREEN
  mov [ScreenWidth], eax
  invoke GetSystemMetrics, SM_CYSCREEN
  mov [ScreenHeight], eax

  invoke CreateWindowEx , WS_EX_OVERLAPPEDWINDOW, _class, _title, WS_OVERLAPPEDWINDOW or WS_VISIBLE or WS_MAXIMIZE,\
                         0, 0, ScreenWidth, ScreenHeight, NULL, NULL, [wc.hInstance], NULL
  
                                                                                          
  test eax, eax
  jz error
          
  mov [MainHandle], eax
  invoke ShowCursor, 0 
  
  invoke  GetDC, [MainHandle]
  mov     [hdc], eax
  
  invoke GetProcessHeap
  mov [HeapHandle], eax

  invoke  ChoosePixelFormat, [hdc], pfd
  invoke  SetPixelFormat, [hdc], eax, pfd

  invoke  wglCreateContext, [hdc]
  invoke  wglMakeCurrent, [hdc], eax  
  
  stdcall Glext.LoadFunctions
  
  ;RealMapSize = 2^MapSize + 1
  mov eax, 2
  shl eax, MAPSIZE
  add eax, 1
  
  
  mov [RealMapSize], eax
  mov ebx, SIZEOFINT
  shl ebx, 1
  add ebx, squareIndicies                                                                                                                        
  mov [ebx], eax
  
  add ebx, SIZEOFINT
  mov [ebx], eax
  
  add ebx, SIZEOFINT
  add ebx, SIZEOFINT
  mov [ebx], eax
  inc  dword [ebx]
  
  
  invoke  glGenVertexArrays, 1, waterVAO
  invoke  glGenBuffers, 1, waterVBO
  invoke  glGenBuffers, 1, waterEBO
  
  invoke  glBindVertexArray, [waterVAO]      
  invoke  glBindBuffer, GL_ARRAY_BUFFER, [waterVBO]
  
  fild [RealMapSize]
  ;0000
  ;0110
  ;1100
  fst [square.y.y]
  fst [square.y.z]
  fst [square.z.x]
  fstp [square.z.y]
  
  invoke  glBufferData, GL_ARRAY_BUFFER, SIZEOFFLOAT * 12, square, GL_STATIC_DRAW
  invoke  glEnableVertexAttribArray, 0 
  invoke  glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE, SIZEOFFLOAT * 3, 0
  
  
  
  invoke  glGenVertexArrays, 1, VAO
  invoke  glGenBuffers, 1, VBO
  invoke  glGenBuffers, 1, EBO
  
  invoke  glBindVertexArray, [VAO]      
  invoke  glBindBuffer, GL_ARRAY_BUFFER, [VBO]
  
  stdcall GenerateMap, [RealMapSize]
  
  ;invoke  glBufferData, GL_ARRAY_BUFFER, SIZEOFFLOAT * 9, triangle, GL_STATIC_DRAW
  ;invoke  glEnableVertexAttribArray, 0 
  ;invoke  glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE, SIZEOFFLOAT * 3, 0
  
  invoke  glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [EBO]

  stdcall FillIndexArr
  
  stdcall Glext.InitShaders, MainVertShaderPath, MainFragShaderPath
  mov [MainProgram], eax
  invoke glUseProgram, eax
  
  stdcall Glext.InitShaders, WaterVertShaderPath, WaterFragShaderPath
  mov [WaterProgram], eax
  
  stdcall CalcProj
  
  invoke glGetUniformLocation, [MainProgram], 'proj'
  invoke glUniformMatrix4fv, eax, 1, GL_FALSE, proj
  
  invoke glUseProgram, [WaterProgram]
  
  invoke  glEnable, GL_DEPTH_TEST
  invoke  glEnable, GL_BLEND
  
  invoke glGetUniformLocation, [WaterProgram], 'proj'
  invoke glUniformMatrix4fv, eax, 1, GL_FALSE, proj
  
  fld1
  fchs
  fild [RealMapSize]
  fscale
  fst [CamPos.x]
  fstp [CamPos.z]
  fstp st0
  mov [CamPos.y], 70.0
  
  ;vec3 CamPos, 10.0, 50.0, 10.0
  
  vec3 CamFront, 0.0, -1.0 , 0.0
  vec3 CamUp, 0.0, 1.0, 0.0
  
  cross CamRight, CamUp, CamFront
  
  mov  [view.x.x], 1.0
  mov  [view.y.y], 1.0
  mov  [view.z.z], 1.0
  mov  [view.w.w], 1.0
  
  
                                          
msg_loop:
  invoke GetMessage, msg, NULL, 0, 0
  cmp eax, 1
  jb end_loop
  jne msg_loop
  invoke TranslateMessage, msg
  invoke DispatchMessage, msg
  jmp msg_loop

error:
  invoke MessageBox, NULL, _error, NULL, MB_ICONERROR + MB_OK

end_loop:
  invoke ExitProcess, [msg.wParam]
  



;===============================================================================
;PROCS
include 'Projection.asm'
include 'View.asm'
include 'Generate.asm'
include 'InputHandle.asm'
  
 
;===============================================================================
;WIN PROC 
  
macro JumpIf value, label
{
        cmp     eax, value
        je      label
}
proc WindowProc uses ebx esi edi, hwnd, msg, wparam, lparam
        mov     eax, [msg]      

        JumpIf  WM_PAINT,       .Paint
        JumpIf  WM_DESTROY,     .Destroy
        JumpIf  WM_KEYDOWN,     .KeyDown

        
        invoke  DefWindowProc, [hwnd], [msg], [wparam], [lparam]
        jmp     .Return
               
.Paint:
                
        stdcall Draw
        jmp     .ReturnZero
.KeyDown:

        cmp     [wparam], 82
        jne     @F
        stdcall GenerateMap, [RealMapSize]
@@:
        cmp     [wparam], VK_ESCAPE
        jne     .ReturnZero
        
        

.Destroy:
        invoke  ExitProcess, ebx

.ReturnZero:
        xor     eax, eax
        
.Return:
        ret
endp  
;===============================================================================
;DRAW
proc Draw

        locals
                temp dd ?
        endl


        invoke  glClearColor, 0.1, 0.1, 0.1, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
 
        
        stdcall KeyboardHandle        
        stdcall MouseHandle
        

        stdcall CalcView
        
        ;Water draw
        invoke  glDisable, GL_DEPTH_TEST
        invoke  glUseProgram, [WaterProgram]
        invoke  glBindVertexArray, [waterVAO]  
        
        invoke  glGetUniformLocation, [WaterProgram], 'view'
        invoke  glUniformMatrix4fv, eax, 1, GL_FALSE, view
        
        invoke  glGetUniformLocation, [WaterProgram], 'waterLevel'
        invoke  glUniform1f, eax, [waterLevel]

        invoke  glDrawArrays, GL_QUADS, 0, 12
        
        invoke  glEnable, GL_DEPTH_TEST
        ;Main draw
        invoke  glUseProgram, [MainProgram]
        
        invoke  glBindVertexArray, [VAO]  
        invoke  glGetUniformLocation, [MainProgram], 'view'
        invoke  glUniformMatrix4fv, eax, 1, GL_FALSE, view
        
        invoke  glGetUniformLocation, [MainProgram], 'waterLevel'
        invoke  glUniform1f, eax, [waterLevel]
        
        invoke  glGetUniformLocation, [MainProgram], 'mountainsHeight'
        invoke  glUniform1f, eax, [mountainsHeight]
        
        invoke  glDrawElements, GL_TRIANGLES, [IndiciesCount], GL_UNSIGNED_INT, 0
        ;invoke  glGetError
        ;invoke  glDrawArrays, GL_TRIANGLES, 0, 9
        
        invoke  SwapBuffers, [hdc]

        ret
endp 

section '.data' data readable writeable

  _class TCHAR 'Render window', 0
  _title TCHAR 'There is nothing to see...', 0
  _error TCHAR 'Startup failed.', 0
  
  ScreenWidth dd 0
  ScreenHeight dd 0
  
  EBO dd ?
  VBO dd ?
  VAO dd ?
  
  waterEBO dd ?
  waterVBO dd ?
  waterVAO dd ?
  
  MainProgram dd ?
  MainFragShaderPath db 'shaders/fragment.fs', 0
  MainVertShaderPath db 'shaders/vertex.vs', 0
  
  WaterProgram dd ?
  WaterFragShaderPath db 'shaders/Wfragment.fs', 0
  WaterVertShaderPath db 'shaders/Wvertex.vs', 0
  
  
  program dd ?


  MainHandle dd ?
  HeapHandle dd ?

  RealMapSize dd ?
  NumOfIndicies dd ?
  temp dd ?


  wc WNDCLASS CS_OWNDC, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class
  
  pfd             PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR,\ 
                                          1,\
                                          PFD_FLAGS,\
                                          PFD_TYPE_RGBA,\
                                          32,\
                                          0, 0, 0, 0, 0, 0,\ 
                                          0, 0,\
                                          0,\
                                          0, 0, 0, 0,\
                                          24,\
                                          8,\
                                          0,\
                                          PFD_MAIN_PLANE,\
                                          0,\
                                          0, 0
  hdc             dd      ?

  msg MSG
  
  SQUAREINDICIESCOUNT = 6
                 
  squareIndicies dd 0, 1, ?,\
                    ?, 1, ?
                                      
  IndiciesCount dd ?
  
  square mat4
   
                 
  view mat4           
  proj mat4  
  transl mat4 
  
  CamPos Vector3f
  CamFront Vector3f
  CamRight Vector3f
  CamUp Vector3f
  
  
  bFirst db 1
  LastX dd ?
  LastY dd ?
  Yaw dd 0.0
  Pitch dd 0.0
  
  NearPlane dd 0.001
  FarPlane dd  10000.0
  FOV dd 90.0
  
  waterLevel dd -10.0
  mountainsHeight dd 10.0
  
  Random.StartNumber dd ?
                 


section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
          user32, 'USER32.DLL',\
          opengl32, 'OPENGL32.DLL',\
          gdi32, 'GDI32.DLL'
          
  import gdi32,\
       ChoosePixelFormat,'ChoosePixelFormat',\
       SetPixelFormat, 'SetPixelFormat',\
       SwapBuffers, 'SwapBuffers'


  include 'api/kernel32.inc'
  include 'api/user32.inc'
  include 'api/opengl.inc'


            
            
            
            
  
    

  
