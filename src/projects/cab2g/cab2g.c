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

#include "cab2g.h"

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
