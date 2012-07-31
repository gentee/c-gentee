/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: prepare 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func prepare( gt2item root )
{
   gt2items gt2s
   
   foreach cur, root.items( gt2s )
   {
      str flag out filename curdata preout
      uint  outfunc
      
      if cur.get( "folder" )
      {
         prepare( cur )
         continue
      }
      _gtalias[ cur.name ] = &cur
      cur.get("flag", flag )
      if flag %!= _flag : continue
      "".getlink( cur )
   }
     
}

 
