include {
  "lib//Graphics.g"
  "lib//GraphicsTypes.g"
  "lib//GraphicsUtils.g"
  "lib//InputDevice.g"
}

define {
  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480
  POINT_COUNT   = 255
}

func Main <entry> {
  arr PointArray[$POINT_COUNT+1] of TPoint
  int mb_left   = 0
  int mb_right  = 0
  float oldtime = 0F
  float angle = 0F
  Sprite2D sprite
  Sprite3D s3d
  int count = 0
  int currentzoom = 0
  int currentpoint = 0
  int offset = 0
  int f x y Trans

  InputDevice.UseMouse()
  InputDevice.UseKeyboard()

  Screen.Create($SCREEN_WIDTH,$SCREEN_HEIGHT,32)

  sprite.Create(16,16,$SPRITE2D_TEXTURE)
  Graphics.StartDraw(sprite)
    Graphics.Box(0,0,16,16,RGB(128,128,128))
    Graphics.Box(1,1,14,14,RGB(255,255,255))
    Graphics.Box(2,2,12,12,RGB(128,128,128))
    Graphics.Box(3,3,10,10,RGB(0,0,0))
  Graphics.StopDraw()
  
  s3d.Create(sprite)
  


  while (!Keyboard.isPushed($BTN_ESCAPE)){
    Screen.FlipBuffers()
    
    Screen.Clear(0x000000)
    
    Mouse.Examine()
    PointArray[count].x = Mouse.X
    PointArray[count].y = Mouse.Y
    
    Screen.Start3D()
      for f=0, f<=$POINT_COUNT, f++ {
        currentzoom=(($POINT_COUNT-f) >> 2)+1
        offset=currentzoom >> 1
        currentpoint = ((f + count) & $POINT_COUNT)
        x = PointArray[currentpoint].x
        y = PointArray[currentpoint].y
        Trans= f / 2

        s3d.Rotate(0,0)
        s3d.Zoom(currentzoom, currentzoom)
        s3d.Rotate(int(angle),1)
        s3d.Show(x-offset,y-offset,Trans)
        s3d.Show(($SCREEN_WIDTH-x)-offset,($SCREEN_HEIGHT-y)-offset,Trans)
        s3d.Rotate(0,0)
        s3d.Zoom(currentzoom, currentzoom)
        s3d.Rotate(int(-angle),1)
        s3d.Show(($SCREEN_WIDTH-x)-offset,y-offset,Trans)
        s3d.Show(x-offset,($SCREEN_HEIGHT-y)-offset,Trans)
        
        angle = angle + 0.1F
        if (angle >= 360F) {
          angle = 0F
        }
      }
    Screen.Stop3D()
    
    Graphics.StartDraw(Screen)
      Graphics.Text(5,5,"Двигай мышью!")
    Graphics.StopDraw()

    count = (count+1) & $POINT_COUNT
    
    Keyboard.Examine()
  }
}

