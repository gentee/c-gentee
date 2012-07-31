/******************************************************************************
*
* Copyright (C) 2004-2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project.
* http://www.gentee.com
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: htmlfromcode 31.10.06
*
* Author: Aleksandr Antypenko ( santy )
*
* Summary: Function converting from gentee code to the html 
*
******************************************************************************/

define
{
   DOCTYPE = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Final//EN\">"
   REST = "<body>\n<!-- Generated with ge2html by Alex Antypenko -->\n<code>\n<pre>\n"
   HEADER = "\$DOCTYPE$ <html>\n \$REST"
   CSS_FILE = ".comment  {color:#cc9999;}\n .keyword  {color:#000000;font-weight: bold;}\n .builtin  {color:#006600;font-weight: bold;}\n .string  {color:#00A033;}\n .syschar {color:#993333;}\n .operchar {color:#330033;}\n .bracket3 {color:#0000FF;}\n .numlines {color:#000000;}\n .number {color:#009999;}\n .type {color:#0000FF;}"
   HEADER_CSS = "\$DOCTYPE$\n<html>\n<head>\n<style>\n<!-- \n \$CSS_FILE$ \n-->\n</style>\n</head>\n\$REST$"
   HEADER_CSS_FILE = "\$DOCTYPE$\n<html>\n<head>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"genteecode.css\">\n</head>\n\$REST$"
   FOOTER = "\n</pre>\n</code>\n</body>\n</html>"
   END_TAGS = "</font>"
   END_TAGS_CSS = "</span>"

} 

include
{
   $"..\..\lib\lex\lex.g"
   "lexfgentee.g"
} 

global
{
   arr tags of str = %{
      "",      // normal
      "<font color=\"#cc9999\">",      // comment
      "<font color=\"#000000\">",      // keyword 
      "<font color=\"#006600\">",      // builtin #FF00FF - ping
      "<font color=\"#00A033\">",      // string
      "<font color=\"#993333\">",      // syschar
      "<font color=\"#330033\">",      // operchar
      "<font color=\"#0000FF\">",      // bracket #3
      "<font color=\"#000000\">",      // numLines
      "<font color=\"#009999\">",      // Number
      "<font color=\"#00ccff\">"       // type       
   } 
   arr tags_css of str = %{
      "",      // normal, nothing needed
      "<span class=comment>",      // comment
      "<span class=keyword>",      // keyword
      "<span class=builtin>",      // builtin
      "<span class=string>",       // string
      "<span class=syschar>",      // syschar
      "<span class=operchar>",     // bracket #2
      "<span class=bracket3>",     // bracket #3
      "<span class=numlines>",     // numLines
      "<span class=number>",       // number
      "<span class=type>"          // type      
   } 
}
 
/*-----------------------------------------------------------------------------
*
* ID: num2str 31.10.06 <version>
* 
* Summary: Convert number lines to the string type
*
* Parameters: 
*           uint number   -  number of lines
*				
* Return :
*        str - converted string
*        
-----------------------------------------------------------------------------*/
func str num2str < result >( uint number )
{
   str tmpStr ;
   int2str( tmpStr, "%d", number ) ;
   result = tmpStr.fillspacer( 5 ) ;
} 
/*-----------------------------------------------------------------------------
*
* ID: detag 31.10.06 <version>
* 
* Summary: Change "<" or ">" symbols on "&lt;" ;"&gt;",&quot;
*
* Parameters: 
*           str stringInfo    -  string for converting
*				
* Return :
*        str - converted string
*        
-----------------------------------------------------------------------------*/
func str detag < result >( str stringInfo )
{
   str strResult
   uint i
   for i = 0, i <= *stringInfo-1, ++i
   {
      str strTmp
      if( stringInfo [ i ] == 0x3C ) : strResult += "&lt;"
      elif( stringInfo [ i ] == 0x3E ) : strResult += "&gt;"
      elif (stringInfo [ i ] == 0x22)  : strResult += "&quot;"
      else 
      {
        strResult += char2str(strTmp,stringInfo [ i ])
        strTmp.clear()
      }
   } 
   result = strResult
} 

/*------------------------------------------------------------------------------
* ID: htmlcodegentee 31.10.06 <version>
* 
* Summary: Convert gentee code to the html

*   Function formatfile - 
*     
*   Parameters: 
*           str namefile    -  name of input file
*	    str OutToFile   -  buffer for converting html code
*				
*   Return :
*        1 - converting buffer
*
------------------------------------------------------------------------------*/
func int htmlcodegentee( str namefile, str outToFile )
{
   str inBuffer, strOutFile, strLine, stemp
   arrout outArr
   uint lex, off, i
   uint igt   // The current gtitem   
   uint startPos, sMainValue, countMult = 0
   byte bNewLine = 1, inBlock = 0, bDot = 0, bDugky = 0
   uint countLines = 1 ;

   outArr.isize = sizeof( lexitem )
   if !( fileexist( namefile ) )
   {
      print( "File not found \n" )
      return 0 ;
   } 
   inBuffer.read( namefile )
   lex = lex_init( 0, lexfgentee.ptr( ) )
   gentee_lex( inBuffer -> buf, lex, outArr )
   //print("------------------------ddd--\n") 
   //
   off = outArr.data.ptr( )
   str stemp1
   fornum i = 0, * outArr
   {
      uint li

      li as off -> lexitem

      stemp1.clear( )

      //print( "type=\( hex2stru( "", li.ltype ) ) pos = \( li.pos ) len=\( li.len ) \( hex2stru( "", li.value ) ) \n" )
      if( li.ltype == $FG_NAME )
      {
         uint uKod
         if( li.value == $KEY_INCLUDE || li.value == $KEY_FUNC || li.value == $KEY_GLOBAL
             || li.value == $KEY_DEFINE || li.value == $KEY_IMPORT || li.value == $KEY_METHOD
             || li.value == $KEY_OPERATOR || li.value == $KEY_TYPE || li.value == $KEY_IFDEF 
			    || li.value == $KEY_EXTERN)
         {
            startPos = * strLine
            sMainValue = li.value
            bNewLine = 0
            strLine.fillspacer( startPos )
            strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + "" + tags_css [ 2 ] +stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
         } 
         elif ( li.value == $KEY_ARR || li.value == $KEY_BUF || li.value == $KEY_BYTE || li.value == $KEY_DOUBLE ||
              li.value == $KEY_FLOAT || li.value == $KEY_HASH || li.value == $KEY_INT || li.value == $KEY_LONG ||
              li.value == $KEY_SHORT || li.value == $KEY_STR || li.value == $KEY_UBYTE || li.value == $KEY_UINT ||
              li.value == $KEY_ULONG || li.value == $KEY_USHORT )
         {
            uKod = 10
            if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ uKod ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS ; bNewLine = 0
            else : strLine += tags_css [ uKod ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
         }
         elif ( li.value == $KEY_AS || li.value == $KEY_BREAK || li.value == $KEY_CASE || li.value == $KEY_CONTINUE ||
              li.value == $KEY_DEFAULT || li.value == $KEY_DO || li.value == $KEY_ELIF || li.value == $KEY_ELSE ||
              li.value == $KEY_FOR || li.value == $KEY_FOREACH || li.value == $KEY_GOTO || li.value == $KEY_IF ||
              li.value == $KEY_LABEL || li.value == $KEY_OF || li.value == $KEY_RETURN  || li.value == $KEY_SWITCH ||
			     li.value == $KEY_SUBFUNC || li.value == $KEY_WHILE || li.value == $KEY_FORNUM)
         {
            uKod = 3
            if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ uKod ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS ; bNewLine = 0
            else : strLine += tags_css [ uKod ] + "<B>"+stemp.substr( inBuffer, li.pos, li.len ) + "</B>"+$END_TAGS_CSS
         }
         else
         {
            if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + stemp.substr( inBuffer, li.pos, li.len ); bNewLine = 0
            else : strLine += stemp.substr( inBuffer, li.pos, li.len )
         } 
      } 
      elif( li.ltype == $FG_STRING || li.ltype == $FG_MACROSTR )
      {
         if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 4 ] + detag( stemp.substr( inBuffer, li.pos, li.len ) ) + $END_TAGS_CSS ; bNewLine = 0
         else : strLine += tags_css [ 4 ] + detag( stemp.substr( inBuffer, li.pos, li.len ) ) + $END_TAGS_CSS
      }
      elif( li.ltype == $FG_BINARY)
      {
         if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 7 ] + stemp.substr( inBuffer, li.pos, li.len )  + $END_TAGS_CSS ; bNewLine = 0
         else : strLine += tags_css [ 7 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
      }
      elif( li.ltype == $FG_COMMENT )
      {
         //strLine += stemp.substr( inBuffer, li.pos, li.len )
         str commentBuf = stemp.substr( inBuffer, li.pos, li.len )
         arr commentArr of str ;
         commentBuf.lines( commentArr, 0 )
         //uint cur
         foreach cur, commentArr
         {
            strLine += tags_css [ 8 ] + num2str( countLines ++ ) + $END_TAGS_CSS + tags_css [ 1 ] + cur + $END_TAGS_CSS
         } 
         strLine += "\n"
         //if (bNewLine) : bNewLine=0
      } 
      elif( li.ltype == $FG_LINECOMMENT )
      {
         if( bNewLine )
         {
            strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 1 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
            bNewLine = 0
         } 
         else : strLine += tags_css [ 1 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
      } 
      elif( li.ltype == $FG_SPACE || li.ltype == $FG_TAB )
      {
         //off += sizeof( lexitem )
         if( bNewLine )
         {
            strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + "" + stemp.substr( inBuffer, li.pos, li.len )
            bNewLine = 0
         } 
         else : strLine += stemp.substr( inBuffer, li.pos, li.len )
         //continue
      } 
      elif( li.ltype == $FG_NUMBER || li.ltype == $FG_MACRO )
      {
         if( bNewLine )
         {
            bNewLine = 0
            strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 9 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
         } 
         else : strLine += tags_css [ 9 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
      } 
      elif( li.ltype == $FG_OPERCHAR )
      {
         if( bNewLine )
         {
            strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 6 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
            bNewLine = 0
         } 
         else : strLine += tags_css [ 5 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
      } 
      elif( li.ltype == $FG_UNKNOWN )
      {
         if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + stemp.substr( inBuffer, li.pos, li.len );bNewLine=0
         else : strLine += stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_SYSCHAR )
      {
         str cTmp = ""
         if( li.value == 0x29 ) : cTmp = ""
         if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + tags_css [ 5 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS ; bNewLine = 0
         else : strLine += cTmp + tags_css [ 5 ] + stemp.substr( inBuffer, li.pos, li.len ) + $END_TAGS_CSS
      } 
      elif( li.ltype == $FG_LINE )
      {
         //strLine += stemp.substr( inBuffer, li.pos, li.len )
         if( bNewLine ) : strLine += tags_css [ 8 ] + num2str( countLines ) + $END_TAGS_CSS + "" + stemp.substr( inBuffer, li.pos, li.len )
         else : strLine += stemp.substr( inBuffer, li.pos, li.len )

         strOutFile += strLine
         //print(strLine+"----111111 \n")
         bNewLine = 1
         countLines ++ ;
         strLine.clear( )
      } 
      stemp.clear( )
      off += sizeof( lexitem )
   } 
   outToFile = strOutFile
   lex_delete( lex )
   return 1
} 


func uint process_file( str namefile )
{
   uint loadFile, writeFile
   str strtoFile, outData, snewfile

   strtoFile += $HEADER_CSS
   if( ! htmlcodegentee( namefile, outData ) ) : return 0 ;
   strtoFile += outData + $FOOTER
   snewfile.fsetext( namefile, "html" )
   if !( writeFile = open( snewfile, $OP_CREATE ) ) : return 0
   strtoFile.write( writeFile )
   close( writeFile )
   return 1
} 
