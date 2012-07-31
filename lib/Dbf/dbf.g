/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
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
* Id: dbf L "Dbf"
* 
* Summary: This library is used to work with #b(dbf) files. The formats 
           #b(dBase III) and #b(dBase IV) are supported. To be able to work, 
           you should describe a variable of the #b(dbf) type. For using this
           library, it is required to specify the file dbf.g (from Lib
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\dbf\dbf.g"]    
*
* List: *#lng/opers#,dbf_oplen,dbf_opfor,
        *#lng/methods#,dbf_append,dbf_bof,dbf_bottom,dbf_close,dbf_create,
        dbf_del,dbf_empty,dbf_eof,dbf_geterror,dbf_go,dbf_isdel,dbf_open,
        dbf_pack,dbf_recno,dbf_skip,dbf_top, 
        *Field methods,dbf_f_count,dbf_f_date,dbf_f_decimal,dbf_f_double,
        dbf_f_find,dbf_f_int,dbf_f_logic,dbf_f_memo,
        dbf_f_name,dbf_f_offset,dbf_f_ptr,dbf_f_str,dbf_f_type,dbf_f_width,
        dbf_fw_date,dbf_fw_double,dbf_fw_int,dbf_fw_logic,dbf_fw_memo,
        dbf_fw_str 
* 
-----------------------------------------------------------------------------*/

define <export>
{
   DBF_PAGE       = 0x40000  // Page size 262144
   
/*-----------------------------------------------------------------------------
* Id: dbflogic D
* 
* Summary: Logic value.
*
-----------------------------------------------------------------------------*/
   DBF_LFALSE     = 0   // The value of the logical field is FALSE.
   DBF_LTRUE      = 1   // The value of the logical field is TRUE.
   DBF_LUNKNOWN   = 2   // The value of the logical field is undefined. 

/*-----------------------------------------------------------------------------
* Id: dbftypes D
* 
* Summary: Types of fields.
*
-----------------------------------------------------------------------------*/
   DBFF_CHAR      = 'C'   // String.
   DBFF_DATE      = 'D'   // Date.
   DBFF_LOGIC     = 'L'   // Logical.
   DBFF_NUMERIC   = 'N'   // Integer.
   DBFF_FLOAT     = 'F'   // Fraction.
   DBFF_MEMO      = 'M'   // Memo field.

/*-----------------------------------------------------------------------------
* Id: dbferrs D
* 
* Summary: Flags for dbf.geterror.
*
-----------------------------------------------------------------------------*/
   ERRDBF_OPEN    = 1   // Cannot open dbf file.
   ERRDBF_READ          // Cannot read dbf file.
   ERRDBF_POS           // File position error.
   ERRDBF_EOF           // There is not the current record.
   ERRDBF_WRITE         // Cannot write dbf file.
   ERRDBF_FOVER         // The length of the string being written is greater /
                        // than the size of the field.
   ERRDBF_TYPE          // Incompatible field type.
   ERRDBT_OPEN          // Cannot open dbt file.
   ERRDBT_READ          // Cannot read dbt file.
   ERRDBT_POS           // An error of positioning in the dbt file.
   ERRDBT_WRITE         // Cannot write dbt file.
//-----------------------------------------------------------------------------

}

type dbfhead {
    byte     version        
    byte     yy
    byte     mm
    byte     dd
    uint     num_recs
    ushort   header_len
    ushort   record_width
    reserved filler[20]
}

type dbfhfield {
    reserved  name[11]
    byte      ftype
    uint      reserve
    ubyte     width
    byte      decimals
    reserved  filler[14]
}

type dbffield {
    str       name
    uint      ftype
    uint      width
    uint      decimals
    uint      offset
}

type dbf
{
   dbfhead    head
   str        name
   uint       error
   file       dbffile
   file       dbtfile
   buf        page          // Страница загруженных данных
   uint       pageoff       // Номер первого загруженного с 0
   uint       pagecount     // Количество загруженных
   uint       pagelimit     // Максимально возможное количество 
                            // элементов на странице
   uint       cur           // Номер текущего элемента с 0
   uint       curfor        // Номер текущего элемента с 1 для foreach
   uint       ptr           // Указатель на текущую запись
   buf        eofbuf        // Пустой буфер       
   uint       mblock        // Размер Memo поля
   arr        fields of dbffield
}

extern {
   method uint dbf.top()
}

method dbf.delete
{
   if this.dbffile.fopen 
   {
      this.dbffile.close( )
      //this.dbffile = 0
   }
   if this.dbtfile.fopen 
   {
      this.dbtfile.close( )
      //this.dbtfile = 0
   }
   this.page.clear()
   this.fields.clear()
}

method uint dbf.error( uint code )
{
   this.error = code
   return 0
}

/*-----------------------------------------------------------------------------
* Id: dbf_oplen F4
* 
* Summary: Get the number of records in the database.
*  
* Return: The number of records.
*
-----------------------------------------------------------------------------*/

operator uint *( dbf dbase )
{
   return dbase.head.num_recs
}

/*-----------------------------------------------------------------------------
* Id: dbf_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over all 
           records of the database. #b(Variable) is a number of the current
           record.
*  
* Title: foreach var,dbf
*
* Define: foreach variable,dbf {...}
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: dbf_eof F2
* 
* Summary: Determine is the current record is in the database.
*  
* Params: fd - This parameter is used in forech operator. /
          Specify 0-&gt;fordata.
*
* Return: Returns 1 if the current record is not defined/found and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

method  uint dbf.eof( fordata fd )
{
   return this.cur >= *this   
}

method uint dbf.getdate()
{
   datetime dt
   
   dt.gettime()
   dt.year %= 100
   if dt.year != this.head.yy || dt.month != this.head.mm ||
      dt.day != this.head.dd
   {
      this.head.yy = dt.year
      this.head.mm = dt.month
      this.head.dd = dt.day
      return 1
   }
   return 0
}

include : "field.g"

/*-----------------------------------------------------------------------------
* Id: dbf_geterror F3
* 
* Summary: Getting an error code. Get the error code in case some method is
           finished unsuccessfully. 
*  
* Return: The code of the last error is returned.$$[dbferrs] 
*
-----------------------------------------------------------------------------*/

method uint dbf.geterror()
{
   return this.error
}

/*-----------------------------------------------------------------------------
* Id: dbf_open F2
* 
* Summary: Open a database (a dbf file). 
*  
* Params: name - The name of the dbf file being opened.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint dbf.open( str name )
{
   buf   btemp
   str   dbtname
   uint  size
   uint  cur
   uint  i
   
   this.delete()
   
   this.name = name
   if !( this.dbffile.open( name, 0 )) : return this.error( $ERRDBF_OPEN )
   if this.dbffile.read( btemp, sizeof( dbfhead )) != sizeof( dbfhead )
   {
      return this.error( $ERRDBF_READ )
   }   
   mcopy( &this.head, btemp.ptr(), sizeof( dbfhead ))
   if this.head.version == 0x83 || this.head.version == 0x8B
   {
      dbtname.fsetext( name, "dbt" )
      if !( this.dbtfile.open( dbtname, 0 )) 
      {
         this.delete()
         return this.error( $ERRDBT_OPEN )
      }
      if this.head.version == 0x8B
      {
         btemp.use = 0
         if this.dbtfile.read( btemp, 32 ) != 32
         {
            this.delete()
            return this.error( $ERRDBT_READ )
         }
         this.mblock = ( btemp.ptr() + 20 )->ushort
         if !this.mblock : this.mblock = 512
      }
      else : this.mblock = 512
   }   
   size = this.dbffile.getsize( )
   //this.page.alloc( ?( $DBF_PAGE < size, $DBF_PAGE, size ))
   this.page.reserve( ?( $DBF_PAGE < size, $DBF_PAGE, size ) )   
   this.pagelimit = this.page.size / this.head.record_width
   this.pagecount = 0
   this.pageoff = 0
   this.cur = 0

   btemp.use = 0
   size = this.head.header_len - sizeof( dbfhead )
   
   if this.dbffile.read( btemp, size ) != size
   {
      this.delete()
      return this.error( $ERRDBF_READ )
   }
   
   cur = btemp.ptr()
   size = 1
   while cur->byte != 0x0D
   {
      cur as dbfhfield
      i = this.fields.expand( 1 );
      this.fields[ i ].name.copy( &cur.name )
      this.fields[ i ].ftype = cur.ftype
      this.fields[ i ].width = cur.width
      this.fields[ i ].decimals = cur.decimals
      this.fields[ i ].offset = size
      size += cur.width
      cur as uint
      cur += sizeof( dbfhfield )
   }
//   print("Size = \(size) Rec_width=\(this.head.record_width)\n")
   // Зануляем буфер для записи eof
   this.eofbuf.clear()
   this.eofbuf.reserve( this.head.record_width + 1 )
   this.eofbuf.use = this.head.record_width
   fornum i=0, this.head.record_width : this.eofbuf[i] = ' '
//   mzero( this.eofbuf.ptr(), this.eofbuf.size )
   this.ptr = this.eofbuf.ptr()
   
   this.top()
   return 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_close F3
* 
* Summary: Close a database. 
*  
-----------------------------------------------------------------------------*/

method dbf.close()
{
   this.delete()
}

/*-----------------------------------------------------------------------------
* Id: dbf_go F2
* 
* Summary: Move to the record with the specified number.
*  
* Params: num - The required record number starting from 1.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method  uint dbf.go( uint num )
{
   uint  prevcur = this.cur
   uint  count = this.head.num_recs
   
   this.cur = --num
   
   if num < *this
   {
      if this.pageoff > num || this.pageoff + this.pagecount <= num
      {
         if count > this.pagelimit
         {
            if prevcur <= num
            {
               this.pageoff = num
               this.pagecount = ?( count - num > this.pagelimit, 
                                   this.pagelimit, count - num )
            }
            else
            {
               this.pagecount = ?( num + 1 > this.pagelimit, 
                                   this.pagelimit, num + 1 )
               this.pageoff = num + 1 - this.pagecount
            }
         }
         else
         {
            this.pageoff = 0
            this.pagecount = count
         }
//         print("Pagecount=\(this.pagecount)\n")
         uint  pos = this.head.header_len + 
                     this.pageoff * this.head.record_width
         // Загружаем данные
         if this.dbffile.setpos( pos, $FILE_BEGIN ) != pos
         {
             return this.error( $ERRDBF_POS )
         }
         uint size = this.pagecount * this.head.record_width
         this.page.use = 0         
         if this.dbffile.read( this.page, size ) != size
         {
            return this.error( $ERRDBF_READ )
         }
//         print("Read=\(size)\n")
      }
      this.ptr = this.page.ptr() + ( this.cur - this.pageoff ) * 
                 this.head.record_width
   }
   else 
   { 
      this.cur = *this
      this.ptr = this.eofbuf.ptr()
   }
   
   return  1
}

/*-----------------------------------------------------------------------------
* Id: dbf_top F3
* 
* Summary: Move to the first record.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method  uint dbf.top()
{
   return this.go( 1 )
}

/*-----------------------------------------------------------------------------
* Id: dbf_bottom F3
* 
* Summary: Move to the last record.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method  uint dbf.bottom()
{
   return this.go( *this )
}

/*-----------------------------------------------------------------------------
* Id: dbf_skip F2
* 
* Summary: Moving to another record. Move forward or backward for the 
           specified number of records.
*  
* Params: step - The step of moving. If it is less than zero, the move will /
                 be toward the beginning of the database. 
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method  uint dbf.skip( int step )
{
   return this.go( this.cur + 1 + step )
}
/*
method  uint dbf.skip( uint step )
{
   return this.go( this.cur + 1 + step )
}*/

/*-----------------------------------------------------------------------------
* Id: dbf_recno F3
* 
* Summary: Getting the number of the current record.
*  
* Return: The number of the current record or 0 if the record is not defined. 
*
-----------------------------------------------------------------------------*/

method  uint dbf.recno()
{
   fordata fd 
   if this.eof( fd ) : return 0
   return this.cur + 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_bof F3
* 
* Summary: Determine is the current record is the first one.
*  
* Return: 1 is returned if the current record is the first one. 
*
-----------------------------------------------------------------------------*/

method  uint dbf.bof()
{
   return !this.cur && *this
}

/*-----------------------------------------------------------------------------
* Id: dbf_isdel F3
* 
* Summary: Getting the record deletion mark. Determine if the current record 
           is marked as deleted. 
*  
* Return: 1 is returned if the current record is marked as deleted.  
*
-----------------------------------------------------------------------------*/

method  uint dbf.isdel()
{
   return ( this.f_ptr( 1 ) - 1 )->byte == 0x2A
}

/*-----------------------------------------------------------------------------
* Id: dbf_del F3
* 
* Summary: Set/clear the deletion mark for the current record. 
*  
* Return: #lng/retf#  
*
-----------------------------------------------------------------------------*/

method  uint dbf.del
{
   fordata fd
   if this.eof( fd ) : return this.error( $ERRDBF_EOF )
   
   uint  pos = this.head.header_len + 
                     this.cur * this.head.record_width   

   this.ptr->byte = ?( this.ptr->byte == '*', ' ', '*' )
   //!this.page.write( this.dbffile, pos, this.ptr - this.page.data, 1 )
   if !this.dbffile.writepos( pos, this.page.ptr() + this.ptr - this.page.data, 1 )
   {
      return this.error( $ERRDBF_WRITE )
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_append F3
* 
* Summary: Adding a record. The method adds a record to a database.  
*  
* Return: #lng/retf#  
*
-----------------------------------------------------------------------------*/

method uint dbf.append()
{
   str   val
   uint  size 
   
   val.fillspacer( this.head.record_width )
   val.appendch( 0x1A )
   
   uint  pos = this.dbffile.getsize( ) - 1 
        //this.head.header_len + this.head.num_recs * this.head.record_width
   
//   if !val->buf.write( this.dbffile, pos, 0, *val )
   if !this.dbffile.writepos( pos, val->buf.ptr(), *val )
   {
      return this.error( $ERRDBF_WRITE )
   }
   this.dbffile.setpos( 4, $FILE_BEGIN )
   //ReadFile( this.dbffile, &this.head.num_recs, 4, &size, 0 )
   size = this.dbffile.read( &this.head.num_recs, 4 )
   this.head.num_recs++
   this.getdate()
   this.dbffile.setpos( 1, $FILE_BEGIN )
   // Записываем дату и количество записей
   //WriteFile( this.dbffile, &this.head.yy, 7, &size, 0 )
   size = this.dbffile.write( &this.head.yy, 7 ) 
   this.pagecount = 1
   this.cur = this.head.num_recs - 1
   this.pageoff = this.cur
   this.page.append( val.ptr(), *val )
//   mcopy( this.page.ptr(), val.ptr(), *val )
//   this.page.use = *val
   return 1
}

func  uint  creatememo( str filename, uint sblock )
{
   buf  btemp
   str  fname 
   
   btemp.reserve( 512 )
   mzero( btemp.ptr(), 512 )
   btemp.use = 512
   fname.fnameext( filename )
   mcopy( btemp.ptr() + 8, fname.ptr(), *fname )
   ( btemp.ptr() + 20 )->ushort = sblock
   return btemp.write( fname.fsetext( filename, "dbt" ))   
}

/*-----------------------------------------------------------------------------
* Id: dbf_empty F2
* 
* Summary: Creating an empty copy. The method creates the same, but empty
           database.
*  
* Params: filename - The full name of the dbf file being created.  
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint dbf.empty( str outfile )
{
   buf  btemp
   dbf  dbftemp
   
   this.dbffile.setpos( 0, $FILE_BEGIN )
   this.dbffile.read( btemp, this.head.header_len )
   btemp += byte( 0x1A )
   dbftemp.getdate()
   mcopy( btemp.ptr() + 1, &dbftemp.head.yy, 3 )
   ( btemp.ptr() + 4 )->uint = 0

   if !btemp.write( outfile )
   {
      return this.error( $ERRDBF_WRITE )
   }
   if this.head.version == 0x83 || this.head.version == 0x8B
   {
      if !creatememo( outfile, this.mblock )
      {
         return this.error( $ERRDBT_WRITE )
      }
   }
   return 1
}

method uint dbf.first( fordata fd )
{
   this.top()
   this.curfor = this.cur + 1
   return &this.curfor
}

method uint dbf.next( fordata fd )
{
   this.skip( 1 )
   this.curfor = this.cur + 1
   return &this.curfor
}

define {
   DBF_PACKSIZE = 1002000
   DBF_PACKUSE = 1000000
}

/*-----------------------------------------------------------------------------
* Id: dbf_pack F2
* 
* Summary: Pack a database. The database is copied into a new file excluding
           records marked as deleted.
*  
* Params: outfile - The name of the new dbf file.  
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint dbf.pack( str outfile )
{
   if !this.empty( outfile ) : return 0

   dbf  newb
   buf  dbfout dbtout
   str  filler
   uint nextmemo rw
   
   if !newb.open( outfile ) 
   {
      return this.error( newb.error )
   }
   newb.dbffile.setpos( newb.head.header_len, $FILE_BEGIN )
   if newb.dbtfile 
   {
      newb.dbtfile.setpos( 0, $FILE_END )
      dbtout.reserve( $DBF_PACKSIZE )
      filler.fill( "\01A", this.mblock, $FILL_LEN )
      nextmemo = 1
   }
   dbfout.reserve( $DBF_PACKSIZE )
   foreach cur, this
   {
      if !this.isdel()
      {
         if newb.dbtfile 
         {
            uint i
            fornum i = 0, *this.fields
            {
               if this.fields[ i ].ftype == $DBFF_MEMO &&
                  this.f_int( i + 1 )                  
               {
                  str  val vmemo
                  uint rsize
                  uint bmust
                  
                  this.f_memo( val, i + 1 )
                  
                  rsize = *val + ?( this.head.version == 0x83, 2, 8 )
                  rsize = rsize / this.mblock + ?( rsize % this.mblock, 1, 0 )
                  bmust = rsize * this.mblock + *dbtout
                  
                  if this.head.version == 0x8B
                  {
                     dbtout += 'ff ff 08 00 \i4 \( *val + 8 )'
                  }
                  vmemo += nextmemo
                  vmemo.fillspacel( this.fields[ i ].width )
                  mcopy( this.f_ptr( i + 1 ), vmemo.ptr(), 
                         this.fields[ i ].width )
                         
                  dbtout.append( val.ptr(), *val )
                  dbtout.append( filler.ptr(), bmust - *dbtout )
                  nextmemo += rsize
                  
                  if dbtout.use > $DBF_PACKUSE
                  {
                     if !newb.dbtfile.write( dbtout )
                     {
                        newb.close()
                        return this.error( $ERRDBT_WRITE )
                     }
                     dbtout.use = 0
                  }
               }
            }
         }
         dbfout.append( this.ptr, this.head.record_width )
         newb.head.num_recs++
         if dbfout.use > $DBF_PACKUSE
         {
            if !newb.dbffile.write( dbfout )
            {
               newb.close()
               return this.error( $ERRDBF_WRITE )
            }
            dbfout.use = 0
         }
      }            
   }
   dbfout += byte( 0x1A )
   if !newb.dbffile.write( dbfout )
   {
      newb.close()
      return this.error( $ERRDBF_WRITE )
   }
   newb.dbffile.setpos( 4, $FILE_BEGIN )
   //WriteFile( newb.dbffile, &newb.head.num_recs, 4, &rw, 0 )
   newb.dbffile.write( &newb.head.num_recs, 4 ) 
   
   if newb.dbtfile 
   {
      if !newb.dbtfile.write( dbtout )
      {
         newb.close()
         return this.error( $ERRDBT_WRITE )
      }
      newb.dbtfile.setpos( 0, $FILE_BEGIN )
      //WriteFile( newb.dbtfile, &nextmemo, 4, &rw, 0 )
      newb.dbtfile.write( &nextmemo, 4 )
   }
   newb.close()
   return 1
}

/*-----------------------------------------------------------------------------
* Id: dbf_create F2
* 
* Summary: Create a dbf file and open it.
*  
* Params: filename - The name of the dbf file being created. 
          fields - The description of database fields. The line containing /
          the description of fields separated by a line break or ';' /
          Field name,Field type,Width,Fractional part length for numbers /
          The name of a field cannot be longer than 10 characters. /
          Possible type fields: $$[dbftypes]
          ver - Version. 0 for dBase III or 1 for dBase IV. 
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method  uint dbf.create( str filename, str fields, uint ver )
{
   arrstr  field //of str
   str  nfield
   buf  out outfield
   uint ismemo
   dbf  dbftemp   
   
   fields.lines( field, 1, 0->arr )
   
   foreach cur, field
   {
      nfield += cur
      nfield.appendch( ';' )
   }   
   field.clear()
   nfield.split( field, ';', $SPLIT_NOSYS )
   dbftemp.head.record_width = 1
   foreach sf, field
   {
      arrstr     items //of str
      dbfhfield  dfield
      
      sf.split( items, ',', $SPLIT_NOSYS )
      if *items[0] > 10 : items[0].setlen( 10 )
      mcopy( &dfield.name, items[0].ptr(), *items[0] )
      
      dfield.ftype = ((items[1])->str)[0]
      dfield.width = uint( items[2] )
      if !dfield.width : dfield.width = 1
      switch dfield.ftype
      {
         case 'N','F'
         {
            if dfield.ftype == 'F' && !ver
            {
               dfield.ftype == 'N'            
            }
            if dfield.width > 20 : dfield.width = 20                        
            dfield.decimals = uint( items[3] )
            
            if dfield.decimals >= dfield.width - 1
            {
               dfield.decimals = dfield.width - 1
            } 
         }
         case 'M'
         {
            dfield.width = 10
            ismemo = 1
         }
         case 'L'
         {
            dfield.width = 1
         }
         case 'D'
         {
            dfield.width = 8
         }
         default
         {
            dfield.ftype = $DBFF_CHAR
         }
      }
      dbftemp.head.record_width += dfield.width
      outfield.append( &dfield, sizeof( dbfhfield ))
   }
   dbftemp.getdate()
   if ismemo
   {
      dbftemp.head.version = ?( ver, 0x8B, 0x83 )
   }
   else : dbftemp.head.version = 0x3
   
   dbftemp.head.header_len = sizeof( dbfhead ) + *outfield + 2
  
   out.copy( &dbftemp.head, sizeof( dbfhead ))
   out += outfield
   out += '0d 00 1a'   
   if !out.write( filename )
   {
      return this.error( $ERRDBF_WRITE )
   }
   if ismemo && !creatememo( filename, 512 )
   {
      return this.error( $ERRDBT_WRITE )
   }
   return this.open( filename )
}