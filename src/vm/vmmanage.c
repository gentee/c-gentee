/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmmanage 26.12.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "vmmanage.h"
//#include "../bytecode/bytecode.h"

/*-----------------------------------------------------------------------------
*
* ID: vmmng_new 26.12.06 0.0.A.
* 
* Summary: Create a new vmmanager
*
-----------------------------------------------------------------------------*/

pvmmanager STDCALL vmmng_new( void )
{
   pvmmanager  pmng = mem_allocz( sizeof( vmmanager ));

   pmng->next = _pvm->pmng;
   _pvm->pmng = pmng;
   pmng->ptr = mem_alloc( 0x100000 );
   pmng->top = pmng->ptr;
   pmng->end = ( pubyte )pmng->ptr + 0xFFF00;

   return pmng;
}

/*-----------------------------------------------------------------------------
*
* ID: vmmng_destroy 26.12.06 0.0.A.
* 
* Summary: Destroy all vm managers
*
-----------------------------------------------------------------------------*/

void STDCALL vmmng_destroy( void )
{
   pvmmanager pmng;

   while ( _pvm->pmng )
   {
      pmng = _pvm->pmng;

      mem_free( pmng->ptr );
      _pvm->pmng = pmng->next;
      mem_free( pmng );
   }
}

/*-----------------------------------------------------------------------------
*
* ID: vmmng_begin 26.12.06 0.0.A.
* 
* Summary: Get a pointer for object
*
-----------------------------------------------------------------------------*/

pubyte STDCALL vmmng_begin( uint size )
{
   pvmmanager  pmng = _pvm->pmng;

   if ( ( pmng->top + 2 * size ) > pmng->end )
   {
      pmng = vmmng_new();
      if ( size + 0xFFFF > 0x100000 )
      {
         mem_free( pmng->ptr );
         pmng->ptr = mem_alloc( size + 0xFFFF );
         pmng->top = pmng->ptr;
         pmng->end = ( pubyte )pmng->ptr + size + 0xFF00;
      }
   }
   return pmng->top;
}

/*-----------------------------------------------------------------------------
*
* ID: vmmng_end 26.12.06 0.0.A.
* 
* Summary: The end of the object
*
-----------------------------------------------------------------------------*/

uint STDCALL vmmng_end( pubyte end )
{
   uint  ret = end - _pvm->pmng->top;

   (( pvmobj )_pvm->pmng->top)->size = ret;

   _pvm->pmng->top = end;
   return ret;
}

//-----------------------------------------------------------------------------
