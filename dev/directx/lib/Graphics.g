include {
  "GraphicsImports.g"
  "defines.g"
  "Font.g"
  "Screen.g"
  "Sprites.g"
  "Sprites3D.g"
  "Image.g"
}

define <export> {
  GRAPHICS_MODE_DEFAULT     = 0
  GRAPHICS_MODE_TRANSPARENT = 1
  GRAPHICS_MODE_XOR         = 2
  GRAPHICS_MODE_OUTLINED    = 4

  PIXELFORMAT_8BITS       = 1 //1 bytes per pixel, palletized
  PIXELFORMAT_15BITS      = 2 //2 bytes per pixel
  PIXELFORMAT_16BITS      = 3 //2 bytes per pixel
  PIXELFORMAT_24BITS_RGB  = 4 //3 bytes per pixel (RRGGBB)
  PIXELFORMAT_24BITS_BGR  = 5 //3 bytes per pixel (BBGGRR)
  PIXELFORMAT_32BITS_RGB  = 6 //4 bytes per pixel (RRGGBB)
  PIXELFORMAT_32BITS_BGR  = 7 //4 bytes per pixel (BBGGRR)
}

type TGraphics <inherit = GAPI_Object>:

global {
  int GE_FrontColor GE_BackColor
  Font GE_Graphics_Font
  int GE_Graphics_Mode
  TGraphics Graphics
}

property int TGraphics.BackColor{
  return GE_BackColor
}
property TGraphics.BackColor(int RGB){
  GE_BackColor = RGB
  g2d_BackColor(RGB)
}
property int TGraphics.FrontColor{
  return GE_FrontColor
}
property TGraphics.FrontColor(int RGB){
  GE_FrontColor = RGB
  g2d_FrontColor(RGB)
}
method TGraphics.Box(int x y width height){
  g2d_Box(x,y,width,height,this.FrontColor)
}
method TGraphics.Box(int x y width height RGB){
  g2d_Box(x,y,width,height,RGB)
}
method TGraphics.Box(int x y width height R G B){
  g2d_Box(x,y,width,height,(R<<16) + (G<<8) + B)
}
method TGraphics.Circle(int x y R){
  g2d_Circle(x,y,R,this.FrontColor)
}
method TGraphics.Circle(int x y R RGB){
  g2d_Circle(x,y,R,RGB)
}
method TGraphics.Circle(int x y R cR cG cB){
  g2d_Circle(x,y,R,(cR<<16) + (cG<<8) + cB)
}
method int TGraphics.getBuffer(){
  return g2d_GetBuffer()
}
method int TGraphics.getBufferPitch(){
  return g2d_GetBufferPitch()
}
method int TGraphics.getBufferPixelFormat(){
  return g2d_GetBufferPixelFormat()
}
property Font TGraphics.DrawFont{
  return GE_Graphics_Font
}
property TGraphics.DrawFont(Font f){
  GE_Graphics_Font = f
  g2d_SetFont(f.Handle)
}
property int TGraphics.Mode{
  return GE_Graphics_Mode
}
property TGraphics.Mode(int Mode){
  GE_Graphics_Mode = Mode
  g2d_SetMode(Mode)
}
method TGraphics.Ellipse(int x y RadiusX RadiusY){
  g2d_Ellipse(x,y,RadiusX,RadiusY,this.FrontColor)
}
method TGraphics.Ellipse(int x y RadiusX RadiusY RGB){
  g2d_Ellipse(x,y,RadiusX,RadiusY,RGB)
}
method TGraphics.Ellipse(int x y RadiusX RadiusY R G B){
  g2d_Ellipse(x,y,RadiusX,RadiusY,(R<<16) + (G<<8) + B)
}
method TGraphics.FillArea(int x y OutlineColor){
  g2d_FillArea(x,y,OutlineColor,this.FrontColor)
}
method TGraphics.FillArea(int x y OutlineColor RGB){
  g2d_FillArea(x,y,OutlineColor,RGB)
}
method TGraphics.Line(int x y width height){
  g2d_Line(x,y,width,height,this.FrontColor)
}
method TGraphics.Line(int x y width height RGB){
  g2d_Line(x,y,width,height,RGB)
}
method TGraphics.Line(int x y width height R G B){
  g2d_Line(x,y,width,height,(R<<16) + (G<<8) + B)
}
method TGraphics.LineXY(int x1 y1 x2 y2){
  g2d_LineXY(x1,y1,x2,y2,this.FrontColor)
}
method TGraphics.LineXY(int x1 y1 x2 y2 RGB){
  g2d_LineXY(x1,y1,x2,y2,RGB)
}
method TGraphics.LineXY(int x1 y1 x2 y2 R G B){
  g2d_LineXY(x1,y1,x2,y2,(R<<16) + (G<<8) + B)
}
method TGraphics.Plot(int x y){
  g2d_Plot(x,y,this.FrontColor)
}
method TGraphics.Plot(int x y RGB){
  g2d_Plot(x,y,RGB)
}
method TGraphics.Plot(int x y R G B){
  g2d_Plot(x,y,(R<<16) + (G<<8) + B)
}
method int TGraphics.getColor(int x y){
  return g2d_GetColor(x,y)
}
method TGraphics.Text(int x y, str Text){
  g2d_DrawText(x,y,Text.ptr(),this.FrontColor,this.BackColor)
}
method TGraphics.Text(int x y, str Text, int FrontColor){
  g2d_DrawText(x,y,Text.ptr(),FrontColor,this.BackColor)
}
method TGraphics.Text(int x y, str Text, int FrontColor BackColor){
  g2d_DrawText(x,y,Text.ptr(),FrontColor,BackColor)
}
method int TGraphics.TextWidth(str Text){
  return g2d_GetTextWidth(Text.ptr())
}
method int TGraphics.TextHeight(str Text){
  return g2d_GetTextHeight(Text.ptr())
}
method TGraphics.StopDraw(){
  g2d_StopDrawing()
}
method int TGraphics.StartDraw(TScreen Output){
  this.FrontColor = 0xFFFFFF
  this.BackColor  = 0x000000
  return g2d_StartDrawing(Output.Canvas)
}
method int TGraphics.StartDraw(Sprite2D Output){
  this.FrontColor = 0xFFFFFF
  this.BackColor  = 0x000000
  return g2d_StartDrawing(Output.Canvas)
}
method int TGraphics.StartDraw(Image Output){
  this.FrontColor = 0xFFFFFF
  this.BackColor  = 0x000000
  return g2d_StartDrawing(Output.Canvas)
}

func GraphicsEntryPoint <entry> {
  if (Sprite2D_Init() && Sprite3D_Init()){
    Sprite3D_SetQuality($SPRITE3D_BILINEAR)
  }
  else {
    GraphicsEntryPoint()
  }
}


