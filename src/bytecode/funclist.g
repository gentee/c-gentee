#!gentee.exe "%1"
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
* Contributors: Sergey ( SWR )
*
* Summary: The program genertaes funclist.h and funclist.ñ files 
*
******************************************************************************/

//include : $"..\..\lib\gtold\gt.g"
include : $"..\..\lib\stdlib\stdlib.g"
include : $"..\..\lib\gt\gt.g"

/*-----------------------------------------------------------------------------
*
* ID: headerout 12.10.06 1.1.A.
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

text headerout( str name author summary )
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* \(name) \{
   str      sdate
   datetime dt
   getdatetime( dt.gettime(), sdate, 0->str )
//   @"\(name) "
   @sdate 
} 0.0.A.
*
* Author: \(author)
*
* Summary: \(summary)
*
******************************************************************************/
\!

/*-----------------------------------------------------------------------------
*
* ID: funclist_h 12.10.06 1.1.A. 
* 
* Summary: The .h output function.
*  
-----------------------------------------------------------------------------*/
text funclist_h( arrstr acmd, arrstr cmt )
\@headerout( "funclist_h", "Generated with 'funclist' program", 
"This file contains a list of the embedded functions and methods.")
#ifndef _FUNCLIST_
#define _FUNCLIST_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include "../common/types.h"

#define  FUNCCOUNT  \( *acmd )

extern const ubyte embfuncs[];
extern const pvoid embfuncaddr[];

/*
\{ 
   uint k
   fornum k, *cmt
   {
       @"\( cmt[k] )\n"
   }
}
*/
   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _FUNCLIST_
\!

/*-----------------------------------------------------------------------------
*
* ID: cmdlist_h 12.10.06 1.1.A. 
* 
* Summary: The .c output function.
*  
-----------------------------------------------------------------------------*/

text  funclist_c( arrstr aout, arrstr ptr )
\@headerout( "funclist_c", "Generated with 'funclist' program",
"This file contains the embedded functions.")

#include <math.h>
#include "../genteeapi/gentee.h"
#include "funclist.h"
#include "bytecode.h"
#include "cmdlist.h"
#include "../common/crc.h"
#include "../common/mix.h"
#include "../common/arr.h"
#include "../common/collection.h"
#include "../vm/vmtype.h"
#include "../vm/vmres.h"
#include "../algorithm/qsort.h"
#include "../algorithm/search.h"

#ifdef RUNTIME
extern uint  STDCALL gentee_lex( pbuf input, plex pl, parr output );
extern plex  STDCALL lex_init( plex pl, puint ptbl );
extern void  STDCALL lex_delete( plex pl );
//uint  STDCALL gentee_lex( pbuf input, plex pl, parr output ){ return 0; }
//plex  STDCALL lex_init( plex pl, puint ptbl ){ return NULL; }
//void  STDCALL lex_delete( plex pl ){}
uint  STDCALL gentee_compile( pcompileinfo compinit ){ return 0; }
#endif

#if defined __WATCOMC__
   #define  ATOI64 atoll
#else
   #define  ATOI64 _atoi64
#endif

const ubyte embfuncs[] = {
\{
   uint i
   
   fornum i, *aout
   {
      if aout[i][0] >= '0' && aout[i][0] <= '9'
      {
         @"0x\( hex2stru(uint( aout[i] ))), "
      }
      elif aout[i][0] == 'T' : @"\(aout[i]), "
      else
      {
         uint k
         str  stemp
        
         if(i !=0):stemp += "\l"
         fornum k, *aout[i]
         {
            stemp += "'"
            stemp.appendch( aout[i][k] )
            stemp += "', "
         }
         stemp += "0, "
         @stemp
      } 
   }
}
};

const pvoid embfuncaddr[] = {
\{
   uint prev = *this  
   
   fornum i = 0, *ptr
   {
      @"\(ptr[i]), "
      if *this > prev + 65
      {
         @"\l"
         prev = *this
      }   
   }
}
};
\!

/*-----------------------------------------------------------------------------
*
* ID: funcmain 12.10.06 1.1.A.ABKL 
* 
* Summary: The main function.
*  
-----------------------------------------------------------------------------*/

func main<main>
{
   arrstr aout
   arrstr ptr
   arrstr cmt
   str hout
   gt cmdgt
//   gtitems gtis
   
   cmdgt.read( "funclist.gt" )
   foreach cur, cmdgt.root()//.items( gtis )
   {
      str     stemp 
      str     ret
      arrstr  items 
      
      cur as gtitem
      if cur.comment : continue 
//      aout += cur.name
      cur.get("comment", stemp )
      cmt += stemp

      cur.get("name", stemp )
      aout += stemp

      cur.get("ret", ret )
      cur.get("params", stemp )
      stemp.split( items, ',', $SPLIT_NOSYS )
      
      aout += str( *items | ?( *ret, 0x80, 0 ))
      if *ret : aout += ret
      foreach curit, items
      {
         aout += curit
      }
      cur.get("func", stemp )
      ptr += stemp
//         shift += "SH_TYPE"
   }
   hout@funclist_h( ptr, cmt )
   hout.write( "funclist.h" )
   hout.clear()
   hout@funclist_c( aout, ptr )
   hout.write( "funclist.c" )
   congetch("Press any key...")
}
