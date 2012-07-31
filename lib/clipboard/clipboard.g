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
* Id: clipboard L "Clipboard"
* 
* Summary: These functions are used to work with the Windows clipboard. 
           For using this library, it is
           required to specify the file clipboard.g (from lib\clipboard
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\clipboard\clipboard.g"]   
*
* List: *,clipboard_gettext,clipboard_empty,clipboard_settext,
        *#lng/methods#,buf_getclip,buf_setclip,str_getclip,str_setclip,
        ustr_getclip,ustr_setclip
* 
-----------------------------------------------------------------------------*/

define <export>
{
   CF_TEXT            = 1
   CF_BITMAP          = 2
   CF_METAFILEPICT    = 3
   CF_SYLK            = 4
   CF_DIF             = 5
   CF_TIFF            = 6
   CF_OEMTEXT         = 7
   CF_DIB             = 8
   CF_PALETTE         = 9
   CF_UNICODETEXT     = 13   
   CF_LOCALE          = 16
}

define
{
   GMEM_FIXED         = 0x0000
   GMEM_MOVEABLE      = 0x0002
   GMEM_NOCOMPACT     = 0x0010
   GMEM_NODISCARD     = 0x0020
   GMEM_ZEROINIT      = 0x0040
   GMEM_MODIFY        = 0x0080
   GMEM_DISCARDABLE   = 0x0100
}

import "kernel32.dll"
{
   uint GlobalAlloc( uint, uint )
   uint GlobalFree( uint )
   uint GlobalLock( uint )
   uint GlobalSize( uint )
   uint GlobalUnlock( uint )
   uint GetUserDefaultLCID()
}

import "user32.dll" 
{
 	uint  CloseClipboard( )
   uint  EmptyClipboard( )
   uint  GetClipboardData( uint )
   uint  OpenClipboard( uint )
   uint  SetClipboardData( uint, uint )
}

/*-----------------------------------------------------------------------------
* Id: buf_getclip F2
* 
* Summary: Copy the clipboard data to buf variable.
*  
* Params: cftype - The type of the clipboard data.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint buf.getclip( uint cftype )
{
   uint hmem ptr len ret
   		
	OpenClipboard( 0 )
   
   if hmem = GetClipboardData( cftype )
   {
      len = GlobalSize( hmem )   
      ptr = GlobalLock( hmem )      
      this.copy( ptr, len )
      GlobalUnlock( ptr )      
   }
   CloseClipboard( )
   return hmem
}

/*-----------------------------------------------------------------------------
* Id: str_getclip F3
* 
* Summary: Copy the clipboard data to str variable if the clipboard contains 
           text data.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint str.getclip()
{
   return this.getclip( $CF_TEXT )
}

/*-----------------------------------------------------------------------------
* Id: clipboard_gettext F
*
* Summary: Gets a string from the clipboard.
*
* Params: data - Result string.    
*  
* Return: #lng/retpar( data ) 
*
-----------------------------------------------------------------------------*/
func str clipboard_gettext( str data )
{
   data.getclip()
   return data
}

/*-----------------------------------------------------------------------------
* Id: clipboard_empty F1
*
* Summary: Clear the clipboard.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint clipboard_empty
{
   if OpenClipboard( 0 )
   {
      EmptyClipboard()
      CloseClipboard()
      return 1
   }
   return 0
}

/*-----------------------------------------------------------------------------
* Id: ustr_getclip F3
* 
* Summary: Copy the clipboard data to unicode str variable if the clipboard 
           contains unicode text data.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ustr.getclip()
{
   return this.getclip( $CF_UNICODETEXT )
}

/*-----------------------------------------------------------------------------
* Id: buf_setclip F2
* 
* Summary: Copy the data of the buf variable to the clipboard.
*  
* Params: cftype - The type of the buf data.
          locale - Locale identifier. It can be 0.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint buf.setclip( uint cftype locale )
{
   uint ret
   uint hmem ptr hmeml
   
	if !OpenClipboard( 0 ) : return 0
   hmem = GlobalAlloc( $GMEM_MOVEABLE, *this )
   hmeml = GlobalAlloc( $GMEM_MOVEABLE, 4 )
   if hmem && hmeml
   {   
      ptr = GlobalLock( hmem )      
      mcopy( ptr, this.ptr(), *this )
      EmptyClipboard( )
      if ( locale )
      {  
         GlobalLock( hmeml )->uint = locale
         SetClipboardData( $CF_LOCALE, hmeml )
      }
      ret = SetClipboardData( cftype, hmem )
   }
   GlobalUnlock( hmeml )   
   GlobalUnlock( hmem )      
	CloseClipboard( )	
   return ret
}

/*-----------------------------------------------------------------------------
* Id: str_setclip F3
* 
* Summary: Copy a string to the clipboard.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint str.setclip()
{
   return this->buf.setclip( $CF_TEXT, GetUserDefaultLCID() )   
}

/*-----------------------------------------------------------------------------
* Id: clipboard_settext F
*
* Summary: Copies a string into the clipboard.
*
* Params: data - The string for copying into the clipboard.    
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint clipboard_settext( str data )
{
   return data.setclip()      
}

/*-----------------------------------------------------------------------------
* Id: ustr_setclip F3
* 
* Summary: Copy a unicode string to the clipboard.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ustr.setclip()
{
   return this->buf.setclip( $CF_UNICODETEXT, GetUserDefaultLCID() ) 
}



