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

#include "ged.h"

void ged_setuint( pgedfield pfield, pubyte ptr, uint ival )
{
   pubyte offset = ptr + pfield->offset;
   switch ( pfield->ftype )
   {
      case FT_BYTE:
      case FT_UBYTE:
         *offset = ( ubyte )ival;
         break;
      case FT_SHORT:
      case FT_USHORT:
         *( pushort )offset = ( ushort )ival;
         break;
      case FT_INT:
      case FT_UINT:
         *( puint )offset = ival;
         break;
   }
}

uint ged_append( pged pdb, puint ptr )
{
   uint  i, aoff = 0;
   pubyte offset;
   pubyte prec = buf_ptr( PRECORD );

//   *prec = 0;  // Delete mask
   mem_zero( prec, pdb->fsize );

   for ( i = 0; i < pdb->head->numfields; i++ )
   {
      offset = prec + pdb->fields[ i ].offset;
      if ( !ptr )
         continue;

      switch ( pdb->fields[ i ].ftype )
      {
         case FT_BYTE:
         case FT_UBYTE:
            *offset = ( ubyte )*ptr;
            break;
         case FT_SHORT:
         case FT_USHORT:
            *( pushort )offset = ( ushort )*ptr;
            break;
         case FT_INT:
         case FT_UINT:
            *( puint )offset = *ptr;
            break;
         case FT_LONG:
         case FT_ULONG:
            *( plong64 )offset = *( plong64 )ptr;
            ptr++;
            break;
         case FT_FLOAT:
            *( puint )offset = *ptr;
            break;
         case FT_DOUBLE:
            *( double* )offset = *( double* )ptr;
            ptr++;
            break;
         case FT_STR:
            if ( *ptr )
               mem_copy( offset, ( pubyte )*ptr, min( pdb->fields[ i ].width, 
                      (uint)lstrlen( ( pubyte )*ptr )));
            break;
         case FT_USTR:
            if ( *ptr )
               mem_copy( offset, ( pubyte )*ptr, min( pdb->fields[ i ].width, 
                      (uint)lstrlenW( ( LPWSTR ) *ptr ) << 1 ));
            break;
      }
      ptr++;
   }
   if ( pdb->head->autoid )
   {
      ged_setuint( pdb->fields + pdb->head->autoid - 1, prec, ++pdb->autoid );
      *( puint )( prec + pdb->fsize ) = pdb->autoid;
      pdb->gm->data.use -= sizeof( uint );
      aoff = sizeof( uint );
   }
   ++pdb->reccount;
//   ++pdb->reccount;
   buf_append( PDATA, prec, pdb->fsize + aoff );
   pdb->db = buf_ptr( PDATA ) + pdb->head->oversize;
   ged_goto( pdb, pdb->reccount );
   return ged_write( pdb, prec, -( long64 )aoff, pdb->fsize + aoff );
}

uint ged_isdel( pged pdb )
{
   return *pdb->recptr;
}

/*BOOL ged_delete( pged pdb, uint recno )
{
   return *pdb->recptr;
}*/