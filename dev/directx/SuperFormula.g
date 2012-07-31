include {
  "lib//Graphics.g"
  "lib//GraphicsUtils.g"
  "lib//InputDevice.g"
}

define {
  SCREEN_WIDTH  = 1024
  SCREEN_HEIGHT = 768
}

func double abs(double Num) {
  return ?(Num > 0D, Num, -Num)
}

func double Super(double m n1 n2 n3 a b phi) {
  return pow((abs(cos(m*phi/4D)/a)),n2)+pow((abs(pow((sin(m*phi/4D)/b),n3))),(1D / -n1))
}

func Main <entry> {
  double var1 = 3.11D
  double var2 = 9.9D
  double var3 = 1.4D
  double var4 = 3.5D
  double var5 = 0.2D
  double var6 = 1.0D
  double phi
  float r PunktA PunktB
  
  InputDevice.UseKeyboard()
  Screen.Create($SCREEN_WIDTH, $SCREEN_HEIGHT, 32)
  
  while(!Keyboard.isReleased($BTN_ESCAPE)) {
    Screen.FlipBuffers()
    Screen.Clear(0x000000)

    Graphics.StartDraw(Screen)
      Graphics.Text(5,  5,  "выбор фигуры (Q/A): " + str(var1))
      Graphics.Text(5, 25,  "параметры (W/S): " + str(var2))
      Graphics.Text(5, 45,  "          (E/D): " + str(var3))
      Graphics.Text(5, 65,  "          (R/F): " + str(var4))
      Graphics.Text(5, 85,  "          (T/G): " + str(var5))
      Graphics.Text(5, 105, "          (X/C): " + str(var6))
      Graphics.Text(5, 145, " лавиши измен€ют формулу!")
      
      phi = 0D
      while (phi < 360D) {
        r        = float(Super(var1,var2,var3,var4,var5,var6,phi))
        PunktA   =  r*float(cos(phi))*10F + float($SCREEN_WIDTH  / 2)
        PunktB   = -r*float(sin(phi))*10F + float($SCREEN_HEIGHT / 2)
        if (((PunktA > 0F) && (PunktA < float($SCREEN_WIDTH))) && ((PunktB > 0F) && (PunktB < float($SCREEN_HEIGHT)))) {
          Graphics.Plot(int(PunktA),int(PunktB), 0x00FF00)
        }
        phi+= 0.01D
      }
    Graphics.StopDraw()
    
    Keyboard.Examine()
    
    if (Keyboard.isReleased($BTN_Q)) : var1+=0.01D
    if (Keyboard.isReleased($BTN_A)) : var1-=0.01D
    if (Keyboard.isReleased($BTN_W)) : var2+=0.1D
    if (Keyboard.isReleased($BTN_S)) : var2-=0.1D
    if (Keyboard.isReleased($BTN_E)) : var3+=0.1D
    if (Keyboard.isReleased($BTN_D)) : var3-=0.1D
    if (Keyboard.isReleased($BTN_R)) : var4+=0.1D
    if (Keyboard.isReleased($BTN_F)) : var4-=0.1D
    if (Keyboard.isReleased($BTN_T)) : var5+=0.1D
    if (Keyboard.isReleased($BTN_G)) : var5-=0.1D
    if (Keyboard.isReleased($BTN_C)) : var6+=0.1D
    if (Keyboard.isReleased($BTN_X)) : var6-=0.1D
    
  }
}
