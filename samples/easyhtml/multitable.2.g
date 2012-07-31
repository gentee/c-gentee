/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: multitable 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

text  multitable
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Multiplication Table</TITLE>
<STYLE TYPE="text/css">
<!--
BODY {background: #FFF; text-align: center;}
TABLE {border-collapse: separate;}
TABLE,TD,TH {border: 1px solid gray;}
TD, TH {padding: 3px; width: 50px; text-align: center;}
TH {background: #BBB;}
-->
</STYLE>
</HEAD>
<BODY>
<TABLE ALIGN=CENTER><TR><TH>&nbsp;\{ 

   uint i j
   for i = 1, i < 10, i++
   {
      @"<TH>\(i)"
   }   
   for i = 1, i < 10, i++
   {
      @"\l<TR><TH>\(i)"
      for j = 1, j < 10, j++
      {
         @"<TD>\( i * j )"
      }                        
   }
}\l</TABLE><BR>
Generated with Gentee Programming Language
</BODY></HTML>\!

func main< main >
{
   str out
   
   out @ multitable()
   out.write( "mtable.htm" )
   shell( "mtable.htm" )
}
