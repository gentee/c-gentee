/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* dll 20.04.2007 0.0.A.
*
* Author:  
*
******************************************************************************/
#include "windows.h"
#include "../../genteeapi/gentee.h"
#include "../../common/msglist.h"

HINSTANCE    handledll;

BOOL WINAPI DllMain( HINSTANCE hinstDll, DWORD fdwReason,
                       LPVOID lpReserved )
//BOOL WINAPI _DllMainCRTStartup( HINSTANCE hinstDll, DWORD fdwReason,
//                       LPVOID lpReserved )
{
   if ( fdwReason == DLL_PROCESS_ATTACH )
      handledll = hinstDll;
   return ( TRUE );
}
 