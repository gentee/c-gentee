define <export> {
  IMAGE_DEPTH_AS_DESKTOP = 128
  IMAGE_FORMAT_BMP       = 0
  IMAGE_FORMAT_JPG       = 1195724874
}

type Image          <inherit = GAPI_Object>:

operator Image = (Image left right){
  left.id = right.id
  return left
}

method int Image.Catch(int Mem){
  this.id = Image_Catch(Mem)
  return this.id
}
method int Image.Catch(int Mem Length){
  this.id = Image_CatchEx(Mem,Length)
  return this.id
}
method Image Image.Dublicate(){
  Image i
  i.id = Image_Copy(this.id)
  return i
}
method int Image.Create(int Width Height){
  this.id = Image_Create(Width, Height, $IMAGE_DEPTH_AS_DESKTOP)
  return this.id
}
method int Image.Create(int Width Height Depth){
  this.id = Image_Create(Width, Height, Depth)
  return this.id
}
method Image.Free(){
  Image_Free(this.id)
}
property int Image.Depth{
  return Image_GetDepth(this.id)
}
property int Image.Width{
  return Image_GetWidth(this.id)
}
property Image.Width(int width){
  Image_Resize(this.id,width,Image_GetHeight(this.id))
}
property int Image.Height{
  return Image_GetHeight(this.id)
}
property Image.Height(int height){
  Image_Resize(this.id,Image_GetWidth(this.id),height)
}
property int Image.Exist{
  return Image_Exist(this.id)
}
method Image.Grab(Image Source, int x y){
  if this.Exist : this.Free() :
  this.id = Image_Grab(Source.id,x,y,Source.Width,Source.Height)
}
method Image.Grab(Image Source, int x y width){
  if this.Exist : this.Free() :
  this.id = Image_Grab(Source.id,x,y,width,Source.Height)
}
method Image.Grab(Image Source, int x y width height){
  if this.Exist : this.Free() :
  this.id = Image_Grab(Source.id,x,y,width,height)
}
property int Image.Handle{
  return Image_GetHandle(this.id)
}
property int Image.Canvas{
  return Image_GetOutput(this.id)
}
method Image.Load(str FileName){
  this.id = Image_Load(FileName.ptr())
}
method Image.Load(str FileName,int Flags){
  this.id = Image_LoadEx(FileName.ptr(),Flags)
}
method Image.Resize(int width height){
  Image_Resize(this.id,width,height)
}
method int Image.Save(str FileName, int Format){
  return Image_Save(this.id,FileName.ptr(),Format,10)
}
method int Image.SaveBMP(str FileName){
  return Image_Save(this.id,FileName.ptr(),$IMAGE_FORMAT_BMP,0)
}
method int Image.SaveJPG(str FileName){
  return Image_Save(this.id,FileName.ptr(),$IMAGE_FORMAT_JPG,10)
}
method int Image.SaveJPG(str FileName, int Quality){
  return Image_Save(this.id,FileName.ptr(),$IMAGE_FORMAT_JPG,Quality)
}
method Image.DrawAlpha(int x y){
  g2d_DrawAlphaImage(this.Handle,x,y)
}
method Image.Draw(int x y){
  g2d_DrawImage(this.Handle,x,y,this.Width,this.Height)
}
method Image.Draw(int x y width height){
  g2d_DrawImage(this.Handle,x,y,width,height)
}
