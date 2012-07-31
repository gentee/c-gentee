/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: standard 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/


func str bnfparser( str in out )
{
   uint i brack mode quote

   str   squote = "<span class = \"darkblue\">'</span>"
   
   fornum i, *in
   {
      if mode && ( in[i] < 'a' || in[i] > 'z' )
      {
         out += "</span>"
         mode = 0         
      }
      if "&lt;".eqlenign( in.ptr() + i )
      {
         brack++
         out += "&lt;"
         i += 3
         continue
      }
      if "0x".eqlenign( in.ptr() + i )
      {
         str val
         val.copy( in.ptr() + i, 4 )
         out += "<span class = \"darkblue\">\(val)</span>"
         i += 3
         continue
      }
      if in[i] == 0x27
      {
         if !quote && in[i + 1] == 0x27
         {
            out += "\(squote)<span class = \"blue\">'</span>\(squote)"
            i += 2
            continue                        
         }

         if !quote
         {
            out += "<span class = \"blue\">"
         }
         else
         {
            out += "</span>"
         }
         out += squote
         quote = !quote         
         continue
      }      
      if !mode && in[i] >= 'a' && in[i] <= 'z' && !brack 
      {
         out += "<span class = \"blue\">"
         mode = 1
      }
      if "&gt;".eqlenign( in.ptr() + i )
      {
         if brack : brack--
         out += "&gt;"
         i += 3
         continue
      }
      out.appendch( in[i] )
   }
   if mode == 1 : out += "</span>"
   return out
}


text bnfout( arrstr param )
\{
   str     bnflist
   arrstr  bnfarr
   
   _gtp.get( "bnf_common", bnflist )

   bnfarr.loadtrim( bnflist )   
   foreach cur, bnfarr
   {
      arrstr  items
      str     stemp
      
      cur.split( items, '=', $SPLIT_FIRST | $SPLIT_NOSYS )
      stemp.replacech( items[1], '<', "&lt;" )
      items[1].replacech( stemp, '>', "&gt;" )
      bnfparser( items[1], stemp.clear() )
      items.clear()
      stemp.split( items, ':', $SPLIT_FIRST | $SPLIT_NOSYS )
      @"<p><b>\( items[0] )</b> :\( items[1] )</p>\l"
   }   
}\!   
   