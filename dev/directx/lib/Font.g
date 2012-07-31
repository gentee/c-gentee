
define <export> {
  FONT_BOLD        = 256
  FONT_ITALIC      = 512
  FONT_UNDERLINE   = 4
  FONT_STRIKEOUT   = 8
  FONT_HIGHQUALITY = 16
}

type Font      <inherit = GAPI_Object>{
  str  tName
  int  tSize
  byte tBold
  byte tItalic
  byte tUnderline
  byte tStrikeOut
  byte tHighQuality
}

operator Font = (Font left right){
  left.id           = right.id
  left.tBold        = right.tBold
  left.tItalic      = right.tItalic
  left.tUnderline   = right.tUnderline
  left.tStrikeOut   = right.tStrikeOut
  left.tHighQuality = right.tHighQuality
  return left
}

property int Font.Handle{
  return Font_GetHandle(this.id)
}
method Font.Free(){
  Font_Free(this.id)
  this.tName        = ""
  this.tBold        = $false
  this.tItalic      = $false
  this.tUnderline   = $false
  this.tStrikeOut   = $false
  this.tHighQuality = $false
}
property int Font.Exist{
  return Font_Exist(this.id)
}
method int Font.Create(str Name, int Size){
  this.id = Font_Load(Name.ptr(),Size)
  return this.id
}
method int Font.Create(str Name, int Size Flags){
  this.id = Font_LoadEx(Name.ptr(),Size,Flags)
  return this.id
}
property int Font.Properties{
  int p = 0
  p = ?(this.tBold,       p ^ $FONT_BOLD,       p)
  p = ?(this.tItalic,     p ^ $FONT_ITALIC,     p)
  p = ?(this.tUnderline,  p ^ $FONT_UNDERLINE,  p)
  p = ?(this.tStrikeOut,  p ^ $FONT_STRIKEOUT,  p)
  p = ?(this.tHighQuality,p ^ $FONT_HIGHQUALITY,p)
  return p
}
property Font.Properties(int p){
  this.tBold        = ?((p & $FONT_BOLD)       ==$FONT_BOLD,       $true,$false)
  this.tItalic      = ?((p & $FONT_ITALIC)     ==$FONT_ITALIC,     $true,$false)
  this.tUnderline   = ?((p & $FONT_UNDERLINE)  ==$FONT_UNDERLINE,  $true,$false)
  this.tStrikeOut   = ?((p & $FONT_STRIKEOUT)  ==$FONT_STRIKEOUT,  $true,$false)
  this.tHighQuality = ?((p & $FONT_HIGHQUALITY)==$FONT_HIGHQUALITY,$true,$false)
  Font_Free(this.id)
  this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
}
property int Font.Bold{
  return this.tBold
}
property Font.Bold(int state){
  int p
  if (this.tBold + state) == 1{
    p = this.Properties
    p = ?(state,p ^ $FONT_BOLD,p & $FONT_BOLD)
    Font_Free(this.id)
    this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
  }
}
property int Font.Italic{
  return this.tItalic
}
property Font.Italic(int state){
  int p
  if (this.tItalic + state) == 1{
    p = this.Properties
    p = ?(state,p ^ $FONT_ITALIC,p & $FONT_ITALIC)
    Font_Free(this.id)
    this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
  }
}
property int Font.Underline{
  return this.tUnderline
}
property Font.Underline(int state){
  int p
  if (this.Underline + state) == 1{
    p = this.Properties
    p = ?(state,p ^ $FONT_UNDERLINE,p & $FONT_UNDERLINE)
    Font_Free(this.id)
    this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
  }
}
property int Font.StrikeOut{
  return this.tStrikeOut
}
property Font.StrikeOut(int state){
  int p
  if (this.tStrikeOut + state) == 1{
    p = this.Properties
    p = ?(state,p ^ $FONT_STRIKEOUT,p & $FONT_STRIKEOUT)
    Font_Free(this.id)
    this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
  }
}
property int Font.HighQuality{
  return this.tHighQuality
}
property Font.HighQuality(int state){
  int p
  if (this.tHighQuality + state) == 1{
    p = this.Properties
    p = ?(state,p ^ $FONT_HIGHQUALITY,p & $FONT_HIGHQUALITY)
    Font_Free(this.id)
    this.id = Font_LoadEx(this.tName.ptr(),this.tSize,this.Properties)
  }
}
