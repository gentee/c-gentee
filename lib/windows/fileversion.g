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

import "version.dll"
{
   uint GetFileVersionInfoSizeA( uint, uint ) -> GetFileVersionInfoSize
   uint GetFileVersionInfoA( uint, uint, uint, uint ) -> GetFileVersionInfo
   uint VerQueryValueA( uint, uint, uint, uint ) -> VerQueryValue 
}

type VS_FIXEDFILEINFO { 
   uint dwSignature 
   uint dwStrucVersion 
   uint dwFileVersionMS 
   uint dwFileVersionLS 
   uint dwProductVersionMS 
   uint dwProductVersionLS 
   uint dwFileFlagsMask 
   uint dwFileFlags 
   uint dwFileOS 
   uint dwFileType 
   uint dwFileSubtype 
   uint dwFileDateMS 
   uint dwFileDateLS 
} 

func uint getfversion( str filename, uint phiver plowver )
{
   buf  data
   uint off get pvs
   
   off = GetFileVersionInfoSize( filename.ptr(), &get )
   
   data.expand( off + 1 )
   if off && GetFileVersionInfo( filename.ptr(), 0, off, data.ptr() )
   {
//      "\\StringFileInfo\\040904E4\\ProductVersion"
      if VerQueryValue( data.ptr(), "\\".ptr(), &pvs, &get )
      {
         phiver->uint = pvs->VS_FIXEDFILEINFO.dwProductVersionMS
         plowver->uint = pvs->VS_FIXEDFILEINFO.dwProductVersionLS
         return 1
      }
   }
   return 0
}

method str str.fversion( uint hiver lowver )
{
   return this = "\( hiver >> 16 ).\( hiver & 0xFFFF ).\( lowver >> 16 ).\( lowver & 0xFFFF )"
   return this
}