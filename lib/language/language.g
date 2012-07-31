/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: prj 18.07.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include
{
   $"..\gt\gt.g"
   $"..\macro\macro.g"
}

define
{
   LANGEXT = "lng"
}

type langdata
{
   str  filename
   str  name
   ustr native
   str  custom
//   uint utf8
}

/*-----------------------------------------------------------------------------
*
* ID: language 12.10.06 1.1.A. 
* 
* Summary: Language type
*  
-----------------------------------------------------------------------------*/

type language <inherit = gt>// index = str>
{
   str  path    // Path to language files
   str  deflang // Default language
   str  curlang // Current language
   str  defin   // Input string of default language
   arr  lnglist of langdata
   macro  macros     
}
/*
global
{
   str  langempty
}
*/
method uint language.getinfo( str filename )
{
   str  data  datacut
   gt   gtdata
   uint gti
   uint newlng
   
   data.read( filename )
   
   datacut.substr( data, 0, data.findch( '/' ) + 2 )
   gtdata.utf8 = 1
   gtdata += datacut
   gti as gtdata.find("data")
   if !&gti : return 0
   newlng as .lnglist[ .lnglist.expand( 1 ) ]
//   .utf8 = /*( gti.find( "utf8" ) ||*/ data.isprefutf8() )
   filename.fgetparts( 0->str, newlng.filename, 0->str )
   gti.get( "name", newlng.name ) 
   gti.get( "native", newlng.native )
   if .deflang %== newlng.filename : .defin = data
   return 1
}  

/*-----------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/

method uint language.getid( str langname )
{
   uint i
   
   fornum i, *.lnglist
   {
      if langname %== .lnglist[i].name : break
   } 
   return i
}

/*-----------------------------------------------------------------------------
*
* ID: language_change 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

method uint language.change( str langname )
{
   subfunc loadcustom( str custlang )
   {
      uint id = .getid( custlang )
      if id < *.lnglist : .root().load( .lnglist[ id ].custom )
   }
   
   .clear()
   .root().load( .defin )
   loadcustom( .deflang )
   if langname %!= .deflang
   { 
      .read( "\(.path)\\\( langname ).\($LANGEXT)")
      loadcustom( langname )
      .curlang = langname
   }      
   else : .curlang = .deflang
   return 1
}

/*-----------------------------------------------------------------------------
*
* ID: language_change 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

method uint language.change( uint id )
{
   if id >= *.lnglist : return 0
   return .change( .lnglist[ id ].filename )
}

/*-----------------------------------------------------------------------------
*
* ID: language_get 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/
/*
method ustr language.getlang( ustr name ret )
{
   ret.clear()
   .get( "default/\( str( name ))", ret )
//   print("Len=\( *ret )\n")
   return ret   
}
*/
/*-----------------------------------------------------------------------------
*
* ID: language_get 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

method ustr language.getlang( str name, ustr ret )
{
   if name[0] == '^' && name[ *name - 1 ] == '^'
   {
      str     in out
      arrstr  items
      ustr    space 
      
      space = ustr(" ")
      in.substr( name, 1, *name - 2 )
      in.split( items, ' ', $SPLIT_EMPTY )
      foreach cur, items
      {
         if *ret : ret += space
         if *cur && .find("default/\( cur )")
         {
            ustr stemp
            .get( "default/\( cur )", stemp )
            ret += stemp        
         }  
         else : ret += ustr( cur ) 
      }
   }  
   else : .get( "default/\( name )", ret )
   .macros.replace( ret )
   return ret   
}

method ustr language.getlang( ustr name ret )
{
   return .getlang( str( name ), ret )
}

/*-----------------------------------------------------------------------------
*
* ID: language_load 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

method uint language.load( str path deflang curlang )
{
   ffind fd
   uint  count
   
   .path = path
   .deflang = deflang
   .utf8 = 1

   fd.init( "\(path)\\*.\($LANGEXT)", $FIND_FILE )
   foreach cur, fd
   {
      if .getinfo( cur.fullname ) : count++  
   }
   .change( deflang )
   if *curlang : .change( curlang )
       
   return count
}

method language.setmacro( str macroname, ustr value )
{
   .macros[ macroname ] = value
}

method language.setmacro( str macroname, str value )
{
   .macros[ macroname ] = ustr( value )
}

method ustr language.getlist<result>
{
   uint i
   
   fornum i, *.lnglist
   {
      result += ustr( "\(.lnglist[i].name) (" ) + .lnglist[i].native + 
                ustr( ")=\(.lnglist[i].filename)\l" )  
   }     
   result.trim( 0xa, $TRIM_SYS | $TRIM_RIGHT )
}

method uint language.load( str lang data )
{
   uint id 
   
   if ( id = .getid( lang )) < *.lnglist
   {
      .lnglist[ id ].custom = data
      if lang %== .curlang : .root().load( data )
           
      return 1
   }
   return 0   
}
/*
func mainlang<main>
{
   language lng
   ustr     list
   
   lng.load( $"k:\gentee\open source\gentee\lib\language\language", "english", "english")
   lng.load( "english", "<default>
   <test4 = \"Custom English\" />
</>   ")
//   lng.load( "russian", "﻿<default>
//   <test2 = \"элемен� Ooops\" />
//</>   ")
//  lng.change( "english" )
   print( "QQQ = \( str( lng.getlang( "^test1 + test2 + test3^", ustr("")))) \n" )
   print( "Test1 = \( str( lng.getlang( "test1", ustr("")))) \n" )
   print( "Test2 = \( str( lng.getlang( ustr("test2"), ustr(""))))\n")
   print( "Test3 = \( str( lng.getlang( ustr("test3"), ustr(""))))\n")
   lng.change( "russian" )
   print( "Test1 = \( str( lng.getlang( "test1", ustr("")))) \n" )
   print( "Test2 = \( str( lng.getlang( ustr("test2"), ustr(""))))\n")
   print( "Test3 = \( str( lng.getlang( ustr("test4"), ustr(""))))\n")
   list = lng.getlist()
   print( "\(str(list))\ncurlang=\(lng.curlang) \( lng.getid( lng.curlang ))" )
   getch()
}*/