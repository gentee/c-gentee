define <export> {
  //Sprite2D
  SPRITE2D_SYSTEMRAM     = 1
  SPRITE2D_ALPHA         = 2
  SPRITE2D_TEXTURE       = 4
  SPRITE2D_ALPHABLENDING = 8
}

type Sprite2D  <inherit = GAPI_Object>{
  int iTransparentColor
}

global {
  int GAPI_Sprite2DTransparent = 0x000000
}

operator Sprite2D = (Sprite2D left, int right){ //создание объекта Sprite2D по хэнделу спрайта
  left.id = right
  return left
}

method int Sprite2D.Catch(int Mem){
  this.id = Sprite2D_Catch(Mem,0)
  return this.id
}
method int Sprite2D.Catch(int Mem Mode){
  this.id = Sprite2D_Catch(Mem,Mode)
  return this.id
}
method int Sprite2D.UnClip(){
  return Sprite2D_Clip(this.id,-1,-1,-1,-1)
}
method int Sprite2D.Clip(int x){
  return Sprite2D_Clip(this.id,x,-1,-1,-1)
}
method int Sprite2D.Clip(int x y){
  return Sprite2D_Clip(this.id,x,y,-1,-1)
}
method int Sprite2D.Clip(int x y width){
  return Sprite2D_Clip(this.id,x,y,width,-1)
}
method int Sprite2D.Clip(int x y width height){
  return Sprite2D_Clip(this.id,x,y,width,height)
}
method int Sprite2D.Dublicate(){
  return Sprite2D_Copy(this.id,0)
}
method int Sprite2D.Dublicate(int Mode){
  return Sprite2D_Copy(this.id,Mode)
}
method int Sprite2D.Create(int width height){
  this.id = Sprite2D_Create(width,height,0)
  return this.id
}
method int Sprite2D.Create(int width height Mode){
  this.id = Sprite2D_Create(width,height,Mode)
  return this.id
}
method Sprite2D.Show(int x y){
  Sprite2D_Display(this.id,x,y)
}
method Sprite2D.ShowAsAlpha(int x y){
  Sprite2D_DisplayAlpha(this.id,x,y)
}
method Sprite2D.ShowShadow(int x y){
  Sprite2D_DisplayShadow(this.id,x,y)
}
method Sprite2D.ShowSolid(int x y RGB){
  Sprite2D_DisplaySolid(this.id,x,y,RGB)
}
method Sprite2D.ShowSolid(int x y R G B){
  Sprite2D_DisplaySolid(this.id,x,y,(R<<16) + (G<<8) + B)
}
method Sprite2D.ShowAlphaBlend(int x y Intensity){
  Sprite2D_DisplayTranslucent(this.id,x,y,Intensity)
}
method Sprite2D.DisplayAsTransparent(int x y){
  Sprite2D_DisplayTransparent(this.id,x,y)
}
method Sprite2D.Free(){
  Sprite2D_Free(this.id)
  this.iTransparentColor = GAPI_Sprite2DTransparent
}
property int Sprite2D.Exist{
  return Sprite2D_Exist(this.id)
}
method int Sprite2D.Load(str FileName){
  this.id = Sprite2D_Load(FileName.ptr(),0)
  return this.id
}
method int Sprite2D.Load(str FileName,int Mode){
  this.id = Sprite2D_Load(FileName.ptr(),Mode)
  return this.id
}
func int Sprite2DCollision(Sprite2D Sprite1, int x1 y1, Sprite2D Sprite2, int x2 y2){
  return Sprite2D_Collision(Sprite1.id,x1,y1,Sprite2.id,x2,y2)
}
func int Sprite2DPixelCollision(Sprite2D Sprite1, int x1 y1, Sprite2D Sprite2, int x2 y2){
  return Sprite2D_PixelCollision(Sprite1.id, x1, y1, Sprite2.id, x2, y2)
}
property int Sprite2D.Depth{
  return Sprite2D_GetDepth(this.id)
}
property int Sprite2D.Height{
  return Sprite2D_GetHeight(this.id)
}
property int Sprite2D.Width{
  return Sprite2D_GetWidth(this.id)
}
property int Sprite2D.Handle{
  return Sprite2D_GetHandle(this.id)
}
func Sprite2DTransparenColor(int RGB){
  Sprite2D_SetTransparentColor(-1,RGB)
}
func Sprite2DTransparenColor(int R G B){
  Sprite2D_SetTransparentColor(-1,(R<<16) + (G<<8) + B)
}
method Sprite2D.setTransparentColor(int RGB){
  this.iTransparentColor = RGB
  Sprite2D_SetTransparentColor(this.id,RGB)
}
method Sprite2D.setTransparentColor(int R G B){
  int rgb = (R<<16) + (G<<8) + B
  this.iTransparentColor = rgb
  Sprite2D_SetTransparentColor(this.id,rgb)
}
property Sprite2D.TransparentColor(int RGB){
  this.iTransparentColor = RGB
  Sprite2D_SetTransparentColor(this.id,RGB)
}
property int Sprite2D.TransparentColor{
  return this.TransparentColor
}
method Sprite2D.AsBuffer{
  Sprite2D_UseBuffer(this.id)
}
property int Sprite2D.Canvas{
  return Sprite2D_GetOutput(this.id)
}

method TScreen.AlphaIntensity(int RGB){
  Sprite2D_ChangeAlphaIntensity(RGB >> 16,RGB >> 8 & 0xFF,RGB & 0xFF)
}
method TScreen.setAlphaIntensity(int RGB){
  Sprite2D_ChangeAlphaIntensity(RGB >> 16,RGB >> 8 & 0xFF,RGB & 0xFF)
}
method TScreen.setAlphaIntensity(int R G B){
  Sprite2D_ChangeAlphaIntensity(R,G,B)
}
method int TScreen.Grab(int x y width height){
  return Sprite2D_Grab(x,y,width,height,0)
}
method int TScreen.Grab(int x y width height Mode){
  return Sprite2D_Grab(x,y,width,height,Mode)
}

method TScreen.AsSprite2D(Sprite2D Sprite){
  Sprite2D_UseBuffer(Sprite.id)
}
method TScreen.AsNormal(){
  Sprite2D_UseBuffer(-1)
}

