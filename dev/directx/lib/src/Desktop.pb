;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Desktop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Desktop_Depth(desk)
  ProcedureReturn DesktopDepth(desk)
EndProcedure
ProcedureDLL.l Desktop_Frequency(desk)
  ProcedureReturn DesktopFrequency(desk)
EndProcedure
ProcedureDLL.l Desktop_Height(desk)
  ProcedureReturn DesktopHeight(desk)
EndProcedure
ProcedureDLL.l Desktop_Width(desk)
  ProcedureReturn DesktopWidth(desk)
EndProcedure
ProcedureDLL.l Desktop_MouseX()
  ProcedureReturn DesktopMouseX()
EndProcedure
ProcedureDLL.l Desktop_MouseY()
  ProcedureReturn DesktopMouseY()
EndProcedure
ProcedureDLL.l Desktop_Examine()
  ProcedureReturn ExamineDesktops()
EndProcedure
ProcedureDLL$ Desktop_Name(desk)
  ProcedureReturn DesktopName(desk)
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 26
; Folding = --