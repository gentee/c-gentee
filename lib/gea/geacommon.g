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

type lzge
{
   uint  hufblock    // Размер блока для построения дерева Хафмана
   // Определяемые для сжатия
   uint  order       // Скорость сжатия от 1 до 10
   // Вычисляемые параметры
   uint  numoff      // Количество элементов смещений из rng
   uint  maxbit      // Количество bit на размер окна
   uint  solidoff    // Solid смещение
   uint  mft0        // ПОследние базы смещений
   uint  mft1
   uint  mft2
   uint  userfunc
   uint  pgeaparam
}

type ppmd
{
//   uint memory
   uint  order
   uint  userfunc
   uint  pgeaparam
}

type geavolume
{
   uint    name      // GEA\x0
   ushort  number    // The number of the volume 0 for the main volume
   uint    unique    // Unique number to detect the volumes
}

// The strcuture of the first volume
type geahead
{
   byte       majorver  // Major version
   byte       minorver  // Minor version
   filetime   date      // System data of the creation
   uint       flags     // Flags
   ushort     count     // The count of volumes.
   uint       size      // Header size ( till data )
   long       summary   // The summary compressed size
   uint       infosize  // The unpacked size of file descriptions
   long       geasize   // The full size of the main file
   long       volsize   // The size of the each volume
   long       lastsize  // The size of the last volume file 
   uint       movedsize // The moved size from the end to the head
   byte       memory    // Memory for PPMD compression ( * MB )
   byte       blocksize // The default size of the block ( * 0x40000 KB )
   byte       solidsize // The previous solid size for LZGE (* 0x40000 KB )
}

type geafile
{
   uint      flags  // Flags
   filetime  ft     // File time
   uint      size   // File size
   uint      attrib // File attribute
   uint      crc    // File CRC                  
   uint      hiver  // Hi version
   uint      lowver // Low version                  
   uint      idgroup  // id of the group
   uint      idpass   // id of the password
   uint      compsize // The compressed size
   str       name     // the name of the file
   str       subfolder  // the name of the subfolder
}

define <export>
{
   GEA_MAJOR       = 1
   GEA_MINOR       = 0
   GEA_MINVOLSIZE  = 0xFFFF    // The minimum size of the volume
   GEA_MAXVOLUMES  = 0xFFFF    // The maximum count of volumes
   GEA_DESCRESERVE = 0x200000  // 2 MB резервировать для записи информации 
                               // о файлах 
   GEA_NAME        = 0x414547  // GEA/x0
   // geahead.flags
   GEAH_PASSWORD   = 0x0001    // There are protected files
   GEAH_COMPRESS   = 0x0002    // File descriptions are compressed
   
   // geafile.flags
   GEAF_ATTRIB   = 0x0001    // There is an attribute    
   GEAF_FOLDER   = 0x0010    // There is a relative path
   GEAF_VERSION  = 0x0020    // There is a version
   GEAF_GROUP    = 0x0040    // There is a group id
   GEAF_PROTECT  = 0x0080    // There is the number of password
   GEAF_SOLID    = 0x0100    // Uses the information of the previous file
}

// Further
// name\x0 - the pattern name of the volumes - geaname.g%02i

// 3. if geahead.flag & $GEAH_PASSWORD 
type geapassinfo  
{
   ushort  count      // The count of passwords     
}
// 3.1. array [ geapassinfo.count ] of uint
// CRC of passwords

// 4. The sequence of file descriptions

type geacompfile
{
   ushort    flags    // Flags
   filetime  ft       // File time
   uint      size     // File size
   uint      compsize // The compressed size 
   uint      crc                  
}
// 1. if geafile.flag & $GEAF_ATTRIB
//    uint - file attribute - valid for next items                  
// 2. if geafile.flag & $GEAF_VERSION
//    uint - hi version
//    uint - low version                  
// 3. if geafile.flag & $GEAF_GROUP
//    uint - id of the group - valid for next items                  
// 4. if geafile.flag & $GEAF_PROTECT
//    id - of geapassinfo - valid for next items
//    from 1. Use 0 for disable protection.
// 5. name\x0 - the name of the file
// 6. if geafile.flag & $GEAF_FOLDER
//    subfolder\x0 - the name of the subfolder - valid for next items

type geadata
{
   byte  order
   uint  size
}

// Data blocks
// 1. byte - order 
//    0 - store
//    1 - LZGE 
//    2 - PPMD
//    * 16 + order если 0 то solid 
//    17 - LZGE with order 1 
//    32 - PPMD solid   
//    Старший бит установлен 1 если блок является началом файла
// 2. uint - the block's size without sizeof( geadata )
  
type geaparam
{
   uint process      // packing/unpacking process size   
   uint done         // The packed/unpacked size
   str  name         // Filename
   uint info         // geafile
   uint mode         // 0 - encoding 1 - decoding 
}

define <export>
{
   // Compression algorithms
   GEA_STORE            = 0
   GEA_LZGE             = 1
   GEA_PPMD             = 2
//   GEA_LZGEOSOLID       = 32
//   GEA_LZGEO            = 33
      
//   IDOK               = 1
//   IDCANCEL           = 2
   GEA_OK               = 1
   GEA_ABORT            = 3
   GEA_RETRY            = 4
   GEA_IGNORE           = 5
/*    IDYES              = 6
    IDNO               = 7*/
   
   GEAERR_PATTERN  = 0   // Wrong pattern
   GEAERR_FILEOPEN       // Cannot open file
   GEAERR_FILEREAD       // Cannot read file
   GEAERR_FILEWRITE      // Cannot write file
   GEAERR_TOOBIG         // Too big file
   GEAERR_MANYVOLUMES    // Too many volumes
   GEAERR_NOTGEA         // The file is not GEA archive
   GEAERR_WRONGVOLUME    // The wrong volume
   GEAERR_WRONGSIZE      // The wrong size of the volume
   GEAERR_INTERNAL       // The internal error
   GEAERR_CRC            // The wrong CRC
   GEAERR_LAST     = 100
   GEAMESS_BEGIN      // Beginning of creating GEA file   
   GEAMESS_END        // GEA file was created successfully
   GEAMESS_COPY       // Файл уже был включен
   GEAMESS_ENBEGIN    // Начать процесс упаковки файла
   GEAMESS_DEBEGIN    // Начать процесс распаковки файла
   GEAMESS_WRITEHEAD  // Запись GEA заголовка
   GEAMESS_ENEND      // Файл упакован
   GEAMESS_DEEND      // Файл распакован
   GEAMESS_WRONGVER   // The unsupported version of GEA file
   GEAMESS_GETVOLUME  // Get the file of the volume. The application must set 
                      // the current directory with the volume  
   GEAMESS_PASSWORD   // Требуется пароль
   GEAMESS_PROCESS = 200  // Процесс упаковки/распаковки 
}

func uint geafunc( uint userfunc code, collection cl )
{
   geaparam  geap
   
   if !userfunc : return 0
   if *cl
   {
      geap.name = cl[ 0 ]->str
      if *cl > 1
      { 
         geap.info = cl[ 1 ]
         if *cl > 2 : geap.process = cl[ 2 ]
      }
   }
   return userfunc->func( code, geap )   
}

//--------------------------------------------------------------------------

func gea_passgen( buf pass, str srcpass )
{
   uint      icrc i count
   reserved  crcb[4]
   
   icrc = crc( srcpass.ptr(), *srcpass, 0xFFFFFFFF )
   pass.expand( 256 )
   pass.use = 256
         
   fornum count, 64
   {
      crcb[0] = icrc & 0xFF
      crcb[1] = ( icrc >> 8 ) & 0xFF
      crcb[2] = ( icrc >> 16 ) & 0xFF
      crcb[3] = ( icrc >> 24 ) & 0xFF
      
      fornum i = 0, 4
      {
         pass[ ( count << 2 ) + i ] = uint( crcb[ i ] ) & 0xFF
      }
      icrc = crc( pass.ptr(), ( count + 1 ) << 2, ?( count, 
                 icrc, icrc >> 1 ))
   }
}

//--------------------------------------------------------------------------

func gea_protect( uint ptr size, buf password )
{
   reserved   crcb[4]
   uint       psw

   crcb[0] = size & 0xFF
   crcb[1] = ( size >> 8 ) & 0xFF
   crcb[2] = ( size >> 16 ) & 0xFF
   crcb[3] = ( size >> 24 ) & 0xFF
   fornum psw, size
   {
      ( ptr + psw )->byte ^= password[ psw & 0xFF ]
   }
}

//--------------------------------------------------------------------------

func uint gea_fileopen( str filename, uint flag, uint userfunc )
{
   uint result
   
   while !( result = open( filename, flag ))
   {
/*      switch geafunc( userfunc, $GEAERR_FILEOPEN, %{ filename })
      {
         case $GEA_RETRY : goto again
         case $GEA_ABORT : return 0
      }*/
      if geafunc( userfunc, $GEAERR_FILEOPEN, %{ filename }) == $GEA_ABORT
      {
         return 0
      } 
   }
   return result
}

//--------------------------------------------------------------------------
