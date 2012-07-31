/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: buffer L "Buffer"
* 
* Summary: Binary data. It is possible to use variables of the #b(buf) type 
  for working with memory. Use this type if you want to store and manage the
   binary data. 
*
* List: *Operators,buf_oplen,buf_opind,buf_opeq,buf_opsum,buf_opadd,buf_opeqeq,
        buf_types2buf,
        *Methods,buf_align,buf_append,buf_clear,buf_copy,buf_crc,buf_del,
        buf_expand,buf_free,buf_findch,buf_getmultistr,buf_getmultiustr,
        buf_insert,
        buf_ptr,buf_read,buf_replace,buf_reserve,buf_write,buf_writeappend  
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: buf_opsum F4
* 
* Summary: Putting two buffers together and creating a resulting buffer.
*  
* Return: The new result buffer.
*
-----------------------------------------------------------------------------*/

operator buf +<result>( buf left, buf right )
{
   ( result = left ) += right
}

/*-----------------------------------------------------------------------------
* Id: buf_types2buf F3
*
* Summary: Converting types to buf. Convert #b(uint) to #b(buf) =&gt; 
            #b('buf( uint )'). 
*  
* Title: buf( type )
* 
* Return: The result buffer.
*
-----------------------------------------------------------------------------*/

method buf uint.buf<result>
{
   result.free()
   result += this   
}

/*-----------------------------------------------------------------------------
* Id: buf_replace F2
* 
* Summary: Replacing data. The method replaces binary data in an object.
*  
* Params: offset - The offset of the data being replaced. 
          size - The size of the data being replaced. 
          value - The #b(buf) object with new data. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method buf  buf.replace( uint offset, uint size, buf value )
{                        
   if  offset >= *this : return this += value
   
   if  offset + size > *this : size = *this - offset

   uint len = *value
   int  dif = len - size
   uint end = offset + size
   
   if dif < 0 : this.del( end - uint( -dif ), uint( -dif ))
   if dif > 0 
   {
      this.expand( *this + len )
      mmove( this.data + end + dif, 
              this.data + end, this.use - end )
      this.use += dif   
   }
   mcopy( this.data + offset, value.data, len )

   return this
}

/*-----------------------------------------------------------------------------
* Id: buf_insert F2
* 
* Summary: Data insertion. The method inserts one buf object into another. 
*  
* Params: offset - The offset where data will be inserted. If the offset is  /
                 greater than the size, data is added to the end to the buffer. 
          value - The #b(buf) object with the data to be inserted. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method buf buf.insert( uint offset, buf value )
{
   return this.insert( offset, value.ptr(), *value )
}

/*-----------------------------------------------------------------------------
* Id: buf_crc F3
* 
* Summary: Calculating the checksum. The method calculates the checksum of data
           for an object of the #b(buf). 
*  
* Return: The checksum is returned. 
*
-----------------------------------------------------------------------------*/

method uint buf.crc
{
   return crc( this.data, this.use, 0xFFFFFFFF )
}

/*-----------------------------------------------------------------------------
* Id: buf_align F3
* 
* Summary: Data alignment. The method aligns the binary data and appends 
           zeros if it is required. 
*  
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method buf buf.align
{
   reserved zero[4]
   
   if this.use & 3 
   {
      this.append( &zero, 4 - ( this.use & 3 ))
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: buf_read F2
* 
* Summary: Reading from a file. The method reads data from the file. 
*  
* Params: filename - Filename.  
* 
* Return: The size of the read data.
*
-----------------------------------------------------------------------------*/

method uint buf.read( str filename )
{
   file f
   this.use = 0   
   if f.open( filename, $OP_READONLY )
   {   
      uint size = f.getsize()
      .reserve( size + 128 ) // резервируем для возможного str 
      this.use = f.read( this.data, size )
      f.close( )
   }
   return this.use
}

/*-----------------------------------------------------------------------------
* Id: buf_write F2
* 
* Summary: Writing to a file. The method writes data to the file. 
*  
* Params: filename - Filename.  
* 
* Return: The size of the written data.
*
-----------------------------------------------------------------------------*/

method uint buf.write( str filename )
{
   file f
   uint wr
   
   if f.open( filename, $OP_CREATE )
   {
      wr = f.write( this.data, *this )
      f.close( )
      return wr
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: buf_writeappend F2
* 
* Summary: Appending data to a file. The method appends data to the specified
          file. 
*  
* Params: filename - Filename.  
* 
* Return: The size of the written data.
*
-----------------------------------------------------------------------------*/

method uint buf.writeappend( str filename )
{
   file f
   uint wr
   
   if f.open( filename, $OP_ALWAYS )
   {
      f.setpos( 0, $FILE_END )
      wr = f.write( this.data, *this )
      f.close( )
      return wr
   }
   return 0
}

/*Тип buf является встроенным
Структура buf включена в компилятор:
type buf < index = byte > {
   uint  data
   uint  use     // занятый размер буфера
   uint  size    // полный размер буфера
   uint  step    // На сколько минимально увеличивать размер 
}
В компилятор включены следующее методы и операции:
buf  buf.append( uint ptr, uint size )
buf  buf.array( uint index ) скрыт
buf  buf.clear() 
buf  buf.copy( uint ptr, uint size )
buf  buf.del( uint offset, uint size )
     buf.delete() скрыт
buf  buf.expand( uint size )     
buf  buf.free()
uint buf.findch( uint ch )
uint buf.index( uint index ) скрыт     
buf  buf.init() скрыт       
buf  buf.insert( uint off ptr size ) скрыт
buf  buf.load( uint ptr, uint size )//Системный метод
uint buf.ptr()
buf  buf.reserve( uint size )

*buf
buf = buf
buf += buf
buf += ubyte
buf += ushort
buf += uint
buf += ulong
buf == buf
buf != buf

*/