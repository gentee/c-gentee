Macro BGR(RGB)
  ((RGB & $FF)<<16 + ((RGB >> 8 & $FF)<<8) + (RGB>>16))
EndMacro

UseTGAImageDecoder()
UseJPEGImageDecoder()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Screen_GetAvailableMemory()
  ProcedureReturn AvailableScreenMemory()
EndProcedure
ProcedureDLL Screen_SetGamma(R,G,B,Flags)
  ChangeGamma(R,G,B,Flags)
EndProcedure
ProcedureDLL Screen_Clear(RGB)
  ClearScreen(BGR(RGB))
EndProcedure
ProcedureDLL Screen_Close()
  CloseScreen()
EndProcedure
ProcedureDLL Screen_DisplayRGBFilter(x,y,width,height,R,G,B)
  DisplayRGBFilter(x, y, Width, Height, R, G, B)
EndProcedure
ProcedureDLL.l Screen_ExamineScreenModes()
  ProcedureReturn ExamineScreenModes()
EndProcedure
ProcedureDLL Screen_FlipBuffers(Mode)
  FlipBuffers(Mode)
EndProcedure
ProcedureDLL.l Screen_IsActive()
  ProcedureReturn IsScreenActive()
EndProcedure
ProcedureDLL.l Screen_NextScreenMode()
  ProcedureReturn NextScreenMode()
EndProcedure
ProcedureDLL.l Screen_Create(width,height,depth,Title$)
  ProcedureReturn OpenScreen(Width, Height, Depth, Title$)
EndProcedure
ProcedureDLL.l Screen_CreateWindowed(WindowID,x,y,Width,Height,AutoStretch,RightOffset,BottomOffset)
  ProcedureReturn OpenWindowedScreen(WindowID,x,y,Width,Height,AutoStretch,RightOffset,BottomOffset)
EndProcedure
ProcedureDLL.l Screen_GetHandle()
  ProcedureReturn ScreenID()
EndProcedure
ProcedureDLL.l Screen_GetDepth()
  ProcedureReturn ScreenModeDepth()
EndProcedure
ProcedureDLL.l Screen_GetHeight()
  ProcedureReturn ScreenModeHeight()
EndProcedure
ProcedureDLL.l Screen_GetWidth()
  ProcedureReturn ScreenModeWidth()
EndProcedure
ProcedureDLL.l Screen_GetRefreshRate()
  ProcedureReturn ScreenModeRefreshRate()
EndProcedure
ProcedureDLL Screen_SetRefreshRate(RefreshRate)
  SetRefreshRate(RefreshRate)
EndProcedure
ProcedureDLL.l Screen_GetOutput()
  ProcedureReturn ScreenOutput()
EndProcedure
ProcedureDLL Screen_SetFrameRate(FrameRate)
  SetFrameRate(FrameRate)
EndProcedure
ProcedureDLL Screen_StartFX()
  StartSpecialFX()
EndProcedure
ProcedureDLL Screen_StopFX()
  StopSpecialFX()
EndProcedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Sprite2D_Init()
  ProcedureReturn InitSprite()
EndProcedure
ProcedureDLL.l Sprite2D_Catch(Mem,Mode)
  ProcedureReturn CatchSprite(#PB_Any,Mem,Mode)
EndProcedure
ProcedureDLL Sprite2D_ChangeAlphaIntensity(R,G,B)
  ChangeAlphaIntensity(R,G,B)
EndProcedure
ProcedureDLL.l Sprite2D_Clip(Sprite,x,y,width,height)
  ProcedureReturn ClipSprite(Sprite, x, y, Width, Height)
EndProcedure
ProcedureDLL.l Sprite2D_Copy(Sprite,Mode)
  ProcedureReturn CopySprite(Sprite,#PB_Any,Mode)
EndProcedure
ProcedureDLL.l Sprite2D_Create(Width,Height,Mode)
  ProcedureReturn CreateSprite(#PB_Any,width,height,mode)
EndProcedure
ProcedureDLL Sprite2D_DisplayAlpha(Sprite,x,y)
  DisplayAlphaSprite(Sprite,x,y)
EndProcedure
ProcedureDLL Sprite2D_DisplayShadow(Sprite,x,y)
  DisplayShadowSprite(Sprite, x, y)
EndProcedure
ProcedureDLL Sprite2D_DisplaySolid(Sprite,x,y,RGB)
  DisplaySolidSprite(Sprite, x, y, BGR(RGB))
EndProcedure
ProcedureDLL Sprite2D_Display(Sprite,x,y)
  DisplaySprite(Sprite,x,y)
EndProcedure
ProcedureDLL Sprite2D_DisplayTranslucent(Sprite,x,y,Intensity)
  DisplayTranslucentSprite(Sprite, x, y, Intensity)
EndProcedure
ProcedureDLL Sprite2D_DisplayTransparent(Sprite,x,y)
  DisplayTransparentSprite(Sprite, x, y)
EndProcedure
ProcedureDLL Sprite2D_Free(Sprite)
  FreeSprite(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_Grab(x,y,width,height,mode)
  ProcedureReturn GrabSprite(#PB_Any, x, y, Width, Height, Mode)
EndProcedure
ProcedureDLL.l Sprite2D_Exist(Sprite)
  ProcedureReturn IsSprite(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_Load(FileName$,Mode.l)
  ProcedureReturn LoadSprite(#PB_Any,FileName$,Mode.l)
EndProcedure
ProcedureDLL.l Sprite2D_Collision(Sprite1, x1, y1, Sprite2, x2, y2)
  ProcedureReturn SpriteCollision(Sprite1, x1, y1, Sprite2, x2, y2)
EndProcedure
ProcedureDLL.l Sprite2D_GetDepth(Sprite)
  ProcedureReturn SpriteDepth(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_GetHeight(Sprite)
  ProcedureReturn SpriteHeight(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_GetWidth(Sprite)
  ProcedureReturn SpriteWidth(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_GetHandle(Sprite)
  ProcedureReturn SpriteID(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_GetOutput(Sprite)
  ProcedureReturn SpriteOutput(Sprite)
EndProcedure
ProcedureDLL.l Sprite2D_PixelCollision(Sprite1, x1, y1, Sprite2, x2, y2)
  ProcedureReturn SpritePixelCollision(Sprite1, x1, y1, Sprite2, x2, y2)
EndProcedure
ProcedureDLL Sprite2D_SetTransparentColor(Sprite, RGB)
  TransparentSpriteColor(Sprite, BGR(RGB))
EndProcedure
ProcedureDLL Sprite2D_UseBuffer(Sprite)
  UseBuffer(Sprite)
EndProcedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Sprite3D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Sprite3D_Init()
  ProcedureReturn InitSprite3D()
EndProcedure
ProcedureDLL.l Sprite3D_Create(Sprite2D)
  ProcedureReturn CreateSprite3D(#PB_Any,Sprite2D)
EndProcedure
ProcedureDLL Sprite3D_Display(Sprite,x,y,Transparency)
  ProcedureReturn DisplaySprite3D(Sprite,x,y,Transparency)
EndProcedure
ProcedureDLL Sprite3D_Free(Sprite)
  FreeSprite3D(Sprite)
EndProcedure
ProcedureDLL.l Sprite3D_Exist(Sprite)
  ProcedureReturn IsSprite3D(Sprite)
EndProcedure
ProcedureDLL Sprite3D_Rotate(Sprite,Angle,Mode)
  RotateSprite3D(Sprite, Angle, Mode)
EndProcedure
ProcedureDLL Sprite3D_BlendingMode(SourceMode, DestinationMode)
  Sprite3DBlendingMode(SourceMode, DestinationMode)
EndProcedure
ProcedureDLL Sprite3D_SetQuality(Quality)
  Sprite3DQuality(Quality)
EndProcedure
ProcedureDLL Sprite3D_Start3D()
  Start3D()
EndProcedure
ProcedureDLL Sprite3D_Stop3D()
  Stop3D()
EndProcedure
ProcedureDLL Sprite3D_Transform(Sprite,x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
  TransformSprite3D(Sprite, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
EndProcedure
ProcedureDLL Sprite3D_Zoom(Sprite,Width,Height)
  ZoomSprite3D(Sprite,Width,Height)
EndProcedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Graphics 2D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL g2d_BackColor(RGB)
  BackColor(BGR(RGB))
EndProcedure
ProcedureDLL g2d_Box(x,y,width,height,color)
  Box(x,y,width,height,BGR(color))
EndProcedure
ProcedureDLL g2d_Circle(x,y,R,color)
  Circle(x,y,R,BGR(color))
EndProcedure
ProcedureDLL g2d_DrawAlphaImage(ImageID,x,y)
  DrawAlphaImage(ImageID,x,y)
EndProcedure
ProcedureDLL g2d_DrawImage(ImageID,x,y,width,height)
  DrawImage(ImageID,x,y,width,height)
EndProcedure
ProcedureDLL g2d_DrawText(x,y,Text$,fcol,bcol)
  DrawText(x,y,Text$,BGR(fcol),BGR(bcol))
EndProcedure
ProcedureDLL.l g2d_GetBuffer()
  ProcedureReturn DrawingBuffer()
EndProcedure
ProcedureDLL.l g2d_GetBufferPitch()
  ProcedureReturn DrawingBufferPitch()
EndProcedure
ProcedureDLL.l g2d_GetBufferPixelFormat()
  ProcedureReturn DrawingBufferPixelFormat()
EndProcedure
ProcedureDLL g2d_SetFont(FontID)
  DrawingFont(FontID)
EndProcedure
ProcedureDLL g2d_SetMode(Mode)
  DrawingMode(Mode)
EndProcedure
ProcedureDLL g2d_Ellipse(x, y, RadiusX, RadiusY,color)
  Ellipse(x, y, RadiusX, RadiusY,BGR(color))
EndProcedure
ProcedureDLL g2d_FillArea(x, y, OutLineColor,color)
  FillArea(x, y, BGR(OutLineColor),BGR(color))
EndProcedure
ProcedureDLL g2d_FrontColor(RGB)
  FrontColor(BGR(RGB))
EndProcedure
ProcedureDLL g2d_Line(x, y, Width, Height,color)
  Line(x, y, Width, Height,BGR(color))
EndProcedure
ProcedureDLL g2d_LineXY(x1, y1, x2, y2,color)
  LineXY(x1, y1, x2, y2,BGR(color))
EndProcedure
ProcedureDLL g2d_Plot(x,y,color)
  Plot(x,y,BGR(color))
EndProcedure
ProcedureDLL.l g2d_GetColor(x,y)
  Protected BGR = Point(x,y)
  ProcedureReturn BGR(BGR)
EndProcedure
ProcedureDLL.l g2d_StartDrawing(OutputID)
  ProcedureReturn StartDrawing(OutputID)
EndProcedure
ProcedureDLL g2d_StopDrawing()
  StopDrawing()
EndProcedure
ProcedureDLL.l g2d_GetTextHeight(Text$)
  ProcedureReturn TextHeight(Text$)
EndProcedure
ProcedureDLL.l g2d_GetTextWidth(Text$)
  ProcedureReturn TextWidth(Text$)
EndProcedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Font
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Font_GetHandle(Font)
  ProcedureReturn FontID(Font)
EndProcedure
ProcedureDLL Font_Free(Font)
  FreeFont(Font)
EndProcedure
ProcedureDLL.l Font_Exist(Font)
  ProcedureReturn IsFont(Font)
EndProcedure
ProcedureDLL.l Font_Load(Name$,Size)
  ProcedureReturn LoadFont(#PB_Any,name$,Size)
EndProcedure
ProcedureDLL.l Font_LoadEx(Name$,Size,Flags)
  ProcedureReturn LoadFont(#PB_Any,name$,Size,Flags)
EndProcedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Image
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Image_Catch(Mem)
  ProcedureReturn CatchImage(#PB_Any,Mem)
EndProcedure
ProcedureDLL.l Image_CatchEx(Mem,Length)
  ProcedureReturn CatchImage(#PB_Any,Mem,Length,#PB_Image_DisplayFormat)
EndProcedure
ProcedureDLL.l Image_Copy(Image)
  ProcedureReturn CopyImage(Image,#PB_Any)
EndProcedure
ProcedureDLL.l Image_Create(Width, Height, Depth)
  ProcedureReturn CreateImage(#PB_Any, Width, Height, Depth)
EndProcedure
ProcedureDLL Image_Free(Image)
  FreeImage(Image)
EndProcedure
ProcedureDLL.l Image_Grab(Image,x,y,width,height)
  ProcedureReturn GrabImage(Image,#PB_Any,x,y,width,height)
EndProcedure
ProcedureDLL.l Image_GetDepth(Image)
  ProcedureReturn ImageDepth(Image)
EndProcedure
ProcedureDLL.l Image_GetHeight(Image)
  ProcedureReturn ImageHeight(Image)
EndProcedure
ProcedureDLL.l Image_GetWidth(Image)
  ProcedureReturn ImageWidth(Image)
EndProcedure
ProcedureDLL.l Image_GetHandle(Image)
  ProcedureReturn ImageID(Image)
EndProcedure
ProcedureDLL.l Image_GetOutput(Image)
  ProcedureReturn ImageOutput(Image)
EndProcedure
ProcedureDLL.l Image_Exist(Image)
  ProcedureReturn IsImage(Image)
EndProcedure
ProcedureDLL.l Image_Load(FileName$)
  ProcedureReturn LoadImage(#PB_Any,FileName$,#PB_Image_DisplayFormat)
EndProcedure
ProcedureDLL.l Image_LoadEx(FileName$,Flags)
  ProcedureReturn LoadImage(#PB_Any,FileName$,Flags)
EndProcedure
ProcedureDLL Image_Resize(Image,w,h)
  ResizeImage(Image,w,h,#PB_Image_Smooth)
EndProcedure
ProcedureDLL.l Image_Save(Image,FileName$,Format,Quality)
  ProcedureReturn SaveImage(Image,FileName$,Format,Quality)
EndProcedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Joystick
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Joystick_Init()
  ProcedureReturn InitJoystick()
EndProcedure
ProcedureDLL.l Joystick_Examine()
  ProcedureReturn ExamineJoystick()
EndProcedure
ProcedureDLL.l Joystick_GetAxisX()
  ProcedureReturn JoystickAxisX()
EndProcedure
ProcedureDLL.l Joystick_GetAxisY()
  ProcedureReturn JoystickAxisY()
EndProcedure
ProcedureDLL.l Joystick_GetButtonState(Button.l)
  ProcedureReturn JoystickButton(Button)
EndProcedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Mouse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Mouse_Init()
  ProcedureReturn InitMouse()
EndProcedure
ProcedureDLL.l Mouse_Examine()
  ProcedureReturn ExamineMouse()
EndProcedure
ProcedureDLL.l Mouse_IsLeftClick()
  ProcedureReturn MouseButton(#PB_MouseButton_Left)
EndProcedure
ProcedureDLL.l Mouse_IsRightClick()
  ProcedureReturn MouseButton(#PB_MouseButton_Right)
EndProcedure
ProcedureDLL.l Mouse_IsMiddleClick()
  ProcedureReturn MouseButton(#PB_MouseButton_Middle)
EndProcedure
ProcedureDLL.l Mouse_GetDX()
  ProcedureReturn MouseDeltaX()
EndProcedure
ProcedureDLL.l Mouse_GetDY()
  ProcedureReturn MouseDeltaY()
EndProcedure
ProcedureDLL.l Mouse_GetX()
  ProcedureReturn MouseX()
EndProcedure
ProcedureDLL.l Mouse_GetY()
  ProcedureReturn MouseY()
EndProcedure
ProcedureDLL.l Mouse_SetPos(x,y)
  ProcedureReturn MouseLocate(x,y)
EndProcedure
ProcedureDLL.l Mouse_SetX(x)
  ProcedureReturn MouseLocate(x,MouseY())
EndProcedure
ProcedureDLL.l Mouse_SetY(y)
  ProcedureReturn MouseLocate(MouseX(),y)
EndProcedure
ProcedureDLL.l Mouse_Wheel()
  ProcedureReturn MouseWheel()
EndProcedure
ProcedureDLL.l Mouse_Release(State.l)
  ProcedureReturn ReleaseMouse(State)
EndProcedure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Keyboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProcedureDLL.l Keyboard_Init()
  ProcedureReturn InitKeyboard()
EndProcedure
ProcedureDLL Keyboard_Examine()
  ExamineKeyboard()
EndProcedure
ProcedureDLL$ Keyboard_GetLastChar()
  ProcedureReturn KeyboardInkey()
EndProcedure
ProcedureDLL Keyboard_SetMode(Mode.l)
  KeyboardMode(Mode)
EndProcedure
ProcedureDLL.l Keyboard_IsPushed(KeyID.l)
  ProcedureReturn KeyboardPushed(KeyID)
EndProcedure
ProcedureDLL.l Keyboard_IsReleased(KeyID.l)
  ProcedureReturn KeyboardReleased(KeyID)
EndProcedure
; IDE Options = PureBasic 4.20 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 353
; FirstLine = 334
; Folding = ----------------------
; Executable = ..\..\Graphics.dll