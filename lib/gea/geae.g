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

//include : $"k:\gentee\gentee language\libraries\filex\filex.g"
//include : $"k:\gentee\gentee language\libraries\filex\fileversion.g"

import "kernel32.dll" {
	uint GetTickCount( )
}

type geae 
{
   geahead    head      // Заголовок
   str        filename  // The main filename
   uint       flags
   str        pattern   // The pattern of the volume
   long       volsize   // 0 - one volume otherwise the size of the volume
   uint       userfunc  // user function
//   uint       userparam // user parameter
//   uint       numvol    // The number of the current volume
   arr        fileinfo of geafile // The array of file descriptions
   hash       addedfiles       // Added files
   str        volpath          // Path to volumes
   arrstr     volnames         // Volume names
   arr        volumes of long  // Volume sizes
   arrstr     passwords        // Passwords
   arr        passbufs of buf  // Long passwords
   
   //  Для solid сжатия 
   buf        bsolid           // Предыдущие данные для solid сжатия
   uint       prevmethod       // Предыдущий метод
   uint       prevorder        // Предыдущий порядок
   uint       prevsolid        // Предыдущий файл был с опцией solid
   uint       prevpass         // Предыдущий пароль
   uint       countsolid       // Количество файлов сжатых           
   
   //  Вывод в файл
   uint       handle           // Главный файл вывода
   uint       curhandle        // Текущий файл вывода
   str        curfilename      // Текущее имя тома
   uint       geaoff           // Смещение GEA данных
   uint       unique 
   buf        out              // Временный буфер для записи
   uint       start            // Указатель начала данных
   uint       end              // Указатель конца данных
   uint       stop             // Указатель конца буфера
   uint       emptyvol         // В первый том ничего не писали
   uint       curvol           // Номер текущего тома записи
}

define
{
   // Flags of geaeinit.flag
   GEAI_APPEND     = 0x0001   // to append a file otherwise to create
//   GEAI_COMPINFO   = 0x0002   // Compress file descriptions
   GEAI_IGNORECOPY = 0x0004   // Ignore copies of files
}

type geaeinit
{
   uint flags     // flags
   str  pattern   // volume pattern
   long volsize   // 0 - one volume otherwise the size of the volume
   uint userfunc  // user function
//   uint userparam // user parameter 
}
/*
method  uint geae.mess( uint code, str name )
{
   return geafunc( this.userfunc, %{ code, name })
}

method  uint geae.mess( uint code, str name, geafile gf )
{
   return geafunc( this.userfunc, %{ code, name, gf })
}

method  uint geae.mess( uint code, str name, geafile gf, uint process )
{
   return geafunc( this.userfunc, %{code, name, gf, process })
}
*/

method  uint geae.mess( uint code, collection cl )
{
   return geafunc( this.userfunc, code, cl )
}

include : "geaefile.g"
   
method  uint geae.create( str filename, geaeinit geai )
{
   str  stemp

   this.flags = geai.flags      
   this.pattern = geai.pattern
   this.volsize = geai.volsize
   this.userfunc = geai.userfunc
//   this.userparam = geai.userparam
   this.filename.ffullname( filename )
   this.volpath.fgetdir( this.filename )
   stemp.fnameext( this.filename )
   this.volnames += stemp
   this.curfilename = this.filename
   verifypath( this.volpath, 0->arrstr )  
   this.mess( $GEAMESS_BEGIN, %{ this.filename })
   
   // Открываем файл
   if !( this.handle = gea_fileopen( this.filename, $OP_EXCLUSIVE | 
         ?( geai.flags & $GEAI_APPEND, $OP_ALWAYS, $OP_CREATE ),
         this.userfunc ) ) : return 0

   this.curhandle = this.handle
   if this.geaoff = getsize( this.handle )
   {
      setpos( this.handle, 0, $FILE_END )
   }
   this.unique = GetTickCount()
   
   // Проверяем размер тома и шаблон 
   if this.volsize
   {
      str  sone

      if this.volsize < long( $GEA_MINVOLSIZE )
      { 
         this.volsize = long( $GEA_MINVOLSIZE )
      }  
      if !*this.pattern
      {
         filename.fgetparts( 0->str, stemp, 0->str ) 
         this.pattern = "\(stemp).g%02u"
      }
//      int2str( sone, this.pattern, 1 )
      sone.out4( this.pattern, 1 )
//      int2str( stemp, this.pattern, 2 )
      stemp.out4( this.pattern, 2 )
      if stemp == sone 
      {
         this.mess( $GEAERR_PATTERN, %{ this.pattern })
         return 0
      } 
   }
   this.addedfiles.ignorecase()
   // Устанавливаем размеры
   datetime dt
   this.head.majorver = $GEA_MAJOR
   this.head.minorver = $GEA_MINOR
   datetimetoftime( dt.gettime(), this.head.date )
   this.head.count = 1   
   this.head.blocksize = 8 // = 0x40000 * 8
   this.head.memory = 8    // 8 MB для PPMD
   this.head.solidsize = 4 // = 0x40000 * 8
   this.bsolid.expand( 0x40000 * this.head.solidsize )
   
   ppmd_start( this.head.memory )
   this.out.expand( 2 * $GEA_DESCRESERVE )
   this.out.use = 2 * $GEA_DESCRESERVE
   this.end = this.start = this.out.ptr()
   this.stop = this.out.ptr() + this.out.use 
   return 1
}

method  geae.writeinfo( buf head )
{
   uint         i
   buf          btemp
   buf          out
   geacompfile  gcf
   str          prevfolder
   uint         prevattrib  prevgroup prevpass
   lzge         lz
   
   foreach cur, this.fileinfo
   {
      btemp.clear()
      gcf.flags = cur.flags
      gcf.ft = cur.ft 
      gcf.size = cur.size
      gcf.compsize = cur.compsize
      gcf.crc = cur.crc
      if cur.attrib != prevattrib
      {
         gcf.flags |= $GEAF_ATTRIB
         btemp += cur.attrib
         prevattrib = cur.attrib   
      }
      if cur.hiver || cur.lowver
      {
         gcf.flags |= $GEAF_VERSION
         btemp += cur.hiver
         btemp += cur.lowver
      }
      if cur.idgroup != prevgroup
      {
         gcf.flags |= $GEAF_GROUP
         btemp += cur.idgroup
         prevgroup = cur.idgroup   
      }
      if cur.idpass != prevpass
      {
         gcf.flags |= $GEAF_PROTECT
         btemp += cur.idpass
         prevpass = cur.idpass   
      }
      btemp += cur.name
      if cur.subfolder != prevfolder  
      {
         gcf.flags |= $GEAF_FOLDER
         btemp += cur.subfolder
         prevfolder = cur.subfolder
      }
      out.append( &gcf, sizeof( geacompfile ))
      out += btemp
   }
   btemp.expand( max( 10000, *out + *out / 10 ))
   lz.order = 10
   btemp.use = lzge_encode( out.ptr(), *out, btemp.ptr(), lz )
   if btemp.use < *out * 90 / 100
   {
      head += btemp
      this.head.flags |= $GEAH_COMPRESS
   }
   else : head += out
   
//   uint  phead 
//   phead as ( head.ptr() + sizeof( geavolume ))->geahead 
//   phead.infosize = *out
   this.head.infosize = *out
//   phead.size = *head                   
}

method  uint geae.close( )
{
   buf       head
   geavolume gv
   uint      i
   
   ppmd_stop()
//   print( "All Files \(sizeof( geahead )) = \(*this.fileinfo) Summary: \( this.head.summary )\n")
   // Формируем заголовок
   this.mess( $GEAMESS_WRITEHEAD, %{ this.filename }) 
   gv.name = $GEA_NAME 
   gv.unique = this.unique   
   if *this.passwords : this.head.flags |= $GEAH_PASSWORD
   
   head.copy( &gv, sizeof( geavolume ))
   head.append( &this.head, sizeof( geahead ))
   head += this.pattern
   
   // Записывем пароли
   if *this.passwords
   {
      head += ushort( *this.passwords )
      foreach curpass, this.passwords
      {
         head += curpass.crc()
      }   
   }

   this.writeinfo( head )
   this.head.size = *head
   this.head.volsize = this.volsize
   // Записываем заголовок
   setpos( this.handle, this.geaoff, $FILE_BEGIN )
   if !write( this.handle, head )
   {
      return this.mess( $GEAERR_FILEWRITE, %{ this.filename })
   }
   // Записываем оставшиеся данные
   if !this.put( 0, 0 ) : return 0
   this.head.count = *this.volumes
   this.head.geasize = getlongsize( this.handle )
   this.head.lastsize = this.volumes[ *this.volumes - 1 ]
   // Закрываем последний том
   if this.curhandle != this.handle : close( this.curhandle )
   // Записываем заново заголовок и информацию о томах
   setpos( this.handle, this.geaoff + sizeof( geavolume ), $FILE_BEGIN )
   WriteFile( this.handle, &this.head, sizeof( geahead ), &i, 0 )
   close( this.handle )

   this.mess( $GEAMESS_END, %{ this.filename })
   return 1
}
