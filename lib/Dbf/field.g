/*-----------------------------------------------------------------------------
* Id: dbf_f_count F3
* 
* Summary: Number of fields.
*  
* Return: Returns the number of fields. 
*
-----------------------------------------------------------------------------*/

method uint dbf.f_count()
{
   return *this.fields
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_decimal F2
* 
* Summary: Getting the size of the fractional part in a numerical field. 
*  
* Params: num - Field number beginning with 1. 
*
* Return: The size of the fractional part.
*
-----------------------------------------------------------------------------*/

method uint dbf.f_decimal( uint num )
{
   return this.fields[ num - 1 ].decimals
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_name F2
* 
* Summary: Get the name of the specified field. 
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the name of the specified field.
*
-----------------------------------------------------------------------------*/

method str  dbf.f_name( uint num )
{
   return this.fields[ num - 1 ].name
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_width F2
* 
* Summary: Get the width of the specified field. 
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the width of the field.
*
-----------------------------------------------------------------------------*/

method uint dbf.f_width( uint num )
{
   return this.fields[ num - 1 ].width
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_find F2
* 
* Summary: Getting the number of a field by its name. 
*  
* Params: name - The name of the field. 
*
* Return: The number of the field with the specified name or
          0 in case of an error.
*
-----------------------------------------------------------------------------*/

method uint dbf.f_find( str name )
{
   uint i
   
   fornum i, *this.fields
   {
      if name %== this.fields[ i ].name : return i + 1
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_offset F2
* 
* Summary: Get the offset of the field. 
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the offset of this field.
*
-----------------------------------------------------------------------------*/

method uint dbf.f_offset( uint num )
{
   return this.fields[ num - 1 ].offset
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_type F2
* 
* Summary: Get the field type. 
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the type of this field. It can be one of the following 
          values. $$[dbftypes]
*
-----------------------------------------------------------------------------*/

method uint dbf.f_type( uint num )
{
   return this.fields[ num - 1 ].ftype
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_ptr F2
* 
* Summary: Pointer to data. Get the pointer to the contents of this field 
           from the current record. 
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the pointer to this field.
*
-----------------------------------------------------------------------------*/

method uint dbf.f_ptr( uint num )
{
   return this.ptr + this.fields[ num - 1 ].offset
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_str F2
* 
* Summary: Getting a value. Get the value of the field from the current 
           record as a string. 
*  
* Params: val - The string for getting the value.  
          num - Field number beginning with 1.  
*
* Return: #lng/retpar( val )
*
-----------------------------------------------------------------------------*/

method str  dbf.f_str( str val, uint num )
{
   uint  width = this.fields[ num - 1 ].width
   
   val.reserve( width )
   val.copy( this.f_ptr( num ), width )
//   val.setlen( width )   
   return val.trimrspace()
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_logic F2
* 
* Summary: Getting a logical value. Get the value of the logical field from 
           the current record.
*  
* Params: num - Field number beginning with 1.  
*
* Return: Returns the value of the logical field.$$[dbflogic]
*
-----------------------------------------------------------------------------*/

method uint dbf.f_logic( uint num )
{
   uint val = this.f_ptr( num )->byte
   
   switch val 
   {
      case 'Y', 'y', 'T', 't' : return $DBF_LTRUE
      case 'N', 'n', 'F', 'f' : return $DBF_LFALSE
   }
   return $DBF_LUNKNOWN
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_date F2
* 
* Summary: Getting a date. Getting the date from the specified field of the
           current record into the structure #a(tdatetime).
*  
* Params:  dt - The structure for getting the date. 
           num - Field number beginning with 1.  
*
* Return: #lng/retpar(dt)
*
-----------------------------------------------------------------------------*/

method datetime dbf.f_date( datetime dt, uint num )
{
//   mzero( &dt, sizeof( datetime ))
   str   st
   str   stemp 
   uint  cur
   
   this.f_str( st, num )
   
   stemp.substr( st, 6, 2 )
   dt.day = stemp.int()//str2int( stemp )
   stemp.substr( st, 4, 2 )
   dt.month = stemp.int()//str2int( stemp )
   st.setlen( 4 )
   dt.year = st.int()//str2int( st )
   
   return dt      
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_date_1 FA
* 
* Summary: Getting the date from the specified field of the current record as 
           a string. 
*  
* Params:  val - The string for getting the date.  
           num - Field number beginning with 1.  
*
* Return: #lng/retpar(val)
*
-----------------------------------------------------------------------------*/

method str dbf.f_date( str val, uint num )
{
   datetime  dt
   
   this.f_date( dt, num )
   getdatetime( dt, val, 0->str )
   return val      
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_double F2
* 
* Summary: Getting a numerical value. Get a numerical value of the double 
           type from the specified field of the current record.  
*  
* Params:  num - Field number beginning with 1.  
*
* Return: A value of the double type.
*
-----------------------------------------------------------------------------*/

method double  dbf.f_double( uint num )
{
   str val
   
   this.f_str( val, num ).trimspace()
   return double( val )
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_int F2
* 
* Summary: Getting an integer value. Get a numerical value of the int type 
           from the specified field of the current record.  
*  
* Params:  num - Field number beginning with 1.  
*
* Return: A number of the int type is returned.
*
-----------------------------------------------------------------------------*/

method int  dbf.f_int( uint num )
{
   str val
   
   this.f_str( val, num ).trimspace()
   return int( val )
}

/*-----------------------------------------------------------------------------
* Id: dbf_f_memo F2
* 
* Summary: Get the value of a memo field. Get the value of the memo field from
           the current record. 
*  
* Params:  val - The string for writing the value.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint dbf.f_memo( str val, uint num )
{
   uint  id = this.f_int( num )
   uint  pos
   
   val.clear()
   if  this.f_type( num ) != $DBFF_MEMO || !id : return 1
   
   pos = id * this.mblock
   if this.dbtfile.setpos( pos, $FILE_BEGIN ) != pos
   {
      return this.error( $ERRDBT_POS )
   }
   
   val->buf.use = 0
   uint i

   if this.head.version == 0x83    // dBase III
   {
      uint prev
      
      while this.dbtfile.read( val->buf, this.mblock )
      {
         fornum i = prev, *val->buf
         {
            if val->buf[i] == 0x1A && val->buf[i + 1] == 0x1A
            {
               break
            }
         }
         prev = *val->buf
         if i < *val->buf : break
      }
   }
   else   // 0x8B   dBase IV
   {
      this.dbtfile.read( val->buf, this.mblock )
      i = ( val.ptr() + 4 )->uint
      val->buf.del( 0, 8 )
      if i > this.mblock
      {
         if this.dbtfile.read( val->buf, i - this.mblock ) != i - this.mblock
         {
            return this.error( $ERRDBT_READ )
         }
      }
      i -= 8
   }  
   val->buf[i] = 0
   val.setlenptr()
   return 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_fw_str F2
* 
* Summary: Writing a value. Write a value into the specified field of 
           the current record.  
*  
* Params:  val - The string being written.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method  uint dbf.fw_str( str val, uint num )
{
   fordata fd 
   if this.eof( fd ) : return this.error( $ERRDBF_EOF )

   uint  width = this.f_width( num )

   if *val > width 
   {
      return this.error( $ERRDBF_FOVER )            
   }
   
   uint  pos = this.head.header_len + 
                     this.cur * this.head.record_width + this.f_offset( num )
   uint  off = this.ptr + this.f_offset( num ) - this.page.data
   
   if this.f_type( num ) == $DBFF_CHAR
   {
      val.fillspacer( width )
   }
   else : val.fillspacel( width )
   
   mcopy( this.page.ptr() + off, val.ptr(), width )   
   //if !this.page.write( this.dbffile, pos, off, width )
   if !this.dbffile.writepos( pos, this.page.ptr() + off, width )
   {
      return this.error( $ERRDBF_WRITE )
   }
   if this.getdate()
   {
      uint size
      
      /*setpos( this.dbffile, 1, $FILE_BEGIN )
      // Записываем дату и количество записей
      WriteFile( this.dbffile, &this.head.yy, 3, &size, 0 )*/
      this.dbffile.writepos( 1, &this.head.yy, 3 ) 
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_fw_logic F2
* 
* Summary: Writing a logical value. Write a logical value into the specified
           field of the current record.
*  
* Params:  val - Number 1 or 0.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method  uint dbf.fw_logic( uint val, uint num )
{
   return this.fw_str( ?( val, "T", "F" ), num  )
}

/*-----------------------------------------------------------------------------
* Id: dbf_fw_date F2
* 
* Summary: Writing a date. Write a date into the specified field of the 
           current record.
*  
* Params:  dt - The structure #a(tdatetime) containing the date.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method  uint dbf.fw_date( datetime dt, uint num )
{
   str val 
   
   val += dt.year
   //int2str( val, "%02i", dt.month )
   //int2str( val, "%02i", dt.day )
   val.out4( "%02i", dt.month )
   val.out4( "%02i", dt.day )
   return this.fw_str(  val, num  )
}

/*-----------------------------------------------------------------------------
* Id: dbf_fw_double F2
* 
* Summary: Writing a numerical value. Write a numerical value into the 
           specified field of the current record.
*  
* Params:  dval - The number being written.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method  uint dbf.fw_double( double dval, uint num )
{
   str   val
   uint  width = this.f_width( num )
   
   //double2str( val, "%\(width).\(this.f_decimal( num ))f", dval )
   val.out8( "%\(width).\(this.f_decimal( num ))f", (&dval)->ulong )

   return this.fw_str(  val, num  )
}

/*-----------------------------------------------------------------------------
* Id: dbf_fw_int F2
* 
* Summary: Writing an integer value. Write a value of the int type into 
           the specified field of the current record. 
*  
* Params:  ival - The number being written.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method  uint dbf.fw_int( int ival, uint num )
{
   str   val
   uint  width = this.f_decimal( num )
   
   val += ival
   if width
   {
      val.appendch( '.' )
      val.fill( "0", width, 0 )
   }
   return this.fw_str(  val, num  )
}

/*method  uint dbf.fw_int( uint ival, uint num )
{
   return this.fw_int( int( ival ), num  )
}*/

/*-----------------------------------------------------------------------------
* Id: dbf_fw_memo F2
* 
* Summary: Writing a value into a memo field. Write a value into the 
           specified memo field of the current record.  
*  
* Params:  val - The string being written.  
           num - Field number beginning with 1.  
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint dbf.fw_memo( str val, uint num )
{
   uint  size
   uint  idmem iread fsize vlen
   str   cur
   
   subfunc uint reqblock( uint rsize )
   {
      rsize += ?( this.head.version == 0x83, 2, 8 )
      return rsize / this.mblock + ?( rsize % this.mblock, 1, 0 )
   }
   
   if  this.f_type( num ) != $DBFF_MEMO : return this.error( $ERRDBF_TYPE )
   this.f_memo( cur, num )      

   if *cur && reqblock( *cur ) >= reqblock( *val )
   { 
      // Записываем поверх старого
      this.dbtfile.setpos( this.f_int( num ) * this.mblock, $FILE_BEGIN )
      if this.head.version == 0x8B &&        
               //!'ff ff 08 00 \i4 \( *val + 8 )'.write( this.dbtfile )
               !this.dbtfile.write( 'ff ff 08 00 \i4 \( *val + 8 )' )
               
      {
         return this.error( $ERRDBT_WRITE )
      }
      
      if !this.dbtfile.write( val ) : return this.error( $ERRDBT_WRITE )
      
      if this.head.version == 0x83 && //!'1a 1a'.write( this.dbtfile )
         !this.dbtfile.write( '1a 1a' )
      {
         return this.error( $ERRDBT_WRITE )
      }
      return 1
   }
   // Записываем в новом месте
   this.dbtfile.setpos( 0, $FILE_BEGIN )
   //ReadFile( this.dbtfile, &idmem, 4, &iread, 0 )
   this.dbtfile.read( &idmem, 4 )
   fsize = this.dbtfile.getsize( )
   this.dbtfile.setpos( 0, $FILE_END )
   if !idmem : idmem = 1

   if idmem * this.mblock > fsize
   {
      // Заполняем до начала записи недостающим размером
      cur.clear()
      cur.fill( "\01A", idmem * this.mblock - fsize, $FILL_LEN )
      if !this.dbtfile.write( cur ) 
      {
         return this.error( $ERRDBT_WRITE )
      }
   }            
   if this.head.version == 0x83
   {
      vlen = *val
      val.fill( "\01A", reqblock( vlen ) * this.mblock, $FILL_LEN )
   }
   else    // dBase IV
   {
      //if //! 'ff ff 08 00 \i4 \( *val + 8 )'.write( this.dbtfile )
      if !this.dbtfile.write( 'ff ff 08 00 \i4 \( *val + 8 )' )
      {
         return this.error( $ERRDBT_WRITE )
      }
   }

   if !this.dbtfile.write( val ) 
   {
      return this.error( $ERRDBT_WRITE )
   }
   if this.head.version == 0x83 : val.setlen( vlen )

   size = reqblock( this.dbtfile.getsize( ) )
   this.dbtfile.setpos( 0, $FILE_BEGIN )   
   //WriteFile( this.dbtfile, &size, 4, &iread, 0 )
   this.dbtfile.write( &size, 4 )
   
   return this.fw_int( idmem, num )
}
