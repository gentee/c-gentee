import "Sound.dll" {
  int Sound_Init()
  int Sound_Catch(int)
  Sound_Free(int)
  int Sound_Exist(int)
  int Sound_Load(int)
  Sound_Play(int,int)
  Sound_SetFrequency(int,int)
  Sound_SetPan(int,int)
  Sound_SetVolume(int,int)
  Sound_Stop(int)
}

include {
  "defines.g"
}

type Sound     <inherit = GAPI_Object>{
  int Freq
  int Vol
  int Pan
}

func SoundInitialize <entry> {
  Sound_Init()
}

method int Sound.Catch(int Mem){
  this.Freq = -1
  this.Pan  = 0
  this.Vol  = 100
  this.id = Sound_Catch(Mem)
  return this.id
}
method Sound.Free(){
  Sound_Free(this.id)
}
property int Sound.Exist{
  return Sound_Exist(this.id)
}
method int Sound.Load(str FileName){
  this.Freq = -1
  this.Pan  = 0
  this.Vol  = 100
  return Sound_Load(FileName.ptr())
}
method Sound.Play(){
  Sound_Play(this.id,0)
}
method Sound.PlayLoop(){
  Sound_Play(this.id,1)
}
property int Sound.Frequency{
  return this.Freq
}
property Sound.Frequency(int f){
  Sound_SetFrequency(this.id,f)
}
property int Sound.Pan{
  return this.Pan
}
property Sound.Pan(int p){
  Sound_SetPan(this.id,p)
}
property int Sound.Volume{
  return this.Vol
}
property Sound.Volume(int v){
  Sound_SetVolume(this.id,v)
}
method Sound.Stop(){
  Sound_Stop(this.id)
}
