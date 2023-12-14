  proc File.LoadContent uses edi,\
     fileName

        locals
                hFile   dd      ?
                length  dd      ?
                read    dd      ?
                pBuffer dd      ?
        endl

        invoke  CreateFile, [fileName], GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        mov     [hFile], eax

        invoke  GetFileSize, [hFile], 0
        inc     eax
        mov     [length], eax
        invoke  HeapAlloc, [HeapHandle], 8, [length]
        mov     [pBuffer], eax

        lea     edi, [read]
        invoke  ReadFile, [hFile], [pBuffer], [length], edi, 0

        invoke  CloseHandle, [hFile]

        mov     eax, [pBuffer]

        ret
endp