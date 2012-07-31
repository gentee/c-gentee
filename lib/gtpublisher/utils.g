/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS  FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func uint fileupdate( str filename, buf data )
{
   uint ret
   file ifile
   str  dir
   
   verifypath( dir.fgetdir( filename ), 0->arrstr )
   ifile.open( filename, $OP_ALWAYS )
   if ifile.getsize() != *data : ret = 1
   else
   {
      buf  btemp
      
      ifile.read( btemp, 0xFFFFFFFF )
      ret = mcmp( btemp.ptr(), data.ptr(), *data )  
   }
   ifile.close()
   if ret : ret = data.write( filename ) 
   return ret
}

func uint fileupdate( str filename data )
{
   uint ret
   
   data.use--
   ret = fileupdate( filename, data->buf )
   data.use++
   return ret  
} 
