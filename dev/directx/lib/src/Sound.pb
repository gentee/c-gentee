UseOGGSoundDecoder()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Sound
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Sound_Init()
  ProcedureReturn InitSound()
EndProcedure
ProcedureDLL.l Sound_Catch(Mem)
  ProcedureReturn CatchSound(#PB_Any,Mem)
EndProcedure
ProcedureDLL Sound_Free(Sound)
  FreeSound(Sound)
EndProcedure
ProcedureDLL.l Sound_Exist(Sound)
  ProcedureReturn IsSound(Sound)
EndProcedure
ProcedureDLL.l Sound_Load(FileName$)
  ProcedureReturn LoadSound(#PB_Any,FileName$)
EndProcedure
ProcedureDLL Sound_Play(Sound, Mode)
  PlaySound(Sound,Mode)
EndProcedure
ProcedureDLL Sound_SetFrequency(Sound, Frequency)
  SoundFrequency(Sound, Frequency)
EndProcedure
ProcedureDLL Sound_SetPan(Sound,Pan)
  SoundPan(Sound,Pan)
EndProcedure
ProcedureDLL Sound_SetVolume(Sound,Volume)
  SoundVolume(Sound,Volume)
EndProcedure
ProcedureDLL Sound_Stop(Sound)
  ProcedureReturn StopSound(Sound)
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; ExecutableFormat = Shared Dll
; Folding = --
; Executable = Sound.dll