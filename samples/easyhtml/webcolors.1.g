/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: webcolors 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define {
   lcount = 12
}

text  item( str rgb )
<TD ALIGN=CENTER><TABLE BGCOLOR=#\(rgb) WIDTH=60><TR><TD>&nbsp;&nbsp;</TD></TR></TABLE>
<FONT FACE="Courier">\(rgb)</FONT>
</TD>
\!

text  colorhtm
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML><HEAD><TITLE>RGB colors for Web</TITLE></HEAD>
<BODY BGCOLOR=#FFFFFF><CENTER>
<TABLE BORDER=0 CELLPADDING=3 CELLSPACING=3><TR>
\{ 
   int vrgb i j k
   uint cur
   
   subfunc outitem
   {
      str  rgb

      rgb.out4( "%06X", vrgb )
      @ item( rgb )
      if ++cur == $lcount 
      {
         @"</TR><TR>"
         cur = 0 
      }
   }
   for i = 0xFF, i >= 0, i -= 0x33
   {
      for j = 0xFF, j >= 0, j -= 0x33
      {
         for k = 0xFF, k >= 0, k -= 0x33
         {
            vrgb = ( i << 16 ) + ( j << 8 ) + k
            outitem()
         }     
      }     
   }
   for vrgb = 0xFFFFFF, vrgb >= 0, vrgb -= 0x111111 : outitem()
   for vrgb = 0xFF0000, vrgb > 0, vrgb -= 0x110000 : outitem()
   for vrgb = 0x00FF00, vrgb > 0, vrgb -= 0x001100 : outitem()
   for vrgb = 0x0000FF, vrgb > 0, vrgb -= 0x000011 : outitem()
}
</TR></TABLE>&nbsp;<BR>
Generated with Gentee Programming Language
</BODY></HTML>
\!

func color< main >
{
   str out
   
   out @ colorhtm()
   out.write( "color.htm" )
   shell( "color.htm" )
}
