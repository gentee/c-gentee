define
{
  TRUE  = 1
  FALSE = 0
}

type Bool
{
  byte data;
}

private
method Bool.Init()
{
  this.data = $FALSE;
} 

public
property Bool.value(byte bData): this.data=bData
property byte Bool.value(): return this.data

operator Bool = (Bool bLeft, byte bData)
{
 if (bData == $TRUE || bData == $FALSE)
 {
  bLeft.data = bData;
 }
 return bLeft;
} 


