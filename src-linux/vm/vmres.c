/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmres 26.12.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "vmres.h"

/*-----------------------------------------------------------------------------
*
* ID: vmres_addstr 26.12.06 0.0.A.
* 
* Summary: Append a string to resource
*
-----------------------------------------------------------------------------*/

uint  STDCALL  vmres_addstr( pubyte ptr )
{
   collect_addptr( &_vm.resource, ptr );

   return collect_count( &_vm.resource ) - 1;
}

/*-----------------------------------------------------------------------------
*
* ID: vmres_get 26.12.06 0.0.A.
* 
* Summary: Get a string from resource
*
-----------------------------------------------------------------------------*/

pstr  STDCALL  vmres_getstr( uint index )
{
   return *( pstr* )collect_index( &_vm.resource, index );
}
