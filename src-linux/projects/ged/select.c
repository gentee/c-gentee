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

cmpfunc  fcmp[] = { 0, &cmpbyte, &cmpubyte, &cmpshort, &cmpushort, &cmpint, 
                     &cmpuint, 0, 0, 0, 0, &cmpstr, &cmpustr };

/* Filter format
   uint size of data
   cmd - SF_
       uint - number of the field from 0
       uint - len [for string fields]
       uint - value
*/

/* Index format
   uint - size of data
   uint - number of the field
   uint - flags & len
*/

int    ges_compare( pvoid left, pvoid right, uint param )
{
   pgedfield  pfield;
   pubyte     lrec, rrec;
   pgedsel    psel = (pgedsel)param;
   puint      pind = ( puint )buf_ptr( PINDEX );
   puint      pend = ( puint )(( pubyte )pind + buf_len( PINDEX ));
   uint       len, flag;
   int        ok = 0;
   
   lrec = psel->pdb->db + ( *(pubyte)left - 1 ) * psel->pdb->fsize;
   rrec = psel->pdb->db + ( *(pubyte)right - 1 ) * psel->pdb->fsize;

   while ( pind < pend && !ok )
   {
      pfield = psel->pdb->fields + *pind++;
      flag = *pind++;
      
      len = flag & 0xFFFF;
      if ( !len )
         len = pfield->width;
      ok = fcmp[ pfield->ftype ]( lrec + pfield->offset, 
                                  rrec + pfield->offset, len );
      if ( flag & IF_DESC )
         ok = -ok;
   }
   return ok;
}

BOOL   ges_updateindex( pgedsel psel )
{
   if ( buf_len( PINDEX ))
   {
      quicksort( buf_ptr( PSELECT ), psel->reccount, sizeof( uint ), 
                 (cmpfunc)&ges_compare, (uint)psel );
   }
   return TRUE;
}

BOOL   ges_reverse( pgedsel psel )
{
   uint   i, itemp, count = psel->reccount >> 1;
   puint  pi = ( puint )buf_ptr( PSELECT );

   for (i = 0; i < count; i++ )
   {
      itemp = pi[i];
      pi[i] = pi[ psel->reccount - i - 1 ];
      pi[ psel->reccount - i - 1 ] = itemp;
   }
   ges_goto( psel, psel->reccount - psel->reccur + 1 );
   return TRUE;
}

BOOL   ges_index( pgedsel psel, puint index )
{
   buf_copy( PINDEX, (pubyte)index + sizeof( uint ), *index );

   return ges_updateindex( psel );
}

BOOL   ges_update( pgedsel psel )
{
   uint   i;
   pubyte prec;
   pged   pdb;
   puint  pstart = ( puint )buf_ptr( PFILTER );
   puint  pend = ( puint )(( pubyte )pstart + buf_len( PFILTER ));

   pdb = psel->pdb;
   prec = pdb->db;
   buf_clear( PSELECT );
   for ( i = 0; i < pdb->reccount; i++ )
   {
      puint  pflt = pstart;
      uint   ok = 0;
      uint   ifield, cmd, not, or, len, type;

      if ( *prec )   // Deleted mark
         continue;
      while ( pflt < pend )
      {
         cmd = *pflt & 0xFFFFFF;
         not = *pflt & SF_NOT;
         or  = *pflt & SF_OR;
         
         if ( cmd > SF_ALL )
         {
            ifield = *++pflt;
            pflt++;
            type = pdb->fields[ ifield ].ftype;
            if ( type == FT_STR )
               len = *pflt++;
            else
               if ( type == FT_USTR )
                  len = *pflt++;
         }
         switch ( cmd )
         {
            case SF_ALL:
               ok = !*prec;
               break;
            case SF_EQ:
               ok = !fcmp[ type ]( pflt, 
                           prec + pdb->fields[ ifield ].offset, len );
               break;
            case SF_LESS:
               ok = fcmp[ type ](  
                           prec + pdb->fields[ ifield ].offset, pflt, len ) < 0;
               break;
            case SF_GREAT:
               ok = fcmp[ type ]( 
                           prec + pdb->fields[ ifield ].offset, pflt,  len ) > 0;
               break;
            case SF_END:
               break;
         }
         if ( not )
            ok = !ok;
         if ( or )
         {
            if ( ok ) break;
         }
         else
            if ( !ok ) break;
         switch ( type )
         {
            case FT_STR:
               pflt = ( puint )((pubyte)pflt + len );
               break;
            case FT_USTR:
               pflt = ( puint )((pubyte)pflt + ( len << 1 ));
               break;
            default:
               pflt++; 
         }
      }
      if ( ok )
      {
         buf_appenduint( PSELECT, i + 1 );
      }
      prec += pdb->fsize;
   }
   psel->reccount = buf_len( PSELECT ) >> 2;

   ges_updateindex( psel );
   ges_goto( psel, 1 );
   return TRUE;
}

BOOL   ges_select( pgedsel psel, pged pdb, puint filter, puint index )
{
   psel->sm = mem_alloc( sizeof( selmem ));

   mem_zero( psel->sm, sizeof( selmem ));
   buf_init( PSELECT );
   buf_init( PINDEX );
   buf_init( PFILTER );

   psel->pdb = pdb;
   buf_copy( PFILTER, (pubyte)filter + sizeof( uint ), *filter );
   ges_update( psel );
   ges_index( psel, index );
   ges_goto( psel, 1 );

   return TRUE;
}

BOOL   ges_close( pgedsel psel )
{
   buf_delete( PSELECT );
   buf_delete( PINDEX );
   buf_delete( PFILTER );
   mem_free( psel->sm );

   return TRUE;
}

uint  ges_goto( pgedsel psel, uint pos )
{
   if ( pos > psel->reccount )
      pos = 0;
   psel->reccur = pos;
   return psel->reccur;
}

uint  ges_recno( pgedsel psel )
{
   if ( !psel->reccur )
      return 0;

   return *( ( puint )buf_ptr( PSELECT ) + psel->reccur - 1 );
}

BOOL  ges_eof( pgedsel psel )
{
   return !psel->reccur;
}

/*
pgedsel ged_select( pgedsel psel, pged pdb )
{
   return psel;
}

pubyte ged_goto( pgedsel psel, uint pos )
{
   pged pdb = psel->pdb;

   if ( pos > pdb->reccount && !pos )
   {
      psel->reccur = 0;
      psel->recptr = buf_ptr( &psel->record );
      mem_zero( psel->recptr, pdb->fsize + 1 );
   }
   else
   {
      psel->reccur = pos;
      psel->recptr = ( pubyte )buf_ptr( &pdb->data ) + pdb->head->oversize +
                    ( pos - 1 ) * pdb->fsize; 
   }
   return psel->recptr;
}
*/