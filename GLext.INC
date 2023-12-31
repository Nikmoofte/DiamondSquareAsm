extensionAddresses:
        glGetProgramInfoLog    dd       ?
        glGetShaderInfoLog     dd       ?
        glGenBuffers           dd       ?
        glGenVertexArrays      dd       ?
        glBindVertexArray      dd       ?
        glBindBuffer           dd       ?
        glBufferData           dd       ?
        glEnableVertexAttribArray dd    ?
        glVertexAttribPointer   dd      ?  ;MYend
        glUseProgram            dd      ?
        glDetachShader          dd      ?
        glDeleteShader          dd      ?
        glDeleteProgram         dd      ?
        glCreateShader          dd      ?
        glShaderSource          dd      ?
        glCompileShader         dd      ?
        glGetShaderiv           dd      ?
        glCreateProgram         dd      ?
        glAttachShader          dd      ?
        glLinkProgram           dd      ?
        glGetProgramiv          dd      ?
        glGetUniformLocation    dd      ?
        glUniform1f             dd      ?
        glUniform2f             dd      ?
        glUniformMatrix4fv      dd      ?

extensionNames:
        db      'glGetProgramInfoLog', 0 
        db      'glGetShaderInfoLog', 0
        db      'glGenBuffers', 0
        db      'glGenVertexArrays', 0      
        db      'glBindVertexArray', 0      
        db      'glBindBuffer', 0           
        db      'glBufferData', 0    
        db      'glEnableVertexAttribArray', 0 
        db      'glVertexAttribPointer', 0  
        db      "glUseProgram", 0
        db      "glDetachShader", 0
        db      "glDeleteShader", 0
        db      "glDeleteProgram", 0
        db      "glCreateShader", 0
        db      "glShaderSource", 0
        db      "glCompileShader", 0
        db      "glGetShaderiv", 0
        db      "glCreateProgram", 0
        db      "glAttachShader", 0
        db      "glLinkProgram", 0
        db      "glGetProgramiv", 0
        db      "glGetUniformLocation", 0
        db      "glUniform1f", 0
        db      "glUniform2f", 0
        db      'glUniformMatrix4fv', 0
        db      0
        

define GL_FRAGMENT_SHADER                0x8B30
define GL_VERTEX_SHADER                  0x8B31
define GL_COMPILE_STATUS                 0x8B81
define GL_LINK_STATUS                    0x8B82
define GL_ARRAY_BUFFER                   0x8892
define GL_STATIC_DRAW                    0x88E4
define GL_ELEMENT_ARRAY_BUFFER           0x8893