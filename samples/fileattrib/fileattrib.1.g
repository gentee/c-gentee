/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: fileattrib 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func main< main >
{
   uint  mode attrib
   str   temp
   str   path
   ffind fd
      
   if argc() > 1
   {
      if argv( temp, 1 ) %== "on" : mode = 1
      elif argv( temp, 1 ) %== "off" : mode = 2
      argv( path, 2 )
   }
   if !mode
   {
      mode = conrequest( "Choose an action (press a number key):
1. Turn on readonly attribute
2. Turn off readonly attribute
3. Exit\n", "1|2|3" ) + 1

      if mode == 3 : return      

      congetstr( "Specify a filename or a wildcard: ", path )
   }
   print( "Action: turn \(?(mode == 1, "ON", "OFF")) readonly attribute\n" )
   fd.init( path, $FIND_FILE | $FIND_RECURSE )
   foreach cur,fd
   {
      attrib = getfileattrib( cur.fullname )
      if mode == 1 : attrib |= $FILE_ATTRIBUTE_READONLY
      else : attrib &= ~$FILE_ATTRIBUTE_READONLY
      setfileattrib( cur.fullname, attrib )
      print( "\(cur.fullname)\n" )
   }
   congetch( "Press any key..." )
}
