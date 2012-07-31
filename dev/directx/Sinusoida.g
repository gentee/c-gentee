include {
  "lib//Graphics.g"
  "lib//InputDevice.g"
}
func Main <entry> {
  int x = 0
  
  InputDevice.UseKeyboard()
  
  Screen.Create(640,480,32)
  while (!Keyboard.isPushed($BTN_ALL)) {
    //Misc.Delay(1)
    x++
    if (x >= 640) {
      x = 0
    }
    Graphics.StartDraw(Screen)
      Graphics.Plot(x,int(sin(double(x)*0.017453)*100.0) + 100,0x00FF00)
    Graphics.StopDraw()
    Screen.FlipBuffers()
    Keyboard.Examine()
  }
}
