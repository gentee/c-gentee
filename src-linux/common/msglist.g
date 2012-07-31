/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: msglist 20.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: The program generates msglist.h and msglist.ñ files 
*
******************************************************************************/

include : $"..\..\lib\gt\gt.g"
include : $"..\bytecode\cmdlist.g"

/*-----------------------------------------------------------------------------
*
* ID: msglist_h 12.10.06 1.1.A. 
* 
* Summary: The .h output function.
*  
-----------------------------------------------------------------------------*/
text msglist_h( arrstr acmd, arrstr cmt )
\@headerout( "msglist_h", "Generated with 'msglist' program", 
"This file contains a list of the compiler's or VM's messages.")
#ifndef _MSGLIST_
#define _MSGLIST_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/types.h"

extern char* msgtext[];

#define  MSGCOUNT  \( *acmd )

enum {
\{
   uint i
   
   fornum i, *acmd
   { 
      @"   \(acmd[ i ] ),  // 0x\( hex2stru( i )) \(i) \( cmt[i] )\l" 
   }   
}
};

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _MSGLIST_
\!

/*-----------------------------------------------------------------------------
*
* ID: msglist_c 12.10.06 1.1.A. 
* 
* Summary: The .c output function.
*  
-----------------------------------------------------------------------------*/

text  msglist_c( arrstr pattern, arrstr acmd )
\@headerout( "msglist_c", "Generated with 'msglist' program", "")

const char* msgtext[] = {
\{
   uint i  
   
   fornum i, *pattern
   {
      @"   \"\( pattern[i] )\", // \( acmd[i] )\l"
   }
}
};
\!

/*-----------------------------------------------------------------------------
*
* ID: msgmain 12.10.06 1.1.A.ABKL 
* 
* Summary: The main function.
*  
-----------------------------------------------------------------------------*/

func msgmain<main>
{
   arrstr aout
   arrstr cmt
   arrstr pattern
   str hout
   gt  msggt
//   gtitems gtis
   
   msggt.read( "msglist.gt" )
   foreach cur, msggt.root() //.items( gtis )
   {
      cur as gtitem
      if cur.comment : continue
      str stemp pat
      aout += cur.name
      cur.get("comment", stemp )
      cmt += stemp     
      cur.get("pattern", pat )
      pattern += ?( *pat, pat, stemp )     
   }
   hout@msglist_h( aout, cmt )
   hout.write( "msglist.h" )
   hout.clear()
   hout@msglist_c( pattern, aout )
   hout.write( "msglist.c" )
   congetch("Press any key...")   
}
