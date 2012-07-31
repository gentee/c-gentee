//Color
func int RGB2BGR(int RGB){
  return (RGB & 0xFF)<<16 + ((RGB >> 8 & 0xFF)<<8) + (RGB>>16)
}
func int getRed(int RGB){
  return RGB >> 16
}
func int getGreen(int RGB){
  return RGB >> 8 & 0xFF
}
func int getBlue(int RGB){
  return RGB & 0xFF
}
func int RGB(int R G B){
  return (R<<16) + (G<<8) + B
}
