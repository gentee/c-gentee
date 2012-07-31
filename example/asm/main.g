/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: main 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Example of the using gentee analizer
*
******************************************************************************/

include
{
   $"..\..\lib\lex\lex.g"
   "lexasm.g"
}

func main<main>
{
   str     in
   uint    i off lex
   arrout  out
   uint    igt   // The current gtitem
   
   out.isize = sizeof( lexitem )
   
   in.read( "test.asm" )
   lex = lex_init( 0, lexgasm.ptr())
   gentee_lex( in->buf, lex, out )
//   start = in.ptr()
   off = out.data.ptr()
 //  igt as this 
   
   fornum i, *out
   {
      uint  li 
      
      li as off->lexitem
      if li.ltype != $ASM_LINE 
      {
         print("type=\( hex2stru("", li.ltype )) pos = \(li.pos) len=\(li.len ) 0x\(hex2stru("", li.value )) \n")
      }

      off += sizeof( lexitem )            
   }
   print("--------------------------\n") 
   off = out.data.ptr()
   fornum i = 0, *out
   {
      uint  li 
      
      li as off->lexitem
      
//      if li.ltype != $ASM_UNKNOWN
      {
         str stemp 

         stemp.substr( in, li.pos, li.len )
         print( " "+= stemp )
      }
      off += sizeof( lexitem )            
   }
   lex_delete( lex ) 
   print("--------------------------\n") 
   congetch("Press any key...")
}
