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

method uint  gedsel.open( ged pdb, collection sfilter sindex )
{
   buf filter
   buf index
   uint  i len
   ustr  utemp stemp

   filter += 0   
   if !*sfilter : filter += $SF_ALL
   fornum i, *sfilter
   {
      filter += sfilter[i]
      
      if ( sfilter[i] & 0xffffff ) > $SF_ALL
      {
         uint ifield
         
         if sfilter.gettype( ++i ) == str
         { 
            ifield = pdb.findfield( sfilter[i]->str ) - 1
         }
         else : ifield = sfilter[i] - 1
         if ifield >= pdb.fieldcount() : return 0
         filter += ifield
         uint pfield
         pfield as pdb.field( ifield )
         i++
         switch pfield.ftype
         {
            case $FT_BYTE, $FT_SHORT, $FT_INT, $FT_FLOAT,$FT_UBYTE, 
                 $FT_USHORT, $FT_UINT 
            {
               if sfilter.gettype( i ) == str : filter += uint( sfilter[i] )
               else : filter += sfilter[i]
            }
            case $FT_LONG, $FT_ULONG, $FT_DOUBLE
            {
               if sfilter.gettype( i ) == uint : filter += ulong( sfilter[i] )
               else : filter += sfilter.ptr( i )->ulong
            }
            case $FT_STR
            {
               stemp.clear()
               
               switch  sfilter.gettype( i )
               {
                  case str : stemp = sfilter[i]->str    
                  case ustr : stemp = str( sfilter[i]->ustr )
               } 
               len = min( 255, *stemp )
               filter += len
               filter.append( stemp.ptr(), len )
            }
            case $FT_USTR
            {
               utemp.clear()
               
               switch sfilter.gettype( i )
               { 
                  case str : utemp = ustr( sfilter[i]->str )
                  case ustr : utemp = sfilter[i]->ustr
               }
               len = min( 255, *utemp )
               filter += len
               filter.append( utemp.ptr(), len << 1 )
            }
         }         
      }
   }
//   filter += $SF_END
   filter.ptr()->uint = *filter - sizeof( uint )
   index += 0
   fornum i = 0, *sindex
   {
      uint ifield
      if sindex.gettype( i ) == str
      { 
         ifield = pdb.findfield( sindex[i]->str ) - 1
      }
      else : ifield = sindex[i] - 1
      if ifield >= pdb.fieldcount() : return 0
      index += ifield
      index += sindex[ ++i ]  
   }
   index.ptr()->uint = *index - sizeof( uint )
   return ges_select( this, pdb, filter.ptr(), index.ptr() )      
}

method uint gedsel.reverse()
{
   return ges_reverse( this )
}

method uint gedsel.update()
{
   return ges_update( this )
}

method uint gedsel.close()
{
   return ges_close( this )
}

operator uint *( gedsel psel )
{
   return psel.reccount
}

method uint gedsel.eof( fordata fd )
{
   return ges_eof( this )
}

method uint gedsel.first( fordata fd )
{
   return ges_goto( this, 1 )   
}

method uint gedsel.next( fordata fd )
{
   return ges_goto( this, this.reccur + 1 )   
}
