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

func uint close( uint handle )
{
   return CloseHandle( handle )
}

func uint getftime( uint handle, filetime ft )
{
   return GetFileTime( handle, 0->filetime, 0->filetime, ft )
}

func long getlongsize( uint handle )
{
   uint high low
   
   low = GetFileSize( handle, &high )
   
   return long( low ) | ( long( high ) << 32L )
}

func uint getsize( uint handle )
{
   return GetFileSize( handle, 0 )
}

func uint open( str name, uint flag )
{
   uint result = CreateFile( name.ptr(), ?( flag & $OP_READONLY, $GENERIC_READ, 
                 $GENERIC_RW ), ?( flag & $OP_EXCLUSIVE, 0, 
                 ?( flag & $OP_READONLY, /*$FILE_SHARE_READ*/$FILE_SHARE_RW, 
                 $FILE_SHARE_RW )), 0, ?( flag & $OP_CREATE,
                 $CREATE_ALWAYS, ?( flag & $OP_ALWAYS, $OPEN_ALWAYS, 
                 $OPEN_EXISTING )), 0/* $FILE_FLAG_WRITE_THROUGH*/, 0 )
   
   return ?( result == $INVALID_HANDLE_VALUE, 0, result )
}

func uint read( uint handle, buf rbuf, uint size )
{
   uint  read

   if size > 16000000 
   {
      uint fsize = getsize( handle )
      if size > fsize : size = fsize
   } 
   rbuf.expand( rbuf.use + size + 1 );

   if ReadFile( handle, rbuf.data + rbuf.use, size, &read, 0 ) 
   { 
      rbuf.use += read
   }
   return read;
}

func uint setftime( uint handle, filetime ft )
{
   return SetFileTime( handle, ft, ft, ft )
}

func long setlongpos( uint handle, long pos, uint mode )
{
   uint high low
   
   high = uint( pos >> 32L )
   low = uint( pos )     
   SetFilePointer( handle, low, &high, mode )
   return pos
}

func  uint setpos( uint handle, int offset, uint mode )
{
   return SetFilePointer( handle, offset, 0, mode )
}

func uint  write( uint handle, buf wbuf )
{
   uint  write

   return WriteFile( handle, wbuf.data, *wbuf, &write, 0 ) && write == *wbuf
}
