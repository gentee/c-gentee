include {
  "lib//Graphics.g"
  "lib//InputDevice.g"
}

define{
  SCREEN_WIDTH = 1024
  SCREEN_HEIGHT = 768
}

func Main <entry>{
  int x = 1
  int y = 1
  int n = $SCREEN_HEIGHT - 1
  
  int  r s
  
  InputDevice.UseKeyboard()

  Screen.Create($SCREEN_WIDTH,$SCREEN_HEIGHT,32)
  
  Image img
  img.Create(n,n)

  Graphics.StartDraw(img)
    for r=0, r<=n, r++ {
      for s=0, s<=(n-r), s++ {
        if (r && s){
          Graphics.Plot(x+r+5  , y+s+5  , 64+r/4, s/4   , s/2+64)
          Graphics.Plot(x+6+n-r, y+6+n-s, s/4   , 64+r/4, s/2+64)
        }
        else{
          Graphics.Plot(x+r+5  , y+s+5  , 128+r/4, s/2    , s/2+128)
          Graphics.Plot(x+6+n-r, y+6+n-s, s/2    , 128+r/4, s/2+128)
        }
      }
    }
  Graphics.StopDraw()
  
  img.Resize($SCREEN_WIDTH,$SCREEN_HEIGHT)


  Graphics.StartDraw(Screen)
    img.Draw(0,0)
  Graphics.StopDraw()

  
  Screen.FlipBuffers()
  
  while (!Keyboard.isPushed($BTN_ALL)){
    Keyboard.Examine()
  }
}
