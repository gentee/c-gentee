/******************************************************************************
*
* Copyright (C) 2008, Gentee, Inc. All rights reserved. 
* This file is part of the Perfect Automation project - http://www.perfectautomation.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE PERFECT AUTOMATION LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type OSVERSIONINFO 
{ 
  uint  dwOSVersionInfoSize 
  uint  dwMajorVersion 
  uint  dwMinorVersion 
  uint  dwBuildNumber 
  uint  dwPlatformId 
  reserved  szCSDVersion[ 128 ] 
  ushort wServicePackMajor
  ushort  wServicePackMinor
  ushort  wSuiteMask
  byte  wProductType
  byte  wReserved
} 

type winver
{
   uint windows
   uint major
   uint minor
   uint platform
   uint build
   str  csd
}

define
{ 
   VER_NT_WORKSTATION = 1
   // Values for winver.windows 
   WIN_UNKNOWN = 0
   WIN_95
   WIN_98
   WIN_ME
   WIN_NT
   WIN_2000
   WIN_XP
   WIN_2003
   WIN_VISTA   
   WIN_7
   WIN_2008
   WIN_2008R2 
   WIN_8   
   WIN_2012
}

import "kernel32.dll"
{
   uint GetVersionExA( OSVERSIONINFO ) -> GetVersionEx 
}

func uint winversion( winver result )
{
   OSVERSIONINFO  osv
   
   osv.dwOSVersionInfoSize = sizeof( OSVERSIONINFO ) 
   if GetVersionEx( osv )
   {
      result.platform = osv.dwPlatformId
      result.major = osv.dwMajorVersion
      result.minor = osv.dwMinorVersion
      result.build = ?( osv.dwPlatformId == 2, osv.dwBuildNumber,
                        osv.dwBuildNumber & 0xFFFF )
      result.csd.copy( &osv.szCSDVersion )
      if osv.dwPlatformId == 1
      {
         if osv.dwMajorVersion == 4
         {
            result.windows = ?( osv.dwMinorVersion >= 10,  
             ? ( osv.dwMinorVersion >= 90, $WIN_ME, $WIN_98 ), $WIN_95 )
         }
      }
      elif osv.dwPlatformId == 2
      {
         switch osv.dwMajorVersion
         {
            case 4 : result.windows = $WIN_NT
            case 6
            { 
               if !osv.dwMinorVersion
               {
                  if  osv.wProductType == $VER_NT_WORKSTATION : result.windows = $WIN_VISTA 
                  else : result.windows = $WIN_2008 
               }
               elif osv.dwMinorVersion == 1
               {
                  if  osv.wProductType == $VER_NT_WORKSTATION : result.windows = $WIN_7 
                  else : result.windows = $WIN_2008R2 
               }
               elif osv.dwMinorVersion == 2 
               {
                  if  osv.wProductType == $VER_NT_WORKSTATION : result.windows = $WIN_8 
                  else : result.windows = $WIN_2012 
               }
            }
            default
            {
               switch osv.dwMinorVersion
               {
                  case 0 : result.windows = $WIN_2000
                  case 1 : result.windows = $WIN_XP
                  case 2 : result.windows = $WIN_2003
               } 
            }  
         } 
      }
      return 1
   }
   return 0   
}