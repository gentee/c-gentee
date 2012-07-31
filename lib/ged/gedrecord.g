/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

method uint ged.append()
{
   return ged_append( this, 0 )
}

method uint ged.append( collection cdata )
{
   buf  data
   uint i
   arrustr aus
   
   fornum i, *cdata
   {
      uint field
      
      field as this.field( i )

      switch field.ftype
      {
         case $FT_BYTE, $FT_SHORT, $FT_INT, $FT_FLOAT
         {
            if cdata.gettype( i ) == str : data += int( cdata[i] )
            else : data += cdata[i]
         }
         case $FT_UBYTE, $FT_USHORT, $FT_UINT
         {
            if cdata.gettype( i ) == str : data += uint( cdata[i] )
            else : data += cdata[i]
         }
         case $FT_ULONG, $FT_DOUBLE
         {
            if cdata.gettype( i ) == uint : data += ulong( cdata[i] )
            else : data += cdata.ptr( i )->ulong
         }
         case $FT_LONG
         {
            if cdata.gettype( i ) == uint : data += long( cdata[i] )
            else : data += cdata.ptr( i )->long
         }
         case $FT_STR
         {
            if cdata.gettype( i ) == str : data += cdata[i]->str.ptr() 
         }
         case $FT_USTR
         {
            if cdata.gettype( i ) == ustr : data += cdata[i]->str.ptr()
            elif cdata.gettype( i ) == str
            {
               aus += ustr( cdata[i]->str ) 
               data += aus[ *aus - 1 ].ptr()
            }
         }
      }
   }
   return ged_append( this, data.ptr())
}

method uint ged.isdel()
{
   return ged_isdel( this )
}