import "Graphics.dll" {
  //Joystick
  int Joystick_Init()
  int Joystick_Examine()
  int Joystick_GetAxisX()
  int Joystick_GetAxisY()
  int Joystick_GetButtonState(int)
  //Keyboard
  int Keyboard_Init()
  Keyboard_Examine()
  int Keyboard_GetLastChar()
  Keyboard_SetMode(int)
  int Keyboard_IsPushed(int)
  int Keyboard_IsReleased(int)
  //Mouse
  int Mouse_Init()
  int Mouse_Examine()
  int Mouse_IsLeftClick()
  int Mouse_IsRightClick()
  int Mouse_IsMiddleClick()
  int Mouse_GetDX()
  int Mouse_GetDY()
  int Mouse_GetX()
  int Mouse_GetY()
  int Mouse_SetPos(int,int)
  int Mouse_SetX(int)
  int Mouse_SetY(int)
  int Mouse_Wheel()
  int Mouse_Release(int)
}

include {
  "defines.g"
}

define <export>{
  //Joystick
  ARROW_L  = 1 //left
  ARROW_LU = 2 //left & up
  ARROW_UL = 2
  ARROW_U  = 3 //up
  ARROW_UR = 4 //up & right
  ARROW_RU = 4
  ARROW_R  = 5 //right
  ARROW_RD = 6 //right & down
  ARROW_DR = 6
  ARROW_D  = 7 //down
  ARROW_DL = 8 //down & left
  ARROW_LD = 8 //left & down

  //Keyboard
  BTN_ALL = -1

  BTN_1            = 2
  BTN_2            = 3
  BTN_3            = 4
  BTN_4            = 5
  BTN_5            = 6
  BTN_6            = 7
  BTN_7            = 8
  BTN_8            = 9
  BTN_9            = 10
  BTN_0            = 11

  BTN_A            = 30
  BTN_B            = 48
  BTN_C            = 46
  BTN_D            = 32
  BTN_E            = 18
  BTN_F            = 33
  BTN_G            = 34
  BTN_H            = 35
  BTN_I            = 23
  BTN_J            = 36
  BTN_K            = 37
  BTN_L            = 38
  BTN_M            = 50
  BTN_N            = 49
  BTN_O            = 24
  BTN_P            = 25
  BTN_Q            = 16
  BTN_R            = 19
  BTN_S            = 31
  BTN_T            = 20
  BTN_U            = 22
  BTN_V            = 47
  BTN_W            = 17
  BTN_X            = 45
  BTN_Y            = 21
  BTN_Z            = 44
  BTN_ESCAPE       = 1
  BTN_MINUS        = 12
  BTN_EQUALS       = 13
  BTN_BACK         = 14
  BTN_TAB          = 15
  BTN_LEFTBRACKET  = 26
  BTN_RIGHTBRACKET = 27
  BTN_RETURN       = 28
  BTN_LCONTROL     = 29
  BTN_SEMICOLON    = 39
  BTN_APOSTROPHE   = 40
  BTN_GRAVE        = 41
  BTN_LSHIFT       = 42
  BTN_BACKSLASH    = 43
  BTN_COMMA        = 51
  BTN_PERIOD       = 52
  BTN_SLASH        = 53
  BTN_RSHIFT       = 54
  BTN_MULTIPLY     = 55
  BTN_LALT         = 56
  BTN_SPACE        = 57
  BTN_CAPITAL      = 58
  BTN_F1           = 59
  BTN_F2           = 60
  BTN_F3           = 61
  BTN_F4           = 62
  BTN_F5           = 63
  BTN_F6           = 64
  BTN_F7           = 65
  BTN_F8           = 66
  BTN_F9           = 67
  BTN_F10          = 68
  BTN_F11          = 87
  BTN_F12          = 88
  BTN_NUMLOCK      = 69
  BTN_SCROLL       = 70
  BTN_PAD0         = 82
  BTN_PAD1         = 79
  BTN_PAD2         = 80
  BTN_PAD3         = 81
  BTN_PAD4         = 75
  BTN_PAD5         = 76
  BTN_PAD6         = 77
  BTN_PAD7         = 71
  BTN_PAD8         = 72
  BTN_PAD9         = 73
  BTN_ADD          = 78
  BTN_SUBSTRACT    = 74
  BTN_DECIMAL      = 83
  BTN_PADENTER     = 156
  BTN_RCONTROL     = 157
  BTN_PADCOMMA     = 179
  BTN_DIVIDE       = 181
  BTN_RALT         = 184
  BTN_PAUSE        = 197
  BTN_HOME         = 199
  BTN_UP           = 200
  BTN_DOWN         = 208
  BTN_LEFT         = 203
  BTN_RIGHT        = 205
  BTN_END          = 207
  BTN_PAGEUP       = 201
  BTN_PAGEDOWN     = 209
  BTN_INSERT       = 210
  BTN_DELETE       = 211

  //Keyboard
  KEYBOARD_QWERTY          = 0
  KEYBOARD_INTERNATIONAL   = 1
  KEYBOARD_ALLOWSYSTEMKEYS = 2
}

type TInputDevice <inherit = GAPI_Object>:
type TJoystick    <inherit = TInputDevice>:
type TKeyboard    <inherit = TInputDevice>:
type TMouse       <inherit = TInputDevice>:

global {
  TInputDevice InputDevice

  //Joystick
  TJoystick Joystick

  //Keyboard
  TKeyboard Keyboard
  arr BTN_KEYS of int = %{$BTN_1, $BTN_2, $BTN_3, $BTN_4, $BTN_5, $BTN_6, $BTN_7, $BTN_8, $BTN_9, $BTN_0, $BTN_A, $BTN_B, $BTN_C, $BTN_D, $BTN_E, $BTN_F, $BTN_G, $BTN_H,
                          $BTN_I, $BTN_J, $BTN_K, $BTN_L, $BTN_M, $BTN_N, $BTN_O, $BTN_P, $BTN_Q, $BTN_R, $BTN_S, $BTN_T, $BTN_U, $BTN_V, $BTN_W, $BTN_X, $BTN_Y, $BTN_Z,
                          $BTN_ESCAPE, $BTN_MINUS, $BTN_EQUALS, $BTN_BACK, $BTN_TAB, $BTN_LEFTBRACKET, $BTN_RIGHTBRACKET, $BTN_RETURN, $BTN_LCONTROL, $BTN_SEMICOLON,
                          $BTN_APOSTROPHE, $BTN_GRAVE, $BTN_LSHIFT, $BTN_BACKSLASH, $BTN_COMMA, $BTN_PERIOD, $BTN_SLASH, $BTN_RSHIFT, $BTN_MULTIPLY, $BTN_LALT,
                          $BTN_SPACE, $BTN_CAPITAL, $BTN_F1, $BTN_F2, $BTN_F3, $BTN_F4, $BTN_F5, $BTN_F6, $BTN_F7, $BTN_F8, $BTN_F9, $BTN_F10, $BTN_F11, $BTN_F12,
                          $BTN_NUMLOCK, $BTN_SCROLL, $BTN_PAD0, $BTN_PAD1, $BTN_PAD2, $BTN_PAD3, $BTN_PAD4, $BTN_PAD5, $BTN_PAD6, $BTN_PAD7, $BTN_PAD8, $BTN_PAD9,
                          $BTN_ADD, $BTN_SUBSTRACT, $BTN_DECIMAL, $BTN_PADENTER, $BTN_RCONTROL, $BTN_PADCOMMA, $BTN_DIVIDE, $BTN_RALT, $BTN_PAUSE, $BTN_HOME, $BTN_UP,
                          $BTN_DOWN, $BTN_LEFT, $BTN_RIGHT, $BTN_END, $BTN_PAGEUP, $BTN_PAGEDOWN, $BTN_INSERT, $BTN_DELETE
                         }
  arr BTN_PUSHED   of int
  arr BTN_RELEASED of int
  int GE_KeyboardMode = $KEYBOARD_QWERTY
  
  //Mouse
  TMouse Mouse
  int GE_MouseLock = $false
}

method int TInputDevice.UseJoystick(){
  return Joystick_Init()
}
method int TInputDevice.UseKeyboard(){
  return Keyboard_Init()
}
method int TInputDevice.UseMouse(){
  return Mouse_Init()
}

//Joystick
method int TJoystick.Examine(){ //опросить джостик
  return Joystick_Examine()
}
method int TJoystick.getAxisX(){   //-1:LEFT 1:RIGHT 0:--
  return Joystick_GetAxisX()
}
method int TJoystick.getAxisY(){   //-1:UP   1:DOWN  0:--
  return Joystick_GetAxisY()
}
method int TJoystick.getArrows(){   //получить положение крестовины джостика (ARROW_*)
  int x = Joystick_GetAxisX()
  int y = Joystick_GetAxisY()
  if   y == -1 {
    if   x == -1 : return $ARROW_LU :
    elif x ==  0 : return $ARROW_U  :
    elif x ==  1 : return $ARROW_RU :
  }
  elif y == 1  {
    if   x == -1 : return $ARROW_LD :
    elif x ==  0 : return $ARROW_D  :
    elif x ==  1 : return $ARROW_RD :
  }
  return $null
}
method int TJoystick.isLeft(){
  return ?(Joystick_GetAxisX()==-1,$true,$false)
}
method int TJoystick.isRight(){
  return ?(Joystick_GetAxisX()==1,$true,$false)
}
method int TJoystick.isUp(){
  return ?(Joystick_GetAxisY()==-1,$true,$false)
}
method int TJoystick.isDown(){
  return ?(Joystick_GetAxisY()==1,$true,$false)
}
method int TJoystick.IsButton(int N){
  return Joystick_GetButtonState(N)
}

//Keyboard
method TKeyboard.Examine(){
  Keyboard_Examine()
}
method str TKeyboard.getChar(){
  str s
  return s.copy(Keyboard_GetLastChar())
}
method int TKeyboard.isPushed(int KeyID){
  return Keyboard_IsPushed(KeyID)
}
method int TKeyboard.isReleased(int KeyID){
  return Keyboard_IsReleased(KeyID)
}
method TKeyboard.getPushedKeys(){
  int i = 0
  uint j KeyID
  BTN_PUSHED.clear()
  fornum j,*BTN_KEYS{
    KeyID = BTN_KEYS[j]
    if Keyboard_IsPushed(KeyID){
      BTN_PUSHED.expand(1)
      BTN_PUSHED[i]=KeyID
      i++
    }
  }
}
method TKeyboard.getReleasedKeys(){
  int i = 0
  uint j KeyID
  BTN_RELEASED.clear()
  fornum j,*BTN_KEYS{
    KeyID = BTN_KEYS[j]
    if Keyboard_IsReleased(KeyID){
      BTN_RELEASED.expand(1)
      BTN_RELEASED[i]=KeyID
      i++
    }
  }
}
property TKeyboard.Mode(int mode){
  GE_KeyboardMode = mode
  Keyboard_SetMode(mode)
}
property int TKeyboard.Mode{
  return GE_KeyboardMode
}

//Mouse
method int TMouse.Examine(){
  return Mouse_Examine()
}
method int TMouse.isLClick(){
  return Mouse_IsLeftClick()
}
method int TMouse.isRClick(){
  return Mouse_IsRightClick()
}
method int TMouse.isMClick(){
  return Mouse_IsMiddleClick()
}
method int TMouse.getDeltaX(){
  return Mouse_GetDX()
}
method int TMouse.getDeltaY(){
  return Mouse_GetDY()
}
property int TMouse.X{
  return Mouse_GetX()
}
property TMouse.X(int a){
  Mouse_SetX(a)
}
property int TMouse.Y{
  return Mouse_GetY()
}
property TMouse.Y(int a){
  Mouse_SetY(a)
}
method TMouse.setXY(int a b){
  Mouse_SetPos(a,b)
}
method TMouse.setPos(int a b){
  Mouse_SetPos(a,b)
}
method int TMouse.getWheel(){
  return Mouse_Wheel()
}
method int TMouse.getWheelTicks(){
  return abs(Mouse_Wheel())
}
method int TMouse.isWheelUp(){
  int ticks = Mouse_Wheel()
  return ?(ticks > 0,ticks,$false)
}
method int TMouse.isWheelDown(){
  int ticks = Mouse_Wheel()
  return ?(ticks < 0,abs(ticks),$false)
}
method int TMouse.Lock(){
  if Mouse_Release($true){
    GE_MouseLock = $true
    return $true
  }
  return $false
}
method int TMouse.Release{
  if (Mouse_Release($false)){
    GE_MouseLock = $false
    return $true
  }
  return $false
}
property int TMouse.Locked{
  return GE_MouseLock
}
property TMouse.Locked(int state){
  if (state > 0){
    this.Lock()
  }
  this.Release()
}
