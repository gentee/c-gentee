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
* ID: formatfile 20.10.06 0.0.A.
*
* Author: Aleksandr Antypenko ( santy )
*
* Summary: Function of utility autoformatting Gentee sources
*
******************************************************************************/

include
{
   $"..\..\lib\lex\lex.g"
   "lexfgentee.g"
} 

type puncmult < protected >
{
   uint uMValue
   uint startPos
} 

operator puncmult =( puncmult left right )
{
   left.uMValue = right.uMValue
   left.startPos = right.startPos
   return left
} 

/******************************************************************************
*   Function formatfile - 
*     
*   Parameters: 
*           str namefile    -  addrees of flinfo structure
*           int intend      -  path and pattern for search files
*	    		uint lenthline  -  max length of line
*	    		byte bCreateNew -  1- create bak file, 0- overwrite existent file
*				
*   Return :
*        1 - formatting file
*
******************************************************************************/
func int formatfile( str namefile, uint indend, uint lenthLine, byte bCreateNew )
{
   str inBuffer, strOutFile, strLine, stemp
   arrout outArr
   uint lex, off, i
   uint igt   // The current gtitem   
   uint startPos, sMainValue, countMult = 0
   byte bNewLine = 0, inBlock = 0, bDot = 0, bDugky = 0
   stack puncStk of puncmult
   puncmult pMult


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

      //if (li.ltype != $FG_UNKNOWN)
      //{
      //print("type=\( hex2stru("", li.ltype )) pos = \(li.pos) len=\(li.len ) \(hex2stru("", li.value )) \n")
      //print(stemp.substr( inBuffer, li.pos, li.len)+" \n")
      if( li.ltype == $FG_NAME )
      {
         if( li.value == $KEY_INCLUDE || li.value == $KEY_FUNC || li.value == $KEY_GLOBAL
         || li.value == $KEY_DEFINE || li.value == $KEY_IMPORT || li.value == $KEY_METHOD
         || li.value == $KEY_OPERATOR || li.value == $KEY_TYPE || li.value == $KEY_IFDEF )
         {
            startPos = * strLine
            sMainValue = li.value
            bNewLine = 0
            strLine.fillspacer( startPos )
            strLine += stemp.substr( inBuffer, li.pos, li.len )
         } 
         else
         {
            if( bNewLine )
            {
               strLine.fillspacer( * strLine + startPos )
               strLine.fillspacer( * strLine + indend )
               //strLine+="DDDD" 
               strLine += stemp.substr( inBuffer, li.pos, li.len )
               bNewLine = 0
            } 
            else
            {
               str sTmp = ""
               if( bDot ) : sTmp = "" ; bDot = 0
               else : sTmp = " "
               if( strLine [ * strLine + startPos - 1 ] == 0x7B )
               {
                  strLine += "\n"
                  strLine.fillspacer( * strLine + startPos )
                  strLine += sTmp + stemp.substr( inBuffer, li.pos, li.len )
                  strOutFile += strLine
                  strLine.clear( )
                  bNewLine = 1
               } 
               else
               {
                  strLine += sTmp + stemp.substr( inBuffer, li.pos, li.len )
               } 
               //bNewLine = 
            } 
         } 
      } 
      elif( li.ltype == $FG_SPACE || li.ltype == $FG_TAB )
      {
         stemp.clear( )
         off += sizeof( lexitem )
         continue
      } 
      elif( li.ltype == $FG_NUMBER || li.ltype == $FG_MACRO )
      {
         if( bNewLine ) : bNewLine = 0
         strLine += " " + stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_OPERCHAR )
      {
         str stmp = ""
         if( li.value == 0x2E ) : stmp = "" ; bDot = 1
         elif(( li.value == 0x2B2B || li.value == 0x2D2D || li.value == 0x7C7C || li.value == 0x2626 )
         && bNewLine )
         {
            stmp.fillspacer( indend )
            strLine.fillspacer( * strLine + startPos )
            bNewLine = 0
         } 
         elif( li.value == 0x7B25 )
         {
            ++ countMult
            if( countMult > 1 )
            {
               puncmult pMultTmp
               pMultTmp.uMValue = sMainValue
               pMultTmp.startPos = startPos
               puncStk.push( ) -> puncmult = pMultTmp
               startPos = startPos + indend
            } 
            stmp = " "
         } 
         else : stmp = " "
         strLine += stmp + stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_LINECOMMENT || li.ltype == $FG_COMMENT )
      {
         str stmp = ""
         strLine.fillspacer( * strLine + startPos )
         if( li.ltype == $FG_LINECOMMENT ) : stmp.fillspacer( indend )
         strLine += stmp + stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_STRING || li.ltype == $FG_MACROSTR )
      {
         str sTmp = ""
         if( bNewLine )
         {
            strLine.fillspacer( * strLine + startPos + indend ) ;
            //sTmp = ?( li.ltype == $FG_MACROSTR, " ", "" )
         } 
         else : sTmp = ?( li.ltype == $FG_STRING, " ", "" )
         strLine += sTmp + stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_UNKNOWN )
      {
         strLine += " " + stemp.substr( inBuffer, li.pos, li.len )
      } 
      elif( li.ltype == $FG_SYSCHAR )
      {
         if( li.value == 0x28 || li.value == 0x29 || li.value == 0x2C )
         {
            if( bNewLine ) : strLine.fillspacer( * strLine )
            strLine += ?( li.value == 0x29, " ", "" ) + stemp.substr( inBuffer, li.pos, li.len )
         } 
         elif( li.value == 0x7B )
         {
            ++ countMult
            if( countMult > 1 )
            {
               puncmult pMultTmp
               pMultTmp.uMValue = sMainValue
               pMultTmp.startPos = startPos
               puncStk.push( ) -> puncmult = pMultTmp
               startPos = startPos + indend
            } 
            bDugky = 1
            // add to stack
            if( bNewLine )
            {
               strLine.fillspacer( * strLine + startPos )
               strLine += stemp.substr( inBuffer, li.pos, li.len )
               //
               //strOutFile += strLine+"\n"
               //strLine.clear()
               bNewLine = 0
               inBlock = 1               //?( li.value == 0x7B,1,0)
            } 
            else
            {
               strLine += "\n"
               strLine.fillspacer( * strLine + startPos )
               strLine += stemp.substr( inBuffer, li.pos, li.len )
               strOutFile += strLine + "\n"
               strLine.clear( )
               inBlock = 1
               bNewLine = 1
            } 
         } 
         elif( li.value == 0x7D )
         {
            if( bNewLine )
            {
               strLine.fillspacer( * strLine + startPos )
               //print (strLine+"----5 \n")
               strLine += stemp.substr( inBuffer, li.pos, li.len )
               strOutFile += strLine + " " ;
               strLine.clear( )
               inBlock = 0
               bNewLine = 0
            } 
            else
            {
               strLine += "\n"
               strLine.fillspacer( * strLine + startPos )
               //print (strLine+"----6 \n")
               strLine += stemp.substr( inBuffer, li.pos, li.len )
               strOutFile += strLine
               strLine.clear( )
               inBlock = 0
               bNewLine = 1
            } 
            bDugky = 0
            if( countMult > 1 )
            {
               puncmult pMultTmp
               pMultTmp = puncStk.top( ) -> puncmult
               sMainValue = pMultTmp.uMValue
               startPos = pMultTmp.startPos
               puncStk.pop( )
            } 
            -- countMult
         } 
         else : strLine += " " + stemp.substr( inBuffer, li.pos, li.len )

      } 
      elif( li.ltype == $FG_LINE )
      {
         strLine += stemp.substr( inBuffer, li.pos, li.len )
         strOutFile += strLine
         //print(strLine+"----111111 \n")
         bNewLine = 1
         strLine.clear( )
      } 
      //}
      stemp.clear( )
      off += sizeof( lexitem )
   } 
   if( bCreateNew )
   {
      str snewfile
      snewfile.fsetext( namefile, "bak" )
      if !( copyfile( namefile, snewfile ) ) : print( "Error create backup file. \n" ) ; return 0
      else : print( "Backup file -- " + snewfile + " -- was created.\n" )
   } 
   strOutFile.write( namefile )
   //
   lex_delete( lex )
   //print("--------------------------\n") 
   //congetch("Press any key...")
   return 1
} 

