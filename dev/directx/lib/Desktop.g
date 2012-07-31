import "Desktop.dll" {
  int Desktop_Depth(int)
  int Desktop_Width(int)
  int Desktop_Height(int)
  int Desktop_Frequency(int)
  int Desktop_MouseX()
  int Desktop_MouseY()
  int Desktop_Examine()
  int Desktop_Name(int)
}

include {
  "defines.g"
}

type TDesktop <inherit = GAPI_Object>:

global {
  TDesktop Desktop
}

property int TDesktop.Depth{
  return Desktop_Depth(0)
}
property int TDesktop.Width{
  return Desktop_Width(0)
}
property int TDesktop.Height{
  return Desktop_Height(0)
}
property int TDesktop.MouseX{
  return Desktop_MouseX()
}
property int TDesktop.MouseY{
  return Desktop_MouseY()
}
method str TDesktop.getName(int id){
  str s
  s.copy(Desktop_Name(id))
  return s
}
method TDesktop.Examine() {
  Desktop_Examine()
}

