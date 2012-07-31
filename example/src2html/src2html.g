#!gentee.exe -p default "%1"
/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS  FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID:  src2html 14.11.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
*
******************************************************************************/

include
{
   $"..\..\lib\lex\lexnew.g"
   $"..\autoformat\lexfgentee.g"
   $"..\autoformat\lexfc.g"
} 

define 
{
   S2H_GENTEE = 0x0001
   S2H_C      = 0x0002
   S2H_UTF8   = 0x0010
   S2H_LINES  = 0x0020
}

text  src2html( str input, uint flags )
\{
   arrout aout
   uint   lex, off, start, end, ptrlex
   str    out
        
   aout.isize = sizeof( lexitem )
   if flags & $S2H_C : ptrlex = lexfc.ptr() 
   else : ptrlex = lexfgentee.ptr()
   lex = lex_init( 0, ptrlex )
   
   if flags & $S2H_UTF8
   {
      ustr   ust = input
      ust.toutf8( input )
   }  
   gentee_lex( &input, lex, &aout )

   off = aout.data.ptr()
   start = input.ptr()
   end = aout.data.ptr() + *aout * sizeof( lexitem )
   while off < end
   {
      uint  li nospan 
      str   ok stemp
      
      li as off->lexitem
      // print("TYpe = \( hex2stru( li.ltype )) Off=\(li.pos) len = \(li.len)\n") 
      if flags & $S2H_C
      {      
      switch li.ltype
      {
         case $FC_NAME
         {
            if li.value && li.value <= 0xFF : out@"<span class=\"srk\">"
            elif li.value > 0xFF : out@"<span class=\"srt\">"
            else : nospan = 1
         }
         case $FC_STRING,$FC_BINARY : out@"<span class=\"srs\">"
         case $FC_COMMENT, $FC_LINECOMMENT : out@"<span class=\"src\">"
         case $FC_NUMBER : out@"<span class=\"srn\">"
         default : nospan = 1
      }
      }
      else
      {      
      switch li.ltype
      {
         case $FG_NAME
         {
            if li.value && li.value <= 0xFF : out@"<span class=\"srk\">"
            elif li.value > 0xFF : out@"<span class=\"srt\">"
            else : nospan = 1
         }
         case $FG_STRING,$FG_BINARY,$FG_TEXTSTR,$FG_FILENAME,$FG_MACROSTR
         {
            out@"<span class=\"srs\">"
         }
         case $FG_COMMENT, $FG_LINECOMMENT : out@"<span class=\"src\">"
         case $FG_MACRO : out@"<span class=\"srm\">"
         case $FG_NUMBER : out@"<span class=\"srn\">"
         default : nospan = 1
      }
      }
      ok.append( start + li.pos, li.len )
      stemp.replacech( ok, '<', "&lt;" )
      ok.replacech( stemp, '>', "&gt;" )
      out@ok
      if !nospan : out@"</span>"
      off += sizeof( lexitem ) 
   }         
   if flags & $S2H_LINES 
   {
      arrstr lines
      uint   i width = 1
      
      lines.load( out, 0 )
      i = *lines
      while i /= 10 : width++
      
      fornum i = 0, *lines
      {
         @"<span class = \"line\">\( "".out4( "%\( width )i", i + 1 ))</span> \( lines[i] )\l"
      }  
   }
   else : @out

//   @input
}\!

func mainsrc2html<main>
{
   str in 
   
   in.read("c:\\temp\\calendar.g")
   @src2html( in, $S2H_GENTEE )
   getch()
}