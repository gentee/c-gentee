include
{
 "bool.g"
}

import "io.dll"
{
 PortOut(uint,uint)
 PortWordOut(uint,uint)
 PortDWordOut(uint,uint)
 uint PortIn(uint)
 uint PortWordIn(uint)
 uint PortDWordIn(uint)
 SetPortBit(uint,uint)
 ClrPortBit(uint,uint)
 NotPortBit(uint,uint)
 uint GetPortBit(uint,uint)
 uint IsDriverInstalled()
 uint LeftPortShift(uint,uint)
 uint RightPortShift(uint,uint)
}


func Bool IsDriverInstall()
{
  Bool bRes;
  bRes.value = IsDriverInstalled();   
  return bRes;
} 

func io_PortOut (short Port,sbyte value) : PortOut(Port,value);
func io_PortWopdOut (short Port,short value) : PortWordOut(Port,value);
func io_PortDWopdOut (short Port,int value) : PortDWordOut(Port,value);
func sbyte io_PortIn (short Port) : return PortIn(Port);
func short io_PortWordIn (short Port) : return PortWordIn(Port);
func int io_PortDWordIn (short Port) : return PortDWordIn(Port);
func io_SetPortBit(short Port,sbyte value) : SetPortBit(Port,value);
func io_ClrPortBit(short Port,sbyte value) : ClrPortBit(Port,value);
func io_NotPortBit(short Port,sbyte value) : NotPortBit(Port,value);
func io_GetPortBit(short Port,sbyte value) : GetPortBit(Port,value);
func short io_LeftPortShift(short Port,sbyte value) : return LeftPortShift(Port,value);
func short io_RightPortShift(short Port,sbyte value) : return RightPortShift(Port,value);