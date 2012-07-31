define <export> {
  SPRITE3D_NOFILTER = 0
  SPRITE3D_BILINEAR = 1

  D3DBLEND_ZERO            = 1
  D3DBLEND_ONE             = 2
  D3DBLEND_SRCCOLOR        = 3
  D3DBLEND_INVSRCCOLOR     = 4
  D3DBLEND_SRCALPHA        = 5
  D3DBLEND_INVSRCALPHA     = 6
  D3DBLEND_DESTALPHA       = 7
  D3DBLEND_INVDESTALPHA    = 8
  D3DBLEND_DESTCOLOR       = 9
  D3DBLEND_INVDESTCOLOR    = 10
  D3DBLEND_SRCALPHASAT     = 11
  D3DBLEND_BOTHSRCALPHA    = 12
  D3DBLEND_BOTHINVSRCALPHA = 13
}

type Sprite3D  <inherit = GAPI_Object>:

global {
  int GE_Sprite3DQuality = $SPRITE3D_BILINEAR
}

operator Sprite3D = (Sprite3D left, int right){ //создание объекта Sprite3D по хэнделу спрайта
  left.id = right
  return left
}
method int Sprite3D.Create(Sprite2D Sprite){
  this.id = Sprite3D_Create(Sprite.id)
  return this.id
}
method Sprite3D.Show(int x y){
  Sprite3D_Display(this.id,x,y,255)
}
method Sprite3D.Show(int x y transparent){
  Sprite3D_Display(this.id,x,y,transparent)
}
method Sprite3D.Free(){
  Sprite3D_Free(this.id)
}
property int Sprite3D.Exist{
  return Sprite3D_Exist(this.id)
}
method Sprite3D.Rotate(int Angle){
  Sprite3D_Rotate(this.id,Angle,0)
}
method Sprite3D.Rotate(int Angle Mode){
  Sprite3D_Rotate(this.id,Angle,Mode)
}
method Sprite3D.Transform(int x1 y1 z1 x2 y2 z2 x3 y3 z3 x4 y4 z4){
  Sprite3D_Transform(this.id,x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
}
method Sprite3D.Zoom(int width height){
  Sprite3D_Zoom(this.id,width,height)
}
property int TScreen.Sprite3DQuality{
  return GE_Sprite3DQuality
}
property TScreen.Sprite3DQuality(int q){
  Sprite3D_SetQuality(q)
}
method TScreen.Start3D(){
  Sprite3D_Start3D()
}
method TScreen.Stop3D(){
  Sprite3D_Stop3D()
}
method TScreen.setSprite3DBlendMode(int SourceMode DestinationMode){
  Sprite3D_BlendingMode(SourceMode, DestinationMode)
}
