define <export> {
  SCREEN_SYNCH     = 1
  SCREEN_NOSYNCH   = 0
  SCREEN_SYNCHSAFE = 2
}

type TScreen   <inherit = GAPI_Object>:
type TScreenMode {
  int tWidth
  int tHeight
  int tDepth
  int tRefreshRate
  int tFrameRate
}

global {
  TScreen Screen
  arr SCREEN_MODES of TScreenMode
  int GAPI_ScreenSynch
  TScreenMode GAPI_ScreenMode
}

method int TScreen.GetFreeMem(){
  return Screen_GetAvailableMemory()
}
property TScreen.Gamma(int RGB){
  Screen_SetGamma(0,0,0,1)
  Screen_SetGamma(RGB >> 16,RGB >> 8 & 0xFF,RGB & 0xFF,0)
}
method TScreen.setGamma(int RGB){
  Screen_SetGamma(0,0,0,1)
  Screen_SetGamma(RGB >> 16,RGB >> 8 & 0xFF,RGB & 0xFF,0)
}
method TScreen.setGamma(int R G B){
  Screen_SetGamma(0,0,0,1)
  Screen_SetGamma(R, G, B, 0)
}
method TScreen.Clear(int RGB){
  Screen_Clear(RGB)
}
method TScreen.Clear(int R G B){
  Screen_Clear((B<<16) + (G<<8) + R)
}
method TScreen.Close(){
  Screen_Close()
}
method TScreen.CreateRGBFilter(int x y width height RGB){

}
method TScreen.CreateRGBFilter(int x y width height R G B){
  Screen_DisplayRGBFilter(x,y,width,height,R,G,B)
}
method int TScreen.getDisplayModes(){
  int i = 0
  SCREEN_MODES.clear()
  if Screen_ExamineScreenModes(){
    while Screen_NextScreenMode(){
      SCREEN_MODES.expand(1)
      SCREEN_MODES[i].tWidth       = Screen_GetWidth ()
      SCREEN_MODES[i].tHeight      = Screen_GetHeight()
      SCREEN_MODES[i].tDepth       = Screen_GetDepth ()
      SCREEN_MODES[i].tRefreshRate = Screen_GetRefreshRate()
      i++
    }
    return $true
  }
  return $false
}
method TScreen.FlipBuffers(){
  Screen_FlipBuffers(GAPI_ScreenSynch)
}
method TScreen.FlipBuffers(int Synch){
  GAPI_ScreenSynch = Synch
  Screen_FlipBuffers(Synch)
}
property int TScreen.Synch{
  return GAPI_ScreenSynch
}
property TScreen.Synch(int Synch){
  GAPI_ScreenSynch = Synch
}
property int TScreen.Active{
  return Screen_IsActive()
}
method int TScreen.Create(int width height depth){
  GAPI_ScreenSynch = $SCREEN_SYNCH
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = depth
  return Screen_Create(width,height,depth,"".ptr())
}
method int TScreen.Create(int width height depth synch){
  GAPI_ScreenSynch = synch
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = depth
  return Screen_Create(width,height,depth,"".ptr())
}
method int TScreen.Create(int width height depth synch, str Title){
  GAPI_ScreenSynch = synch
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = depth
  return Screen_Create(width,height,depth,Title.ptr())
}
method int TScreen.CreateWindowed(int hwnd x y width height){
  GAPI_ScreenSynch = $SCREEN_SYNCH
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = 0
  return Screen_CreateWindowed(hwnd,x,y,width,height,$true,0,0)
}
method int TScreen.CreateWindowed(int hwnd x y width height AutoStretch){
  GAPI_ScreenSynch = $SCREEN_SYNCH
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = 0
  return Screen_CreateWindowed(hwnd,x,y,width,height,AutoStretch,0,0)
}
method int TScreen.CreateWindowed(int hwnd x y width height AutoStretch RightOffset BottomOffset){
  GAPI_ScreenSynch = $SCREEN_SYNCH
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = 0
  return Screen_CreateWindowed(hwnd,x,y,width,height,AutoStretch,RightOffset,BottomOffset)
}
method int TScreen.CreateWindowed(int hwnd x y width height AutoStretch RightOffset BottomOffset Synch){
  GAPI_ScreenSynch = Synch
  GAPI_ScreenMode.tWidth  = width
  GAPI_ScreenMode.tHeight = height
  GAPI_ScreenMode.tDepth  = 0
  return Screen_CreateWindowed(hwnd,x,y,width,height,AutoStretch,RightOffset,BottomOffset)
}
property int TScreen.Handle{
  return Screen_GetHandle()
}
property TScreen.RefreshRate(int fps){
  GAPI_ScreenMode.tRefreshRate = fps
  Screen_SetRefreshRate(fps)
}
property int TScreen.RefreshRate{
  return GAPI_ScreenMode.tRefreshRate
}
property TScreen.FrameRate(int fps){
  GAPI_ScreenMode.tFrameRate = fps
  Screen_SetFrameRate(fps)
}
property int TScreen.FrameRate{
  return GAPI_ScreenMode.tFrameRate
}
property int TScreen.Canvas(){
  return Screen_GetOutput()
}
method TScreen.StartFX(){
  Screen_StartFX()
}
method TScreen.StopFX(){
  Screen_StopFX()
}


