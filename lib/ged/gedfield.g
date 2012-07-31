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

method uint ged.findfield( str name )
{
   return ged_findfield( this, name.ptr())  
}

method gedfield ged.field( uint ind )
{
   return ged_field( this, ind )->gedfield
}

method uint ged.fieldcount
{
   return this.head->gedhead.numfields
}

method uint ged.fieldptr( uint ifield )
{
   return ged_fieldptr( this, this.reccur, ifield )
}

method uint ged.getuint( uint ifield )
{
   return ged_getuint( this, this.reccur, ifield )
}

method long ged.getlong( uint ifield )
{
   return ged_getlong( this, this.reccur, ifield )
}

method float ged.getfloat( uint ifield )
{
   return ged_getfloat( this, this.reccur, ifield )
}

method double ged.getdouble( uint ifield )
{
   return ged_getdouble( this, this.reccur, ifield )
}

method str ged.getstr( uint ifield, str ret )
{
   ret.clear()
   switch this.field( ifield ).ftype
   {
      case $FT_BYTE, $FT_SHORT, $FT_INT : ret += int( this.getuint( ifield ))
      case $FT_UBYTE, $FT_USHORT, $FT_UINT : ret += this.getuint( ifield )
      case $FT_FLOAT : ret += this.getfloat( ifield )
      case $FT_LONG : ret += this.getlong( ifield )
      case $FT_ULONG : ret += ulong( this.getlong( ifield ))
      case $FT_DOUBLE :  ret += this.getdouble( ifield )
      case $FT_STR
      {
         uint ptr = this.fieldptr( ifield )
         if ( ptr + this.field( ifield ).width - 1 )->ubyte
         {
            ret.append( ptr, this.field( ifield ).width ) 
         }
         else : ret.append( ptr, mlen( ptr ))
      }
      case $FT_USTR
      {
         ustr utemp
         uint ptr = this.fieldptr( ifield )
         if ( ptr + this.field( ifield ).width - 2 )->ushort
         {
            utemp.copy( ptr, this.field( ifield ).width )
            utemp.setlen( this.field( ifield ).width >> 1 )
         }
         else : utemp.copy( ptr )
         ret += str( utemp )
      }  
   }
   return ret
}

