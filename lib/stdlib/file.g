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

define <export> {
/*-----------------------------------------------------------------------------
* Id: fileflags D
* 
* Summary: File flags for file.open.
*
-----------------------------------------------------------------------------*/
   OP_READONLY  = 0x0001   // Open as read-only.
   OP_EXCLUSIVE = 0x0002   // Open in the exclusive mode.
   OP_CREATE    = 0x0004   // Create the file.
   OP_ALWAYS    = 0x0008   // Create the file only if it does not exist.

//-----------------------------------------------------------------------------
}

/*-----------------------------------------------------------------------------
* Id: tfile T file 
* 
* Summary: File structure.
*
-----------------------------------------------------------------------------*/

type file {
   uint fopen           // 1 if the file is opened.
   uint handle          // The handle of the opened file.
   str  name            // The name of the file.
}

/*-----------------------------------------------------------------------------
* Id: file_close F3
*
* Summary: Close a file. 
*  
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint file.close( )
{
   if .fopen
   {
      .fopen = 0
      return CloseHandle( .handle )
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: file_open F2
*
* Summary: Open a file. 
*  
* Params: name - The name of the file to be opened. 
          flag - The following flags can be used.$$[fileflags] 
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint file.open( str name, uint flag )
{
   .name = name
   .handle = CreateFile( 
         name.ptr(), 
         ?( flag & $OP_READONLY, $GENERIC_READ, $GENERIC_RW ), 
         ?( flag & $OP_EXCLUSIVE, 0, 
            ?( flag & $OP_READONLY, $FILE_SHARE_RW, $FILE_SHARE_RW )), 
         0, 
         ?( flag & $OP_CREATE, $CREATE_ALWAYS, 
            ?( flag & $OP_ALWAYS, $OPEN_ALWAYS, $OPEN_EXISTING )), 
         0, 
         0 )      
   return .fopen = .handle != $INVALID_HANDLE_VALUE
}

/*-----------------------------------------------------------------------------
* Id: file_getsize F3
*
* Summary: Get the size of the file. 
*  
* Return: The size of the file less 4GB.
*
-----------------------------------------------------------------------------*/

method uint file.getsize( )
{
   if .fopen
   { 
      return GetFileSize( .handle, 0 )
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: file_read F2
*
* Summary: Reading a file. 
*  
* Params: ptr - The pointer where the file will be read. 
          size - The size of the data being read. 
* 
* Return: The function returns the size of the read data.
*
-----------------------------------------------------------------------------*/

method uint file.read( uint ptr, uint size )
{
   uint  read
   
   if .fopen 
   {
   /*   if size > 16000000 
      {
         uint fsize = .getsize()
         if size > fsize : size = fsize
      } 
      rbuf.expand( rbuf.use + size + 1 );*/
      
      if ReadFile( .handle, ptr, size, &read, 0 ) 
      {
         return read
      }      
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: file_read_1 FA
*
* Summary: Reading a file. 
*  
* Params: rbuf - The buffer where data will be read. Reading is carried out /
                 by adding data to the buffer. It means that read data will /
                 be added to those already existing in the buffer.  
          size - The size of the data being read. 
* 
* Return: The function returns the size of the read data.
*
-----------------------------------------------------------------------------*/

method uint file.read( buf rbuf, uint size )
{
   if size > 16000000 
   {
      uint fsize = .getsize()
      if size > fsize : size = fsize
   } 
   rbuf.expand( rbuf.use + size + 1 )
   uint fread = this.read( rbuf.data + rbuf.use, size )
   rbuf.use += fread
   return fread
}

/*-----------------------------------------------------------------------------
* Id: file_setpos F2
*
* Summary: Set the current position in the file. 
*  
* Params: offset - Position offset. 
          mode - The type of moving the position.$$[filesetmode] 
* 
* Return: The function returns the current position in the file.
*
-----------------------------------------------------------------------------*/

method uint file.setpos( int offset, uint mode )
{
   if .fopen
   {
      return SetFilePointer( .handle, offset, 0, mode )
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: file_write F2
*
* Summary: Writing to a file. 
*  
* Params: data - The pointer to the memory which data will be written.
          size - The size of the data being written.   
* 
* Return: The function returns the size of the written data.
*
-----------------------------------------------------------------------------*/

method uint  file.write( uint data, uint size )
{
   uint  write
   if .fopen
   {
      if WriteFile( .handle, data, size, &write, 0 ) && write == size
      {
         return write
      }
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: file_write_1 FA
*
* Summary: Writing to a file. 
*  
* Params: rbuf - The buffer from which data will be written.   
* 
* Return: The function returns the size of the written data.
*
-----------------------------------------------------------------------------*/

method uint file.write( buf rbuf )
{  
   return .write( rbuf.data, *rbuf )
}

/*-----------------------------------------------------------------------------
* Id: file_write_2 FA
*
* Summary: Writing to a file from the position. 
*  
* Params: pos - The start position for writing. 
          data - The pointer to the memory which data will be written.
          size - The size of the data being written.   
* 
* Return: The function returns the size of the written data.
*
-----------------------------------------------------------------------------*/

method uint file.writepos( uint pos, uint data, uint size )
{
   uint write
   
   if .setpos( pos, $FILE_BEGIN ) != pos : return 0
   
   return .write( data, size )   
}

//В Linux нет
/*-----------------------------------------------------------------------------
* Id: file_gettime F2
*
* Summary: Get the time when the file was last modified. 
*  
* Params: ft - The variable for getting the time of a file.   
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint file.gettime( filetime ft )
{   
   return GetFileTime( this.handle, 0->filetime, 0->filetime, ft )
}

/*-----------------------------------------------------------------------------
* Id: file_settime F2
*
* Summary: Set time for a file. 
*  
* Params: ft - New time for the file.   
* 
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint file.settime( filetime ft )
{
   return SetFileTime( this.handle, ft, ft, ft )
}

//-------------------------------------------------

