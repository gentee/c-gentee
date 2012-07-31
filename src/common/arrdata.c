/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: arr 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "arrdata.h"
//! temporary
//#include "../os/user/defines.h"

/*-----------------------------------------------------------------------------
*
* ID: arrdata_appendstr 23.10.06 0.0.A.
* 
* Summary: Append str to arrdata of str
*
* Return: The length of the appended string
*
-----------------------------------------------------------------------------*/

uint  STDCALL arrdata_appendstr( parrdata pa, pubyte input )
{
   pstr  ps;

   ps = ( pstr )arr_append( pa );
   str_init( ps );
   str_copyzero( ps, input );
   return str_len( ps );
}

/*-----------------------------------------------------------------------------
*
* ID: arrdata_delete 23.10.06 0.0.A.
* 
* Summary: Delete arrdata
*
-----------------------------------------------------------------------------*/

void  STDCALL arrdata_delete( parrdata pa )
{
   uint i, count = arr_count( pa );

   for ( i = 0; i < count; i++ )
      buf_delete( arrdata_get( pa, i ));
   arr_delete( pa );
}

/*-----------------------------------------------------------------------------
*
* ID: arrdata_get 23.10.06 0.0.A.
* 
* Summary: Get the item with <i> number (from 0)
*
-----------------------------------------------------------------------------*/

pstr  STDCALL arrdata_get( parrdata pa, uint index )
{
   return ( pstr )( buf_ptr( &pa->data ) + index * sizeof( buf ));
}

/*-----------------------------------------------------------------------------
*
* ID: arrdata_init 23.10.06 0.0.A.
* 
* Summary: Init arrdata
*
-----------------------------------------------------------------------------*/

parrdata  STDCALL arrdata_init( parrdata pa )
{
   arr_init( pa, sizeof( buf ));
   return pa;
}

/*-----------------------------------------------------------------------------
*
* ID: arrdata_strload 23.10.06 0.0.A.
* 
* Summary: Load arrdata from string 0 string 0 string 00
*
-----------------------------------------------------------------------------*/

uint  STDCALL arrdata_strload( parrdata pa, pubyte input )
{
   uint count = 0;

   if ( !input )
      return 0;

   while ( *input )
   {
      input += arrdata_appendstr( pa, input ) + 1;
      count++;
   }

   return count;
}

//--------------------------------------------------------------------------
