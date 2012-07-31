/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: mix 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: Different functions.
*
******************************************************************************/

#include "mix.h"
#include "../genteeapi/gentee.h"

/*-----------------------------------------------------------------------------
* Id: argc F1
*
* Summary: Get the number of parameters. The function returns the count of 
           parameters in the command line. 
*  
* Return: The number of parameters passed in the command line.
*
* Define: func uint argc()
*
-----------------------------------------------------------------------------*/

uint      STDCALL argc()
{
   uint    count = 0;
   pubyte  cur = _gentee.args;

   if ( cur )
      while ( *cur )
      {
         count++;
         cur += mem_len( cur ) + 1;
      }
   return count;
}

/*-----------------------------------------------------------------------------
* Id: argv F
*
* Summary: Get a parameter. The function returns the parameter of 
           the command line.
*  
* Params: ret - A variable to write the return value to. 
          num - The number of the parameter to be obtained beginning from 1. 
*
* Return: #lng/retpar( ret )
*
* Define: func str argv( str ret, uint num )
*
-----------------------------------------------------------------------------*/

pstr      STDCALL argv( pstr ret, uint num )
{
   pubyte  cur = _gentee.args;

   str_clear( ret );
   if ( cur )
      while ( *cur )
      {
         num--;
         if ( !num )
         {
            str_copyzero( ret, cur );
            break;
         }
         cur += mem_len( cur ) + 1;
      }
   return ret;
}
