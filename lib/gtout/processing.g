/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtout 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func output( gt2item root )
{
   str      curdir
   gt2items gt2s
   
   getcurdir( curdir )
   verifypath( root.get( "folder" ), 0->arr )
   setcurdir( root.get( "folder" ) )
   foreach cur, root.items( gt2s )
   {
      str flag out filename curdata preout
      uint  outfunc

      if cur.get( "folder" )
      {
         output( cur )
         continue
      }
      cur.get("flag", flag )
      if flag %!= _flag : continue
      cur.get( "pattern", flag )
      if !( outfunc = getid( flag )) : continue
      preout@outfunc->func( cur )
      cur.process( preout, out, 0->arr )
      
      filename.getfilename( cur )
      curdata.read( filename )
      
      if curdata.crc() != out.crc()
      { 
         out.write( filename ) 
         print("Processing = \(cur.name) \(filename)\n")
      }          
   }
     
   setcurdir( curdir )
}

func processing( gt2 igt )
{
   uint root

   root as igt.find("root")
   output( root )   
}         
