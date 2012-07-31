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

HINSTANCE    handledll;

// See ged.h -> Type of fields

uint  fsizes[] = { 0, 1, 1, 2, 2, 4, 4, 8, 8, 4, 8, 0, 0 };

BOOL WINAPI DllMain( HINSTANCE hinstDll, DWORD fdwReason,
                       LPVOID lpReserved )
//BOOL WINAPI _DllMainCRTStartup( HINSTANCE hinstDll, DWORD fdwReason,
//                       LPVOID lpReserved )
{
   if ( fdwReason == DLL_PROCESS_ATTACH )
   {
      handledll = hinstDll;
      mem_init();
   }
   return ( TRUE );
}

pged  ged_init( pged pdb )
{
   pdb->gm = mem_alloc( sizeof( gedmem ));

   mem_zero( pdb->gm, sizeof( gedmem ));
   buf_init( &pdb->gm->record );
   buf_init( &pdb->gm->data );
   buf_init( &pdb->gm->head );
   str_init( &pdb->gm->dbname );
   str_init( &pdb->gm->dbfile );

   str_copyzero( &pdb->gm->dbname, pdb->filename );
   os_filefullname( &pdb->gm->dbname, &pdb->gm->dbfile );
   return pdb;
}

BOOL ged_delete( pged pdb )
{
   buf_delete( &pdb->gm->head );
   buf_delete( &pdb->gm->data );
   buf_delete( &pdb->gm->record );
   str_delete( &pdb->gm->dbname );
   str_delete( &pdb->gm->dbfile );
   mem_free( pdb->gm );
   return TRUE;
}

uint ged_error( pged pdb, uint code )
{
   uint ret;

   pdb->error = code;
   pdb->filename = buf_ptr( PFILE );
   if ( pdb->call )
   {
      pdb->call( pdb->nfyparam, &ret, ( puint )pdb );
      pdb->error = ret;
   }
   return !pdb->error;
}

BOOL  ged_read( pged pdb, pbuf ret, long64 pos, uint size )
{
   if ( !size )
      size = ( uint )os_filesize( pdb->handle );

   buf_reserve( ret, size );

   os_filepos( pdb->handle, pos, pos < 0 ? FSET_END : FSET_BEGIN );

   if ( size && !os_fileread( pdb->handle, buf_ptr( ret ), size ))
      ged_error( pdb, GDE_READFILE );

   buf_setlen( ret, size );

   return !pdb->error;
}

BOOL  ged_write( pged pdb, pubyte data, long64 pos, uint size )
{
   os_filepos( pdb->handle, pos, pos < 0 ? FSET_END : FSET_BEGIN );

   if ( !os_filewrite( pdb->handle, data, size ))
      ged_error( pdb, GDE_WRITEFILE );

   return !pdb->error;
}

BOOL ged_close( pged pdb )
{
   os_fileclose( pdb->handle );
   return ged_delete( pdb );
}

BOOL ged_create( pged pdb, pgedfieldinit pfi )
{
   gedhead  head;
   pbuf     out;
   pubyte   genteeinfo = "Open source Gentee database format http://www.gentee.com";

   ged_init( pdb );
   mem_zero( &head, sizeof( gedhead ));
   out = PDATA;
   head.ext = GED_STRING;
   head.size = sizeof( gedhead );

   buf_append( out, ( pubyte )&head, sizeof( gedhead ) );
   
   if ( os_fileexist( PFILE ) && !ged_error( pdb, GDE_GEDEXIST ))
      return !pdb->error;

   pdb->handle = os_fileopen( PFILE, FOP_CREATE );
   
   if ( !pdb->handle )
      return ged_error( pdb, GDE_OPENFILE );

   while ( pfi->ftype )
   {
      buf_appendch( out, ( ubyte )( pfi->ftype & 0xFF ));
      if ( !fsizes[ pfi->ftype & 0xFF ] )
         buf_appendch( out, ( ubyte )min( 255, pfi->ftype >> 16 ));
      buf_append( out, pfi->name, lstrlen( pfi->name ) + 1 );
      head.numfields++;   
      pfi++;
   }
   buf_appendch( out, GEI_GENTEE );
   buf_appendushort( out, (ushort)( lstrlen( genteeinfo ) + 1 ));
   buf_append( out, genteeinfo, lstrlen( genteeinfo ) + 1 );
   head.oversize = ( ushort )buf_len( out );

   if ( pdb->autoid )
   {
      head.autoid = ( ushort )pdb->autoid;
      buf_appenduint( out, 0 );
   }
   mem_copy( buf_ptr( out ), ( pubyte )&head, sizeof( gedhead ));
   if ( !os_filewrite( pdb->handle, buf_ptr( out ), buf_len( out )))
      return ged_error( pdb, GDE_WRITEFILE );

   os_fileclose( pdb->handle );

   ged_delete( pdb );

   return !pdb->error;
}

BOOL ged_open( pged pdb )
{
   uint   i;
   pubyte ptr;

   ged_init( pdb );

   pdb->handle = os_fileopen( PFILE, 0 );
   
   if ( !pdb->handle )
      return ged_error( pdb, GDE_OPENFILE );
   
   ged_read( pdb, PDATA, 0, 0 );
   
   pdb->db = buf_ptr( PDATA );
   pdb->head = ( pgedhead )pdb->db;
   buf_reserve( PHEAD, pdb->head->oversize + pdb->head->numfields * sizeof( gedfield ));
   buf_copy( PHEAD, pdb->db, pdb->head->oversize ); 
   pdb->head = ( pgedhead )buf_ptr( PHEAD );

   if ( pdb->head->ext != GED_STRING )
      return ged_error( pdb, GDE_FORMAT );

   pdb->fields = ( pgedfield )( ( pubyte )pdb->head + pdb->head->oversize );
   pdb->fsize = 1; // The first byte is the deleted mark
   ptr = ( pubyte )pdb->head + sizeof( gedhead );
   for ( i = 0; i < pdb->head->numfields; i++ )
   {
      pdb->fields[ i ].ftype = *ptr++;
      pdb->fields[ i ].width = fsizes[ pdb->fields[ i ].ftype ] ? 
                       fsizes[ pdb->fields[ i ].ftype ] : *ptr++;
      pdb->fields[ i ].offset = ( ushort )pdb->fsize; 

      if ( pdb->fields[ i ].ftype == FT_USTR )
         pdb->fields[ i ].width <<= 1;
      pdb->fields[ i ].name = ptr;
      ptr += lstrlen( ptr ) + 1;
      pdb->fsize += pdb->fields[ i ].width;
   }
   if ( pdb->head->autoid )
      pdb->autoid = *( puint )( pdb->db + buf_len( PDATA ) - sizeof( uint ));

   pdb->reccount = ( buf_len( PDATA ) - pdb->head->oversize - 
                   ( pdb->head->autoid ? sizeof( uint ) : 0 )) / pdb->fsize;
   pdb->db += pdb->head->oversize;
   buf_reserve( PRECORD, pdb->fsize + sizeof( uint ));
   ged_goto( pdb, 1 );

   return !pdb->error;
}

uint  ged_goto( pged pdb, uint pos )
{
   if ( pos > pdb->reccount )
      pos = 0;
   pdb->reccur = pos;
   pdb->recptr = ( pos ? pdb->db + ( pos - 1 ) * pdb->fsize : buf_ptr( PRECORD ));
   return pdb->reccur;
}

uint  ged_recno( pged pdb )
{
   return pdb->reccur;
}

BOOL  ged_eof( pged pdb )
{
   return !pdb->reccur;
}
