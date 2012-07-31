/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define 
{
   GEAD_TEST = 0    // Testing
   GEAD_MEM         // Writing to buf
   GEAD_FILE        // Writing to file
}

type gead 
{
   geavolume  volume    // GEA volume
   geahead    head      // GEA header
   uint       userfunc  // user function
   str        filename  // The main filename
   str        lastpath  // The last path to GEA files
   str        curfilename  // The current filename
   uint       geaoff    // The offset of GEA data
   buf        moved     // The last data
   str        pattern   // The pattern of the volume
   arr        passcrc   // CRC of passwords
   arr        fileinfo of geafile // The array of file descriptions
   arr        offset of long      // The offsets of the beginning of the files
   buf        input               // The input buffer
   long       inoff               // The offset of the read input 
   uint       insize              // The size of the read input
   buf        output              // The output buffer
   
   uint       handle              // Текущий открытый файл
   uint       curdisk             // Номер текущего открытого тома
   
   arr        voloff of long      // The offset of volumes
   arr        volsize of long     // The size of volumes
   
   uint       blocksize
   uint       solidsize
   uint       lastsolid           // The last unpacked solid file
   uint       demode              // See GEAD_* defines 
   arrstr     passwords         // Passwords
   arr        passbufs of buf  // Long passwords
//   uint       storesize
//   uint       handle    // The handle of the main file
/*   uint       flags
   str        pattern   // The pattern of the volume
   long       volsize   // 0 - one volume otherwise the size of the volume
   uint       userparam // user parameter
//   uint       numvol    // The number of the current volume
   arr        fileinfo of geafile // The array of file descriptions
   hash       addedfiles       // Added files
   str        volpath          // Path to volumes
   arr        volnames of str  // Volume names
   arr        volumes of long  // Volume sizes
*/
}

type geadinit
{
   uint userfunc  // user function
   uint geaoff    // the offset of GEA data 
//   uint userparam // user parameter 
}

method  uint gead.validatepass( uint id, str password )
{
   uint ret i
   
   if id > *this.passcrc : return 1
   
   fornum i, *this.passcrc
   {
      if !id || id == i + 1
      {
         if this.passcrc[ i ] == password.crc()
         {
            this.passwords[ i ] = password
            gea_passgen( this.passbufs[ i ], password )
            ret = 1
         }
      }  
   }
   return ret
}

method  uint gead.mess( uint code, collection cl )
{
   return geafunc( this.userfunc, code, cl )
}

include : "geadfile.g" 

method uint gead.open( str filename, geadinit gi )
{
   uint handle cur i count
   buf  head   btemp
   
   this.userfunc = gi.userfunc
   this.geaoff = gi.geaoff
   this.filename.ffullname( filename )
   
   // Открываем файл
   if !( handle = gea_fileopen( this.filename, $OP_READONLY, 
                       this.userfunc )) : return 0
   this.lastpath.fgetdir( this.filename )
   setpos( handle, this.geaoff, $FILE_BEGIN )
   read( handle, head, $GEA_DESCRESERVE )
   mcopy( &this.volume, head.ptr(), sizeof( geavolume ))
   mcopy( &this.head, head.ptr() + sizeof( geavolume ), sizeof( geahead ))
   if this.volume.name != $GEA_NAME
   {
      return this.mess( $GEAERR_NOTGEA, %{ this.filename })   
   }
   if this.head.majorver != $GEA_MAJOR || this.head.minorver != $GEA_MINOR 
   {
      if this.mess( $GEAMESS_WRONGVER, %{ this.filename }) != $GEA_IGNORE
      { 
         return 0
      }   
   }
   if getlongsize( handle ) < this.head.geasize
   {
      return this.mess( $GEAERR_WRONGSIZE, %{ this.filename })   
   }       
   cur = head.ptr() + sizeof( geavolume ) + sizeof( geahead ) 
   this.pattern.copy( cur )
   cur += *this.pattern + 1
   if this.head.flags & $GEAH_PASSWORD
   {
      count = cur->ushort
      cur += sizeof( ushort )
      fornum i = 0, count
      {
         this.passcrc[ this.passcrc.expand( 1 ) ] = cur->uint
         this.passwords += ""
         this.passbufs.expand( 1 )
         cur += sizeof( uint )
      }              
   }
   if this.head.flags & $GEAH_COMPRESS
   {
      lzge lz
      
      btemp.expand( this.head.infosize )
      lzge_decode( cur, btemp.ptr(), this.head.infosize, lz )
      btemp.use = this.head.infosize
      cur = btemp.ptr() 
   }
   uint end = cur + this.head.infosize
   uint curattrib curgroup curpass
   str  curfolder
   long curoff
   
   while cur < end
   {
      uint gf gc
      
      this.fileinfo.expand( 1 )
      gf as this.fileinfo[ *this.fileinfo - 1 ]
      gc as cur->geacompfile
      gf.flags = gc.flags
      gf.ft = gc.ft
      gf.size = gc.size
      gf.compsize = gc.compsize 
      gf.crc = gc.crc    
      cur += sizeof( geacompfile )
      if gf.flags & $GEAF_ATTRIB
      {
         curattrib = gf.attrib = cur->uint
         cur += 4
      }
      else : gf.attrib = curattrib   
      if gf.flags & $GEAF_VERSION
      {
         gf.hiver = cur->uint
         cur += 4
         gf.lowver = cur->uint
         cur += 4
      }
      if gf.flags & $GEAF_GROUP
      {
         curgroup = gf.idgroup = cur->uint
         cur += 4
      }
      else : gf.idgroup = curgroup   
      if gf.flags & $GEAF_PROTECT
      {
         curpass = gf.idpass = cur->uint
         cur += 4
      }
      else : gf.idpass = curpass   
      gf.name.copy( cur )
      cur += *gf.name + 1
      if gf.flags & $GEAF_FOLDER
      {
         curfolder = gf.subfolder.copy( cur )
         cur += *gf.subfolder + 1  
      }
      else : gf.subfolder = curfolder
      // Добавляем смещения
      this.offset.expand( 1 )
      this.offset[ *this.offset - 1 ] = curoff
      curoff += long( gf.compsize )
   }
   if this.head.movedsize
   {
      this.moved.copy( head.ptr() + this.head.size, this.head.movedsize )
   }
   else
   {  // Копируем данные в буфер
      this.input.copy( head.ptr() + this.head.size, *head - this.head.size )
      this.insize = *head - this.head.size
   }
   this.handle = handle
   // Вычисляем смещения и размеры томов
   long voloff
   
   this.volsize.expand( this.head.count + 1 )
   this.voloff.expand( this.head.count + 1 )
   fornum i = 0, this.head.count
   {
      long size
      if !i
      {
         size = this.head.geasize - long( this.head.movedsize ) - 
                long( this.head.size ) - long( this.geaoff )
      }
      elif i == this.head.count - 1
      {
         size = this.head.lastsize - long( sizeof( geavolume ))
      }
      else : size = this.head.volsize - long( sizeof( geavolume ))
      this.volsize[ i ] = size
      this.voloff[ i ] = voloff
      voloff += size
   }
   if this.head.movedsize
   {
      this.volsize[ this.head.count ] = long( this.head.movedsize )
      this.voloff[ this.head.count ] = voloff
   } 
   this.blocksize = 0x40000 * this.head.blocksize
   this.solidsize = 0x40000 * this.head.solidsize

   this.input.expand( this.blocksize + 64 )
   this.output.expand( this.blocksize + this.solidsize + 64 )
   this.lastsolid = 0xFFFFFFFF
   ppmd_start( this.head.memory )

   return 1
}

method uint gead.close
{
   ppmd_stop()
   close( this.handle )
   return 1
}