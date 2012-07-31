 '///////////////////////////////////////////////////////////////////////////
 'Программа линковщик для добавления скомпилированног кода в секцию EXE файла
 'Для компиляции этого исходника, использовать компилятор PowerBASIC for Windows, версии 8.01 или старше
 'В принципе можно использовать и более ранние версии, но для этого надо будет заново пересобрать PBR файл ресурсов
 'именно тем компилятором ресурсов, который прилагается к данной версии PowerBASIC.
 '(c) Пашков Александр 2005г.
 '////////////////////////////////////////////////////////////////////////////

 #Compile  Dll "ExeLink.dll"
 #Tools    Off
 #Dim      All
 #Register Default
 #Resource "ExeLink.pbr"
 #Include  "Win32API.inc"

 Global ghInstance As Dword

  Macro Function AnsiUnicode (CodePage, AnsiTxt)
      MacroTemp WideCharStr, l
      Dim l As Dword, WideCharStr As String
      l = Len(AnsiTxt) + 1
      WideCharStr = String$(l + l, 0)
      MultiByteToWideChar CodePage, 0, ByVal StrPtr(AnsiTxt), l, ByVal StrPtr(WideCharStr), l
  End Macro = WideCharStr

   Macro ReadPeFile
      f = FreeFile: Err = 0
      Open szPePath For Binary Shared As #f
      If Err = 0 Then Get$ #f, Lof(f), szPeFileData
      Close #f: If Err Then Exit Do
      lpImageDosHeader = StrPtr(szPeFileData)
      If Len(szPeFileData) < SizeOf(IMAGE_DOS_HEADER) Then Err = 1: Exit Do
      If @lpImageDosHeader.e_magic <> %IMAGE_DOS_SIGNATURE Then Err = 1: Exit Do
      If Len(szPeFileData) < @lpImageDosHeader.e_lfanew + SizeOf(IMAGE_NT_HEADERS) Then Err = 1: Exit Do
      lpImageNtHeaders = lpImageDosHeader + @lpImageDosHeader.e_lfanew
      If @lpImageNtHeaders.Signature <> %IMAGE_NT_SIGNATURE Then Err = 1: Exit Do
      If @lpImageNtHeaders.FileHeader.SizeOfOptionalHeader <> SizeOf(@lpImageNtHeaders.OptionalHeader) Or _
         @lpImageNtHeaders.OptionalHeader.Magic <> %IMAGE_NT_OPTIONAL_HDR32_MAGIC Then Err = 2: Exit Do
   End Macro

   Macro WritePeFile
      f = FreeFile
      Open szPePath For Output As f
      If Err = 0 Then Print #f, szPeFileData;
      Close #f
   End Macro


 Function ReadExeFile (szExeFileName As String, szExeData As String, RsRcPresent As Dword) As Long
      Dim f                         As Local Dword
      Dim i                         As Local Dword
      Dim lpImageDosHeader          As Local IMAGE_DOS_HEADER Ptr
      Dim lpImageNtHeaders          As Local IMAGE_NT_HEADERS Ptr
      Dim lpImageSectionHeader      As Local IMAGE_SECTION_HEADER Ptr
      ErrClear: f = FreeFile: Open szExeFileName For Binary Lock Write As #f
      If Err = 0 Then Get$ #f, Lof(f), szExeData
      Close #f: If Err Then Function = 1: Exit Function
      lpImageDosHeader = StrPtr(szExeData)
      If Len(szExeData) < SizeOf(IMAGE_DOS_HEADER) Then Function = 2: Exit Function
      If @lpImageDosHeader.e_magic <> %IMAGE_DOS_SIGNATURE Then Function = 2: Exit Function
      If Len(szExeData) < @lpImageDosHeader.e_lfanew + SizeOf(IMAGE_NT_HEADERS) Then Function = 2: Exit Function
      lpImageNtHeaders = lpImageDosHeader + @lpImageDosHeader.e_lfanew
      If @lpImageNtHeaders.Signature <> %IMAGE_NT_SIGNATURE Then Function = 2: Exit Function
      If @lpImageNtHeaders.FileHeader.SizeOfOptionalHeader <> SizeOf(@lpImageNtHeaders.OptionalHeader) Or _
         @lpImageNtHeaders.OptionalHeader.Magic <> %IMAGE_NT_OPTIONAL_HDR32_MAGIC Then Function = 2: Exit Function
      If @lpImageNtHeaders.FileHeader.NumberOfSections < 1 Then Function = 2: Exit Function
      lpImageDosHeader     = StrPtr(szExeData)
      lpImageNtHeaders     = lpImageDosHeader + @lpImageDosHeader.e_lfanew
      lpImageSectionHeader = lpImageNtHeaders + SizeOf(IMAGE_NT_HEADERS)
      If @lpImageNtHeaders.OptionalHeader.DataDirectory(%IMAGE_DIRECTORY_ENTRY_RESOURCE).VirtualAddress <> 0 Then _
            RsRcPresent = 1 Else RsRcPresent = 0
  End Function

  Function AddDataSectionToExe   (szExeData As String, szNewSectionName As String, szNewSectionData As String, ByVal SectionTp As Dword)   As Long
      Dim lpImageDosHeader          As Local IMAGE_DOS_HEADER Ptr
      Dim lpImageNtHeaders          As Local IMAGE_NT_HEADERS Ptr
      Dim lpImageSectionHeader      As Local IMAGE_SECTION_HEADER Ptr
      Dim szSectionFileImage()      As Local String
      Dim nSections                 As Local Dword
      Dim FileAlignment             As Local Dword
      Dim SectionAlignment          As Local Dword
      Dim SizeOfSectionOld          As Local Dword
      Dim SizeOfSectionNew          As Local Dword
      Dim i                         As Local Dword
      Dim j                         As Local Dword
      Dim k                         As Local Dword
      Dim m                         As Local Dword
      lpImageDosHeader     = StrPtr(szExeData)
      lpImageNtHeaders     = lpImageDosHeader + @lpImageDosHeader.e_lfanew
      lpImageSectionHeader = lpImageNtHeaders + SizeOf(IMAGE_NT_HEADERS)
      nSections            = @lpImageNtHeaders.FileHeader.NumberOfSections
      FileAlignment        = @lpImageNtHeaders.OptionalHeader.FileAlignment
      SectionAlignment     = @lpImageNtHeaders.OptionalHeader.SectionAlignment
      If (nSections < 1) Or (FileAlignment < 1) Or (SectionAlignment < 1) Then Function = 1: Exit Function
      ReDim szSectionFileImage(nSections + 1)
      For i = 0 To nSections - 1
         For j = i + 1 To nSections - 1
            If @lpImageSectionHeader[j].VirtualAddress  < @lpImageSectionHeader[i].VirtualAddress Then _
               Swap @lpImageSectionHeader[j], @lpImageSectionHeader[i]
         Next
         SizeOfSectionOld = @lpImageSectionHeader[i].SizeOfRawData
         SizeOfSectionNew = FileAlignment * ((SizeOfSectionOld + FileAlignment - 1) \ FileAlignment)
         szSectionFileImage(i + 1) = Mid$(szExeData, @lpImageSectionHeader[i].PointerToRawData + 1, SizeOfSectionOld) + _
            String$(SizeOfSectionNew - SizeOfSectionOld, 0)
         If Len(szSectionFileImage(i + 1)) <> SizeOfSectionNew Then Function = 1: Exit Function
      Next
      SizeOfSectionOld = Len(szNewSectionData)
      SizeOfSectionNew = FileAlignment * ((SizeOfSectionOld + FileAlignment - 1) \ FileAlignment)
      szSectionFileImage(nSections + 1) = szNewSectionData + String$(SizeOfSectionNew - SizeOfSectionOld, 0)
      If Len(szSectionFileImage(nSections + 1)) <> SizeOfSectionNew Then Function = 1: Exit Function
      SizeOfSectionOld = lpImageSectionHeader - lpImageDosHeader + SizeOf(IMAGE_SECTION_HEADER) * nSections
      SizeOfSectionNew = FileAlignment * ((SizeOfSectionOld + SizeOf(IMAGE_SECTION_HEADER) + FileAlignment - 1) \ FileAlignment)
      szSectionFileImage(0) = Left$(szExeData, SizeOfSectionOld) + String$(SizeOfSectionNew - SizeOfSectionOld, 0)
      If Len(szSectionFileImage(0)) <> SizeOfSectionNew Then Function = 1: Exit Function
      Incr nSections
      k = 0: For i = 0 To nSections: k = k + Len(szSectionFileImage(i)): Next
      szExeData = String$(k, 0): k = StrPtr(szExeData)
      For i = 0 To nSections
         MoveMemory ByVal k, ByVal StrPtr(szSectionFileImage(i)), Len(szSectionFileImage(i))
         k = k + Len(szSectionFileImage(i))
      Next
      lpImageDosHeader     = StrPtr(szExeData)
      lpImageNtHeaders     = lpImageDosHeader + @lpImageDosHeader.e_lfanew
      lpImageSectionHeader = lpImageNtHeaders + SizeOf(IMAGE_NT_HEADERS)
      @lpImageSectionHeader[nSections - 1].xName =  Left$(szNewSectionName + String$(8, 0), 8)
      @lpImageSectionHeader[nSections - 1].Misc.VirtualSize = Len(szNewSectionData)
      @lpImageSectionHeader[nSections - 1].Characteristics   = &H40000040???
      k = Len(szSectionFileImage(0))
      @lpImageNtHeaders.FileHeader.NumberOfSections = nSections
      @lpImageNtHeaders.OptionalHeader.SizeOfHeaders = k
      m = k
      For i = 0 To nSections - 1
         @lpImageSectionHeader[i].PointerToRawData = k
         j = Len(szSectionFileImage(i + 1))
         @lpImageSectionHeader[i].SizeOfRawData = j
         k = k + j
         m = SectionAlignment * ((m + SectionAlignment - 1) \ SectionAlignment)
         If i = nSections - 1 Then
            @lpImageSectionHeader[i].VirtualAddress = m
            If SectionTp = 1 Then
               @lpImageNtHeaders.OptionalHeader.DataDirectory(%IMAGE_DIRECTORY_ENTRY_RESOURCE).VirtualAddress = @lpImageSectionHeader[i].VirtualAddress
               @lpImageNtHeaders.OptionalHeader.DataDirectory(%IMAGE_DIRECTORY_ENTRY_RESOURCE).nSize = @lpImageSectionHeader[i].Misc.VirtualSize
            End If
         End If
         If m > @lpImageSectionHeader[i].VirtualAddress Then Function = 1: Exit Function
         If (@lpImageSectionHeader[i].VirtualAddress Mod SectionAlignment) Then Function = 1: Exit Function
         m = @lpImageSectionHeader[i].VirtualAddress + @lpImageSectionHeader[i].Misc.VirtualSize
      Next
      @lpImageNtHeaders.OptionalHeader.SizeOfImage = SectionAlignment * ((m + SectionAlignment - 1) \ SectionAlignment)
      @lpImageNtHeaders.OptionalHeader.SizeOfInitializedData = @lpImageNtHeaders.OptionalHeader.SizeOfInitializedData + _
      @lpImageSectionHeader[nSections - 1].Misc.VirtualSize

   End Function

   Function AddDummyResSection (szExeFileNameIn As String, szExeFileNameOut As String) As Long
      Dim szExeData                 As Local String
      Dim szSectionData             As Local String
      Dim RsRcPresent               As Local Dword
      Dim f                         As Local Dword
      If ReadExeFile (szExeFileNameIn, szExeData, RsRcPresent) Then Function = -1: Exit Function
      If RsRcPresent = 0 Then
         szSectionData = String$(16, 0)
         If AddDataSectionToExe (szExeData, ".rsrc", szSectionData, 1) Then Function = -2: Exit Function
         Err = 0: f = FreeFile: Open szExeFileNameOut For Output As #f
         If Err = 0 Then Print #f, szExeData;
         Close #f: If Err Then Function = -4: Exit Function
       ElseIf szExeFileNameIn <> szExeFileNameOut Then
         If CopyFile (ByVal StrPtr(szExeFileNameIn), ByVal StrPtr(szExeFileNameOut), 0) = 0 Then _
            Function = -4: Exit Function
      End If
   End Function

  Function AddResToExe (szExeFileNameIn As String, szExeFileNameOut As String, szResFileName As String, ByVal DeleteExisting As Dword) As Long
      Dim hLib                      As Static Dword
      Dim hBeginUpdateResourceW     As Static Dword
      Dim hUpdateResourceW          As Static Dword
      Dim hEndUpdateResourceW       As Static Dword
      Dim szTmp                     As Local String
      Dim szTmpU                    As Local String
      Dim hUpdateRes                As Local Dword
      Dim IniPos                    As Local Dword
      Dim CurPos                    As Local Dword Ptr
      Dim EndPos                    As Local Dword
      Dim lpResType                 As Local Word Ptr
      Dim lpResName                 As Local Word Ptr
      Dim lpDataVersion             As Local Dword Ptr
      Dim lpCodePage                As Local Word Ptr
      Dim ResTypeIdAddr             As Local Dword
      Dim ResNameIdAddr             As Local Dword
      Dim f                         As Local Dword
      Dim i                         As Local Dword
      If hLib = 0 Then
         hLib = GetModuleHandle("Unicows.dll")
         If hLib = 0 Then hLib = LoadLibrary("Unicows.dll")
         If hLib = 0 Then hLib = LoadLibrary("Kernel32.dll")
      End If
      If hBeginUpdateResourceW = 0 Then hBeginUpdateResourceW = GetProcAddress(hLib, "BeginUpdateResourceW")
      If hUpdateResourceW      = 0 Then hUpdateResourceW      = GetProcAddress(hLib, "UpdateResourceW")
      If hEndUpdateResourceW   = 0 Then hEndUpdateResourceW   = GetProcAddress(hLib, "EndUpdateResourceW")
      If AddDummyResSection (szExeFileNameIn, szExeFileNameOut) Then Function = -1: Exit Function
      f = FreeFile: ErrClear
      Open szResFileName For Binary Shared As #f
      If Err = 0 Then Get$ #f, Lof(f), szTmp
      Close #f
      If Left$(szTmp, 32) <> Chr$(0, 0, 0, 0, 32, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0) + String$(16, 0) Then _
         Function = 1: Exit Function
      szTmpU = AnsiUnicode(GetACP, szExeFileNameOut)
      If hBeginUpdateResourceW = 0 Then hUpdateRes = 0 Else _
         Call Dword hBeginUpdateResourceW Using BeginUpdateResource (ByVal StrPtr(szTmpU), DeleteExisting) To hUpdateRes
      If hUpdateRes = 0 Then Function = 1: Exit Function
      IniPos = StrPtr(szTmp)
      CurPos = IniPos + 32
      EndPos = IniPos + Len(szTmp)
      Do
         If CurPos >= EndPos Then Exit Do
         lpResType = CurPos + 8
         If @lpResType = &HFFFF?? Then
            ResTypeIdAddr = @lpResType[1]
            Incr lpResType
         Else
            ResTypeIdAddr = lpResType
            While @lpResType <> 0: Incr lpResType: Wend
         End If
         lpResName = lpResType + 2

         If @lpResName = &HFFFF?? Then
            ResNameIdAddr = @lpResName[1]
            Incr lpResName
         Else
            ResNameIdAddr = lpResName
            While @lpResName <> 0: Incr lpResName: Wend
         End If
         lpDataVersion = lpResName + 2

         If ((lpDataVersion - CurPos) Mod 4) <> 0 Then Incr lpDataVersion

         lpCodePage = lpDataVersion + 6

         If hUpdateResourceW = 0 Then i = 0 Else _
            Call Dword hUpdateResourceW Using UpdateResource(hUpdateRes, ByVal ResTypeIdAddr, ByVal ResNameIdAddr, _
               @lpCodePage, ByVal CurPos + @CurPos[1], ByVal @CurPos) To i
         If i = 0 Then Function = 1: Exit Function
         @CurPos = Fix((@CurPos + 3) / 4) * 4
         CurPos = CurPos + @CurPos[1] + @CurPos
      Loop
      If hEndUpdateResourceW = 0 Then i = 0 Else _
         Call Dword hEndUpdateResourceW Using EndUpdateResource (hUpdateRes, 0) To i
      If i = 0 Then Function = 1: Exit Function
   End Function

   Function MarkAsConsole (szPePath As String, ConvertToConsole As Dword) As Dword
      Dim szPeFileData                As Local String
      Dim lpImageDosHeader            As Local IMAGE_DOS_HEADER Ptr
      Dim lpImageNtHeaders            As Local IMAGE_NT_HEADERS Ptr
      Dim f                           As Local Dword
      Dim i                           As Local Dword
      Do
       If ConvertToConsole = 0 Then Exit Function
          ReadPeFile
          @lpImageNtHeaders.OptionalHeader.SubSystem = 3: Exit Do
       Loop
       WritePeFile
       ConvertToConsole = 0: Function = 1
   End Function

   Function MarkAsGUI (szPePath As String, ConvertToConsole As Dword) As Dword
      Dim szPeFileData                As Local String
      Dim lpImageDosHeader            As Local IMAGE_DOS_HEADER Ptr
      Dim lpImageNtHeaders            As Local IMAGE_NT_HEADERS Ptr
      Dim f                           As Local Dword
      Dim i                           As Local Dword
      Do
       If ConvertToConsole = 0 Then Exit Function
          ReadPeFile
           @lpImageNtHeaders.OptionalHeader.SubSystem = 2: Exit Do
       Loop
       WritePeFile
       ConvertToConsole = 0: Function = 1 ' successful
   End Function

   Function MarkAsVersion (szPePath As String, ConvertToConsole As Dword, ByVal app As Word) As Dword
      Dim szPeFileData                As Local String
      Dim lpImageDosHeader            As Local IMAGE_DOS_HEADER Ptr
      Dim lpImageNtHeaders            As Local IMAGE_NT_HEADERS Ptr
      Dim f                           As Local Dword
      Dim i                           As Local Dword
      Do
       If ConvertToConsole = 0 Then Exit Function
          ReadPeFile
          @lpImageNtHeaders.OptionalHeader.MajorSubsystemVersion = app
           Exit Do
       Loop
       WritePeFile
       ConvertToConsole = 0: Function = 1
   End Function

   Function Add_Res_Section Alias "Add_Res_Section" (ByRef FileStub_A As Asciiz * 255, ByRef RES_A As Asciiz * 255 ) Export As Dword
      Local Result As Long
      Local FileStub As String
      Local RES      As String
      FileStub=FileStub_A
      RES=RES_A
      Open FileStub For Input As #1
          If Err <> 0 Then
              Close #1:Function=1:Exit Function
          End If
      Close #1
      Open RES For Input As #1
          If Err <> 0 Then
              Close #1:Function=2:Exit Function
          End If
       Close #1
       Result= AddResToExe (FileStub, FileStub, Res, 1)
       If Result=-1 Then Function=3:Exit Function
       If Result<>0 Then Function=4:Exit Function
  End Function

  Function Add_Data_Section  Alias "Add_Data_Section" (ByRef szExeData_A As Asciiz * 255,ByRef szNewSectionName_A As Asciiz * 255,ByRef szNewSectionData_A As Asciiz * 255)Export  As Long
    Local Result As Long
    Local szExeData          As String
    Local szNewSectionName   As String
    Local szNewSectionData   As String
    szExeData=szExeData_A
    szNewSectionName=szNewSectionName_A
    szNewSectionData=szNewSectionData_A
    Open szExeData For Input As #1
      If Err <> 0 Then
          Close #1:Function=1:Exit Function
      End If
    Close #1
    Open szNewSectionData For Input As #1
      If Err <> 0 Then
          Close #1:Function=2:Exit Function
      End If
    Close #1
    Dim tmpExeData                As Local String
    Dim szSectionData             As Local String
    Dim f                         As Local Dword
    If ReadExeFile (szExeData, tmpExeData, 0)<>0 Then
         Function = 3:Exit Function
    End If
    Open szNewSectionData For Binary As #1
    If Err = 0 Then Get$ #1, Lof(1), szSectionData
    Close #1
    Result=AddDataSectionToExe (tmpExeData, szNewSectionName , szSectionData , 0)
    If Result<>0 Then Function = 4: Exit Function
     f = FreeFile
     Open szExeData For Output As #f
       If Err = 0 Then Print #f, tmpExeData;
     Close #f
     If Err Then Function = 4
   End Function

  Function Set_Sub_System Alias "Set_Sub_System" (ByRef ExeFile_A As Asciiz * 255, ByVal app As Dword)Export As Dword
      Local Result      As Long
      Dim   tmpExeData  As Local String
      Local ExeFile     As String
      ExeFile=ExeFile_A
      Open ExeFile For Input As #1
      If Err <> 0 Then
          Close #1:Function=1:Exit Function
      End If
      Close #1
     If app<>1 And app<>2 Then Function=2:Exit Function
     If ReadExeFile (ExeFile, tmpExeData, 0)<>0 Then Function = 3:Exit Function
     If APP=1 Then  Result= MarkAsConsole (ExeFile,1)
     If APP=2 Then  Result= MarkAsGUI (ExeFile,1)
     If Result<>1 Then Function=3
  End Function

  Function Set_OS_Version Alias "Set_OS_Version" (ByRef ExeFile_A As Asciiz * 255, ByVal app As Word)Export As Dword
    Local Result      As Long
    Dim   tmpExeData  As Local String
    Local ExeFile     As String
    ExeFile=ExeFile_A
    Open ExeFile For Input As #1
      If Err <> 0 Then
          Close #1:Function=1:Exit Function
      End If
    Close #1
    If App<>3 And App<>4 And app<>5 Then Function=2:Exit Function
    Result=MarkAsVersion  ( ExeFile,1,app)
    If  Result<>1 Then Function=3
  End Function

'/////////////////////////////////////////////////////////////////////////////////////////
'/ Точка входа в DLL
'/
  Function LibMain (ByVal hInstance   As Long, _
                  ByVal fwdReason   As Long, _
                  ByVal lpvReserved As Long) As Long

    Select Case fwdReason

    Case %DLL_PROCESS_ATTACH
        ghInstance = hInstance
        Function = 1   'success!
    Case %DLL_PROCESS_DETACH
        Function = 1   'success!
    Case %DLL_THREAD_ATTACH
        Function = 1   'success!
    Case %DLL_THREAD_DETACH
        Function = 1   'success!

    End Select

  End Function
'/////////////////////////////////////////////////////////////////////////////////////////
