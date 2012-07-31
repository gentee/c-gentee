/*******************************************************************************
<fieldsql>
ODBC Library    
<copyright author="Alexander Krivonogov" year=2006 
file="This file is part of the Gentee GUI library."></>
   <description>
Definition of 'win' type.
   </>
</>
*******************************************************************************/
//include { "odbcquery.ge" }
/*extern {

method uint odbcquery.getlongdata( odbcfield f, str val )
}*/
type odbcfield {
   str  name
   str  val
   int  sqlind
   uint sqltype
   uint sqlsize
   uint sqldecdig
   uint vtype
   uint hstmt//query
   uint index
}

type numeric {
  long   val
  uint   scale 
}

type timestamp {
  ushort year      
  ushort month      
  ushort day     
  ushort hour      
  ushort minute      
  ushort second      
  uint   fraction
}

method uint odbcfield.getsqltype()
{
   return this.sqltype  
}

method uint odbcfield.getsqlsize()
{
   return this.sqlsize
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_isnull F3
*
* Summary: Determines if the field contains the NULL value. 
*  
* Return: Returns nonzero, if the field contains the NULL value; otherwise, 
          it returns zero. 
*
-----------------------------------------------------------------------------*/

method uint odbcfield.isnull()
{
   return this.sqlind == -1 
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getdatetime F2
*
* Summary: Gets the field's value as a value of the datetime type. This method
           is applied for fields that contain date and/or time.
*
* Params: dt - Result #a(tdatetime) object.    
*  
* Return: #lng/retpar( dt )  
*
-----------------------------------------------------------------------------*/

method datetime odbcfield.getdatetime( datetime dt )
{
   if this.vtype == datetime 
   {
      uint ts = this.val.ptr()
      ts as timestamp      
      dt.year = ts.year                      
      dt.month = ts.month    
      dt.day = ts.day       
      dt.hour = ts.hour              
      dt.minute = ts.minute                  
      dt.second = ts.second                              
      dt.msec  = ts.fraction / 1000000
      dt.dayofweek = dt.dayofweek()       
   }   
   return dt
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getbuf F2
*
* Summary: Gets the field's value as a value of the buf type (the binary data).
           This method is applied for fields with binary data. 
*
* Params: dest - Result #b(buf) object.     
*  
* Return: #lng/retpar( dest )  
*
-----------------------------------------------------------------------------*/

method buf odbcfield.getbuf( buf dest )
{
   if this.isnull()
   {
      dest.clear()
      return dest//="NULL"
   }
   //if this.sqlind > this.sqlsize
   if this.vtype == buf 
   {  
      //if !*this.val
      {             
         uint newsize
         SQLGetData( this.hstmt, this.index + 1, $SQL_BINARY, this.val.ptr(),
            0, &newsize )               
         this.val->buf.expand( newsize + 1 ) 
         SQLGetData( this.hstmt, this.index + 1, $SQL_BINARY, this.val.ptr(),
            newsize + 1, &newsize )
         this.val.setlen( newsize )
         /*this.val->buf.expand( this.sqlind + 1 ) 
         SQLGetData( this.hstmt, this.index + 1, $SQL_BINARY, this.val.ptr(),
            this.sqlind + 1, &this.sqlind )*/
      }
      dest.copy( this.val->buf.ptr(), this.sqlind );        
   }   
   return dest
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getstr F2
*
* Summary: Get the field's value as a string of the #b(str) type. This method 
           is applied for fields that contain a string, a date, time and 
           numeric fields. 
*
* Params: dest - Result #b(str) object.     
*  
* Return: #lng/retpar( dest )  
*
-----------------------------------------------------------------------------*/

method str odbcfield.getstr( str dest )
{
   if this.isnull(): return dest.clear()//="NULL"
   if this.vtype == str 
   {      
      if !this.sqlsize  
      {         
         //if !*this.val 
         {                   
            uint newsize
            SQLGetData( this.hstmt, this.index + 1, $SQL_CHAR, this.val.ptr(),
               0, &newsize )               
            this.val->buf.expand( newsize + 1 ) 
            SQLGetData( this.hstmt, this.index + 1, $SQL_CHAR, this.val.ptr(),
               newsize + 1, &newsize )
            this.val.setlen( newsize )
         }  
      }
      return dest.copy( this.val.ptr() )
   }
   elif this.vtype == numeric : return dest.copy( this.val.ptr() )
   
   dest.clear()   
   if this.vtype == int : dest@this.val.ptr()->int
   elif this.vtype == long : dest@this.val.ptr()->long    
   elif this.vtype == double : dest@this.val.ptr()->double 
   elif this.vtype == datetime 
   {
      datetime dt
      str d, t      
      this.getdatetime( dt )    
      getdatetime( dt, d, t )      
      dest = d +" "+ t
   }
   return dest
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getint_1 FB
*
* Summary: Gets the field's value as an unsigned integer. This method is 
           applied for fields that contain integers (the storage size is up 
           to 4 bytes). 
*  
* Return: Returns the field's value. 
*
-----------------------------------------------------------------------------*/

method uint odbcfield.getuint()
{
   if this.vtype == int : return this.val.ptr()->uint   
   return 0      
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getint F3
*
* Summary: Gets the field's value as an integer. This method is applied for
           fields that contain integers (the storage size is up to 4 bytes).  
*  
* Return: Returns the field's value. 
*
-----------------------------------------------------------------------------*/

method int odbcfield.getint()
{
   if this.vtype == int : return this.val.ptr()->int   
   return 0
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getlong F3
*
* Summary: Get the field's value as a number of the long type. This method 
           is applied for fields that contain long integers (8 bytes).  
*  
* Return: Returns the field's value. 
*
-----------------------------------------------------------------------------*/

method long odbcfield.getlong()
{
   if this.vtype == long : return this.val.ptr()->long   
   return 0l      
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getlong_1 FB
*
* Summary: Get the field's value as a number of the #b(ulong) type. This 
           method is applied for fields that contain long integers (8 bytes).  
*  
* Return: Returns the field's value. 
*
-----------------------------------------------------------------------------*/

method ulong odbcfield.getulong()
{
   if this.vtype == long : return this.val.ptr()->ulong   
   return 0l      
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getnumeric F2
*
* Summary: Gets the field's value as a fixed point number. This method is
           applied for fields that contain fixed point numbers. The structure 
           is applied for data of this type, as follows: #srcg[ 
|type numeric {
|   long val
|   uint scale 
|}]
           The #b(val) field contains the integer representation of a number,
           and the #b(scale) field indicates how many times val is divided 
           by 10 in order to get a real number (a precision number). 
*
* Params: num - Result numeric structure.    
*  
* Return: #lng/retpar( num )  
*
-----------------------------------------------------------------------------*/

method numeric odbcfield.getnumeric( numeric num )
{
   uint i
   long value
   uint pr = 0, scale = 0, sign = 0
   
   fornum i = 0, $NUMERIC_SIZE
   {      
      if this.val[i]== 0 : break
      if this.val[i]>='0' && this.val[i]<='9'
      {
         value *= 10l
         value += long( this.val[i] & 0x0F )    
         pr++  
      }
      elif this.val[i]=='.'
      {
         scale = pr  
      }
      elif this.val[i]=='-'
      {
         sign = 1
      }         
   }
   if scale : scale = pr - scale
   if sign : value = -value
   num.scale = scale
   num.val = value   
   return num   
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getdouble F3
*
* Summary: Gets the field's value as a floating-point number. This method 
           is applied for fields that contain floating-point numbers.
*  
* Return: Returns the field's value. 
*
-----------------------------------------------------------------------------*/

method double odbcfield.getdouble()
{
   if this.vtype == double : return this.val.ptr()->double
   if this.vtype == int : return double( this.val.ptr()->int )
   if this.vtype == long : return double( this.val.ptr()->long )
   if this.vtype == numeric 
   {
      numeric num
      double value 
      uint i
      
      this.getnumeric( num )
      value = double( num.val )
      fornum i = 0, num.scale: value /= 10d
      return value
   }      
   return 0d     
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_gettype F3
*
* Summary: Gets a type of the field's value. Returns the identifier of one 
           of the following types: 
           #b( 'buf, str, int, long, numeric, double, datetime'). 
*  
* Return: Type identifier.  
*
-----------------------------------------------------------------------------*/

method uint odbcfield.gettype()
{
   return this.vtype
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getname F2
*
* Summary: Gets a field's name. 
*
* Params: result - Result string.     
*  
* Return: #lng/retpar( result )  
*
-----------------------------------------------------------------------------*/

method str odbcfield.getname( str result )
{
   result = this.name
   return result
}

/*-----------------------------------------------------------------------------
* Id: odbcfield_getindex F3
*
* Summary: Gets the field index number.
*  
* Return: Field index number. 
*
-----------------------------------------------------------------------------*/

method uint odbcfield.getindex()
{
   return this.index
}
